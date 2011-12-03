;; Referee file, state machine for the game flow coupled with actual referee

(define-twig-object referee Child 1 @(-7 0 0) @(1 0 0))
(set! referee.Color Color.White)

;; Listen to the bounding box of the field
(field-bounds.Listeners.Add referee)

(within referee
  (define-state-machine officiate
    (serve (enter (begin (titles.Say "testing")))
	   (messages ((game-state-message 'play)
		      (begin (goto play)))
		     (ExitRegionMessage
		      (cond ((eq? $message.PhysicalObject.Name "user")
			     (referee.Say "Go serve the ball!"))))))
    (play  (messages (ExitRegionMessage
		      (cond ((eq? $message.PhysicalObject.Name "ball")
			     (log-message "Out of bounds:" $message.PhysicalObject)
			     (referee.Say (String.Format "{0} out of bounds!"
						 $message.PhysicalObject.Name))
			     ;and update score based on who last hit(against) (global var?)
			     (send-game-state 'serve))))
		     ((game-state-message 'serve)
		      (begin (goto serve)))
		     ((game-state-message 'dead)
		      (begin (referee.Say "Dead ball!")
			     ;and update score based on who last hit it(for) (global var?)
			     ))))))