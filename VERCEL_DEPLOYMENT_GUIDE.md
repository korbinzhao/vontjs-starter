# Vont.js 全栈应用 Vercel 部署技术方案

## 📋 项目概述

### 项目名称
VontJS Starter - 基于 Vont 框架的全栈应用

### 技术栈分析

#### 后端技术栈
- **框架**: Vont v1.0.0-beta.23（基于 Koa 2.x）
- **运行时**: Node.js 20
- **语言**: TypeScript 5.1.6
- **API 设计**: RESTful API，文件路由系统

#### 前端技术栈
- **框架**: React 18.2.0
- **路由**: React Router DOM 6.14.2
- **构建工具**: Vite 7.2.0
- **样式**: Tailwind CSS v4.0
- **语言**: TypeScript

#### 部署平台
- **目标平台**: Vercel
- **Serverless 适配**: @vercel/node v5.5.9

---

## 🏗️ 项目结构深度解析

### 目录结构
```
vontjs-starter/
├── src/
│   ├── api/                  # 后端 API 路由（文件路由）
│   │   ├── users.ts         # GET /api/users, POST /api/users
│   │   └── users/
│   │       └── [id].ts      # GET/PUT/DELETE /api/users/:id
│   ├── pages/               # 前端页面（文件路由）
│   │   ├── index.tsx        # 首页 /
│   │   ├── about.tsx        # 关于页面 /about
│   │   └── users.tsx        # 用户管理页面 /users
│   ├── lib/                 # 工具库
│   │   └── api.ts           # 前端 API 调用封装
│   ├── styles/              # 全局样式
│   │   └── app.css
│   └── types/               # TypeScript 类型定义
│       └── api.ts           # API 响应类型
├── dist/                    # 构建输出目录
│   ├── server/             # 服务器端构建产物
│   │   └── index.js        # 生产服务器入口
│   ├── client/             # 客户端构建产物
│   │   ├── assets/         # 静态资源（JS/CSS）
│   │   └── index.html      # HTML 入口
│   └── api/                # API 路由构建产物
├── index.html              # HTML 模板
├── vont.config.ts          # Vont 框架配置
├── vercel.json             # Vercel 部署配置
├── package.json
└── tsconfig.json
```

### 核心特性

#### 1. 文件路由系统
Vont 框架采用文件系统路由，自动将文件路径映射为路由：
- `src/api/users.ts` → `/api/users`
- `src/api/users/[id].ts` → `/api/users/:id`（动态路由）
- `src/pages/index.tsx` → `/`
- `src/pages/users.tsx` → `/users`

#### 2. HTTP 方法映射
API 文件通过导出特定函数名来处理不同的 HTTP 方法：
```typescript
export const get = async (ctx: Context) => { }    // GET 请求
export const post = async (ctx: Context) => { }   // POST 请求
export const put = async (ctx: Context) => { }    // PUT 请求
export const del = async (ctx: Context) => { }    // DELETE 请求
```

#### 3. 类型安全
- 前后端共享类型定义（`src/types/api.ts`）
- 完整的 TypeScript 支持
- 严格模式下不允许使用 `any` 类型（符合代码规范）

---

## 🚀 Vercel 部署架构

### 部署模式

#### 当前配置分析
```json
{
  "buildCommand": "npm run build",
  "framework": "Other",
  "builds": [{
    "src": "dist/server/index.js",
    "use": "@vercel/node"
  }],
  "routes": [{
    "src": "/(.*)",
    "dest": "/dist/server/index.js"
  }]
}
```

#### 架构图
```
用户请求
    ↓
Vercel Edge Network (CDN)
    ↓
Vercel Serverless Functions (@vercel/node)
    ↓
dist/server/index.js (Vont Production Server)
    ↓
┌─────────────┬──────────────┐
│ API Routes  │ Static Assets│
│ (动态处理)   │  (静态服务)   │
└─────────────┴──────────────┘
```

### 工作流程

#### 构建流程
1. **执行** `npm run build` (即 `vont build`)
2. **编译 TypeScript** → JavaScript (ES2020)
3. **构建前端**
   - Vite 打包 React 应用
   - 输出到 `dist/client/`
   - 生成优化的 JS/CSS 资源
4. **构建后端**
   - 编译 API 路由到 `dist/api/`
   - 生成服务器入口 `dist/server/index.js`
