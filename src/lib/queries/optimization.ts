import { query } from "@/lib/db";

export async function getOptimizationOpportunities() {
  const { rows } = await query<{ id: string; resource_name: string; resource_type: string; workspace_name: string; issue_type: string; issue: string; current_monthly_cost: string; potential_saving: string; recommendation: string; risk: string; status: string; detected_at: Date }>(`
    SELECT o.id, r.resource_name, r.resource_type, w.workspace_name, o.issue_type, o.issue, o.current_monthly_cost, o.potential_saving, o.recommendation, o.risk, o.status, o.detected_at
    FROM optimization_opportunities o LEFT JOIN databricks_resources r ON r.id = o.resource_id LEFT JOIN databricks_workspaces w ON w.id = r.workspace_id
    ORDER BY CASE WHEN o.status = 'OPEN' THEN 0 ELSE 1 END, o.potential_saving DESC`);
  return rows.map((r) => ({ id: r.id, resourceName: r.resource_name, resourceType: r.resource_type, workspaceName: r.workspace_name, issueType: r.issue_type, issue: r.issue, currentMonthlyCost: Number(r.current_monthly_cost), potentialSaving: Number(r.potential_saving), recommendation: r.recommendation, risk: r.risk, status: r.status, detectedAt: r.detected_at }));
}
