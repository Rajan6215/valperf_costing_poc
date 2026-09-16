-- =========================================================
-- VALPERF POC - DUMMY / SEED DATA
-- Focus: Databricks Cost & Performance Optimization
-- Database: valperf_poc
--
-- IMPORTANT:
-- Run this script once on an empty ValPerf POC schema.
-- It assumes the tables from 01_create_tables.sql already exist.
-- =========================================================

BEGIN;

-- Stop accidental duplicate seeding.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM organizations
        WHERE name = 'Demo Organization'
    ) THEN
        RAISE EXCEPTION
            'Demo Organization already exists. Seed script appears to have already been run.';
    END IF;
END $$;

-- =========================================================
-- 1. ORGANIZATION
-- =========================================================
INSERT INTO organizations (name)
VALUES ('Demo Organization');

-- =========================================================
-- 2. USER
-- =========================================================
INSERT INTO users (
    organization_id,
    email,
    full_name,
    role,
    status
)
SELECT
    id,
    'admin@valperf.local',
    'ValPerf Admin',
    'ADMIN',
    'ACTIVE'
FROM organizations
WHERE name = 'Demo Organization';

-- =========================================================
-- 3. DATABRICKS CONNECTION
-- =========================================================
INSERT INTO databricks_connections (
    organization_id,
    connection_name,
    cloud_provider,
    workspace_url,
    account_id,
    authentication_type,
    status,
    last_sync_at
)
SELECT
    id,
    'Production Databricks',
    'AZURE',
    'https://adb-demo.azuredatabricks.net',
    'demo-account-001',
    'OAUTH_M2M',
    'CONNECTED',
    CURRENT_TIMESTAMP
FROM organizations
WHERE name = 'Demo Organization';

-- =========================================================
-- 4. DATABRICKS WORKSPACES
-- =========================================================
INSERT INTO databricks_workspaces (
    organization_id,
    connection_id,
    workspace_id,
    workspace_name,
    workspace_url,
    cloud_provider,
    region,
    status
)
SELECT
    o.id,
    c.id,
    w.workspace_id,
    w.workspace_name,
    w.workspace_url,
    'AZURE',
    'East US',
    'ACTIVE'
FROM organizations o
JOIN databricks_connections c
    ON c.organization_id = o.id
CROSS JOIN (
    VALUES
        ('ws-prod-001', 'Production Workspace', 'https://adb-production.azuredatabricks.net'),
        ('ws-analytics-001', 'Analytics Workspace', 'https://adb-analytics.azuredatabricks.net'),
        ('ws-dev-001', 'Development Workspace', 'https://adb-development.azuredatabricks.net')
) AS w(workspace_id, workspace_name, workspace_url)
WHERE o.name = 'Demo Organization'
  AND c.connection_name = 'Production Databricks';

-- =========================================================
-- 5. DATABRICKS RESOURCES
-- =========================================================

-- Production Workspace
INSERT INTO databricks_resources (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    resource_name,
    resource_type,
    owner,
    environment,
    status
)
SELECT
    o.id,
    c.id,
    w.id,
    r.resource_id,
    r.resource_name,
    r.resource_type,
    r.owner,
    r.environment,
    'ACTIVE'
FROM organizations o
JOIN databricks_connections c
    ON c.organization_id = o.id
JOIN databricks_workspaces w
    ON w.connection_id = c.id
CROSS JOIN (
    VALUES
        ('job-001', 'customer_etl_job', 'JOB', 'Data Engineering', 'PRODUCTION'),
        ('cluster-001', 'analytics_cluster', 'CLUSTER', 'Analytics Team', 'PRODUCTION'),
        ('job-002', 'daily_finance_job', 'JOB', 'Finance Data Team', 'PRODUCTION'),
        ('pipeline-001', 'customer360_pipeline', 'PIPELINE', 'Data Engineering', 'PRODUCTION')
) AS r(resource_id, resource_name, resource_type, owner, environment)
WHERE o.name = 'Demo Organization'
  AND c.connection_name = 'Production Databricks'
  AND w.workspace_name = 'Production Workspace';

-- Analytics Workspace
INSERT INTO databricks_resources (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    resource_name,
    resource_type,
    owner,
    environment,
    status
)
SELECT
    o.id,
    c.id,
    w.id,
    r.resource_id,
    r.resource_name,
    r.resource_type,
    r.owner,
    r.environment,
    'ACTIVE'
FROM organizations o
JOIN databricks_connections c
    ON c.organization_id = o.id
JOIN databricks_workspaces w
    ON w.connection_id = c.id