5. **生成生产服务器**
   - 集成 Koa 服务器
   - 配置静态文件服务
   - 设置 API 路由

#### 运行流程
1. **Vercel 启动** `dist/server/index.js`
2. **Vont 初始化生产服务器**
   ```javascript
   import { startProductionServer } from "vont";
   startProductionServer();
   ```
3. **请求路由**
   - 静态资源请求 → 直接从 `dist/client/` 提供
   - API 请求 (`/api/*`) → 路由到 API 处理函数
   - 页面请求 → 返回 SPA HTML + 客户端路由接管

---

## ⚙️ 配置优化方案

### 1. Vercel 配置优化

#### 推荐配置 (vercel.json)
```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "version": 2,
  "buildCommand": "npm run build",
  "installCommand": "npm install",
  "framework": null,
  "regions": ["hkg1"],
  "builds": [
    {
      "src": "dist/server/index.js",
      "use": "@vercel/node",
      "config": {
        "maxDuration": 10,
        "memory": 1024
      }
    }
  ],
  "routes": [
    {
      "src": "/assets/(.*)",
      "dest": "/dist/client/assets/$1",
      "headers": {
        "cache-control": "public, max-age=31536000, immutable"
      }
    },
    {
      "src": "/(.*)",
      "dest": "/dist/server/index.js"
    }
  ],
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "no-cache, no-store, must-revalidate"
        }
      ]
    }
  ]
}
```

#### 配置说明
- **regions**: `["hkg1"]` - 香港区域，适合亚洲用户
- **maxDuration**: 10 秒 - Serverless 函数最大执行时间
- **memory**: 1024 MB - 函数内存限制
- **静态资源缓存**: 1 年（immutable）
- **API 无缓存**: 确保数据实时性

### 2. 构建优化

#### package.json 脚本优化
```json
{
  "scripts": {
    "dev": "vont dev",
    "build": "npm run type-check && vont build",
    "build:vercel": "vont build",
    "start": "vont start",
    "type-check": "tsc --noEmit",
    "preview": "vont start"
  }
}
```

### 3. 生产环境配置

#### 创建 vont.config.production.ts
```typescript
import { defineConfig } from 'vont';
import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  // 从环境变量读取端口（Vercel 自动设置）
  port: parseInt(process.env.PORT || '3000'),
  host: '0.0.0.0',

  // API 前缀
  apiPrefix: '/api',

  // 构建优化
  build: {
    sourcemap: false,        // 生产环境关闭 sourcemap
    minify: true,           // 代码压缩
    outDir: 'dist',         // 输出目录
  },

  viteConfig: {
    plugins: [
      tailwindcss(),
      react(),
    ],
    
    // Vite 构建优化
    build: {
      target: 'es2020',
      cssCodeSplit: true,
      rollupOptions: {
        output: {
          manualChunks: {
            'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          },
        },
      },
    },
  },
});
```

### 4. 环境变量配置

#### 本地开发 (.env.local)
```bash
# 服务端口
PORT=3000

# API Base URL（本地开发）
VITE_API_BASE_URL=http://localhost:3000

# Node 环境
NODE_ENV=development
```

#### Vercel 环境变量（在 Vercel Dashboard 配置）
```bash
# Node 环境
NODE_ENV=production

# 其他环境变量根据需要添加
# DATABASE_URL=...
# API_KEY=...
```

---

## 📝 部署步骤

### 方式一：通过 Vercel CLI 部署

#### 1. 安装 Vercel CLI
```bash
npm install -g vercel
```

#### 2. 登录 Vercel
```bash
vercel login
```

#### 3. 初始化项目
```bash
# 在项目根目录执行
vercel

# 按照提示配置：
# - Set up and deploy? Yes
# - Which scope? [选择你的账号]
# - Link to existing project? No
# - What's your project's name? vontjs-starter
# - In which directory is your code located? ./
```

#### 4. 部署到生产环境
```bash
vercel --prod
```

### 方式二：通过 Vercel Dashboard 部署

#### 1. GitHub 集成（推荐）

1. 将代码推送到 GitHub 仓库
   ```bash
   git add .
   git commit -m "feat: prepare for vercel deployment"
   git push origin main
   ```

