;; ============================================================
;; ENCAJAR PLANOS v3.5
;; ============================================================
;; Fusion: Funcionalidad v2.0 + Prompts v1.5 + Capa Encaje (v3.5)
;; - Selecciona y procesa plano ORIGEN (capa magenta "PlanoOrigen", explotar)
;; - Vuelve a la Capa "0" antes de pedir el segundo plano [MOD v3.5]
;; - Prompts de selección amigables (estilo v1.5)
;; - Alineacion y escala automatica
;; ============================================================

(defun c:EncajarPlanos35 (/ *error* old_osmode old_clayer
                          origen_ss target_ss blk_name target_ent
                          p1_source p1_dest p2_source p2_dest
                          line1 line2 explosion_count max_explosions
                          ss_blocks i ent obj_list)

  ;; ---------------------------------------------------------
  ;; Error handling function
  ;; ---------------------------------------------------------
  (defun *error* (msg)
    (if old_osmode (setvar "OSMODE" old_osmode))
    (if old_clayer (setvar "CLAYER" old_clayer))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  ;; ---------------------------------------------------------
  ;; Helper Functions (from v2.0)
  ;; ---------------------------------------------------------

  ;; Force Z=0 (Strict 2D Mode)
  (defun force-z-0 (pt)
    (list (car pt) (cadr pt) 0.0)
  )

  ;; Create or get layer with specified color
  (defun crear-capa (nombre color / layer_data)
    (if (not (tblsearch "LAYER" nombre))
      (progn
        ;; Create new layer
        (command "_.LAYER" "_Make" nombre "_Color" (itoa color) nombre "")
        (princ (strcat "\nCapa '" nombre "' creada con color " (itoa color) "."))
      )
      (progn
        ;; Layer exists, ensure color is correct
        (command "_.LAYER" "_Color" (itoa color) nombre "")
        (princ (strcat "\nCapa '" nombre "' ya existe. Color actualizado."))
      )
    )
  )

  ;; Count blocks in selection set
  (defun contar-bloques (ss / count i ent etype)
    (setq count 0)
    (if ss
      (progn
        (setq i 0)
        (while (< i (sslength ss))
          (setq ent (ssname ss i))
          (setq etype (cdr (assoc 0 (entget ent))))
          (if (= etype "INSERT")
            (setq count (1+ count))
          )
          (setq i (1+ i))
        )
      )
    )
    count
  )

  ;; Explode all blocks in selection set and return new selection
  (defun explotar-bloques (ss / i ent etype new_ss last_ent)
    (setq new_ss (ssadd))
    (if ss
      (progn
        (setq i 0)
        (while (< i (sslength ss))
          (setq ent (ssname ss i))
          (setq etype (cdr (assoc 0 (entget ent))))
          (if (= etype "INSERT")
            (progn
              ;; Get last entity before explode
              (setq last_ent (entlast))
              ;; Explode this block
              (command "_.EXPLODE" ent)
              ;; Add all new entities to new selection
              (while (setq last_ent (entnext last_ent))
                (ssadd last_ent new_ss)
              )
            )
            ;; Not a block, keep it in new selection
            (ssadd ent new_ss)
          )
          (setq i (1+ i))
        )
      )
    )
    new_ss
  )

  ;; Move all entities in selection set to specified layer
  (defun mover-a-capa (ss nombre_capa / i ent entdata)
    (if ss
      (progn
        (setq i 0)
        (while (< i (sslength ss))
          (setq ent (ssname ss i))
          (setq entdata (entget ent))
          ;; Change layer (DXF code 8)
          (if (assoc 8 entdata)
            (setq entdata (subst (cons 8 nombre_capa) (assoc 8 entdata) entdata))
            (setq entdata (append entdata (list (cons 8 nombre_capa))))
          )
          ;; Change color to BYLAYER (DXF code 62 = 256)
          (if (assoc 62 entdata)
            (setq entdata (subst (cons 62 256) (assoc 62 entdata) entdata))
          )
          (entmod entdata)
          (setq i (1+ i))
        )
      )
    )
  )



  ;; ---------------------------------------------------------
  ;; MAIN PROGRAM START
  ;; ---------------------------------------------------------

  ;; Save system variables
  (setq old_osmode (getvar "OSMODE"))
  (setq old_clayer (getvar "CLAYER"))
  (setq max_explosions 10)

  (princ "\n--- Encajar Planos v3.5 ---")

  ;; ---------------------------------------------------------
  ;; STEP 1: Select and Process Source Plan (Plano Origen)
  ;; ---------------------------------------------------------
  ;; Using friendly prompt style
  (princ "\nSelecciona el plano ORIGEN y dale a intro")
  (setq origen_ss (ssget))

  (if (not origen_ss)
    (progn (princ "\nNo se selecciono ningun objeto. Cancelando.") (exit))
  )

  ;; Process Origin (v2.0 logic)
  (princ "\nProcesando plano origen...")
  (crear-capa "PlanoOrigen" 6) ;; Magenta

  ;; Explode blocks recursively
  (setq explosion_count 0)
  (setq ss_blocks origen_ss)

  (while (and (> (contar-bloques ss_blocks) 0)
              (< explosion_count max_explosions))
    (setq ss_blocks (explotar-bloques ss_blocks))
    (setq explosion_count (1+ explosion_count))
  )

  ;; Move to layer
  (mover-a-capa ss_blocks "PlanoOrigen")
  
  ;; [MODIFICACION v3.5] Reset to Layer 0 after processing Origin
  (setvar "CLAYER" "0")

  ;; ---------------------------------------------------------
  ;; STEP 2: Select Target Objects
  ;; ---------------------------------------------------------
  ;; v1.5 Prompt
  (princ "\nSelecciona el plano a encajar y dale a intro")
  (setq target_ss (ssget))

  (if (not target_ss)
    (progn (princ "\nNo se selecciono ningun objeto. Cancelando.") (exit))
  )

  ;; Create Block temp
  (setq blk_name (strcat "Encaje_Temp_" (rtos (getvar "CDATE") 2 8)))
  (command "_.-BLOCK" blk_name '(0 0 0) target_ss "")
  (command "_.-INSERT" blk_name '(0 0 0) "1" "1" "0")
  (setq target_ent (entlast))

  ;; ---------------------------------------------------------
  ;; STEP 3: Alignment Points
  ;; ---------------------------------------------------------
  (princ "\n--- Definir Puntos de Encaje ---")

  ;; Point 1 (v1.5 prompts)
  (initget 1)
  (setq p1_source (force-z-0 (getpoint "\nSelecciona un punto en el plano A ENCAJAR: ")))
  (initget 1)
  (setq p1_dest (force-z-0 (getpoint p1_source "\nSelecciona ese punto en el plano ORIGEN: ")))
  (command "_.LINE" p1_source p1_dest "")
  (setq line1 (entlast))

  ;; Point 2 (v1.5 prompts)
  (initget 1)
  (setq p2_source (force-z-0 (getpoint "\nSelecciona otro punto en el plano A ENCAJAR: ")))
  (initget 1)
  (setq p2_dest (force-z-0 (getpoint p2_source "\nSelecciona ese otro punto en el plano ORIGEN: ")))
  (command "_.LINE" p2_source p2_dest "")
  (setq line2 (entlast))

  ;; ---------------------------------------------------------
  ;; STEP 4: Execute Alignment
  ;; ---------------------------------------------------------
  (princ "\nAlineando...")
  (setvar "OSMODE" 0)

  ;; ALIGN "Yes" to scale (v1.5/v2.0 logic)
  (command "_.ALIGN" target_ent "" p1_source p1_dest p2_source p2_dest "" "_Yes")

  ;; ---------------------------------------------------------
  ;; STEP 5: Cleanup
  ;; ---------------------------------------------------------
  (if line1 (entdel line1))
  (if line2 (entdel line2))
  
  ;; (command "_.EXPLODE" target_ent) ;; DESACTIVADO por peticion usuario: mantener como bloque

  ;; Restore settings
  (setvar "OSMODE" old_osmode)
  (setvar "CLAYER" old_clayer)

  (princ "\nEncaje completado correctamente. (v3.5)")
  (princ)
)

(princ "\nComando 'EncajarPlanos35' cargado. Usa 'EncajarPlanos35' para ejecutar.")
(princ)
