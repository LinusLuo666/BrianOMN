#!/bin/bash

# 简化部署脚本 - 无需 sudo 权限
# 适用于已有 Docker 环境的情况

set -e

echo "🚀 Cron 工具简化部署..."

# 检查必要工具
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 未安装，请先安装此工具"
        exit 1
    else
        echo "✅ $1 已安装"
    fi
}

echo "📋 检查环境..."
check_command docker
check_command git

# 检查 docker-compose 或 docker compose
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    echo "✅ docker-compose 已安装"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
    echo "✅ docker compose (plugin) 已安装"
else
    echo "❌ Docker Compose 未安装"
    exit 1
fi

# 检查 Docker 权限
if ! docker ps &> /dev/null; then
    echo "❌ Docker 权限不足，请联系管理员"
    echo "需要运行: sudo usermod -aG docker $USER"
    echo "然后重新登录"
    exit 1
fi

echo "✅ 环境检查通过"

# 确保在项目目录
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ 未找到 docker-compose.yml 文件"
    echo "请确保在项目根目录运行此脚本"
    exit 1
fi

echo "📦 开始构建和启动服务..."

# 停止可能存在的旧容器
$COMPOSE_CMD down 2>/dev/null || true

# 构建并启动服务
$COMPOSE_CMD up -d --build

echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "📊 服务状态:"
$COMPOSE_CMD ps

# 检查健康状态
echo "🏥 健康检查:"
for i in {1..30}; do
    if curl -s http://localhost:8080/actuator/health >/dev/null 2>&1; then
        echo "✅ 后端服务正常"
        break
    else
        echo "⏳ 等待后端启动... ($i/30)"
        sleep 2
    fi
done

# 获取访问地址
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "localhost")

echo ""
echo "🎉 部署完成！"
echo "📱 前端访问: http://$PUBLIC_IP"
echo "🔧 后端 API: http://$PUBLIC_IP:8080/api/health"
echo ""
echo "📋 管理命令:"
echo "  查看日志: $COMPOSE_CMD logs -f"
echo "  重启服务: $COMPOSE_CMD restart"
echo "  停止服务: $COMPOSE_CMD down"
echo ""

# 显示日志（可选）
read -p "是否查看实时日志? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "按 Ctrl+C 退出日志查看"
    $COMPOSE_CMD logs -f
fi