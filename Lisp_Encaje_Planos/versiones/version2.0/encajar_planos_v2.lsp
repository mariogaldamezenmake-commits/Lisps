;; ============================================================
;; ENCAJAR PLANOS v2.0
;; ============================================================
;; Mejoras respecto a v1.0:
;; - Selecciona y explota el plano origen (recursivamente)
;; - Crea capa "PlanoOrigen" con color magenta
;; - Mueve el plano explotado a dicha capa
;; - Corrige bugs: elimina lineas de referencia, explota bloque final
;; ============================================================

(defun c:EncajarPlanos2 (/ *error* old_osmode old_clayer
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
  ;; Helper Functions
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
  (setq max_explosions 10) ;; Maximum explosion iterations to prevent infinite loop

  (princ "\n============================================")
  (princ "\n   ENCAJAR PLANOS v2.0")
  (princ "\n============================================")

  ;; ---------------------------------------------------------
  ;; STEP 1: Select and Process Source Plan (Plano Origen)
  ;; ---------------------------------------------------------
  (princ "\n\n--- PASO 1: Preparar Plano Origen ---")
  (princ "\nSeleccione TODOS los objetos del PLANO ORIGEN (el plano de referencia):")
  (setq origen_ss (ssget))

  (if (not origen_ss)
    (progn (princ "\nNo se selecciono ningun objeto. Cancelando.") (exit))
  )

  (princ (strcat "\nObjetos seleccionados: " (itoa (sslength origen_ss))))

  ;; Create layer "PlanoOrigen" with magenta color (6)
  (princ "\n\nCreando capa 'PlanoOrigen'...")
  (crear-capa "PlanoOrigen" 6) ;; 6 = Magenta in AutoCAD

  ;; Explode blocks recursively
  (princ "\n\nExplotando bloques del plano origen...")
  (setq explosion_count 0)
  (setq ss_blocks origen_ss)

  (while (and (> (contar-bloques ss_blocks) 0)
              (< explosion_count max_explosions))
    (princ (strcat "\n  Iteracion " (itoa (1+ explosion_count))
                   ": " (itoa (contar-bloques ss_blocks)) " bloques encontrados. Explotando..."))
    (setq ss_blocks (explotar-bloques ss_blocks))
    (setq explosion_count (1+ explosion_count))
  )

  (if (> (contar-bloques ss_blocks) 0)
    (princ (strcat "\n  AVISO: Quedan " (itoa (contar-bloques ss_blocks))
                   " bloques sin explotar (limite de iteraciones alcanzado)."))
    (princ "\n  Todos los bloques han sido explotados correctamente.")
  )

  (princ (strcat "\nTotal de explosiones realizadas: " (itoa explosion_count)))

  ;; Move all exploded objects to PlanoOrigen layer
  (princ "\n\nMoviendo objetos a capa 'PlanoOrigen' con color magenta...")
  (mover-a-capa ss_blocks "PlanoOrigen")
  (princ (strcat "\n  " (itoa (sslength ss_blocks)) " objetos movidos a capa 'PlanoOrigen'."))

  ;; ---------------------------------------------------------
  ;; STEP 2: Select Target Objects and Convert to Block
  ;; ---------------------------------------------------------
  (princ "\n\n--- PASO 2: Seleccionar Plano a Encajar ---")
  (princ "\nSeleccione TODOS los objetos del PLANO QUE DESEA ENCAJAR:")
  (setq target_ss (ssget))

  (if (not target_ss)
    (progn (princ "\nNo se selecciono ningun objeto. Cancelando.") (exit))
  )

  ;; Create a unique block name based on current time
  (setq blk_name (strcat "Encaje_Temp_" (rtos (getvar "CDATE") 2 8)))

  (princ (strcat "\nCreando bloque temporal: " blk_name))

  ;; Create Block at 0,0,0 to preserve absolute coordinates
  (command "_.-BLOCK" blk_name '(0 0 0) target_ss "")

  ;; Insert the block back at 0,0,0
  (command "_.-INSERT" blk_name '(0 0 0) "1" "1" "0")
  (setq target_ent (entlast)) ;; This is now our single object to align

  ;; ---------------------------------------------------------
  ;; STEP 3: Alignment Points
  ;; ---------------------------------------------------------
  (princ "\n\n--- PASO 3: Definir Puntos de Encaje ---")
  (princ "\nSeleccione 2 pares de puntos para Mover, Rotar y Escalar.")

  ;; Point 1
  (initget 1)
  (setq p1_source (force-z-0 (getpoint "\nPunto 1 en el BLOQUE (Origen): ")))
  (initget 1)
  (setq p1_dest (force-z-0 (getpoint p1_source "\nPunto 1 en el PLANO ORIGEN (Destino): ")))
  (command "_.LINE" p1_source p1_dest "")
  (setq line1 (entlast)) ;; Save reference to delete later

  ;; Point 2
  (initget 1)
  (setq p2_source (force-z-0 (getpoint "\nPunto 2 en el BLOQUE (Origen): ")))
  (initget 1)
  (setq p2_dest (force-z-0 (getpoint p2_source "\nPunto 2 en el PLANO ORIGEN (Destino): ")))
  (command "_.LINE" p2_source p2_dest "")
  (setq line2 (entlast)) ;; Save reference to delete later

  ;; ---------------------------------------------------------
  ;; STEP 4: Execute Alignment
  ;; ---------------------------------------------------------
  (princ "\n\n--- PASO 4: Ejecutando Alineacion ---")
  (princ "\nAlineando...")
  (setvar "OSMODE" 0) ;; Disable snaps for command execution

  ;; Command: ALIGN
  (command "_.ALIGN" target_ent "" p1_source p1_dest p2_source p2_dest "" "Y")

  ;; ---------------------------------------------------------
  ;; STEP 5: Cleanup - Explode final block and remove helper lines
  ;; ---------------------------------------------------------
  (princ "\n\n--- PASO 5: Limpieza Final ---")

  ;; Delete helper lines
  (princ "\nEliminando lineas de referencia...")
  (if line1 (entdel line1))
  (if line2 (entdel line2))

  ;; Explode the aligned block to return individual objects
  (princ "\nExplotando bloque alineado para restaurar objetos individuales...")
  (command "_.EXPLODE" target_ent)

  ;; Restore settings
  (setvar "OSMODE" old_osmode)
  (setvar "CLAYER" old_clayer)

  (princ "\n\n============================================")
  (princ "\n   ENCAJE COMPLETADO CORRECTAMENTE")
  (princ "\n============================================")
  (princ "\n- Plano origen: explotado y en capa 'PlanoOrigen' (magenta)")
  (princ "\n- Plano encajado: alineado, escalado y rotado")
  (princ "\n============================================")
  (princ)
)

(princ "\n============================================")
(princ "\n  ENCAJAR PLANOS v2.0 cargado")
(princ "\n  Escriba 'EncajarPlanos2' para iniciar")
(princ "\n============================================")
(princ)
