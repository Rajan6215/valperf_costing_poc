import { query } from "@/lib/db";

export async function getDatabricksConnection() {
  const { rows } = await query<{ id: string; connection_name: string; cloud_provider: string; workspace_url: string; account_id: string; authentication_type: string; status: string; last_sync_at: Date | null }>(`
    SELECT id, connection_name, cloud_provider, workspace_url, account_id, authentication_type, status, last_sync_at
    FROM databricks_connections ORDER BY created_at DESC LIMIT 1`);
  const r = rows[0]; if (!r) return null;
  return { id: r.id, connectionName: r.connection_name, cloudProvider: r.cloud_provider, workspaceUrl: r.workspace_url, accountId: r.account_id, authenticationType: r.authentication_type, status: r.status, lastSyncAt: r.last_sync_at };
}

export async function getSyncStatus() {
  const { rows } = await query<{ sync_type: string; started_at: Date; completed_at: Date | null; status: string; records_processed: string }>(`SELECT sync_type, started_at, completed_at, status, records_processed FROM sync_runs ORDER BY started_at DESC LIMIT 1`);
  const r = rows[0]; if (!r) return null;
  return { syncType: r.sync_type, startedAt: r.started_at, completedAt: r.completed_at, status: r.status, recordsProcessed: Number(r.records_processed) };
}

export async function getResourceTags(resourceId: string) {
  const { rows } = await query<{ key: string; value: string }>(`SELECT tag_key AS key, tag_value AS value FROM resource_tags WHERE resource_id = $1 ORDER BY tag_key`, [resourceId]);
  return rows;
}
