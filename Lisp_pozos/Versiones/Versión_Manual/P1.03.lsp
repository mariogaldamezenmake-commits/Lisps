;;; ------------------------------------------------------------
;;; P1.03.lsp – Versión reconstruida con lógica basada en coordenada X
;;; LÓGICA:
;;; - Bloques siempre se leen de izquierda a derecha
;;; - Bloques siempre apuntan en la dirección de la polilínea
;;; - Vértice IZQUIERDO (X menor): punto de inserción EN el vértice
;;; - Vértice DERECHO (X mayor): punto de inserción desplazado 0.65m hacia atrás
;;; Requisito: Usuario debe tener OSNAP activado (endpoint, vertex, node)
;;; Autor: Adaptado para Mario Galdámez – AutoCAD 2026
;;; ------------------------------------------------------------

(vl-load-com)

;; ========================================
;; FUNCIONES AUXILIARES
;; ========================================

(defun _deg->rad (a) (* pi (/ a 180.0)))
(defun _rad->deg (r) (* 180.0 (/ r pi)))
(defun _pt->ucs (p) (trans p 0 1))
(defun _pt->wcs (p) (trans p 1 0))
(defun _xy (p) (list (car p) (cadr p)))
(defun _d2 (p q) (distance (_xy p) (_xy q))) ; distancia en 2D (ignora Z)
(defun _rtosN (n prec) (rtos n 2 prec))      ; real a string con 'prec' decimales

(defun _normalize-angle (ang)
  ;; Normaliza un ángulo a rango [0, 2*PI)
  (while (< ang 0.0)
    (setq ang (+ ang (* 2.0 pi)))
  )
  (while (>= ang (* 2.0 pi))
    (setq ang (- ang (* 2.0 pi)))
  )
  ang
)

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
  ;; Inserta "LA" y rellena atributos por TAG: RESULTADO, DIAMETRODELTUBO, NUMERODETUBOS
  (setq insPtWCS (trans (list (car insPtUCS) (cadr insPtUCS) 0.0) 1 0)) ; UCS->WCS Z=0
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq lay (vla-get-ActiveLayout doc))
  (setq blkSpace (vla-get-Block lay)) ; contenedor del layout activo (Model o Paper)

  (if (not (tblsearch "BLOCK" "LA"))
    (progn (prompt "\n**ERROR**: No existe un bloque llamado 'LA' en el dibujo.") nil)
    (progn
      (setq blkObj (vla-InsertBlock blkSpace
                                    (vlax-3d-point insPtWCS)
                                    "LA"
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
              ((= tag "RESULTADO")       (vla-put-TextString a sResultado))
              ((= tag "DIAMETRODELTUBO") (vla-put-TextString a sDiam))
              ((= tag "NUMERODETUBOS")   (vla-put-TextString a sNum))
            )
          )
        )
      )
      blkObj
    )
  )
)

;; ========================================
;; FUNCIONES DE DETECCIÓN AUTOMÁTICA
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
;; FUNCIÓN PRINCIPAL
;; ========================================

