# Vercel 部署配置说明

本文档详细说明了 `vercel.json` 配置文件的各个选项。

## 配置结构

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "version": 2,
  "buildCommand": "npm run build",
  "installCommand": "npm install",
  "framework": null,
  "regions": ["hkg1"],
  "builds": [...],
  "routes": [...],
  "headers": [...]
}
```

## 配置项说明

### 基础配置

#### `version`
- **类型**: `number`
- **值**: `2`
- **说明**: Vercel 平台版本，目前使用 v2

#### `buildCommand`
- **类型**: `string`
- **值**: `"npm run build"`
- **说明**: 构建命令，执行 `vont build` 生成生产构建产物

#### `installCommand`
- **类型**: `string`
- **值**: `"npm install"`
- **说明**: 依赖安装命令

#### `framework`
- **类型**: `string | null`
- **值**: `null`
- **说明**: 框架类型，设为 `null` 表示自定义框架（Vont）

#### `regions`
- **类型**: `string[]`
- **值**: `["hkg1"]`
- **说明**: 部署区域，`hkg1` 为香港数据中心
- **可选值**:
  - `hkg1`: 香港
  - `sin1`: 新加坡
  - `iad1`: 美国东部
  - `sfo1`: 美国西部
  - 更多区域请参考 [Vercel 文档](https://vercel.com/docs/concepts/edge-network/regions)

### Builds 配置

定义如何构建和运行 Serverless Functions。

```json
{
  "builds": [
    {
      "src": "dist/server/index.js",
      "use": "@vercel/node",
      "config": {
        "maxDuration": 10,
        "memory": 1024
      }
    }
  ]
}
```

#### `src`
- **说明**: 服务器入口文件路径
- **值**: `"dist/server/index.js"`

#### `use`
- **说明**: 使用的 Vercel Runtime
- **值**: `"@vercel/node"`
- **其他可选**: `@vercel/python`, `@vercel/go`, `@vercel/ruby`

#### `config.maxDuration`
- **说明**: 函数最大执行时间（秒）
- **值**: `10`
- **限制**: 
  - Hobby 计划: 10 秒
  - Pro 计划: 60 秒
  - Enterprise 计划: 900 秒

#### `config.memory`
- **说明**: 函数内存限制（MB）
- **值**: `1024`
- **可选值**: `128`, `256`, `512`, `1024`, `1536`, `3008`

### Routes 配置

定义请求路由规则。

```json
{
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
  ]
}
```

#### 静态资源路由
- **匹配**: `/assets/*` 路径
- **目标**: `dist/client/assets/` 目录
- **缓存**: 1 年（31536000 秒），`immutable` 表示永不变化
- **说明**: 优化静态资源加载速度

#### 动态路由（兜底）
- **匹配**: 所有其他路径 `/(.*)`
- **目标**: `dist/server/index.js`
- **说明**: 由 Vont 服务器处理 API 和页面请求

### Headers 配置

为特定路径设置 HTTP 响应头。

```json
{
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

#### API 路由缓存策略
- **匹配**: `/api/*` 路径
- **缓存策略**: 禁用缓存
  - `no-cache`: 需要验证缓存
  - `no-store`: 完全禁止存储
  - `must-revalidate`: 必须重新验证过期缓存
- **说明**: 确保 API 响应总是最新的

## 高级配置选项

### 环境变量

在 Vercel Dashboard 中配置，或在 `vercel.json` 中定义：

```json
{
  "env": {
    "API_URL": "https://api.example.com"
  },
  "build": {
    "env": {
      "BUILD_TIME": "true"
    }
  }
}
```

### 重定向

```json
{
  "redirects": [
    {
      "source": "/old-path",
      "destination": "/new-path",
      "permanent": true
    }
  ]
}
```

### CORS 配置

```json
{
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        {
          "key": "Access-Control-Allow-Origin",
          "value": "*"
        },
        {
          "key": "Access-Control-Allow-Methods",
          "value": "GET, POST, PUT, DELETE, OPTIONS"
        },
        {
          "key": "Access-Control-Allow-Headers",
          "value": "Content-Type, Authorization"
        }
      ]
    }
  ]
}
```

### 自定义域名

```json
{
  "alias": ["example.com", "www.example.com"]
}
```

## 性能优化建议

### 1. 区域选择
根据用户地理位置选择最近的区域：
- 中国用户: `hkg1` (香港) 或 `sin1` (新加坡)
- 美国用户: `iad1` (东部) 或 `sfo1` (西部)
- 欧洲用户: `fra1` (法兰克福)

### 2. 缓存策略
- **静态资源**: 长期缓存 (1年) + immutable
- **API 响应**: 根据业务需求设置合适的缓存时间
- **HTML 页面**: 短期缓存或 no-cache

### 3. 函数配置
- 根据实际需求调整 `maxDuration`
- 合理设置 `memory`，避免浪费资源

## 调试技巧

### 查看构建日志
```bash
vercel logs [deployment-url]
```

### 本地测试配置
```bash
# 使用 Vercel CLI 本地运行
vercel dev
```

### 检查路由规则
在浏览器开发者工具中查看请求路径和响应头，确认路由规则是否生效。

## 常见问题

### Q: 为什么我的 API 返回 404？
A: 检查以下几点：
1. `dist/server/index.js` 是否存在
2. 构建是否成功
3. 路由配置是否正确

### Q: 静态资源无法加载？
A: 确认：
1. `dist/client/assets/` 目录存在
2. 资源路径是否正确
3. 路由配置匹配规则

### Q: 如何修改部署区域？
A: 修改 `regions` 配置并重新部署。

## 参考资源

- [Vercel 配置文档](https://vercel.com/docs/configuration)
- [Vercel Node.js Runtime](https://vercel.com/docs/runtimes#official-runtimes/node-js)
- [Vercel 路由文档](https://vercel.com/docs/configuration#routes)
- [Vercel 区域列表](https://vercel.com/docs/concepts/edge-network/regions)

---

**提示**: 修改配置后需要重新部署才能生效。

