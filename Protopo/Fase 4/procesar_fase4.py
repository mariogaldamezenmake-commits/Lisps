import os
import sys

def parsear_codigo(codigo_completo):
    """
    Parsea: TIPO & CONTADOR [F]
    Retorna: tipo, contador, tiene_f
    """
    codigo = codigo_completo.strip()
    
    # 1. Quitar F
    tiene_f = False
    if codigo.lower().endswith('f'):
        tiene_f = True
        codigo = codigo[:-1] 
    
    # 2. Separar Tipo y Contador
    if '&' in codigo:
        partes = codigo.split('&')
        contador = partes[-1]
        tipo = "&".join(partes[:-1]) 
    else:
        # Puntos sueltos sin contador (ej: "99")
        tipo = codigo
        contador = None 
        
    return tipo, contador, tiene_f

def procesar_fase4(archivo_entrada, archivo_salida):
    print(f"Fase 4 (Salida Limpia) - Leyendo: {archivo_entrada}...")
    
    lineas = []
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f:
            for raw_linea in f:
                linea_txt = raw_linea.strip()
                if not linea_txt: continue
                campos = linea_txt.split(',')
                if len(campos) < 1: continue
                lineas.append(campos)
    except Exception as e:
        print(f"Error lectura: {e}")
        input("Presiona Intro...")
        return

    if not lineas:
        print("Archivo vacío.")
        return

    lineas_procesadas = []
    total_lineas = len(lineas)

    for i in range(total_lineas):
        campos_actuales = lineas[i]
        codigo_raw_actual = campos_actuales[-1]
        
        tipo_act, cont_act, _ = parsear_codigo(codigo_raw_actual)
        
        # Identidad de Línea = (Tipo, Contador)
        # Si contador es None, es un punto suelto (no forma línea, o es línea de 1 pto sin &)
        if cont_act is not None:
            id_linea_actual = (tipo_act, cont_act)
        else:
            id_linea_actual = None # No es parte de una secuencia numerada &...
        
        # Mirar ANTERIOR
        if i > 0:
            tipo_prev, cont_prev, _ = parsear_codigo(lineas[i-1][-1])
            if cont_prev is not None:
                id_linea_prev = (tipo_prev, cont_prev)
            else:
                id_linea_prev = None
        else:
            id_linea_prev = None 

        # Mirar SIGUIENTE
        if i < total_lineas - 1:
            tipo_next, cont_next, _ = parsear_codigo(lineas[i+1][-1])
            if cont_next is not None:
                id_linea_next = (tipo_next, cont_next)
            else:
                id_linea_next = None
        else:
            id_linea_next = None

        # --- LÓGICA FASE 4 ---
        
        nuevo_codigo = tipo_act # Por defecto, la salida es solo el TIPO (sin &Contador, sin F)
        
        # ¿Es Inicio de una línea numerada?
        # Debe tener contador, ser distinto al anterior y continuar en el siguiente.
        if id_linea_actual is not None:
            es_nuevo = (id_linea_actual != id_linea_prev)
            continua = (id_linea_actual == id_linea_next)
            
            if es_nuevo and continua:
                nuevo_codigo = tipo_act + "00"
            
            # Si no es inicio, se queda como 'tipo_act' (limpio)
            
        else:
            # Puntos sueltos (sin &) se quedan igual (tipo_act)
            pass

        # Guardar
        campos_salida = list(campos_actuales)
        campos_salida[-1] = nuevo_codigo
        lineas_procesadas.append(campos_salida)

    # Escritura
    try:
        with open(archivo_salida, 'w', encoding='utf-8') as f_out:
            for campos in lineas_procesadas:
                f_out.write(','.join(campos) + '\n')
        print(f"¡Éxito Fase 4! Generado: {archivo_salida}")
    except Exception as e:
        print(f"Error escritura: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        ruta_entrada = sys.argv[1]
        folder = os.path.dirname(ruta_entrada)
        nombre_base = os.path.splitext(os.path.basename(ruta_entrada))[0]
        ruta_salida = os.path.join(folder, f"{nombre_base}_fase4.txt")
        procesar_fase4(ruta_entrada, ruta_salida)
    else:
        procesar_fase4("entrada_fase4.txt", "salida_fase4.txt")
