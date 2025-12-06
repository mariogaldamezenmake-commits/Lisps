============================================
DATOS BRUTOS - LEVANTAMIENTO TOPOGRÁFICO
============================================

Este directorio contiene datos en bruto obtenidos en campo durante el levantamiento de pozos.
Los datos están organizados por CASOS, cada uno representando una topología diferente de red.

============================================
ESTRUCTURA DE CARPETAS
============================================

📁 1_datos_brutos/
  📁 caso1/  → Red de saneamiento LINEAL (5 pozos)
  📁 caso2/  → Red pluvial RADIAL (7 pozos)

============================================
FORMATO DE ARCHIVOS
============================================

-------------------------------------------
PRIMERA_PASADA.txt / PRIMERA_PASADA_2.txt
-------------------------------------------
Levantamiento planialétrico y altimétrico
Una fila por pozo

Columnas:
1. ID_POZO          - Identificador único del pozo
2. X                - Coordenada X (centro de tapa)
3. Y                - Coordenada Y (centro de tapa)
4. Z                - Cota de la tapa (m)
5. FECHA            - Fecha levantamiento (YYYYMMDD)
6. OPERADOR         - Iniciales del técnico

-------------------------------------------
SEGUNDA_PASADA.txt / SEGUNDA_PASADA_2.txt
-------------------------------------------
Caracterización detallada de pozos y tubos
Una fila por tubo (los datos del pozo se repiten)

Columnas:
1. ID_POZO          - Referencia al pozo
2. TIPO_AGUA        - Tipo de servicio (pluvial/fecal/potable/acequia/telecom/electrica/no_se_sabe)
3. FORMA_TAPA       - Forma de la tapa (circular/cuadrada)
4. DIM_TAPA         - Dimensión de tapa: diámetro si circular, lado si cuadrada (cm)
5. PROF_ARENERO     - Profundidad total del pozo hasta arenero (m)
6. NUM_TUBO         - Número de orden del tubo (1, 2, 3...)
7. TOTAL_TUBOS      - Cantidad total de tubos en este pozo
8. TIPO_TUBO        - Tipo de tubo (colector_entrada/colector_salida/acometida/desconocido)
9. DIAM_TUBO        - Diámetro del tubo (cm)
10. PROF_TUBO       - Profundidad desde tapa hasta parte baja del agujero del tubo (m)
11. FECHA           - Fecha de caracterización (YYYYMMDD)
12. OPERADOR        - Iniciales del técnico

-------------------------------------------
CROQUIS_AUTOCAD.txt / CROQUIS_AUTOCAD_2.txt
-------------------------------------------
Esquema visual de la red con:
- Diagrama de topología
- Tabla de detalles por pozo
- Instrucciones para dibujo en AutoCAD
- Coordenadas 3D calculadas para polilíneas

============================================
DESCRIPCIÓN DE CASOS
============================================

┌────────┬──────────────┬───────┬───────┬──────────┬──────────────────┐
│  CASO  │   TOPOLOGÍA  │ POZOS │ TUBOS │   TIPO   │    DESCRIPCIÓN   │
├────────┼──────────────┼───────┼───────┼──────────┼──────────────────┤
│ caso1  │   LINEAL     │   5   │  12   │  FECAL   │ Red saneamiento  │
│        │              │       │       │          │ con acometidas   │
├────────┼──────────────┼───────┼───────┼──────────┼──────────────────┤
│ caso2  │   RADIAL     │   7   │  12   │ PLUVIAL  │ Red drenaje con  │
│        │              │       │       │          │ colector central │
└────────┴──────────────┴───────┴───────┴──────────┴──────────────────┘

-------------------------------------------
CASO 1: Red de saneamiento lineal
-------------------------------------------
- P001 → P002 → P003 → P004 → P005
- Pozo de arranque + pozos intermedios + acometidas laterales
- Flujo por gravedad descendente
- Colector principal Ø30cm, acometidas Ø20cm
- Operador: JMS | Fecha: Octubre 2024

-------------------------------------------
CASO 2: Red pluvial radial
-------------------------------------------
- 1 pozo central (P001) + 6 pozos periféricos (P002-P007)
- Todos los pozos periféricos drenan hacia el centro
- Topología simétrica tipo "estrella"
- Todos los colectores Ø40cm
- Operador: MGR | Fecha: Noviembre 2024

============================================
USO CON AUTOLISP
============================================

Estos archivos CSV están diseñados para ser procesados automáticamente
por los comandos P1 (versiones v2.0, v2.1) que leen:

1. PRIMERA_PASADA.txt → Obtiene coordenadas X,Y,Z de pozos
2. SEGUNDA_PASADA.txt → Obtiene datos de tubos y caracterización

El comando P1:
- Carga ambos archivos CSV
- Calcula cotas de tubos automáticamente
- Guía al usuario para ajustar polilíneas 3D
- Inserta bloques POZO/LA con atributos rellenos

============================================
COORDENADAS
============================================

Sistema: UTM (ficticias para ejemplos)
Zona: 30N (simulada)
Unidades: Metros

Nota: Las coordenadas son ficticias pero mantienen proporciones
y distancias realistas para fines de demostración y capacitación.

============================================
