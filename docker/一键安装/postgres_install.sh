#!/bin/bash

# 拉取 PostgreSQL 镜像
docker pull postgres

# 检查镜像是否拉取成功
echo "检查拉取的镜像:"
docker image ls | grep postgres

# 创建 PostgreSQL 卷
docker volume create postgres-volume

# 启动 PostgreSQL 容器
POSTGRES_PASSWORD=32110219miku
docker run -d --name=postgres13 -p 5432:5432 -v postgres-volume:/var/lib/postgresql/data -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD postgres

# 检查 PostgreSQL 容器是否正常运行
echo "检查 PostgreSQL 容器状态:"
docker ps | grep postgres13

# 若容器未正常运行，查看日志
if [ $? -ne 0 ]; then
    echo "PostgreSQL 容器未正常运行，查看日志:"
    docker logs postgres13
fi

echo "PostgreSQL 已部署。"
echo "默认用户名: postgres，密码: $POSTGRES_PASSWORD"    