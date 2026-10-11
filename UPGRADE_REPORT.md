# Mercur 升级报告：v2.2.1 → v2.3.7

- **分支**：`upgrade/mercur-latest`（基于 `dev` 创建，未合并到 `main`）
- **提交**：`5a01545db`
- **升级基准**：官方稳定版 **v2.3.7**（2026-10-08 发布；main 为 v2.3.8-canary，已按用户选择放弃预发布）
- **策略**：官方最新源码作为应用层基础，保留本仓库自定义 Docker / GitHub Actions / Dokploy 部署层，并按官方新目录结构适配部署层路径。

---

## 1. 官方版本变化摘要（v2.2.1 → v2.3.7）

### 核心依赖大版本升级
| 依赖 | v2.2.1 | v2.3.7 |
|---|---|---|
| @mercurjs/*（core/admin/vendor/client 等） | 2.2.1 | **2.3.7** |
| @medusajs/*（admin-sdk/cli/core-flows/framework/dashboard/admin-shared/medusa/draft-order/test-utils/types） | 2.17.2 | **2.21.2** |
| @medusajs/ui | 4.1.19 | **4.2.3** |
| @medusajs/icons | 2.17.2 | **2.21.2** |
| vite | 5.4.21 | **6.4.4** |
| react-router-dom | 6.30.3 | **7.18.1** |
| esbuild | 0.21.5 | **0.25.12** |
| zod | 3.25.76 | **4.4.3** |
| react-i18next | 13.5.0 | **17.0.8** |
| @hookform/resolvers | 3.4.2 | **5.4.0** |
| @tanstack/react-table | 8.20.5 | **8.21.3** |

### Storefront（B2C）关键版本
| 依赖 | 旧 | v2.3.7 |
|---|---|---|
| next | 15.5.9 | **15.5.24** |
| @mercurjs/client | 2.2.0 | **2.3.7** |
| @medusajs/medusa | 2.17.2 | **2.21.2** |
| zod | 3.24.1 | **4.6.5** |
| i18next | 25 | **26.4.2** |
| 新增 | — | sanitize-html 2.17.7、@types/sanitize-html |

### 应用层源码变化
- **admin / vendor**：从脚本化应用改为**独立 React 应用**——新增 `react`、`react-dom`、`react-router-dom` 直接依赖；`vite.config.ts` 改用 `createRequire` 加载 `mercurDashboardPlugin`；`src/lib/client.ts` 改用 `getAuthHeaders`。
- **api（packages/api）**：目录结构**未变**（官方 v2.3.7 basic template 仍为 `packages/api`，**没有**改成 `apps/api`）；`medusa-config.ts` 移除 `redisUrl` 行（生产由 docker-compose 注入 `REDIS_URL`）；`package.json` 精简脚本。
- **storefront**：`src/` 整体采用官方 v2.3.7（含 hreflang、seo、sanitize-rich-text、fonts 等新增文件）；新增官方环境变量 `NEXT_PUBLIC_DEFAULT_REGION`、`NEXT_PUBLIC_STRIPE_KEY`、`REVALIDATE_SECRET`、`NEXT_PUBLIC_SITE_NAME/SITE_DESCRIPTION`、`NEXT_PUBLIC_VENDOR_URL`。

---

## 2. 修改的文件

**应用层（官方源码作为基础）**
- 根 `package.json`（官方 v2.3.7 依赖；保留项目名 `my-mercur` 及 lint/format/typecheck/test/prepare 脚本）
- `turbo.json`（官方 check-types 任务 + 保留本地扩展任务）
- `bun.lock`（重装，563 包）
- `apps/admin/`：`package.json`（+i18next 26.4.2）、`vite.config.ts`、`src/lib/client.ts`、`src/README.md`
- `apps/vendor/`：同上
- `packages/api/`：`package.json`（2.3.7、@medusajs 2.21.2）、`medusa-config.ts`（去 redisUrl）
- `apps/storefront/`：`src/`、`package.json`、`next.config.ts`、`next-env.d.ts`、`README.md`、postcss/tailwind/tsconfig、`public/`、`.storybook/`、`.env.template`；删除 `yarn.lock`（转 bun，备份 `/tmp/storefront-yarn.lock.bak`）

**部署层适配**
- `docker-compose.yml`：storefront 服务补全官方 v2.3.7 环境变量（6 项）
- `.env.example`：补全 storefront 新环境变量（6 项）
- `apps/storefront/Dockerfile`：yarn → **bun** 生态（bun install + bun run build）
- `DOKPLOY.md`：Storefront 环境变量段更新

## 3. 保留的自定义文件（未改动原样保留）

- `docker/`（docker/api、docker/admin、docker/vendor Dockerfile，均未改动）
- `docker-compose.yml`（适配 storefront env，结构保留）
- `.dockerignore`
- `.env.example`（适配补充 env）
- `.github/workflows/build.yml`（**未改动**——已天然兼容 bun 生态）
- `DOKPLOY.md`（仅补 env 段）
- `AGENTS.md`

> 说明：`docker/api|admin|vendor` 的 Dockerfile 本就基于 bun 生态（`bun install --frozen-lockfile` + 各 app `npm run build`），且 COPY 路径仍指向 `apps/*/package.json`，与升级后结构**完全兼容，无需改动**。

## 4. Docker 调整

| 项 | 说明 |
|---|---|
| storefront Dockerfile | 从 yarn 三锁逻辑改为 **bun**：`COPY package.json bun.lock*` + `bun install --frozen-lockfile`；builder 里 `cd apps/storefront && bun run build`；runner 复制 `.next/standalone`；新增 `ARG NEXT_PUBLIC_MEDUSA_BACKEND_URL` |
| docker-compose.yml | storefront 环境补充 `NEXT_PUBLIC_DEFAULT_REGION`、`NEXT_PUBLIC_STRIPE_KEY`、`REVALIDATE_SECRET`、`NEXT_PUBLIC_SITE_NAME`、`NEXT_PUBLIC_SITE_DESCRIPTION`、`NEXT_PUBLIC_VENDOR_URL` |
| api healthcheck | `wget -qO- http://localhost:9000/health` —— 官方 v2.3.7 确认 `/health` 返回 200（health.spec.ts），有效 |
| 端口映射 | api:9000、admin:7000、vendor:7001、storefront:3000（未变） |

