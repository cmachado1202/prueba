# QA final · Matriz de escenarios

| Escenario | Entrada | Resultado esperado |
|---|---|---|
| Documento válido | PDF/imagen válida con campos críticos | Procesamiento completo y decisión técnica según validación |
| Campo crítico faltante | Documento sin uno de los campos requeridos | `HUMAN_REVIEW` |
| Archivo corrupto | Binario inválido | HTTP 400 / `DOCUMENTO_INVALIDO` |
| Falla Document AI | Error/timeout del proveedor | Respuesta controlada; no continuar con datos incompletos |
| Agente A falla | API/JSON inválido | Agente B no se ejecuta; `HUMAN_REVIEW` |
| Agente A baja confianza | confidence < umbral | Se corta handoff; `HUMAN_REVIEW` |
| Agente B falla | API/JSON inválido | `HUMAN_REVIEW` |
| Coste supera presupuesto | costo acumulado > umbral | alerta + fallback |
| Latencia elevada | latency > umbral | alerta operativa |
| Canal alerta ausente | URL no configurada | no falla el flujo; alerta persiste en MySQL |
| Log MySQL falla | error de persistencia | el caso no se transforma en aprobación automática |
| Auth inválida | header incorrecto/ausente | solicitud rechazada |
| PII | datos completos en documento | agentes reciben payload sanitizado |

## Criterios de aceptación

- ningún error de agente produce `AUTO_CONTINUE`;
- `transaction_id` se mantiene durante toda la ejecución;
- no se registran secretos;
- no se registra texto documental en observabilidad;
- la capa de agentes no recibe PII;
- las reglas determinísticas tienen precedencia;
- los prompts no habilitan decisiones regulatorias.

## Evidencia

Las capturas de ejecución deben generarse únicamente sobre una instancia real y anonimizada. Ver `docs/evidence-checklist.md`.
