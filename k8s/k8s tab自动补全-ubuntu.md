apt update && apt install -y bash-completion
# 永久生效（写入 ~/.bashrc，每次登录自动加载）
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc