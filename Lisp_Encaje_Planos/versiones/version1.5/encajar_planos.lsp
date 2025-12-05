(defun c:EncajarPlanos (/ *error* old_osmode target_ss blk_name target_ent p1_source p1_dest p2_source p2_dest)

  ;; ============================================================
  ;; ENCAJAR PLANOS v1.5
  ;; ============================================================
  ;; Based on v1.0 but with specific prompts and auto-scaling
  ;; ============================================================

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

  (princ "\n--- Encajar Planos v1.5 ---")

  ;; ---------------------------------------------------------
  ;; STEP 1: Select Target Objects and Convert to Block
  ;; ---------------------------------------------------------
  ;; Prompt changed as requested
  (princ "\nSelecciona el plano a encajar y dale a intro")
  (setq target_ss (ssget))
  
  (if (not target_ss)
    (progn (princ "\nNo se selecciono ningun objeto. Cancelando.") (exit))
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
  
  ;; Point 1
  ;; Prompts changed as requested
  (initget 1)
  (setq p1_source (force-z-0 (getpoint "\nSelecciona un punto en el plano A ENCAJAR: ")))
  (initget 1)
  (setq p1_dest (force-z-0 (getpoint p1_source "\nSelecciona ese punto en el plano ORIGEN: ")))
  (command "_.LINE" p1_source p1_dest "") ;; Visual feedback
  
  ;; Point 2
  ;; Prompts inferred to match style
  (initget 1)
  (setq p2_source (force-z-0 (getpoint "\nSelecciona otro punto en el plano A ENCAJAR: ")))
  (initget 1)
  (setq p2_dest (force-z-0 (getpoint p2_source "\nSelecciona ese otro punto en el plano ORIGEN: ")))
  (command "_.LINE" p2_source p2_dest "")

  ;; ---------------------------------------------------------
  ;; STEP 3: Execute Alignment
  ;; ---------------------------------------------------------
  (princ "\nAlineando...")
  (setvar "OSMODE" 0) ;; Disable snaps for command execution
  
  ;; Command: ALIGN
  ;; We confirm "Y" for scaling to ensure "el plano origen siempre manda".
  ;; This treats the origin points as the master scale.
  (command "_.ALIGN" target_ent "" p1_source p1_dest p2_source p2_dest "" "_Yes")

  ;; Restore settings
  (setvar "OSMODE" old_osmode)
  
  (princ "\nEncaje completado correctamente.")
  (princ)
)

(princ "\nComando 'EncajarPlanos' v1.5 cargado. Escriba EncajarPlanos para iniciar.")
(princ)
