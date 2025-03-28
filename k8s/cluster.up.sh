# nginx gateway fabric 설치 및 배포
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v1.6.2" | kubectl apply -f -
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v1.6.2/deploy/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v1.6.2/deploy/default/deploy.yaml

# metrics-server 배포
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system --type=json -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# worker에 volume path에 해당하는 dir을 만들어야 함. 경로 확인은 db/db.pv.yaml내 볼륨 경로와 일치해야 함
# 아래의 명령어는 control-plane 1개, worker 2개를 생성했다는 가정임
# 두 노드에 미리 volume path여러개 만들어두는 의미
sudo docker exec desktop-worker mkdir -p /mnt/disks/vol1
sudo docker exec desktop-worker mkdir -p /mnt/disks/vol2
sudo docker exec desktop-worker2 mkdir -p /mnt/disks/vol1
sudo docker exec desktop-worker2 mkdir -p /mnt/disks/vol2


# 공유 스토리지 생성
kubectl apply -f shared.sc.yaml

# 서비스 배포
kubectl apply -f account-service/db/
kubectl apply -f account-service/server/

# 서비스 배포
kubectl apply -f loan-service/db/
kubectl apply -f loan-service/server/
