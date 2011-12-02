; User control

; User movement using R,D,F,G as W,A,S,D replacement due to S being used by Twig
; Movement based on posture forces due to lack of walking system, player levitates

(define-twig-object user Child 1 @(4 0 9))
(set! user.Color Color.Blue)
(set! user.FacingDirection @(0 0 -1))

;; CODE TO DEFINE MOVEMENT - LEAVE AS IS

(within user
	(define-signal up-vect (if (key-down? Keys.R) @(0 0 -1.1) @(0 0 0))))
(within user
	(define-signal down-vect (if (key-down? Keys.F) @(0 0 0.8)  @(0 0 0))))
(within user
	(define-signal right-vect (if (key-down? Keys.G) @(1 0 0) @(0 0 0))))
(within user
	(define-signal left-vect (if (key-down? Keys.D) @(-1 0 0) @(0 0 0))))

(within user
	(define-posture-behavior movement
	  (posture-force pelvis-force: 
			 (+ up-vect down-vect left-vect right-vect))
	  activation: 250))

;; CODE FOR HIT BEHAVIOR
(within user
  (define-signal-procedure (move-hand-to arm hand-position)
    (limb-command end-acceleration:
		  (* (- hand-position arm.End.Position)
		     300)))
  (define-left-arm-behavior racket-swing
    (move-hand-to this.Arms.Left
		  (+ this.Arms.Left.Root.Position
		     (vector 0.05
			     this.Arms.Left.Length
			     0)))
    activation: 0))
  

;; CODE FOR HITTING THE BALL

;; State machine for actually implementing the signals and states of hitting the ball
(within user
  (define-state-machine user-states
    (normal (when (and (key-down? Keys.Space)
		       (<= (distance ball.Position this.SpineTop.Position) 1))
	      (begin (send-game-state 'play)
		     (goto hit)))
	    (when (and (key-down? Keys.Space)
		       (> (distance ball.Position this.SpineTop.Position) 1))
	      (begin (goto idle))))
    (idle  (enter (begin (start racket-swing)
			 (set-timeout 1.5)))
	   (messages (TimeoutMessage
		     (stop racket-swing)
		     (begin (goto normal)))))
    (hit (enter (begin (start racket-swing)
			  (set-timeout 0.1)))
	   (messages (TimeoutMessage
		      (begin (set! ball.Position @(0 0 1))
			     (stop racket-swing)
			     (goto normal)))))))