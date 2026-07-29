FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json bun.lock* package-lock.json* pnpm-lock.yaml* yarn.lock* ./
COPY packages/api/package.json ./packages/api/
COPY packages/*/package.json ./packages/
COPY apps/admin/package.json ./apps/admin/
COPY apps/vendor/package.json ./apps/vendor/
COPY apps/storefront/package.json ./apps/storefront/

RUN corepack enable && \
  if [ -f bun.lock ]; then corepack prepare bun@1.3.11 --activate && bun install --frozen-lockfile; \
  elif [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
  elif [ -f yarn.lock ]; then corepack prepare yarn@1.22.22 --activate && yarn install --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  else npm install; \
  fi

FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build API and bundle dashboards
RUN cd packages/api && npm run build

FROM node:20-alpine AS production
RUN apk add --no-cache curl
WORKDIR /app

# Copy bundled API server and dashboards
COPY --from=builder /app/packages/api/.medusa/server ./server
COPY --from=builder /app/node_modules ./node_modules

# Copy built static assets if any
COPY --from=builder /app/packages/api/public ./public

ENV NODE_ENV=production
ENV PORT=9000

EXPOSE 9000

# Medusa server
CMD ["node", "server/server.js"]
