# 🔄 Versiones del Comando P1

Esta carpeta contiene la evolución histórica del comando P1 para AutoCAD, desde la versión inicial hasta las versiones más avanzadas con lectura automática desde CSV.

---

## ⭐ Versión Recomendada

### **P1_v2.1.lsp** - Detección Automática + CSV

**Fecha:** Octubre 2024
**Estado:** ✅ Producción
**Uso recomendado:** Proyectos grandes con archivos CSV

#### Características
- ✅ Lectura automática desde `PRIMERA_PASADA.txt` y `SEGUNDA_PASADA.txt`
- ✅ Detección automática de polilínea 3D más cercana al click
- ✅ Identificación automática de vértice mediante OSNAP
- ✅ Ajuste automático de cota Z del vértice
- ✅ Inserción de bloque **POZO** con atributos calculados
- ✅ Orientación según tangente de la polilínea
- ✅ Procesamiento tubo por tubo con feedback informativo

#### Requisitos
- Archivos CSV en la misma carpeta
- Bloque `POZO` con atributos: `RESULTADO`, `DIAMETRODETUBO`, `NUMERODETUBOS`
- OSNAP activado (Endpoint, Vertex, Node)
- Al menos una polilínea 3D por tubo

#### Flujo de trabajo
1. Ejecutar comando `P1`
2. Seleccionar archivo `SEGUNDA_PASADA.txt`
3. Para cada tubo:
   - Ver información en pantalla
   - Click EN el vértice de la polilínea (OSNAP detecta)
   - Click para punto de inserción del bloque
4. Repetir automáticamente para todos los tubos del CSV

#### Ventajas vs v2.0
- ⚡ **Más rápido:** Un click menos por tubo
- ✅ **Cero errores:** No hay riesgo de seleccionar polilínea incorrecta
- 🎯 **Más intuitivo:** Solo click en vértice, sistema detecta todo

---

## 📚 Versiones Históricas

### **P1_v2.0.lsp** - Lectura CSV con Selección Manual

**Fecha:** Octubre 2024
**Estado:** ⚠️ Deprecada (usar v2.1)

#### Características
- ✅ Lectura automática desde CSV
- ⚠️ Requiere selección manual de polilínea
- ⚠️ Requiere click en extremo después de seleccionar
- ✅ Cálculo automático de cotas
- ✅ Inserción de bloque POZO

#### Por qué actualizar a v2.1
- v2.1 elimina el paso de seleccionar la polilínea manualmente
- Búsqueda optimizada por comparación de coordenadas exactas
- Menos propenso a errores de usuario

---

### **P1_v1.2.lsp** - Entrada Manual Múltiple

**Fecha:** Octubre 2024
**Estado:** 📦 Archivada

#### Características
- ✅ Procesamiento de múltiples pozos en una ejecución
- ✅ Entrada manual de datos en dos fases:
  - **Fase 1:** Recopilación de datos de TODOS los pozos
  - **Fase 2:** Inserción gráfica uno por uno
- ✅ Validaciones integradas (profundidad > 0, diámetro > 0, etc.)
- ✅ Mejor manejo de errores que v1.0

#### Ventajas
- Ideal para introducir datos mirando la libreta de campo
- Datos numéricos en lote, luego inserciones gráficas seguidas

#### Cuándo usar
- Cuando NO tienes archivos CSV
- Proyectos medianos (5-20 pozos)
- Prefieres verificar todos los datos antes de insertar

---

### **P1.0.lsp** - Versión Inicial

**Fecha:** Octubre 2024
**Estado:** 📦 Archivada (histórica)

#### Características
- ✅ Inserción de UN SOLO pozo por ejecución
- ✅ Entrada manual de datos: cota tapa, profundidad, diámetro, tubos
- ✅ Selección manual de polilínea 3D
- ✅ Selección manual de extremo
- ✅ Cálculo automático: `resultado = cota_tapa - profundidad`
- ✅ Inserción de bloque POZO con atributos
- ✅ Orientación según tangente

#### Limitaciones
- ⚠️ Solo procesa un pozo a la vez
- ⚠️ Hay que repetir el comando para cada pozo
- ⚠️ No lee datos desde CSV

#### Cuándo usar
- Proyectos muy pequeños (1-2 pozos)
- Cuando necesitas máximo control paso a paso
- Para entender la lógica base del sistema

---

## 📊 Comparación de Versiones

| Característica | v1.0 | v1.2 | v2.0 | v2.1 ⭐ |
|---------------|------|------|------|---------|
| **Entrada de datos** | Manual 1x1 | Manual múltiple | CSV | CSV |
| **Procesamiento** | Individual | Lote (2 fases) | Lote (CSV) | Lote (CSV) |
| **Selección polilínea** | Manual | Manual | Manual | ✅ Automática |
| **Selección vértice** | Click extremo | Click extremo | Click extremo | ✅ OSNAP auto |
| **Validaciones** | Básicas | Avanzadas | Avanzadas | Avanzadas |
| **Tiempo/tubo** | ~2 min | ~1 min | ~30 seg | ⚡ ~20 seg |
| **Propenso a errores** | Alto | Medio | Medio | ✅ Bajo |
| **Ideal para** | 1-2 pozos | 5-20 pozos | 10-100 pozos | 10-1000 pozos |

---

## 🎯 ¿Qué Versión Usar?

```
┌─────────────────────────────────────┐
│ ¿Tienes archivos CSV?               │
└──────────┬──────────────────────────┘
           │
    ┌──────┴──────┐
    │ SÍ          │ NO
    ▼             ▼
┌───────────┐  ┌─────────────────┐
│ P1_v2.1   │  │ ¿Cuántos pozos? │
│    ⭐      │  └────────┬────────┘
└───────────┘           │
                  ┌─────┴─────┐
                  │           │
                 1-5        5-20
                  │           │
                  ▼           ▼
            ┌──────────┐  ┌──────────┐
            │ P1.03    │  │ P1_v1.2  │
            │ (Manual) │  │ (Manual) │
            └──────────┘  └──────────┘
```

---

## 🚀 Migración entre Versiones

### De v1.0 a v1.2
- Mismo flujo, pero puedes procesar múltiples pozos
- Introduce todos los datos primero, luego inserta gráficamente

### De v1.2 a v2.0
- Crea archivos CSV con tus datos de campo
- Elimina entrada manual de datos
- Gana velocidad y reduce errores de transcripción

### De v2.0 a v2.1
- Mismos archivos CSV
- Elimina paso de selección manual de polilínea
- Solo haz click en el vértice con OSNAP activado

---

## 🔗 Ver También

- **[Versión_Manual/](./Versión_Manual/)** - Variantes con entrada manual y bloque LA
- **[../CLAUDE.md](../CLAUDE.md)** - Documentación técnica completa
- **[../README.md](../README.md)** - Inicio rápido del proyecto

---

## 📝 Notas Técnicas

### Bloque POZO - Atributos
Todas las versiones usan el mismo bloque con estos atributos:
- `RESULTADO`: Cota Z del fondo del tubo (calculada: cota_tapa - profundidad)
- `DIAMETRODETUBO`: Diámetro del tubo en cm
- `NUMERODETUBOS`: Cantidad total de tubos en el pozo

### Compatibilidad
- **AutoCAD:** 2026 (compatible con versiones anteriores)
- **Sistema:** Windows/Mac/Linux
- **Formato CSV:** UTF-8 con separador de coma (,)

---

**💡 Consejo Final:** Si estás empezando un nuevo proyecto, usa directamente **P1_v2.1.lsp**. Es la versión más optimizada y con menos margen de error.
