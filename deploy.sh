#!/bin/bash

# Ubuntu Docker 部署脚本 - Cron Tools
# 在 clone 项目后运行此脚本完成部署

set -e

echo "🚀 开始部署 Cron Tools..."

# 检查是否为 root 用户
if [ "$EUID" -eq 0 ]; then
    echo "❌ 请不要使用 root 用户运行此脚本"
    exit 1
fi

# 获取当前目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📁 项目目录: $SCRIPT_DIR"

# 1. 检查并安装 Docker
echo "🐳 检查 Docker 安装..."
if ! command -v docker &> /dev/null; then
    echo "📦 安装 Docker..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo "✅ Docker 安装完成，请重新登录或运行 'newgrp docker' 使权限生效"
else
    echo "✅ Docker 已安装"
fi

# 2. 检查并安装 Docker Compose
echo "🔧 检查 Docker Compose 安装..."
if ! command -v docker-compose &> /dev/null; then
    echo "📦 安装 Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose 安装完成"
else
    echo "✅ Docker Compose 已安装"
fi

# 3. 检查 Docker 服务状态
echo "🔍 检查 Docker 服务..."
if ! sudo systemctl is-active --quiet docker; then
    echo "🔄 启动 Docker 服务..."
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# 4. 检查用户是否在 docker 组中
if ! groups $USER | grep -q '\bdocker\b'; then
    echo "⚠️  当前用户不在 docker 组中，需要重新登录或运行 'newgrp docker'"
    echo "   请运行以下命令之一："
    echo "   1) newgrp docker && ./deploy.sh"
    echo "   2) 重新登录系统后运行 ./deploy.sh"
    exit 1
fi

# 检查 Docker 权限
if ! docker ps &>/dev/null; then
    echo "❌ Docker 权限不足，请运行："
    echo "   newgrp docker && ./deploy.sh"
    echo "   或者重新登录系统"
    exit 1
fi

# 5. 停止已存在的容器
echo "🛑 停止现有容器..."
docker-compose down --remove-orphans 2>/dev/null || true

# 6. 清理旧镜像（可选）
read -p "是否清理旧镜像以确保使用最新代码? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    echo "🧹 清理旧镜像..."
    docker-compose down --rmi all --volumes --remove-orphans 2>/dev/null || true
    docker system prune -f 2>/dev/null || true
fi

# 7. 构建并启动服务
echo "🔨 构建并启动服务..."
docker-compose up -d --build

# 8. 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 9. 检查服务状态
echo "🔍 检查服务状态..."
docker-compose ps

# 10. 检查后端健康状态
echo "🏥 检查后端健康状态..."
for i in {1..30}; do
    if curl -f http://localhost:8080/api/health &>/dev/null; then
        echo "✅ 后端服务已就绪"
        break
    else
        echo "⏳ 等待后端服务启动... ($i/30)"
        sleep 2
    fi
    
    if [ $i -eq 30 ]; then
        echo "❌ 后端服务启动超时"
        echo "📋 查看日志:"
        docker-compose logs backend
        exit 1
    fi
done

# 11. 获取服务器 IP
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}' || echo "localhost")

# 12. 显示部署结果
echo ""
echo "🎉 部署完成！"
echo ""
echo "📊 服务状态:"
docker-compose ps
echo ""
echo "🌐 访问地址:"
echo "  前端: http://$SERVER_IP"
echo "  后端: http://$SERVER_IP:8080"
echo "  健康检查: http://$SERVER_IP:8080/api/health"
echo ""
echo "📝 常用命令:"
echo "  查看日志: docker-compose logs -f"
echo "  重启服务: docker-compose restart"
echo "  停止服务: docker-compose down"
echo "  更新服务: git pull && docker-compose up -d --build"
echo ""
echo "🧪 运行测试:"
echo "  cd backend && ./mvnw test"
echo ""

# 13. 测试核心功能
echo "🧪 测试核心功能..."
if curl -s "http://localhost:8080/api/parse?expr=0%200%204%20*%20*%20?" | grep -q '"valid":true'; then
    echo "✅ Cron 解析功能正常"
else
    echo "⚠️  Cron 解析功能可能有问题，请检查日志"
fi

echo ""
echo "🚀 部署完成！请访问 http://$SERVER_IP 开始使用"