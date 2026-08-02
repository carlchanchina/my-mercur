FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json bun.lock* ./
COPY packages/api/package.json ./packages/api/
COPY packages/*/package.json ./packages/
COPY apps/admin/package.json ./apps/admin/
COPY apps/vendor/package.json ./apps/vendor/
COPY apps/storefront/package.json ./apps/storefront/

ENV BUN_INSTALL=/usr/local/share/bun
RUN apk add --no-cache curl bash && \
  corepack enable && \
  if [ -f bun.lock ]; then \
    curl -fsSL https://bun.sh/install | bash -s "bun-v1.3.11" && \
    ln -sf $BUN_INSTALL/bin/bun /usr/local/bin/bun && \
    bun install --frozen-lockfile --backend=copyfile; \
  elif [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
  elif [ -f yarn.lock ]; then corepack prepare yarn@1.22.22 --activate && yarn install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  else npm install; \
  fi

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app ./
COPY . .

# Vite bakes the backend URL at build time, so it must be supplied as a build arg.
ARG VITE_MERCUR_BACKEND_URL
ENV VITE_MERCUR_BACKEND_URL=$VITE_MERCUR_BACKEND_URL
RUN cd apps/admin && npm run build
RUN cd apps/vendor && npm run build

# Build API and bundle dashboards
RUN cd packages/api && npm run build

# The production stage copies static assets from packages/api/public. That directory
# only exists when the project ships one; create it if absent so the COPY never fails.
RUN mkdir -p /app/packages/api/public

FROM node:20-alpine AS production
RUN apk add --no-cache curl
WORKDIR /app

# Medusa v2 runs in production via the medusa CLI from packages/api
# (`medusa start`), which loads the compiled .medusa/server build.
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages/api ./packages/api
COPY --from=builder /app/apps/admin/dist ./apps/admin/dist
COPY --from=builder /app/apps/vendor/dist ./apps/vendor/dist

ENV NODE_ENV=production
ENV PORT=9000

WORKDIR /app/packages/api
EXPOSE 9000

# Medusa production server. Reads MEDUSA_WORKER_MODE (server|worker|shared).
# Run migrations before starting the server.
COPY scripts/start.sh /app/scripts/start.sh
RUN chmod +x /app/scripts/start.sh
CMD ["/app/scripts/start.sh"]
