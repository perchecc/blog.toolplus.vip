---
title: 五分钟快速部署：用 Docker 和 Docker Compose 部署 FastAPI 应用
publishDate: 2025-09-20
updatedDate: 2025-09-20
tags: 
  - FastAPI
  - Docker
description: ""
---

本指南提供一个极简的 FastAPI 应用从代码到部署的全流程。

#### 1. 准备项目文件
创建项目目录，并在此目录下创建以下文件：

**1. `main.py` (FastAPI 应用代码)**
```python
from fastapi import FastAPI
app = FastAPI()
@app.get("/")
def read_root():
    return {"Hello": "World"}
```

**2. `requirements.txt` (项目依赖)**
```
fastapi==0.104.1
uvicorn[standard]==0.24.0
```

**3. `Dockerfile` (构建镜像的指令)**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**4. `docker-compose.yml` (定义和启动服务)**
```yaml
services:
  fastapi-app:
    build: .
    container_name: my-fastapi-app
    ports:
      - "8000:8000"
    restart: unless-stopped
```

#### 2. 部署命令
1.  将以上文件通过 1Panel 的文件管理器或 `scp` 命令上传到服务器。
2.  在服务器上，进入项目目录。
3.  执行一键部署命令：
    ```bash
    docker-compose up -d
    ```
4.  访问 `http://你的服务器IP:8000` 查看结果，访问 `http://你的服务器IP:8000/docs` 查看交互文档。

#### 3. 项目结构
```
my-fastapi-project/
├── main.py
├── requirements.txt
├── Dockerfile
└── docker-compose.yml
```

---