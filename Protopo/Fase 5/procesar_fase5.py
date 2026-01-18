import os
import sys

# Estructura de campos esperada:
# 0: Estacion
# 1: PUNTO (Clave de ordenación intra-grupo)
# ... intermedios ...
# -1: CODIGO (Tipo & Contador [F])

def parsear_codigo(codigo_completo):
    """
    Retorna: tipo, contador, tiene_f
    """
    codigo = codigo_completo.strip()
    
    tiene_f = False
    if codigo.lower().endswith('f'):
        tiene_f = True
        codigo = codigo[:-1] 
    
    if '&' in codigo:
        partes = codigo.split('&')
        contador = partes[-1] # Ultima parte es el contador
        tipo = "&".join(partes[:-1]) # El resto es el tipo
    else:
        tipo = codigo
        contador = None 
        
    return tipo, contador, tiene_f

def procesar_fase5(archivo_entrada, archivo_salida):
    print(f"Fase 5 (Sort) - Leyendo: {archivo_entrada}...")
    
    lineas = []
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f:
            for raw_linea in f:
                linea_txt = raw_linea.strip()
                if not linea_txt: continue
                campos = linea_txt.split(',')
                if len(campos) < 2: continue 
                lineas.append(campos)
    except Exception as e:
        print(f"Error lectura: {e}")
        return

    if not lineas:
        print("Archivo vacío.")
        return

    # --- 1. AGRUPACIÓN ---
    grupos = [] 
    mapa_grupos = {}
    puntos_sueltos_idx = 0 
    
    for campos in lineas:
        cod_raw = campos[-1]
        tipo, contador, _ = parsear_codigo(cod_raw)
        
        try:
            num_punto = float(campos[1]) 
        except:
            num_punto = 0 
            
        punto_obj = {
            'campos': campos,
            'num': num_punto
        }

        if contador is not None:
            # Línea numerada: Agrupar por (Tipo, Contador)
            clave_grupo = (tipo, contador)
            
            if clave_grupo in mapa_grupos:
                idx = mapa_grupos[clave_grupo]
                grupos[idx]['puntos'].append(punto_obj)
            else:
                nuevo_grupo = {
                    'tipo': 'linea',
                    'clave': clave_grupo,
                    'puntos': [punto_obj],
                    'primer_orden': len(grupos), # Orden de llegada original (fallback)
                    'min_punto': float('inf')    # Se calculará despues
                }
                grupos.append(nuevo_grupo)
                mapa_grupos[clave_grupo] = len(grupos) - 1
        else:
            # Punto suelto: Se queda solo
            # Usamos num_punto también para ordenarlos luego entre sí
            nuevo_grupo = {
                'tipo': 'suelto',
                'clave': (tipo, f"suelto_{puntos_sueltos_idx}"),
                'puntos': [punto_obj],
                'primer_orden': len(grupos),
                'min_punto': num_punto 
            }
            grupos.append(nuevo_grupo)
            puntos_sueltos_idx += 1

    # --- 2. ORDENACIÓN ---
    
    # A) Ordenar PUNTOS dentro de cada grupo
    for grp in grupos:
        if grp['tipo'] == 'linea':
            grp['puntos'].sort(key=lambda x: x['num'])
            # El min_punto es el del primero tras ordenar
            if grp['puntos']:
                grp['min_punto'] = grp['puntos'][0]['num']
            else:
                grp['min_punto'] = float('inf')

    # B) Ordenar GRUPOS entre sí por 'min_punto'
    grupos.sort(key=lambda x: x['min_punto'])

    # --- 3. PROCESAMIENTO SALIDA ---
    lineas_salida = []
    
    for grp in grupos:
        puntos = grp['puntos']
        if not puntos: continue
        
        # Tipo base del primer punto
        tipo_base, _, _ = parsear_codigo(puntos[0]['campos'][-1])
        
        for i, p in enumerate(puntos):
            campos_orig = list(p['campos'])
            
            nuevo_cod = tipo_base
            
            if grp['tipo'] == 'linea':
                # Regla Fase 4: Inicio -> 00
                if i == 0:
                    nuevo_cod += "00"
                # Resto -> Limpio
            else:
                # Puntos sueltos -> Limpio
                pass
            
            campos_orig[-1] = nuevo_cod
            lineas_salida.append(campos_orig)

    # Escritura
    try:
        with open(archivo_salida, 'w', encoding='utf-8') as f_out:
            for campos in lineas_salida:
                f_out.write(','.join(campos) + '\n')
        print(f"¡Éxito Fase 5! Generado: {archivo_salida}")
    except Exception as e:
        print(f"Error escritura: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        ruta_entrada = sys.argv[1]
        folder = os.path.dirname(ruta_entrada)
        nombre_base = os.path.splitext(os.path.basename(ruta_entrada))[0]
        ruta_salida = os.path.join(folder, f"{nombre_base}_fase5.txt")
        procesar_fase5(ruta_entrada, ruta_salida)
    else:
        # Default para testing
        entrada = "entrada_fase5.txt"
        salida = "entrada_fase5_fase5.txt" # Forzamos este nombre para coincidir con la prueba
        if os.path.exists(entrada):
            procesar_fase5(entrada, salida)
        else:
            print(f"No encuentro {entrada}")
