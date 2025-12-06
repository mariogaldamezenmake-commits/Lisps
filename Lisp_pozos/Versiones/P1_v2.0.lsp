;;; ------------------------------------------------------------
;;; P1_v2.0.lsp – Carga automática desde ficheros CSV + inserción de bloques POZO
;;; Basado en P1_v1.2.lsp
;;; Mejora: Los datos se cargan desde PRIMERA_PASADA.txt y SEGUNDA_PASADA.txt
;;;         El usuario solo selecciona archivos, polilíneas y puntos de inserción
;;; Autor: Adaptado para Mario Galdámez – AutoCAD 2026
;;; ------------------------------------------------------------

(vl-load-com)

;; ========================================
;; FUNCIONES AUXILIARES (de v1.2)
;; ========================================

(defun _deg->rad (a) (* pi (/ a 180.0)))
(defun _rad->deg (r) (* 180.0 (/ r pi)))
(defun _pt->ucs (p) (trans p 0 1))
(defun _pt->wcs (p) (trans p 1 0))
(defun _xy (p) (list (car p) (cadr p)))
(defun _d2 (p q) (distance (_xy p) (_xy q))) ; distancia en 2D (ignora Z)
(defun _rtosN (n prec) (rtos n 2 prec))      ; real a string con 'prec' decimales

(defun _is-3dpoly? (e)
  (and e
       (eq (cdr (assoc 0 (entget e))) "POLYLINE")
       (= (logand (cdr (assoc 70 (entget e))) 8) 8)
  )
)

(defun _3dpoly-vertices (e / v lst ed)
  ;; Devuelve lista de (ename . pointWCS) para cada VERTEX
  (setq v (entnext e))
  (while (and v (setq ed (entget v)) (not (eq (cdr (assoc 0 ed)) "SEQEND")))
    (if (eq (cdr (assoc 0 ed)) "VERTEX")
      (setq lst (cons (cons v (cdr (assoc 10 ed))) lst))
    )
    (setq v (entnext v))
  )
  (reverse lst)
)

(defun _set-vertex-z (vname newZ / ed pnew)
  (setq ed (entget vname))
  (if ed
    (progn
      (setq pnew (cdr (assoc 10 ed)))
      (setq pnew (list (car pnew) (cadr pnew) newZ))
      (entmod (subst (cons 10 pnew) (assoc 10 ed) ed))
      (entupd vname)
      T
    )
    nil
  )
)

(defun _insert-pozo-with-attrs (insPtUCS rotRad sResultado sDiam sNum
                                         / doc lay blkSpace insPtWCS blkObj var arr tag)
  ;; Inserta "POZO" y rellena atributos por TAG: RESULTADO, DIAMETRODETUBO, NUMERODETUBOS
  (setq insPtWCS (trans (list (car insPtUCS) (cadr insPtUCS) 0.0) 1 0)) ; UCS->WCS Z=0
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq lay (vla-get-ActiveLayout doc))
  (setq blkSpace (vla-get-Block lay)) ; contenedor del layout activo (Model o Paper)

  (if (not (tblsearch "BLOCK" "POZO"))
    (progn (prompt "\n**ERROR**: No existe un bloque llamado 'POZO' en el dibujo.") nil)
    (progn
      (setq blkObj (vla-InsertBlock blkSpace
                                    (vlax-3d-point insPtWCS)
                                    "POZO"
                                    1.0 1.0 1.0
                                    rotRad))
      ;; Si el bloque tiene atributos, obtenerlos y rellenar por TAG
      (if (= (vla-get-HasAttributes blkObj) :vlax-true)
        (progn
          ;; Método correcto: vla-GetAttributes -> Variant con SAFEARRAY
          (setq var (vla-GetAttributes blkObj))
          (setq arr (vlax-safearray->list (vlax-variant-value var)))
          (foreach a arr
            (setq tag (strcase (vla-get-TagString a))) ; a MAYÚSCULAS
            (cond
              ((= tag "RESULTADO")      (vla-put-TextString a sResultado))
              ((= tag "DIAMETRODETUBO") (vla-put-TextString a sDiam))
              ((= tag "NUMERODETUBOS")  (vla-put-TextString a sNum))
            )
          )
        )
      )
      blkObj
    )
  )
)

