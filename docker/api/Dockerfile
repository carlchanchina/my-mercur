FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json bun.lock* package-lock.json* pnpm-lock.yaml* yarn.lock* ./
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
# Copy the whole deps workspace, not just the root node_modules. bun uses an
# isolated layout: each workspace's direct deps live in <workspace>/node_modules
# as symlinks into the root node_modules/.bun store. Copying only the root
# node_modules drops apps/*/node_modules (@mercurjs/*, @types/node) and
# packages/api/node_modules (@medusajs/framework), breaking tsc.
COPY --from=deps /app ./
COPY . .

# Build the admin & vendor dashboard panels first so bundle-dashboards.mjs can
# copy their dist into the Medusa server artifact (it expects apps/<name>/dist).
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
# (`medusa start`), which loads the compiled .medusa/server build. The CLI lives
# at packages/api/node_modules/.bin/medusa, and bun's isolated layout symlinks
# packages/api/node_modules entries into the root node_modules/.bun store. So we
# must copy BOTH the root store and the full packages/api (source + .medusa
# build + its own node_modules). Copying only .medusa/server + root node_modules
# breaks the server (no medusa CLI, missing runtime deps).
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages/api ./packages/api

ENV NODE_ENV=production
ENV PORT=9000

WORKDIR /app/packages/api
EXPOSE 9000

# Medusa production server. Reads MEDUSA_WORKER_MODE (server|worker|shared).
CMD ["./node_modules/.bin/medusa", "start"]
