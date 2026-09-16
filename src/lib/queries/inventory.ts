import { query } from "@/lib/db";

export async function getInventory() {
  const { rows } = await query<{ id: string; resource_name: string; resource_type: string; workspace_name: string; owner: string | null; environment: string | null; status: string; monthly_cost: string }>(`
    SELECT r.id, r.resource_name, r.resource_type, w.workspace_name, r.owner, r.environment, r.status, COALESCE(SUM(c.cost), 0) AS monthly_cost
    FROM databricks_resources r JOIN databricks_workspaces w ON w.id = r.workspace_id
    LEFT JOIN cost_usage c ON c.resource_id = r.id AND c.usage_date >= date_trunc('month', CURRENT_DATE)
    GROUP BY r.id, r.resource_name, r.resource_type, w.workspace_name, r.owner, r.environment, r.status ORDER BY monthly_cost DESC`);
  return rows.map((r) => ({ id: r.id, resourceName: r.resource_name, resourceType: r.resource_type, workspaceName: r.workspace_name, owner: r.owner, environment: r.environment, status: r.status, monthlyCost: Number(r.monthly_cost) }));
}

export async function getInventorySummary() {
  const { rows } = await query<{ total_resources: string; jobs: string; clusters: string; sql_warehouses: string; pipelines: string; model_serving: string }>(`
    SELECT COUNT(*) AS total_resources,
      COUNT(*) FILTER (WHERE resource_type = 'JOB') AS jobs,
      COUNT(*) FILTER (WHERE resource_type = 'CLUSTER') AS clusters,
      COUNT(*) FILTER (WHERE resource_type IN ('SQL_WAREHOUSE', 'WAREHOUSE')) AS sql_warehouses,
      COUNT(*) FILTER (WHERE resource_type = 'PIPELINE') AS pipelines,
      COUNT(*) FILTER (WHERE resource_type IN ('MODEL_SERVING', 'SERVING_ENDPOINT')) AS model_serving
    FROM databricks_resources`);
  const r = rows[0]; return { totalResources: Number(r.total_resources), jobs: Number(r.jobs), clusters: Number(r.clusters), sqlWarehouses: Number(r.sql_warehouses), pipelines: Number(r.pipelines), modelServing: Number(r.model_serving) };
}