(defun c:P1 (/ ctapa prof diam ntub resultado precRes precDiam
             tolerance pClick foundData e vIdx vData verts
             vStart vSecond vPenul vEnd pStart pSecond pPenul pEnd
             isStart angRad angNorm angDeg insPt
             blkLength xClick xMin xMax isRightVertex offsetAngle
             sRes sDiam sNum ok)

  (setq precRes 3)   ; decimales para 'resultado' en atributo
  (setq precDiam 2)  ; decimales para 'diámetro' en atributo
  (setq tolerance 0.001) ; tolerancia para comparar puntos (1mm)
  (setq blkLength 0.65)  ; longitud de desplazamiento en metros

  ;; ====== SOLICITAR DATOS ======
  (prompt "\n=== P1.03: Ajuste de Z e inserción de bloque LA (reconstruido) ===")
  (prompt "\n⚠️ IMPORTANTE: Asegúrate de tener OSNAP activado (Endpoint, Vertex, Node)\n")

  (setq ctapa (getreal "\nCota de la tapa (real): "))
  (if (not ctapa) (progn (prompt "\nCancelado.") (princ) (exit)))

  (setq prof  (getreal "\nProfundidad (real, positiva si baja): "))
  (if (not prof) (progn (prompt "\nCancelado.") (princ) (exit)))

  (setq diam  (getreal "\nDiámetro del tubo (real): "))
  (if (not diam) (progn (prompt "\nCancelado.") (princ) (exit)))

  (setq ntub  (getint  "\nNúmero de tubos (entero): "))
  (if (not ntub) (progn (prompt "\nCancelado.") (princ) (exit)))

  (setq resultado (- ctapa prof))
  (prompt (strcat "\n>> resultado = " (_rtosN resultado precRes)))

  ;; ====== DETECCIÓN AUTOMÁTICA DE POLILÍNEA Y VÉRTICE ======
  (prompt (strcat "\nHaz click EN el VÉRTICE (con OSNAP) al que quieres asignar Z=" (_rtosN resultado precRes) ": "))
  (setq pClick (getpoint))

  (if (not pClick)
    (progn (prompt "\nCancelado.") (princ) (exit))
  )

  ;; Buscar la polilínea 3D que tiene un vértice exactamente en pClick
  (setq foundData (_find-3dpoly-with-vertex-at pClick tolerance))

  (if (not foundData)
    (progn
      (prompt "\n**ERROR**: No se encontró ninguna polilínea 3D con vértice en ese punto.")
      (prompt "\n           ¿Tienes OSNAP activado? Verifica Endpoint/Vertex/Node.")
      (princ)
      (exit)
    )
  )

  ;; Extraer datos: (polyline-ename vertex-index (vertex-ename . vertex-point))
  (setq e (nth 0 foundData))
  (setq vIdx (nth 1 foundData))
  (setq vData (nth 2 foundData))

  (prompt (strcat "\n✓ Detectada polilínea 3D - Vértice #" (itoa vIdx)))

  ;; Modificar Z del vértice encontrado
  (setq ok (_set-vertex-z (car vData) resultado))
  (if (not ok)
    (prompt "\n**ADVERTENCIA**: No se pudo modificar la Z del vértice.")
    (prompt (strcat "\n✓ Z del vértice ajustada a " (_rtosN resultado precRes)))
  )

  ;; ====== CALCULAR ÁNGULO DE ORIENTACIÓN ======
  ;; Obtener todos los vértices para calcular ángulo de orientación
  (setq verts (_3dpoly-vertices e))
  (if (< (length verts) 2)
    (progn
      (prompt "\n**ERROR**: La polilínea tiene menos de 2 vértices.")
      (princ)
      (exit)
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
  ;; IMPORTANTE: El ángulo es SIEMPRE desde el vértice inicial hacia el segundo
  ;; o desde el penúltimo hacia el final (dirección de la polilínea)
  (setq angRad
        (if isStart
          (angle (_pt->ucs pStart) (_pt->ucs pSecond))
          (angle (_pt->ucs pPenul) (_pt->ucs pEnd))
        )
  )

  (prompt (strcat "\n✓ Ángulo base de la polilínea: " (_rtosN (_rad->deg angRad) 2) "°"))

  ;; ====== CORRECCIÓN DE ORIENTACIÓN PARA LEGIBILIDAD ======
  ;; Normalizar el ángulo entre 0 y 2π
  (setq angNorm (_normalize-angle angRad))

  ;; Si el ángulo está entre 90° y 270° (π/2 y 3π/2), el bloque quedaría boca abajo
  ;; o se leería de derecha a izquierda, así que lo giramos 180°
  (if (and (> angNorm (/ pi 2.0)) (< angNorm (* 1.5 pi)))
    (progn
      (setq angRad (+ angRad pi))
      (setq angRad (_normalize-angle angRad))
      (setq angDeg (_rad->deg angRad))
      (prompt (strcat "\n✓ Ángulo corregido para lectura de izquierda a derecha: " (_rtosN angDeg 2) "°"))
    )
    (progn
      (setq angDeg (_rad->deg angRad))
      (prompt (strcat "\n✓ Ángulo de orientación: " (_rtosN angDeg 2) "°"))
    )
  )

  ;; ====== SOLICITAR PUNTO DE INSERCIÓN ======
  (setq insPt (getpoint "\nPunto de inserción (planta) para el bloque LA: "))
  (if (not insPt) (progn (prompt "\nCancelado.") (princ) (exit)))

  ;; ====== DETERMINAR SI ES VÉRTICE DERECHO (X mayor) ======
  ;; Extraer coordenada X del punto de inserción
  (setq xClick (car insPt))

  ;; Encontrar X mínima y máxima de la polilínea
  (setq xMin (car pStart))
  (setq xMax (car pStart))
  (foreach v verts
    (setq xMin (min xMin (car (cdr v))))
    (setq xMax (max xMax (car (cdr v))))
  )

  ;; Determinar si es vértice derecho (comparar con tolerancia)
  (setq isRightVertex (> (- xClick xMin) (- xMax xClick)))

  (if isRightVertex
    (progn
      ;; Vértice DERECHO: desplazar 0.65m hacia atrás (ángulo + 180°)
      (setq offsetAngle (+ angRad pi))
      (setq insPt (polar insPt offsetAngle blkLength))
      (prompt (strcat "\n✓ Vértice DERECHO detectado - Punto desplazado " (_rtosN blkLength 2) "m hacia la izquierda"))
    )
    (prompt "\n✓ Vértice IZQUIERDO detectado - Punto de inserción en el vértice")
  )

  ;; ====== INSERTAR BLOQUE LA ======
  ;; Preparar strings para atributos
  (setq sRes  (_rtosN resultado precRes))
  (setq sDiam (_rtosN diam     precDiam))
  (setq sNum  (itoa ntub))

  ;; Insertar bloque y rellenar atributos
  (if (_insert-pozo-with-attrs insPt angRad sRes sDiam sNum)
    (prompt "\n✓ Bloque LA insertado y atributos asignados.")
    (prompt "\n**ERROR** al insertar el bloque LA.")
  )

  (princ)
)

(princ "\nComando cargado: P1 - Versión 1.03 reconstruida (Bloque LA)")
(princ)
