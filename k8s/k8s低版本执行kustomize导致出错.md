[root@k8s-master kustomize]# kubectl kustomize dev
Error: json: cannot unmarshal object into Go struct field Kustomization.patchesStrategicMerge of type patch.StrategicMerge


当前是kube v1.20, 属于2020年低版本，使用kube v1.30 没该问题

https://github.com/kubernetes-sigs/kustomize/releases

手动安装kustomize最新版，放置/usr/local/bin

使用指令

kustomize build dev > dev.yaml
kubectl apply -f dev.yaml

问题解决。