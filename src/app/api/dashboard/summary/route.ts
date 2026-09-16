import { databaseFailure, ok } from "@/lib/api"; import { getDashboardSummary } from "@/lib/queries/dashboard";
export const runtime="nodejs"; export const dynamic="force-dynamic";
export async function GET(){try{return ok(await getDashboardSummary());}catch{return databaseFailure("Dashboard summary");}}
