### Init Container基础概念
Init Container是一种特殊容器，在Pod的主容器启动之前执行。它们通常用于：
- 执行初始化任务，如环境准备、依赖检查
- 等待外部服务就绪
- 执行一次性配置任务
- 与主容器共享数据

### 简单示例：使用Init Container准备静态文件
下面是一个包含Init Container的Pod配置示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
spec:
  containers:
  - name: main-container
    image: nginx:1.25
    ports:
    - containerPort: 80
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html
  # 定义Init Container
  initContainers:
  - name: init-container
    image: busybox:1.36
    command: ['sh', '-c', 'echo "Hello from Init Container" > /work-dir/index.html']
    volumeMounts:
    - name: workdir
      mountPath: /work-dir
  # 定义共享卷
  volumes:
  - name: workdir
    emptyDir: {}
```

### 配置说明
1. **主容器**：使用Nginx镜像，将共享卷挂载到默认的HTML目录
2. **Init Container**：使用BusyBox镜像，执行一个简单的shell命令创建index.html文件
3. **共享卷**：使用emptyDir类型的卷，用于在Init Container和主容器之间共享数据

### Init Container的关键特性
- **按定义顺序执行**：如果有多个Init Container，它们会按顺序逐个执行
- **执行完成后退出**：每个Init Container必须成功完成才能继续下一个
- **失败处理**：如果Init Container失败，Kubernetes会根据restartPolicy重启Pod
- **共享数据**：通过volumes实现与主容器的数据共享

### 练习题
1. 创建一个包含Init Container的Pod，要求：
   - Init Container从http://example.com下载一个文件
   - 主容器使用Nginx展示下载的文件

2. 创建一个带有多个Init Container的Pod，要求：
   - 第一个Init Container创建一个包含当前日期的文件
   - 第二个Init Container在该文件中追加"Processed by second init"
   - 主容器使用BusyBox打印该文件内容

### 练习题解答步骤
#### 问题1解答
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: download-demo
spec:
  containers:
  - name: web-server
    image: nginx:1.25
    ports:
    - containerPort: 80
    volumeMounts:
    - name: download-volume
      mountPath: /usr/share/nginx/html
  initContainers:
  - name: download-file
    image: busybox:1.36
    command: ['sh', '-c', 'wget -O /downloads/index.html http://example.com']
    volumeMounts:
    - name: download-volume
      mountPath: /downloads
  volumes:
  - name: download-volume
    emptyDir: {}
```

#### 问题2解答
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-init-demo
spec:
  containers:
  - name: print-file
    image: busybox:1.36
    command: ['sh', '-c', 'cat /data/output.txt']
    volumeMounts:
    - name: data-volume
      mountPath: /data
  initContainers:
  - name: create-file
    image: busybox:1.36
    command: ['sh', '-c', 'date > /data/output.txt']
    volumeMounts:
    - name: data-volume
      mountPath: /data
  - name: append-text
    image: busybox:1.36
    command: ['sh', '-c', 'echo "Processed by second init" >> /data/output.txt']
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    emptyDir: {}
```

### 验证方法
1. 对于问题1，可以通过以下命令验证：
   ```bash
   kubectl port-forward download-demo 8080:80
   curl http://localhost:8080
   ```

2. 对于问题2，可以通过查看Pod日志验证：
   ```bash
   kubectl logs multi-init-demo
   ```