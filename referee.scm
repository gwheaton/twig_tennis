;; Referee file, state machine for the game flow coupled with actual referee

(define-twig-object referee Child 1 @(-7 0 0) @(1 0 0))
(set! referee.Color Color.White)

;; Listen to the bounding box of the field
(field-bounds.Listeners.Add referee)

(within referee
  (define-state-machine officiate
    (start (enter (begin (titles.Say "testing")
			 (send-game-state 'serve)))
	   (messages (ExitRegionMessage
		      (cond ((eq? $message.PhysicalObject.Name "ball")
			     (log-message "Out of bounds:" $message.PhysicalObject)
			     (referee.Say (String.Format "{0} out of bounds!"
						 $message.PhysicalObject.Name))
			     (send-game-state 'serve))
			    ((eq? $message.PhysicalObject.Name "user")
			     (log-message "Out of bounds:" $message.PhysicalObject)
			     (referee.Say "Get back on the court!"))))))))