CROSS JOIN (
    VALUES
        ('warehouse-001', 'bi_warehouse', 'SQL_WAREHOUSE', 'BI Team', 'PRODUCTION'),
        ('job-003', 'ml_training', 'JOB', 'Machine Learning Team', 'PRODUCTION'),
        ('warehouse-002', 'reporting_warehouse', 'SQL_WAREHOUSE', 'Reporting Team', 'PRODUCTION'),
        ('model-001', 'churn_model_endpoint', 'MODEL_SERVING', 'Machine Learning Team', 'PRODUCTION')
) AS r(resource_id, resource_name, resource_type, owner, environment)
WHERE o.name = 'Demo Organization'
  AND c.connection_name = 'Production Databricks'
  AND w.workspace_name = 'Analytics Workspace';

-- Development Workspace
INSERT INTO databricks_resources (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    resource_name,
    resource_type,
    owner,
    environment,
    status
)
SELECT
    o.id,
    c.id,
    w.id,
    'cluster-dev-001',
    'dev_cluster',
    'CLUSTER',
    'Data Engineering',
    'DEVELOPMENT',
    'ACTIVE'
FROM organizations o
JOIN databricks_connections c
    ON c.organization_id = o.id
JOIN databricks_workspaces w
    ON w.connection_id = c.id
WHERE o.name = 'Demo Organization'
  AND c.connection_name = 'Production Databricks'
  AND w.workspace_name = 'Development Workspace';

-- =========================================================
-- 6. RESOURCE TAGS
-- =========================================================
INSERT INTO resource_tags (
    organization_id,
    resource_id,
    tag_key,
    tag_value
)
SELECT
    organization_id,
    id,
    'owner',
    owner
FROM databricks_resources
WHERE organization_id = (
    SELECT id
    FROM organizations
    WHERE name = 'Demo Organization'
);

INSERT INTO resource_tags (
    organization_id,
    resource_id,
    tag_key,
    tag_value
)
SELECT
    organization_id,
    id,
    'environment',
    environment
FROM databricks_resources
WHERE organization_id = (
    SELECT id
    FROM organizations
    WHERE name = 'Demo Organization'
);

INSERT INTO resource_tags (
    organization_id,
    resource_id,
    tag_key,
    tag_value
)
SELECT
    organization_id,
    id,
    'cost_center',
    CASE
        WHEN resource_name IN ('customer_etl_job', 'customer360_pipeline')
            THEN 'CC-DATA-001'
        WHEN resource_name IN ('bi_warehouse', 'reporting_warehouse')
            THEN 'CC-BI-001'
        WHEN resource_name IN ('ml_training', 'churn_model_endpoint')
            THEN 'CC-ML-001'
        WHEN resource_name = 'daily_finance_job'
            THEN 'CC-FIN-001'
        ELSE 'CC-DEV-001'
    END
FROM databricks_resources
WHERE organization_id = (
    SELECT id
    FROM organizations
    WHERE name = 'Demo Organization'
);

-- =========================================================
-- 7. CURRENT MONTH COST DATA
-- Target total: approximately $45,280
-- =========================================================
WITH resource_weights AS (
    SELECT *
    FROM (
        VALUES
            ('customer_etl_job',      'Jobs Compute',        0.19::NUMERIC, 0.55::NUMERIC),
            ('analytics_cluster',      'All-Purpose Compute', 0.16::NUMERIC, 0.65::NUMERIC),
            ('bi_warehouse',           'SQL Warehouses',      0.14::NUMERIC, 0.45::NUMERIC),
            ('ml_training',            'Jobs Compute',        0.11::NUMERIC, 0.55::NUMERIC),
            ('daily_finance_job',      'Jobs Compute',        0.10::NUMERIC, 0.55::NUMERIC),
            ('customer360_pipeline',   'Serverless',          0.09::NUMERIC, 0.70::NUMERIC),
            ('reporting_warehouse',    'SQL Warehouses',      0.08::NUMERIC, 0.45::NUMERIC),
            ('dev_cluster',            'All-Purpose Compute', 0.06::NUMERIC, 0.65::NUMERIC),
            ('churn_model_endpoint',   'Model Serving',       0.07::NUMERIC, 0.80::NUMERIC)
    ) AS t(resource_name, product_name, weight, list_price)
),
dates AS (
    SELECT generate_series(
        date_trunc('month', CURRENT_DATE)::date,
        CURRENT_DATE,
        INTERVAL '1 day'
    )::date AS usage_date
),
date_count AS (
    SELECT COUNT(*)::NUMERIC AS day_count
    FROM dates
)
INSERT INTO cost_usage (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    usage_date,
    product_name,
    sku_name,
    usage_quantity,
    usage_unit,
    list_price,
    cost,
    currency
)
SELECT
    r.organization_id,
    r.connection_id,
    r.workspace_id,
    r.id,
    d.usage_date,
    rw.product_name,
    CASE rw.product_name
        WHEN 'Jobs Compute' THEN 'STANDARD_JOBS_COMPUTE'
        WHEN 'All-Purpose Compute' THEN 'STANDARD_ALL_PURPOSE_COMPUTE'
        WHEN 'SQL Warehouses' THEN 'STANDARD_SQL_COMPUTE'
        WHEN 'Serverless' THEN 'SERVERLESS_COMPUTE'
        WHEN 'Model Serving' THEN 'MODEL_SERVING'
        ELSE 'OTHER'
    END,
    ROUND(((45280::NUMERIC * rw.weight / dc.day_count) / rw.list_price), 6),
    'DBU',
    rw.list_price,
    ROUND((45280::NUMERIC * rw.weight / dc.day_count), 6),
    'USD'
