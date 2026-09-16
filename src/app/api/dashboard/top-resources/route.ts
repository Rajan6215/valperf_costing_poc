import { databaseFailure, ok } from "@/lib/api"; import { getTopResources } from "@/lib/queries/dashboard";
export const runtime="nodejs"; export const dynamic="force-dynamic";
export async function GET(){try{return ok(await getTopResources());}catch{return databaseFailure("Top resources");}}
