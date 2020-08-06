; Required installing quicklisp: See https://www.quicklisp.org/beta/
(load "~/quicklisp/setup.lisp") ; I don't want it to be /too/ magical (e.g. relying on user's sbclrc is too magical)
(ql:quickload :cl-ppcre)

(defun prompt-read (prompt)
  (format *query-io* "~a: " prompt)
  (force-output *query-io*)
  (read-line *query-io*))

(defparameter *c++-templates*
  (list :array (list :read (list "
	arrayName#.clear();

	if (!inputJson.HasMember(\"arrayName#\"))
		return;

	const rapidjson::Value& arrayName#JsonArray = inputJson#[\"arrayName#\"];
	int numArrayName# = static_cast<int>(arrayName#JsonArray.Size());
	arrayName#.resize(numArrayName#);

	for (int instanceName#Index = 0; instanceName#Index < numArrayName#; ++instanceName#Index)
	{
		const RapidJsonObject& instanceName#Json = arrayName#JsonArray[instanceName#Index].GetObject();
		instanceType& instanceName# = arrayName#[instanceName#Index]"
                    "[aA]rrayName#" "inputJson#" "instanceType" "[Ii]nstanceName#")
                     :write nil)
        :int (list :read (list "instanceName#.field# = instanceName#Json[\"field#\"].GetInt();"
                               "instanceName#" "field#"))
        :uint (list :read (list "instanceName#.field# = instanceName#Json[\"field#\"].GetUint();"
                               "instanceName#" "field#"))))

(defun template-replace (read-write-template)
  (let ((template-modify (car (getf read-write-template :read)))
        (patterns (cdr (getf read-write-template :read))))
    (dolist (pattern patterns)
      (setf template-modify (cl-ppcre:regex-replace-all pattern template-modify
                                  (prompt-read (format nil "~A" pattern)) :preserve-case t)))
    template-modify))

(defun fulfill-template (order)
  (let ((read-output "")) ;(write-output ""))
    (dolist (template-request order)
      ; TODO More efficient way to concat in-place? e.g. don't concat, just write out a list of strs
      (setf read-output
            (concatenate 'string read-output
             (if (equal (type-of template-request) 'CONS)
                 (fulfill-template template-request) ; List? Recurse
                 (template-replace (getf *c++-templates* template-request))))))
    read-output))

(defun template-create ()
  (let ((template-order (read-from-string (prompt-read "Template order"))))
    (fulfill-template template-order)))

(defun make-argument-details (struct-name &rest arguments)
  `(defstruct ,struct-name ,arguments))

(defun main-fun ()
  (format t "Language Test: SBCL. Args: ~{~A~^, ~}.~%" (cdr sb-ext:*posix-argv*))
  (format t "Code generator~%Example input: (:array (:array (:int :uint)))~%Supported types:")
  (dolist (template-type *c++-templates*)
    (when (equal (type-of template-type) 'KEYWORD)
      (format t "~a~%" template-type)))
  (template-create))
;; (let ((args (make-arguments :num-data 10000 :initial-value 0.0 :operation "" :operation-arg-1 0.0)))
;; (format t args)))
