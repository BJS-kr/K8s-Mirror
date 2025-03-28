import { test, before, after } from 'node:test';
import assert from 'node:assert';
import mysql from 'mysql2/promise';
import { LoanRepository } from './repository';
import { LoanRequest } from '../connector/dto';
import { GenericContainer, StartedTestContainer } from 'testcontainers';
import { init } from '../db/init';

let container: StartedTestContainer;
let db: mysql.Connection;
let loanRepo: LoanRepository;

async function setupDatabase() {
  container = await new GenericContainer('mysql:9.2')
    .withEnvironment({
      MYSQL_DATABASE: 'test',
      MYSQL_ROOT_PASSWORD: 'test',
    })
    .withExposedPorts(3306)
    .start();

  const port = container.getMappedPort(3306);
  const host = container.getHost();

  db = await mysql.createConnection({
    host,
    port,
    user: 'root',
    password: 'test',
  });

  await init(db);

  loanRepo = new LoanRepository(db);
}

before(async () => {
  await setupDatabase();
});

after(async () => {
  await db.end();
  await container.stop();
});

test('addLoan should insert a new loan', async () => {
  const loanReq: LoanRequest = { account: 'test_acc', currency: 'USD', amount: 1000 };
  const result = await loanRepo.addLoan(loanReq);
  assert.strictEqual(result, true);

  const [rows] = await db.execute('SELECT amount FROM loans WHERE account = ? AND currency = (SELECT id FROM currencies WHERE name = ?)', [loanReq.account, loanReq.currency]);
  assert.strictEqual((rows as any)[0].amount, 1000);
});

test('reimburseLoan should update the loan amount', async () => {
  const loanReq: LoanRequest = { account: 'test_acc', currency: 'USD', amount: 500 };
  const result = await loanRepo.reimburseLoan(loanReq);
  assert.strictEqual(result, true);

  const [rows] = await db.execute('SELECT amount FROM loans WHERE account = ? AND currency = (SELECT id FROM currencies WHERE name = ?)', [loanReq.account, loanReq.currency]);
  assert.strictEqual((rows as any)[0].amount, 500);
});

test('reimburseLoan should fail when reimbursing more than available', async () => {
  const loanReq: LoanRequest = { account: 'test_acc', currency: 'USD', amount: 2000 };
  const result = await loanRepo.reimburseLoan(loanReq);
  assert.strictEqual(result, false);
});
