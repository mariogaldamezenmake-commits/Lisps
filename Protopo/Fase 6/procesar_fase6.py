import os
import sys

# Estructura de campos esperada:
# 0: Estacion
# 1: PUNTO (Clave de ordenación intra-grupo)
# ... intermedios ...
# -1: CODIGO (Tipo & Contador [F] @Atributos)

def parsear_codigo_completo(codigo_raw):
    """
    Descompone el código en:
    - Base limpia (para lógica de agrupación Tipo&Contador)
    - Sufijos especiales (todo lo que va con @)
    - Tiene F "clásica" (termina en F sin ser @F)
    """
    codigo = codigo_raw.strip()
    
    # Separar por @
    # Ejemplo: 59&1@AS@C -> base="59&1", partes_at=["AS", "C"]
    if '@' in codigo:
        trozos = codigo.split('@')
        base = trozos[0]
        atributos = trozos[1:] # Lista de atributos (sin el @)
    else:
        base = codigo
        atributos = []

    # Analizar la BASE para sacar Tipo, Contador y F "antigua"
    tiene_f_base = False
    if base.lower().endswith('f'):
        # Cuidado: si el tipo es "DEF", termina en F pero es parte del nombre
        # La F de fin de línea suele ir al final del contador "59&1F"
        # O si es punto suelto "MuroF"? -> Asumiremos logica anterior:
        # Si hay &, la F al final es marcador. Si no hay &, ¿es marcador o nombre?
        # En fases anteriores: "tiene_f = True, codigo = codigo[:-1]"
        # Mantenemos esa lógica conservadora para la BASE.
        tiene_f_base = True
        base_sin_f = base[:-1]
    else:
        base_sin_f = base

    # Parsear Tipo y Contador de la base limpia
    if '&' in base_sin_f:
        partes = base_sin_f.split('&')
        contador = partes[-1]
        tipo = "&".join(partes[:-1])
    else:
        tipo = base_sin_f
        contador = None

    return {
        'tipo': tipo,
        'contador': contador,
        'atributos': atributos,
        'base_original': base # Para depuración si hace falta
    }

def procesar_fase6(archivo_entrada, archivo_salida):
    print(f"Fase 6 (@) - Leyendo: {archivo_entrada}...")
    
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
        info = parsear_codigo_completo(cod_raw)
        
        tipo = info['tipo']
        contador = info['contador']
        
        try:
            num_punto = float(campos[0]) # Campo 0 es el número de punto en este formato
        except:
            num_punto = 0 
            
        punto_obj = {
            'campos': campos,
            'num': num_punto,
            'info_codigo': info # Guardamos el parseo para usarlo al escribir
        }

        if contador is not None:
            # Línea numerada: Agrupar por (Tipo, Contador) IGNORANDO atributos
            clave_grupo = (tipo, contador)
            
            if clave_grupo in mapa_grupos:
                idx = mapa_grupos[clave_grupo]
                grupos[idx]['puntos'].append(punto_obj)
            else:
                nuevo_grupo = {
                    'tipo': 'linea',
                    'clave': clave_grupo,
                    'puntos': [punto_obj],
                    'primer_orden': len(grupos),
                    'min_punto': float('inf')
                }
                grupos.append(nuevo_grupo)
                mapa_grupos[clave_grupo] = len(grupos) - 1
        else:
            # Punto suelto
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
        
        # Tipo base del grupo (lo sacamos del primer punto, aunque todos comparten tipo)
        tipo_base = puntos[0]['info_codigo']['tipo']
        
        for i, p in enumerate(puntos):
            campos_orig = list(p['campos'])
            info = p['info_codigo']
            
            # 1. Construir Parte Principal (Salida Limpia Fase 4)
            nuevo_cod_base = tipo_base
            
            if grp['tipo'] == 'linea':
                # Inicio -> 00
                if i == 0:
                    nuevo_cod_base += "00"
            
            # 2. Construir Sufijos (Fase 6)
            # "Ingore lo que hay detrás de la @ y que al final acabe cambiando las @ por espacios"
            sufijos_str = ""
            if info['atributos']:
                # Unir atributos con espacios (suplantando la @)
                # Ej: atributos=['AS', 'C'] -> " AS C"
                sufijos_str = " " + " ".join(info['atributos'])
            
            # Codigo Final = BaseModificada + Sufijos
            codigo_final = nuevo_cod_base + sufijos_str
            
            campos_orig[-1] = codigo_final
            lineas_salida.append(campos_orig)

    # Escritura
    try:
        with open(archivo_salida, 'w', encoding='utf-8') as f_out:
            for campos in lineas_salida:
                f_out.write(','.join(campos) + '\n')
        print(f"¡Éxito Fase 6! Generado: {archivo_salida}")
    except Exception as e:
        print(f"Error escritura: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        ruta_entrada = sys.argv[1]
        folder = os.path.dirname(ruta_entrada)
        nombre_base = os.path.splitext(os.path.basename(ruta_entrada))[0]
        ruta_salida = os.path.join(folder, f"{nombre_base}_fase6.txt")
        procesar_fase6(ruta_entrada, ruta_salida)
    else:
        entrada = "entrada_fase6.txt"
        salida = "entrada_fase6_fase6.txt"
        if os.path.exists(entrada):
            procesar_fase6(entrada, salida)
        else:
            print(f"No encuentro {entrada}")
