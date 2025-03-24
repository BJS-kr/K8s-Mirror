FROM golang:1.23.2 AS builder

WORKDIR /app

COPY . .

RUN go build -o account_service

# alpine으로 했을 때 libc.so.6가 없음. 설치 과정을 거치는 것보다 busybox로
FROM busybox

WORKDIR /app

COPY ./.env .
COPY --from=builder /app/account_service .

CMD ["./account_service"]