;;; Heads-up displays used in the game

;;; Specialized message log that ignores collision messages
(new-component MessageLogHUD Keys.M "Non-collision messages"
	       (message-filter (not (or CollisionMessage UserActivityMessage)))
	       Visible: false)

;;; A text overlay for displaying announcements
(define titles (new-component TitleScreen))
(titles.Transparent)