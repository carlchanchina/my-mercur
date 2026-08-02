// Minimal CDP client to pause and dump call stack (connect to local inspector)
const http = require('http');
const crypto = require('crypto');
const net = require('net');

const wsUrl = new Promise((res, rej) => {
  http.get('http://127.0.0.1:9229/json/list', (r) => {
    let d = ''; r.on('data', c => d += c);
    r.on('end', () => { try { res(JSON.parse(d)[0].webSocketDebuggerUrl); } catch(e){ rej(e); } });
  }).on('error', rej);
});

function makeWs(url, onPaused, onMsg) {
  const u = new URL(url);
  const key = crypto.randomBytes(16).toString('base64');
  const sock = net.connect(Number(u.port), u.hostname);
  let pending = {};
  let id = 0;
  let buf = Buffer.alloc(0);
  const callbacks = { onMsg };
  return new Promise((res, rej) => {
    sock.on('error', rej);
    sock.on('connect', () => {
      sock.write(`GET ${u.pathname.replace(u.host,'')||u.pathname} HTTP/1.1\r\nHost: ${u.host}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: ${key}\r\nSec-WebSocket-Version: 13\r\n\r\n`);
    });
    sock.on('data', d => {
      buf = Buffer.concat([buf, d]);
      process();
      function process() {
        if (buf.length < 2) return;
        const op = buf[0]; const l0 = buf[1] & 0x7f;
        let off = 2, len;
        if (l0 === 126) { if(buf.length<4)return; len=buf.readUInt16BE(2); off=4; }
        else if (l0 === 127) return;
        else len = l0;
        if (len === 0 && op===8) { return; }
        if (buf.length < off+len) return;
        const payload = buf.slice(off, off+len).toString();
        buf = buf.slice(off+len);
        if ((op & 0x0f) === 1) {
          let m; try { m = JSON.parse(payload);}catch{return process();}
          if (m.id && pending[m.id]) { pending[m.id](m); delete pending[m.id]; }
          if (m.method === 'Debugger.paused') onPaused(m.params);
          if (m.method) callbacks.onMsg && callbacks.onMsg(m.method);
        }
        if (buf.length) process();
      }
    });
    sock.send = (method, params) => new Promise(resolve => { const mid=++id; pending[mid]=resolve; sendFrame(JSON.stringify({id:mid,method,params:params||{}})); });
    function sendFrame(payload) {
      const b = Buffer.from(payload); const mask = crypto.randomBytes(4);
      let header;
      if (b.length < 126) header = Buffer.from([0x81, 0x80|b.length]);
      else { header = Buffer.from([0x81,0x80|126,0,0]); header.writeUInt16BE(b.length,2); }
      const body = Buffer.alloc(b.length+4); mask.copy(body,0);
      for(let i=0;i<b.length;i++) body[i+4]=b[i]^mask[i%4];
      sock.write(Buffer.concat([header,body]));
    }
    // flush any http handshake header line
    // the first data events may be http response; simplified: rely on frames after connect
  });
}

function dump(params) {
  console.log('### PAUSED ###');
  for (const f of (params.callFrames||[]).slice(0,50)) {
    const fn = f.functionName || '(anon)';
    console.log(`  ${fn} @ ${f.url}:${f.location?f.location.lineNumber+1:'?'}`);
  }
  let a = params.asyncStackTrace, n=0;
  while (a && n<40) { n++;
    for (const f of (a.callFrames||[]).slice(0,8)) if(f.functionName) console.log(`    [async] ${f.functionName} @ ${f.url}:${f.location?f.location.lineNumber+1:'?'}`);
    a = a.parent;
  }
  process.exit(0);
}

(async () => {
  const url = await wsUrl;
  console.log('connecting', url);
  const ws = await makeWs(url, dump);
  await ws.send('Runtime.enable');
  await ws.send('Debugger.enable');
  await ws.send('Debugger.pause');
  console.log('pause requested');
  setTimeout(()=>{ console.log('NO_PAUSE_TIMEOUT'); process.exit(3); }, 15000);
})();
