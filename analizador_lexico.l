%{
/*Analizador léxico para la materia de compilaldores 2018-2
Barriga Martínez Diego Alberto
Luis Bustos*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
FILE *salida;
char *clase0[] = {{"#define"},{"#elif"},{"#else"},{"#endif"},{"#if"},{"#ifdef"},{"#ifndef"},{"#undef"}};
char *clase4[] = {{">"},{">="},{"<"},{"<="},{"=="},{"!="}};
char *clase6[]= {{"("},{")"}};
char *clase7[]= {{"+"},{"-"},{"*"},{"/"},{"%"}};

%}
comentario     (\/\/.*|\/\*(.|\n)+\*\/)$
especial       [\(\)\{\}\.\"\;\t\n ]
lineaCodigo    ^([^#].*)
dig            [0-9]
mantReal       ({dig}*\.{dig}+|{dig}+\.{dig})
entero         ([1-9]{dig}*|0)
opRel          >|>=|<|<=|==|!=
opAri          \+|\-|\*|\/|%
reservadas     #define|#elif|#else|#endif|#if|#ifdef|#ifndef|#undef
valCteSimbol   \"({mantReal}|{entero})\"
cteSimbol      [A-Z]{1,8}
%%

{comentario} {
  fprintf(salida, "=== %s === es comentario\n", yytext);
}

{lineaCodigo} {
  fprintf(salida, "=== %s === es lineaCodigo a analizar\n", yytext);
}

{reservadas} {
  fprintf(salida, "=== %s === es palabra reservada\n", yytext);
  int i=0;
  char iguales;
  for(i;i<8;i++){
    iguales = strcmp(clase0[i],yytext);
    if(!iguales){
       printf("Son iguales: %s", clase0[i]);
       fprintf(salida,"token(0,%d)\n",i);
       break;
    }
  }
}

{cteSimbol} {
  fprintf(salida, "=== %s === es constante simbolica\n", yytext);
}

{valCteSimbol} {
  fprintf(salida, "=== %s === es valor de constante simbolica\n", yytext);
}

{entero} {
  fprintf(salida, "=== %s === es entero\n", yytext);
  fprintf(salida, "token(3,%d)\n",atoi(yytext));
}

{opAri} {
  fprintf(salida, "=== %s === es operador aritmetico\n", yytext);
  int i=0;
  char iguales;
  for(i;i<5;i++){
    iguales = strcmp(clase7[i],yytext);
    if(!iguales){
        fprintf(salida,"token(7,%d)\n",i);
        break;
    }
  }
}
{opRel} {
  fprintf(salida, "=== %s === es operador relacional\n", yytext);
  int i=0;
  char iguales;
  for(i;i<7;i++){
	iguales = strcmp(clase4[i],yytext);
	if(!iguales){
		fprintf(salida,"token(4,%d)\n",i);
		break;
	}
  }
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
