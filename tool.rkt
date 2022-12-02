#lang racket/base
(require racket/unit
         drracket/tool
         racket/gui
         mrlib/switchable-button
         racket/class
         images/icons/style
         images/icons/symbol)

(define tool@
  (unit
    (import drracket:tool^)
    (export drracket:tool-exports^)

    (define (phase1) (void))
    (define (phase2) (void))

    (define autorun-mixin
      (mixin ((class->interface text%)) ()

        (define/augment (after-insert start len)
          (inner (void) after-insert start len)
          ;; XXX Steals focus
          (when autorun?
            (send autorun? execute-callback)))
        (define/augment (after-delete start len)
          (inner (void) after-delete start len)
          (when autorun?
            (send autorun? execute-callback)))
        
        (define autorun? #f)
        (define/public (flip-autorun! the-unit-frame)
          (set! autorun? (if autorun? #f the-unit-frame)))

        (super-new)))

    (define autorun-button-mixin
      (mixin (drracket:unit:frame<%>) ()
        (super-new)
        (inherit get-button-panel
                 get-definitions-text)
        (inherit register-toolbar-button)

        (let ()
          (define autorun-icon
            (recycle-icon #:color run-icon-color))
          (define btn
            (new switchable-button%
                 (label "Autorun")
                 (callback (λ (button)
                             (send (get-definitions-text)
                                   flip-autorun!
                                   this)))
                 (parent (get-button-panel))
                 (bitmap autorun-icon)))
          (register-toolbar-button btn #:number 11)
          (send (get-button-panel) change-children
                (λ (l)
                  (cons btn (remq btn l)))))))

    (drracket:get/extend:extend-definitions-text autorun-mixin)
    (drracket:get/extend:extend-unit-frame autorun-button-mixin)))

(provide tool@)
