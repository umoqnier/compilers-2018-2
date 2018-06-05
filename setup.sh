# usr/bin/bash

# Llamada a flex
flex analizador_lexico_sintactico.l

# Llamada al compilador gcc
gcc -Wpedantic lex.yy.c -lfl -o analizador_lexico_sintactico.o

# Ejecución del binario con archivo a analizar como argumento
./analizador_lexico_sintactico.o example_accept.c
