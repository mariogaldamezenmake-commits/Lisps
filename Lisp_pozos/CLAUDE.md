\## 📋 Descripción del Proyecto



En este proyecto de topografía se realiza un levantamiento de pozos y arquetas para posteriormente procesar la información en gabinete. El proceso se divide en \*\*dos pasadas en campo\*\* y un \*\*trabajo de gabinete\*\*.



---



\## 📍 Primera Pasada: Levantamiento Planialétrico y Altimétrico



\### Objetivo



Dotar de coordenadas planialtéricas (X, Y, Z) a las tapas de los pozos.



\### Procedimiento



1\. \*\*Ubicación\*\*: Se identifica cada pozo en campo

2\. \*\*Medición\*\*: Se toma un único punto en el \*\*centro de la tapa\*\* del pozo

3\. \*\*Registro\*\*: Se obtienen coordenadas X, Y, Z (cota de la tapa)

4\. \*\*Numeración\*\*: Se asigna un identificador único a cada pozo



\### Equipo utilizado



\- Estación total o GPS RTK

\- Prisma o antena GPS

\- Libreta de campo



\### Datos obtenidos



\- \*\*Pozo ID\*\*: Identificador único

\- \*\*X, Y\*\*: Coordenadas planialtéricas

\- \*\*Z (cota de tapa)\*\*: Altura de la tapa del pozo



---



\## 🔍 Segunda Pasada: Caracterización del Pozo



\### Objetivo



Obtener información detallada sobre las características físicas y conexiones de cada pozo.



\### Procedimiento



\### 1. Medición de la tapa



\- \*\*Diámetro de la trapa\*\* (para pozos circulares)

\- \*\*Dimensiones\*\* (para arquetas cuadradas) → esto tengo que preguntarlo porque no estoy seguro



\### 2. Apertura del pozo



\- Se abre la tapa para inspección interna



\### 3. Categorización del tipo de agua



Se clasifica según el tipo de agua que transporta:



\- 💧 \*\*Pluvial\*\*: Aguas de lluvia

\- 🚽 \*\*Fecal / Saneamiento\*\*: Aguas residuales

\- 💧 \*\*Potable\*\*: Agua de consumo

\- 🌾 \*\*Acequia\*\*: Riego agrícola

\- 📶 \*\*Telecomunicaciones\*\*: Cableado

\- ⚡ \*\*Electricidad\*\*: Red eléctrica

\- ❓ \*\*No se sabe\*\*: Casos dudosos



\### 4. Medición de profundidad de los tubos



\- Se mide la distancia vertical desde la \*\*tapa hasta la parte baja del agujero del tubo\*\*

\- Esta medida permite calcular la \*\*cota del tubo\*\*: `cota\_fondo = cota\_tapa - profundidad`



\### 5. Conteo y medición de tubos



Para cada tubo conectado al pozo:



\- \*\*Cantidad\*\*: Número total de tubos

\- \*\*Diámetro\*\*: De cada tubo individual

\- Profundidad: distancia a la parte mas lejana de la tapa al tubo

\- \*\*Dirección\*\*: Se anota hacia dónde se dirige en un croquis

\- \*\*Tipo de tubo\*\*:

&nbsp;   - 🔹 \*\*Colector principal\*\*: Entrada y salida (flujo principal) → Puede no saberse al abrir el tubo que agujero es la entrada y cual es la salida. Puede darse el caso de que solo haya un agujero de salida y no entrada en cuyo caso se trata de un pozo de arranque.

&nbsp;   - 🔸 \*\*Acometidas\*\*: Conexiones secundarias (puede haber varias)



\### 6. Registro en plano de situación



El equipo trabaja con un \*\*plano en papel\*\* donde:



\- Anota el \*\*número del pozo\*\*

\- Marca la \*\*profundidad del pozo para saber la cota del arenero → duda preguntar\*\*

\- Anota el número de tubos del pozo

\- Anota los diámetros de los tubos

\- Anota las profundidades de los tubos

\- Dibuja \*\*líneas\*\* representando los tubos con su dirección aproximada

\- Relaciona pozos: \*"el pozo 24 conecta con el pozo 25"\*



---



\## 📊 Tipos de Pozos



\### Por forma de la tapa



\- 🔵 \*\*Pozos\*\*: Tapa circular

\- 🟪 \*\*Arquetas\*\*: Tapa cuadrada/rectangular



