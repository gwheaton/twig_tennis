;; Setting and field
(define field-width 10)
(define field-depth 16)

;; Cloaked shadow ball
(within shadow
  (define-state-machine shadow-state
    (normal (enter
	      (begin (set! this.Position (vector ball.ballpos.BoxedValue.X
						 0.1
						 ball.ballpos.BoxedValue.Z))
		     (set-timeout 0.01)))
	    (messages (TimeoutMessage
		       (goto normal))))))

;; Cloaked shadow ball
;;(within shadow
  ;;(define-state-machine shadow-state
    ;;(normal (enter
;;	      (begin (set! this.Position.X ballposX)
;;		     (user.Say "Made it to normal")
;;		     (goto wait))))
  ;;  (wait (enter
;;	   (begin (user.Say "made it to wait")
;;		  (set-timeout 0.1)))
;;	  (messages (TimeoutMessage
;;		     (goto normal))))))

(new-component Wall @(0 0 0) field-width 1 0.1) ;; the net
  
(new-component Wall @(5 0 -8) 
	       @(5 0 8) 
	       0.1 
	       0.1 
	       Cloaked: true) ;; right side of field
(new-component Wall @(-5 0 -8)
	       @(-5 0 8)
	       0.1 
	       0.1 
	       Cloaked: true) ;; left side of field
(new-component Wall @(5 0 -8) 
	       @(-5 0 -8)
	       0.1
	       0.1 
	       Cloaked: true) ;; end 1
(new-component Wall @(-5 0 8) 
	       @(5 0 8) 
	       0.1 
	       0.1 
	       Cloaked: true) ;; end 2


