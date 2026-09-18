# UIF · Automatización inteligente Production-Ready

**Proyecto Coderhouse · Automatización + Document AI + Agentes de IA**

## Problema de negocio

El proyecto automatiza el **relevamiento, extracción y control inicial de Formularios UIF provenientes de GST @CashFlow**.

El sistema recibe documentos, conserva su trazabilidad mediante SHA-256, extrae datos a una estructura uniforme, ejecuta controles determinísticos y utiliza dos agentes especializados para revisar calidad de datos y decidir el enrutamiento operativo.

> **Límite funcional:** la IA no determina si una operación es sospechosa, no decide cumplimiento normativo y no reemplaza a Cumplimiento. Ante duda o baja confianza, el flujo deriva a revisión humana.

## Evolución por módulos

- **Módulo 1:** plan de automatización, arquitectura mínima y esquema de datos.
- **Módulo 2:** ingesta documental + Document AI + normalización + validación.
- **Checkpoint actual:** capa multiagente, observabilidad, gestión de secretos, sanitización PII, circuit breaker, alertas y fallback.

## Workflow principal

`/workflow/uif_production_ready.json`

El workflow anterior del Módulo 2 se conserva en:

`/workflow/uif_document_ai.json`

## Arquitectura de producción

```text
GST @CashFlow
   ↓
Webhook autenticado
   ↓
Validación + SHA-256
   ↓
Document AI / NVIDIA
   ↓
Normalización determinística
   ↓
Data Sanitization
   ↓
Agente A · Analista de Integridad
   ↓
Gate / Circuit Breaker
   ├── falla o baja confianza → HUMAN_REVIEW
   ↓
Agente B · Revisor / Enrutador
   ↓
Control determinístico final
   ├── AUTO_CONTINUE
   └── HUMAN_REVIEW
   ↓
Logs MySQL + alertas operativas
```

Diagrama detallado: `/docs/architecture.md`.

## Agentes

### Agente A · Analista de Integridad

Evalúa completitud e inconsistencias usando solo datos sanitizados. Produce un `quality_score`, issues y un resumen para el handoff.

Prompt documentado en `/prompts/agent_analyst.md`.

### Agente B · Revisor y Enrutador

Recibe el payload sanitizado + la salida del Agente A. Solo puede decidir:

- `AUTO_CONTINUE`
- `HUMAN_REVIEW`

Prompt documentado en `/prompts/agent_reviewer.md`.

### Patrón

Se usa **Handoff controlado**. No existe un loop reflexivo infinito: hay como máximo dos llamadas de agentes. Si el Agente A falla o no supera el gate, el Agente B no se invoca.

## Observabilidad

Cada ejecución genera un UUID `transaction_id` al inicio.

La tabla `uif_agent_logs` registra:

- `timestamp`
- `transaction_id`
- `agent_name`
- `input_tokens`
- `output_tokens`
- `estimated_cost_usd`
- `latency_ms`
- `status`
- decisión/error
- metadata estructurada sin PII

Las alertas quedan en `uif_agent_alerts` con estado `OPEN`, incluso si todavía no se configuró un webhook externo.

DDL: `/sql/observability.sql`.

> El endpoint NVIDIA NIM usado por este prototipo está publicado actualmente como **Free Endpoint**, por lo que el costo directo de API es USD 0. De todos modos, el workflow contabiliza tokens y tiene la fórmula de costo parametrizable para un endpoint/proveedor pago.

## Seguridad

### Credenciales

No hay llaves reales en Git. Crear en n8n:

1. **NVIDIA API** · Bearer Auth.
2. **UIF Webhook Auth** · Header Auth.
3. **UIF Observability MySQL** · MySQL.

El export del workflow referencia estas credenciales por nombre, pero no incluye sus secretos.

### Sanitización

Antes de cualquier agente se quitan nombre, documento, CUIT/CUIL, domicilio, reportante, importe exacto, ticket, máquina y texto documental. Los logs tampoco incluyen PII.

Ver `/docs/security.md`.

## Setup

1. Ejecutar `/sql/observability.sql` en la base UIF.
2. Importar `/workflow/uif_production_ready.json` en n8n.
3. Crear/asignar las tres credenciales indicadas arriba.
4. En `Sanitizar PII + Trace`, configurar:
   - precio de input/output por millón de tokens;
   - umbral de confianza si se desea modificar 0.85;
   - URL real del canal de alertas.
5. Publicar el workflow.
6. Consumir el endpoint `POST /webhook/uif-ingesta` enviando el Header Auth configurado.
7. Ejecutar prueba controlada y validar telemetría por `transaction_id`.

Variables de referencia: `.env.example`.

## Mecanismos de control

- reintentos limitados en APIs;
- timeout de Document AI y agentes;
- contratos JSON estrictos;
- máximo 2 llamadas de agentes;
- presupuesto máximo de referencia: USD 0.50 por ejecución;
- umbral de confianza: 0.85;
- fallback seguro a `HUMAN_REVIEW`;
- alerta persistente en MySQL por fallo de agente, latencia o presupuesto; webhook externo opcional;
- la IA nunca puede sobreescribir un faltante crítico detectado por reglas.

## Documento de pre-entrega

El mapeo directo contra la consigna de Coderhouse está en `/docs/pre-entrega-coderhouse.md`.

## Runbook

Ver `/docs/runbook.md`.

## Evidencias

Las capturas deben provenir de una ejecución real y anonimizada. Checklist completo:

`/docs/evidence-checklist.md`

No se suben formularios reales al repositorio.

## Estructura

```text
.
├── .env.example
├── README.md
├── docs/
│   ├── architecture.md
│   ├── evidence-checklist.md
│   ├── pre-entrega-coderhouse.md
│   ├── runbook.md
│   └── security.md
├── prompts/
│   ├── agent_analyst.md
│   └── agent_reviewer.md
├── schema/
│   ├── uif_formulario.schema.json
│   └── uif_agent_log.schema.json
├── sql/
│   └── observability.sql
└── workflow/
    ├── uif_document_ai.json
    └── uif_production_ready.json
```

## Criterios de evaluación cubiertos

| Criterio | Implementación |
|---|---|
| Complejidad técnica | 2 agentes especializados + patrón Handoff + gate determinístico |
| Robustez | Retry, timeout, circuit breaker, contratos JSON y fallback humano |
| Seguridad | Credentials n8n, webhook autenticado, sanitización PII, sin secretos en Git |
| Trazabilidad | UUID por ejecución + logs por agente + tokens/costo/latencia/status |
| Operación | README + arquitectura + runbook + checklist de evidencias |