\### Por tipo de conexión



\- 🔴 \*\*Pozo de arranque\*\*: Solo tiene UNA salida de colector principal (sin entrada). Define el punto inicial de la red y el sentido de flujo.

\- 🟪 \*\*Pozo intermedio\*\*: Tiene entrada y salida de colector

\- 🟡 \*\*Pozo con acometidas\*\*: Tiene conexiones secundarias además del colector



---



\## 📝 Conceptos Importantes



\### Colector Principal



\- Solo puede haber \*\*UN colector principal\*\* en cada pozo

\- Tiene una \*\*entrada\*\* y una \*\*salida\*\*

\- Si solo hay flujo en una dirección sin entrada → \*\*Pozo de arranque\*\*

\- Si no fluye agua, es difícil determinar cuál es entrada y cuál salida



\### Acometidas



\- Puede haber \*\*múltiples acometidas\*\* en un pozo

\- Son conexiones que desembocan en el colector

\- No forman parte del flujo principal



\### Sentido de flujo



\- Se determina observando el flujo de agua en el pozo

\- Los \*\*pozos de arranque\*\* ayudan a establecer el sentido de la red

\- Importante para validación de diseño y normativas



---



\## 🛠️ Desafíos en Campo



\### 🎯 Dirección de tubos



\*\*Problema\*\*: Es complicado determinar con precisión hacia dónde se dirige cada tubo.



\*\*Solución actual\*\*:



\- El técnico se mete físicamente en el pozo

\- Observa visualmente la dirección aproximada

\- Anota en el plano la conexión estimada con otros pozos



---



\## 💼 Trabajo de Gabinete



Una vez recopilada toda la información de campo, se procede a:



1\. \*\*Digitalización\*\* en AutoCAD:

&nbsp;   - Creación de polilíneas 3D para tubos

&nbsp;   - Ajuste de cotas Z en extremos

&nbsp;   - Inserción de bloques (POZO o LA, según proyecto) con atributos

2\. \*\*Validación\*\*:

&nbsp;   - Verificar conexiones entre pozos

&nbsp;   - Comprobar coherencia de cotas

&nbsp;   - Detectar errores en direcciones

3\. \*\*Generación de entregables\*\*:

&nbsp;   - Planos de planta

&nbsp;   - Planos de perfil longitudinal

&nbsp;   - Fichas técnicas por pozo

&nbsp;   - Listados y tablas



\### 🤖 Herramientas de Automatización: Comando P1



Para agilizar el trabajo de gabinete se ha desarrollado el comando \*\*P1\*\* en AutoLISP para AutoCAD 2026.



\#### P1.lsp (Versión 1.0)



\*\*Propósito\*\*: Inserción de UN SOLO pozo a la vez



\*\*Flujo de trabajo\*\*:

1\. \*\*Solicita datos del pozo\*\*:

&nbsp;   - Cota de la tapa (Z de la superficie)

&nbsp;   - Profundidad del tubo (medida desde tapa hasta parte baja del agujero)

&nbsp;   - Diámetro del tubo

&nbsp;   - Número de tubos conectados



2\. \*\*Calcula automáticamente\*\*:

