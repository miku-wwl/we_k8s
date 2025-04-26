istioctl version 查询istio版本
去对应版本下载kiali对应yaml  https://github.com/istio/istio/blob/1.25.2/samples/addons/kiali.yaml

修改kiali 的type 从ClusterIP改为 NodePort

kubectl edit svc kiali -n istio-system

从外部浏览器访问对应的地址。
