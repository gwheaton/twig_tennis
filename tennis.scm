;; Main program file
;(Debugger.Launch)

(require 'state-machines)

(define (send-game-state args ...)
  (game.SendMessage (new GameStateMessage null args)))

(define end-game-score 10)
(define user-score 0)
(define opponent-score 0)

;; Global declarations, vars
(define-twig-object ball Ball @(4 0 7) @(0 255 50) 0.1)
(define-twig-object user Child 1 @(3 0 7) @(0 0 -1))
(define-twig-object opponent Child 1 @(0 0 -4.5))

;; for AI calculations
(define hitstrength 0) ;; for AI, 0 if lob, 1 if med, 2 if hard
(define userpos @(0 0 0)) ;; user position when hit
(define userfd @(0 0 0)) ;; user facing direciton when hit

(within ball
  (define power 0))

;; Load files here
(load "HUDs.scm")
(load "user.scm")
(load "opponent.scm")
(load "field.scm")
(load "referee.scm")

;; Camera
(set! TwigGame.CurrentGame.CameraPosition @(0 5 16))


