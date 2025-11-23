# Vont.js Vercel 部署快速参考卡

## 🚀 快速命令

### 开发
```bash
npm install              # 安装依赖
npm run dev             # 启动开发服务器
npm run type-check      # TypeScript 类型检查
```

### 构建
```bash
npm run build           # 构建生产版本
npm start              # 启动生产服务器
npm run preview        # 构建并预览
```

### 部署
```bash
# 方式 1: Vercel CLI
vercel                 # 预览部署
vercel --prod          # 生产部署

# 方式 2: 部署脚本
./deploy.sh preview    # 预览部署
./deploy.sh production # 生产部署
```

### 测试
```bash
./test-api.sh                           # 测试本地 API
./test-api.sh https://your-app.vercel.app  # 测试线上 API
```

## 📂 关键文件

| 文件 | 用途 |
|------|------|
| `src/api/*.ts` | API 路由（后端） |
| `src/pages/*.tsx` | 页面组件（前端） |
| `src/lib/api.ts` | API 客户端工具 |
| `src/types/api.ts` | 类型定义 |
| `vercel.json` | Vercel 配置 |
| `vont.config.ts` | Vont 开发配置 |
| `vont.config.production.ts` | Vont 生产配置 |

## 🔗 URL 路由

### 前端页面
- `/` → `src/pages/index.tsx`
- `/users` → `src/pages/users.tsx`
- `/about` → `src/pages/about.tsx`

### API 路由
- `GET /api/users` → `src/api/users.ts` (export const get)
- `POST /api/users` → `src/api/users.ts` (export const post)
- `GET /api/users/:id` → `src/api/users/[id].ts` (export const get)
- `PUT /api/users/:id` → `src/api/users/[id].ts` (export const put)
- `DELETE /api/users/:id` → `src/api/users/[id].ts` (export const del)

## 📝 API 方法导出

```typescript
// src/api/users.ts
export const get = async (ctx: Context) => { }    // GET
export const post = async (ctx: Context) => { }   // POST
export const put = async (ctx: Context) => { }    // PUT
export const del = async (ctx: Context) => { }    // DELETE
export const patch = async (ctx: Context) => { }  // PATCH
```

## 🔧 Vercel 配置要点

```json
{
  "regions": ["hkg1"],              // 部署区域（香港）
  "builds": [{
    "src": "dist/server/index.js",  // 服务器入口
    "use": "@vercel/node",          // Node.js Runtime
    "config": {
      "maxDuration": 10,            // 最大执行时间（秒）
      "memory": 1024                // 内存限制（MB）
    }
  }]
}
```

## 🐛 常见问题速查

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| API 404 | 构建产物不存在 | 运行 `npm run build` |
| 静态资源 404 | 路由配置错误 | 检查 `vercel.json` routes |
| 函数超时 | 执行时间过长 | 调整 `maxDuration` |
| 类型错误 | TypeScript 配置 | 运行 `npm run type-check` |
| Node 版本错误 | 版本不匹配 | 检查 `.node-version` (20) |

## 📊 性能优化检查清单

- [ ] 静态资源长期缓存（1年）
- [ ] API 响应禁用缓存
- [ ] 代码分割（React vendor）
- [ ] 生产环境关闭 sourcemap
- [ ] 选择最近的部署区域
- [ ] 合理设置函数内存

## 🔐 安全检查清单

- [ ] 环境变量使用 Vercel Dashboard 配置
- [ ] 敏感信息不在代码中硬编码
- [ ] CORS 配置限制允许域名
- [ ] API 添加速率限制
- [ ] TypeScript strict mode 开启

## 📚 文档速查

| 文档 | 内容 | 推荐阅读 |
|------|------|----------|
| README.md | 项目概览 | ⭐⭐⭐⭐⭐ |
| DEPLOYMENT_QUICKSTART.md | 5分钟部署 | ⭐⭐⭐⭐⭐ |
| VERCEL_DEPLOYMENT_GUIDE.md | 完整技术方案 | ⭐⭐⭐⭐ |
| ARCHITECTURE.md | 架构详解 | ⭐⭐⭐⭐ |
| VERCEL_CONFIG_EXPLAINED.md | 配置说明 | ⭐⭐⭐ |
| PROJECT_SUMMARY.md | 项目总结 | ⭐⭐⭐ |

## 🔍 调试命令

```bash
# 查看 Vercel 日志
vercel logs
vercel logs --follow

# 查看部署列表
vercel ls

# 本地测试 Vercel 配置
vercel dev

# 检查构建产物
ls -la dist/
ls -la dist/server/
ls -la dist/client/
```

## 🌐 Vercel 区域代码

| 区域 | 代码 | 延迟（中国） |
|------|------|--------------|
| 香港 | hkg1 | 🟢 低 |
| 新加坡 | sin1 | 🟡 中 |
| 东京 | nrt1 | 🟡 中 |
| 美国东部 | iad1 | 🔴 高 |
| 美国西部 | sfo1 | 🔴 高 |

## 💻 开发规范

- ✅ 单个文件不超过 500 行
- ✅ 禁止使用 `any` 类型
- ✅ 合理拆分组件
- ✅ 遵循函数式编程

## 🎯 快速链接

- [Vont 文档](https://vont.dev)
- [Vercel Dashboard](https://vercel.com/dashboard)
- [Vercel 文档](https://vercel.com/docs)
- [React 文档](https://react.dev)
- [TypeScript 文档](https://www.typescriptlang.org)

## 📞 获取帮助

1. 查看项目文档（docs/）
2. 运行 `./test-api.sh` 测试 API
3. 检查 Vercel 部署日志
4. 查看常见问题章节

---

**打印此卡片以便快速查阅** 📌

