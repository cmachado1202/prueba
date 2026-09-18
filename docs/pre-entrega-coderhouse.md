# Pre-entrega Coderhouse · Agentes de IA y Despliegue en Producción

## Objetivo

Evolucionar el flujo UIF construido en los módulos anteriores a una versión controlada, trazable y preparada para operación, incorporando una capa multiagente sin delegar decisiones regulatorias a la IA.

## 1. Preparación del repositorio

Cumplido:

- export n8n: `workflow/uif_production_ready.json`;
- plantilla segura: `.env.example`;
- arquitectura: `docs/architecture.md`;
- prompts versionados en `prompts/`;
- SQL de observabilidad en `sql/`;
- runbook operativo;
- checklist de evidencias.

No se publican llaves ni formularios reales.

## 2. Implementación de agentes

### Agente A · Analista de Integridad
Revisa la calidad del dato extraído y devuelve:
- estado OK/REVIEW;
- quality_score;
- issues críticos;
- warnings;
- resumen de handoff.

### Agente B · Revisor y Enrutador
Recibe el output sanitizado del Agente A y decide solamente:
- `AUTO_CONTINUE`;
- `HUMAN_REVIEW`.

El patrón utilizado es **Handoff controlado**. El segundo agente solo se ejecuta si el primero supera el gate de contrato, confianza y control.

## 3. Observabilidad

Se genera un `transaction_id` UUID al inicio y se propaga durante toda la ejecución.

La tabla `uif_agent_logs` registra por agente:

- timestamp;
- transaction_id;
- agent_name;
- input_tokens;
- output_tokens;
- estimated_cost_usd;
- latency_ms;
- status;
- decision/error_code;
- metadata sin PII.

El endpoint NVIDIA usado para el prototipo se publica actualmente como **Free Endpoint**, por lo que el costo directo del endpoint es 0 USD. El workflow igualmente contabiliza tokens y contiene la fórmula de costo con tarifas parametrizables para un proveedor/endpoint pago.

## 4. Hardening de seguridad

- Webhook protegido con Header Auth.
- NVIDIA configurado mediante credencial Bearer de n8n.
- MySQL mediante credencial n8n de mínimo privilegio.
- Sanitización de PII antes de los agentes.
- Logs sin nombre, documento, CUIT/CUIL, domicilio, reportante ni texto documental.
- No se almacena chain-of-thought; solo decisión estructurada y motivos operativos.

## 5. Mecanismos de control

- máximo dos llamadas de agentes;
- sin bucles reflexivos;
- timeout y reintentos acotados;
- contratos JSON validados;
- confianza mínima 0.85;
- presupuesto máximo configurable;
- fallback seguro a revisión humana;
- alertas por fallos y umbrales;
- las reglas determinísticas tienen precedencia sobre los agentes.

## 6. Runbook

Disponible en `docs/runbook.md`. Contempla:
- fallo de Document AI;
- fallo/JSON inválido del Agente A;
- baja confianza;
- fallo del Agente B;
- latencia elevada;
- presupuesto excedido;
- caída del log MySQL;
- autenticación fallida del webhook.

## 7. Evidencias pendientes de ejecución

Las únicas evidencias que no pueden generarse de forma ficticia son capturas de una ejecución real en la instancia n8n:

1. flujo multiagente importado;
2. ejecución `AUTO_CONTINUE`;
3. ejecución `HUMAN_REVIEW`;
4. registros MySQL del mismo `transaction_id`.

La guía exacta está en `docs/evidence-checklist.md`.

## Cobertura de criterios

| Criterio | Evidencia técnica |
|---|---|
| Complejidad Técnica | 2 agentes + Handoff + gate + control determinístico |
| Robustez | retry, timeout, validación contractual, circuit breaker, fallback |
| Seguridad | credentials, Header Auth, PII sanitizada, secretos fuera de Git |
| Trazabilidad | UUID, logs por agente, tokens, latencia, costo y estado |
