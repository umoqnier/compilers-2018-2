# usr/bin/bash

# Llamada a flex
flex analizador_lexico.l

# Llamada al compilador gcc
gcc -lfl lex.yy.c -o analizador_lexico.o

# Ejecución del binario con archivo a analizar como argumento
./analizador_lexico.o example.c
