# Encajar Planos v3.5

Lisp para encajar planos de forma automática (hace alineación y escala a la vez).

**Comando:** `EncajarPlanos35`

## ¿Qué hay de nuevo en la 3.5?
Básicamente he arreglado lo de las capas que molestaba en las versiones anteriores:
1.  **Vuelta a Capa 0**: Después de procesar el "Plano Origen", el Lisp te devuelve automáticamente a la capa "0". Así no metes el bloque nuevo en la capa magenta por error.
2.  **Colores originales**: El plano que vas a encajar SE QUEDA COMO ESTÁ. No le cambia ni capas ni colores, solo lo convierte en bloque para moverlo fácil.

## Cómo funciona

1.  Carga el Lisp (`EncajarPlanos35` o arrastrar).
2.  **Selecciona plano ORIGEN**: El de base. Se pasa a su capa y se explota.
3.  **Selecciona plano A ENCAJAR**: El nuevo. Se hace bloque pero conserva sus propiedades.
4.  **Puntos de referencia**:
    *   Punto 1 en el plano a encajar -> Punto 1 en el origen.
    *   Punto 2 en el plano a encajar -> Punto 2 en el origen.
5.  Listo. Se mueve, gira y escala solo.
