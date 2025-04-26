下载目前最新版安装文件
https://github.com/istio/istio/releases/tag/1.25.2

tar zxvf istio-1.25.2-linux-amd64.tar.gz

cd istio-1.25.2

export PATH=$PWD/bin:$PATH

istioctl install -y

如果没有负载均衡器, loadbalancer 需要修改istio-ingressgateway 的type为NodePort

kubectl edit svc istio-ingressgateway -n istio-system
进入修改即可


卸载istio

istioctl uninstall -y --purge