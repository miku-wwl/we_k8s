修改hostname指令
给三台机器分别设置主机名
hostnamectl set-hostname xxx
第一台：k8s-master
第二台：k8s-node1
第三台：k8s-node2


k8s 1.32 安装
https://blog.csdn.net/qq_39839075/article/details/146540947

containerd 镜像源配置
https://www.cnblogs.com/manbaFan/articles/18794262


k8s 集群验证

nginx-deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.1
        ports:
        - containerPort: 80    
```

验证nginx
root@k8s-master:/home/miku/k8s# kubectl get pods -owide
NAME                               READY   STATUS    RESTARTS   AGE     IP          NODE        NOMINATED NODE   READINESS GATES
nginx-deployment-cc6647449-5mrt6   1/1     Running   0          7m16s   10.44.0.2   k8s-node1   <none>           <none>
nginx-deployment-cc6647449-9n4mt   1/1     Running   0          7m16s   10.47.0.2   k8s-node2   <none>           <none>
nginx-deployment-cc6647449-qktxd   1/1     Running   0          7m16s   10.47.0.1   k8s-node2   <none>           <none>
nginx-deployment-cc6647449-qqzfk   1/1     Running   0          7m16s   10.44.0.1   k8s-node1   <none>           <none>
nginx-deployment-cc6647449-v9t2w   1/1     Running   0          7m16s   10.44.0.3   k8s-node1   <none>           <none>
root@k8s-master:/home/miku/k8s# kubectl exec -it nginx-deployment-cc6647449-5mrt6 -- /bin/bash
root@nginx-deployment-cc6647449-5mrt6:/# curl localhost