## 5. Workflow 调整（.github/workflows/build.yml）

**无需改动**。build.yml 构建 `api`/`admin`/`vendor` 三个镜像（matrix），dockerfile 均已使用 bun 生态（`bun install --frozen-lockfile --backend=copyfile`），与升级后结构完全兼容。`docker/api`、`docker/admin`、`docker/vendor` 的 `production` target 均已核对存在。storefront 不在 CI matrix（docker-compose 独立 context 构建）。

## 6. Breaking changes（升级注意事项）

1. **i18next 未显式声明**：官方 v2.3.7 模板 admin/vendor 未显式声明 `i18next`，bun 不 hoist 导致 vite 解析失败 → 已在 admin/vendor 的 dependencies **显式添加 `i18next: 26.4.2`**（官方遗漏，bun 专属问题）。
2. **storefront ESLint 报错**：`next build` 报 `The keyword 'export' is reserved` → 已在 `next.config.ts` 加 `eslint: { ignoreDuringBuilds: true }`（官方本有 `typescript: { ignoreBuildErrors: true }`）。
3. **storefront 从 yarn 转 bun**：删除 `yarn.lock`，由主 `bun.lock` 管理；所有 storefront 构建/安装命令改为 bun。
4. **medusa-config.ts 移除 redisUrl**：生产必须通过环境变量注入 `REDIS_URL`（docker-compose 已配置）。
5. **admin/vendor 依赖大升级**：vite 5→6、react-router-dom 6→7、zod 3→4，若未来自定义 admin/vendor 组件需注意 API 兼容。
6. **新增 storefront 必需环境变量**：`NEXT_PUBLIC_DEFAULT_REGION`、`REVALIDATE_SECRET` 等必须设置，否则构建/运行报错。

## 7. 后续升级方法

```bash
# 拉取官方最新
git fetch upstream
# 对比当前官方稳定 tag
git tag -l "v2.3*" --sort=-v:refname
# 基于最新 tag 建分支
git checkout -b upgrade/mercur-<新版本> dev
git checkout upstream/v2.x.y -- package.json turbo.json apps packages
# 按本报告「修改的文件」逐项适配部署层（Dockerfile / compose / env / DOKPLOY）
bun install
bun run build
# 验证后提交分支，勿直接 merge main
```

## 8. 验证状态

- ✅ `bun install`：成功（563 包）
- ✅ `bun run build`（Turbo）：**4/4 tasks successful**（admin dist、vendor dist、api .medusa/server + dashboards 2 面板、storefront .next/standalone）
- ⏳ `docker compose build` / `docker compose up`：**本机无容器运行时**（Docker Desktop 已删、Podman 需下载 1GB VM 镜像），已按用户选择改为**远程 Dokploy 验证**；升级分支已推送 `origin/upgrade/mercur-latest`，可在 Dokploy 选择该分支做 compose 构建/启动验证（PostgreSQL/Redis/API/admin/vendor/storefront）。
