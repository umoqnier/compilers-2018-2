# usr/bin/bash

# Borrando archivos
rm -f lex.yy.c analizador_lexico.o

flex analizador_lexico.l
gcc -lfl lex.yy.c -o analizador_lexico.o
./analizador_lexico.o example.c
cat salida.txt