&nbsp;   - \`resultado = cota\_tapa - profundidad\`

&nbsp;   - Este "resultado" es la \*\*cota Z del fondo del tubo\*\*



3\. \*\*Ajusta la geometría 3D\*\*:

&nbsp;   - Permite seleccionar una polilínea 3D (que representa el tubo)

&nbsp;   - Permite hacer clic cerca del extremo deseado

&nbsp;   - \*\*Modifica la coordenada Z de ese extremo\*\* al valor "resultado"

&nbsp;   - Esto garantiza que la polilínea 3D termina exactamente en la cota del fondo del tubo



4\. \*\*Inserta el bloque POZO\*\*:

&nbsp;   - Inserta un bloque llamado "POZO" en el punto especificado

&nbsp;   - Rellena automáticamente los atributos:

&nbsp;     - \`RESULTADO\`: Cota Z del fondo del tubo

&nbsp;     - \`DIAMETRODETUBO\`: Diámetro del tubo

&nbsp;     - \`NUMERODETUBOS\`: Cantidad de tubos conectados

&nbsp;   - \*\*Orienta el bloque\*\* según la tangente de la polilínea en ese extremo



\*\*Ventaja\*\*: Reduce errores al calcular cotas y asigna atributos de forma automática



\#### P1\_v1.2.lsp (Versión 1.2)



\*\*Propósito\*\*: Inserción de \*\*MÚLTIPLES pozos en una sola ejecución\*\*



\*\*Mejoras respecto a v1.0\*\*:



1\. \*\*Proceso en dos fases\*\*:

&nbsp;   - \*\*FASE 1 - Recopilación de datos\*\*: Se solicitan los datos de TODOS los pozos consecutivamente (cota, profundidad, diámetro, tubos)

&nbsp;   - \*\*FASE 2 - Inserción gráfica\*\*: Se insertan los bloques uno por uno, seleccionando polilíneas y extremos



2\. \*\*Validaciones integradas\*\*:

&nbsp;   - Verifica que la profundidad sea positiva

&nbsp;   - Verifica que el diámetro sea positivo

&nbsp;   - Verifica que haya al menos 1 tubo

&nbsp;   - Emite advertencias si los valores son incorrectos



3\. \*\*Mejor manejo de errores\*\*:

&nbsp;   - Si falla la inserción de un pozo, permite continuar con los siguientes

&nbsp;   - Mensajes informativos sobre el progreso (ej: "POZO 3 de 5")

&nbsp;   - Opción de cancelar o saltar pozos individuales



4\. \*\*Experiencia de usuario mejorada\*\*:

&nbsp;   - Muestra resumen de datos antes de cada inserción

&nbsp;   - Indica progreso durante el proceso

&nbsp;   - Mensaje final con el total de pozos procesados



\*\*Ventaja principal\*\*: Permite trabajar en \*\*lote\*\*, ideal cuando se tienen muchos pozos del mismo levantamiento. Se pueden introducir todos los datos numéricos de una vez (mirando la libreta de campo) y luego hacer todas las inserciones gráficas seguidas.



\*\*Uso recomendado\*\*: Cuando tienes 5+ pozos para digitalizar, usar v1.2 ahorra mucho tiempo al no tener que repetir el comando para cada pozo.



\#### P1\_v2.0.lsp (Versión 2.0 - CARGA AUTOMÁTICA DESDE CSV)



\*\*Propósito\*\*: Automatización completa mediante \*\*lectura de datos desde archivos CSV\*\* (PRIMERA\_PASADA.txt y SEGUNDA\_PASADA.txt)



\*\*Revolución en el flujo de trabajo\*\*:



1\. \*\*Entrada de datos\*\*: Ya NO se escriben datos manualmente en gabinete

&nbsp;   - Los datos ya están capturados en los archivos CSV de campo

&nbsp;   - El usuario solo selecciona el archivo SEGUNDA\_PASADA.txt

&nbsp;   - El sistema busca automáticamente PRIMERA\_PASADA.txt en la misma carpeta



2\. \*\*Procesamiento automático\*\*:

&nbsp;   - Lee y combina ambos archivos CSV

&nbsp;   - Para cada tubo, calcula automáticamente: \`cota\_tubo = cota\_tapa - prof\_tubo\`

&nbsp;   - Muestra resumen: "5 pozos cargados, 12 tubos totales"



3\. \*\*Flujo iterativo por tubo\*\*:

&nbsp;   - Para CADA tubo en SEGUNDA\_PASADA.txt:

&nbsp;     - Muestra información: "POZO P003 - Tubo 2/3 - Colector salida Ø30cm"

&nbsp;     - Muestra cálculo: "Cota tapa: 107.78m | Prof: 2.30m → Cota tubo: 105.48m"

&nbsp;     - Solicita: Seleccionar polilínea 3D

&nbsp;     - Solicita: Click en extremo de la polilínea

&nbsp;     - Ajusta automáticamente Z del vértice a la cota calculada

&nbsp;     - Solicita: Punto de inserción del bloque POZO

&nbsp;     - Inserta bloque con atributos ya rellenos

&nbsp;     - Continúa con el siguiente tubo



4\. \*\*Datos extraídos de los CSV\*\*:

&nbsp;   - De PRIMERA\_PASADA.txt: ID\_POZO, X, Y, Z (cota\_tapa)

&nbsp;   - De SEGUNDA\_PASADA.txt: tipo\_agua, forma\_tapa, dim\_tapa, prof\_arenero, num\_tubo, total\_tubos, tipo\_tubo, diam\_tubo, prof\_tubo

&nbsp;   - Calculados: cota\_tubo (para ajustar Z del vértice)



5\. \*\*Atributos del bloque POZO\*\* (igual que en v1.2):

&nbsp;   - \`RESULTADO\`: Cota del tubo (cota\_tapa - prof\_tubo)

&nbsp;   - \`DIAMETRODETUBO\`: Diámetro del tubo en cm

&nbsp;   - \`NUMERODETUBOS\`: Total de tubos del pozo



\*\*Ventajas clave de v2.0\*\*:

\- ✅ \*\*Cero escritura manual\*\*: Los datos ya están en los CSV de campo

\- ✅ \*\*Cero errores de transcripción\*\*: No hay riesgo de equivocarse al teclear números

\- ✅ \*\*Procesamiento tubo por tubo\*\*: El usuario solo hace clicks en posiciones correctas

\- ✅ \*\*Trazabilidad completa\*\*: Toda la información viene directamente de campo

\- ✅ \*\*Escalabilidad\*\*: Funciona igual con 5 tubos o 500 tubos



\*\*Uso recomendado\*\*: \*\*SIEMPRE\*\* que tengas los archivos CSV de campo. Esta es la versión definitiva para producción. Solo requiere que el técnico de campo haya registrado correctamente los datos en PRIMERA\_PASADA.txt y SEGUNDA\_PASADA.txt.



\*\*Requisitos\*\*:

\- Archivos PRIMERA\_PASADA.txt y SEGUNDA\_PASADA.txt en la misma carpeta

\- Formato CSV con separador de coma (,)

\- Bloque "POZO" con atributos RESULTADO, DIAMETRODETUBO, NUMERODETUBOS



\#### P1\_v2.1.lsp (Versión 2.1 - DETECCIÓN AUTOMÁTICA DE VÉRTICE) ⭐ ACTUAL



\*\*Propósito\*\*: Simplificación del flujo de trabajo mediante \*\*detección automática de polilínea 3D y vértice\*\*



\*\*Mejora principal respecto a v2.0\*\*:



En la v2.0, el usuario debía:

1\. Seleccionar la polilínea 3D manualmente

2\. Hacer click cerca del extremo

3\. Insertar el bloque POZO



En la v2.1, el usuario solo debe:

1\. \*\*Hacer click cerca del vértice\*\* → El sistema detecta automáticamente la polilínea 3D más cercana

2\. Insertar el bloque POZO



\*\*Nuevas funcionalidades técnicas\*\*:



1\. \*\*Búsqueda eficiente de polilíneas 3D\*\*:

&nbsp;   - El sistema busca entre las polilíneas 3D del dibujo

&nbsp;   - No requiere que el usuario identifique o seleccione cuál es la correcta

&nbsp;   - Detecta automáticamente cuál tiene un vértice exactamente en el punto del click

&nbsp;   - Se detiene cuando encuentra la primera coincidencia (optimización de rendimiento)



2\. \*\*Detección automática de vértice mediante OSNAP\*\*:

&nbsp;   - Asume que el usuario tiene OSNAP activado (Endpoint, Vertex, Node)

&nbsp;   - El click del usuario está exactamente en el vértice gracias a OSNAP

&nbsp;   - Busca eficientemente qué polilínea 3D tiene un vértice en ese punto exacto

&nbsp;   - Usa tolerancia de 1mm para comparar coordenadas (evita errores de punto flotante)

&nbsp;   - Mucho más rápido que calcular distancias a todos los vértices



3\. \*\*Feedback informativo mejorado\*\*:

&nbsp;   - Aviso inicial: "⚠️ IMPORTANTE: Asegúrate de tener OSNAP activado (Endpoint, Vertex, Node)"

&nbsp;   - Muestra qué vértice fue detectado: "✓ Detectada polilínea 3D - Vértice #0"

&nbsp;   - Confirma cuando la Z es ajustada: "✓ Z del vértice ajustada a 105.48m"

&nbsp;   - Si OSNAP no está activado, avisa: "¿Tienes OSNAP activado? Verifica Endpoint/Vertex/Node"

&nbsp;   - Elimina la posibilidad de seleccionar la polilínea incorrecta



\*\*Flujo de trabajo detallado\*\*:



Para cada tubo del archivo CSV:

1\. Sistema muestra información del tubo:

&nbsp;   - ">>> TUBO 3 de 12 <<<"

&nbsp;   - "POZO: P003 | Tubo 2/3 | Tipo: colector\_salida | Ø30cm"

&nbsp;   - "Cota tapa: 107.78m | Profundidad: 2.30m → Cota tubo: 105.48m"



2\. Usuario hace click cerca del vértice deseado



3\. Sistema detecta y procesa automáticamente:

&nbsp;   - Encuentra la polilínea 3D más cercana

&nbsp;   - Identifica el vértice más cercano al click

&nbsp;   - Ajusta la coordenada Z del vértice a la cota calculada

&nbsp;   - Calcula el ángulo de orientación basándose en la tangente



4\. Usuario hace click para insertar el bloque POZO



5\. Sistema inserta el bloque con atributos ya rellenos y continúa con el siguiente tubo



\*\*Ventajas clave de v2.1\*\*:

\- ✅ \*\*Un click menos por tubo\*\*: Elimina el paso de seleccionar la polilínea

\- ✅ \*\*Cero errores de selección\*\*: No hay riesgo de seleccionar la polilínea equivocada

\- ✅ \*\*Más rápido y eficiente\*\*: Búsqueda optimizada por comparación de coordenadas exactas en lugar de calcular distancias

\- ✅ \*\*Más intuitivo\*\*: Solo hacer click en el vértice (con OSNAP), el sistema detecta todo automáticamente

\- ✅ \*\*Escalable\*\*: Funciona igual de bien con 10 polilíneas que con 1000

\- ✅ \*\*Mismo nivel de automatización\*\*: Mantiene todas las ventajas de v2.0 (lectura de CSV, cálculos automáticos, etc.)



\*\*Uso recomendado\*\*: \*\*VERSIÓN RECOMENDADA\*\* para todos los proyectos. Es la evolución natural de la v2.0 con un flujo de trabajo más eficiente y menos propenso a errores.



\*\*Requisitos\*\*:

\- Archivos PRIMERA\_PASADA.txt y SEGUNDA\_PASADA.txt en la misma carpeta

\- Formato CSV con separador de coma (,)

\- Bloque "POZO" con atributos RESULTADO, DIAMETRODETUBO, NUMERODETUBOS

\- Al menos una polilínea 3D dibujada por cada tubo antes de ejecutar el comando

\- ⚠️ \*\*OSNAP activado\*\*: Es fundamental tener activados los modos Endpoint, Vertex o Node para que el click se "pegue" exactamente al vértice de la polilínea



\*\*Comparación de velocidad\*\*:

\- v1.0: ~2 minutos por tubo (entrada manual de datos + selección + inserción)

\- v1.2: ~1 minuto por tubo (entrada manual en lote + selección + inserción)

\- v2.0: ~30 segundos por tubo (lectura CSV + selección polilínea + click extremo + inserción)

\- v2.1: ~20 segundos por tubo (lectura CSV + click vértice + inserción) 🚀



\#### 🔧 Variantes del Proyecto para Usuarios Específicos



El proyecto incluye adaptaciones de las herramientas principales para diferentes usuarios y configuraciones de bloques. Estas variantes se encuentran en carpetas separadas:



\##### Mario/P1.01.lsp (Variante con Bloque LA)



\*\*Diferencias respecto a las versiones principales\*\*:

\- \*\*Bloque utilizado\*\*: "LA" (en lugar de "POZO")

\- \*\*Nombre del atributo\*\*: "DIAMETRODELTUBO" (en lugar de "DIAMETRODETUBO")

\- \*\*Base de código\*\*: Combina entrada manual de datos (como v1.0) con detección automática de vértice por OSNAP (como v2.1)

\- \*\*Método de trabajo\*\*: Entrada de datos uno por uno, sin lectura desde CSV



\*\*Flujo de trabajo\*\*:

1\. Solicita datos manualmente (cota tapa, profundidad, diámetro, número de tubos)

2\. Usuario hace click EN el vértice (con OSNAP activado)

3\. Sistema detecta automáticamente la polilínea 3D

4\. Ajusta Z del vértice al valor calculado

5\. Usuario define punto de inserción

6\. Inserta bloque "LA" con atributos rellenos



\*\*Cuándo usar esta variante\*\*:

\- Cuando el dibujo utiliza el bloque "LA" en lugar de "POZO"

\- Cuando se prefiere entrada manual de datos en lugar de CSV

\- Cuando se trabaja con pocos tubos (1-3 por sesión)



\*\*Bloque LA - Atributos\*\*:

\- \`RESULTADO\`: Cota Z del fondo del tubo (calculada automáticamente)

\- \`DIAMETRODELTUBO\`: Diámetro del tubo en cm

\- \`NUMERODETUBOS\`: Cantidad total de tubos en el pozo



\##### Mario/P1.02.lsp (Variante con Orientación Corregida) ⭐ ACTUAL



\*\*Propósito\*\*: Corrección de orientación del bloque LA para lectura siempre de izquierda a derecha



\*\*Mejora principal respecto a P1.01\*\*:



\- \*\*Orientación inteligente del bloque\*\*: El bloque LA siempre queda legible, nunca boca abajo

\- \*\*Corrección automática\*\*: Si el ángulo de la polilínea haría que el bloque quede invertido (ángulos entre 90° y 270°), automáticamente suma 180° para corregir la orientación

\- \*\*Características del bloque LA\*\*:

&nbsp;   - Longitud: 0.60 metros

&nbsp;   - Punto de inserción: Esquina inferior izquierda con offset (-0.0305m, -0.0283m) para alineación perfecta con vértice izquierdo de líneas horizontales



\*\*Nueva funcionalidad técnica\*\*:



1\. \*\*Función `_normalize-angle`\*\*:

&nbsp;   - Normaliza ángulos al rango [0, 2π) para cálculos consistentes



2\. \*\*Lógica de corrección automática\*\*:

&nbsp;   - Calcula el ángulo de la tangente de la polilínea en el vértice

&nbsp;   - Verifica si el ángulo está entre 90° y 270° (que dejaría el bloque ilegible)

&nbsp;   - Si es así, suma automáticamente 180° (π radianes) para invertir la orientación

&nbsp;   - Garantiza que el texto del bloque siempre se lea de izquierda a derecha



3\. \*\*Mensajes informativos mejorados\*\*:

&nbsp;   - Indica cuando se aplica corrección: "✓ Ángulo corregido para lectura de izquierda a derecha: XX.XX°"

&nbsp;   - Muestra ángulo sin corrección: "✓ Ángulo de orientación: XX.XX°"



\*\*Tabla de comportamiento de orientación\*\*:



| Ángulo original | ¿Se corrige? | Acción | Resultado |
|----------------|--------------|--------|-----------|
| 0° - 90° | ❌ No | Mantiene ángulo | Bloque legible (apunta arriba-derecha) |
| 90° - 270° | ✅ Sí | +180° | Bloque invertido para quedar legible |
| 270° - 360° | ❌ No | Mantiene ángulo | Bloque legible (apunta abajo-derecha) |



\*\*Flujo de trabajo\*\* (idéntico a P1.01 pero con orientación mejorada):

1\. Solicita datos manualmente (cota tapa, profundidad, diámetro, número de tubos)

2\. Usuario hace click EN el vértice (con OSNAP activado)

3\. Sistema detecta automáticamente la polilínea 3D

4\. Ajusta Z del vértice al valor calculado

5\. \*\*Calcula y corrige automáticamente la orientación del bloque\*\*

6\. Usuario define punto de inserción

7\. Inserta bloque "LA" con atributos rellenos y orientación correcta



\*\*Ventajas clave de P1.02\*\*:

\- ✅ \*\*Siempre legible\*\*: El bloque nunca queda boca abajo o invertido

\- ✅ \*\*Cero intervención manual\*\*: La corrección es completamente automática

\- ✅ \*\*Mantiene funcionalidad\*\*: Todas las características de P1.01 siguen disponibles

\- ✅ \*\*Feedback claro\*\*: Informa al usuario cuando se aplica corrección

\- ✅ \*\*Profesional\*\*: Los planos siempre tienen bloques uniformemente orientados



\*\*Cuándo usar esta variante\*\*:

\- Para trabajos con bloque LA donde no se necesita posicionamiento automático

\- Especialmente útil cuando las polilíneas tienen diferentes orientaciones

\- Ideal para proyectos donde la legibilidad de planos es crítica



\##### Mario/P1.03.lsp (Versión Reconstruida con Posicionamiento Inteligente) ⭐ ACTUAL



\*\*Propósito\*\*: Posicionamiento automático inteligente del bloque LA basado en coordenada X del vértice



\*\*Mejora principal respecto a P1.02\*\*:



\- \*\*Posicionamiento automático basado en vértice izquierdo/derecho\*\*: El sistema detecta automáticamente si el vértice es el izquierdo o derecho de la polilínea y ajusta el punto de inserción en consecuencia

\- \*\*Lógica basada en coordenada X\*\*: Usa la coordenada X del vértice para determinar si es izquierdo (X menor) o derecho (X mayor)

\- \*\*Desplazamiento condicional\*\*: Solo desplaza el punto de inserción cuando es necesario (vértice derecho)



\*\*Características del bloque LA\*\*:

&nbsp;   - Longitud: 0.60 metros

&nbsp;   - Punto de inserción: Esquina inferior izquierda

&nbsp;   - Desplazamiento: 0.65m hacia atrás para vértices derechos

&nbsp;   - Orientación: Siempre de izquierda a derecha, nunca boca abajo



\*\*Nueva funcionalidad técnica\*\*:



1\. \*\*Detección de vértice izquierdo/derecho por coordenada X\*\*:

&nbsp;   - Calcula X mínima y X máxima de todos los vértices de la polilínea

&nbsp;   - Compara la X del punto de inserción con xMin y xMax

&nbsp;   - Si está más cerca de xMin → vértice IZQUIERDO

&nbsp;   - Si está más cerca de xMax → vértice DERECHO



2\. \*\*Posicionamiento condicional\*\*:

&nbsp;   - \*\*Vértice IZQUIERDO\*\*: Punto de inserción exactamente EN el vértice (sin desplazamiento)

&nbsp;   - \*\*Vértice DERECHO\*\*: Punto de inserción desplazado 0.65m en dirección (ángulo + 180°)

&nbsp;   - Resultado: Ambos bloques quedan "dentro" de la polilínea, cerca del círculo/pozo



3\. \*\*Cálculo de ángulo unificado\*\*:

&nbsp;   - Calcula la tangente de la polilínea en el extremo

&nbsp;   - Ambos bloques (izquierdo y derecho) usan el mismo ángulo de la polilínea

&nbsp;   - Corrección automática si el ángulo está entre 90°-270° (suma 180° para legibilidad)



4\. \*\*Mensajes informativos detallados\*\*:

&nbsp;   - Muestra ángulo base de la polilínea

&nbsp;   - Indica si se aplicó corrección para legibilidad

&nbsp;   - Informa si es vértice izquierdo o derecho

&nbsp;   - Confirma el desplazamiento aplicado



\*\*Flujo de trabajo\*\*:

1\. Solicita datos manualmente (cota tapa, profundidad, diámetro, número de tubos)

2\. Usuario hace click EN el vértice (con OSNAP activado)

3\. Sistema detecta automáticamente la polilínea 3D

4\. Ajusta Z del vértice al valor calculado

5\. \*\*Calcula el ángulo base de la polilínea\*\*

6\. \*\*Corrige el ángulo para legibilidad si es necesario\*\*

7\. Usuario define punto de inserción

8\. \*\*Sistema detecta si es vértice IZQUIERDO o DERECHO por coordenada X\*\*

9\. \*\*Aplica desplazamiento condicional (solo para vértice derecho)\*\*

10\. Inserta bloque "LA" con atributos rellenos y orientación correcta



\*\*Tabla de comportamiento\*\*:



| Vértice | Coordenada X | Punto de inserción | Desplazamiento | Resultado |
|---------|--------------|-------------------|----------------|-----------|
| IZQUIERDO | X menor (más cerca de xMin) | EN el vértice | ❌ Ninguno | Bloque se extiende hacia la derecha, queda dentro |
| DERECHO | X mayor (más cerca de xMax) | Desplazado 0.65m | ✅ -0.65m hacia atrás | Bloque se extiende hacia la derecha, termina en el vértice |



\*\*Ventajas clave de P1.03\*\*:

\- ✅ \*\*Posicionamiento perfecto\*\*: Todos los bloques quedan "dentro" de sus polilíneas

\- ✅ \*\*Lógica robusta\*\*: Basada en coordenadas X, no en índices de vértices

\- ✅ \*\*Dos bloques por polilínea\*\*: Funciona perfectamente para insertar bloques en ambos extremos

\- ✅ \*\*Orientación consistente\*\*: Todos los bloques apuntan en la misma dirección que su polilínea

\- ✅ \*\*Siempre legible\*\*: Corrección automática para lectura de izquierda a derecha

\- ✅ \*\*Feedback claro\*\*: Mensajes detallados sobre cada decisión del sistema



\*\*Cuándo usar esta variante\*\*:

\- \*\*RECOMENDADA\*\* para todos los trabajos con bloque LA

\- Ideal cuando se insertan 2 bloques por polilínea (uno en cada extremo)

\- Perfecta para pozos con múltiples polilíneas radiales

\- Especialmente útil para mantener todos los bloques cerca del pozo central



\*\*Requisitos\*\*:

\- Bloque "LA" con atributos RESULTADO, DIAMETRODELTUBO, NUMERODETUBOS

\- Al menos una polilínea 3D dibujada por cada tubo

\- ⚠️ \*\*OSNAP activado\*\*: Fundamental para detección de vértices



\##### Victor/P1.lsp (Variante Intermedia)



Similar a Mario/P1.01.lsp pero para el bloque "POZO" con atributo "DIAMETRODETUBO" estándar. Representa una versión de transición que combina características de v1.0 y v2.1.



\##### Estructura del Proyecto



```
POZOS/
├── P1.0.lsp              # Versión 1.0 (base histórica)
├── P1\_v1.2.lsp           # Versión 1.2 (entrada manual múltiple)
├── P1\_v2.0.lsp           # Versión 2.0 (carga CSV)
├── P1\_v2.1.lsp           # Versión 2.1 (detección automática) ⭐ RECOMENDADA
├── Mario/
│   ├── P1.01.lsp         # Variante con bloque LA
│   ├── P1.02.lsp         # Variante con orientación corregida
│   └── P1.03.lsp         # Variante con posicionamiento inteligente ⭐ ACTUAL
├── Victor/
│   └── P1.lsp            # Variante intermedia con bloque POZO
├── Bloques/
│   └── LA.dwg            # Archivo de bloque LA
└── 1\_datos\_brutos/
    ├── PRIMERA\_PASADA.txt
    ├── SEGUNDA\_PASADA.txt
    ├── CROQUIS\_AUTOCAD.txt
    └── README.txt
