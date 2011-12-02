;; Setting and field

(new-component Wall @(0 0 0) 12 0.5 0.1) ;; the net

(new-component Wall @(6 0 -14) @(6 0 14) 0.1 0.1) ;; right side of field
(new-component Wall @(-6 0 -14) @(-6 0 14) 0.1 0.1) ;; left side of field
(new-component Wall @(6 0 -14) @(-6 0 -14) 0.1 0.1) ;; end 1
(new-component Wall @(-6 0 14) @(6 0 14) 0.1 0.1) ;; end 2



