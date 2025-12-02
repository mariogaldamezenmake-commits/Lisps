;; ================================================================================
;; LISP: Automatización de Nivelación Digital v2.0
;; Fecha: 10/11/2025
;; Descripción: Inserta códigos y cotas desde nivel digital en AutoCAD
;;              con selección de precisión decimal
;; ================================================================================

(defun C:ND (/ archivo lineas datos altura pt1 pt2 distancia idx total precision decimales)

  ;; ============================================================================
  ;; 1. SELECCIONAR NÚMERO DE DECIMALES
  ;; ============================================================================

  (princ "\n=== SELECCIÓN DE DECIMALES ===")
  (princ "\n¿Cuántos decimales desea mostrar en las cotas?")
  (princ "\n  1 decimal  → Ejemplo: 10,0 m")
  (princ "\n  2 decimales → Ejemplo: 10,00 m")
  (princ "\n  3 decimales → Ejemplo: 10,000 m")
  (princ "\n  4 decimales → Ejemplo: 10,0000 m")
  (princ "\n  5 decimales → Ejemplo: 10,00000 m")

  (initget "1 2 3 4 5")
  (setq precision (getkword "\n¿Cuántos decimales? [1/2/3/4/5] <3>: "))

  ;; Valor por defecto: 3 decimales
  (if (not precision)
    (setq precision "3")
  )

  ;; Convertir string a número
  (setq decimales (atoi precision))

  (princ (strcat "\nSe usarán " (itoa decimales) " decimales"))

  ;; ============================================================================
  ;; 2. CARGAR ARCHIVO CSV
  ;; ============================================================================

  (setq archivo (getfiled "Seleccionar archivo de datos" "" "csv;txt" 8))

  (if (not archivo)
    (progn
      (princ "\n*** Operación cancelada ***")
      (exit)
    )
  )

  ;; Leer el archivo completo
  (setq lineas (leer-archivo archivo))

  (if (not lineas)
    (progn
      (princ "\n*** Error: No se pudo leer el archivo ***")
      (exit)
    )
  )

  ;; Parsear datos (código y cota)
  (setq datos (mapcar '(lambda (linea) (parsear-linea linea decimales)) lineas))

  ;; Filtrar líneas vacías o inválidas
  (setq datos (vl-remove nil datos))

  (if (= (length datos) 0)
    (progn
      (princ "\n*** Error: No hay datos válidos en el archivo ***")
      (exit)
    )
  )

  (princ (strcat "\n" (itoa (length datos)) " puntos cargados desde el archivo"))

  ;; ============================================================================
  ;; 3. DEFINIR ALTURA DEL TEXTO
  ;; ============================================================================

  (princ "\n")
  (princ "\n=== DEFINIR ALTURA DEL TEXTO ===")
  (princ "\nMarque el primer punto de referencia:")

  (setq pt1 (getpoint "\nPrimer punto: "))

  (if (not pt1)
    (progn
      (princ "\n*** Operación cancelada ***")
      (exit)
    )
  )

  (princ "\nMarque el segundo punto (se mostrará una línea de referencia):")

  ;; Usar grread para mostrar línea dinámica
  (setq pt2 (getpoint-con-linea pt1))

  (if (not pt2)
    (progn
      (princ "\n*** Operación cancelada ***")
      (exit)
    )
  )

  ;; Calcular altura del texto (distancia entre puntos)
  (setq distancia (distance pt1 pt2))
  (setq altura distancia)

  (princ (strcat "\nAltura del texto: " (rtos altura 2 3)))

  ;; ============================================================================
  ;; 4. INSERTAR TEXTOS UNO POR UNO
  ;; ============================================================================

  (setq idx 0)
  (setq total (length datos))

  (princ "\n")
  (princ "\n=== INSERTAR TEXTOS ===")
  (princ "\nHaga clic donde desea insertar cada texto")
  (princ "\n(Presione ESC para cancelar)")

  (while (and (< idx total))

    (setq dato-actual (nth idx datos))
    (setq codigo (car dato-actual))
    (setq cota-metros (cadr dato-actual))

    ;; Formatear texto: "A15 : 9,954"
    (setq texto-formateado (formatear-texto codigo cota-metros decimales))

    (princ (strcat "\n\n[" (itoa (+ idx 1)) "/" (itoa total) "] " texto-formateado))

    ;; Pedir punto de inserción
    (setq pt-insercion (getpoint "\nPunto de inserción: "))

    (if pt-insercion
      (progn
        ;; Insertar TEXT en AutoCAD
        (command "_.TEXT" pt-insercion altura "0" texto-formateado)
        (setq idx (+ idx 1))
      )
      (progn
        ;; Usuario canceló
        (princ "\n*** Operación interrumpida por el usuario ***")
        (setq idx total) ;; Salir del bucle
      )
    )
  )

  (princ (strcat "\n\n=== PROCESO COMPLETADO: " (itoa idx) " textos insertados ==="))
  (princ)
)


;; ============================================================================
;; FUNCIONES AUXILIARES
;; ============================================================================

;; Leer archivo línea por línea
(defun leer-archivo (archivo / f lineas linea)
  (setq lineas '())
  (if (setq f (open archivo "r"))
    (progn
      (while (setq linea (read-line f))
        (if (> (strlen linea) 0)
          (setq lineas (append lineas (list linea)))
        )
      )
      (close f)
    )
  )
  lineas
)

;; Parsear una línea: "A1;9990.123" → ("A1" 9.990123)
(defun parsear-linea (linea decimales / partes codigo cota-str cota-centesimas cota-metros)
  (if (wcmatch linea "*;*")
    (progn
      ;; Separar por punto y coma
      (setq partes (separar-string linea ";"))
      (setq codigo (car partes))
      (setq cota-str (cadr partes))

      ;; Eliminar puntos y comas del string (solo dejar dígitos)
      (setq cota-str (limpiar-numero cota-str))

      ;; Convertir a número (centésimas de milímetro)
      (setq cota-centesimas (atof cota-str))

      ;; Convertir centésimas de mm a metros y redondear
      (setq cota-metros (convertir-y-redondear cota-centesimas decimales))

      (list codigo cota-metros)
    )
    nil ;; Línea inválida
  )
)

;; Limpiar número: eliminar puntos y comas, dejar solo dígitos
(defun limpiar-numero (str / resultado i char)
  (setq resultado "")
  (setq i 1)
  (while (<= i (strlen str))
    (setq char (substr str i 1))
    (if (or (and (>= char "0") (<= char "9")))
      (setq resultado (strcat resultado char))
    )
    (setq i (+ i 1))
  )
  resultado
)

;; Separar string por delimitador
(defun separar-string (str delim / pos resultado)
  (setq resultado '())
  (while (setq pos (vl-string-search delim str))
    (setq resultado (append resultado (list (substr str 1 pos))))
    (setq str (substr str (+ pos 2)))
  )
  (append resultado (list str))
)

;; Convertir centésimas de mm a metros con redondeo según precisión
;; 1 centésima de mm = 0.00001 m
;; Centésimas de mm → metros: dividir entre 100000
(defun convertir-y-redondear (centesimas-mm decimales / metros factor)

  ;; Convertir centésimas de mm a metros
  (setq metros (/ centesimas-mm 100000.0))

  ;; Redondear según número de decimales
  (setq factor (expt 10.0 decimales))
  (setq metros (/ (fix (+ (* metros factor) 0.5)) factor))

  metros
)

;; Formatear texto: "A15 : 9,954"
(defun formatear-texto (codigo cota-metros decimales / cota-str)

  ;; Convertir cota a string con decimales especificados
  (setq cota-str (rtos cota-metros 2 decimales))

  ;; Reemplazar punto por coma
  (setq cota-str (substituir-caracter cota-str "." ","))

  ;; Formato final: "Código : Cota"
  (strcat codigo " : " cota-str)
)

;; Sustituir carácter en string
(defun substituir-caracter (str viejo nuevo / resultado i char)
  (setq resultado "")
  (setq i 1)
  (while (<= i (strlen str))
    (setq char (substr str i 1))
    (if (= char viejo)
      (setq resultado (strcat resultado nuevo))
      (setq resultado (strcat resultado char))
    )
    (setq i (+ i 1))
  )
  resultado
)

;; Obtener punto con línea dinámica de referencia
(defun getpoint-con-linea (pt1 / pt2 grr codigo punto guardado)
  (setq guardado (getvar "OSMODE"))
  (setvar "OSMODE" 0) ;; Desactivar osnaps temporalmente

  (setq pt2 nil)
  (setq punto pt1)

  ;; Modo gráfico con grread
  (while (not pt2)
    (setq grr (grread T 15 0))
    (setq codigo (car grr))

    (cond
      ;; Movimiento del ratón (código 5)
      ((= codigo 5)
       (setq punto (cadr grr))
       ;; Dibujar línea temporal
       (grdraw pt1 punto 1 1)
      )

      ;; Clic izquierdo (código 3)
      ((= codigo 3)
       (setq pt2 (cadr grr))
      )

      ;; ESC o cancelar (código 11)
      ((= codigo 11)
       (setq pt2 nil)
       (setvar "OSMODE" guardado)
       (exit)
      )
    )
  )

  (setvar "OSMODE" guardado)
  pt2
)

;; ============================================================================
;; MENSAJES
;; ============================================================================

(princ "\n===============================================")
(princ "\n  LISP: Nivelación Digital v2.0 Cargado")
(princ "\n  Comando: ND")
(princ "\n===============================================")
(princ)
