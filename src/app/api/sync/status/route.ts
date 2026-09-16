import { databaseFailure, fail, ok } from "@/lib/api"; import { getSyncStatus } from "@/lib/queries/connections";
export const runtime="nodejs"; export const dynamic="force-dynamic";
export async function GET(){try{const data=await getSyncStatus();return data?ok(data):fail("Sync status not found",404);}catch{return databaseFailure("Sync status");}}
