### 什么是StorageClass？
StorageClass是Kubernetes中用于动态创建PV(持久卷)的模板。它允许集群管理员定义不同的"存储类型"，这些类型具有不同的服务质量、备份策略或其他参数。

### 简单案例：基于hostPath的StorageClass

#### 1. 创建StorageClass

```yaml
# storageclass.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner  # 使用no-provisioner表示静态分配
volumeBindingMode: WaitForFirstConsumer   # 延迟绑定，直到Pod请求时才绑定PV
```

这个StorageClass使用了特殊的`no-provisioner`，表示我们将手动创建PV。在实际生产环境中，你会使用云提供商的插件(如aws-ebs、gce-pd)或其他存储插件。

#### 2. 创建持久卷(PV)

```yaml
# pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
  labels:
    type: local
spec:
  storageClassName: local-storage  # 必须匹配上面创建的StorageClass名称
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"  # 宿主机上的路径
```

#### 3. 创建持久卷声明(PVC)

```yaml
# pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
spec:
  storageClassName: local-storage  # 必须匹配StorageClass名称
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi  # 请求3GB空间，不能超过PV的5GB
```

#### 4. 创建使用PVC的Pod

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-container
    image: nginx:1.25
    ports:
    - containerPort: 80
    volumeMounts:
    - name: test-volume
      mountPath: /usr/share/nginx/html  # 将PVC挂载到容器的这个路径
  volumes:
  - name: test-volume
    persistentVolumeClaim:
      claimName: local-pvc  # 引用上面创建的PVC
```

### 部署步骤

1. 创建StorageClass:
```bash
kubectl apply -f storageclass.yaml
```

2. 创建PV:
```bash
kubectl apply -f pv.yaml
```

3. 创建PVC:
```bash
kubectl apply -f pvc.yaml
```

4. 查看PVC状态，应该是"Bound":
```bash
kubectl get pvc local-pvc
```

5. 创建Pod:
```bash
kubectl apply -f pod.yaml
```

6. 验证Pod是否正常运行:
```bash
kubectl get pod test-pod
```

``` shell
root@miku-virtual-machine:/home# kubectl get sc
NAME            PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-storage   kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   false                  12s
root@miku-virtual-machine:/home# kubectl get sc
NAME            PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALL
local-storage   kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   fal
root@miku-virtual-machine:/home# kubectl get pv
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAG
local-pv   5Gi        RWO            Retain           Bound    default/local-pvc   local-
root@miku-virtual-machine:/home# kubectl get pvc
NAME        STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS    VOLUMEATTRIBUTE
local-pvc   Bound    local-pv   5Gi        RWO            local-storage   <unset>
root@miku-virtual-machine:/home#
root@miku-virtual-machine:/home# kubectl get pod test-pod
NAME       READY   STATUS    RESTARTS   AGE
test-pod   1/1     Running   0          58s
root@miku-virtual-machine:/home#

```
### 练习题

#### 题目1
创建一个新的StorageClass，命名为"fast-storage"，使用相同的`no-provisioner`。然后创建一个10GB的PV和一个5GB的PVC，最后部署一个使用这个PVC的Nginx Pod。

#### 解题步骤
1. 创建fast-storage StorageClass:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

2. 创建PV:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: fast-pv
spec:
  storageClassName: fast-storage
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/fast-data"
```

3. 创建PVC:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fast-pvc
spec:
  storageClassName: fast-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

4. 创建Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fast-nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    volumeMounts:
    - name: fast-volume
      mountPath: /usr/share/nginx/html
  volumes:
  - name: fast-volume
    persistentVolumeClaim:
      claimName: fast-pvc
```

#### 题目2
修改上面的Pod，添加第二个容器，将同一个PVC挂载到不同的路径。

#### 解题步骤
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    volumeMounts:
    - name: shared-volume
      mountPath: /usr/share/nginx/html  # Nginx默认网站目录
  - name: busybox
    image: busybox:1.36
    command: ["/bin/sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: shared-volume
      mountPath: /data  # Busybox容器挂载到/data路径
  volumes:
  - name: shared-volume
    persistentVolumeClaim:
      claimName: fast-pvc  # 使用之前创建的PVC
```

### 关键点总结
1. StorageClass是PV的模板
2. PV是集群中的存储资源
3. PVC是对PV的请求
4. Pod通过PVC使用存储
5. StorageClass名称必须在PV、PVC中保持一致