```



\*\*Recomendaciones de uso\*\*:

\- \*\*Para proyectos grandes con CSV\*\*: Usar P1\_v2.1.lsp (carpeta raíz)

\- \*\*Para entrada manual rápida con bloque LA\*\*: Usar Mario/P1.03.lsp (con posicionamiento inteligente) ⭐ RECOMENDADA

\- \*\*Para entrada manual con bloque POZO\*\*: Usar Victor/P1.lsp

\- \*\*Para trabajo colaborativo\*\*: Las variantes en carpetas Mario/ y Victor/ están diseñadas para usuarios específicos



\*\*📌 Versión en uso actualmente\*\*: **Mario/P1.03.lsp** (bloque LA, entrada manual con detección automática de vértice, orientación corregida y posicionamiento inteligente basado en coordenada X)



---



\## 📦 Información de Bloques AutoCAD



El proyecto utiliza bloques con atributos dinámicos para representar pozos/arquetas en AutoCAD:



\### Bloque POZO (Estándar)

\- \*\*Nombre del bloque\*\*: "POZO"

\- \*\*Atributos\*\*:

&nbsp;   - \`RESULTADO\`: Cota del tubo (calculada automáticamente)

&nbsp;   - \`DIAMETRODETUBO\`: Diámetro del tubo en cm

&nbsp;   - \`NUMERODETUBOS\`: Total de tubos del pozo

\- \*\*Usado en\*\*: P1.0.lsp, P1\_v1.2.lsp, P1\_v2.0.lsp, P1\_v2.1.lsp, Victor/P1.lsp



\### Bloque LA (Variante)

\- \*\*Nombre del bloque\*\*: "LA"

\- \*\*Atributos\*\*:

&nbsp;   - \`RESULTADO\`: Cota del tubo (calculada automáticamente)

&nbsp;   - \`DIAMETRODELTUBO\`: Diámetro del tubo en cm (nota: "DEL" en lugar de "DE")

&nbsp;   - \`NUMERODETUBOS\`: Total de tubos del pozo

\- \*\*Usado en\*\*: Mario/P1.01.lsp

\- \*\*Ubicación\*\*: Bloques/LA.dwg



\*\*Diferencia clave\*\*: El atributo del diámetro tiene nombres ligeramente diferentes: "DIAMETRODETUBO" (POZO) vs "DIAMETRODELTUBO" (LA).



---

