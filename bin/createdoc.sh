#!/bin/bash

docDir="../doc"
libDir="../lib"

perldoc -o html -d $docDir/AEdataProc.pm.html ../AEdataProc.pm

perldoc -o Markdown -d ../README.md ../*.pm

perl createLibPod.pl