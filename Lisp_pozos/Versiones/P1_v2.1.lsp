;;; ------------------------------------------------------------
;;; P1_v2.1.lsp – Detección automática de vértice mediante OSNAP
;;; Basado en P1_v2.0.lsp
;;; Mejora: En lugar de seleccionar polilínea + click en extremo,
;;;         solo se hace click en el vértice (con OSNAP activado)
;;;         y se detecta automáticamente la polilínea 3D que contiene ese punto
;;; Requisito: Usuario debe tener OSNAP activado (endpoint, vertex, node)
;;; Autor: Adaptado para Mario Galdámez – AutoCAD 2026
;;; ------------------------------------------------------------

(vl-load-com)

;; ========================================
;; FUNCIONES AUXILIARES (de v2.0)
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
;; NUEVAS FUNCIONES PARA v2.1: DETECCIÓN POR OSNAP
;; ========================================

(defun _points-equal? (p1 p2 tol)
  ;; Compara dos puntos 3D con tolerancia
  ;; Retorna T si están dentro de la tolerancia
  (< (distance p1 p2) tol)
)

(defun _find-3dpoly-with-vertex-at (pClick tolerance / ss i e verts v found foundPoly foundIdx foundVertex idx)
  ;; Busca una polilínea 3D que tenga un vértice exactamente en el punto pClick
  ;; Asume que el usuario usó OSNAP, por lo que pClick está en el vértice exacto
  ;; Retorna: (polyline-ename vertex-index (vertex-ename . vertex-point))
  (setq ss (ssget "X" '((0 . "POLYLINE"))))

  (if (not ss)
    (progn
      (prompt "\n**ERROR**: No hay polilíneas en el dibujo.")
      nil
    )
    (progn
      (setq found nil)
      (setq i 0)

      (while (and (< i (sslength ss)) (not found))
        (setq e (ssname ss i))

        (if (_is-3dpoly? e)
          (progn
            ;; Obtener vértices de esta polilínea
            (setq verts (_3dpoly-vertices e))
            (setq idx 0)

            ;; Buscar si algún vértice coincide con pClick
            (foreach v verts
              (if (_points-equal? (cdr v) pClick tolerance)
                (progn
                  (setq foundPoly e)
                  (setq foundIdx idx)
                  (setq foundVertex v)
                  (setq found T)
                )
              )
              (setq idx (+ idx 1))
            )
          )
        )

        (setq i (+ i 1))
      )

      (if found
        (list foundPoly foundIdx foundVertex)
        nil
      )
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
             tolerance pClick foundData e vIdx vData verts vStart vSecond vPenul vEnd
             pStart pSecond pPenul pEnd isStart angRad insPt ok)

  (setq precRes 3)   ; decimales para 'resultado' en atributo
  (setq precDiam 2)  ; decimales para 'diametro' en atributo
  (setq tolerance 0.001) ; tolerancia para comparar puntos (1mm)

  ;; ====== FASE 1: CARGA DE DATOS ======
  (prompt "\n=== P1 v2.1: DETECCIÓN AUTOMÁTICA DE VÉRTICE CON OSNAP ===")

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
  (prompt "\n⚠️ IMPORTANTE: Asegúrate de tener OSNAP activado (Endpoint, Vertex, Node)")
  (prompt "\nAhora haz click EN el vértice de cada tubo (con OSNAP) y luego en el punto de inserción.\n")

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

    ;; ====== MÉTODO v2.1: Click EN el vértice (con OSNAP) ======
    (prompt (strcat "\nHaz click EN el VÉRTICE (con OSNAP) al que quieres asignar Z=" (_rtosN cota-tubo precRes) "m: "))
    (setq pClick (getpoint))

    (if (not pClick)
      (progn
        (prompt "\nCancelado. Saltando este tubo.")
        (setq i (+ i 1))
        (continue)
      )
    )

    ;; Buscar la polilínea 3D que tiene un vértice exactamente en pClick
    (setq foundData (_find-3dpoly-with-vertex-at pClick tolerance))

    (if (not foundData)
      (progn
        (prompt "\n**ERROR**: No se encontró ninguna polilínea 3D con vértice en ese punto.")
        (prompt "\n           ¿Tienes OSNAP activado? Verifica Endpoint/Vertex/Node.")
        (setq i (+ i 1))
        (continue)
      )
    )

    ;; Extraer datos: (polyline-ename vertex-index (vertex-ename . vertex-point))
    (setq e (nth 0 foundData))
    (setq vIdx (nth 1 foundData))
    (setq vData (nth 2 foundData))

    (prompt (strcat "\n✓ Detectada polilínea 3D - Vértice #" (itoa vIdx)))

    ;; Modificar Z del vértice encontrado
    (setq ok (_set-vertex-z (car vData) cota-tubo))
    (if (not ok)
      (prompt "\n**ADVERTENCIA**: No se pudo modificar la Z del vértice.")
      (prompt (strcat "\n✓ Z del vértice ajustada a " (_rtosN cota-tubo precRes) "m"))
    )

    ;; Obtener todos los vértices para calcular ángulo de orientación
    (setq verts (_3dpoly-vertices e))
    (if (< (length verts) 2)
      (progn
        (prompt "\n**ERROR**: La polilínea tiene menos de 2 vértices. Saltando inserción de bloque.")
        (setq i (+ i 1))
        (continue)
      )
    )

    (setq vStart (car verts)
          vSecond (cadr verts)
          vEnd (last verts)
          vPenul (nth (- (length verts) 2) verts))

    (setq pStart (cdr vStart)
          pSecond (cdr vSecond)
          pEnd (cdr vEnd)
          pPenul (cdr vPenul))

    ;; Determinar si el vértice modificado es el inicial o final
    (setq isStart (= vIdx 0))

    ;; Ángulo de orientación en planta (UCS), tangente en el extremo
    (setq angRad
          (if isStart
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

(princ "\nComando cargado: P1 v2.1 - Detección de vértice con OSNAP desde CSV.")
(princ)
