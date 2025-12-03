(defun c:EncajarPlanos (/ *error* old_osmode target_ss blk_name target_ent p1_source p1_dest p2_source p2_dest)

  ;; Error handling function
  (defun *error* (msg)
    (if old_osmode (setvar "OSMODE" old_osmode))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  ;; Save system variables
  (setq old_osmode (getvar "OSMODE"))
  
  ;; Helper to force Z=0 (Strict 2D Mode)
  (defun force-z-0 (pt)
    (list (car pt) (cadr pt) 0.0)
  )

  (princ "\n--- Encajar Planos (Modo Simplificado) ---")

  ;; ---------------------------------------------------------
  ;; STEP 1: Select Target Objects and Convert to Block
  ;; ---------------------------------------------------------
  (princ "\nSeleccione TODOS los objetos del plano que desea encajar:")
  (setq target_ss (ssget))
  
  (if (not target_ss)
    (progn (princ "\nNo se seleccionó ningún objeto. Cancelando.") (exit))
  )

  ;; Create a unique block name based on current time
  (setq blk_name (strcat "Encaje_Temp_" (rtos (getvar "CDATE") 2 6)))
  
  (princ (strcat "\nCreando bloque temporal: " blk_name))
  
  ;; Create Block at 0,0,0 to preserve absolute coordinates
  (command "_.-BLOCK" blk_name '(0 0 0) target_ss "")
  
  ;; Insert the block back at 0,0,0
  (command "_.-INSERT" blk_name '(0 0 0) "1" "1" "0")
  (setq target_ent (entlast)) ;; This is now our single object to align

  ;; ---------------------------------------------------------
  ;; STEP 2: Alignment Points
  ;; ---------------------------------------------------------
  (princ "\n--- Definir Puntos de Encaje ---")
  (princ "\nSeleccione 2 pares de puntos para Mover, Rotar y Escalar.")

  ;; Point 1
  (initget 1)
  (setq p1_source (force-z-0 (getpoint "\nPunto 1 en el BLOQUE (Origen): ")))
  (initget 1)
  (setq p1_dest (force-z-0 (getpoint p1_source "\nPunto 1 en el PLANO ORIGEN (Destino): ")))
  (command "_.LINE" p1_source p1_dest "") ;; Visual feedback
  
  ;; Point 2
  (initget 1)
  (setq p2_source (force-z-0 (getpoint "\nPunto 2 en el BLOQUE (Origen): ")))
  (initget 1)
  (setq p2_dest (force-z-0 (getpoint p2_source "\nPunto 2 en el PLANO ORIGEN (Destino): ")))
  (command "_.LINE" p2_source p2_dest "")

  ;; ---------------------------------------------------------
  ;; STEP 3: Execute Alignment
  ;; ---------------------------------------------------------
  (princ "\nAlineando...")
  (setvar "OSMODE" 0) ;; Disable snaps for command execution
  
  ;; Command: ALIGN
  ;; Select objects: target_ent
  ;; Enter ("")
  ;; Source 1 -> Dest 1
  ;; Source 2 -> Dest 2
  ;; Enter ("") to finish points (2D align only needs 2 points usually, or 3rd point is nil)
  ;; Scale objects based on alignment points? [Yes/No] <N>: Y
  
  (command "_.ALIGN" target_ent "" p1_source p1_dest p2_source p2_dest "" "Y")

  ;; Restore settings
  (setvar "OSMODE" old_osmode)
  
  (princ "\nEncaje completado correctamente.")
  (princ)
)

(princ "\nComando 'EncajarPlanos' cargado. Escriba EncajarPlanos para iniciar.")
