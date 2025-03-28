import mysql, { ResultSetHeader } from "mysql2/promise";
import { LoanRequest } from '../connector/dto';


export class LoanRepository {
  constructor(private readonly db: mysql.Connection) {}

  private isResultSetHeader(res: any): res is ResultSetHeader {
    return (res as ResultSetHeader).affectedRows !== undefined;
  }

  async addLoan(loanReq: LoanRequest): Promise<boolean> {
    const [res, _] = await this.db.execute(`
      INSERT INTO loans (account, currency, amount) 
      VALUES (?, (SELECT id FROM currencies WHERE name = ?), ?) 
      ON DUPLICATE KEY UPDATE amount = amount + ?`, 
      [loanReq.account, loanReq.currency, loanReq.amount, loanReq.amount]
    )
    
    if (!this.isResultSetHeader(res)) {
      return false;
    }

    return res.affectedRows == 1;
  }

  async reimburseLoan(loanReq: LoanRequest): Promise<boolean> {
    const [res, _] = await this.db.execute(`
      UPDATE loans 
      SET amount = amount - ? 
      WHERE account = ? AND currency = (SELECT id FROM currencies WHERE name = ?) AND amount >= ?`, 
      [loanReq.amount, loanReq.account, loanReq.currency, loanReq.amount]
    )
    
    if (!this.isResultSetHeader(res)) {
      return false;
    }

    return res.affectedRows == 1;
  }
}