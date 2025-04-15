下载 ingress 配置文件
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/baremetal/deploy.yaml

# 修改镜像
vi deploy.yaml
# 1、将image k8s.gcr.io/ingressnginx/controller:v0.46.0@sha256:52f0058bed0a17ab0fb35628ba97e8d52b5d32299fbc03cc0f6c7b9ff036b61a的值改为如下值：
registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/ingress-nginx-controller:v0.46.0

kubectl apply -f deploy.yaml

kubectl get pod,svc -n ingress-nginx -owide

```
[root@k8s-master ~]# kubectl get pod,svc -n ingress-nginx -owide
NAME                                            READY   STATUS      RESTARTS   AGE    IP               NODE        NOMINATED NODE   READINESS GATES
pod/ingress-nginx-admission-create-q52mr        0/1     Completed   0          173m   10.244.169.132   k8s-node2   <none>           <none>
pod/ingress-nginx-admission-patch-qnpc7         0/1     Completed   2          173m   10.244.36.70     k8s-node1   <none>           <none>
pod/ingress-nginx-controller-65bf56f7fc-t7hbp   1/1     Running     0          173m   10.244.169.133   k8s-node2   <none>           <none>

NAME                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE    SELECTOR
service/ingress-nginx-controller             NodePort    10.96.167.122   <none>        80:30021/TCP,443:30923/TCP   173m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
service/ingress-nginx-controller-admission   ClusterIP   10.96.158.188   <none>        443/TCP                      173m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
[root@k8s-master ~]#
[root@k8s-master ~]#
```

集群外部，使用30021 端口



ingress.yaml
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bookinfo
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: bookinfo.imooc.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: bookinfo
            port:
              number: 80

```
kubectl apply -f ingress.yml

[root@k8s-master ~]# kubectl get ingress -owide
NAME       CLASS   HOSTS                 ADDRESS           PORTS   AGE
bookinfo   nginx   bookinfo.weilai.com   192.168.171.151   80      82m
[root@k8s-master ~]#

配置Host
```
192.168.171.150 bookinfo.weilai.com
```

curl bookinfo.weilai.com:30021 查看内容

































