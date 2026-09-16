import { databaseFailure, ok } from "@/lib/api"; import { getInventorySummary } from "@/lib/queries/inventory";
export const runtime="nodejs"; export const dynamic="force-dynamic";
export async function GET(){try{return ok(await getInventorySummary());}catch{return databaseFailure("Inventory summary");}}