2. 访问 [Vercel Dashboard](https://vercel.com/dashboard)

3. 点击 "Import Project"

4. 选择 GitHub 仓库

5. 配置项目：
   - **Framework Preset**: Other
   - **Build Command**: `npm run build`
   - **Output Directory**: （留空，由 vercel.json 控制）
   - **Install Command**: `npm install`

6. 配置环境变量（如需要）

7. 点击 "Deploy"

#### 2. Git 集成部署流程
```
本地开发 → Git Push → GitHub/GitLab/Bitbucket
                            ↓
                    Vercel 自动检测
                            ↓
                    自动构建和部署
                            ↓
                    生成预览 URL
                            ↓
                    合并到主分支 → 生产环境自动更新
```

### 方式三：从本地目录直接部署

```bash
# 构建项目
npm run build

# 部署（首次）
vercel

# 部署到生产环境
vercel --prod
```

---

## 🔍 部署后验证

### 1. 检查部署状态
```bash
# 查看部署历史
vercel ls

# 查看部署日志
vercel logs [deployment-url]
```

### 2. 测试 API 端点

#### 测试 GET 请求
```bash
# 获取所有用户
curl https://your-app.vercel.app/api/users

# 获取单个用户
curl https://your-app.vercel.app/api/users/1
```

#### 测试 POST 请求
```bash
curl -X POST https://your-app.vercel.app/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

### 3. 测试前端页面
- 首页: `https://your-app.vercel.app/`
- 用户页: `https://your-app.vercel.app/users`
- 关于页: `https://your-app.vercel.app/about`

### 4. 性能检查
```bash
# 使用 Lighthouse 检查性能
npx lighthouse https://your-app.vercel.app --view
```

---

## 🐛 常见问题与解决方案

### 问题 1: 404 错误 - API 路由无法访问

**症状**: 访问 `/api/users` 返回 404

**原因**:
- Vercel 路由配置不正确
- 构建产物路径错误

**解决方案**:
1. 检查 `vercel.json` 中的路由配置
2. 确保 `dist/server/index.js` 存在
3. 验证构建命令执行成功：`npm run build`

### 问题 2: 静态资源 404

**症状**: CSS/JS 文件无法加载

**原因**: 静态资源路径配置错误

**解决方案**:
```json
{
  "routes": [
    {
      "src": "/assets/(.*)",
      "dest": "/dist/client/assets/$1"
    }
  ]
}
```

### 问题 3: 函数超时

**症状**: Error: Function execution timed out

**原因**: Serverless 函数执行时间超过限制（默认 10s）

**解决方案**:
```json
{
  "builds": [{
    "src": "dist/server/index.js",
    "use": "@vercel/node",
    "config": {
      "maxDuration": 10
    }
  }]
}
```

### 问题 4: Node 版本不兼容

**症状**: 构建失败，Node 版本错误

**解决方案**:
1. 检查 `.node-version` 文件（当前: 20）
2. 在 `package.json` 中指定 Node 版本：
```json
{
  "engines": {
    "node": "20.x"
  }
}
```

### 问题 5: TypeScript 编译错误

**症状**: Build failed with TypeScript errors

**解决方案**:
1. 本地运行类型检查：`npm run type-check`
2. 修复所有类型错误
3. 确保没有使用 `any` 类型（符合代码规范）

### 问题 6: 环境变量未生效

**症状**: 环境变量在生产环境中为 undefined

**解决方案**:
1. 在 Vercel Dashboard → Settings → Environment Variables 中配置
2. 前端环境变量必须以 `VITE_` 开头
3. 重新部署以应用新的环境变量

---

## 🎯 性能优化建议

### 1. 代码分割
```typescript
// 在 vont.config.ts 中配置
viteConfig: {
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'utils': ['@/lib/api'],
        },
      },
    },
  },
}
```

### 2. 静态资源优化
- 启用 CDN 缓存（Vercel 自动提供）
- 图片使用 WebP 格式
- 开启 Gzip/Brotli 压缩（Vercel 自动启用）

### 3. API 响应优化
```typescript
// 在 API 中添加缓存头
export const get = async (ctx: Context) => {
  ctx.set('Cache-Control', 'public, max-age=60');
  ctx.body = { data: users };
};
```

### 4. 预渲染（可选）
对于静态页面，可以配置预渲染：
```json
{
  "buildCommand": "npm run build && npm run prerender"
}
```

---

## 📊 监控和日志

### 1. Vercel Analytics
在 Vercel Dashboard 中启用 Analytics 查看：
- 访问量统计
- 地理位置分布
- 设备类型分析
- 性能指标

### 2. 日志查看
```bash
# 实时日志
vercel logs --follow

# 特定部署的日志
vercel logs [deployment-url]
```

### 3. 错误追踪（建议集成）
- Sentry
- LogRocket
- Datadog

---

## 🔐 安全建议

### 1. API 安全
```typescript
// 添加 CORS 配置
import cors from '@koa/cors';

// 在 Vont 配置中添加中间件
export default defineConfig({
  middleware: [
    cors({
      origin: process.env.NODE_ENV === 'production' 
        ? 'https://your-domain.com'
        : '*',
    }),
  ],
});
```

### 2. 环境变量安全
- 敏感信息存储在 Vercel 环境变量中
- 不要在代码中硬编码 API 密钥
- 使用 `.env` 文件（添加到 `.gitignore`）

### 3. 速率限制
```typescript
// 安装 koa-ratelimit
import rateLimit from 'koa-ratelimit';

// 应用速率限制
export default defineConfig({
  middleware: [
    rateLimit({
      driver: 'memory',
      db: new Map(),
      duration: 60000,
      max: 100,
    }),
  ],
});
```

---

## 📚 最佳实践

### 1. 代码组织
- ✅ 单个文件不超过 500 行（符合规范）
- ✅ 合理拆分组件和工具函数
- ✅ 使用 TypeScript 明确类型，禁止 `any`
- ✅ 保持代码可维护性

### 2. 版本控制
- 使用语义化版本号
- 创建 Git 标签对应部署版本
- 维护 CHANGELOG.md

### 3. CI/CD 流程
```yaml
# .github/workflows/deploy.yml (示例)
name: Deploy to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '20'
      - run: npm install
      - run: npm run type-check
      - run: npm run build
      # Vercel 自动处理部署
```

### 4. 测试策略
```bash
# 添加测试脚本到 package.json
{
  "scripts": {
    "test": "vitest",
    "test:e2e": "playwright test"
  }
}
```

---

## 🎉 部署清单

在部署到生产环境之前，请确认以下事项：

- [ ] 代码已通过 TypeScript 类型检查 (`npm run type-check`)
- [ ] 本地构建成功 (`npm run build`)
- [ ] 本地生产模式测试通过 (`npm start`)
- [ ] `vercel.json` 配置正确
- [ ] `.node-version` 文件存在且版本正确（20）
- [ ] 环境变量已在 Vercel Dashboard 配置
- [ ] API 端点已测试
- [ ] 前端路由正常工作
- [ ] 静态资源可正常加载
- [ ] 性能指标符合预期
- [ ] 安全措施已实施
- [ ] 错误监控已配置
- [ ] 文档已更新

---

## 📖 参考资源

### Vont 框架
- [Vont 官方文档](https://vont.dev)
- [GitHub 仓库](https://github.com/vontjs/vont)

### Vercel
- [Vercel 文档](https://vercel.com/docs)
- [Vercel Node.js Runtime](https://vercel.com/docs/runtimes#official-runtimes/node-js)
- [Vercel CLI](https://vercel.com/docs/cli)

### 相关技术
- [React 文档](https://react.dev)
- [Koa 文档](https://koajs.com)
- [Vite 文档](https://vitejs.dev)
- [TypeScript 文档](https://www.typescriptlang.org)
- [Tailwind CSS](https://tailwindcss.com)

---

## 💡 总结

这个 Vont.js 全栈应用采用现代化的技术栈和架构设计：

1. **前后端分离但统一构建**: React 前端 + Koa 后端通过 Vont 框架统一管理
2. **文件路由系统**: 简化路由配置，提高开发效率
3. **TypeScript 全栈类型安全**: 前后端共享类型定义
4. **Serverless 架构**: 适配 Vercel 平台，自动扩展，按需付费
5. **性能优化**: 代码分割、CDN 缓存、资源优化
6. **开发体验**: HMR、类型检查、代码规范

通过本技术方案，你可以：
- ✅ 理解项目的完整架构和工作原理
- ✅ 顺利将应用部署到 Vercel 平台
- ✅ 解决部署过程中的常见问题
- ✅ 优化应用性能和安全性
- ✅ 建立可持续的 CI/CD 流程

**下一步行动**: 按照"部署步骤"章节的指引，选择合适的部署方式开始部署！

---

*文档版本: 1.0.0*  
*最后更新: 2025-11-23*  
*维护者: VontJS Team*

