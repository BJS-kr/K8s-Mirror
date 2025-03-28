export interface LoanRequest {
  account: string;
  currency: 'USD' | 'KRW' | 'JPY' | 'EUR' | 'GBP';
  amount: number;
}

