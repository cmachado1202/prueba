# Entrega Final Coderhouse · Proyecto Production-Ready

## 1. Problema seleccionado

El proceso elegido es el **relevamiento, extracción y control inicial de Formularios UIF disponibles en GST @CashFlow**.

El cuello de botella original es documental: la información debe localizarse, leerse, estructurarse y revisarse antes de poder utilizarse de forma consistente. El proyecto automatiza esa capa repetitiva y deja las decisiones regulatorias fuera de la IA.

## 2. Objetivo final

Construir una versión que pueda:

1. recibir un documento de forma autenticada;
2. validar que el archivo sea procesable;
3. calcular SHA-256 para trazabilidad;
4. extraer datos a una estructura uniforme;
5. normalizar y validar campos críticos;
6. sanitizar PII antes de los agentes;
7. ejecutar un análisis multiagente controlado;
8. decidir únicamente el enrutamiento técnico;
9. persistir el output estructurado en SQL;
10. registrar telemetría y alertas;
11. derivar a una persona cualquier caso dudoso o fallido.

## 3. Flujo end-to-end

```text
Webhook autenticado
→ Validación archivo
→ SHA-256
→ Document AI
→ Parseo JSON
→ Normalización
→ Validaciones determinísticas
→ Sanitización PII
→ Agente A
→ Gate
→ Agente B si corresponde
→ Control determinístico final
→ AUTO_CONTINUE / HUMAN_REVIEW
→ Persistencia SQL del resultado
→ Logs + alertas
```

## 4. Implementación multiagente

### Agente A · Analista de Integridad

Responsabilidad: revisar la calidad del dato extraído.

Salida:

- `status`;
- `quality_score`;
- `critical_issues`;
- `warnings`;
- `handoff_summary`.

### Agente B · Revisor / Enrutador

Responsabilidad: revisar el resultado del Agente A y decidir solo el recorrido técnico:

- `AUTO_CONTINUE`;
- `HUMAN_REVIEW`.

### Patrón

Se implementa **Handoff controlado**. El segundo agente solo se invoca si el primer agente supera el gate de contrato, confianza y estado. No hay loops infinitos ni autonomía abierta.

## 5. Robustez

La versión final contempla fallos reales de integración:

- archivo inválido;
- fallo del proveedor de Document AI;
- respuesta que no puede convertirse a JSON;
- fallo del Agente A;
- baja confianza;
- fallo del Agente B;
- latencia superior al umbral;
- presupuesto máximo excedido;
- caída de la persistencia de observabilidad;
- canal externo de alertas no configurado;
- autenticación inválida.

La regla principal es que un error de IA **nunca habilita continuidad automática**.

## 6. Seguridad

Se aplican cuatro controles principales:

1. secretos fuera de Git mediante Credentials de n8n;
2. Header Auth en el webhook;
3. sanitización de PII antes de los agentes;
4. logs sin texto documental ni datos identificatorios.

No se almacena cadena de pensamiento. Se registran solamente decisiones estructuradas, métricas y errores operativos.

## 7. Trazabilidad y observabilidad

Cada ejecución genera un `transaction_id` UUID.

Por agente se registran:

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

Esto permite reconstruir qué pasó en una ejecución sin exponer el contenido sensible del formulario en los logs. El output operativo completo se guarda por separado en `uif_processed_results`, con acceso restringido.

## 8. ROI basado en telemetría

El flujo deja instrumentadas las métricas necesarias para calcular el ROI con datos de operación y no con estimaciones ocultas:

- tiempo automático por ejecución;
- tasa de éxito;
- tasa de revisión humana;
- consumo de tokens;
- coste;
- errores/fallbacks.

La fórmula y las consultas están documentadas en `docs/roi.md`.

## 9. Documentación de usuario

La guía `docs/user-guide.md` explica:

- qué significa cada estado;
- cuándo un caso requiere revisión;
- qué hacer frente a un error;
- qué datos no deben copiarse en tickets o capturas.

## 10. Despliegue estable

El procedimiento `docs/deployment.md` define:

- preparación de MySQL;
- creación de credenciales;
- importación del workflow;
- publicación;
- smoke test;
- validación de logs;
- health check;
- rollback.

## 11. Evidencias y QA

La entrega incluye:

- workflow exportado;
- prompts;
- schemas;
- SQL;
- ejemplos sintéticos;
- matriz de pruebas;
- capturas reales disponibles del checkpoint anterior;
- checklist para capturas multiagente reales sin PII.

No se fabrican capturas ni se publican datos reales para completar una evidencia.

## 12. Correspondencia con los criterios

| Criterio | Cómo se cumple |
|---|---|
| Complejidad técnica | Dos agentes, Handoff, gate, reglas determinísticas y observabilidad |
| Robustez | Fallos capturados, timeout/retry, fallback y circuit breaker |
| Seguridad | Secretos fuera de Git, autenticación y sanitización PII |
| Trazabilidad | UUID, logs persistentes, tokens, coste, latencia y status |
| Documentación | Técnica, usuario, incidentes, despliegue, ROI y QA |
| Operación | Workflow Production-Ready y procedimiento estable de publicación/rollback |

## 13. Límites del proyecto

El sistema no:

- determina si una operación es sospechosa;
- reemplaza a Cumplimiento;
- aprueba o rechaza clientes;
- completa información faltante inventando datos;
- expone documentos reales en el repositorio.

Ese límite forma parte del diseño de seguridad.
