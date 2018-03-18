%{
/*Analizador léxico para la materia de compilaldores 2018-2
Barriga Martínez Diego Alberto
Luis Bustos*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
FILE *salida;
%}

reservadas #define|#elif|#else|#endif|#if|#ifdef|#ifndef|#undef

%%
{reservadas} {
  fprintf(salida, "Just a test: %s es palabra reservada\n", yytext);

}
%%

void main(int argc, char *argv[]){
  if ( argc != 2 )  // Se ingresa solo un argumento
	  printf( "El programa: %s requiere el nombre del archivo como segundo argumento.\n", argv[0] );
	else{
		yyin = fopen(argv[1], "r");  // yyin por defecto es el archivo de entrada
    salida = fopen("salida.txt", "w");
    yylex();
    fclose(salida);
	}
}
