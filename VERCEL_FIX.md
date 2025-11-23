# Vercel 部署问题修复说明

## 问题诊断

部署失败的主要原因：
1. **npm 源问题**：`package-lock.json` 使用了阿里内部 npm 源（`registry.anpm.alibaba-inc.com`），Vercel 无法访问
2. **缺少 Node.js 版本配置**：未指定 Node.js 版本可能导致版本不匹配
3. **缺少 Vercel 配置**：没有明确的构建配置

## 已完成的修复

### 1. 创建 .npmrc 文件
指定使用公共 npm 源：
```
registry=https://registry.npmjs.org/
```

### 2. 创建 .node-version 文件
指定 Node.js 版本为 20（LTS 版本）

### 3. 创建 vercel.json 配置文件
指定构建命令和输出目录：
```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "installCommand": "npm install",
  "framework": null,
  "devCommand": "npm run dev"
}
```

### 4. 重新生成 package-lock.json
删除旧的 `package-lock.json` 和 `node_modules`，使用公共 npm 源重新安装依赖

## 下一步操作

请执行以下命令将修改提交到仓库：

```bash
git add .npmrc .node-version vercel.json package-lock.json
git commit -m "fix: 修复 Vercel 部署问题 - 使用公共 npm 源和添加部署配置"
git push origin main
```

提交后，Vercel 会自动触发新的部署，应该能够成功完成依赖安装。

## 验证本地构建

在推送之前，可以先在本地验证构建是否正常：

```bash
npm run build
```

如果构建成功，`dist` 目录下会生成静态文件。

## 其他建议

如果仍然遇到问题，可以考虑：
1. 在 Vercel 项目设置中手动指定 Node.js 版本
2. 检查 Vercel 构建日志中的详细错误信息
3. 考虑降级某些依赖版本（如 tailwindcss 和 vite）

