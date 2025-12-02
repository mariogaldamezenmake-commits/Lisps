;; ================================================================================
;; LISP: Automatización de Nivelación Digital
;; Fecha: 07/11/2025
;; Descripción: Inserta códigos y cotas desde nivel digital en AutoCAD
;; ================================================================================

(defun C:ND (/ archivo lineas datos altura pt1 pt2 distancia idx total)

  ;; ============================================================================
  ;; 1. CARGAR ARCHIVO CSV
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
  (setq datos (mapcar 'parsear-linea lineas))

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
  ;; 2. DEFINIR ALTURA DEL TEXTO
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
  ;; 3. INSERTAR TEXTOS UNO POR UNO
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
    (setq texto-formateado (formatear-texto codigo cota-metros))

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

;; Parsear una línea: "A1;999.01" → ("A1" 9.990)
(defun parsear-linea (linea / partes codigo cota-cm cota-metros)
  (if (wcmatch linea "*;*")
    (progn
      ;; Separar por punto y coma
      (setq partes (separar-string linea ";"))
      (setq codigo (car partes))
      (setq cota-cm (atof (cadr partes)))

      ;; Convertir centímetros a metros con redondeo especial
      (setq cota-metros (convertir-y-redondear cota-cm))

      (list codigo cota-metros)
    )
    nil ;; Línea inválida
  )
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

;; Convertir centímetros a metros con redondeo especial
;; Regla: Si décima de milímetro > 5 → redondear al alza el milímetro
(defun convertir-y-redondear (cota-cm / cota-mm decima-mm cota-mm-redondeada cota-metros)

  ;; Convertir cm a mm (multiplicar por 10)
  (setq cota-mm (* cota-cm 10.0))

  ;; Obtener la décima de milímetro
  ;; Ejemplo: 9990.7 mm → décima = 7
  (setq decima-mm (abs (rem (fix (* cota-mm 10.0)) 10)))

  ;; Aplicar regla de redondeo
  (if (> decima-mm 5)
    ;; Redondear al alza al siguiente milímetro
    (setq cota-mm-redondeada (+ (fix cota-mm) 1.0))
    ;; Mantener redondeado normal
    (setq cota-mm-redondeada (fix (+ cota-mm 0.5)))
  )

  ;; Convertir mm a metros (dividir por 1000)
  (setq cota-metros (/ cota-mm-redondeada 1000.0))

  cota-metros
)

;; Formatear texto: "A15 : 9,954"
(defun formatear-texto (codigo cota-metros / cota-str)

  ;; Convertir cota a string con 3 decimales
  (setq cota-str (rtos cota-metros 2 3))

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
(princ "\n  LISP: Nivelación Digital Cargado")
(princ "\n  Comando: ND")
(princ "\n===============================================")
(princ)
