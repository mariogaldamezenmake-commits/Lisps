# Manual de Uso - EncajarPlanos LISP (Simplificado)

Este script alinea un plano (bloque) sobre otro utilizando 2 puntos de referencia, ajustando automáticamente la posición, rotación y escala.

## Requisitos Previos
1. **Abrir AutoCAD**.
2. **Tener ambos planos en el mismo dibujo**:
   - El **Plano Origen** debe estar en su posición correcta.
   - El **Plano a Encajar** debe estar insertado en el dibujo (como bloque o conjunto de objetos), en cualquier lugar.

## Instrucciones

1. Cargue el lisp con `APPLOAD`.
2. Escriba el comando `EncajarPlanos`.
3. **Seleccione los objetos a encajar**: Seleccione todos los elementos del plano que desea mover (líneas, textos, bloques, etc.).
   - El script los convertirá automáticamente en un bloque temporal para poder moverlos todos juntos.
4. **Defina los Puntos de Encaje**:
   - **Punto 1 Origen**: Clic en un punto del bloque que va a mover.
   - **Punto 1 Destino**: Clic en el punto correspondiente del plano base.
   - **Punto 2 Origen**: Clic en otro punto del bloque que va a mover.
   - **Punto 2 Destino**: Clic en el punto correspondiente del plano base.
5. **Resultado**:
   - El script moverá, rotará y escalará el bloque seleccionado para que los puntos coincidan.
   - **Nota**: El script fuerza el cálculo en 2D (Z=0), por lo que no importa si selecciona puntos con altura.

## Ubicación
`C:\Users\Usuario\Desktop\Modo_Desarrollador\Lisps\Lisp_Encaje_Planos\encajar_planos.lsp`