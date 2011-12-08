;; Referee file, state machine for the game flow coupled with actual referee

(define-twig-object referee Child 1 @(-7 0 0) @(1 0 0))
(set! referee.Color Color.White)

;; Listen to the bounding box of the field
(field-bounds.Listeners.Add referee)

(define lasthit 0) ;; who last hit for scoring, 0 for user 1 for AI

(within referee
  (define-state-machine officiate
    (serve (enter (begin (titles.Say (String.Format "User: {0} AI: {1}"
						     user-score
						     opponent-score))))
	   (messages ((game-state-message 'userhit)
		      (begin (goto play)))
		     (ExitRegionMessage
		      (begin (if (eq? $message.PhysicalObject.Name "user")
				 (referee.Say "Go serve the ball!"))
			     (send-game-state 'serve)))))
    (play  (messages (ExitRegionMessage
		      (cond ((eq? $message.PhysicalObject.Name "ball")
			     (send-game-state 'outofbounds)
			     (log-message "Out of bounds:" $message.PhysicalObject)
			     (referee.Say (String.Format "{0} out of bounds!"
						 $message.PhysicalObject.Name))
			     (if (= lasthit 0)
				 (set! opponent-score (+ 1 opponent-score))
				 (set! user-score (+ 1 user-score)))
			     (if (= lasthit 0)
				 (send-game-state 'AIscore))
			     (send-game-state 'serve))))
		     ((game-state-message 'serve)
		      (begin (goto serve)))
		     ((game-state-message 'dead)
		      (begin (referee.Say "Dead ball!")
			     (if (> ball.Position.Z 0)
				 (set! opponent-score (+ 1 opponent-score))
				 (set! user-score (+ 1 user-score)))
			     (if (> ball.Position.Z 0)
				 (send-game-state 'AIscore))
			     (send-game-state 'serve)))))))