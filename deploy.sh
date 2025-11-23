#!/bin/bash

# Vont.js 应用 Vercel 部署脚本
# 使用方法: ./deploy.sh [production|preview]

set -e  # 遇到错误立即退出

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 开始 Vont.js 应用部署流程${NC}"

# 检查部署环境
DEPLOY_ENV=${1:-preview}

if [ "$DEPLOY_ENV" != "production" ] && [ "$DEPLOY_ENV" != "preview" ]; then
    echo -e "${RED}❌ 错误: 无效的部署环境 '$DEPLOY_ENV'${NC}"
    echo "使用方法: ./deploy.sh [production|preview]"
    exit 1
fi

echo -e "${YELLOW}📋 部署环境: $DEPLOY_ENV${NC}"

# 步骤 1: 类型检查
echo -e "\n${YELLOW}🔍 步骤 1/5: TypeScript 类型检查${NC}"
npm run type-check
echo -e "${GREEN}✅ 类型检查通过${NC}"

# 步骤 2: 本地构建测试
echo -e "\n${YELLOW}🔨 步骤 2/5: 本地构建测试${NC}"
npm run build
echo -e "${GREEN}✅ 构建成功${NC}"

# 步骤 3: 检查构建产物
echo -e "\n${YELLOW}📦 步骤 3/5: 验证构建产物${NC}"
if [ ! -f "dist/server/index.js" ]; then
    echo -e "${RED}❌ 错误: 服务器入口文件不存在${NC}"
    exit 1
fi

if [ ! -d "dist/client" ]; then
    echo -e "${RED}❌ 错误: 客户端构建目录不存在${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 构建产物验证通过${NC}"

# 步骤 4: 检查 Vercel CLI
echo -e "\n${YELLOW}🔧 步骤 4/5: 检查 Vercel CLI${NC}"
if ! command -v vercel &> /dev/null; then
    echo -e "${RED}❌ 错误: Vercel CLI 未安装${NC}"
    echo "请运行: npm install -g vercel"
    exit 1
fi

echo -e "${GREEN}✅ Vercel CLI 已安装${NC}"

# 步骤 5: 部署到 Vercel
echo -e "\n${YELLOW}🚀 步骤 5/5: 部署到 Vercel ($DEPLOY_ENV)${NC}"

if [ "$DEPLOY_ENV" = "production" ]; then
    echo -e "${YELLOW}⚠️  即将部署到生产环境，请确认！${NC}"
    read -p "继续？ (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}❌ 部署已取消${NC}"
        exit 0
    fi
    
    vercel --prod
else
    vercel
fi

echo -e "\n${GREEN}🎉 部署完成！${NC}"
echo -e "${YELLOW}📝 查看部署日志: vercel logs${NC}"
echo -e "${YELLOW}🔗 查看部署列表: vercel ls${NC}"

