import os
import sys

def procesar_txt_v1(archivo_entrada, archivo_salida):
    """
    Versión 1:
    - Asume que el usuario marca el FIN de línea con 'F' (ej: Muro1F).
    - El script detecta el INICIO de línea (cambio de código) y añade 'C' (ej: Muro1C).
    - Respeta las 'F' existentes.
    """
    lineas = []
    
    # 1. Leer archivo
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f:
            for raw_linea in f:
                linea = raw_linea.strip()
                if not linea: continue
                campos = linea.split(',')
                # Asegurar que hay al menos código
                if len(campos) < 1: continue 
                lineas.append(campos)
    except FileNotFoundError:
         print(f"ERROR: No se encontró el archivo '{archivo_entrada}'")
         return

    # 2. Procesar
    # Necesitamos saber cuándo CAMBIA el código para marcar el inicio (C)
    # y respetar si ya viene con F.
    
    lineas_procesadas = []
    ultimo_codigo_base = None

    for i, campos in enumerate(lineas):
        # Asumimos que el código está en la última posición
        codigo_actual = campos[-1].strip()
        
        # Extraer la base del código (quitar F si la tiene)
        # OJO: En V1, la F viene explícita.
        if codigo_actual.endswith('F') or codigo_actual.endswith('f'):
            tiene_fin = True
            codigo_base = codigo_actual[:-1]
        else:
            tiene_fin = False
            codigo_base = codigo_actual

        # Determinar si es INICIO (C)
        # Es inicio si el código base es diferente al anterior
        es_inicio = (codigo_base != ultimo_codigo_base)

        nuevo_codigo = codigo_base

        if es_inicio:
            nuevo_codigo += "C"
        
        if tiene_fin:
            nuevo_codigo += "F"

        # Actualizar campos
        campos[-1] = nuevo_codigo
        lineas_procesadas.append(campos)
        
        # Actualizar memoria para el siguiente loop
        # Si este punto tenía fin, el siguiente (si es igual) será un nuevo inicio hipotéticamente?
        # NO, si tiene fin, el siguiente ciclo el "ultimo_codigo_base" debería resetearse o mantenerse?
        # En topografía: Muro1 -> Muro1 -> Muro1F. El siguiente es Arbol1.
        # Arbol1 != Muro1 => Inicio.
        # Caso complejo: Muro1 -> Muro1F -> Muro1 -> Muro1F.
        # 1. Muro1 (Inicio) -> Muro1C
        # 2. Muro1F -> Muro1F
        # 3. Muro1 -> (es diff de Muro1? No, pero el anterior acabó).
        # AJUSTE LÓGICA: Si el anterior tuvo fin, el actual DEBE ser inicio aunque se llame igual.
        
        if tiene_fin:
            ultimo_codigo_base = None # Forzar que el siguiente sea detectado como nuevo cambio
        else:
            ultimo_codigo_base = codigo_base

    # 3. Escribir salida
    with open(archivo_salida, 'w', encoding='utf-8') as f_out:
        for campos in lineas_procesadas:
            f_out.write(','.join(campos) + '\n')

    print(f"Procesado V1 completado: {archivo_salida}")

if __name__ == "__main__":
    # Soporte arrastrar y soltar
    if len(sys.argv) > 1:
        entrada = sys.argv[1]
        folder = os.path.dirname(entrada)
        nombre = os.path.splitext(os.path.basename(entrada))[0]
        salida = os.path.join(folder, f"{nombre}_proc_v1.txt")
    else:
        entrada = "entrada_v1.txt"
        salida = "salida_v1.txt"

    if os.path.exists(entrada):
        procesar_txt_v1(entrada, salida)
    else:
        print(f"Pon un archivo llamado '{entrada}' junto al script o arrástralo encima.")
        input("Presiona Intro para salir...")
