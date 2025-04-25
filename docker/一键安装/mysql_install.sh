#!/bin/bash

# 拉取 MySQL 8.3.0 镜像
docker pull mysql:8.3.0

# 检查镜像是否拉取成功
if [ $? -ne 0 ]; then
    echo "拉取 MySQL 8.3.0 镜像失败，请检查网络或 Docker 配置。"
    exit 1
fi

# 创建挂载目录
mkdir -p /home/mysql/{conf,data,log}

# 创建配置文件
cat << EOF > /home/mysql/conf/my.cnf
[client]
# 设置客户端默认字符集 utf8mb4
default-character-set=utf8mb4
[mysql]
# 设置服务器默认字符集为 utf8mb4
default-character-set=utf8mb4
[mysqld]
# 配置服务器的服务号，为日后需要集群做准备
server-id = 1
# 开启 MySQL 数据库的二进制日志，用于记录用户对数据库的操作 SQL 语句，为日后需要集群做准备
log-bin=mysql-bin
# 设置清理超过 30 天的日志，以免日志堆积造成服务器内存爆满。2592000 秒等于 30 天的秒数
binlog_expire_logs_seconds = 2592000
# 解决 MySQL 8.0 版本 GROUP BY 问题
sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
# 允许最大的连接数
max_connections=1000
# 禁用符号链接以防止各种安全风险
symbolic-links=0
# 设置东八区时区
default-time_zone = '+8:00'
EOF

# 启动 MySQL 容器
docker run \
-p 3306:3306 \
--restart=always \
--name mysql \
--privileged=true \
-v /home/mysql/log:/var/log/mysql \
-v /home/mysql/data:/var/lib/mysql \
-v /home/mysql/conf/my.cnf:/etc/mysql/my.cnf \
-e MYSQL_ROOT_PASSWORD=a12bCd3_W45pUq6 \
-d mysql:8.3.0

# 检查容器是否启动成功
if [ $? -eq 0 ]; then
    echo "MySQL 8.3.0 容器已成功启动。"
else
    echo "启动 MySQL 8.3.0 容器失败，请检查配置或 Docker 状态。"
fi    