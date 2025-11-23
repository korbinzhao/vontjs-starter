# Vont.js Starter - 全栈应用

这是一个基于 Vont 框架构建的现代化全栈应用示例，展示了前后端一体化开发和 Vercel 部署的最佳实践。

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/your-repo/vontjs-starter)

## ✨ 特性

- 🎨 **现代 UI** - Tailwind CSS v4 + React 18
- ⚡ **文件路由** - API 和页面的零配置路由系统
- 🔧 **TypeScript** - 全栈类型安全支持
- 🔄 **热更新** - 开发环境即时反馈
- 🚀 **Serverless** - 开箱即用的 Vercel 部署配置
- 📦 **代码分割** - 自动优化的生产构建

## 📚 文档

- 📖 [完整部署指南](./VERCEL_DEPLOYMENT_GUIDE.md) - 详细的技术方案和架构说明
- 🚀 [快速开始](./DEPLOYMENT_QUICKSTART.md) - 5 分钟部署到 Vercel
- 🏗️ [架构图](./ARCHITECTURE.md) - 系统架构和数据流详解

## 🎯 快速开始

### 本地开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问 http://localhost:3000
```

### 生产构建

```bash
# 构建项目
npm run build

# 启动生产服务器
npm start

# 预览构建结果
npm run preview
```

### 部署到 Vercel

```bash
# 方式 1: 使用 Vercel CLI
npm install -g vercel
vercel --prod

# 方式 2: 使用部署脚本
chmod +x deploy.sh
./deploy.sh production

# 方式 3: GitHub 集成（推荐）
# 将代码推送到 GitHub，然后在 Vercel Dashboard 中导入项目
```

详细部署步骤请查看 [DEPLOYMENT_QUICKSTART.md](./DEPLOYMENT_QUICKSTART.md)

## 📁 项目结构

```
vontjs-starter/
├── src/                           # 源代码目录
│   ├── api/                       # 后端 API 路由（文件路由）
│   │   ├── users.ts               # GET/POST /api/users
│   │   └── users/
│   │       └── [id].ts            # GET/PUT/DELETE /api/users/:id
│   ├── pages/                     # 前端页面（文件路由）
│   │   ├── index.tsx              # 首页 /
│   │   ├── about.tsx              # 关于页面 /about
│   │   └── users.tsx              # 用户管理 /users
│   ├── lib/                       # 工具库
│   │   └── api.ts                 # 前端 API 调用封装
│   ├── styles/                    # 全局样式
│   │   └── app.css                # Tailwind CSS
│   └── types/                     # TypeScript 类型定义
│       └── api.ts                 # API 响应类型
├── dist/                          # 构建产物（自动生成）
│   ├── server/                    # 服务器构建产物
│   ├── client/                    # 客户端构建产物
│   └── api/                       # API 路由构建产物
├── .github/                       # GitHub 配置
│   └── workflows/
│       └── deploy.yml             # CI/CD 自动部署
├── index.html                     # HTML 模板
├── vont.config.ts                 # Vont 框架配置
├── vont.config.production.ts      # 生产环境配置
├── vercel.json                    # Vercel 部署配置
├── package.json                   # 项目依赖
├── tsconfig.json                  # TypeScript 配置
├── deploy.sh                      # 部署脚本
├── test-api.sh                    # API 测试脚本
├── VERCEL_DEPLOYMENT_GUIDE.md     # 完整部署指南
├── DEPLOYMENT_QUICKSTART.md       # 快速开始指南
└── ARCHITECTURE.md                # 架构文档
```

> **注意**: 无需 `vite.config.ts`！所有 Vite 配置通过 `vont.config.ts` 的 `viteConfig` 字段管理。

## API Routes

### GET /api/users
Get all users

### POST /api/users
Create a new user

Body: `{ "name": string, "email": string }`

### GET /api/users/:id
Get user by ID

## Pages

- `/` - Home page with framework overview
- `/about` - About the framework
- `/users` - User management demo

## Technologies

- **Backend**: Koa 2.x
- **Frontend**: React 18 + React Router 6
- **Build Tool**: Vite 5 (managed by Vont)
- **Styling**: Tailwind CSS v4
- **Language**: TypeScript
- **Framework**: Vont (File-based routing + HMR)

## Configuration

This example includes three configuration files demonstrating different use cases:

### 1. `vont.config.ts` (Full Example)

Complete configuration with all available options and detailed comments:

```typescript
import { defineConfig } from 'vont';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  port: 3000,
  apiPrefix: '/api',
  vitePlugins: [tailwindcss()],
  build: {
    sourcemap: true,
    minify: true,
  },
  // ... and more options
});
```

### 2. `vont.config.minimal.ts` (Minimal)

Minimal configuration that only overrides necessary settings:

```typescript
export default defineConfig({
  port: 3000,
  vitePlugins: [tailwindcss(), react()],
});
```

### 3. `vont.config.production.ts` (Production)

Optimized configuration for production deployments:

```typescript
export default defineConfig({
  port: parseInt(process.env.PORT || '8080'),
  build: {
    sourcemap: false,
    minify: true,
  },
  viteConfig: {
    build: {
      rollupOptions: {
        output: {
          manualChunks: {
            'react-vendor': ['react', 'react-dom'],
          },
        },
      },
    },
  },
});
```

### Using Different Configs

```bash
# Use default vont.config.ts
npm run dev

# Use production config
cp vont.config.production.ts vont.config.ts
npm run build

# Use minimal config
cp vont.config.minimal.ts vont.config.ts
npm run dev
```

## 🧪 测试

### API 端点测试

```bash
# 测试本地开发服务器
./test-api.sh

# 测试生产环境
./test-api.sh https://your-app.vercel.app
```

### 类型检查

```bash
npm run type-check
```

## 🔧 开发规范

本项目遵循以下代码规范：

- ✅ 单个文件不超过 500 行
- ✅ TypeScript 项目中类型必须明确，不使用 `any`
- ✅ 合理的组件拆分，保证代码可维护性
- ✅ 遵循函数式编程和 React Hooks 最佳实践

## 📊 技术栈

### 后端
- **框架**: Vont (基于 Koa 2.x)
- **语言**: TypeScript 5.1+
- **运行时**: Node.js 20
- **API 设计**: RESTful + 文件路由

### 前端
- **框架**: React 18
- **路由**: React Router 6
- **样式**: Tailwind CSS v4
- **构建**: Vite 7 (由 Vont 管理)

### 部署
- **平台**: Vercel
- **架构**: Serverless Functions
- **CDN**: Vercel Edge Network
- **CI/CD**: GitHub Actions (可选)

## 🚀 部署清单

在部署到生产环境之前，请确认：

- [ ] 代码通过 TypeScript 类型检查
- [ ] 本地构建成功
- [ ] API 端点测试通过
- [ ] 环境变量已配置（如需要）
- [ ] `vercel.json` 配置正确
- [ ] 文档已更新

## 📖 学习资源

### 框架文档
- [Vont 官方文档](https://vont.dev)
- [Vercel 文档](https://vercel.com/docs)
- [React 文档](https://react.dev)

### 项目文档
- [完整部署指南](./VERCEL_DEPLOYMENT_GUIDE.md) - 深入理解部署流程
- [架构文档](./ARCHITECTURE.md) - 了解系统架构
- [快速开始](./DEPLOYMENT_QUICKSTART.md) - 5 分钟部署

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📝 许可证

MIT License

---

**Built with ❤️ using [Vont Framework](https://vont.dev)**
