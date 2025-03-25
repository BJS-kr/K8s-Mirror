# K8s MSA

분리된 서비스 두 개가 존재합니다. k8s 클러스터에 집중하기 위해 미니멀하게 구현했습니다.
각각 다른 팀이 구현 중이라고 가정하고 다른 언어와 데이터베이스를 사용했습니다.

### 계좌 서비스
구현: Go, PostgreSQL
기능: 계좌 생성, 대출 및 상환 요청, 잔고 조회

### 대출 서비스
구현: Node.js, MySQL
기능: 대출 및 상환 가능 여부 판단, 대출 및 상환

## Gateway
Gateway Resource를 빌드한 방법: https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/

서버 접속 구조
Nginx Gateway(nginx-gateway service in nginx-gateway namespace) -> Gateway -> ClusterIP(for Deployment) -> Pod
트러블: nginx gateway 서비스를 내가 따로 생성해줘야 되는줄 알았음. 위 링크대로 설치하면 nginx-gateway ns에 자동으로 접속 서비스가 생기는 거였음. 설치과정에서 자동으로 nginx GatewayClass가 default ns에 생성됨
GatewayClass, Gateway, HTTPRoute 전부 default ns에 있지만 GatewayClass가 nginx-gateway controller랑 소통하고 있으므로 nginx-gateway ns에 있는 nginx-gateway svc와 협업할 수 있는 것임
port forward를 해줘야 한다는건 docker desktop + Kind 때문인데, Kind를 수동 설치하면 extraPortMapping를 설정할 수 있지만 docker desktop에서는 설정 자체가 아예 노출이 안됨.
즉, control-plane에서 자동 할당된 포트 말고는 외부와 그 어떤 통신도 불가능해짐 NodePort를 쓰건 LB를 쓰건 마찬가지다. 원래 Kind에서 NodePort나 LB쓰려면 extraPortMappings해줘야 함.

좀 더 자세히는 Nginx Gateway pod는 내부에 컨테이너 두 개를 돌리는데, 하나는 Nginx gateway fabric이고, 하나는 그냥 nginx임.
Nginx gateway fabric이 kube api server와 소통해서 자원을 탐색하는거고, nginx는 fabric이 찾아온 결과대로 routing을 구성하는 것임.
전체 아키텍처는 https://docs.nginx.com/nginx-gateway-fabric/overview/gateway-architecture/ 를 참고


hpa를 위해 metrics-server 설치한다. kubelet-insecure-tls를 임시로 추가한다.
공식 문서에서 지정하는 apply커맨드를 실행 후 deployment를 edit한다.
https://github.com/kubernetes-sigs/metrics-server#deployment

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl edit deployment metrics-server -n kube-system
```
hpa의 타겟 utilization이 unknown으로 나올 때가 있는데, pod에 request cpu안넣어서 그런경우가 있다고 하는데 난 넣었는데? describe에서도 확인 됨
계속 안되길래 describe hpa해보니 pg의 메트릭이 없다고 나온다?? 
알고보니 deploy의 selector를 app: account-service로 해두었다. 

### File naming

1. 공식 축약어를 파일 이름에 사용. svc, pv 등
2. 공식 축약어가 없는 resource의 경우 소문자로 풀 네임: statefulset, networkpolicy 등
3. 계층적 구조일 경우 . 으로 계층 구분. 예) server.gateway.svc.yaml 등
4. 위계가 아닌 경우 - 으로 단어 구분. 예) account-service-secret.yaml 등