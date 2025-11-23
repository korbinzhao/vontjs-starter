# Vont.js 全栈应用架构图

## 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                          用户浏览器                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   首页 (/)   │  │  用户页面     │  │   关于页面    │        │
│  │  index.tsx   │  │  /users      │  │   /about     │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│           │                 │                │                  │
│           └─────────────────┴────────────────┘                  │
│                          │                                      │
│                   React Router                                  │
└───────────────────────────┼──────────────────────────────────────┘
                            │
                            │ HTTP Requests
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Vercel Edge Network                          │
│                         (CDN + Load Balancer)                   │
└───────────────────────────┼──────────────────────────────────────┘
                            │
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│               Vercel Serverless Functions                       │
│                     (@vercel/node)                              │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │            dist/server/index.js                          │ │
│  │       (Vont Production Server - Koa)                     │ │
│  └───────────────────────────────────────────────────────────┘ │
│                            │                                    │
│      ┌────────────────────┼─────────────────────┐             │
│      │                    │                      │             │
│      ↓                    ↓                      ↓             │
│  ┌────────┐         ┌──────────┐         ┌──────────┐        │
│  │ API    │         │ Static   │         │ HTML     │        │
│  │ Routes │         │ Assets   │         │ Pages    │        │
│  │ /api/* │         │ /assets/*│         │ /*       │        │
│  └────────┘         └──────────┘         └──────────┘        │
│      │                    │                      │             │
│      ↓                    ↓                      ↓             │
│  ┌────────┐         ┌──────────┐         ┌──────────┐        │
│  │dist/api│         │dist/     │         │dist/     │        │
│  │        │         │client/   │         │client/   │        │
│  │users.js│         │assets/   │         │index.html│        │
│  │[id].js │         │*.js,*.css│         │          │        │
│  └────────┘         └──────────┘         └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

## 源码到构建产物映射

```
源码结构 (src/)                 →      构建产物 (dist/)
─────────────────────────────────────────────────────────────
src/api/users.ts                →      dist/api/users.js
  ├─ export const get           →        GET /api/users
  └─ export const post          →        POST /api/users

src/api/users/[id].ts           →      dist/api/users/[id].js
  ├─ export const get           →        GET /api/users/:id
  ├─ export const put           →        PUT /api/users/:id
  └─ export const del           →        DELETE /api/users/:id

src/pages/index.tsx             →      dist/client/assets/*.js
  └─ React Component            →        Route: /

src/pages/users.tsx             →      dist/client/assets/*.js
  └─ React Component            →        Route: /users

src/pages/about.tsx             →      dist/client/assets/*.js
  └─ React Component            →        Route: /about

src/lib/api.ts                  →      dist/client/assets/*.js
  └─ API Client Functions       →        前端 API 调用工具

src/styles/app.css              →      dist/client/assets/*.css
  └─ Tailwind CSS               →        全局样式

index.html                      →      dist/client/index.html
  └─ HTML Template              →        SPA 入口文件
```

## 请求流程详解

### 1. 前端页面请求
```
用户访问 https://your-app.vercel.app/users
    ↓
Vercel CDN 检查缓存
    ↓
转发到 Serverless Function
    ↓
dist/server/index.js 处理
    ↓
返回 dist/client/index.html
    ↓
浏览器加载 HTML
    ↓
加载 React 应用 (dist/client/assets/*.js)
    ↓
React Router 渲染 /users 页面
    ↓
显示 UsersPage 组件
```

### 2. API 请求流程
```
用户点击"添加用户"按钮
    ↓
前端调用 post('/users', { name, email })
    ↓
HTTP POST https://your-app.vercel.app/api/users
    ↓
Vercel CDN (不缓存 API 请求)
    ↓
转发到 Serverless Function
    ↓
dist/server/index.js 路由匹配
    ↓
加载 dist/api/users.js
    ↓
执行 export const post 函数
    ↓
返回 JSON 响应 { data: newUser }
    ↓
前端接收响应并更新 UI
```

### 3. 静态资源请求
```
浏览器请求 /assets/index-abc123.js
    ↓
Vercel CDN 检查缓存
    ↓
如果命中缓存: 直接返回 (极快)
    ↓
如果未命中: 从 Serverless Function 获取
    ↓
dist/server/index.js 提供静态文件
    ↓
从 dist/client/assets/ 读取文件
    ↓
设置缓存头 (max-age=31536000, immutable)
    ↓
返回文件内容
    ↓
Vercel CDN 缓存该文件
    ↓
浏览器接收并缓存
```

## 文件路由系统

Vont 框架的核心特性是文件系统路由：

```
文件路径                        →      URL 路径
────────────────────────────────────────────────────
src/api/users.ts               →      /api/users
src/api/users/[id].ts          →      /api/users/:id (动态路由)
src/api/posts.ts               →      /api/posts
src/api/posts/[id]/comments.ts →      /api/posts/:id/comments

src/pages/index.tsx            →      /
src/pages/about.tsx            →      /about
src/pages/users.tsx            →      /users
src/pages/users/[id].tsx       →      /users/:id (如果存在)
```

## 数据流

```
┌─────────────────────────────────────────────────────────┐
│                    前端 (React)                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  UsersPage Component                            │   │
│  │  ┌────────────────┐  ┌─────────────────────┐   │   │
│  │  │ useState       │  │ useEffect           │   │   │
│  │  │ - users        │  │ - loadUsers()       │   │   │
│  │  │ - loading      │  │ - on mount          │   │   │
│  │  └────────────────┘  └─────────────────────┘   │   │
│  │                                                  │   │
│  │  ┌──────────────────────────────────────────┐  │   │
│  │  │ Event Handlers                           │  │   │
│  │  │ - handleCreateUser()                     │  │   │
│  │  │ - handleUpdateUser()                     │  │   │
│  │  └──────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────┘   │
│                       │                                 │
│                       │ 调用                            │
│                       ↓                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │  src/lib/api.ts                                 │   │
│  │  ┌────────────────────────────────────────┐    │   │
│  │  │ export async function get<T>()         │    │   │
│  │  │ export async function post<T>()        │    │   │
│  │  │ export async function put<T>()         │    │   │
│  │  │ export async function del<T>()         │    │   │
│  │  └────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────┘   │
└───────────────────────┼─────────────────────────────────┘
                        │
                        │ HTTP Request
                        │ (fetch)
                        ↓
┌─────────────────────────────────────────────────────────┐
│              后端 API (Koa)                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │  src/api/users.ts                               │   │
│  │  ┌────────────────────────────────────────┐    │   │
│  │  │ export const get = async (ctx) => {    │    │   │
│  │  │   ctx.body = { data: users };          │    │   │
│  │  │ }                                       │    │   │
│  │  │                                         │    │   │
│  │  │ export const post = async (ctx) => {   │    │   │
│  │  │   const { name, email } = ctx.request  │    │   │
│  │  │   const newUser = {...};               │    │   │
│  │  │   users.push(newUser);                 │    │   │
│  │  │   ctx.body = { data: newUser };        │    │   │
│  │  │ }                                       │    │   │
│  │  └────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────┘   │
│                       │                                 │
│                       │ 访问                            │
│                       ↓                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │  数据层 (内存数组 - 示例)                       │   │
│  │  const users: User[] = [...]                    │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 类型共享

```
┌─────────────────────────────────────────────────────────┐
│              src/types/api.ts                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ export interface User {                         │   │
│  │   id: number;                                   │   │
│  │   name: string;                                 │   │
│  │   email: string;                                │   │
│  │ }                                               │   │
│  │                                                  │   │
│  │ export interface ApiResponse<T> {               │   │
│  │   data: T;                                      │   │
│  │   error?: string;                               │   │
│  │ }                                               │   │
│  └─────────────────────────────────────────────────┘   │
└────────────┬──────────────────────────┬─────────────────┘
             │                          │
      import │                          │ import
             ↓                          ↓
┌──────────────────────┐    ┌─────────────────────────┐
│  前端使用              │    │  后端使用                │
│  src/pages/users.tsx │    │  src/api/users.ts      │
│                      │    │                         │
│  const [users,       │    │  export const get =    │
│    setUsers]         │    │    async (ctx) => {    │
│    = useState<       │    │    ctx.body = {        │
│      User[]>([]);    │    │      data: users       │
│                      │    │    } as ApiResponse    │
│  const response =    │    │      <User[]>;         │
│    await get<        │    │  }                     │
│      ApiResponse     │    │                         │
│      <User[]>>(...); │    │                         │
└──────────────────────┘    └─────────────────────────┘
```

## 部署流程

```
本地开发
  ├─ npm run dev (开发模式)
  ├─ Vont Dev Server 启动
  ├─ 前端 HMR (Vite)
  └─ 后端 API 热重载

         ↓ git push

GitHub Repository
  └─ main 分支更新

         ↓ 自动触发

Vercel CI/CD
  ├─ 1. 检测到代码变更
  ├─ 2. 拉取代码
  ├─ 3. 安装依赖 (npm install)
  ├─ 4. 类型检查 (npm run type-check)
  ├─ 5. 构建项目 (npm run build)
  │      ├─ Vite 构建前端 → dist/client/
  │      ├─ 编译 API 路由 → dist/api/
  │      └─ 生成服务器 → dist/server/index.js
  ├─ 6. 部署到 Serverless Functions
  └─ 7. 更新 CDN 缓存

         ↓

生产环境
  ├─ https://your-app.vercel.app
  ├─ Edge Network (全球 CDN)
  └─ Serverless Functions (按需扩展)
```

## 技术栈总结

```
┌─────────────────────────────────────────────────────────┐
│                      技术栈层次                         │
├─────────────────────────────────────────────────────────┤
│  部署平台      │  Vercel                                │
├─────────────────────────────────────────────────────────┤
│  运行时        │  Node.js 20 + @vercel/node            │
├─────────────────────────────────────────────────────────┤
│  框架          │  Vont v1.0.0-beta.23                  │
│                │  ├─ 前端: React 18                     │
│                │  └─ 后端: Koa 2                        │
├─────────────────────────────────────────────────────────┤
│  路由          │  ├─ 前端: React Router 6              │
│                │  └─ 后端: 文件系统路由                 │
├─────────────────────────────────────────────────────────┤
│  构建工具      │  Vite 7 (由 Vont 管理)               │
├─────────────────────────────────────────────────────────┤
│  样式          │  Tailwind CSS v4                      │
├─────────────────────────────────────────────────────────┤
│  语言          │  TypeScript 5 (strict mode)           │
├─────────────────────────────────────────────────────────┤
│  包管理器      │  npm                                   │
└─────────────────────────────────────────────────────────┘
```

---

**更多详细信息请查看:**
- [完整部署指南](./VERCEL_DEPLOYMENT_GUIDE.md)
- [快速开始](./DEPLOYMENT_QUICKSTART.md)

