# Guía de usuario · UIF Automatización

## Objetivo

Esta guía explica cómo interpretar el resultado del flujo sin entrar en detalles internos de implementación.

## Estados posibles

### AUTO_CONTINUE

El documento fue procesado, los campos críticos pasaron las validaciones y la capa de revisión no detectó una condición que obligue a intervención manual.

Este estado significa únicamente que el dato puede continuar al **siguiente paso técnico**.

No significa aprobación de cumplimiento.

### HUMAN_REVIEW

Una persona debe revisar el caso antes de continuar.

Puede ocurrir por:

- campo crítico faltante;
- inconsistencia;
- baja confianza;
- fallo de un agente;
- contrato JSON inválido;
- presupuesto o control operativo;
- otra regla determinística.

## Qué hacer ante HUMAN_REVIEW

1. Buscar el `transaction_id`.
2. Revisar la ejecución correspondiente en n8n.
3. Ver los motivos de revisión.
4. Comparar contra el documento original desde un entorno autorizado.
5. Corregir o completar el circuito por el procedimiento definido por el área.
6. No pegar PII en tickets, chats o capturas.

## Errores de entrada

### DOCUMENTO_INVALIDO

El archivo está vacío, corrupto o no coincide con un formato permitido.

Acción: volver al documento original y reenviarlo.

### ERROR_DOCUMENT_AI

El proveedor no pudo devolver una salida estructurada utilizable.

Acción: revisar la ejecución y la disponibilidad/credencial del proveedor. No forzar continuidad.

### Autenticación fallida

El webhook rechaza entradas que no utilizan la credencial configurada.

Acción: validar Header Auth desde el sistema origen.

## Qué información se puede usar para soporte

Sí:

- `transaction_id`;
- timestamp;
- status;
- nombre técnico del agente;
- latency_ms;
- código de error;
- decisión de enrutamiento.

No:

- nombre del cliente;
- DNI/CUIT/CUIL;
- domicilio;
- texto completo del formulario;
- capturas con PII;
- claves o tokens.

## Regla general

Ante duda, el circuito debe permanecer en revisión humana.
