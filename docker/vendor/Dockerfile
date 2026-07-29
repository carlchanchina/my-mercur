FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json bun.lock* package-lock.json* pnpm-lock.yaml* yarn.lock* ./
COPY packages/api/package.json ./packages/api/
COPY packages/*/package.json ./packages/
COPY apps/admin/package.json ./apps/admin/
COPY apps/vendor/package.json ./apps/vendor/
COPY apps/storefront/package.json ./apps/storefront/
RUN if [ -f bun.lock ]; then corepack enable && corepack prepare bun@1.3.11 --activate && bun install --frozen-lockfile; elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm install --frozen-lockfile; elif [ -f yarn.lock ]; then corepack enable && yarn install --frozen-lockfile; elif [ -f package-lock.json ]; then npm ci; else npm install; fi
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN cd apps/vendor && npm run build
FROM nginx:1.27-alpine
COPY --from=builder /app/apps/vendor/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
