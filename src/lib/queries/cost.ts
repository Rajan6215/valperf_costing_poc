import { query } from "@/lib/db";

export type CostFilters = { from?: string; to?: string; workspace?: string; product?: string; resourceType?: string };
export function isDate(value: string) { return /^\d{4}-\d{2}-\d{2}$/.test(value) && !Number.isNaN(Date.parse(`${value}T00:00:00Z`)); }

export async function getCosts(filters: CostFilters) {
  const conditions: string[] = []; const values: string[] = [];
  const add = (sql: string, value: string) => { values.push(value); conditions.push(sql.replace("?", `$${values.length}`)); };
  if (filters.from) add("c.usage_date >= ?::date", filters.from);
  if (filters.to) add("c.usage_date <= ?::date", filters.to);
  if (filters.workspace) add("w.workspace_name = ?", filters.workspace);
  if (filters.product) add("c.product_name = ?", filters.product);
  if (filters.resourceType) add("r.resource_type = ?", filters.resourceType);
  if (!filters.from && !filters.to) conditions.push("c.usage_date >= date_trunc('month', CURRENT_DATE)");
  const where = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
  const { rows } = await query<{ date: string; workspace_name: string; product_name: string; resource_name: string; resource_type: string; cost: string; currency: string }>(`
    SELECT c.usage_date::date::text AS date, w.workspace_name, c.product_name, r.resource_name, r.resource_type, SUM(c.cost) AS cost, COALESCE(c.currency, 'USD') AS currency
    FROM cost_usage c JOIN databricks_resources r ON r.id = c.resource_id JOIN databricks_workspaces w ON w.id = c.workspace_id
    ${where} GROUP BY c.usage_date::date, w.workspace_name, c.product_name, r.resource_name, r.resource_type, c.currency ORDER BY c.usage_date DESC, cost DESC`, values);
  const items = rows.map((r) => ({ date: r.date, workspaceName: r.workspace_name, productName: r.product_name, resourceName: r.resource_name, resourceType: r.resource_type, cost: Number(r.cost), currency: r.currency }));
  return { total: items.reduce((sum, item) => sum + item.cost, 0), items };
}
