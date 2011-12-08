;; File for the AI opponent

;;(define-twig-object opponent Child 1 @(0 0 -4))
(set! opponent.Color Color.Red)
(set! opponent.MaxSpeed 30.0)

;; CODE FOR HIT BEHAVIOR
(within opponent
  (define-signal-procedure (move-hand-to arm hand-position)
    (limb-command end-acceleration:
		  (* (- hand-position arm.End.Position)
		     300)))
  (define-right-arm-behavior racket-swing
    (move-hand-to this.Arms.Right
		  (+ this.Arms.Right.Root.Position
		     (vector 0.05
			     this.Arms.Right.Length
			     0)))
    activation: 0))

;; LOCOMOTION
(within opponent
 (define-locomotion-behavior pursue-ball
    (+ (- ball.Position this.Position)
       (- ball.Position this.Position))
    call-activation: 1)
 ;;(define-locomotion-behavior backtocenter
   ;;(- @(0 0 -5) this.Position)
  ;; call-activation: 1)
 (define-posture-behavior backtocenter
   (posture-force pelvis-force:
		  (* 80 (- @(0 0 -5) this.Position)))
   call-activation: 1)
 (define-posture-behavior pursue-ball-lob
   (posture-force pelvis-force:
		 ;; (* -100 (* (- this.Position userpos)
		   ;;  (/ (magnitude (cross (- this.Position userpos) userfd))
		;;	(* (magnitude (- this.Position userpos))
		;;	   (magnitude userfd))))))
		  (* 150 (vector (- ball.Position.X this.Position.X)
				 0 
				 (- ball.Position.Z this.Position.Z))))
		  call-activation: 1)
 (define-posture-behavior pursue-ball-med
   (posture-force pelvis-force:
		;; (* -100 (* (- this.Position userpos)
		  ;;   (/ (magnitude (cross (- this.Position userpos) userfd))
		;;	(* (magnitude (- this.Position userpos))
		;;	   (magnitude userfd))))))
		  (* 180 (vector (- ball.Position.X this.Position.X)
				 0 
				 (- ball.Position.Z this.Position.Z))))
   call-activation: 1)
 (define-posture-behavior pursue-ball-hard
   (posture-force pelvis-force:
		;; (* -100 (* (- this.Position userpos)
		  ;;   (/ (magnitude (cross (- this.Position userpos) userfd))
		;;	(* (magnitude (- this.Position userpos))
		;;	   (magnitude userfd))))))
		  (* 200 (vector (- ball.Position.X this.Position.X)
				 0 
				 (- ball.Position.Z this.Position.Z))))
   call-activation: 1))


;; STATE MACHINE FOR AI
(within opponent
  (define-state-machine opponent-states
    (wait (enter (begin (start backtocenter)))
	  (messages ((game-state-message 'userhit)
		     ;;(if (= hitstrength 0)
		;;	 (set-timeout 0.3)
		;;	 (if (= hitstrength 1)
		;;	     (set-timeout 0.4)
		;;	     (set-timeout 0.5))))
		  ;;  (TimeoutMessage
		     (goto move)))
	  (when (<= (distance this.Position @(0 0 -5)) 0.5)
	    (begin (if (running? backtocenter)
		       (stop backtocenter))))
	  (exit (begin (if (running? backtocenter)
			   (stop backtocenter)))))
    (move (when (<= ball.Position.Z 1.5)
	    (begin (if (= hitstrength 0)
		       (start pursue-ball-lob)
		       (if (= hitstrength 1)
			   (start pursue-ball-med)
			   (start pursue-ball-hard)))))
	  (when (and (<= (distance ball.Position this.SpineTop.Position) 1.8)
		     (<= ball.Position.Z 0.1))
	    (begin
	           (if (running? pursue-ball-lob)
				(stop pursue-ball-lob)
				(if (running? pursue-ball-med)
				    (stop pursue-ball-med)
				    (stop pursue-ball-hard)))
		   (send-game-state 'AIhit)
		   (goto hit)))
	  (messages ((game-state-message 'dead)
		     (begin (if (running? pursue-ball-lob)
				(stop pursue-ball-lob)
				(if (running? pursue-ball-med)
				    (stop pursue-ball-med)
				    (stop pursue-ball-hard)))
			    (goto wait)))
		    ((game-state-message 'outofbounds)
		     (begin
                            (if (running? pursue-ball-lob)
				(stop pursue-ball-lob)
				(if (running? pursue-ball-med)
				    (stop pursue-ball-med)
				    (stop pursue-ball-hard)))
			    (goto wait)))))
    (hit (enter (begin (start racket-swing)
			  (set-timeout 0.2)
			  (set! lasthit 1))) ;; set last hit to the AI now
	   (messages (TimeoutMessage
		      (begin ;;(set! ball.Position (+ this.Arms.Right.End.Position
						   ;; @(0 1 -1)))
			     (stop racket-swing)
			     (goto wait)))
		   ((game-state-message 'dead)
		     (begin (if (running? pursue-ball-lob)
				(stop pursue-ball-lob)
				(if (running? pursue-ball-med)
				    (stop pursue-ball-med)
				    (stop pursue-ball-hard)))
			    (goto wait)))
		    ((game-state-message 'outofbounds)
		     (begin
                            (if (running? pursue-ball-lob)
				(stop pursue-ball-lob)
				(if (running? pursue-ball-med)
				    (stop pursue-ball-med)
				    (stop pursue-ball-hard)))
			    (goto wait)))))))
    
    
