import os
import sys

def parsear_codigo(codigo_completo):
    """
    Parsea el campo final formato TIPO & CONTADOR [F]
    Ej: '59&1F' -> tipo='59', contador='1', tiene_f=True
    Ej: 'Muro&2' -> tipo='Muro', contador='2', tiene_f=False
    """
    codigo = codigo_completo.strip()
    
    # 1. Detectar y quitar F final
    tiene_f = False
    if codigo.lower().endswith('f'):
        tiene_f = True
        codigo = codigo[:-1] 
    
    # 2. Separar por '&'
    # Ahora la lógica es: LO DE ANTES es TIPO, LO DE DESPUES es CONTADOR
    if '&' in codigo:
        partes = codigo.split('&')
        # Robustez: Si hay más de un &, asumimos que el último separa el contador
        contador = partes[-1]
        tipo = "&".join(partes[:-1]) # El resto es el tipo
    else:
        # Caso raro sin &: Asumimos que todo es Tipo y contador vacío (o '0')
        tipo = codigo
        contador = "0"
        
    return tipo, contador, tiene_f

def procesar_fase3(archivo_entrada, archivo_salida):
    print(f"Fase 3 (Tipo&Contador) - Leyendo: {archivo_entrada}...")
    
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
        print(f"Error al leer: {e}")
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
        
        tipo_act, cont_act, f_act = parsear_codigo(codigo_raw_actual)
        
        # Identificador Único de Línea = (Tipo, Contador)
        id_linea_actual = (tipo_act, cont_act)
        
        # Mirar ANTERIOR
        if i > 0:
            codigo_raw_prev = lineas[i-1][-1]
            tipo_prev, cont_prev, _ = parsear_codigo(codigo_raw_prev)
            id_linea_prev = (tipo_prev, cont_prev)
        else:
            id_linea_prev = None 

        # Mirar SIGUIENTE
        if i < total_lineas - 1:
            codigo_raw_next = lineas[i+1][-1]
            tipo_next, cont_next, _ = parsear_codigo(codigo_raw_next)
            id_linea_next = (tipo_next, cont_next)
        else:
            id_linea_next = None

        # --- LÓGICA FASE 3 ---
        
        # 1. Detectar Inicio: Cambio de (Tipo+Contador) + Continuidad del mismo (Tipo+Contador)
        es_nuevo_id = (id_linea_actual != id_linea_prev)
        tiene_continuidad = (id_linea_actual == id_linea_next)
        es_inicio = es_nuevo_id and tiene_continuidad

        # 2. Transformar
        nuevo_tipo = tipo_act
        
        if es_inicio:
            nuevo_tipo += "00" # Regla: Tipo -> Tipo00 al inicio
            
        # Reconstruir código: NuevoTipo & Contador (sin F)
        # Nota: La F ya se quitó al parsear y NO se vuelve a poner (Regla Fase 2 heredada: eliminar F)
        
        nuevo_codigo_completo = f"{nuevo_tipo}&{cont_act}"
        
        # Guardar en copia
        campos_salida = list(campos_actuales)
        campos_salida[-1] = nuevo_codigo_completo
        lineas_procesadas.append(campos_salida)

    # Escritura
    try:
        with open(archivo_salida, 'w', encoding='utf-8') as f_out:
            for campos in lineas_procesadas:
                f_out.write(','.join(campos) + '\n')
        print(f"¡Éxito Fase 3! Generado: {archivo_salida}")
    except Exception as e:
        print(f"Error escritura: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        ruta_entrada = sys.argv[1]
        folder = os.path.dirname(ruta_entrada)
        nombre_base = os.path.splitext(os.path.basename(ruta_entrada))[0]
        ruta_salida = os.path.join(folder, f"{nombre_base}_fase3.txt")
        
        procesar_fase3(ruta_entrada, ruta_salida)
    else:
        entrada_def = "entrada_fase3.txt"
        salida_def = "salida_fase3.txt"
        if os.path.exists(entrada_def):
            procesar_fase3(entrada_def, salida_def)
        else:
            print(f"Arrastra archivo o pon '{entrada_def}'.")
            input("Presiona Intro...")
