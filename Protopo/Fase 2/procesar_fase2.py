import os
import sys

def obtener_id_limpio(codigo_completo):
    """
    Parsea el campo final (ej: '3&17F') para obtener el ID de línea (ej: '17').
    Retorna (id_limpio, tiene_f)
    """
    codigo = codigo_completo.strip()
    
    # Detectar y quitar F final
    tiene_f = False
    if codigo.lower().endswith('f'):
        tiene_f = True
        codigo = codigo[:-1] 
    
    # Separar por '&'
    if '&' in codigo:
        partes = codigo.split('&')
        id_limpio = partes[-1]
    else:
        id_limpio = codigo
        
    return id_limpio, tiene_f

def procesar_fase2(archivo_entrada, archivo_salida):
    print(f"Fase 2 - Leyendo: {archivo_entrada}...")
    
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
        
        id_actual, tiene_f_actual = obtener_id_limpio(codigo_raw_actual)
        
        # Mirar ANTERIOR
        if i > 0:
            codigo_raw_prev = lineas[i-1][-1]
            id_prev, _ = obtener_id_limpio(codigo_raw_prev)
        else:
            id_prev = None 

        # Mirar SIGUIENTE
        if i < total_lineas - 1:
            codigo_raw_next = lineas[i+1][-1]
            id_next, _ = obtener_id_limpio(codigo_raw_next)
        else:
            id_next = None

        # --- LÓGICA FASE 2 ---
        
        # 1. Detectar Inicio: Cambio ID + Continuidad
        es_nuevo_id = (id_actual != id_prev)
        tiene_continuidad = (id_actual == id_next)
        es_inicio = es_nuevo_id and tiene_continuidad

        # 2. Reconstruir Código
        # Base: El código original SIN la F (porque en Fase 2 "se eliminan las F")
        if tiene_f_actual:
            # Si tenía F, la quitamos del string original
            # Cuidado: codigo_raw_actual puede ser '3&MuroF'
            # Hay que quitar la 'F' del final conservando el '3&Muro'
            base_sin_f = codigo_raw_actual.strip()[:-1] 
        else:
            base_sin_f = codigo_raw_actual.strip()

        nuevos_digitos = ""
        if es_inicio:
            nuevos_digitos = "00"
        
        # Resultado: CódigoBase + 00 (si inicio)
        # Nota: Si era Fin, ya le quitamos la F en 'base_sin_f'
        final_codigo = base_sin_f + nuevos_digitos
        
        # Guardar en copia
        campos_salida = list(campos_actuales)
        campos_salida[-1] = final_codigo
        lineas_procesadas.append(campos_salida)

    # Escritura
    try:
        with open(archivo_salida, 'w', encoding='utf-8') as f_out:
            for campos in lineas_procesadas:
                f_out.write(','.join(campos) + '\n')
        print(f"¡Éxito Fase 2! Generado: {archivo_salida}")
    except Exception as e:
        print(f"Error escritura: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        ruta_entrada = sys.argv[1]
        folder = os.path.dirname(ruta_entrada)
        nombre_base = os.path.splitext(os.path.basename(ruta_entrada))[0]
        ruta_salida = os.path.join(folder, f"{nombre_base}_fase2.txt")
        
        procesar_fase2(ruta_entrada, ruta_salida)
    else:
        entrada_def = "entrada_fase2.txt"
        salida_def = "salida_fase2.txt"
        if os.path.exists(entrada_def):
            procesar_fase2(entrada_def, salida_def)
        else:
            print(f"Arrastra archivo o pon '{entrada_def}'.")
            input("Presiona Intro...")
