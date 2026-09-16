import { databaseFailure, ok } from "@/lib/api"; import { getSpendByProduct } from "@/lib/queries/dashboard";
export const runtime="nodejs"; export const dynamic="force-dynamic";
export async function GET(){try{return ok(await getSpendByProduct());}catch{return databaseFailure("Spend by product");}}
