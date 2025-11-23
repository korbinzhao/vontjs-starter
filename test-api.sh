#!/bin/bash

# API 端点测试脚本
# 使用方法: ./test-api.sh [base-url]
# 示例: ./test-api.sh https://your-app.vercel.app

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认使用本地开发服务器
BASE_URL=${1:-http://localhost:3000}

echo -e "${BLUE}🧪 开始测试 API 端点${NC}"
echo -e "${YELLOW}📍 Base URL: $BASE_URL${NC}"
echo ""

# 测试计数器
PASS_COUNT=0
FAIL_COUNT=0

# 测试函数
test_api() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_status=$5
    
    echo -e "${YELLOW}测试: $name${NC}"
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅ 通过 (状态码: $status_code)${NC}"
        echo -e "${BLUE}响应: $body${NC}"
        ((PASS_COUNT++))
    else
        echo -e "${RED}❌ 失败 (期望: $expected_status, 实际: $status_code)${NC}"
        echo -e "${RED}响应: $body${NC}"
        ((FAIL_COUNT++))
    fi
    echo ""
}

# 运行测试
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  测试 1: 获取所有用户 (GET)${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
test_api "GET /api/users" "GET" "/api/users" "" "200"

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  测试 2: 获取单个用户 (GET)${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
test_api "GET /api/users/1" "GET" "/api/users/1" "" "200"

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  测试 3: 创建新用户 (POST)${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
test_api "POST /api/users" "POST" "/api/users" \
    '{"name":"Test User","email":"test@example.com"}' "201"

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  测试 4: 更新用户 (PUT)${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
test_api "PUT /api/users/1" "PUT" "/api/users/1" \
    '{"name":"Updated User"}' "200"

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  测试 5: 删除用户 (DELETE)${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
test_api "DELETE /api/users/1" "DELETE" "/api/users/1" "" "204"

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  测试 6: 获取不存在的用户 (404)${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
test_api "GET /api/users/9999" "GET" "/api/users/9999" "" "404"

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  测试 7: 创建用户（缺少字段）${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
test_api "POST /api/users (invalid)" "POST" "/api/users" \
    '{"name":"Only Name"}' "400"

# 测试前端页面
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  测试前端页面${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

echo -e "${YELLOW}测试: GET / (首页)${NC}"
status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")
if [ "$status" = "200" ]; then
    echo -e "${GREEN}✅ 通过 (状态码: $status)${NC}"
    ((PASS_COUNT++))
else
    echo -e "${RED}❌ 失败 (状态码: $status)${NC}"
    ((FAIL_COUNT++))
fi
echo ""

echo -e "${YELLOW}测试: GET /users (用户页面)${NC}"
status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/users")
if [ "$status" = "200" ]; then
    echo -e "${GREEN}✅ 通过 (状态码: $status)${NC}"
    ((PASS_COUNT++))
else
    echo -e "${RED}❌ 失败 (状态码: $status)${NC}"
    ((FAIL_COUNT++))
fi
echo ""

echo -e "${YELLOW}测试: GET /about (关于页面)${NC}"
status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/about")
if [ "$status" = "200" ]; then
    echo -e "${GREEN}✅ 通过 (状态码: $status)${NC}"
    ((PASS_COUNT++))
else
    echo -e "${RED}❌ 失败 (状态码: $status)${NC}"
    ((FAIL_COUNT++))
fi
echo ""

# 测试总结
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  测试总结${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✅ 通过: $PASS_COUNT${NC}"
echo -e "${RED}❌ 失败: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}⚠️  部分测试失败${NC}"
    exit 1
fi

