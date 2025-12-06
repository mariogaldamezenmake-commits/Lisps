# 🚰 Proyecto POZOS - Automatización de Levantamiento Topográfico

> **Sistema automatizado para digitalización de pozos y arquetas en AutoCAD mediante AutoLISP**

[![AutoCAD](https://img.shields.io/badge/AutoCAD-2026-blue.svg)](https://www.autodesk.com/products/autocad/)
[![AutoLISP](https://img.shields.io/badge/AutoLISP-Latest-green.svg)](https://www.autodesk.com/developer-network/platform-technologies/autolisp)

---

## 📖 Descripción

Este proyecto contiene herramientas AutoLISP para automatizar el proceso de digitalización de levantamientos topográficos de redes de saneamiento, pluviales y otras infraestructuras subterráneas.

El flujo de trabajo abarca desde la **captura de datos en campo** (coordenadas, profundidades, diámetros) hasta la **generación automática de planos en AutoCAD** con bloques parametrizados y polilíneas 3D ajustadas a las cotas reales.

## 🚀 Inicio Rápido

### Versiones Recomendadas

| Versión | Uso | Archivo |
|---------|-----|---------|
| **v2.1** ⭐ | Lectura automática desde CSV | `Versiones/P1_v2.1.lsp` |
| **P1.03** ⭐ | Entrada manual con bloque LA | `Versiones/Versión_Manual/P1.03.lsp` |

### Instalación

1. **Carga el script en AutoCAD:**
   ```
   (load "C:/ruta/a/P1_v2.1.lsp")
   ```

2. **Ejecuta el comando:**
   ```
   P1
   ```

3. **Sigue las instrucciones en pantalla**

## 📂 Estructura del Proyecto

```
POZOS/
├── README.md                    # 📖 Este archivo
├── CLAUDE.md                    # 📚 Documentación técnica completa
├── Versiones/                   # 🔄 Scripts AutoLISP
│   ├── P1_v2.1.lsp             # ⭐ Versión con CSV + detección automática
│   ├── P1_v2.0.lsp             # Versión con CSV
│   ├── P1_v1.2.lsp             # Versión con entrada múltiple
│   ├── P1.0.lsp                # Versión inicial
│   └── Versión_Manual/         # Variantes con entrada manual
│       ├── P1.03.lsp           # ⭐ Posicionamiento inteligente
│       ├── P1.02.lsp           # Orientación corregida
│       └── P1.01.lsp           # Base manual
├── 1_datos_brutos/             # 📊 Archivos CSV de ejemplo
│   ├── PRIMERA_PASADA.txt      # Coordenadas X,Y,Z de tapas
│   ├── SEGUNDA_PASADA.txt      # Características de pozos y tubos
│   └── CROQUIS_AUTOCAD.txt     # Croquis de conexiones
└── Dibujo_Para_Pruebas/        # 🧪 Dibujos .dwg para testing
```

## ✨ Características Principales

### P1_v2.1 (Versión CSV Recomendada)

- ✅ **Lectura automática** desde archivos CSV
- ✅ **Detección automática** de polilíneas 3D cercanas
- ✅ **Ajuste automático** de cotas Z en vértices
- ✅ **Inserción masiva** de bloques con atributos
- ✅ **Cálculo automático** de cota_tubo = cota_tapa - profundidad
- ✅ **Orientación inteligente** según tangente de polilínea

### P1.03 (Versión Manual Recomendada)

- ✅ **Entrada manual** de datos (cota, profundidad, diámetro)
- ✅ **Detección automática** de polilínea 3D por OSNAP
- ✅ **Posicionamiento inteligente** basado en coordenada X
- ✅ **Orientación corregida** (siempre legible de izquierda a derecha)
- ✅ **Bloque LA** con atributos personalizados

## 📋 Requisitos

- **AutoCAD 2026** (compatible con versiones anteriores)
- **Bloques AutoCAD:**
  - `POZO` con atributos: `RESULTADO`, `DIAMETRODETUBO`, `NUMERODETUBOS`
  - `LA` con atributos: `RESULTADO`, `DIAMETRODELTUBO`, `NUMERODETUBOS`
- **OSNAP activado** (Endpoint, Vertex, Node)
- **Archivos CSV** (para versiones v2.x):
  - `PRIMERA_PASADA.txt`
  - `SEGUNDA_PASADA.txt`

## 📚 Documentación Completa

Lee **[CLAUDE.md](./CLAUDE.md)** para:

- 📍 Proceso completo de levantamiento en campo
- 🔍 Metodología de caracterización de pozos
- 🛠️ Guía detallada de cada versión del script
- 💼 Flujo de trabajo en gabinete
- 🤖 Documentación técnica de funciones

## 🔄 Evolución del Proyecto

| Versión | Fecha | Características Principales |
|---------|-------|----------------------------|
| **v1.0** | Oct 2024 | Inserción individual con entrada manual |
| **v1.2** | Oct 2024 | Procesamiento múltiple en lote |
| **v2.0** | Oct 2024 | Lectura automática desde CSV |
| **v2.1** | Oct 2024 | Detección automática de polilíneas ⭐ |
| **P1.03** | Nov 2024 | Posicionamiento inteligente con bloque LA ⭐ |

## 🎯 Flujo de Trabajo Típico

### Con archivos CSV (v2.1)

1. **Campo:** Registrar datos en `PRIMERA_PASADA.txt` y `SEGUNDA_PASADA.txt`
2. **AutoCAD:** Dibujar polilíneas 3D aproximadas para cada tubo
3. **Ejecutar:** Comando `P1`
4. **Seleccionar:** Archivo `SEGUNDA_PASADA.txt`
5. **Interacción:** Para cada tubo:
   - Click en vértice de polilínea (sistema detecta automáticamente)
   - Click para insertar bloque POZO
6. **Resultado:** Polilíneas ajustadas + bloques insertados con atributos

### Con entrada manual (P1.03)

1. **AutoCAD:** Dibujar polilíneas 3D para cada tubo
2. **Ejecutar:** Comando `P1`
3. **Introducir:** Datos del pozo (cota tapa, profundidad, diámetro, tubos)
4. **Click:** En vértice de polilínea (con OSNAP)
5. **Click:** Punto de inserción del bloque LA
6. **Repetir:** Para cada tubo adicional

## 🤝 Contribuir

Este proyecto está en desarrollo activo. Para mejoras o reportar bugs:

1. Crea un issue describiendo el problema
2. Propón cambios mediante pull requests
3. Consulta la documentación completa en [CLAUDE.md](./CLAUDE.md)

## 📄 Licencia

Proyecto desarrollado para uso interno en levantamientos topográficos.

---

**💡 Tip:** Para proyectos grandes (10+ pozos), usa la versión v2.1 con CSV. Para trabajos rápidos (1-5 pozos), usa P1.03 con entrada manual.

**⚠️ Importante:** Asegúrate de tener OSNAP activado (Endpoint, Vertex, Node) para el correcto funcionamiento de todas las versiones.
