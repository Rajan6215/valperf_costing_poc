import { databaseFailure, ok } from "@/lib/api"; import { getInventory } from "@/lib/queries/inventory";
export const runtime="nodejs"; export const dynamic="force-dynamic";
export async function GET(){try{return ok(await getInventory());}catch{return databaseFailure("Inventory");}}
