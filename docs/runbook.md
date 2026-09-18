# Runbook operativo · UIF Multiagente

## Objetivo

Restablecer el servicio sin permitir que un fallo de IA derive en una decisión automática insegura. El fallback por defecto es **HUMAN_REVIEW**.

## Matriz de incidentes

| Evento | Comportamiento automático | Acción operativa |
|---|---|---|
| Documento inválido/corrupto | Respuesta 400 | Revisar origen del archivo y reintentar con original válido |
| Document AI falla | Respuesta controlada 502 | Revisar proveedor/credencial; no continuar con datos incompletos |
| Agente A falla o rompe contrato JSON | Corta handoff; HUMAN_REVIEW | Buscar `transaction_id`, revisar ejecución y credencial NVIDIA |
| Agente A baja confianza | No ejecuta Agente B; HUMAN_REVIEW | Revisar extracción y campos críticos |
| Agente B falla | HUMAN_REVIEW | Revisar ejecución; no forzar AUTO_CONTINUE |
| Latencia supera umbral | Genera alerta | Revisar latencia del proveedor y salud de n8n |
| Coste supera presupuesto | Circuit breaker + HUMAN_REVIEW | Revisar tokens, prompt y tarifas configuradas |
| MySQL de observabilidad falla | El nodo no bloquea el caso | Revisar credencial/conectividad; usar historial de ejecución como respaldo |
| Webhook devuelve 401/403 | Entrada bloqueada | Validar Header Auth del sistema origen |

## Alertas operativas

Toda alerta se persiste primero en `uif_agent_alerts` con estado `OPEN`. Si existe un webhook externo configurado, además se envía al canal operativo. Si no existe, el flujo no falla: Operaciones puede consultar la tabla de alertas pendientes.

Consulta rápida:

```sql
SELECT * FROM uif_agent_alerts WHERE status = 'OPEN' ORDER BY timestamp DESC;
```

## Investigación por transaction_id

1. Buscar el `transaction_id` en `uif_agent_logs`.
2. Revisar qué agentes participaron y su `status`.
3. Comparar `latency_ms`, tokens y costo.
4. Abrir la ejecución correspondiente en n8n.
5. No copiar PII a tickets, chats ni capturas.
6. Corregir la causa y reejecutar con el documento original desde un entorno autorizado.

## Regla de fallback

Ningún error de agente habilita continuidad automática. Todo fallo, contrato inválido o confianza inferior a 0.85 deriva a revisión humana.

## Circuit breaker

El diseño permite como máximo dos llamadas de agentes por ejecución. No existe un bucle reflexivo. El segundo agente solo se ejecuta si el primero supera el gate.

## Recuperación

Una vez corregido el incidente, reintentar desde n8n usando los datos de la ejecución original o reenviar el documento desde el origen autenticado. Confirmar que se creen tres registros de telemetría esperados: Analista, Revisor (si fue invocado) y Orquestador.
