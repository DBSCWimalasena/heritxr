import mysql from "mysql2";
import fs from "fs";
import path from "path";
import dotenv from "dotenv";

dotenv.config();

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT),
  ssl: {
    ca: fs.readFileSync(
      path.resolve("certs/DigiCertGlobalRootG2.crt.pem")
    )
  }
});

db.connect((err) => {
  if (err) {
    console.error("❌ MySQL connection failed:", err.message);
  } else {
    console.log("✅ MySQL connected to Azure");
  }
});

export default db;
