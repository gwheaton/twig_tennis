;; Setting and field

(new-component Wall @(0 0 0) 12 0.5 0.1) ;; the net

(new-component Wall @(6 0 -14) @(6 0 14) 0.1 0.1 Cloaked: true) ;; right side of field
(new-component Wall @(-6 0 -14) @(-6 0 14) 0.1 0.1 Cloaked: true) ;; left side of field
(new-component Wall @(6 0 -14) @(-6 0 -14) 0.1 0.1 Cloaked: true) ;; end 1
(new-component Wall @(-6 0 14) @(6 0 14) 0.1 0.1 Cloaked: true) ;; end 2

(define field-width 12)
(define field-depth 28)

;; Code for the ball
(define-twig-object ball Ball @(0 0 1) @(0 255 50) 0.1)
(within ball
  (define-state-machine reset-on-score
    (start (messages ((game-state-message 'serve)
		      (begin (set! this.Position @(0 0 1))))))))

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



