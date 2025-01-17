;;; -*- Gerbil -*-
;;; © vyzo
;;; Generics: macros
package: std/generic

(import :std/generic/dispatch
        (rename-in <MOP> (defmethod defmethod~)))
(export #t (phi: +1 #t))

(begin-syntax
  (defclass (generic-info macro-object) (table procedure))
  (defclass generic-type-info ())
  (defclass (primitive-type-info generic-type-info) (type))
  (defclass (builtin-type-info generic-type-info) (runtime-identifier)))

(defsyntax (defgeneric stx)
  (def (generate-generic id default)
    (with-syntax* ((id id)
                   (default default)
                   (dispatch-table-id (stx-identifier #'id #'id "::t"))
                   (dispatch-table
                    #'(def dispatch-table-id
                        (make-generic 'id default)))
                   (procedure-id (stx-identifier #'id #'id "::apply"))
                   (procedure
                    (syntax/loc stx
                      (def (procedure-id . args)
                        (apply generic-dispatch dispatch-table-id args))))
                   (meta
                    #'(defsyntax id
                        (make-generic-info
                         table: (quote-syntax dispatch-table-id)
                         procedure: (quote-syntax procedure-id)
                         macro:
                         (syntax-rules ()
                           ((_ arg (... ...))
                            (procedure-id arg (... ...)))
                           (id (identifier? #'id) procedure-id))))))
      #'(begin dispatch-table procedure meta)))

  (syntax-case stx ()
    ((_ id)
     (identifier? #'id)
     (generate-generic #'id #f))
    ((_ id default)
     (identifier? #'id)
     (generate-generic #'id #'default))))

(defrules defprimitive-type ()
  ((_ id (type-id ...))
   (and (identifier? #'id)
        (identifier-list? #'(type-id ...)))
   (defsyntax id
     (make-primitive-type-info type: '(type-id ... t)))))

(defsyntax (defbuiltin-type stx)
  (syntax-case stx ()
    ((_ id type-expr)
     (with-syntax ((klass::t (stx-identifier #'id #'id "::t")))
       #'(begin
           (def klass::t type-expr)
           (defsyntax id
             (make-builtin-type-info runtime-identifier: (quote-syntax klass::t))))))))

(defsyntax (defmethod stx)
  (def (class-method-option? x)
    (memq (stx-e x) '(rebind:)))

  (def (generic-type-id? id)
    (and (identifier? id)
         (let (info (syntax-local-value id false))
           (or (generic-type-info? info)
               (runtime-type-info? info)))))

  (def (generic-type-e type-info)
    (cond
     ((primitive-type-info? type-info)
      (with-syntax ((type (@ type-info type)))
        #'(quote type)))
     ((or (runtime-struct-info? type-info)
          (runtime-class-info? type-info)
          (builtin-type-info? type-info))
      (with-syntax ((klass::t (@ type-info runtime-identifier)))
        #'(type-linearize-class klass::t)))
     (else
      (raise-syntax-error #f "Bad syntax; unknown argument type" stx))))

  (def (generic-impl-id generic-id type-ids)
    (datum->syntax generic-id
      (string->symbol
       (string-join
        (map (lambda (id) (symbol->string (stx-e id)))
             (cons generic-id type-ids))
        "::"))))

  (syntax-case stx (@method)
    ((_ (@method id type) impl . opts)
     (with-syntax ((body (stx-cdr stx)))
       (syntax/loc stx
         (defmethod~ . body))))

    ((_ (generic-id (arg-id type-id) ...) body ...)
     (cond
      ((and (identifier? #'generic-id)
            (generic-info? (syntax-local-value #'generic-id false))
            (identifier-list? #'(arg-id ...))
            (stx-andmap generic-type-id? #'(type-id ...)))
       (with-syntax* ((impl-id
                       (generic-impl-id #'generic-id #'(type-id ...)))
                      (@next-method
                       (stx-identifier #'generic-id '@next-method))
                      (generic::t
                       (@ (syntax-local-value #'generic-id)
                          table))
                      ((values type-infos)
                       (stx-map syntax-local-value #'(type-id ...)))
                      ((arg-type ...)
                       (map generic-type-e type-infos))
                      (impl
                       (syntax/loc stx
                         (lambda (arg-id ...) body ...)))
                      (defimpl
                        (syntax/loc stx
                          (def impl-id
                            (let-syntax
                                ((@next-method
                                  (syntax-rules ()
                                    ((_ arg-id ...)
                                     (generic-dispatch-next generic::t impl-id arg-id ...)))))
                              impl)))))
         (syntax/loc stx
           (begin
             defimpl
             (generic-bind! generic::t [arg-type ...] impl-id)))))
      ((not (identifier? #'generic-id))
       (raise-syntax-error #f "Bad syntax; expected method identifier"
                           stx #'generic-id))
      ((not (generic-info? (syntax-local-value #'generic-id false)))
       (raise-syntax-error #f "Bad syntax; expected generic method identifier"
                           stx #'generic-id))
      ((not (identifier-list? #'(arg-id ...)))
       (let (bad-id (find (? (not identifier?)) #'(arg-id ...)))
         (raise-syntax-error #f "Bad syntax; expected identifier"
                             stx bad-id)))
      (else
       (let (bad-id (find (? (not generic-type-id?)) #'(type-id ...)))
         (raise-syntax-error #f "Bad syntax; expected generic type identifier"
                             stx bad-id)))))))