FROM resource_weights rw
JOIN databricks_resources r
    ON r.resource_name = rw.resource_name
CROSS JOIN dates d
CROSS JOIN date_count dc
WHERE r.organization_id = (
    SELECT id
    FROM organizations
    WHERE name = 'Demo Organization'
);

-- =========================================================
-- 8. PREVIOUS MONTH COST DATA
-- Target total: approximately $41,120
-- =========================================================
WITH resource_weights AS (
    SELECT *
    FROM (
        VALUES
            ('customer_etl_job',      'Jobs Compute',        0.19::NUMERIC, 0.55::NUMERIC),
            ('analytics_cluster',      'All-Purpose Compute', 0.16::NUMERIC, 0.65::NUMERIC),
            ('bi_warehouse',           'SQL Warehouses',      0.14::NUMERIC, 0.45::NUMERIC),
            ('ml_training',            'Jobs Compute',        0.11::NUMERIC, 0.55::NUMERIC),
            ('daily_finance_job',      'Jobs Compute',        0.10::NUMERIC, 0.55::NUMERIC),
            ('customer360_pipeline',   'Serverless',          0.09::NUMERIC, 0.70::NUMERIC),
            ('reporting_warehouse',    'SQL Warehouses',      0.08::NUMERIC, 0.45::NUMERIC),
            ('dev_cluster',            'All-Purpose Compute', 0.06::NUMERIC, 0.65::NUMERIC),
            ('churn_model_endpoint',   'Model Serving',       0.07::NUMERIC, 0.80::NUMERIC)
    ) AS t(resource_name, product_name, weight, list_price)
),
dates AS (
    SELECT generate_series(
        (date_trunc('month', CURRENT_DATE) - INTERVAL '1 month')::date,
        (date_trunc('month', CURRENT_DATE) - INTERVAL '1 day')::date,
        INTERVAL '1 day'
    )::date AS usage_date
),
date_count AS (
    SELECT COUNT(*)::NUMERIC AS day_count
    FROM dates
)
INSERT INTO cost_usage (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    usage_date,
    product_name,
    sku_name,
    usage_quantity,
    usage_unit,
    list_price,
    cost,
    currency
)
SELECT
    r.organization_id,
    r.connection_id,
    r.workspace_id,
    r.id,
    d.usage_date,
    rw.product_name,
    CASE rw.product_name
        WHEN 'Jobs Compute' THEN 'STANDARD_JOBS_COMPUTE'
        WHEN 'All-Purpose Compute' THEN 'STANDARD_ALL_PURPOSE_COMPUTE'
        WHEN 'SQL Warehouses' THEN 'STANDARD_SQL_COMPUTE'
        WHEN 'Serverless' THEN 'SERVERLESS_COMPUTE'
        WHEN 'Model Serving' THEN 'MODEL_SERVING'
        ELSE 'OTHER'
    END,
    ROUND(((41120::NUMERIC * rw.weight / dc.day_count) / rw.list_price), 6),
    'DBU',
    rw.list_price,
    ROUND((41120::NUMERIC * rw.weight / dc.day_count), 6),
    'USD'
FROM resource_weights rw
JOIN databricks_resources r
    ON r.resource_name = rw.resource_name
CROSS JOIN dates d
CROSS JOIN date_count dc
WHERE r.organization_id = (
    SELECT id
    FROM organizations
    WHERE name = 'Demo Organization'
);

