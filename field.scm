;; Setting and field

(new-component Wall @(0 0 0) 12 0.5 0.1) ;; the net

(new-component Wall @(6 0 -10) @(6 0 10) 0.1 0.1 Cloaked: true) ;; right side of field
(new-component Wall @(-6 0 -10) @(-6 0 10) 0.1 0.1 Cloaked: true) ;; left side of field
(new-component Wall @(6 0 -10) @(-6 0 -10) 0.1 0.1 Cloaked: true) ;; end 1
(new-component Wall @(-6 0 10) @(6 0 10) 0.1 0.1 Cloaked: true) ;; end 2

(define field-width 12)
(define field-depth 20)

;; Code for the ball
(define-twig-object ball Ball @(5 0 9) @(0 255 50) 0.1)
(within ball
  (define-state-machine ball-state
    (serve (enter (begin (set! this.Position @(5 0 0))))
	   (messages ((game-state-message 'serve)
		      (begin (set! this.Position @(5 0 9))))
		     ((game-state-message 'play)
		      (begin (goto play))))
	   (when (<= 1.5 (distance this.Position (vector 5 0 9)))
	     (begin (set! this.Position @(100 0 100))
		    (send-game-state 'serve))))
    (play (enter (begin (referee.Say "Ball in play")))
	  (when (<= this.Position.Y 0.6)
	    (begin (send-game-state 'dead)
		   (goto dead))))
    (dead (enter (set-timeout 5))
	  (messages (TimeoutMessage
		     (begin (send-game-state 'serve)
			    (goto serve)))))))

;; Code for the force controller for hitting the ball
;;(define controller
  ;;(new ForceController "controller" ball.Nodes ))

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



