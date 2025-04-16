base路径
we_cloudnative\bookinfo\deploy\kubernetes\kustomize\base

补丁路径
we_cloudnative\bookinfo\deploy\kubernetes\kustomize\dev\kustomization.yaml
```yaml
kubectl 1.20 使用
bases:
- ../base/

namePrefix: weilai-
nameSuffix: -dev
namespace: test

patchesStrategicMerge:
- set_memory.yaml

patchesJson6902:
- target:
    version: v1
    group: networking.k8s.io
    kind: Ingress
    name: bookinfo
  path: set_host.yaml
```

we_cloudnative\bookinfo\deploy\kubernetes\kustomize\dev\set_host.yaml
```yaml
- op: replace
  path: /spec/rules/0/host
  value: bookinfo.weilai.com
```

we_cloudnative\bookinfo\deploy\kubernetes\kustomize\dev\set_memory.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bookinfo
spec:
  template:
    spec:
      containers:
      - name: bookinfo
        resources: 
          limits: 
            memory: 512Mi
```
kubectl apply -k dev 后，pod,svc,ingress 正常

curl bookinfo.weilai.com:30021/bookinfo 返回 503

执行 kubectl kustomize dev 
ingress ✅部分， 应该修改成service的名字
```
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  name: weilai-bookinfo-dev
  namespace: test
spec:
  ingressClassName: nginx
  rules:
  - host: bookinfo.weilai.com
    http:
      paths:
      - backend:
          service:
            name: bookinfo ✅
            port:
              number: 80
        path: /bookinfo
        pathType: Prefix
```



[root@k8s-master kustomize]# kubectl  get pod,svc,ingress -n test -owide
NAME                                       READY   STATUS    RESTARTS   AGE     IP               NOD
pod/weilai-bookinfo-dev-55b59669b9-cw2bd   1/1     Running   0          9m12s   10.244.169.145   k8s
pod/weilai-bookinfo-dev-55b59669b9-kms89   1/1     Running   0          9m12s   10.244.169.144   k8s
pod/weilai-bookinfo-dev-55b59669b9-x8x4x   1/1     Running   0          9m12s   10.244.36.89     k8s

NAME                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/weilai-bookinfo-dev   ClusterIP   10.96.122.52   <none>        80/TCP    9m12s   app=bookinf

NAME                                            CLASS   HOSTS                 ADDRESS           PORT
ingress.networking.k8s.io/weilai-bookinfo-dev   nginx   bookinfo.weilai.com   192.168.171.151   80


kubectl edit ingress/weilai-bookinfo-dev -n test

进行修改即可
```yaml
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"networking.k8s.io/v1","kind":"Ingress","metadata":{"annotations":{"nginx.ingress.kubernetes.io/rewrite-target":"/"},"name":"weilai-bookinfo-dev","namespace":"test"},"spec":{"ingressClassName":"nginx","rules":[{"host":"bookinfo.weilai.com","http":{"paths":[{"backend":{"service":{"name":"bookinfo","port":{"number":80}}},"path":"/bookinfo","pathType":"Prefix"}]}}]}}
    nginx.ingress.kubernetes.io/rewrite-target: /
  creationTimestamp: "2025-04-16T05:40:00Z"
  generation: 2
  name: weilai-bookinfo-dev
  namespace: test
  resourceVersion: "31539"
  uid: 94f97e9c-26da-46ac-839f-140e0d556dad
spec:
  ingressClassName: nginx
  rules:
  - host: bookinfo.weilai.com
    http:
      paths:
      - backend:
          service:
            name: weilai-bookinfo-dev ✅
            port:
              number: 80
        path: /bookinfo
        pathType: Prefix
status:
  loadBalancer:
    ingress:
    - ip: 192.168.171.151
```


curl bookinfo.weilai.com:30021/bookinfo 返回 需要的信息