;; Code for the ball
(within ball
  ;; Force controllers for user hit serves
  (define-force-controller userhitlobS ball
    (+ user.FacingDirection (vector 0 0.9 -0.8))
    call-activation: 1)
  (define-force-controller userhitmedS ball
    (+ user.FacingDirection (vector 0 0.7 -1.5))
    call-activation: 1)
  (define-force-controller userhithardS ball
    (+ user.FacingDirection (vector 0 0.5 -2.5))
    call-activation: 1)
  ;; User hit normals
  (define-force-controller userhitlob ball
    (+ user.FacingDirection (vector -0.1 2 -2.9))
    call-activation: 1)
  (define-force-controller userhitmed ball
    (+ user.FacingDirection (vector -0.15 1.5 -3.7))
    call-activation: 1)
  (define-force-controller userhithard ball
    (+ user.FacingDirection (vector -0.2 1 -4.7))
    call-activation: 1)
  ;; Force controllers for AI hits
  (define-force-controller AIhitlob ball
    (+ @(0 0 1) (vector 0.1 1.4 2.4))
    call-activation: 1)
  (define-force-controller AIhitmed ball
    (+ @(0 0 1) (vector 0.15 1.1 3.3))
    call-activation: 1)
  (define-force-controller AIhithard ball
    (+ @(0 0 1) (vector 0.2 0.7 4.2))
    call-activation: 1)
  (define-state-machine ball-state
    (serve (enter (begin (set! this.Position @(4 0 0))
			 (if (running? userhitlobS)
			     (stop userhitlobS)
			     (if (running? userhitmedS)
				 (stop userhitmedS)
				 (stop userhithardS)))))
	   (messages ((game-state-message 'serve)
		      (begin (set! this.Position @(4 0 7))))
		     ((game-state-message 'userhit)
		      (begin (goto play))))
	   (when (<= 1.5 (distance this.Position (vector 4 0 7)))
	     (begin (set! this.Position @(100 0 100))
		    (send-game-state 'serve))))
    (play (enter (begin (referee.Say "Ball in play")
			(if (< power 0.3)
			    (start userhitlobS)
			    (if (< power 1)
				(start userhitmedS)
				(start userhithardS)))
			(if (< power 0.3)
			    (set! hitstrength 0)
			    (if (< power 1)
				(set! hitstrength 1)
				(set! hitstrength 2)))
			(if (= hitstrength 0)
			    (set! ball.Color Color.GreenYellow)
			    (if (= hitstrength 1)
				(set! ball.Color Color.Yellow)
				(set! ball.Color Color.Orange)))
			(set-timeout 0.05)))
	  (messages (TimeoutMessage
		      (begin (if (running? userhitlob)
				 (stop userhitlob)
				 (if (running? userhitmed)
				     (stop userhitmed)
				     (stop userhithard)))
			     (if (running? AIhitlob)
				 (stop AIhitlob)
				 (if (running? AIhitmed)
				     (stop AIhitmed)
				     (stop AIhithard)))
			     (if (running? userhitlobS)
				 (stop userhitlobS)
				 (if (running? userhitmedS)
				     (stop userhitmedS)
				     (stop userhithardS)))))
		    ((game-state-message 'userhit)
		     (begin (if (< power 0.3)
				(start userhitlob)
				(if (< power 1)
				    (start userhitmed)
				    (start userhithard)))
			    (if (< power 0.3)
				(set! hitstrength 0)
				(if (< power 1)
				    (set! hitstrength 1)
				    (set! hitstrength 2)))
			    (if (= hitstrength 0)
				(set! ball.Color Color.GreenYellow)
				(if (= hitstrength 1)
				    (set! ball.Color Color.Yellow)
				    (set! ball.Color Color.Orange)))
			    (set-timeout 0.05)))
		    ((game-state-message 'AIhit)
		     (begin ;; code for calculating which one to use here, globals vars set by opponent when he sends 'AIhit?
		       (if (= hitstrength 0)
			   (start AIhitlob)
			   (if (= hitstrength 1)
			       (start AIhitmed)
			       (start AIhithard)))
		       (if (= hitstrength 0)
			   (set! ball.Color Color.GreenYellow)
			   (if (= hitstrength 1)
			       (set! ball.Color Color.Yellow)
			       (set! ball.Color Color.Orange)))
		       (set-timeout 0.05))))
	  (when (<= this.Position.Y 0.6)
	    (begin (send-game-state 'dead)
		   (goto dead))))
    (dead (enter (begin (set-timeout 5)
			(if (running? userhitlob)
			     (stop userhitlob)
			     (if (running? userhitmed)
				 (stop userhitmed)
				 (stop userhithard)))
			(if (running? AIhitlob)
			    (stop AIhitlob)
			    (if (running? AIhitmed)
				(stop AIhitmed)
				(stop AIhithard)))))
	  (messages (TimeoutMessage
		     (begin (send-game-state 'serve)
			    (goto serve))))))
  (define start-time 0)
  (define-state-machine power
    (start (when (key-down? Keys.Space)
		      (begin ;;(user.Say (String.Format "{0}" start-time))
			(set! start-time Physics.Time)))
	   (messages ((key-up? Keys.Space)
		      (begin ;;(user.Say (String.Format "{0}" start-time))
			(set! power (- Physics.Time start-time))))))))    

;; Code for the bounding box of the field
(define field-bounds
  (new-component SpatialTrigger
		 "field-bounds"
		 (new BoundingBox
		      (vector (* field-width
				 -0.5)
			      -100
			      (* field-depth -0.5))
		      (vector (* field-width
				 0.5)
			      100
			      (* field-depth 0.5)))))
				  

;; Parent behaviors
(within (list cheerer1 cheerer2 cheerer3)
	(define-signal timeSpent (true-time true))
	(define-signal switch (if (= (mod timeSpent 0.1) 0)
				  true
				  false))
	(define-signal onFirstStep (toggle switch false))
	(define-signal-procedure (move-hand-to arm hand-position)
	  (limb-command end-acceleration:
			(* (- hand-position arm.End.Position)
			   200)))
	(define-right-arm-behavior cheerRight
		      (move-hand-to this.Arms.Right
				    (+ this.Arms.Right.Root.Position
				       (if onFirstStep
					   (vector 0.05
						   this.Arms.Right.Length
						   0)
					   (vector -0.3
						   this.Arms.Right.Length
						   0))))
	  activation: 0)
	(define-left-arm-behavior cheerLeft
		      (move-hand-to this.Arms.Left
				    (+ this.Arms.Left.Root.Position
				       (if onFirstStep
					   (vector -0.05
						   this.Arms.Left.Length
						   0)
					   (vector 0.3
						   this.Arms.Left.Length
						   0))))
	  activation: 0))

;; State machine for cheerers
(within (list cheerer1 cheerer2 cheerer3)
	(define-state-machine cheerer-states
	  (idle (enter (begin (stop cheerLeft)
			      (stop cheerRight)))
		(messages ((game-state-message 'AIscore)
			   (begin (goto cheer)))))
	  (cheer (enter (begin (start cheerLeft)
			       (start cheerRight)
			       (if (= hitstrength 0)
				   (this.Say "take that!")
				   (if (= hitstrength 1)
				       (this.Say "lolololololol")
				       (this.Say "de-nied")))))
		 (messages ((game-state-message 'userhit)
			    (begin (goto idle)))))))