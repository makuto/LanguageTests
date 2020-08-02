#!/bin/sh

sbcl --load Main.lisp \
	 --eval "(sb-ext:save-lisp-and-die \"MainExe\" :toplevel 'main-fun :executable t)"

./MainExe test test2
