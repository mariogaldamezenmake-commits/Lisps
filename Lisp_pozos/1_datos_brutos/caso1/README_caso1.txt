================================================================================
                    CASO 1 - RED DE SANEAMIENTO LINEAL
================================================================================

DESCRIPCIÓN:
Red de saneamiento (fecal) con topología LINEAL de 5 pozos interconectados
en secuencia. Incluye 1 pozo de arranque, pozos intermedios, acometidas
laterales y flujo por gravedad descendente.

TOPOLOGÍA:
P001 → P002 → P003 → P004 → P005
  ↓      ↓      ↓ (3 acometidas laterales)

CARACTERÍSTICAS:
- Tipo de red: FECAL (saneamiento)
- Pozos: 5 (P001-P005)
- Tubos totales: 12 (colectores + acometidas)
- Colector principal: Ø30cm
- Acometidas: Ø20cm
- P001: Pozo de arranque (solo salida)
- P002, P004: Pozos intermedios (entrada + salida)
- P003: Pozo con 1 acometida lateral
- P005: Pozo final con 2 acometidas laterales

ARCHIVOS:
- PRIMERA_PASADA.txt: Coordenadas planialtéricase (5 pozos)
- SEGUNDA_PASADA.txt: Caracterización de tubos (12 registros)
- CROQUIS_AUTOCAD.txt: Esquema visual y datos para dibujo

OPERADOR: JMS (Juan Martínez Sánchez)
FECHAS:
- Primera pasada: 15/10/2024
- Segunda pasada: 22/10/2024

USO:
Este caso representa una red típica de saneamiento urbano con flujo
gravitacional en secuencia lineal con derivaciones.
