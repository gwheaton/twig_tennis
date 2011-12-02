; User control

; User movement using R,D,F,G as W,A,S,D replacement due to S being used by Twig
; Movement based on posture forces due to lack of walking system, player levitates

(define-twig-object user Child 1 @(4 0 9))
(set! user.Color Color.Blue)

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

;; CODE FOR HITTING THE BALL

;; State machine for actually implementing the signals and states of hitting the ball
(within user
  (define-state-machine hit
    (normal (when (and (key-down? Keys.Space)
		       (<= (distance ball.Position this.SpineTop.Position) 1))
	      (begin (send-game-state 'play)
		     (set! ball.Position @(0 0 1)))))))