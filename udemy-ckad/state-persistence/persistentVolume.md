### 案例：使用HostPath存储卷部署Nginx

#### 1. 什么是PersistentVolume(PV)和PersistentVolumeClaim(PVC)？
- **PersistentVolume (PV)**：是集群中由管理员提供的存储资源，独立于Pod的生命周期。
- **PersistentVolumeClaim (PVC)**：是用户对存储的请求，类似于Pod对计算资源的请求。

#### 2. 创建PV和PVC的YAML文件

首先，我们需要创建一个PV定义：
```yaml
# pv-example.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```

然后，创建一个PVC来请求这个PV：
```yaml
# pvc-example.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

#### 3. 使用PVC的Pod定义
接下来，创建一个使用这个PVC的Nginx Pod：
```yaml
# pod-with-pvc.yaml
apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: task-pv-claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
```

#### 4. 部署步骤

**步骤1：创建PV**
```bash
kubectl apply -f pv-example.yaml
```

**步骤2：创建PVC**
```bash
kubectl apply -f pvc-example.yaml
```

**步骤3：检查PVC状态**
```bash
kubectl get pvc task-pv-claim
```
当状态为`Bound`时，表示PVC已成功绑定到PV。

**步骤4：创建Pod**
```bash
kubectl apply -f pod-with-pvc.yaml
```

**步骤5：验证数据持久化**
```bash
# 进入Pod
kubectl exec -it task-pv-pod -- /bin/bash

# 在挂载目录创建一个测试文件
echo "Hello from PVC" > /usr/share/nginx/html/index.html

# 退出容器
exit

# 验证Nginx是否 serving该文件
kubectl port-forward task-pv-pod 8080:80
```
现在访问 http://localhost:8080 应该能看到"Hello from PVC"。

#### 5. 练习题

**练习1：创建PV和PVC**
- 创建一个5Gi的PV，使用`manual`存储类，访问模式为`ReadWriteOnce`
- 创建一个请求2Gi存储的PVC，使用相同的存储类和访问模式

**练习2：部署应用并使用PVC**
- 部署一个Redis Pod，使用上面创建的PVC
- Redis数据应存储在`/data`目录

**练习3：验证数据持久化**
- 向Redis中写入一些数据
- 删除并重新创建Redis Pod
- 验证数据是否仍然存在

#### 6. 解题步骤

**练习1解答**
```yaml
# 练习1的PV定义
apiVersion: v1
kind: PersistentVolume
metadata:
  name: exercise-pv
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/exercise-data"
```

```yaml
# 练习1的PVC定义
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: exercise-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

**练习2解答**
```yaml
# 练习2的Redis Pod定义
apiVersion: v1
kind: Pod
metadata:
  name: redis-pod
spec:
  volumes:
    - name: redis-storage
      persistentVolumeClaim:
        claimName: exercise-pvc
  containers:
    - name: redis
      image: redis
      ports:
        - containerPort: 6379
      volumeMounts:
        - mountPath: "/data"
          name: redis-storage
```

**练习3解答**
```bash
# 连接到Redis Pod
kubectl exec -it redis-pod -- redis-cli

# 设置一个键值对
127.0.0.1:6379> SET mykey "Hello Redis"
OK

# 获取值验证
127.0.0.1:6379> GET mykey
"Hello Redis"

# 退出Redis客户端
127.0.0.1:6379> exit

# 删除Pod
kubectl delete pod redis-pod

# 重新创建Pod（使用相同的yaml文件）
kubectl apply -f redis-pod.yaml

# 再次连接到Redis并验证数据
kubectl exec -it redis-pod -- redis-cli
127.0.0.1:6379> GET mykey
"Hello Redis"
```

