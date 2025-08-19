#!/bin/bash

# 容器环境专用部署脚本
# 适用于无 sudo 权限的环境

set -e

echo "🚀 开始部署 Cron 表达式解析工具 (容器环境版本)..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为容器环境
if [ -f /.dockerenv ] || [ -n "${CONTAINER}" ]; then
    print_warning "检测到容器环境，跳过系统级配置"
else
    print_status "非容器环境，但无 sudo 权限，使用用户级安装"
fi

# 检查 Docker 是否已安装
print_status "检查 Docker 安装状态..."
if command -v docker &> /dev/null; then
    print_status "Docker 已安装: $(docker --version)"
else
    print_error "Docker 未安装。请联系系统管理员安装 Docker"
    echo "或者尝试以下命令（如果有权限）："
    echo "curl -fsSL https://get.docker.com | sh"
    exit 1
fi

# 检查 Docker Compose 是否已安装
print_status "检查 Docker Compose 安装状态..."
if command -v docker-compose &> /dev/null; then
    print_status "Docker Compose 已安装: $(docker-compose --version)"
elif docker compose version &> /dev/null; then
    print_status "Docker Compose (plugin) 已安装: $(docker compose version)"
    # 创建 docker-compose 别名
    echo 'alias docker-compose="docker compose"' >> ~/.bashrc
else
    print_error "Docker Compose 未安装。请联系系统管理员安装"
    echo "或者尝试以下命令（如果有权限）："
    echo "curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o ~/.local/bin/docker-compose"
    echo "chmod +x ~/.local/bin/docker-compose"
    exit 1
fi

# 检查 Docker 权限
print_status "检查 Docker 权限..."
if docker ps &> /dev/null; then
    print_status "Docker 权限正常"
else
    print_error "Docker 权限不足。请联系系统管理员将您添加到 docker 组："
    echo "sudo usermod -aG docker \$USER"
    echo "然后重新登录"
    exit 1
fi

# 创建项目目录
print_status "创建项目目录..."
PROJECT_DIR="$HOME/cron-tools"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

print_status "✅ 环境检查完成！"
print_status "项目目录: $PROJECT_DIR"
print_status "下一步: 运行项目生成脚本"
print_status "curl -O https://raw.githubusercontent.com/YOUR_REPO/quick-deploy.sh"
print_status "chmod +x quick-deploy.sh && ./quick-deploy.sh"

echo ""
echo "🔗 部署完成后访问: http://\$(curl -s ifconfig.me 2>/dev/null || echo 'localhost')"
echo ""