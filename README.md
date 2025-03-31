# K8s MSA

K8s 클러스터와 http 서버 두 개가 포함되어있습니다.  
서버는 각각 다른 팀이 구현 중이라고 가정하고 다른 언어와 데이터베이스를 사용했습니다.

## 서비스
### 계좌 서비스 (app/account-service)
구현: Go, PostgreSQL  
기능: 계좌 생성, 대출 및 상환 요청, 잔고 조회  
  
### 대출 서비스 (app/loan-service)
구현: Node.js, MySQL  
기능: 상환 가능 여부 판단, 대출 및 상환  
  
## K8s (k8s/)
### 개요
1. account-service, loan-service 디렉토리가 생성되어있으며, 각각의 서비스를 위한 resource definitions로 이루어져 있습니다.  
2. 각 서비스 디렉토리는 db, server 하위 디렉토리로 구성되어 있습니다.  
3. 비용이 두려워 클러스터를 클라우드에 배포하지 않았습니다.

### 실행
script(k8s/cluster.up.sh)로 실행합니다.

```bash
cd k8s
sh cluster.up.sh
```

### 서비스의 구성
하나의 서비스는 아래와 같이 동작하며, 각 서비스는 같은 구조를 따릅니다.

<br />
<img src="flow.jpg" alt="architecture" width="500"> 
</img>

# 개발 환경
Kind(Kubernetes v1.32.2) 3 nodes  
Windows docker desktop 4.0.0(Docker 28.0.1)  
WSL2 Ubuntu 22.04  


