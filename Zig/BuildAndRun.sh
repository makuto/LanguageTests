#!/bin/sh

~/local/bin/zig build-exe -I. CImportTest.zig && ./CImportTest

~/local/bin/zig build-exe Main.zig \
	&& echo "\n\nRunning:\n\n" \
	&& ./Main operation multiply operationArg1 10.0 numData 10000

echo "\n\nHelp test:\n\n"
./Main
