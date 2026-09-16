# UIF · Flujo Operativo de Extracción Inteligente

**Proyecto final · Módulo 2**

## Caso de uso

Este repositorio implementa la evolución técnica del plan de automatización definido en el Módulo 1 para el circuito de Formularios UIF disponible en GST @CashFlow.

El objetivo de este checkpoint es construir el **Ingestor de Datos** del proyecto: recibir un PDF o imagen, aplicar extracción documental con IA, normalizar los campos, validar la información crítica y devolver un JSON estructurado apto para controles posteriores.

El flujo **no determina si una operación es sospechosa, no decide cumplimiento normativo y no reemplaza la revisión de Cumplimiento**. La IA se limita a lectura y estructuración documental.

## Arquitectura

```text
Webhook
  ↓
Preparar entrada
  ├─ archivo multipart/form-data
  └─ pdf_url → descarga
  ↓
Validar archivo
  ↓
Base64 + SHA-256
  ↓
Document AI / NVIDIA API
  ↓
JSON estructurado
  ↓
Normalización
  ↓
Validación de campos críticos
  ├─ OK
  └─ Requiere revisión
```

## Herramienta de orquestación

- **n8n**
- Workflow exportado: `/workflow/uif_document_ai.json`

## Endpoint

### POST `/webhook/uif-ingesta`

El Webhook acepta dos modalidades.

### Opción A · Archivo

Enviar `multipart/form-data` con:

- `archivo`: PDF, JPG o PNG
- `formulario_id`: opcional

El workflow detecta automáticamente la primera propiedad binaria recibida.

### Opción B · URL

Enviar JSON:

```json
{
  "formulario_id": "UIF-000123",
  "pdf_url": "https://servidor-ejemplo.local/documentos/uif-000123.pdf"
}
```

## Configuración de credenciales

No se incluyen secretos en el repositorio.

El workflow usa el header HTTP:

```text
Authorization: Bearer PEGA_AQUI_TU_NVIDIA_API_KEY
```

Para probarlo en n8n, reemplazar temporalmente el placeholder por una NVIDIA API key válida dentro del nodo `Document AI - NVIDIA`.

Antes de exportar o publicar el workflow, volver a dejar el placeholder. La API key real no debe subirse al repositorio ni aparecer en capturas públicas.

## Extracción con Document AI

El nodo `Document AI - NVIDIA` utiliza entrada de archivo PDF/imagen y solicita salida estructurada mediante JSON Schema.

El modelo extrae únicamente:

- número de formulario;
- datos principales del cliente;
- fecha, ticket, máquina e importe de la operación;
- moneda y medio de pago cuando sean inequívocos;
- condición PEP;
- requerimiento de certificado/documentación;
- nombre del reportante.

Cuando un dato no se encuentra o un checkbox no puede determinarse de manera inequívoca, debe devolver `null`.

## Esquema de datos

El contrato final se conserva en:

`/schema/uif_formulario.schema.json`

Estructura principal:

```json
{
  "formulario_id": "string",
  "fecha_procesamiento": "date-time",
  "cliente": {
    "nombre_completo": "string",
    "tipo_documento": "DNI | CUIT | CUIL | PASAPORTE | OTRO",
    "numero_documento": "string",
    "cuit_cuil": "string | null",
    "domicilio": "string | null"
  },
  "operacion": {
    "fecha": "YYYY-MM-DD",
    "ticket": "string | null",
    "maquina": "string | null",
    "importe": 0,
    "moneda": "ARS",
    "medio_pago": "string | null"
  },
  "declaraciones": {
    "pep": "boolean | null",
    "certificado_documentacion": "boolean | null"
  },
  "reportante": {
    "nombre": "string | null"
  },
  "control": {
    "documento_completo": true,
    "requiere_revision": false,
    "motivos_revision": [],
    "confianza_extraccion": 1
  },
  "archivo": {
    "nombre_original": "string",
    "sha256": "64 caracteres hexadecimales"
  }
}
```

## Normalización

El nodo `Normalizar y validar` aplica las siguientes reglas:

- fechas `DD/MM/YYYY` → `YYYY-MM-DD`;
- importes con `$`, puntos de miles y coma decimal → número;
- documento → enum normalizado;
- DNI/CUIT/CUIL → solo dígitos;
- moneda vacía → `ARS`;
- cadenas vacías → `null`.

