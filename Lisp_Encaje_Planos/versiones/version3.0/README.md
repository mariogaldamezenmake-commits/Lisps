# Encajar Planos v3.0

Esta versión combina la facilidad de uso de la v1.5 con la potencia de procesamiento de la v2.0.

## Comando de Inicio
Escribe `EncajarPlanos3` en la barra de comandos.

## Características Principales

### 1. Mensajes Amigables (Estilo v1.5)
Utiliza los mensajes claros y directos que solicitaste:
- "Selecciona el plano ORIGEN y dale a intro"
- "Selecciona el plano a encajar y dale a intro"
- "Selecciona un punto en el plano A ENCAJAR" ... "en el plano ORIGEN"

### 2. Procesamiento Inteligente del Plano Origen (De v2.0)
El plano de referencia (Origen) se procesa automáticamente para facilitar el trabajo:
- **Explota recursivamente** todos los bloques para asegurar que las líneas sean accesibles.
- Mueve todo el contenido a una nueva capa llamada **"PlanoOrigen"**.
- Asigna color **Magenta** (cod 6) para diferenciarlo claramente.

### 3. Escalado Automático
El Lisp detecta y aplica la escala necesaria automáticamente ("el plano origen siempre manda"). **No pregunta** si deseas escalar, lo hace por defecto.

### 4. Resultado Limpio
Al finalizar el encaje:
- El **Plano a Encajar** se mantiene como un **BLOQUE** único (para manipularlo fácilmente o borrarlo si hiciera falta).
- Se eliminan las líneas auxiliares creadas durante el proceso.

## Instalación
1. Carga el archivo `encajar_planos_v3.lsp` usando el comando `APPLOAD`.
2. Escribe `EncajarPlanos3` para ejecutar.
