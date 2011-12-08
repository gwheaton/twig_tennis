;; Main program file
;(Debugger.Launch)

(require 'state-machines)

(define (send-game-state args ...)
  (game.SendMessage (new GameStateMessage null args)))

(define end-game-score 10)
(define user-score 0)
(define opponent-score 0)

;; Global declarations, vars
(define-twig-object tree1 Tree @(-10 0 -12))
(define-twig-object tree2 Tree @(10 0 -14))
(define-twig-object tree3 Tree @(4 0 -23))
(define-twig-object cheerer1 Adult @(4 0 -15) @(0 0 1))
(define-twig-object cheerer2 Adult @(-2 0 -13) @(0 0 1))
(define-twig-object cheerer3 Adult @(-5 0 -14) @(0 0 1))
(within (list cheerer1 cheerer2 cheerer3)
  (set! this.Color Color.Purple))
(define-twig-object ball Ball @(4 0 7) @(0 255 50) 0.1)
(define-twig-object shadow Ball @(4 0 7) @(0 0 0) 0.05 Cloaked: True)
(define-twig-object user Child 1 @(3 0 7) @(0 0 -1))
(define-twig-object opponent Child 1.8 @(0 0 -6))

;; for AI calculations
(define hitstrength 0) ;; for AI, 0 if lob, 1 if med, 2 if hard

(within ball
  (define-signal ballpos ball.Position))

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
;;(set! TwigGame.CurrentGame.CameraPosition @(14 5 0))
