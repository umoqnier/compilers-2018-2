# usr/bin/bash

# Llamada a flex
flex analizador_lss.l

# Llamada al compilador gcc
gcc -Wpedantic lex.yy.c -lfl -o analizador_lss.o

# Ejecución del binario con archivo a analizar como argumento
./analizador_lss.o accept_simple.c
