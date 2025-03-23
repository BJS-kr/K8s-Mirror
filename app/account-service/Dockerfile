FROM golang:1.23.2 AS builder

WORKDIR /app

COPY . .

RUN go build -o main main.go

FROM alpine:latest

WORKDIR /

COPY --from=builder /app/main .

CMD ["./main"]