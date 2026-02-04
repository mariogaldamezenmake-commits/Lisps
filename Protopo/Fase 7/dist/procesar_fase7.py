import os
import sys

def parsear_codigo(codigo_raw):
    """
    Parsea el código de la última columna.
    Retorna un diccionario con:
    - 'original': el código original completo
    - 'tipo': la parte antes del '&' (o todo si no hay '&')
    - 'contador': la parte entre '&' y '@' (o None si no hay '&')
    - 'es_linea': True si tiene '&', False si no.
    """
    codigo = codigo_raw.strip()
    
    if '&' not in codigo:
        # Grupo A: Puntos sueltos
        # No tienen '&', por lo tanto el tipo es todo el código (sin atributos si los hubiera, 
        # pero la definición dice "todo lo que esté antes del &", y si no hay &...)
        # Si hubiera un @ en un punto suelto, la definición "222 - tipo" parece implicar todo hasta el &
        # Pero si no hay &, ¿hasta el @?
        # Revisando reglas: "222&7@F". 
        # Si es punto suelto (Grupo A), "no tendría & ni nada despues del &".
        # Asumimos que puede tener atributos con @?
        # "un punto que no pertenece a una línea ... no tiene base"
        # Simplificación: Todo lo que hay es el Tipo.
        # Si tiene @, ¿es parte del tipo o son atributos? 
        # La regla "222 - tipo (todo lo que esté antes del &)" es clave.
        # Si no hay &, todo es tipo... ¿o hasta el @?
        # En fases anteriores se separaba por @.
        # Asumiremos la separacion standard: Tipo es lo principal.
        # Si viene "Arbol@D", Tipo="Arbol".
        if '@' in codigo:
            tipo = codigo.split('@')[0]
        else:
            tipo = codigo
        return {
            'original': codigo,
            'tipo': tipo,
            'contador': None,
            'es_linea': False
        }
    else:
        # Grupo B: Líneas
        # "222&7@F"
        # Tipo: antes del &
        partes_amp = codigo.split('&')
        tipo = partes_amp[0]
        resto = '&'.join(partes_amp[1:]) # Lo que sigue al primer &
        
        # Contador: entre & y @
        if '@' in resto:
            contador_str = resto.split('@')[0]
        else:
            contador_str = resto
            
        return {
            'original': codigo,
            'tipo': tipo,
            'contador': contador_str,
            'es_linea': True
        }

def get_type_sort_key(tipo):
    """
    Retorna una clave de ordenación para el Tipo.
    - (0, numero) si es numérico.
    - (1, texto) si es alfanumérico.
    Esto asegura que los numéricos vayan antes que las letras.
    """
    try:
        val = float(tipo)
        return (0, val)
    except ValueError:
        return (1, tipo)

def get_counter_sort_key(contador_str):
    """
    Retorna clave para ordenar contadores numéricamente.
    """
    try:
        val = float(contador_str)
        return val
    except ValueError:
        return contador_str

def procesar_fase7(archivo_entrada, archivo_salida):
    print(f"Fase 7 - Procesando: {archivo_entrada}")
    
    lineas_datos = []
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f:
            for linea in f:
                linea = linea.strip()
                if not linea: continue
                campos = linea.split(',')
                if len(campos) < 1: continue
                lineas_datos.append(campos)
    except Exception as e:
        print(f"Error leyendo archivo de entrada: {e}")
        return

    if not lineas_datos:
        print("El archivo está vacío.")
        return

    grupo_a = [] # Puntos sueltos
    grupo_b = [] # Líneas

    # 1. Clasificación
    for campos in lineas_datos:
        cod_raw = campos[-1] # Última columna
        info = parsear_codigo(cod_raw)
        
        item = {
            'campos': campos,
            'info': info
        }
        
        if info['es_linea']:
            grupo_b.append(item)
        else:
            grupo_a.append(item)

    # 2. Procesamiento Grupo A (Puntos sueltos)
    # Ordenar: Tipo (Numérico < Alfabético)
    grupo_a.sort(key=lambda x: get_type_sort_key(x['info']['tipo']))
    
    # En Grupo A no se modifican los códigos (según instrucciones implícitas, solo se ordenan)
    # o ¿se limpian atributos? "En el grupo A quiero que los puntos se ordenen...". 
    # No dice nada de cambiar el código. Se dejan tal cual.

    # 3. Procesamiento Grupo B (Líneas)
    # Estructura: Diccionario[Tipo][Contador] = lista_puntos
    b_dict = {}
    
    for item in grupo_b:
        tipo = item['info']['tipo']
        contador = item['info']['contador']
        
        if tipo not in b_dict:
            b_dict[tipo] = {}
        if contador not in b_dict[tipo]:
            b_dict[tipo][contador] = []
            
        b_dict[tipo][contador].append(item)

    # Ordenar Tipos
    tipos_ordenados = sorted(b_dict.keys(), key=get_type_sort_key)
    
    grupo_b_final = []
    
    for tipo in tipos_ordenados:
        subcajas = b_dict[tipo]
        # Ordenar Contadores numéricamente
        contadores_ordenados = sorted(subcajas.keys(), key=get_counter_sort_key)
        
        for contador in contadores_ordenados:
            puntos = subcajas[contador]
            # Mantener orden original de lectura es automático porque fuimos haciendo append en ese orden
            
            # Procesar Puntos de esta línea
            for i, item in enumerate(puntos):
                # Modificar código (borrar bloque &..., añadir 00 al primero)
                campos_nuevos = list(item['campos'])
                tipo_limpio = item['info']['tipo']
                
                if i == 0:
                    nuevo_codigo = f"{tipo_limpio}00"
                else:
                    nuevo_codigo = tipo_limpio
                
                # Se sobreescribe la última columna con el nuevo código limpio
                campos_nuevos[-1] = nuevo_codigo
                grupo_b_final.append(campos_nuevos)

    # 4. Escritura Salida (Grupo B primero, luego Grupo A)
    # Nota: Grupo A mantiene sus campos originales, Grupo B tiene campos modificados.
    
    lineas_salida = grupo_b_final + [x['campos'] for x in grupo_a]
    
    try:
        with open(archivo_salida, 'w', encoding='utf-8') as f_out:
            for campos in lineas_salida:
                f_out.write(','.join(campos) + '\n')
        print(f"Generado exitosamente: {archivo_salida}")
    except Exception as e:
        print(f"Error escribiendo archivo de salida: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        entrada = sys.argv[1]
    else:
        entrada = "entrada_fase7.txt"

    if os.path.exists(entrada):
        # Nombre salida: nombre_original_fase7.txt
        base, ext = os.path.splitext(entrada)
        salida = f"{base}_fase7{ext}"
        procesar_fase7(entrada, salida)
    else:
        print(f"No se encuentra el archivo de entrada: {entrada}")
