-- =========================================================
-- VALPERF POC - POSTGRESQL DATABASE SCHEMA
-- Focus: Databricks Cost & Performance Optimization
-- Database: valperf_poc
--
-- Run this script while connected to the valperf_poc database.
-- This script does NOT drop existing tables.
-- =========================================================

-- =========================================================
-- 1. ORGANIZATIONS
-- =========================================================
CREATE TABLE IF NOT EXISTS organizations (
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 2. USERS
-- =========================================================
CREATE TABLE IF NOT EXISTS users (
    id              BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL,
    email           VARCHAR(255) NOT NULL,
    full_name       VARCHAR(255),
    role            VARCHAR(50) NOT NULL DEFAULT 'VIEWER',
    status          VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_users_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT uq_users_email
        UNIQUE (email),

    CONSTRAINT chk_users_role
        CHECK (role IN ('ADMIN', 'FINOPS', 'PLATFORM_ENGINEER', 'VIEWER')),

    CONSTRAINT chk_users_status
        CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- =========================================================
-- 3. DATABRICKS CONNECTIONS
-- Do NOT store client secrets/passwords in this table.
-- =========================================================
CREATE TABLE IF NOT EXISTS databricks_connections (
    id                  BIGSERIAL PRIMARY KEY,
    organization_id     BIGINT NOT NULL,
    connection_name     VARCHAR(255) NOT NULL,
    cloud_provider      VARCHAR(50) NOT NULL,
    workspace_url       TEXT,
    account_id          VARCHAR(255),
    authentication_type VARCHAR(50) DEFAULT 'OAUTH_M2M',
    status              VARCHAR(50) NOT NULL DEFAULT 'DISCONNECTED',
    last_sync_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_dbx_connection_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT chk_dbx_cloud_provider
        CHECK (cloud_provider IN ('AZURE', 'AWS', 'GCP')),

    CONSTRAINT chk_dbx_connection_status
        CHECK (status IN ('CONNECTED', 'DISCONNECTED', 'ERROR'))
);

-- =========================================================
-- 4. DATABRICKS WORKSPACES
-- =========================================================
CREATE TABLE IF NOT EXISTS databricks_workspaces (
    id              BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL,
    connection_id   BIGINT NOT NULL,
    workspace_id    VARCHAR(255),
    workspace_name  VARCHAR(255) NOT NULL,
    workspace_url   TEXT,
    cloud_provider  VARCHAR(50),
    region          VARCHAR(100),
    status          VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_workspace_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_workspace_connection
        FOREIGN KEY (connection_id)
        REFERENCES databricks_connections(id),

    CONSTRAINT chk_workspace_cloud_provider
        CHECK (cloud_provider IS NULL OR cloud_provider IN ('AZURE', 'AWS', 'GCP')),

    CONSTRAINT chk_workspace_status
        CHECK (status IN ('ACTIVE', 'INACTIVE')),

    CONSTRAINT uq_connection_workspace
        UNIQUE (connection_id, workspace_name)
);

-- =========================================================
-- 5. DATABRICKS RESOURCES
-- =========================================================
CREATE TABLE IF NOT EXISTS databricks_resources (
    id              BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL,
    connection_id   BIGINT NOT NULL,
    workspace_id    BIGINT NOT NULL,
    resource_id     VARCHAR(255),
    resource_name   VARCHAR(500) NOT NULL,
    resource_type   VARCHAR(100) NOT NULL,
    owner           VARCHAR(255),
    environment     VARCHAR(100),
    status          VARCHAR(50) DEFAULT 'ACTIVE',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_resource_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_resource_connection
        FOREIGN KEY (connection_id)
        REFERENCES databricks_connections(id),

    CONSTRAINT fk_resource_workspace
        FOREIGN KEY (workspace_id)
        REFERENCES databricks_workspaces(id),

    CONSTRAINT chk_resource_type
        CHECK (resource_type IN (
            'JOB',
            'CLUSTER',
            'SQL_WAREHOUSE',
            'PIPELINE',
            'MODEL_SERVING',
            'OTHER'
        )),

    CONSTRAINT chk_resource_status
        CHECK (status IN ('ACTIVE', 'INACTIVE', 'TERMINATED', 'UNKNOWN'))
);

-- =========================================================
-- 6. COST USAGE
-- Main Databricks usage/cost fact table.
-- =========================================================
CREATE TABLE IF NOT EXISTS cost_usage (
    id              BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL,
    connection_id   BIGINT NOT NULL,
    workspace_id    BIGINT,
    resource_id     BIGINT,
    usage_date      DATE NOT NULL,
    product_name    VARCHAR(255) NOT NULL,
    sku_name        VARCHAR(255),
    usage_quantity  NUMERIC(20,6),
    usage_unit      VARCHAR(100),
    list_price      NUMERIC(20,6),
    cost            NUMERIC(20,6) NOT NULL DEFAULT 0,
    currency        VARCHAR(10) NOT NULL DEFAULT 'USD',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_cost_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_cost_connection
        FOREIGN KEY (connection_id)
        REFERENCES databricks_connections(id),

    CONSTRAINT fk_cost_workspace
        FOREIGN KEY (workspace_id)
        REFERENCES databricks_workspaces(id),

    CONSTRAINT fk_cost_resource
        FOREIGN KEY (resource_id)
        REFERENCES databricks_resources(id),

    CONSTRAINT chk_cost_non_negative
        CHECK (cost >= 0),

    CONSTRAINT chk_usage_quantity_non_negative
        CHECK (usage_quantity IS NULL OR usage_quantity >= 0)
);

-- =========================================================
-- 7. RESOURCE TAGS
-- =========================================================
CREATE TABLE IF NOT EXISTS resource_tags (
    id              BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL,
    resource_id     BIGINT NOT NULL,
    tag_key         VARCHAR(255) NOT NULL,
    tag_value       VARCHAR(500),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_tag_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_tag_resource
        FOREIGN KEY (resource_id)
        REFERENCES databricks_resources(id),

    CONSTRAINT uq_resource_tag
        UNIQUE (resource_id, tag_key)
);

-- =========================================================
-- 8. OPTIMIZATION OPPORTUNITIES
-- =========================================================
CREATE TABLE IF NOT EXISTS optimization_opportunities (
    id                   BIGSERIAL PRIMARY KEY,
    organization_id      BIGINT NOT NULL,
    connection_id        BIGINT NOT NULL,
    workspace_id         BIGINT,
    resource_id          BIGINT,
    issue_type           VARCHAR(100),
    issue                TEXT NOT NULL,
    current_monthly_cost NUMERIC(20,6),
    potential_saving     NUMERIC(20,6),
    recommendation       TEXT,
    risk                 VARCHAR(50) NOT NULL DEFAULT 'LOW',
    status               VARCHAR(50) NOT NULL DEFAULT 'OPEN',
    detected_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_optimization_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id),

    CONSTRAINT fk_optimization_connection
        FOREIGN KEY (connection_id)
        REFERENCES databricks_connections(id),

    CONSTRAINT fk_optimization_workspace
        FOREIGN KEY (workspace_id)
        REFERENCES databricks_workspaces(id),

    CONSTRAINT fk_optimization_resource
        FOREIGN KEY (resource_id)
        REFERENCES databricks_resources(id),

    CONSTRAINT chk_optimization_risk
        CHECK (risk IN ('LOW', 'MEDIUM', 'HIGH')),

    CONSTRAINT chk_optimization_status
        CHECK (status IN ('OPEN', 'ACCEPTED', 'IMPLEMENTED', 'DISMISSED')),

    CONSTRAINT chk_potential_saving
        CHECK (potential_saving IS NULL OR potential_saving >= 0)
);

-- =========================================================
-- 9. SYNC RUNS
-- =========================================================
CREATE TABLE IF NOT EXISTS sync_runs (
    id                BIGSERIAL PRIMARY KEY,
    connection_id     BIGINT NOT NULL,
    sync_type         VARCHAR(100) NOT NULL,
    started_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at      TIMESTAMPTZ,
    status            VARCHAR(50) NOT NULL DEFAULT 'RUNNING',
    records_processed INTEGER NOT NULL DEFAULT 0,
    error_message     TEXT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_sync_connection
        FOREIGN KEY (connection_id)
        REFERENCES databricks_connections(id),

    CONSTRAINT chk_sync_status
        CHECK (status IN ('RUNNING', 'SUCCESS', 'FAILED')),

    CONSTRAINT chk_records_processed
        CHECK (records_processed >= 0)
);

-- =========================================================
-- INDEXES
-- =========================================================
CREATE INDEX IF NOT EXISTS idx_users_organization
    ON users (organization_id);

CREATE INDEX IF NOT EXISTS idx_dbx_connections_organization
    ON databricks_connections (organization_id);

CREATE INDEX IF NOT EXISTS idx_workspaces_connection
    ON databricks_workspaces (connection_id);

CREATE INDEX IF NOT EXISTS idx_resources_workspace
    ON databricks_resources (workspace_id);

CREATE INDEX IF NOT EXISTS idx_resources_type
    ON databricks_resources (resource_type);

CREATE INDEX IF NOT EXISTS idx_cost_usage_date
    ON cost_usage (usage_date);

CREATE INDEX IF NOT EXISTS idx_cost_workspace_date
    ON cost_usage (workspace_id, usage_date);

CREATE INDEX IF NOT EXISTS idx_cost_resource_date
    ON cost_usage (resource_id, usage_date);

CREATE INDEX IF NOT EXISTS idx_cost_product_date
    ON cost_usage (product_name, usage_date);

CREATE INDEX IF NOT EXISTS idx_tags_resource
    ON resource_tags (resource_id);

CREATE INDEX IF NOT EXISTS idx_optimization_status
    ON optimization_opportunities (status);

CREATE INDEX IF NOT EXISTS idx_optimization_resource
    ON optimization_opportunities (resource_id);

CREATE INDEX IF NOT EXISTS idx_sync_connection_started
    ON sync_runs (connection_id, started_at DESC);

-- =========================================================
-- OPTIONAL VERIFICATION
-- =========================================================
-- SELECT table_name
-- FROM information_schema.tables
-- WHERE table_schema = 'public'
-- ORDER BY table_name;
