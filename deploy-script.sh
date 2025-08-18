#!/bin/bash

# Cron Tools 服务器部署脚本
# 适用于全新的 Ubuntu 服务器

set -e  # 遇到错误时退出

echo "🚀 开始部署 Cron 表达式解析工具..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root 用户
if [ "$EUID" -eq 0 ]; then
    print_warning "检测到 root 用户，建议使用普通用户运行此脚本"
fi

# 步骤 1：更新系统
print_status "步骤 1: 更新系统包..."
sudo apt update && sudo apt upgrade -y

# 步骤 2：安装基础工具
print_status "步骤 2: 安装基础工具..."
sudo apt install -y curl wget vim git htop unzip ufw

# 步骤 3：安装 Docker
print_status "步骤 3: 安装 Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_status "Docker 安装完成"
else
    print_status "Docker 已安装，跳过..."
fi

# 步骤 4：安装 Docker Compose
print_status "步骤 4: 安装 Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_status "Docker Compose 安装完成"
else
    print_status "Docker Compose 已安装，跳过..."
fi

# 步骤 5：启动 Docker 服务
print_status "步骤 5: 启动 Docker 服务..."
sudo systemctl start docker
sudo systemctl enable docker

# 步骤 6：配置防火墙
print_status "步骤 6: 配置防火墙..."
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
echo "y" | sudo ufw enable

# 步骤 7：创建项目目录
print_status "步骤 7: 创建项目目录..."
PROJECT_DIR="$HOME/cron-tools"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

print_status "项目目录创建完成: $PROJECT_DIR"

# 验证安装
print_status "验证安装..."
echo "Docker 版本: $(docker --version)"
echo "Docker Compose 版本: $(docker-compose --version)"

print_status "✅ 基础环境配置完成！"
print_warning "⚠️  请重新登录 SSH 会话以应用 Docker 用户组变更"
print_status "下一步: 将项目文件上传到 $PROJECT_DIR 目录"
print_status "然后运行: cd $PROJECT_DIR && docker-compose up -d"

echo ""
echo "🔗 部署完成后访问: http://$(curl -s ifconfig.me)"
echo ""