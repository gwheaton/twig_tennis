;; Main program file
;(Debugger.Launch)

(require 'state-machines)

(define (send-game-state args ...)
  (game.SendMessage (new GameStateMessage null args)))

(define end-game-score 10)
(define user-score 0)
(define opponent-score 0)

;; Load files here
(load "field.scm")
(load "user.scm")
(load "opponent.scm")
(load "referee.scm")