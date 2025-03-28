import express from "express";
import "dotenv/config";
import { makeLoanRouter } from './loan/router';
import { LoanRepository } from './loan/repository';
import { makeConn } from './db/makeConn';
import { init } from './db/init';

async function main() {
  const app = express();
  const conn = await makeConn();
  
  await init(conn);
  
  app.use(express.json());
  app.get("/health", (_, res) => void res.sendStatus(200))
  app.use("/api", makeLoanRouter(new LoanRepository(conn)))
  app.all("*", (_, res) => void res.sendStatus(404))

  app.listen(process.env.HTTP_PORT || 8081, () => {
    console.log(`Loan service is running on port ${process.env.HTTP_PORT || 8081}`)
  })
}

main()