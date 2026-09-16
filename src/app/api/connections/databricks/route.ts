import { databaseFailure, fail, ok } from "@/lib/api"; import { getDatabricksConnection } from "@/lib/queries/connections";
export const runtime="nodejs"; export const dynamic="force-dynamic";
export async function GET(){try{const data=await getDatabricksConnection();return data?ok(data):fail("Databricks connection not found",404);}catch{return databaseFailure("Databricks connection");}}