-- =========================================================
-- 9. OPTIMIZATION OPPORTUNITIES
-- Total potential saving: $8,450
-- =========================================================
INSERT INTO optimization_opportunities (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    issue_type,
    issue,
    current_monthly_cost,
    potential_saving,
    recommendation,
    risk,
    status
)
SELECT
    organization_id,
    connection_id,
    workspace_id,
    id,
    'RIGHTSIZING',
    'Low utilization / oversized cluster',
    7244.80,
    1900,
    'Reduce cluster size based on historical utilization.',
    'LOW',
    'OPEN'
FROM databricks_resources
WHERE resource_name = 'analytics_cluster';

INSERT INTO optimization_opportunities (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    issue_type,
    issue,
    current_monthly_cost,
    potential_saving,
    recommendation,
    risk,
    status
)
SELECT
    organization_id,
    connection_id,
    workspace_id,
    id,
    'IDLE_RESOURCE',
    'SQL Warehouse is idle for long periods',
    6339.20,
    1250,
    'Reduce SQL Warehouse auto-stop time.',
    'LOW',
    'OPEN'
FROM databricks_resources
WHERE resource_name = 'bi_warehouse';

INSERT INTO optimization_opportunities (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    issue_type,
    issue,
    current_monthly_cost,
    potential_saving,
    recommendation,
    risk,
    status
)
SELECT
    organization_id,
    connection_id,
    workspace_id,
    id,
    'LONG_RUNNING_JOB',
    'Job cluster runtime is higher than expected',
    8603.20,
    1100,
    'Review job cluster configuration and execution time.',
    'MEDIUM',
    'OPEN'
FROM databricks_resources
WHERE resource_name = 'customer_etl_job';

INSERT INTO optimization_opportunities (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    issue_type,
    issue,
    current_monthly_cost,
    potential_saving,
    recommendation,
    risk,
    status
)
SELECT
    organization_id,
    connection_id,
    workspace_id,
    id,
    'IDLE_RESOURCE',
    'Development cluster is running outside business hours',
    2716.80,
    1700,
    'Automatically terminate the development cluster when unused.',
    'LOW',
    'OPEN'
FROM databricks_resources
WHERE resource_name = 'dev_cluster';

INSERT INTO optimization_opportunities (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    issue_type,
    issue,
    current_monthly_cost,
    potential_saving,
    recommendation,
    risk,
    status
)
SELECT
    organization_id,
    connection_id,
    workspace_id,
    id,
    'RIGHTSIZING',
    'ML training compute appears oversized',
    4980.80,
    1500,
    'Evaluate smaller worker types for model training.',
    'MEDIUM',
    'OPEN'
FROM databricks_resources
WHERE resource_name = 'ml_training';

INSERT INTO optimization_opportunities (
    organization_id,
    connection_id,
    workspace_id,
    resource_id,
    issue_type,
    issue,
    current_monthly_cost,
    potential_saving,
    recommendation,
    risk,
    status
)
SELECT
    organization_id,
    connection_id,
    workspace_id,
    id,
    'SCHEDULE_OPTIMIZATION',
    'Reporting warehouse runs longer than required',
    3622.40,
    1000,
    'Review warehouse schedule and reduce unnecessary runtime.',
    'LOW',
    'OPEN'
FROM databricks_resources
WHERE resource_name = 'reporting_warehouse';

-- =========================================================
-- 10. SYNC RUN
-- =========================================================
INSERT INTO sync_runs (
    connection_id,
    sync_type,
    started_at,
    completed_at,
    status,
    records_processed,
    error_message
)
SELECT
    id,
    'FULL_SYNC',
    CURRENT_TIMESTAMP - INTERVAL '2 minutes',
    CURRENT_TIMESTAMP,
    'SUCCESS',
    (
        SELECT COUNT(*)
        FROM cost_usage
        WHERE organization_id = (
            SELECT id
            FROM organizations
            WHERE name = 'Demo Organization'
        )
    ),
    NULL
FROM databricks_connections
WHERE connection_name = 'Production Databricks';

COMMIT;

-- =========================================================
-- OPTIONAL VERIFICATION
-- =========================================================

-- Current month spend
-- SELECT ROUND(SUM(cost), 2) AS current_month_spend
-- FROM cost_usage
-- WHERE usage_date >= date_trunc('month', CURRENT_DATE);

-- Previous month spend
-- SELECT ROUND(SUM(cost), 2) AS previous_month_spend
-- FROM cost_usage
-- WHERE usage_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
--   AND usage_date < date_trunc('month', CURRENT_DATE);

-- Potential savings
-- SELECT ROUND(SUM(potential_saving), 2) AS potential_saving
-- FROM optimization_opportunities
-- WHERE status = 'OPEN';
