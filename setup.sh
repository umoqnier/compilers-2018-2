# usr/bin/bash

# Borrando archivos
rm -f lex.yy.c analizador_lexico.o

# Llamada a flex
flex analizador_lexico.l

# Llamada al compilador gcc
gcc -lfl lex.yy.c -o analizador_lexico.o

# Ejecución del binario con archivo a analizar como argumento
./analizador_lexico.o example.c

# Impresión del archivo de salida
#cat salida.txt
