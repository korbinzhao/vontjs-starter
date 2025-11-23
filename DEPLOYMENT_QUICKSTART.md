# Vercel 部署快速开始

本文档提供快速部署到 Vercel 的步骤说明。完整技术方案请参考 [VERCEL_DEPLOYMENT_GUIDE.md](./VERCEL_DEPLOYMENT_GUIDE.md)。

## 📋 前置要求

- Node.js 20+
- npm 或 yarn
- Vercel 账号
- Git（推荐）

## 🚀 快速部署

### 方式 1: 通过 Vercel CLI（推荐用于首次部署）

1. **安装 Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **登录 Vercel**
   ```bash
   vercel login
   ```

3. **部署项目**
   ```bash
   # 预览部署（测试用）
   npm run build
   vercel
   
   # 生产部署
   vercel --prod
   ```

### 方式 2: 通过 GitHub 集成（推荐用于持续部署）

1. **推送代码到 GitHub**
   ```bash
   git add .
   git commit -m "feat: prepare for vercel deployment"
   git push origin main
   ```

2. **在 Vercel Dashboard 导入项目**
   - 访问 https://vercel.com/dashboard
   - 点击 "Import Project"
   - 选择你的 GitHub 仓库
   - 点击 "Deploy"

   Vercel 会自动读取 `vercel.json` 配置并完成部署。

### 方式 3: 使用部署脚本

```bash
# 赋予执行权限
chmod +x deploy.sh

# 预览部署
./deploy.sh preview

# 生产部署
./deploy.sh production
```

## 🔍 验证部署

部署成功后，你会收到一个 Vercel URL（例如：https://your-app.vercel.app）

### 测试端点

1. **前端页面**
   - 首页: https://your-app.vercel.app/
   - 用户页: https://your-app.vercel.app/users
   - 关于页: https://your-app.vercel.app/about

2. **API 端点**
   ```bash
   # 获取所有用户
   curl https://your-app.vercel.app/api/users
   
   # 创建新用户
   curl -X POST https://your-app.vercel.app/api/users \
     -H "Content-Type: application/json" \
     -d '{"name":"Test User","email":"test@example.com"}'
   ```

## ⚙️ 配置环境变量

在 Vercel Dashboard 中配置环境变量：

1. 进入项目设置: Settings → Environment Variables
2. 添加必要的环境变量（如果有）
3. 重新部署以应用更改

## 🔧 常见问题

### 问题 1: 构建失败

**解决方案:**
```bash
# 本地测试构建
npm run type-check
npm run build

# 检查是否有类型错误或构建错误
```

### 问题 2: API 路由 404

**解决方案:**
- 确保 `vercel.json` 配置正确
- 检查 `dist/server/index.js` 是否存在
- 查看 Vercel 部署日志

### 问题 3: 静态资源无法加载

**解决方案:**
- 检查 `vercel.json` 中的静态资源路由配置
- 确保 `dist/client/assets/` 目录存在

## 📚 详细文档

更多详细信息，请查看：
- [完整部署指南](./VERCEL_DEPLOYMENT_GUIDE.md) - 详细的技术方案和架构说明
- [Vercel 官方文档](https://vercel.com/docs)
- [Vont 框架文档](https://vont.dev)

## 🆘 需要帮助？

- 查看 [常见问题章节](./VERCEL_DEPLOYMENT_GUIDE.md#常见问题与解决方案)
- 查看 Vercel 部署日志: `vercel logs`
- 检查 GitHub Issues

---

**祝部署顺利！** 🎉

