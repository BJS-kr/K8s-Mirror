import mysql from "mysql2/promise";

export const init = async (conn: mysql.Connection) => {
  await conn.execute(`
    CREATE TABLE IF NOT EXISTS currencies (
      id TINYINT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(3) NOT NULL UNIQUE
    )
  `)
  
  await conn.execute(`  
    CREATE TABLE IF NOT EXISTS loans (
      amount INT NOT NULL,
      currency TINYINT NOT NULL,
      account VARCHAR(20) NOT NULL,

      PRIMARY KEY (account, currency),
      FOREIGN KEY (currency) REFERENCES currencies(id)
    )
  `)

  await conn.execute(`
    INSERT INTO currencies (name) VALUES ('USD'), ('KRW'), ('JPY'), ('EUR'), ('GBP')
    ON DUPLICATE KEY UPDATE name = name
  `)
}