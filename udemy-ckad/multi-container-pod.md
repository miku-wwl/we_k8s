### **一、多容器Pod基础概念**
多容器Pod就像一个"公寓"，里面住着多个"居民"（容器）：
- **共享空间**：所有容器可以访问相同的网络（IP地址）和存储（磁盘）。
- **共同命运**：所有容器一起启动、一起停止。

**典型场景**：一个容器负责主要工作，另一个容器提供辅助功能（如日志收集、文件同步）。


### **二、超级简单案例：Web服务器 + 文件更新器**
#### **场景说明**
- **主容器**：Nginx Web服务器，显示`/usr/share/nginx/html/index.html`的内容。
- **辅助容器**：BusyBox，每10秒更新一次`index.html`文件中的时间戳。
- **共享存储**：使用`emptyDir`（临时内存磁盘）让两个容器读写同一个文件。


### **三、命令式部署（一步步操作）**
#### **1. 创建Pod（只包含Nginx）**
```bash
kubectl run webserver --image=nginx:1.25 --port=80 --restart=Never
```

#### **2. 编辑Pod，添加第二个容器和共享卷**
```bash
kubectl edit pod webserver
```

在编辑器中，找到`spec.containers`部分，添加第二个容器：
```yaml
  - name: time-updater
    image: busybox
    command: ["/bin/sh", "-c"]
    args:
      - |
        while true; do
          echo "<h1>Hello from K8s! Time: $(date)</h1>" > /var/www/index.html
          sleep 10
        done
    volumeMounts:
      - name: shared-files
        mountPath: /var/www
```

在`spec`部分底部添加卷定义：
```yaml
volumes:
  - name: shared-files
    emptyDir: {}
```

修改Nginx容器的`volumeMounts`，挂载相同的卷到`/usr/share/nginx/html`：
```yaml
    volumeMounts:
      - name: shared-files
        mountPath: /usr/share/nginx/html
```

最终YAML结构如下（只显示关键部分）：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webserver
spec:
  containers:
    - name: nginx
      image: nginx:1.25
      ports:
        - containerPort: 80
      volumeMounts:
        - name: shared-files
          mountPath: /usr/share/nginx/html
    - name: time-updater
      image: busybox
      command: ["/bin/sh", "-c"]
      args:
        - |
          while true; do
            echo "<h1>Hello from K8s! Time: $(date)</h1>" > /var/www/index.html
            sleep 10
          done
      volumeMounts:
        - name: shared-files
          mountPath: /var/www
  volumes:
    - name: shared-files
      emptyDir: {}
```


### **四、声明式部署（YAML文件）**
simple-pod.yaml

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: webserver
spec:
  containers:
    - name: nginx
      image: nginx:1.25
      ports:
        - containerPort: 80
      volumeMounts:
        - name: shared-files
          mountPath: /usr/share/nginx/html
    - name: time-updater
      image: busybox
      command: ["/bin/sh", "-c"]
      args:
        - |
          while true; do
            echo "<h1>Hello from K8s! Time: $(date)</h1>" > /var/www/index.html
            sleep 10
          done
      volumeMounts:
        - name: shared-files
          mountPath: /var/www
  volumes:
    - name: shared-files
      emptyDir: {}
```



### **五、验证部署结果**
#### **1. 应用YAML文件**
```bash
kubectl apply -f simple-pod.yaml
```

#### **2. 检查Pod状态**
```bash
kubectl get pods webserver
# 等待状态变为 Running
```

#### **3. 查看容器日志**
```bash
# 查看Nginx日志
kubectl logs webserver -c nginx

# 查看时间更新器日志
kubectl logs webserver -c time-updater
```

#### **4. 访问Web服务器**
```bash
# 端口转发到本地
kubectl port-forward webserver 8080:80

# 在浏览器打开 http://localhost:8080
# 每10秒刷新页面，时间戳会更新
```


### **六、练习题（适合初学者）**
#### **1. 基础题：修改更新频率**
**题目**：将时间更新器的更新频率从10秒改为5秒。

**解题步骤**：
```bash
# 1. 编辑Pod
kubectl edit pod webserver

# 2. 找到time-updater容器的args部分
# 3. 将sleep 10改为sleep 5
# 4. 保存退出，Kubernetes会自动重启容器
```

#### **2. 进阶题：添加第三个容器**
**题目**：添加一个名为`counter`的容器，统计`index.html`的更新次数。

**解题步骤**：
1. 编辑Pod：`kubectl edit pod webserver`
2. 添加第三个容器：
```yaml
    - name: counter
      image: busybox
      command: ["/bin/sh", "-c"]
      args:
        - |
          count=0
          while true; do
            if [ -f /var/www/index.html ]; then
              count=$((count+1))
              echo "Update count: $count" > /var/www/count.txt
            fi
            sleep 1
          done
      volumeMounts:
        - name: shared-files
          mountPath: /var/www
```
3. 访问`http://localhost:8080/count.txt`查看统计结果


### **七、关键概念回顾**
1. **共享存储**：通过`emptyDir`卷实现容器间文件共享。
2. **多容器协作**：一个容器写文件，另一个容器读文件。
3. **命令式 vs 声明式**：
   - 命令式：适合快速测试，直接修改运行中的Pod。
   - 声明式：适合生产环境，通过YAML文件管理。