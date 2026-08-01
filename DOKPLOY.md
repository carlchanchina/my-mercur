# Dokploy Deployment Guide

## 1. Prerequisites
- Dokploy server with Docker / Docker Compose support
- Domain names pointing to your Dokploy host:
  - api -> `api.example.com`
  - storefront -> `example.com` or `shop.example.com`

## 2. Repository
- Use this repo as the Dokploy Git source.
- Recommended branch strategy:
  - `main` for production
  - `staging` for staging
  - `dev` for development

## 3. Dokploy Project Setup
- Create 3 Dokploy projects: `my-mercur-dev`, `my-mercur-staging`, `my-mercur-prod`
- For each project:
  - Type: **Docker Compose**
  - Source: connect Git repo
  - Compose file: `docker-compose.yml`
  - Branch: dev / staging / main accordingly

## 4. Environment Variables (per project)
Set these in Dokploy project env, do NOT commit real secrets.

### Required
- `POSTGRES_USER=mercur`
- `POSTGRES_PASSWORD=<strong password>`
- `POSTGRES_DB=mercur`

### Backend
- `DATABASE_URL=postgres://mercur:mercur@postgres:5432/mercur`
- `REDIS_URL=redis://redis:6379`
- `JWT_SECRET=<random>`
- `COOKIE_SECRET=<random>`
- `STORE_CORS=https://your-storefront.example.com`
- `ADMIN_CORS=https://your-admin.example.com`
- `VENDOR_CORS=https://your-vendor.example.com`
- `AUTH_CORS=https://your-admin.example.com,https://your-vendor.example.com,https://your-storefront.example.com`
- `FILE_BACKEND_URL=https://api.example.com/static`
- `MEDUSA_BACKEND_URL=https://api.example.com`
- `MEDUSA_ADMIN_ONBOARDING_TYPE=default`

### Storefront
- `NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://api.example.com`
- `NEXT_PUBLIC_BASE_URL=https://shop.example.com`
- `NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=apk_...`
- `NEXT_PUBLIC_ALGOLIA_APP_ID=`
- `NEXT_PUBLIC_ALGOLIA_SEARCH_API_KEY=`
- `NEXT_PUBLIC_ALGOLIA_INDEX_PREFIX=mercur`
- `NEXT_PUBLIC_TALKJS_APP_ID=`

### Dashboards
- `VITE_MERCUR_BACKEND_URL=https://api.example.com`

## 5. First Deploy / Database Migrations
- First deploy can fail until DB is ready.
- After first deploy, run migrations from Dokploy app terminal or SSH:
  - `cd /home/dokploy/projects/my-mercur-prod/packages/api`
  - `./node_modules/.bin/medusa db:migrate`
- Optional: seed demo data
  - `./node_modules/.bin/medusa exec ./src/scripts/seed.ts`

## 6. Default Logins (after seed)
- Admin: `admin@mercur.dev` / `supersecret`
- Seller: `seller@mercur.dev` / `supersecret`

## 7. Panels
- Admin: `https://api.example.com/dashboard`
- Seller: `https://api.example.com/seller`
- Storefront: `https://shop.example.com`
- API health: `https://api.example.com/health`
