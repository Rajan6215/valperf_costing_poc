import { query } from "@/lib/db";

export async function getDashboardSummary() {
  const { rows } = await query<{ monthly_spend: string; previous_month_spend: string; potential_savings: string; active_workspaces: string }>(`
    SELECT
      COALESCE((SELECT SUM(cost) FROM cost_usage WHERE usage_date >= date_trunc('month', CURRENT_DATE)), 0) AS monthly_spend,
      COALESCE((SELECT SUM(cost) FROM cost_usage WHERE usage_date >= date_trunc('month', CURRENT_DATE) - interval '1 month' AND usage_date < date_trunc('month', CURRENT_DATE)), 0) AS previous_month_spend,
      COALESCE((SELECT SUM(potential_saving) FROM optimization_opportunities WHERE status = 'OPEN'), 0) AS potential_savings,
      COALESCE((SELECT COUNT(DISTINCT workspace_id) FROM cost_usage WHERE usage_date >= date_trunc('month', CURRENT_DATE)), 0) AS active_workspaces
  `);
  const row = rows[0];
  return { monthlySpend: Number(row.monthly_spend), previousMonthSpend: Number(row.previous_month_spend), potentialSavings: Number(row.potential_savings), activeWorkspaces: Number(row.active_workspaces), currency: "USD" };
}

export async function getCostTrend() {
  const { rows } = await query<{ date: string; cost: string }>(`SELECT usage_date::date::text AS date, SUM(cost) AS cost FROM cost_usage WHERE usage_date >= date_trunc('month', CURRENT_DATE) GROUP BY usage_date::date ORDER BY usage_date::date`);
  return rows.map((row) => ({ date: row.date, cost: Number(row.cost) }));
}

export async function getSpendByProduct() {
  const { rows } = await query<{ product: string; cost: string }>(`SELECT product_name AS product, SUM(cost) AS cost FROM cost_usage WHERE usage_date >= date_trunc('month', CURRENT_DATE) GROUP BY product_name ORDER BY SUM(cost) DESC`);
  return rows.map((row) => ({ product: row.product, cost: Number(row.cost) }));
}

export async function getTopResources(limit = 10) {
  const { rows } = await query<{ resource_name: string; resource_type: string; workspace_name: string; owner: string | null; environment: string | null; monthly_cost: string }>(`
    SELECT r.resource_name, r.resource_type, w.workspace_name, r.owner, r.environment, SUM(c.cost) AS monthly_cost
    FROM cost_usage c JOIN databricks_resources r ON r.id = c.resource_id JOIN databricks_workspaces w ON w.id = c.workspace_id
    WHERE c.usage_date >= date_trunc('month', CURRENT_DATE)
    GROUP BY r.id, r.resource_name, r.resource_type, w.workspace_name, r.owner, r.environment
    ORDER BY monthly_cost DESC LIMIT $1`, [limit]);
  return rows.map((r) => ({ resourceName: r.resource_name, resourceType: r.resource_type, workspaceName: r.workspace_name, owner: r.owner, environment: r.environment, monthlyCost: Number(r.monthly_cost) }));
}
