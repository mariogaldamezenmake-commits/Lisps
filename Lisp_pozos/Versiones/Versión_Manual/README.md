# 🖊️ Versión Manual - Variantes con Bloque LA

Esta carpeta contiene variantes del comando P1 que utilizan **entrada manual de datos** y el **bloque LA** en lugar del bloque POZO estándar.

Estas versiones están diseñadas para usuarios específicos y proyectos que requieren el bloque LA con características particulares.

---

## ⭐ Versión Recomendada

### **P1.03.lsp** - Posicionamiento Inteligente

**Fecha:** Noviembre 2024
**Estado:** ✅ Producción (versión actual)
**Uso recomendado:** Todos los trabajos con bloque LA

#### Características Principales

##### 🎯 Posicionamiento Automático Inteligente
- **Detección por coordenada X:** Sistema identifica automáticamente si el vértice es izquierdo o derecho
- **Vértice IZQUIERDO (X menor):** Punto de inserción exactamente EN el vértice (sin desplazamiento)
- **Vértice DERECHO (X mayor):** Punto de inserción desplazado 0.65m hacia atrás
- **Resultado:** Ambos bloques quedan "dentro" de la polilínea, cerca del pozo central

##### 📐 Orientación Inteligente
- **Cálculo de ángulo base** según tangente de la polilínea
- **Corrección automática:** Si ángulo está entre 90°-270°, suma 180° para legibilidad
- **Siempre legible:** Bloques nunca quedan boca abajo o invertidos
- **Orientación consistente:** Todos los bloques apuntan en dirección de su polilínea

##### 🔍 Detección Automática
- **Búsqueda eficiente** de polilínea 3D por OSNAP
- **Usuario solo hace click EN el vértice**
- Sistema detecta automáticamente qué polilínea corresponde
- **Cero errores de selección**

#### Especificaciones del Bloque LA
- **Longitud:** 0.60 metros
- **Punto de inserción:** Esquina inferior izquierda
- **Desplazamiento (vértice derecho):** 0.65m hacia atrás
- **Atributos:**
  - `RESULTADO`: Cota del tubo (calculada)
  - `DIAMETRODELTUBO`: Diámetro en cm (nota: "DEL" en lugar de "DE")
  - `NUMERODETUBOS`: Cantidad total de tubos

#### Flujo de Trabajo
1. Ejecutar comando `P1`
2. Introducir datos manualmente:
   - Cota de la tapa (Z)
   - Profundidad del tubo (desde tapa hasta parte baja del agujero)
   - Diámetro del tubo (cm)
   - Número total de tubos
3. Click EN el vértice (con OSNAP activado)
   - Sistema detecta automáticamente la polilínea 3D
   - Sistema ajusta Z del vértice a la cota calculada
   - Sistema calcula ángulo y aplica corrección si es necesario
4. Click para punto de inserción del bloque
   - Sistema detecta si es vértice izquierdo o derecho por coordenada X
   - Sistema aplica desplazamiento condicional
   - Sistema inserta bloque LA con orientación correcta

#### Ventajas Clave
- ✅ **Posicionamiento perfecto:** Todos los bloques quedan "dentro" de sus polilíneas
- ✅ **Lógica robusta:** Basada en coordenadas X, no en índices de vértices
- ✅ **Dos bloques por polilínea:** Funciona perfectamente para ambos extremos
- ✅ **Orientación consistente:** Todos apuntan en la misma dirección que su polilínea
- ✅ **Siempre legible:** Corrección automática para lectura de izquierda a derecha
- ✅ **Feedback claro:** Mensajes detallados sobre cada decisión del sistema

#### Casos de Uso
- ✅ **RECOMENDADO** para todos los trabajos con bloque LA
- ✅ Ideal cuando se insertan 2 bloques por polilínea (uno en cada extremo)
- ✅ Perfecta para pozos con múltiples polilíneas radiales
- ✅ Especialmente útil para mantener todos los bloques cerca del pozo central

