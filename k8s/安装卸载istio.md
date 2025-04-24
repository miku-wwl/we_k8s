下载目前最新版安装文件
https://github.com/istio/istio/releases/tag/1.25.2

tar zxvf istio-1.25.2-linux-amd64.tar.gz

cd istio-1.25.2

export PATH=$PWD/bin:$PATH

istioctl install -y

卸载istio

istioctl uninstall -y --purge