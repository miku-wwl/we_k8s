docker pull redis

mkdir -p /data/redis/conf
cd /data/redis/conf
touch redis.conf

mkdir -p /data/redis/data


docker run -itd --name redis --restart=always --log-opt max-size=100m --log-opt max-file=2 -p 6379:6379 -v /data/redis/conf/redis.conf:/etc/redis/redis.conf -v /data/redis/data:/data  redis redis-server /etc/redis/redis.conf --appendonly yes  --requirepass qwe123

