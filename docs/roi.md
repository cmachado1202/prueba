# ROI basado en telemetría

## Enfoque

El proyecto no fija un ROI a partir de números inventados dentro del código. La versión final instrumenta las métricas necesarias para calcularlo con datos reales.

## Métricas automáticas

Desde `uif_agent_logs` se obtienen:

- cantidad de ejecuciones;
- latencia por agente;
- tasa de Success / Fail / Skipped;
- input_tokens;
- output_tokens;
- estimated_cost_usd;
- decisión final asociada al `transaction_id`.

También se puede calcular la tasa de revisión humana y la estabilidad operativa.

## Métrica manual de referencia

Para comparar con el proceso anterior se debe medir una muestra real de procesamiento manual y obtener:

`T_manual = mediana de minutos requeridos por formulario sin automatización`

No se recomienda usar una percepción o una estimación informal.

## Indicadores

### Tiempo automático promedio

`T_auto = promedio(latency_ms por ejecución) / 60000`

### Tasa de revisión humana

`review_rate = casos HUMAN_REVIEW / total de casos`

### Tiempo humano residual

`T_human_residual = review_rate × T_review`

### Tiempo ahorrado

`minutes_saved = T_manual - (T_auto + T_human_residual)`

### Ahorro económico

`saving = (minutes_saved / 60) × costo_hora × cantidad_documentos`

### Coste IA

`ai_cost = SUM(estimated_cost_usd)`

### ROI

`ROI = (saving - ai_cost - otros_costos_operativos) / (ai_cost + otros_costos_operativos)`

## Consultas SQL

### Latencia y costo por ejecución

```sql
SELECT
  transaction_id,
  SUM(latency_ms) AS total_latency_ms,
  SUM(input_tokens) AS input_tokens,
  SUM(output_tokens) AS output_tokens,
  SUM(estimated_cost_usd) AS estimated_cost_usd,
  MAX(CASE WHEN agent_name = 'Orchestrator' THEN decision END) AS final_decision
FROM uif_agent_logs
GROUP BY transaction_id;
```

### Tasa de fallos por agente

```sql
SELECT
  agent_name,
  COUNT(*) AS events,
  SUM(status = 'Fail') AS failures,
  ROUND(100 * SUM(status = 'Fail') / COUNT(*), 2) AS failure_rate_pct
FROM uif_agent_logs
GROUP BY agent_name;
```

### Latencia media

```sql
SELECT
  agent_name,
  ROUND(AVG(latency_ms), 0) AS avg_latency_ms,
  MAX(latency_ms) AS max_latency_ms
FROM uif_agent_logs
WHERE status = 'Success'
GROUP BY agent_name;
```

## Umbral para una evaluación confiable

Para el informe final de ROI operativo conviene utilizar una ventana mínima de ejecuciones representativa del proceso y reportar:

- mediana, no solo promedio;
- tasa de revisión;
- tasa de error;
- coste total;
- documentos procesados;
- ahorro de tiempo.

## Ejemplo ilustrativo

Cualquier ejemplo numérico utilizado en una presentación debe identificarse como **simulación** hasta contar con una muestra productiva. El repositorio no presenta una simulación como si fuera telemetría real.

## Resultado esperado

La automatización aporta valor si reduce el tiempo manual sin aumentar de forma descontrolada la revisión humana, los fallos o el coste por documento. La telemetría permite demostrarlo con evidencia.
