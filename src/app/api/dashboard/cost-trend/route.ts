import { databaseFailure, ok } from "@/lib/api"; import { getCostTrend } from "@/lib/queries/dashboard";
export const runtime="nodejs"; export const dynamic="force-dynamic";
export async function GET(){try{return ok(await getCostTrend());}catch{return databaseFailure("Cost trend");}}
