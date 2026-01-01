import os
import sys

def procesar_txt_v2(archivo_entrada, archivo_salida):
    """
    Versión 2:
    - No requiere 'F' en el archivo de entrada.
    - Detecta secuencias de códigos iguales.
    - Si hay > 1 punto con mismo código seguido:
      - Primero -> Añade 'C'
      - Último -> Añade 'F'
    - Si es un punto aislado (sin igual anterior ni posterior), NO añade nada.
    """
    lineas = []
    
    # 1. Leer archivo
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f:
            for raw_linea in f:
                linea = raw_linea.strip()
                if not linea: continue
                campos = linea.split(',')
                if len(campos) < 1: continue 
                lineas.append(campos)
    except FileNotFoundError:
         print(f"ERROR: No se encontró el archivo '{archivo_entrada}'")
         return

    if not lineas:
        print("Archivo vacío.")
        return

    # 2. Agrupar por bloques consecutivos de mismo código
    bloques = []
    if not lineas: return

    bloque_actual = [lineas[0]]
    codigo_actual = lineas[0][-1].strip()

    for i in range(1, len(lineas)):
        campos = lineas[i]
        codigo = campos[-1].strip()
        
        if codigo == codigo_actual:
            bloque_actual.append(campos)
        else:
            # Fin del bloque anterior
            bloques.append(bloque_actual)
            # Inicio nuevo bloque
            bloque_actual = [campos]
            codigo_actual = codigo
    
    # Añadir el último bloque
    bloques.append(bloque_actual)

    # 3. Procesar bloques y generar salida
    lineas_procesadas = []

    for bloque in bloques:
        # Si el bloque tiene solo 1 elemento, es un punto aislado.
        # Regla: "que no le ponga F o C a un punto que no quiere ser una línea"
        if len(bloque) == 1:
            lineas_procesadas.append(bloque[0])
            continue
        
        # Si tiene más de 1 elemento, es una línea.
        # Primero -> C
        primero = bloque[0]
        primero[-1] = primero[-1].strip() + "C"
        lineas_procesadas.append(primero)

        # Intermedios
        for medio in bloque[1:-1]:
            lineas_procesadas.append(medio)
        
        # Último -> F
        ultimo = bloque[-1]
        ultimo[-1] = ultimo[-1].strip() + "F"
        lineas_procesadas.append(ultimo)

    # 4. Escribir salida
    with open(archivo_salida, 'w', encoding='utf-8') as f_out:
        for campos in lineas_procesadas:
            f_out.write(','.join(campos) + '\n')

    print(f"Procesado V2 (Automático) completado: {archivo_salida}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        entrada = sys.argv[1]
        folder = os.path.dirname(entrada)
        nombre = os.path.splitext(os.path.basename(entrada))[0]
        salida = os.path.join(folder, f"{nombre}_proc_v2.txt")
    else:
        entrada = "entrada_v2.txt"
        salida = "salida_v2.txt"

    if os.path.exists(entrada):
        procesar_txt_v2(entrada, salida)
    else:
        print(f"Pon un archivo llamado '{entrada}' junto al script o arrástralo encima.")
        input("Presiona Intro para salir...")
