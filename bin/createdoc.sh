#!/bin/bash

perldoc -o html -d ../doc/doc.html ../*.pm

perldoc -o Markdown -d ../README.md ../*.pm


#pod2html 