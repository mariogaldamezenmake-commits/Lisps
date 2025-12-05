# Encajar Planos v3.5

## Descripción
Esta rutina LISP automatiza el proceso de encajar un plano (Plano a Encajar) sobre otro (Plano Origen) mediante alineación y escala automática.

**Comando:** `EncajarPlanos35`

## Novedades v3.5
-   **Reset a Capa 0**: Tras procesar el plano origen, la capa activa vuelve automáticamente a la capa "0" para evitar insertar el plano destino en capas incorrectas.
-   **Sin cambios de capa en destino**: El plano a encajar mantiene sus capas y colores originales.

## Instrucciones de Uso

1.  **Cargar el LISP**: Arrastra el archivo a AutoCAD o usa el comando `APPLOAD`.
2.  **Ejecutar**: Escribe `EncajarPlanos35` y pulsa Intro.
3.  **Seleccionar Plano Origen**:
    -   Selecciona las entidades del plano base.
    -   El script las moverá a la capa "PlanoOrigen" (Color Magenta) y las explotará si es necesario.
    -   *La capa activa cambiará automáticamente a "0".*
4.  **Seleccionar Plano a Encajar**:
    -   Selecciona las entidades del plano que quieres alinear.
    -   Se convertirán en un bloque temporal para facilitar la manipulación.
5.  **Definir Puntos**:
    -   Sigue las instrucciones en pantalla para marcar 2 puntos en el plano a encajar y sus correspondientes en el plano origen.
6.  **Resultado**:
    -   El plano se moverá, rotará y escalará automáticamente para encajar.

## Historial
-   **v3.5**: Vuelta a capa 0 tras origen. Mensajes amigables.
-   **v3.0**: Versión previa con lógica base.