---

## 📚 Versiones Anteriores

### **P1.02.lsp** - Orientación Corregida

**Fecha:** Noviembre 2024
**Estado:** ⚠️ Deprecada (usar P1.03)

#### Características
- ✅ Entrada manual de datos
- ✅ Detección automática de polilínea 3D por OSNAP
- ✅ Orientación corregida para legibilidad
- ⚠️ **SIN posicionamiento automático:** Usuario define punto de inserción
- ✅ Corrección automática si ángulo está entre 90°-270°

#### Mejora Principal vs P1.01
- **Orientación inteligente:** Bloque LA siempre se lee de izquierda a derecha
- **Función `_normalize-angle`:** Normaliza ángulos al rango [0, 2π)
- **Corrección automática:** Suma 180° cuando el bloque quedaría invertido
- **Feedback informativo:** Indica cuando se aplica corrección de orientación

#### Por qué actualizar a P1.03
- P1.03 añade posicionamiento automático inteligente
- Ya no necesitas calcular manualmente dónde insertar el bloque
- Sistema detecta automáticamente si es vértice izquierdo o derecho
- Bloques siempre quedan en la posición óptima

---

### **P1.01.lsp** - Base con Bloque LA

**Fecha:** Noviembre 2024
**Estado:** 📦 Archivada

#### Características
- ✅ Entrada manual de datos (uno por uno)
- ✅ Detección automática de vértice por OSNAP
- ✅ Base de código combina v1.0 + v2.1
- ⚠️ **SIN corrección de orientación:** Bloques pueden quedar invertidos
- ⚠️ **SIN posicionamiento automático**

#### Limitaciones
- ⚠️ Bloques pueden quedar boca abajo en polilíneas con ciertas orientaciones
- ⚠️ Usuario debe calcular manualmente el punto de inserción óptimo
- ⚠️ Puede requerir rotaciones manuales posteriores

#### Cuándo usar
- Solo para mantener compatibilidad con proyectos antiguos
- **NO RECOMENDADA** para nuevos trabajos (usar P1.03)

---

## 📊 Comparación de Versiones

| Característica | P1.01 | P1.02 | P1.03 ⭐ |
|---------------|-------|-------|---------|
| **Entrada de datos** | Manual 1x1 | Manual 1x1 | Manual 1x1 |
| **Bloque usado** | LA | LA | LA |
| **Detección polilínea** | ✅ Automática | ✅ Automática | ✅ Automática |
| **Detección vértice** | ✅ OSNAP | ✅ OSNAP | ✅ OSNAP |
| **Corrección orientación** | ❌ No | ✅ Sí (90°-270°) | ✅ Sí (90°-270°) |
| **Posicionamiento auto** | ❌ No | ❌ No | ✅ Sí (por coord X) |
| **Desplazamiento inteligente** | ❌ No | ❌ No | ✅ Sí (vértice derecho) |
| **Bloques siempre legibles** | ❌ No | ✅ Sí | ✅ Sí |
| **Bloques siempre "dentro"** | ❌ No | ❌ No | ✅ Sí |
| **Tiempo/tubo** | ~1 min | ~50 seg | ⚡ ~40 seg |
| **Facilidad de uso** | Media | Media | ✅ Alta |
| **Resultado profesional** | Medio | Alto | ✅ Excelente |

---

## 🎯 Tabla de Comportamiento (P1.03)

### Posicionamiento por Coordenada X

| Vértice | Coordenada X | Punto de Inserción | Desplazamiento | Resultado Visual |
|---------|--------------|-------------------|----------------|------------------|
| **IZQUIERDO** | X menor (más cerca de xMin) | EN el vértice | ❌ Ninguno | Bloque se extiende hacia la derecha → |
| **DERECHO** | X mayor (más cerca de xMax) | Desplazado 0.65m atrás | ✅ -0.65m | Bloque termina en el vértice ← |

