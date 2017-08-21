#!/bin/bash
# run in basedir/bin: ./createdoc.sh

docDir="../doc"
libDir="../lib"

perldoc -o html -d $docDir/AEdataProc.pm.html ../AEdataProc.pm

#perldoc needs Pod::Perldoc::ToMarkdown !!!
perldoc -o Markdown -d ../README.md ../AEdataProc.pm

perl createLibPod.pl