# Texto breve para la entrega

**Proyecto:** Automatización del circuito de Formularios UIF  
**Herramienta:** n8n  
**Componente de extracción:** Document AI mediante modelo multimodal con salida JSON estructurada.

El workflow recibe un PDF/imagen o una URL mediante Webhook, valida el archivo, lo transforma a Base64, calcula SHA-256, extrae los campos definidos en el esquema del Módulo 1, normaliza fechas e importes y valida campos críticos. Los documentos incompletos o ambiguos son derivados a revisión, sin automatizar decisiones de cumplimiento UIF.

**Repositorio público:** https://github.com/cmachado1202/prueba

**Evidencia incluida en el repositorio:**
- `/workflow/uif_document_ai.json`
- `README.md`
- `/schema/uif_formulario.schema.json`
- `/assets/01_flujo_completo.png`
- `/assets/02_ejecucion_exitosa.png`
- `/assets/03_rama_revision_o_error.png`