### Orientación por Ángulo

| Ángulo Original | Rango | ¿Se corrige? | Acción | Resultado |
|----------------|-------|--------------|--------|-----------|
| 0° - 90° | Primer cuadrante | ❌ No | Mantiene | Bloque legible ↗ |
| 90° - 180° | Segundo cuadrante | ✅ Sí | +180° | Bloque invertido para legibilidad ↘ |
| 180° - 270° | Tercer cuadrante | ✅ Sí | +180° | Bloque invertido para legibilidad ↗ |
| 270° - 360° | Cuarto cuadrante | ❌ No | Mantiene | Bloque legible ↘ |

---

## 🔧 Requisitos Técnicos

### Para todas las versiones
- **AutoCAD:** 2026 (compatible con versiones anteriores)
- **Bloque LA** con atributos:
  - `RESULTADO`: Cota del tubo
  - `DIAMETRODELTUBO`: Diámetro del tubo (nota: "DEL" vs "DE")
  - `NUMERODETUBOS`: Total de tubos
- **OSNAP activado:** Endpoint, Vertex, Node (⚠️ FUNDAMENTAL)
- **Polilíneas 3D:** Al menos una por tubo antes de ejecutar

### Archivo del bloque
- **Ubicación recomendada:** `../../../bloques/LA.dwg`
- **Formato:** DWG de AutoCAD
- **Atributos:** Deben estar exactamente como se especifica

---

## 🚀 ¿Qué Versión Usar?

```
┌─────────────────────────────────────┐
│ ¿Usas el bloque LA?                 │
└──────────┬──────────────────────────┘
           │
         SÍ
           │
           ▼
    ┌──────────────┐
    │   P1.03      │  ⭐ SIEMPRE RECOMENDADA
    │              │
    │ • Posición   │
    │ • Orientación│
    │ • Detección  │
    └──────────────┘
```

**🎯 Conclusión:** Si necesitas trabajar con el bloque LA, **usa directamente P1.03**. No hay ninguna razón para usar las versiones anteriores excepto compatibilidad con proyectos muy antiguos.

---

## 🔄 Migración entre Versiones

### De P1.01 a P1.02
- **Beneficio:** Bloques siempre legibles
- **Cambio:** Automático, solo actualiza el archivo .lsp
- **Compatibilidad:** 100%, mismos requisitos

### De P1.02 a P1.03
- **Beneficio:** Posicionamiento automático perfecto
- **Cambio:** Automático, solo actualiza el archivo .lsp
- **Compatibilidad:** 100%, mismos requisitos
- **Resultado:** Ya no necesitas pensar dónde insertar, sistema lo calcula

---

## 🔗 Ver También

- **[../](../)** - Versiones con lectura CSV
- **[../../CLAUDE.md](../../CLAUDE.md)** - Documentación técnica completa del proyecto
- **[../../README.md](../../README.md)** - Inicio rápido

---

## 📝 Diferencias con Versiones CSV

### Bloque LA vs POZO
| Aspecto | Bloque LA (Versión Manual) | Bloque POZO (Versión CSV) |
|---------|---------------------------|---------------------------|
| **Nombre** | LA | POZO |
| **Atributo diámetro** | DIAMETRODELTUBO (con "DEL") | DIAMETRODETUBO (con "DE") |
| **Entrada datos** | Manual | CSV automático |
| **Posicionamiento** | Inteligente por coord X | Según tangente |
| **Casos de uso** | Proyectos pequeños/medianos | Proyectos grandes |

---

**💡 Consejo:** Para proyectos nuevos con bloque LA, carga **P1.03.lsp** y disfruta del posicionamiento automático y orientación perfecta.

**⚠️ Importante:** NO olvides activar OSNAP (Endpoint, Vertex, Node) antes de usar cualquiera de estas versiones.
