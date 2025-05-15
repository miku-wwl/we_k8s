下面是一个简单的Kubernetes Volume使用示例，帮助你理解基本概念。


### **案例1：使用emptyDir Volume**
**场景**：在Pod中创建一个临时目录，供多个容器共享数据。

**YAML配置**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: empty-dir-demo
spec:
  containers:
  - name: writer
    image: busybox
    args: ["/bin/sh", "-c", "echo 'Hello from writer' > /data/hello.txt && sleep 3600"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: reader
    image: busybox
    args: ["/bin/sh", "-c", "cat /data/hello.txt && sleep 3600"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}  # 临时目录，Pod删除时数据丢失
```

**说明**：
1. `volumes` 部分定义了名为 `shared-data` 的 Volume，类型为 `emptyDir`。
2. 两个容器（`writer` 和 `reader`）都挂载了这个 Volume 到各自的 `/data` 目录。
3. `writer` 容器写入数据到 `/data/hello.txt`，`reader` 容器读取该文件。


``` shell
root@miku-virtual-machine:/home/udemy# kubectl logs empty-dir-demo -c reader
Hello from writer
```


### **案例2：使用hostPath Volume**
**场景**：将宿主机的目录挂载到Pod中，实现持久化存储。

**YAML配置**：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: host-path-demo
spec:
  containers:
  - name: container
    image: busybox
    args: ["/bin/sh", "-c", "echo 'Data from hostPath' > /data/host-data.txt && sleep 3600"]
    volumeMounts:
    - name: host-volume
      mountPath: /data
  volumes:
  - name: host-volume
    hostPath:
      path: /tmp/data  # 宿主机路径
      type: DirectoryOrCreate  # 如果目录不存在，则创建
```

**说明**：
1. `hostPath` 类型的 Volume 将宿主机的 `/tmp/data` 目录挂载到Pod的 `/data` 目录。
2. Pod删除后，数据仍然保存在宿主机上。

``` shell
root@k8s-node1:/tmp/data# cat host-data.txt
Data from hostPath
```

### **练习题**
#### **题目1：创建共享Volume Pod**
- **要求**：创建一个Pod，包含两个容器 `app` 和 `sidecar`，使用 `emptyDir` Volume 共享数据。
  - `app` 容器写入当前时间到 `/shared/time.txt`。
  - `sidecar` 容器每隔5秒打印 `/shared/time.txt` 的内容。

#### **题目2：持久化存储**
- **要求**：创建一个Nginx Pod，使用 `hostPath` 将宿主机的 `/var/www/html` 目录挂载到Pod的 `/usr/share/nginx/html`，使Nginx能够 serving 宿主机上的网页文件。


### **解题步骤**
#### **题目1解答**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-volume-pod
spec:
  containers:
  - name: app
    image: busybox
    args: ["/bin/sh", "-c", "while true; do date > /shared/time.txt; sleep 1; done"]
    volumeMounts:
    - name: shared-volume
      mountPath: /shared
  - name: sidecar
    image: busybox
    args: ["/bin/sh", "-c", "while true; do cat /shared/time.txt; sleep 5; done"]
    volumeMounts:
    - name: shared-volume
      mountPath: /shared
  volumes:
  - name: shared-volume
    emptyDir: {}
```

``` shell
root@miku-virtual-machine:/home/udemy# kubectl logs shared-volume-pod sidecar
Thu May 15 16:02:14 UTC 2025
Thu May 15 16:02:19 UTC 2025
Thu May 15 16:02:24 UTC 2025
Thu May 15 16:02:29 UTC 2025
Thu May 15 16:02:34 UTC 2025
Thu May 15 16:02:39 UTC 2025
Thu May 15 16:02:44 UTC 2025
Thu May 15 16:02:49 UTC 2025
Thu May 15 16:02:54 UTC 2025
```

#### **题目2解答**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-hostpath
spec:
  containers:
  - name: nginx
    image: nginx:1.19
    ports:
    - containerPort: 80
    volumeMounts:
    - name: html-volume
      mountPath: /usr/share/nginx/html
  volumes:
  - name: html-volume
    hostPath:
      path: /var/www/html
      type: DirectoryOrCreate
```


### **验证方法**
1. **题目1验证**：
   ```bash
   kubectl logs shared-volume-pod sidecar
   ```
   应该看到不断更新的时间戳。

2. **题目2验证**：
   ```bash
   # 在宿主机创建测试文件
   echo "Hello from host" > /var/www/html/index.html
   # 访问Nginx服务
   kubectl port-forward nginx-hostpath 8080:80
   curl http://localhost:8080
   ```


### **关键概念总结**
- **emptyDir**：临时存储，Pod内容器共享，Pod删除时数据丢失。
- **hostPath**：挂载宿主机目录，用于持久化存储或访问宿主机文件。
- **volumeMounts**：容器内挂载点配置，需与 `volumes` 部分对应。

如果需要更复杂的Volume类型（如PVC、ConfigMap等），可以继续提问！ 😊