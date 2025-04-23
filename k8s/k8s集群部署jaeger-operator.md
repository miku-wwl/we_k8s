kubernetes集群模式下使用jaeger，安装jaeger-operator

安装cert-manger

```
kubectl apply -f cert-manager.yaml

```

```
在 Kubernetes 集群中自动申请、颁发、续订和管理 TLS/SSL 证书。

```

安装证书后确认
```
kubectl get pod -n cert-manager
```

输出如下内容表示安装成功了

```
NAME                                       READY   STATUS    RESTARTS       AGE
cert-manager-6796d554c5-vq7zc              1/1     Running   26 (66m ago)   43h
cert-manager-cainjector-77cd756b5d-7h9nz   1/1     Running   2 (26h ago)    43h
cert-manager-webhook-dbb5879d7-9k28s       1/1     Running   2 (26h ago)    43h

```


安装Jaeger
```
kubectl create namespace observability
kubectl create -f jaeger-operator.yaml

```

创建实例

```
kubectl apply -f sample.yaml

```


修改一下ingress，从而通过域名访问
```
root@miku-virtual-machine:~# kubectl get ingress -n observability
NAME             CLASS   HOSTS               ADDRESS           PORTS   AGE
simplest-query   nginx   jaeger.weilai.com   192.168.171.153   80      6h36m
kubectl edit ingress simplest-query -n observability
```

rules部分
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  creationTimestamp: "2025-04-23T07:33:04Z"
  generation: 2
  labels:
    app: jaeger
    app.kubernetes.io/component: query-ingress
    app.kubernetes.io/instance: simplest
    app.kubernetes.io/managed-by: jaeger-operator
    app.kubernetes.io/name: simplest-query
    app.kubernetes.io/part-of: jaeger
  name: simplest-query
  namespace: observability
  ownerReferences:
  - apiVersion: jaegertracing.io/v1
    controller: true
    kind: Jaeger
    name: simplest
    uid: 8a43c439-9924-4346-8e4a-e96d5f24d397
  resourceVersion: "5335"
  uid: 5d9008f7-c880-48d5-b464-034c979ebbfa
spec:
  ingressClassName: nginx
  rules:
  - host: jaeger.weilai.com
    http:
      paths:
      - backend:
          service:
            name: simplest-query
            port:
              number: 16686
        path: /
        pathType: Prefix
status:
  loadBalancer:
    ingress:
    - ip: 192.168.171.153


```