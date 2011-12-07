;; Setting and field
(define field-width 10)
(define field-depth 16)

(new-component Wall @(0 0 0) field-width 0.8 0.1) ;; the net

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
  ;; Force controllers for user hits
  (define-force-controller userhitlob ball
    (+ user.FacingDirection (vector -0.1 0.35 0.2))
    call-activation: 1)
  (define-force-controller userhitmed ball
    (+ user.FacingDirection (vector -0.15 0.3 -0.1))
    call-activation: 1)
  (define-force-controller userhithard ball
    (+ user.FacingDirection (vector -0.2 0.25 -0.3))
    call-activation: 1)
  ;; Force controllers for AI hits
  (define-force-controller AIhitlob ball
    (+ opponent.FacingDirection (vector 0.1 0.35 -0.2))
    call-activation: 1)
  (define-force-controller AIhitmed ball
    (+ opponent.FacingDirection (vector 0.15 0.3 0.1))
    call-activation: 1)
  (define-force-controller AIhithard ball
    (+ opponent.FacingDirection (vector 0.2 0.25 0.3))
    call-activation: 1)
  (define-state-machine ball-state
    (serve (enter (begin (set! this.Position @(4 0 0))
			 (if (running? userhitlob)
			     (stop userhitlob)
			     (if (running? userhitmed)
				 (stop userhitmed)
				 (stop userhithard)))))
	   (messages ((game-state-message 'serve)
		      (begin (set! this.Position @(4 0 7))))
		     ((game-state-message 'userhit)
		      (begin (goto play))))
	   (when (<= 1.5 (distance this.Position (vector 4 0 7)))
	     (begin (set! this.Position @(100 0 100))
		    (send-game-state 'serve))))
    (play (enter (begin (referee.Say "Ball in play")
			(if (< power 0.3)
			    (start userhitlob)
			    (if (< power 1)
				(start userhitmed)
				(start userhithard)))
			(set-timeout 0.1)))
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
				     (stop AIhithard)))))
		    ((game-state-message 'userhit)
		     (begin (if (< power 0.3)
			    (start userhitlob)
			    (if (< power 1)
				(start userhitmed)
				(start userhithard)))
			    (set-timeout 0.1)))
		    ((game-state-message 'AIhit)
		     (begin ;; code for calculating which one to use here, globals vars set by opponent when he sends 'AIhit?
		       (start AIhitlob)
		       (set-timeout 0.1))))
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



