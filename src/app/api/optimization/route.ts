import { databaseFailure, ok } from "@/lib/api"; import { getOptimizationOpportunities } from "@/lib/queries/optimization";
export const runtime="nodejs"; export const dynamic="force-dynamic";
export async function GET(){try{return ok(await getOptimizationOpportunities());}catch{return databaseFailure("Optimization opportunities");}}
