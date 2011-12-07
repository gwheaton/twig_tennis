;; Setting and field
(define field-width 10)
(define field-depth 16)

(new-component Wall @(0 0 0) field-width 0.5 0.1) ;; the net

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
  ;; Force controller
  (define-force-controller fly ball
    (+ user.FacingDirection (vector -0.2 0.4 0))
    call-activation: 1)
  (define-state-machine ball-state
    (serve (enter (begin (set! this.Position @(4 0 0))
			 (stop fly)))
	   (messages ((game-state-message 'serve)
		      (begin (set! this.Position @(4 0 7))))
		     ((game-state-message 'play)
		      (begin (goto play))))
	   (when (<= 1.5 (distance this.Position (vector 4 0 7)))
	     (begin (set! this.Position @(100 0 100))
		    (send-game-state 'serve))))
    (play (enter (begin (referee.Say "Ball in play")
			(start fly)
			(set-timeout 0.1)
			))
	  (messages (TimeoutMessage
		     (stop fly)))
	  (when (<= this.Position.Y 0.6)
	    (begin (send-game-state 'dead)
		   (goto dead))))
    (dead (enter (begin (set-timeout 5)
			(stop fly)))
	  (messages (TimeoutMessage
		     (begin (send-game-state 'serve)
			    (goto serve)))))))

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



