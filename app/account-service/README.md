# Account Service

Loan Service와 통신하여 잔액을 변경합니다.
계좌 생성 직후 잔액은 0원 입니다.
화폐의 종류는 USD, KRW, JPY 입니다.

금액 추가 요청시: 
  1. 요청 금액만큼 Stock이 충분하다면 잔액 증가
  2. 성공시 Loan Service에서 요청된 Currency차감
금액 차감 요청시: 
  1. 요청 금액만큼 잔액이 충분하다면 잔액 감가
  2. 성공시 Loan Service에서 요청된 Currency 증가


## 기능

- 계좌 생성
- 계좌 잔액 변경
- 계좌 잔액 조회

## 테스트

```bash
go test -v -race ./account
```
