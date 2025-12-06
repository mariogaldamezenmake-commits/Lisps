;;; ------------------------------------------------------------
;;; P1_v1.2.lsp – Ajusta Z de extremos de 3D Polylines e inserta múltiples bloques POZO
;;; Basado en P1.lsp
;;; Mejora: Permite insertar múltiples pozos en una sola ejecución
;;; Autor: Adaptado para Mario Galdámez – AutoCAD 2026
;;; ------------------------------------------------------------

(vl-load-com)

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

(defun c:P1 (/ nPozos datosLista i ctapa prof diam ntub resultado
             precRes precDiam sRes sDiam sNum
             ss e pPick verts vStart vSecond vPenul vEnd
             pStart pSecond pPenul pEnd endPicked angRad insPt ok
             datoActual)

  (setq precRes 3)  ; decimales para 'resultado' en atributo
  (setq precDiam 2) ; decimales para 'diametro' en atributo

  ;; ====== FASE 1: RECOPILACIÓN DE DATOS ======
  (prompt "\n=== INSERCIÓN MÚLTIPLE DE POZOS ===")
  (setq nPozos (getint "\n¿Cuántos pozos deseas insertar? "))

  (if (or (not nPozos) (<= nPozos 0))
    (progn (prompt "\nCancelado o número inválido.") (princ) (exit))
  )

  (setq datosLista '())
  (setq i 1)

  ;; Recopilar datos de todos los pozos
  (while (<= i nPozos)
    (prompt (strcat "\n\n--- POZO " (itoa i) " de " (itoa nPozos) " ---"))

    (setq ctapa (getreal "\nCota de la tapa (real): "))
    (if (not ctapa)
      (progn (prompt "\nCancelado.") (princ) (exit))
    )

    (setq prof (getreal "\nProfundidad (real, positiva si baja): "))
    (if (not prof)
      (progn (prompt "\nCancelado.") (princ) (exit))
    )

    ;; Validación de profundidad
    (if (<= prof 0)
      (progn
        (prompt "\n**ADVERTENCIA**: La profundidad debería ser positiva.")
      )
    )

    (setq diam (getreal "\nDiámetro del tubo (real): "))
    (if (not diam)
      (progn (prompt "\nCancelado.") (princ) (exit))
    )

    ;; Validación de diámetro
    (if (<= diam 0)
      (progn
        (prompt "\n**ADVERTENCIA**: El diámetro debe ser positivo.")
      )
    )

    (setq ntub (getint "\nNúmero de tubos (entero): "))
    (if (not ntub)
      (progn (prompt "\nCancelado.") (princ) (exit))
    )

    ;; Validación de número de tubos
    (if (<= ntub 0)
      (progn
        (prompt "\n**ADVERTENCIA**: Debe haber al menos 1 tubo.")
      )
    )

    (setq resultado (- ctapa prof))
    (prompt (strcat "\n>> resultado = " (_rtosN resultado precRes)))

    ;; Almacenar datos en lista
    (setq datosLista
      (append datosLista
        (list (list ctapa prof diam ntub resultado))
      )
    )

    (setq i (+ i 1))
  )

  ;; ====== FASE 2: INSERCIÓN DE BLOQUES ======
  (prompt "\n\n=== FASE DE INSERCIÓN ===")
  (prompt "\nAhora selecciona polilíneas, extremos y puntos de inserción para cada pozo.\n")

  (setq i 1)

  (foreach datos datosLista
    (prompt (strcat "\n\n>>> INSERTANDO POZO " (itoa i) " de " (itoa nPozos) " <<<"))

    ;; Extraer datos almacenados
    (setq ctapa (nth 0 datos))
    (setq prof (nth 1 datos))
    (setq diam (nth 2 datos))
    (setq ntub (nth 3 datos))
    (setq resultado (nth 4 datos))

    (prompt (strcat "\nDatos: Cota=" (_rtosN ctapa precRes)
                    " Profundidad=" (_rtosN prof precRes)
                    " Diámetro=" (_rtosN diam precDiam)
                    " Tubos=" (itoa ntub)
                    " Resultado=" (_rtosN resultado precRes)))

    ;; Seleccionar 3D Polyline
    (prompt "\nSelecciona una Polilínea 3D: ")
    (setq ss (entsel))
    (if (or (not ss) (not (car ss)))
      (progn
        (prompt "\nNo has seleccionado entidad. Saltando este pozo.")
        (setq i (+ i 1))
        (continue)
      )
    )

    (setq e (car ss))
    (if (not (_is-3dpoly? e))
      (progn
        (prompt "\n**ERROR**: La entidad no es una Polilínea 3D. Saltando este pozo.")
        (setq i (+ i 1))
        (continue)
      )
    )

    ;; Pedir clic cerca del extremo deseado
    (setq pPick (getpoint "\nHaz clic cerca del EXTREMO al que quieres asignar la Z=resultado: "))
    (if (not pPick)
      (progn
        (prompt "\nCancelado. Saltando este pozo.")
        (setq i (+ i 1))
        (continue)
      )
    )

    ;; Obtener vértices (WCS) y extremos
    (setq verts (_3dpoly-vertices e))
    (if (< (length verts) 2)
      (progn
        (prompt "\n**ERROR**: La polilínea tiene menos de 2 vértices. Saltando este pozo.")
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

    ;; Fijar Z=resultado en el extremo elegido
    (if (eq endPicked 'START)
      (setq ok (_set-vertex-z (car vStart) resultado))
      (setq ok (_set-vertex-z (car vEnd)   resultado))
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
        (prompt "\nCancelado. Saltando este pozo.")
        (setq i (+ i 1))
        (continue)
      )
    )

    ;; Preparar strings para atributos
    (setq sRes  (_rtosN resultado precRes))
    (setq sDiam (_rtosN diam     precDiam))
    (setq sNum  (itoa ntub))

    ;; Insertar bloque y rellenar atributos
    (if (_insert-pozo-with-attrs insPt angRad sRes sDiam sNum)
      (prompt (strcat "\n✓ Bloque POZO " (itoa i) " insertado correctamente."))
      (prompt (strcat "\n✗ ERROR al insertar el bloque POZO " (itoa i) "."))
    )

    (setq i (+ i 1))
  )

  (prompt (strcat "\n\n=== PROCESO COMPLETADO: " (itoa nPozos) " pozos procesados ==="))
  (princ)
)

(princ "\nComando cargado: escribe P1 para inserción múltiple de pozos.")
(princ)
