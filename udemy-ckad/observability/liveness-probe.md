### 基本概念
Liveness probe是Kubernetes中用于检测容器是否健康的机制。当探测失败时，Kubernetes会根据配置重启容器，确保应用始终处于可用状态。

### 简单案例：基于HTTP请求的存活探针

下面是一个使用Nginx的Deployment配置，包含了基本的liveness probe设置：
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
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
        image: nginx:1.24
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 10
          timeoutSeconds: 1
          successThreshold: 1
          failureThreshold: 3
```

### 配置参数解释
- **httpGet**: 通过HTTP请求进行探测，检查Nginx的根路径(/)
- **initialDelaySeconds**: 容器启动后等待15秒再开始探测
- **periodSeconds**: 每10秒进行一次探测
- **timeoutSeconds**: 探测请求超时时间为1秒
- **successThreshold**: 连续1次成功视为健康
- **failureThreshold**: 连续3次失败视为不健康，触发容器重启

### 练习题

#### 题目1：修改存活探针配置
- 要求：将探测路径改为`/healthz`，并设置更长的超时时间(5秒)
- 提示：你需要修改`httpGet.path`和`timeoutSeconds`参数

#### 题目2：添加命令行探针
- 要求：为容器添加一个命令行探针，通过执行`nginx -t`命令检查配置是否正确
- 提示：使用`exec`类型的探针，配置示例：
```yaml
livenessProbe:
  exec:
    command:
    - nginx
    - -t
```

#### 题目3：理解探针参数
- 问题：如果将`failureThreshold`设置为1，会发生什么？
- 答案：容器只要探测失败1次就会被重启，可能导致服务不稳定

### 解题步骤

#### 题目1解答
修改后的配置片段：
```yaml
livenessProbe:
  httpGet:
    path: /healthz  # 修改探测路径
    port: 80
  initialDelaySeconds: 15
  periodSeconds: 10
  timeoutSeconds: 5  # 增加超时时间
  successThreshold: 1
  failureThreshold: 3
```

#### 题目2解答
完整的Deployment配置：
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
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
        image: nginx:1.24
        ports:
        - containerPort: 80
        livenessProbe:
          exec:  # 使用命令行探针
            command:
            - nginx
            - -t
          initialDelaySeconds: 10
          periodSeconds: 30
```

#### 题目3解析
将`failureThreshold`设置为1会使探针变得过于敏感。即使是短暂的网络波动或临时负载高峰导致的探测失败，也会触发容器重启，可能导致服务频繁中断。通常建议将此值设置为3或更高，以容忍偶发的不稳定情况。

### 验证方法
部署应用后，你可以使用以下命令查看探针状态：
```bash
kubectl describe pod <pod-name>
```
在输出中查找"Liveness probe"部分，查看探针的执行结果和状态。


Kubernetes 允许为同一个容器设置多种类型的存活探针（Liveness Probe），但需要注意的是同一时间只能使用一种探测方式。