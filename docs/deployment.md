# Despliegue estable · UIF Production-Ready

## Objetivo

Publicar el workflow de forma repetible, con secretos fuera de Git, observabilidad y una ruta clara de rollback.

## Prerrequisitos

- instancia n8n operativa;
- acceso a la base MySQL destinada a observabilidad;
- credencial del proveedor de IA;
- credencial Header Auth para el webhook;
- acceso autorizado al origen del documento;
- backup/export de la versión anterior del workflow.

## 1. Preparar la base

Ejecutar:

`sql/observability.sql`

Verificar que existan:

- `uif_agent_logs`;
- `uif_agent_alerts`.

La credencial del workflow debe usar mínimo privilegio.

## 2. Crear credenciales en n8n

Crear, sin copiar secretos al workflow exportado:

1. `NVIDIA API` · Bearer Auth.
2. `UIF Webhook Auth` · Header Auth.
3. `UIF Observability MySQL` · MySQL.

## 3. Importar

Importar:

`workflow/uif_production_ready.json`

Reasignar las credenciales por nombre y revisar que ningún nodo muestre un secreto literal.

## 4. Configurar parámetros

Revisar:

- umbral mínimo de confianza;
- presupuesto máximo;
- tarifas por millón de tokens;
- URL de alertas si se utiliza;
- timeouts.

## 5. Smoke test

Ejecutar al menos:

1. documento válido de prueba;
2. documento de prueba con campo crítico faltante;
3. archivo inválido.

Validar:

- `transaction_id`;
- respuesta esperada;
- registros en `uif_agent_logs`;
- ausencia de PII en logs;
- alerta cuando corresponda.

## 6. Publicación

Activar el workflow solamente después del smoke test.

El endpoint productivo debe utilizar autenticación.

## 7. Verificación post-publicación

Durante las primeras ejecuciones revisar:

- errores de API;
- latencia;
- tasa de `HUMAN_REVIEW`;
- tokens/coste;
- alertas OPEN;
- logs por `transaction_id`.

## 8. Operación estable

Controles recomendados:

- conservar export de la versión publicada;
- revisar alertas abiertas;
- mantener un historial de cambios en Git;
- rotar credenciales fuera del repositorio;
- evitar cambios directos sin export posterior;
- validar que el workflow continúe activo luego de mantenimiento/reinicio de la instancia.

## 9. Rollback

Si una publicación nueva falla:

1. desactivar la versión defectuosa;
2. importar o reactivar el último export estable;
3. reasignar credenciales;
4. ejecutar smoke test;
5. confirmar logs;
6. reactivar el endpoint.

No utilizar un fallo de IA como motivo para saltar el control humano.

## 10. Criterio de estabilidad

La versión se considera operativamente estable cuando:

- el webhook está autenticado;
- los tres tipos de credencial están administrados fuera de Git;
- los casos de prueba pasan;
- el fallback a revisión funciona;
- la telemetría se persiste;
- no hay PII en logs;
- existe un rollback probado/documentado.
