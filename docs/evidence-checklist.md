# Evidencias para la entrega

Estas capturas deben provenir de una ejecución real. No fabricar evidencias ni mostrar PII o secretos.

## Capturas requeridas

1. `assets/04_flujo_multiagente.png`
   - Debe verse Document AI → Sanitización → Agente A → Handoff → Agente B → Control → Logs/Fallback.

2. `assets/05_ejecucion_auto_continue.png`
   - Ejecución exitosa.
   - Mostrar `transaction_id`, estados de ambos agentes y decisión `AUTO_CONTINUE`.
   - Ocultar PII y credenciales.

3. `assets/06_ejecucion_human_review.png`
   - Caso con un campo crítico faltante o baja confianza.
   - Mostrar que el sistema deriva a `HUMAN_REVIEW`.

4. `assets/07_observabilidad_mysql.png`
   - Consulta de `uif_agent_logs` filtrada por un `transaction_id`.
   - Deben verse agent_name, tokens, estimated_cost_usd, latency_ms y status.

## Query sugerida

```sql
SELECT
  timestamp,
  transaction_id,
  agent_name,
  input_tokens,
  output_tokens,
  estimated_cost_usd,
  latency_ms,
  status,
  decision
FROM uif_agent_logs
WHERE transaction_id = 'PEGAR_UUID_DE_PRUEBA'
ORDER BY id;
```

## Validación final

- No hay claves visibles.
- No hay nombre, DNI, CUIT/CUIL, domicilio ni reportante visibles.
- El `transaction_id` es el mismo en workflow y logs.
- Si el Agente A falla, el Agente B no se ejecuta.
- Ningún agente emite una decisión de cumplimiento.
