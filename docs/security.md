# Seguridad y privacidad

## Secretos

Las claves no se guardan en el workflow ni en Git. En n8n se crean estas credenciales:

1. **NVIDIA API** · tipo Bearer Auth.
2. **UIF Webhook Auth** · tipo Header Auth.
3. **UIF Observability MySQL** · credencial MySQL con permisos mínimos sobre la tabla de logs.

El archivo `.env.example` documenta variables esperadas para despliegue, pero nunca debe completarse en Git.

## Sanitización PII

Antes de los Agentes A y B se ejecuta `Sanitizar PII + Trace`. Se eliminan del payload enviado a los agentes:

- nombre completo;
- número de documento;
- CUIT/CUIL;
- domicilio;
- nombre del reportante;
- importe exacto;
- ticket y máquina;
- texto completo del documento.

Los agentes trabajan con presencia/ausencia de campos, tipos normalizados, fecha, moneda y métricas de control.

## Webhook

El endpoint de producción usa Header Auth. No debe exponerse sin autenticación. n8n permite autenticación Basic/Header/JWT para webhooks y su auditoría de seguridad detecta webhooks sin protección como riesgo.

## Logs

No se guarda cadena de pensamiento. Se guardan:
- decisiones estructuradas;
- motivos resumidos;
- tokens;
- latencia;
- coste estimado;
- estado;
- `transaction_id`.

## Principio de mínimo privilegio

La credencial MySQL del workflow debe tener únicamente permisos de `INSERT` sobre `uif_agent_logs` y, si Operaciones necesita consultar, usar otra credencial de solo lectura.


## Persistencia operativa

El resultado estructurado final se almacena en `uif_processed_results`. Esta tabla puede contener PII dentro de `resultado_json`, por lo que debe tener acceso restringido, retención definida y permisos mínimos. La separación es deliberada: `uif_agent_logs` y `uif_agent_alerts` siguen sin PII para permitir observabilidad operativa segura.
