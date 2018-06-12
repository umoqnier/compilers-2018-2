#/usr/bin/bash

flex analizador_lss.l

gcc -g -Wpedantic lex.yy.c -lfl -o analizador_lss.o

gdb --args analizador_lss.o accept_simple.c
