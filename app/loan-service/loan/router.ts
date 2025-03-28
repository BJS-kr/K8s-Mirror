import express from "express";
import { LoanRepository } from './repository';
import { requestLoan, returnLoan } from "./handlers";

export const makeLoanRouter = (loanRepository: LoanRepository) => {
  const loanRouter = express.Router();
  
  loanRouter.patch("/loan/request", requestLoan(loanRepository))
  loanRouter.patch("/loan/return", returnLoan(loanRepository))

  return loanRouter;
}


