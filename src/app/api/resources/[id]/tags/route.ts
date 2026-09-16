import { databaseFailure, fail, ok } from "@/lib/api"; import { getResourceTags } from "@/lib/queries/connections";
export const runtime="nodejs"; export const dynamic="force-dynamic";
export async function GET(_request:Request,{params}:{params:Promise<{id:string}>}){const {id}=await params;if(!id.trim())return fail("Resource ID is required",400);try{return ok(await getResourceTags(id));}catch{return databaseFailure("Resource tags");}}
