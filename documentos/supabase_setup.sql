-- ============================================================================
-- SETUP COMPLETO DE SUPABASE PARA DASHBOARD KOMMO + META ADS
-- ============================================================================
-- Ejecutar este script en el SQL Editor de Supabase
-- ============================================================================

-- 1. TABLA: LEADS (Datos principales de leads de Kommo)
CREATE TABLE IF NOT EXISTS leads (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    pipeline_id BIGINT,
    pipeline_name TEXT,
    status_id BIGINT,
    status_name TEXT,
    responsible_user_id BIGINT,
    responsible_user_name TEXT,
    price NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT FALSE,
    utm_source TEXT,
    utm_campaign TEXT,
    utm_medium TEXT,
    utm_content TEXT,
    utm_term TEXT,
    desarrollo TEXT,
    modelo TEXT,
    contact_name TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TABLA: EVENTS (Historial completo de eventos)
-- Nota: ID es TEXT porque Kommo v4 usa ULIDs
CREATE TABLE IF NOT EXISTS events (
    id TEXT PRIMARY KEY,
    lead_id BIGINT REFERENCES leads(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_by_id BIGINT,
    created_by_name TEXT,
    value_before JSONB,
    value_after JSONB,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TABLA: CONVERSIONS
CREATE TABLE IF NOT EXISTS conversions (
    id SERIAL PRIMARY KEY,
    lead_id BIGINT REFERENCES leads(id) ON DELETE CASCADE,
    pipeline_id BIGINT,
    pipeline_name TEXT,
    from_status_id BIGINT,
    from_status TEXT,
    to_status_id BIGINT,
    to_status TEXT,
    converted_at TIMESTAMP WITH TIME ZONE,
    time_in_previous_status_hours NUMERIC,
    time_in_previous_status_days NUMERIC,
    created_by_id BIGINT,
    created_by_name TEXT,
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. TABLA: RESPONSE_TIMES
CREATE TABLE IF NOT EXISTS response_times (
    lead_id BIGINT PRIMARY KEY REFERENCES leads(id) ON DELETE CASCADE,
    lead_created_at TIMESTAMP WITH TIME ZONE,
    first_action_at TIMESTAMP WITH TIME ZONE,
    first_action_type TEXT,
    response_time_seconds INTEGER,
    response_time_minutes NUMERIC,
    response_time_hours NUMERIC,
    response_time_days NUMERIC,
    response_quality TEXT,
    responsible_user_id BIGINT,
    responsible_user_name TEXT,
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. TABLA: USERS
CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    role TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. TABLA: PIPELINES
CREATE TABLE IF NOT EXISTS pipelines (
    id BIGINT PRIMARY KEY,
    name TEXT NOT NULL,
    is_main BOOLEAN DEFAULT FALSE,
    sort_order INTEGER,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. TABLA: PIPELINE_STATUSES
CREATE TABLE IF NOT EXISTS pipeline_statuses (
    id BIGINT PRIMARY KEY,
    pipeline_id BIGINT REFERENCES pipelines(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color TEXT,
    sort_order INTEGER,
    last_synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Vistas y Funciones (Ver archivo original para triggers y lógica compleja)
-- ...
