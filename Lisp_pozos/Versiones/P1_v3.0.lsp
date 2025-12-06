;;; ------------------------------------------------------------
;;; P1_v3.0.lsp – Versión mejorada con detección automática y rotación inteligente
;;; Basado en código del compañero y P1_v2.1
;;; Características:
;;; 1. Detección automática de polilínea y vértice (OSNAP)
;;; 2. Atributos extendidos: COTATAPA, PROFUNDIDAD y Capa especial
;;; 3. Rotación Inteligente: El bloque siempre se coloca legible (no boca abajo)
;;;
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

;; ========================================
;; FUNCIONES DE INSERCIÓN DE BLOQUE POZO
;; ========================================

(defun _insert-pozo-with-attrs (insPtUCS rotRad sResultado sDiam sNum sCtapa sProf
                                         / doc lay blkSpace insPtWCS blkObj var arr tag)
  ;; Inserta "POZO" y rellena atributos por TAG
  (setq insPtWCS (trans (list (car insPtUCS) (cadr insPtUCS) 0.0) 1 0)) ; UCS->WCS Z=0
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq lay (vla-get-ActiveLayout doc))
  (setq blkSpace (vla-get-Block lay))

  (if (not (tblsearch "BLOCK" "POZO"))
    (progn (prompt "\n**ERROR**: No existe un bloque llamado 'POZO' en el dibujo.") nil)
    (progn
      (setq blkObj (vla-InsertBlock blkSpace
                                    (vlax-3d-point insPtWCS)
                                    "POZO"
                                    1.0 1.0 1.0
                                    rotRad))
      (if (= (vla-get-HasAttributes blkObj) :vlax-true)
        (progn
          (setq var (vla-GetAttributes blkObj))
          (setq arr (vlax-safearray->list (vlax-variant-value var)))

          (foreach a arr
            (setq tag (strcase (vla-get-TagString a)))

            (cond
              ((= tag "RESULTADO")
                (vla-put-TextString a sResultado)
              )
              ((= tag "DIAMETRODETUBO")
                (vla-put-TextString a sDiam)
              )
              ((= tag "NUMERODETUBOS")
                (vla-put-TextString a sNum)
              )
              ((= tag "COTATAPA")
                (vla-put-TextString a sCtapa)
                (vla-put-Layer a "00_cota tapa y profundidad")
              )
              ((= tag "PROFUNDIDAD")
                (vla-put-TextString a sProf)
                (vla-put-Layer a "00_cota tapa y profundidad")
              )
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
  (< (distance p1 p2) tol)
)

(defun _find-3dpoly-with-vertex-at (pClick tolerance / ss i e verts v found foundPoly foundIdx foundVertex idx)
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
            (setq verts (_3dpoly-vertices e))
            (setq idx 0)

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
             isStart angRad insPt sRes sDiam sNum sCtapa sProf ok)

  (setq precRes 3)   ; decimales para 'resultado' en atributo
  (setq precDiam 0)  ; decimales para 'diámetro' en atributo
  (setq tolerance 0.001) ; tolerancia para comparar puntos (1mm)

  ;; ====== SOLICITAR DATOS ======
  (prompt "\n=== P1 v3.0: Ajuste Z + Bloque POZO con Rotación Inteligente ===")
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

  (setq isStart (= vIdx 0))

  (setq angRad
        (if isStart
          (angle (_pt->ucs pStart) (_pt->ucs pSecond))
          (angle (_pt->ucs pPenul) (_pt->ucs pEnd))
        )
  )

  ;; --- IMPROVEMENT v3.0: Smart Rotation ---
  ;; Evitar que el bloque salga "boca abajo" o "leyendo hacia la izquierda"
  ;; Rango legible: [-pi/2, pi/2] -> [270°, 90°] (pasando por 0)
  ;; Si el ángulo está entre 90° y 270° (pi/2 y 3pi/2), se gira 180°
  (if (and (> angRad (* 0.5 pi)) (<= angRad (* 1.5 pi)))
    (setq angRad (+ angRad pi))
  )
  ;; ----------------------------------------

  ;; ====== INSERTAR BLOQUE POZO ======
  (setq insPt (getpoint "\nPunto de inserción (planta) para el bloque POZO: "))
  (if (not insPt) (progn (prompt "\nCancelado.") (princ) (exit)))

  ;; Preparar strings para atributos
  (setq sRes  (_rtosN resultado precRes))
  (setq sDiam (_rtosN diam     precDiam))
  (setq sNum  (itoa ntub))
  (setq sCtapa (_rtosN ctapa precRes))
  (setq sProf  (_rtosN prof  precRes))

  ;; Insertar bloque y rellenar atributos
  (if (_insert-pozo-with-attrs insPt angRad sRes sDiam sNum sCtapa sProf)
    (prompt "\n✓ Bloque POZO insertado y atributos asignados.")
    (prompt "\n**ERROR** al insertar el bloque POZO.")
  )

  (princ)
)

(princ "\nComando cargado: P1 v3.0 - Detección automática + Rotación Inteligente")
(princ)
