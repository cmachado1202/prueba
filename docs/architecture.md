# Arquitectura · UIF Production-Ready

```mermaid
flowchart LR
    GST[GST @CashFlow] --> IN[Webhook autenticado]
    IN --> VAL[Validación archivo + SHA-256]
    VAL --> DOC[Document AI / NVIDIA]
    DOC --> NORM[Normalización + controles rígidos]
    NORM --> SAN[Data Sanitization]
    SAN --> A[Agente A · Analista]
    A --> LOGA[(uif_agent_logs)]
    A --> GATE{Confidence / contrato / presupuesto}
    GATE -->|OK| B[Agente B · Revisor]
    GATE -->|Falla| H[Revisión humana]
    B --> LOGB[(uif_agent_logs)]
    B --> CTRL[Control determinístico]
    CTRL --> LOGO[(uif_agent_logs)]
    CTRL -->|AUTO_CONTINUE| NEXT[Siguiente paso técnico]
    CTRL -->|HUMAN_REVIEW| H
    CTRL -->|Umbral operativo| ALERT[Alerta]
```

## Patrón de orquestación

Se usa **Handoff controlado**: el Agente A analiza integridad y, solo si supera el gate de contrato/confianza/coste, entrega el caso al Agente B. No hay bucles reflexivos ni agentes llamándose indefinidamente.

## Por qué este patrón

El proceso UIF exige trazabilidad y límites de autoridad. Por eso la IA no puede sobreescribir reglas determinísticas ni tomar decisiones regulatorias. El control final siempre valida los outputs de los agentes y aplica fallback a revisión humana.

## Fronteras de datos

- **Document AI:** procesa el documento necesario para extracción.
- **Capa de agentes:** recibe únicamente datos sanitizados.
- **Logs:** no contienen PII ni texto documental.
- **Repositorio:** no contiene PDFs reales ni secretos.