;; ========================================
;; FUNCIONES DE LECTURA DE ARCHIVOS CSV
;; ========================================

(defun leer-linea-csv (linea separador / lst pos inicio)
  ;; Divide una línea CSV por el separador (ej: ",")
  ;; Retorna lista de strings
  (setq lst '())
  (setq inicio 1)

  (while (setq pos (vl-string-search separador linea inicio))
    (setq lst (append lst (list (substr linea inicio (- pos inicio -1)))))
    (setq inicio (+ pos 2))
  )

  ;; Agregar el último campo
  (setq lst (append lst (list (substr linea inicio))))
  lst
)

(defun leer-archivo-csv (archivo separador / f linea resultado)
  ;; Lee un archivo CSV y retorna lista de listas (filas parseadas)
  ;; archivo: ruta completa al archivo
  ;; separador: "," por defecto
  (setq resultado '())

  (if (setq f (open archivo "r"))
    (progn
      (while (setq linea (read-line f))
        (if (and linea (> (strlen linea) 0))
          (setq resultado (append resultado (list (leer-linea-csv linea separador))))
        )
      )
      (close f)
      resultado
    )
    (progn
      (prompt (strcat "\n**ERROR**: No se pudo abrir el archivo: " archivo))
      nil
    )
  )
)

(defun cargar-primera-pasada (archivo / datos resultado fila id x y z)
  ;; Lee PRIMERA_PASADA.txt
  ;; Retorna lista asociativa: ((ID . (X Y Z)) ...)
  ;; Formato: P001,725432.15,4372156.82,108.45,20241015,JMS
  (setq datos (leer-archivo-csv archivo ","))
  (setq resultado '())

  (foreach fila datos
    (if (>= (length fila) 4)
      (progn
        (setq id (nth 0 fila))
        (setq x (atof (nth 1 fila)))
        (setq y (atof (nth 2 fila)))
        (setq z (atof (nth 3 fila)))
        (setq resultado (append resultado (list (cons id (list x y z)))))
      )
    )
  )

  resultado
)

(defun cargar-segunda-pasada (archivo / datos resultado fila tubo)
  ;; Lee SEGUNDA_PASADA.txt
  ;; Retorna lista de tubos (cada uno es una lista asociativa)
  ;; Formato: P001,fecal,circular,60,1.80,1,1,colector_salida,30,1.70,20241022,JMS
  (setq datos (leer-archivo-csv archivo ","))
  (setq resultado '())

  (foreach fila datos
    (if (>= (length fila) 10)
      (progn
        (setq tubo (list
          (cons 'ID_POZO       (nth 0 fila))          ; P001
          (cons 'TIPO_AGUA     (nth 1 fila))          ; fecal
          (cons 'FORMA_TAPA    (nth 2 fila))          ; circular
          (cons 'DIM_TAPA      (atof (nth 3 fila)))   ; 60
          (cons 'PROF_ARENERO  (atof (nth 4 fila)))   ; 1.80
          (cons 'NUM_TUBO      (atoi (nth 5 fila)))   ; 1
          (cons 'TOTAL_TUBOS   (atoi (nth 6 fila)))   ; 1
          (cons 'TIPO_TUBO     (nth 7 fila))          ; colector_salida
          (cons 'DIAM_TUBO     (atof (nth 8 fila)))   ; 30
          (cons 'PROF_TUBO     (atof (nth 9 fila)))   ; 1.70
        ))
        (setq resultado (append resultado (list tubo)))
      )
    )
  )

  resultado
)

(defun combinar-datos (primera segunda / resultado tubo id-pozo datos-pozo cota-tapa cota-tubo tubo-completo)
  ;; Combina datos de primera y segunda pasada
  ;; Para cada tubo: busca su pozo en primera, agrega cota_tapa y calcula cota_tubo
  (setq resultado '())

  (foreach tubo segunda
    (setq id-pozo (cdr (assoc 'ID_POZO tubo)))
    (setq datos-pozo (assoc id-pozo primera))

    (if datos-pozo
      (progn
        (setq cota-tapa (caddr (cdr datos-pozo)))  ; Z del pozo
        (setq cota-tubo (- cota-tapa (cdr (assoc 'PROF_TUBO tubo))))

        ;; Agregar campos calculados al tubo
        (setq tubo-completo (append tubo (list
          (cons 'COTA_TAPA cota-tapa)
          (cons 'COTA_TUBO cota-tubo)
        )))

        (setq resultado (append resultado (list tubo-completo)))
      )
      (prompt (strcat "\n**ADVERTENCIA**: No se encontró el pozo " id-pozo " en PRIMERA_PASADA.txt"))
    )
  )

  resultado
)

;; ========================================
;; FUNCIÓN PRINCIPAL
;; ========================================

(defun c:P1 (/ archivo-segunda archivo-primera carpeta
             datos-primera datos-segunda tubos-completos
             i tubo id-pozo num-tubo total-tubos tipo-tubo diam-tubo
             cota-tapa prof-tubo cota-tubo
             precRes precDiam sRes sDiam sNum
             ss e pPick verts vStart vSecond vPenul vEnd
             pStart pSecond pPenul pEnd endPicked angRad insPt ok)

  (setq precRes 3)   ; decimales para 'resultado' en atributo
  (setq precDiam 2)  ; decimales para 'diametro' en atributo

  ;; ====== FASE 1: CARGA DE DATOS ======
  (prompt "\n=== P1 v2.0: CARGA AUTOMÁTICA DESDE CSV ===")

  ;; Solicitar archivo SEGUNDA_PASADA.txt
  (setq archivo-segunda (getfiled "Selecciona SEGUNDA_PASADA.txt" "" "txt" 8))
  (if (not archivo-segunda)
    (progn (prompt "\nCancelado.") (princ) (exit))
  )

  ;; Buscar PRIMERA_PASADA.txt en la misma carpeta
  (setq carpeta (vl-filename-directory archivo-segunda))
  (setq archivo-primera (strcat carpeta "\\PRIMERA_PASADA.txt"))

  (if (not (findfile archivo-primera))
    (progn
      (prompt (strcat "\n**ERROR**: No se encontró PRIMERA_PASADA.txt en la carpeta: " carpeta))
      (princ)
      (exit)
    )
  )

  ;; Cargar datos
  (prompt "\nCargando datos...")
  (setq datos-primera (cargar-primera-pasada archivo-primera))
  (setq datos-segunda (cargar-segunda-pasada archivo-segunda))

  (if (or (not datos-primera) (not datos-segunda))
    (progn
      (prompt "\n**ERROR**: No se pudieron cargar los datos.")
      (princ)
      (exit)
    )
  )

  ;; Combinar datos
  (setq tubos-completos (combinar-datos datos-primera datos-segunda))

  (prompt (strcat "\n✓ Datos cargados: "
                  (itoa (length datos-primera)) " pozos, "
                  (itoa (length tubos-completos)) " tubos"))

  ;; ====== FASE 2: PROCESAMIENTO DE TUBOS ======
  (prompt "\n\n=== FASE DE PROCESAMIENTO ===")
  (prompt "\nAhora selecciona polilíneas, extremos y puntos de inserción para cada tubo.\n")

  (setq i 1)

  (foreach tubo tubos-completos
    ;; Extraer datos del tubo
    (setq id-pozo      (cdr (assoc 'ID_POZO tubo)))
    (setq num-tubo     (cdr (assoc 'NUM_TUBO tubo)))
    (setq total-tubos  (cdr (assoc 'TOTAL_TUBOS tubo)))
    (setq tipo-tubo    (cdr (assoc 'TIPO_TUBO tubo)))
    (setq diam-tubo    (cdr (assoc 'DIAM_TUBO tubo)))
    (setq cota-tapa    (cdr (assoc 'COTA_TAPA tubo)))
    (setq prof-tubo    (cdr (assoc 'PROF_TUBO tubo)))
    (setq cota-tubo    (cdr (assoc 'COTA_TUBO tubo)))

    ;; Mostrar información del tubo actual
    (prompt (strcat "\n\n>>> TUBO " (itoa i) " de " (itoa (length tubos-completos)) " <<<"))
    (prompt (strcat "\nPOZO: " id-pozo
                    " | Tubo " (itoa num-tubo) "/" (itoa total-tubos)
                    " | Tipo: " tipo-tubo
                    " | Ø" (_rtosN diam-tubo 0) "cm"))
    (prompt (strcat "\nCota tapa: " (_rtosN cota-tapa precRes) "m"
                    " | Profundidad: " (_rtosN prof-tubo precRes) "m"
                    " → Cota tubo: " (_rtosN cota-tubo precRes) "m"))

    ;; Seleccionar 3D Polyline
    (prompt "\nSelecciona una Polilínea 3D: ")
    (setq ss (entsel))
    (if (or (not ss) (not (car ss)))
      (progn
        (prompt "\nNo has seleccionado entidad. Saltando este tubo.")
        (setq i (+ i 1))
        (continue)
      )
    )

    (setq e (car ss))
    (if (not (_is-3dpoly? e))
      (progn
        (prompt "\n**ERROR**: La entidad no es una Polilínea 3D. Saltando este tubo.")
        (setq i (+ i 1))
        (continue)
      )
    )

    ;; Pedir clic cerca del extremo deseado
    (setq pPick (getpoint (strcat "\nHaz clic cerca del EXTREMO al que quieres asignar Z=" (_rtosN cota-tubo precRes) ": ")))
    (if (not pPick)
      (progn
        (prompt "\nCancelado. Saltando este tubo.")
        (setq i (+ i 1))
        (continue)
      )
    )

    ;; Obtener vértices (WCS) y extremos
    (setq verts (_3dpoly-vertices e))
    (if (< (length verts) 2)
      (progn
        (prompt "\n**ERROR**: La polilínea tiene menos de 2 vértices. Saltando este tubo.")
        (setq i (+ i 1))
        (continue)
      )
    )

    (setq vStart (car verts)
          vSecond (cadr verts)
          vEnd (last verts)
    )
    (setq vPenul (nth (- (length verts) 2) verts))

    (setq pStart (cdr vStart)
          pSecond (cdr vSecond)
          pEnd (cdr vEnd)
          pPenul (cdr vPenul))

    ;; Elegir extremo más cercano al clic (en UCS-2D)
    (setq endPicked
          (if (<= (_d2 (_pt->ucs pPick) (_pt->ucs pStart))
                  (_d2 (_pt->ucs pPick) (_pt->ucs pEnd)))
            'START 'END))

    ;; Fijar Z=cota-tubo en el extremo elegido
    (if (eq endPicked 'START)
      (setq ok (_set-vertex-z (car vStart) cota-tubo))
      (setq ok (_set-vertex-z (car vEnd)   cota-tubo))
    )
    (if (not ok)
      (prompt "\n**ADVERTENCIA**: No se pudo modificar la Z del vértice.")
    )

    ;; Ángulo de orientación en planta (UCS), tangente en el extremo elegido
    (setq angRad
          (if (eq endPicked 'START)
            (angle (_pt->ucs pStart) (_pt->ucs pSecond))
            (angle (_pt->ucs pPenul) (_pt->ucs pEnd))
          )
    )

    ;; Punto de inserción en planta (UCS). Se fuerza Z=0 en la inserción.
    (setq insPt (getpoint "\nPunto de inserción (planta) para el bloque POZO: "))
    (if (not insPt)
      (progn
        (prompt "\nCancelado. Saltando este tubo.")
        (setq i (+ i 1))
        (continue)
      )
    )

    ;; Preparar strings para atributos
    (setq sRes  (_rtosN cota-tubo precRes))
    (setq sDiam (_rtosN diam-tubo precDiam))
    (setq sNum  (itoa total-tubos))

    ;; Insertar bloque y rellenar atributos
    (if (_insert-pozo-with-attrs insPt angRad sRes sDiam sNum)
      (prompt (strcat "\n✓ Bloque POZO insertado para tubo " (itoa i) "."))
      (prompt (strcat "\n✗ ERROR al insertar el bloque POZO para tubo " (itoa i) "."))
    )

    (setq i (+ i 1))
  )

  (prompt (strcat "\n\n=== PROCESO COMPLETADO: " (itoa (length tubos-completos)) " tubos procesados ==="))
  (princ)
)

(princ "\nComando cargado: escribe P1 para carga automática desde CSV.")
(princ)
