import os
import sys

def procesar_txt(archivo_entrada, archivo_salida):
    """
    Procesa un TXT con coordenadas y códigos, marca el inicio de línea (C) 
    y conserva el final de línea (F) según el campo código.
    """
    lineas = []
    
    # Leer todas las líneas y almacenar con sus campos
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f:
            for raw_linea in f:
                linea = raw_linea.strip()
                if not linea:
                    continue  # Ignorar líneas vacías
                campos = linea.split(',')
                lineas.append(campos)
    except FileNotFoundError:
         print(f"ERROR: No se encontró el archivo '{archivo_entrada}'")
         return
    
    # Diccionario para marcar el primer punto de cada línea
    inicio_linea_dict = {}  # key: (tipo_linea, numero_linea), value: índice de primer punto

    # Primero recorremos para identificar el primer punto de cada línea
    for idx, campos in enumerate(lineas):
        if not campos: continue
        codigo = campos[-1]  # Último campo = código
        # Extraer tipo y número de línea
        if codigo.endswith('F'):
            codigo_base = codigo[:-1]  # sin F
        else:
            codigo_base = codigo
        tipo_num = codigo_base  # Ej: '1&1'

        if tipo_num not in inicio_linea_dict:
            inicio_linea_dict[tipo_num] = idx  # Guardamos primer índice

    # Ahora procesamos y escribimos la salida
    with open(archivo_salida, 'w', encoding='utf-8') as f_out:
        for idx, campos in enumerate(lineas):
            if not campos: continue
            codigo = campos[-1]
            # Extraer tipo_num
            if codigo.endswith('F'):
                tipo_num = codigo[:-1]
            else:
                tipo_num = codigo
            
            # Marcar inicio
            if idx == inicio_linea_dict.get(tipo_num):
                # Agregar C al último campo
                # NOTA: Si es Start y End a la vez, aquí pierde el F.
                campos[-1] = campos[-1].replace('F','') + 'C'
            # Mantener F al final
            elif codigo.endswith('F'):
                campos[-1] = campos[-1]  # Se mantiene F
            else:
                campos[-1] = tipo_num  # Punto intermedio sin C ni F
            
            # Escribir línea
            f_out.write(','.join(campos) + '\n')

    print(f"Archivo procesado correctamente: {archivo_salida}")


if __name__ == "__main__":
    # Si se pasa un argumento (arrastrar archivo), úsalo
    if len(sys.argv) > 1:
        entrada = sys.argv[1]
        folder = os.path.dirname(entrada)
        nombre = os.path.splitext(os.path.basename(entrada))[0]
        salida = os.path.join(folder, f"{nombre}_procesado.txt")
    else:
        # Default original
        entrada = "entrada.txt"
        salida = "salida.txt"

    if os.path.exists(entrada):
        procesar_txt(entrada, salida)
    else:
        print(f"Esperando {entrada} o arrastra un archivo sobre el ejecutable.")
        input("Presiona Enter para salir...") # Pausa para ver el error en exe
