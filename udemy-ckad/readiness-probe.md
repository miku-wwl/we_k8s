### 就绪探针（Readiness Probe）基础概念

就绪探针用于判断容器是否已经就绪可以接收外部流量。当一个Pod内的容器被判定为未就绪时，Kubernetes不会将该容器所在Pod包含在Service的负载均衡池中。

### 简单案例：Nginx服务就绪探针配置

下面是一个包含就绪探针配置的Nginx Deployment示例：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
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
        image: nginx:1.24.0
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5  # 容器启动后等待5秒开始探测
          periodSeconds: 10       # 每10秒探测一次
          successThreshold: 1     # 连续1次成功视为就绪
          failureThreshold: 3     # 连续3次失败视为未就绪
          timeoutSeconds: 1       # 探测超时时间1秒
```

### 配置参数说明

这个就绪探针配置使用了HTTP GET请求方式，主要参数解释：

- `httpGet.path`: 探针发送HTTP请求的路径
- `httpGet.port`: 探针发送HTTP请求的端口
- `initialDelaySeconds`: 容器启动后等待多久开始执行探针检查
- `periodSeconds`: 探针执行的频率
- `successThreshold`: 连续多少次成功才被认为就绪
- `failureThreshold`: 连续多少次失败才被认为未就绪
- `timeoutSeconds`: 探针请求超时时间

### 练习题

#### 练习1：修改探针配置

给定以下Deployment YAML，修改它添加就绪探针配置：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:1.0.0
        ports:
        - containerPort: 8080
```

要求：
1. 使用HTTP GET方式探测路径`/healthz`
2. 容器启动后10秒开始探测
3. 每5秒探测一次
4. 连续2次成功视为就绪
5. 连续4次失败视为未就绪
6. 超时时间设置为2秒

#### 练习2：分析探针配置问题

分析以下就绪探针配置存在哪些问题：

```yaml
readinessProbe:
  httpGet:
    path: /status
    port: 8080
  initialDelaySeconds: 0
  periodSeconds: 1
  successThreshold: 3
  failureThreshold: 1
  timeoutSeconds: 5
```

### 解题步骤

#### 练习1解答

修改后的YAML文件如下：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
  labels:
    app: myapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:1.0.0
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
          successThreshold: 2
          failureThreshold: 4
          timeoutSeconds: 2
```

#### 练习2问题分析

这个探针配置存在以下问题：

1. `initialDelaySeconds: 0` - 容器可能还未完全启动就开始探测，容易误判
2. `periodSeconds: 1` - 探测频率过高，可能影响应用性能
3. `successThreshold: 3` - 需要连续3次成功才就绪，标准偏高
4. `failureThreshold: 1` - 只允许1次失败，容错性太低
5. `timeoutSeconds: 5` - 超时时间较长，可能导致故障发现不及时

推荐改进配置：

```yaml
readinessProbe:
  httpGet:
    path: /status
    port: 8080
  initialDelaySeconds: 10  # 等待容器启动
  periodSeconds: 5        # 降低探测频率
  successThreshold: 1     # 一次成功即可
  failureThreshold: 3     # 增加容错性
  timeoutSeconds: 2       # 缩短超时时间
```

### 验证方法

部署带有就绪探针的应用后，可以使用以下命令验证：

1. 查看Pod状态：`kubectl get pods`
2. 查看探针详细状态：`kubectl describe pod <pod-name>`
3. 查看事件日志：`kubectl get events`

当就绪探针失败时，Pod状态会显示`NotReady`，并且在事件日志中可以看到探针失败的记录。