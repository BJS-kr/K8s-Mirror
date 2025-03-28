import mysql from "mysql2/promise";

export const makeConn = async () => {
  const conn = await mysql.createConnection({
    host: process.env.NODE_ENV === 'development' ? 'localhost' : process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT || "3306"),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
  })

  await conn.execute(`
    CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME}
  `)

  await conn.query(`
    USE ${process.env.DB_NAME}
  `)

  return conn;
}
