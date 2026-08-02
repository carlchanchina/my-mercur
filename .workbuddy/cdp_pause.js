// CDP client: connect to inspector, pause, dump call stack
const http = require('http');
const net = require('net');

function getWsUrl() {
  return new Promise((res, rej) => {
    http.get('http://127.0.0.1:9229/json/list', (r) => {
      let d = '';
      r.on('data', (c) => (d += c));
      r.on('end', () => {
        try { res(JSON.parse(d)[0].webSocketDebuggerUrl); } catch (e) { rej(e); }
      });
    }).on('error', rej);
  });
}

// minimal WS client (no masking needed for server->client; we only send small frames masked)
function connect(wsUrl) {
  const u = new URL(wsUrl);
  return new Promise((res, rej) => {
    const key = Buffer.from(Math.random().toString(36).slice(2)).toString('base64');
    const sock = net.connect(Number(u.port), u.hostname);
    sock.on('connect', () => {
      sock.write(
        `GET ${u.pathname} HTTP/1.1\r\nHost: ${u.host}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: ${key}\r\nSec-WebSocket-Version: 13\r\n\r\n`
      );
    });
    const pending = {};
    let buf = Buffer.alloc(0);
    let id = 0;
    sock.on('data', (d) => {
      buf = Buffer.concat([buf, d]);
      // send frame opcode 1, fin1
      function sendRaw(payload) {
        const b = Buffer.from(payload);
        const mask = Buffer.from([1,2,3,4]);
        let header;
        const len = b.length;
        if (len < 126) header = Buffer.from([0x81, 0x80 | len]);
        else { header = Buffer.from([0x81, 0x80 | 126, 0x00, 0x00]); header.writeUInt16BE(len, 2); }
        const body = Buffer.alloc(b.length + 4);
        for (let i=0;i<4;i++) body[i]=mask[i];
        for (let i=0;i<b.length;i++) body[i+4]=b[i]^mask[i%4];
        sock.write(Buffer.concat([header, body]));
      }
      // parse incoming frames (unmasked from server)
      function processFrame() {
        if (buf.length < 2) return;
        const opcode = buf[0] & 0x0f;
        const len0 = buf[1] & 0x7f;
        let offset = 2, len;
        if (len0 < 126) len = len0;
        else if (len0 === 126) { if (buf.length < 4) return; len = buf.readUInt16BE(2); offset = 4; }
        else { return; } // 64-bit not needed
        if (buf.length < offset + len) return;
        const payload = buf.slice(offset, offset + len).toString('utf8');
        buf = buf.slice(offset + len);
        if (opcode === 1) {
          let msg; try { msg = JSON.parse(payload); } catch(e){}
          if (msg) {
            if (msg.id && pending[msg.id]) { pending[msg.id](msg); delete pending[msg.id]; }
            if (msg.method === 'Debugger.paused') { done(msg.params); }
            if (msg.method === 'Runtime.exceptionThrown') { console.error('EXC', JSON.stringify(msg.params)); }
          }
        }
        return processFrame();
      }
      if (opcode===undefined) return; // not connected yet
      function send(method, params) {
        const mid = ++id;
        return new Promise((resolve) => { pending[mid] = resolve; sendRaw(JSON.stringify({id:mid, method, params: params||{}})); });
      }
      // expose
      sock.send = send;
      res(sock);
    });
    sock.on('error', rej);
  });
}

async function main() {
  const wsUrl = await getWsUrl();
  console.log('WS', wsUrl);
  const sock = await connect(wsUrl);
  await sock.send('Runtime.enable');
  await sock.send('Debugger.enable');
  await sock.send('Debugger.pause');
  // wait for paused via done callback set in connect
}
let finished=false;
function done(params){
  if (finished) return; finished=true;
  console.log('=== PAUSED ===');
  const frames = params.callFrames || [];
  console.log('stack depth:', frames.length);
  for (const f of frames.slice(0, 40)) {
    const fn = f.functionName || '(anonymous)';
    const loc = f.location ? `${f.url}:${f.location.lineNumber+1}:${(f.location.columnNumber||0)+1}` : f.url;
    console.log(`  ${fn} @ ${loc}`);
  }
  console.log('=== async stacks ===');
  const asp = params.asyncStackTrace;
  let a = asp; let n=0;
  while(a && n<30){ n++; for(const f of (a.callFrames||[]).slice(0,6)){ if(f.functionName) console.log(`  [async] ${f.functionName} @ ${f.url}:${(f.location?.lineNumber||0)+1}`); } a=a.parent; }
  process.exit(0);
}
// monkey: connect() calls res(sock) before 'paused' handler set? We set done globally above.
main().catch(e=>{console.error('ERR',e.message); process.exit(2)});
setTimeout(()=>{ console.log('TIMEOUT no pause'); process.exit(3); }, 15000);
