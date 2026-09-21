# Entrega Final · Proyecto de Automatización

**Alumna:** Carolina Machado  
**Proyecto:** Automatización inteligente del circuito de Formularios UIF  
**Origen:** GST @CashFlow  
**Orquestador:** n8n  
**Extracción documental:** Document AI mediante NVIDIA  
**Patrón de agentes:** Handoff controlado  
**Versión a evaluar:** Production-Ready

## Link para entregar en Coderhouse

https://github.com/cmachado1202/prueba

## Archivo principal

`workflow/uif_production_ready.json`

## Qué contiene la entrega

La versión final incluye el flujo exportado de n8n, dos agentes con system prompts versionados, sanitización de PII, manejo de secretos, observabilidad persistente, control de coste/latencia, fallbacks, alertas, documentación técnica, guía de usuario, runbook, despliegue, QA y metodología de ROI basada en telemetría.

La IA se usa para **lectura, estructuración y revisión de calidad de datos**. No determina sospecha, no aprueba ni rechaza operaciones y no reemplaza a Cumplimiento.

## Recorrido recomendado para el evaluador

1. Leer `README.md`.
2. Revisar `docs/entrega-final-coderhouse.md`.
3. Abrir `workflow/uif_production_ready.json`.
4. Revisar los prompts en `prompts/`.
5. Revisar `sql/observability.sql`.
6. Revisar `docs/security.md`, `docs/runbook.md`, `docs/deployment.md` y `docs/roi.md`.

## Entregables clave

- `workflow/uif_production_ready.json`
- `.env.example`
- `docs/architecture.md`
- `docs/entrega-final-coderhouse.md`
- `docs/user-guide.md`
- `docs/runbook.md`
- `docs/security.md`
- `docs/deployment.md`
- `docs/roi.md`
- `docs/qa-final.md`
- `prompts/agent_analyst.md`
- `prompts/agent_reviewer.md`
- `schema/uif_formulario.schema.json`
- `schema/uif_agent_log.schema.json`
- `sql/observability.sql`

## Evidencia

El repositorio conserva capturas reales del checkpoint anterior en `assets/`. No se publican formularios reales, PII ni secretos. Las capturas adicionales de ejecución multiagente deben realizarse únicamente sobre una instancia n8n real y anonimizada; la guía se encuentra en `docs/evidence-checklist.md`.
