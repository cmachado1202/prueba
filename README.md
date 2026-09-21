# UIF · Automatización inteligente Production-Ready

**Proyecto Final Coderhouse · Automatización + Document AI + Orquestación de Agentes de IA**

## Qué resuelve

Este proyecto automatiza el **relevamiento, extracción y control inicial de Formularios UIF provenientes de GST @CashFlow**.

El flujo recibe un PDF o imagen, valida el documento, genera trazabilidad con SHA-256, extrae información estructurada, aplica controles determinísticos y utiliza dos agentes especializados para revisar la calidad de los datos y decidir el enrutamiento técnico.

> **Límite funcional:** la IA no determina si una operación es sospechosa, no decide cumplimiento normativo y no reemplaza a Cumplimiento. Ante faltantes, inconsistencias, baja confianza o fallos de IA, el caso se deriva a revisión humana.

## Entrega final

La guía principal para evaluar el proyecto está en:

- [ENTREGA.md](ENTREGA.md)
- [docs/entrega-final-coderhouse.md](docs/entrega-final-coderhouse.md)

Workflow final:

- [workflow/uif_production_ready.json](workflow/uif_production_ready.json)

El workflow anterior del Módulo 2 se conserva únicamente como evolución histórica:

- [workflow/uif_document_ai.json](workflow/uif_document_ai.json)

## Arquitectura

```text
GST @CashFlow
   ↓
Webhook autenticado
   ↓
Validación de archivo + SHA-256
   ↓
Document AI / NVIDIA
   ↓
Normalización determinística
   ↓
Sanitización de PII
   ↓
Agente A · Analista de Integridad
   ↓
Gate de seguridad
   ├── falla / contrato inválido / baja confianza → HUMAN_REVIEW
   ↓
Agente B · Revisor / Enrutador
   ↓
Control determinístico final
   ├── AUTO_CONTINUE
   └── HUMAN_REVIEW
   ↓
Observabilidad MySQL + alertas operativas
```

Diagrama y explicación: [docs/architecture.md](docs/architecture.md).

## Agentes y patrón de orquestación

### Agente A · Analista de Integridad

Evalúa completitud e inconsistencias sobre un payload previamente sanitizado. Devuelve un contrato estructurado con estado, `quality_score`, issues y resumen de handoff.

Prompt versionado: [prompts/agent_analyst.md](prompts/agent_analyst.md).

### Agente B · Revisor y Enrutador

Recibe los datos sanitizados y la salida del Agente A. Solo puede resolver el **enrutamiento técnico**:

- `AUTO_CONTINUE`
- `HUMAN_REVIEW`

Prompt versionado: [prompts/agent_reviewer.md](prompts/agent_reviewer.md).

### Patrón

Se utiliza **Handoff controlado**. Hay como máximo dos llamadas de agentes. Si el Agente A falla o no supera el gate, el Agente B no se invoca.

## Robustez

El diseño incluye:

- autenticación del webhook;
- validación de tipo/firma del archivo;
- SHA-256 para trazabilidad;
- timeouts y reintentos acotados;
- contratos JSON estructurados;
- gate de confianza;
- circuit breaker por coste/estado;
- fallback seguro a `HUMAN_REVIEW`;
- alertas operativas;
- precedencia de reglas determinísticas sobre decisiones de agentes.

Runbook: [docs/runbook.md](docs/runbook.md).

## Seguridad y protección de datos

Los secretos no se almacenan en Git. El workflow final referencia credenciales de n8n.

Antes de invocar la capa de agentes se eliminan datos personales como nombre, documento, CUIT/CUIL, domicilio, reportante, ticket, máquina, importe exacto y texto documental.

Documentación: [docs/security.md](docs/security.md).

Plantilla de variables: [.env.example](.env.example).

## Observabilidad

Cada ejecución genera un `transaction_id` UUID y registra telemetría persistente.

La tabla `uif_agent_logs` almacena:

- timestamp;
- transaction_id;
- agent_name;
- input_tokens;
- output_tokens;
- estimated_cost_usd;
- latency_ms;
- status;
- decisión/error;
- metadata estructurada sin PII.

Las alertas se persisten en `uif_agent_alerts`. El output estructurado final se persiste además en `uif_processed_results`, que funciona como destino operativo SQL del flujo.

DDL: [sql/observability.sql](sql/observability.sql).

## ROI basado en telemetría

El ROI no se calcula a partir de valores inventados dentro del workflow. Se obtiene con métricas reales de operación: latencia, tasa de revisión humana, éxito/fallo, tokens y coste por ejecución, combinadas con una medición del tiempo manual de referencia.

Metodología, fórmulas y consultas SQL: [docs/roi.md](docs/roi.md).

## Documentación de usuario

Guía de estados, interpretación de resultados y acciones operativas:

[docs/user-guide.md](docs/user-guide.md).

## Despliegue estable

La versión final está preparada para importarse en n8n y operar de forma permanente con credenciales administradas fuera de Git, tablas de observabilidad, logs y fallback humano.

Procedimiento de despliegue, rollback y verificación: [docs/deployment.md](docs/deployment.md).

## Pruebas y QA

Matriz de escenarios de validación:

[docs/qa-final.md](docs/qa-final.md).

Ejemplos sintéticos sin datos reales:

- [examples/request_url.json](examples/request_url.json)
- [examples/expected_auto_continue.json](examples/expected_auto_continue.json)
- [examples/expected_human_review.json](examples/expected_human_review.json)

## Evidencias

Se conservan capturas reales del checkpoint operativo anterior en `assets/`.

No se fabrican capturas de producción ni se publican formularios reales. Para la versión multiagente, el repositorio aporta el workflow exportable, contratos, prompts, SQL de telemetría, runbook, escenarios de QA y documentación de despliegue. La guía para capturas reales de una instancia n8n está en [docs/evidence-checklist.md](docs/evidence-checklist.md).

## Estructura

```text
.
├── .env.example
├── ENTREGA.md
├── README.md
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   ├── entrega-final-coderhouse.md
│   ├── evidence-checklist.md
│   ├── pre-entrega-coderhouse.md
│   ├── qa-final.md
│   ├── roi.md
│   ├── runbook.md
│   ├── security.md
│   └── user-guide.md
├── examples/
│   ├── expected_auto_continue.json
│   ├── expected_human_review.json
│   └── request_url.json
├── prompts/
│   ├── agent_analyst.md
│   └── agent_reviewer.md
├── schema/
│   ├── uif_agent_log.schema.json
│   └── uif_formulario.schema.json
├── sql/
│   └── observability.sql
└── workflow/
    ├── uif_document_ai.json
    └── uif_production_ready.json
```

## Cobertura de evaluación

| Criterio | Implementación |
|---|---|
| Complejidad de orquestación | 2 agentes especializados + Handoff + gate determinístico |
| Robustez ante APIs externas | timeout, retry, contratos JSON, error capturado y fallback humano |
| Seguridad | credenciales n8n, webhook autenticado, sanitización PII y secretos fuera de Git |
| Trazabilidad | UUID por ejecución + logs persistentes + tokens + coste + latencia + status |
| Documentación | README, arquitectura, guía de usuario, runbook, despliegue, QA y ROI |
| Operación estable | workflow exportado, persistencia SQL del resultado, observabilidad, alertas, rollback y checklist de despliegue |
