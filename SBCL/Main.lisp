(defstruct arguments num-data
   initial-value
   operation
   operation-arg-1)

(defun main ()
  (format t "Language Test: SBCL")
  (let ((args (make-arguments :num-data 10000 :initial-value 0.0 :operation "" :operation-arg-1 0.0)))
    (format t args)))
