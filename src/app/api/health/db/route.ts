import { databaseFailure, ok } from "@/lib/api"; import { query } from "@/lib/db";
export const runtime = "nodejs"; export const dynamic = "force-dynamic";
export async function GET(){try{const {rows}=await query<{database:string;server_time:Date}>("SELECT current_database() AS database, NOW() AS server_time");return ok({database:rows[0].database,serverTime:rows[0].server_time});}catch{return databaseFailure("Database health check");}}
