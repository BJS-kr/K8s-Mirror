import express from "express";
import { LoanRequest } from '../connector/dto';
import { LoanRepository } from './repository';


const isLoanRequest = (body: any): body is LoanRequest => {
  if (typeof body.account !== 'string') return false;
  
  switch (body.currency) {
    case 'USD':
    case 'KRW':
    case 'JPY':
    case 'EUR':
    case 'GBP':
      break;
    default:
      return false;
  }

  if (typeof body.amount !== 'number') return false;

  return true;
}

export const requestLoan =  (loanRepository:LoanRepository) => async (req:express.Request, res:express.Response) => {
    if (!isLoanRequest(req.body)) {
      res.status(400).send("Invalid request");
      return;
    }

    const result = await loanRepository.addLoan(req.body);

    if (!result) {
      res.status(400).send("Failed to add loan");
      return;
    }

    res.sendStatus(200);
  }

export const returnLoan =  (loanRepository:LoanRepository) => async (req:express.Request, res:express.Response) => {
    if (!isLoanRequest(req.body)) {
      res.status(400).send("Invalid request");
      return;
    }

    const result = await loanRepository.reimburseLoan(req.body);

    if (!result) {
      res.status(400).send("Failed to reimburse loan");
      return;
    }

    res.sendStatus(200);
  }