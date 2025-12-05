# Encajar Planos v1.5

Esta versión es una variante de la v1.0 (Modo Simplificado) con modificaciones específicas para mejorar la rapidez de uso y eliminar decisiones obvias.

## Características

- **Sin preguntas de escala**: El script asume automáticamente que el plano origen (destino) tiene la escala correcta. Al alinear, el objeto siempre se escalará para coincidir con los puntos seleccionados en el origen ("el plano origen siempre manda").
- **Prompts Directos**: Mensajes más cortos y directos para agilizar el proceso ("Selecciona y dale a intro").
- **Flujo Simplificado**:
  1. Seleccionar objetos a encajar.
  2. Seleccionar Punto 1 en objeto a encajar.
  3. Seleccionar Punto 1 destino en origen.
  4. Seleccionar Punto 2 en objeto a encajar.
  5. Seleccionar Punto 2 destino en origen.
  6. ¡Listo! (Alineación y escalado automático).

## Mejoras Respecto a v1.0
- Se elimina la pregunta final "¿Desea atribuir una escala a los objetos basándose en los puntos de alineación?". Se responde "Sí" automáticamente.
- Textos de ayuda modificados a petición del usuario para ser más intuitivos.