Ejemplo:

```text
$6.277.500,00 → 6277500.00
15/09/2026 → 2026-09-15
D.N.I. → DNI
```

## Validación

Se consideran críticos:

- `formulario_id`
- `cliente.nombre_completo`
- `cliente.tipo_documento`
- `cliente.numero_documento`
- `operacion.fecha`
- `operacion.importe`

Si alguno falta:

```json
{
  "documento_completo": false,
  "requiere_revision": true,
  "motivos_revision": [
    "campo_critico_faltante:cliente.numero_documento"
  ]
}
```

La confianza del checkpoint se calcula como proporción de campos críticos presentes. No representa una decisión de cumplimiento.

## Resiliencia y manejo de errores

El workflow contempla:

1. **Entrada inválida**  
   No se recibió archivo ni URL → HTTP 400.

2. **Documento vacío/corrupto**  
   Se comprueba tamaño, tipo MIME y firma binaria de PDF/JPG/PNG → HTTP 400.

3. **Error en Document AI**  
   El nodo HTTP continúa por una rama controlada y devuelve un error estructurado → HTTP 502.

4. **Datos incompletos**  
   La ejecución finaliza correctamente, pero `requiere_revision=true`.

## Ejemplo de salida correcta

```json
{
  "formulario_id": "UIF-000123",
  "fecha_procesamiento": "2026-09-16T14:30:00.000Z",
  "cliente": {
    "nombre_completo": "CLIENTE DE PRUEBA",
    "tipo_documento": "DNI",
    "numero_documento": "00000000",
    "cuit_cuil": "20000000001",
    "domicilio": "DOMICILIO ANONIMIZADO"
  },
  "operacion": {
    "fecha": "2026-09-15",
    "ticket": "3",
    "maquina": "12000021",
    "importe": 6277500,
    "moneda": "ARS",
    "medio_pago": null
  },
  "declaraciones": {
    "pep": false,
    "certificado_documentacion": false
  },
  "reportante": {
    "nombre": "REPORTANTE ANONIMIZADO"
  },
  "control": {
    "documento_completo": true,
    "requiere_revision": false,
    "motivos_revision": [],
    "confianza_extraccion": 1
  },
  "archivo": {
    "nombre_original": "formulario_uif_prueba.pdf",
    "sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
  }
}
```

## Prueba con documento real

Para la validación del checkpoint se utiliza un formulario UIF real de seis páginas.

**Importante:** el PDF de prueba contiene datos personales y no debe publicarse en este repositorio. Las capturas que se incorporen en `/assets` deben anonimizar DNI, CUIT/CUIL, domicilio, teléfono, correo electrónico y cualquier otro dato identificatorio.

## Capturas requeridas

Agregar en `/assets`:

- `01_flujo_completo.png`
- `02_ejecucion_exitosa.png`
- `03_rama_revision_o_error.png`

Las capturas deben provenir de una ejecución real de n8n. No deben fabricarse ni contener credenciales o datos personales visibles.

## Archivos de ejemplo

- `/examples/request_url.json`
- `/examples/response_ok.json`
- `/examples/response_revision.json`

## Importación

1. Abrir n8n.
2. Importar `/workflow/uif_document_ai.json`.
3. Crear las variables `NVIDIA_API_KEY` y, opcionalmente, `NVIDIA_DOCUMENT_MODEL`.
4. Abrir el nodo `Document AI - NVIDIA` y verificar la autorización.
5. Ejecutar el Webhook en modo de prueba.
6. Enviar un PDF real.
7. Confirmar que el flujo finalice en `Responder OK` o `Responder revisión`.
8. Guardar las capturas anonimizadas en `/assets`.
9. Exportar nuevamente el workflow si n8n actualiza automáticamente versiones de nodos.

## Criterios del checkpoint

| Criterio | Implementación |
|---|---|
| Funcionalidad | Webhook + archivo/URL + extracción + respuesta |
| Mapeo | JSON final basado en el esquema del Módulo 1 |
| Resiliencia | entrada inválida, documento corrupto, error de IA y revisión |
| Calidad de datos | fechas, importes, documentos, nulos y SHA-256 normalizados |