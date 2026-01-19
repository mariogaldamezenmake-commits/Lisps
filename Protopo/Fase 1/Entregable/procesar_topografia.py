import os
import sys

def obtener_id_limpio(codigo_completo):
    """
    Parsea el campo final (ej: '3&17F') para obtener el ID de línea (ej: '17').
    Retorna (id_limpio, tiene_f)
    """
    # 1. Quitar espacios
    codigo = codigo_completo.strip()
    
    # 2. Detectar y quitar F final (independiente de mayús/minús)
    tiene_f = False
    if codigo.lower().endswith('f'):
        tiene_f = True
        codigo = codigo[:-1] # Quitamos la F temporalmente para extraer ID
    
    # 3. Separar por '&'
    if '&' in codigo:
        partes = codigo.split('&')
        # El ID es la parte derecha (última)
        id_limpio = partes[-1]
    else:
        # Si no tiene &, asumimos que todo es el ID (robustez)
        id_limpio = codigo
        
    return id_limpio, tiene_f

def procesar_topografia(archivo_entrada, archivo_salida):
    print(f"Leyendo: {archivo_entrada}...")
    
    lineas = []
    
    # --- LECTURA ---
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f:
            for raw_linea in f:
                linea_txt = raw_linea.strip()
                if not linea_txt: continue
                campos = linea_txt.split(',')
                if len(campos) < 1: continue
                lineas.append(campos)
    except Exception as e:
        print(f"Error al leer archivo: {e}")
        input("Presiona Intro para salir...")
        return

    if not lineas:
        print("El archivo está vacío.")
        return

    lineas_procesadas = []
    total_lineas = len(lineas)

    # --- PROCESAMIENTO ---
    for i in range(total_lineas):
        campos_actuales = lineas[i]
        codigo_raw_actual = campos_actuales[-1]
        
        id_actual, tiene_f_actual = obtener_id_limpio(codigo_raw_actual)
        
        # Mirar ANTERIOR
        if i > 0:
            codigo_raw_prev = lineas[i-1][-1]
            id_prev, _ = obtener_id_limpio(codigo_raw_prev)
        else:
            id_prev = None # Inicio de archivo

        # Mirar SIGUIENTE
        if i < total_lineas - 1:
            codigo_raw_next = lineas[i+1][-1]
            id_next, _ = obtener_id_limpio(codigo_raw_next)
        else:
            id_next = None # Fin de archivo

        # LÓGICA DE MARCADO
        # ¿Es Inicio?
        # Condición: El ID cambia respecto al anterior Y es igual al siguiente (continuidad)
        es_nuevo_id = (id_actual != id_prev)
        tiene_continuidad = (id_actual == id_next)
        
        suffijo_c = ""
        # Solo ponemos C si es nuevo Y tiene continuación (evita marcar puntos aislados)
        if es_nuevo_id and tiene_continuidad:
            suffijo_c = "C"
        
        # RECONSTRUCCIÓN DEL CÓDIGO
        # Queremos mantener el formato original (con o sin F original) + C si corresponde
        
        nuevo_codigo = codigo_raw_actual.strip() + suffijo_c
        
        # Crear COPIA de campos para no modificar la lista original 'lineas'
        campos_salida = list(campos_actuales)
        campos_salida[-1] = nuevo_codigo
        lineas_procesadas.append(campos_salida)

    # --- ESCRITURA ---
    try:
        with open(archivo_salida, 'w', encoding='utf-8') as f_out:
            for campos in lineas_procesadas:
                f_out.write(','.join(campos) + '\n')
        print(f"¡Éxito! Generado: {archivo_salida}")
    except Exception as e:
        print(f"Error al escribir archivo: {e}")

if __name__ == "__main__":
    # Soporte Drag & Drop
    if len(sys.argv) > 1:
        ruta_entrada = sys.argv[1]
        folder = os.path.dirname(ruta_entrada)
        nombre_base = os.path.splitext(os.path.basename(ruta_entrada))[0]
        ruta_salida = os.path.join(folder, f"{nombre_base}_proc.txt")
        
        procesar_topografia(ruta_entrada, ruta_salida)
        # Pausa para que el usuario vea el resultado si lanzó el exe
        # print("Presiona Intro para cerrar...")
        # input() 
        # (Comentado para pruebas automáticas, descomentar para EXE final)
    else:
        # Modo prueba manual (sin argumentos)
        entrada_def = "entrada_prueba.txt"
        salida_def = "salida_prueba.txt"
        if os.path.exists(entrada_def):
            procesar_topografia(entrada_def, salida_def)
        else:
            print(f"Arrastra un archivo sobre el ejecutable o crea '{entrada_def}'.")
            input("Presiona Intro para salir...")
