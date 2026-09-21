CREATE TABLE IF NOT EXISTS uif_agent_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  timestamp DATETIME(3) NOT NULL,
  transaction_id CHAR(36) NOT NULL,
  agent_name VARCHAR(64) NOT NULL,
  input_tokens INT UNSIGNED NOT NULL DEFAULT 0,
  output_tokens INT UNSIGNED NOT NULL DEFAULT 0,
  estimated_cost_usd DECIMAL(12,8) NOT NULL DEFAULT 0,
  latency_ms INT UNSIGNED NOT NULL DEFAULT 0,
  status ENUM('Success','Fail','Skipped') NOT NULL,
  decision VARCHAR(64) NULL,
  error_code VARCHAR(64) NULL,
  metadata_json JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_uif_agent_logs_transaction (transaction_id),
  KEY idx_uif_agent_logs_timestamp (timestamp),
  KEY idx_uif_agent_logs_agent_status (agent_name, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Los logs NO deben contener PII ni texto documental original.
-- Recomendación: la credencial usada por el workflow debe tener solo INSERT sobre esta tabla.


CREATE TABLE IF NOT EXISTS uif_agent_alerts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  timestamp DATETIME(3) NOT NULL,
  transaction_id CHAR(36) NOT NULL,
  severity ENUM('MEDIUM','HIGH') NOT NULL,
  status ENUM('OPEN','ACKNOWLEDGED','CLOSED') NOT NULL DEFAULT 'OPEN',
  reason VARCHAR(512) NOT NULL,
  latency_ms INT UNSIGNED NOT NULL DEFAULT 0,
  estimated_cost_usd DECIMAL(12,8) NOT NULL DEFAULT 0,
  payload_json JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_uif_agent_alerts_status_time (status, timestamp),
  KEY idx_uif_agent_alerts_transaction (transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Destino operativo del output estructurado.
-- A diferencia de uif_agent_logs/uif_agent_alerts, esta tabla puede contener PII
-- dentro de resultado_json. Debe tener permisos restringidos y retención acorde a la política interna.
CREATE TABLE IF NOT EXISTS uif_processed_results (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  timestamp DATETIME(3) NOT NULL,
  transaction_id CHAR(36) NOT NULL,
  formulario_id VARCHAR(128) NULL,
  final_status ENUM('AUTO_CONTINUE','HUMAN_REVIEW') NOT NULL,
  requires_human_review TINYINT(1) NOT NULL DEFAULT 0,
  resultado_json JSON NOT NULL,
  orchestration_json JSON NULL,
  sha256 CHAR(64) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_uif_processed_results_transaction (transaction_id),
  KEY idx_uif_processed_results_status_time (final_status, timestamp),
  KEY idx_uif_processed_results_formulario (formulario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
