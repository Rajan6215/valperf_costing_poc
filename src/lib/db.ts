import { Pool, type QueryResultRow } from "pg";

const required = ["PGHOST", "PGPORT", "PGDATABASE", "PGUSER", "PGPASSWORD"] as const;

function createPool() {
  const missing = required.filter((name) => !process.env[name]);
  if (missing.length) throw new Error(`Missing PostgreSQL configuration: ${missing.join(", ")}`);
  return new Pool({
    host: process.env.PGHOST,
    port: Number(process.env.PGPORT),
    database: process.env.PGDATABASE,
    user: process.env.PGUSER,
    password: process.env.PGPASSWORD,
    max: 10,
    idleTimeoutMillis: 30_000,
    connectionTimeoutMillis: 5_000,
  });
}

const globalForDb = globalThis as unknown as { valperfPool?: Pool };
export const pool = globalForDb.valperfPool ?? createPool();
if (process.env.NODE_ENV !== "production") globalForDb.valperfPool = pool;

export async function query<T extends QueryResultRow>(text: string, values: unknown[] = []) {
  return pool.query<T>(text, values);
}
