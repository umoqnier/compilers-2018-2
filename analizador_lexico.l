%{
/*Analizador léxico para la materia de compilaldores 2018-2
Barriga Martínez Diego Alberto
Bustos Ramírez Luis Enrique*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
FILE *salida;
FILE *logs;

typedef struct{
  int clase;
  int valor;
}Token;

typedef struct{
  char *nombre;
  int valor;
  int alcance;
}Simbolo;

typedef struct{
  char *constante;
}CteSimbolica;

typedef struct{
  char *codigo;
}codAnaliza;


/* Prototipos de funciones */
Token *agregaToken(Token *, Token);
Simbolo *agregaSimbolo(Simbolo *, Simbolo);
CteSimbolica *agregaConstanteS(CteSimbolica *, CteSimbolica);
codAnaliza *agregaCodAnaliza(codAnaliza *, codAnaliza);

Token *tokens; // Arreglo (tabla) de tokens
Simbolo *simbolos; // Arreglo (tabla) de símbolos
CteSimbolica *tablaCteS;  // Arreglo de strings para constantes simbolicas
codAnaliza *tablaCodigoAnalizar;  // Arreglo de strings para código

int lenTokens = 0; // Longitud de la tabla de tokens
int lenSimbolos = 0;  // Longitud de  la tabla de simbolos
int lenCteSimbolicas = 0;  // Longitud de la  tabla de constantes simbolicas
int lenTablaCodigo = 0;  // Longitud de tabla de código a analizar

char *clase0[] = {"#define","#elif","#else","#endif","#if","#ifdef","#ifndef","#undef"};
char *clase4[] = {">",">=","<","<=","==","!="};
char *clase6[] = {"(",")"};
char *clase7[] = {"+","-","*","/","%"};

%}

comentario     (\/\/.*|\/\*(.|\n)+\*\/)$
especial       [()]
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

{lineaCodigo} {
  //fprintf(salida, "=== %s === codigo a analizar\n", yytext);
  printf("Codigo a analizar **%s** encontrado", yytext);
  Token t;
  codAnaliza ca;
  t.clase = 5;
  ca.codigo = (char *)malloc(strlen(yytext)*sizeof(char));
  strcpy(ca.codigo, yytext);
  lenTablaCodigo++;
  tablaCodigoAnalizar = agregaCodAnaliza(tablaCodigoAnalizar, ca);
  t.valor = lenTablaCodigo - 1;
  lenTokens++;
  tokens = agregaToken(tokens, t);
  //printf("Current state --> token(%d,%d)\n", t.clase, t.valor);
  fprintf(salida, "Current state --> token(%d,%d)\n", t.clase, t.valor);
}

{reservadas} {
  //fprintf(salida, "=== %s === reservada\n", yytext);
  short i, j;
  char iguales;
  Token t; // Declaración de un token
  t.clase = 0;
  for(i = 0; i < 8; i++){
    iguales = strcmp(clase0[i], yytext);
    if(iguales == 0){
       printf("Palabra Reservada **%s** encontrada", clase0[i]);
       t.valor = i;
       lenTokens++;
       tokens = agregaToken(tokens, t);
       //printf("current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
       fprintf(salida, "current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
       break;
    }
  }
}

{cteSimbol} {
  printf("\nConstante simbolica **%s** encontrada", yytext);
  Token t;
  Simbolo s;
  char i;
  short tamSimb;
  char iguales;
  char bandera = 0;
  s.valor = -1;
  s.alcance = -1;
  t.clase = 1;
  for(i = 0; i < lenSimbolos; i++){  // Busqueda del simbolo en la tabla
    iguales = strcmp(simbolos[i].nombre, yytext);
    if(iguales == 0){
      //printf("\tSimbolo %s en pos %d\n", yytext, i);
      t.valor = i;
      bandera = 1;
      break;
    }
  }
  if(bandera == 0){  // La constante no esta en la tabla de simbolos. Se agrega
    //printf("\tAgregando %s a la tabla de simbolos\n", yytext);
    //fprintf(salida, "Agregando %s a tabla de simbolos\n", yytext);
    tamSimb = strlen(yytext);
    s.nombre = (char *)malloc(tamSimb * sizeof(char));  // Asigna memoria para guardar una cadena del tamaño del simbolo
    strcpy(s.nombre, yytext);
    lenSimbolos++;
    simbolos = agregaSimbolo(simbolos, s);
    t.valor = lenSimbolos - 1;  // El ultimo agregado
  }
  lenTokens++;
  tokens = agregaToken(tokens, t);
  //printf("current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
  fprintf(salida, "current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
}

{valCteSimbol} {
  printf("\nValor constante simbolica **%s** encontrada", yytext);
  char i, iguales, bandera = 0;
  Token t;
  CteSimbolica cs;
  t.clase = 2;
  cs.constante = (char *)malloc(strlen(yytext)*sizeof(char));
  strcpy(cs.constante, yytext);
  lenCteSimbolicas++;
  tablaCteS = agregaConstanteS(tablaCteS, cs);
  t.valor = lenSimbolos - 1;
  lenTokens++;
  tokens = agregaToken(tokens, t);
  //printf("current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
  fprintf(salida, "current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
}

{entero} {
  printf("\nEntero **%s** encontrado", yytext);
  Token t;
  lenTokens++;
  t.clase = 3;
  t.valor = atoi(yytext);
  tokens = agregaToken(tokens, t);
  //printf("current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
  fprintf(salida, "current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);

}

{opAri} {
  printf("\nOperador aritmetico|  %s  |encontrado", yytext);
  char iguales, i;
  Token t;
  t.clase = 7;
  for(i = 0; i < 5; i++){
    iguales = strcmp(clase7[i], yytext);
    if(!iguales){
        t.valor = i;
        lenTokens++;
        tokens = agregaToken(tokens, t);
        //printf("current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
        fprintf(salida, "current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
        break;
    }
  }
}

{opRel} {
  printf("\nOperador relacional|  %s  |encontrado", yytext);
  char iguales, i;
  Token t;
  t.clase = 4;
  for(i = 0; i < 7 ;i++){
	iguales = strcmp(clase4[i],yytext);
	  if(!iguales){
		  t.valor = i;
      lenTokens++;
      tokens = agregaToken(tokens, t);
      //printf("current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
      fprintf(salida, "current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
  		break;
	  }
  }
}

{especial} {
	printf("\nSimbolo especial|  %s  |encontrado",yytext);
	Token t;
	char iguales = strcmp(clase6[0],yytext);	
	t.clase = 6;
	if(!iguales)
		t.valor = 0;
	else
		t.valor = 1;
	lenTokens++;
      	tokens = agregaToken(tokens, t);
	fprintf(salida, "current state --> token(%d,%d)\n", tokens[lenTokens-1].clase, tokens[lenTokens-1].valor);
}
%%

/* ====================================
    Funciones para estructura tokens
======================================*/

Token *agregaToken(Token *arr, Token new){
  if(lenTokens == 1){
    arr[0] = new;
  }else{
    arr = (Token *)realloc(arr, lenTokens*sizeof(Token));
    arr[lenTokens - 1] = new;
  }
  return arr;
}

/* ======================================
    Funciones para manejo de Tabla de constantes simbólicas
======================================*/

CteSimbolica *agregaConstanteS(CteSimbolica *arr, CteSimbolica nuevaConstante){
  //printf("Len Constantes Simbol: %d\n", lenCteSimbolicas);
  if(lenCteSimbolicas == 1){
    arr[0] = nuevaConstante;
  }else{
    arr = (CteSimbolica *)realloc(arr, lenCteSimbolicas * sizeof(CteSimbolica));
    arr[lenCteSimbolicas - 1] = nuevaConstante;
  }

  return arr;
};

/* ======================================
    Funciones para Tabla de simbolos
======================================*/

Simbolo *agregaSimbolo(Simbolo *arr, Simbolo new){
  //printf("Len simbolos: %d\n", lenSimbolos);
  if(lenSimbolos == 1){ // No se necesita realloc por que se inicializa el arreglo de simbolos en main()
    arr[0] = new;
  }
  else{
    arr = (Simbolo *)realloc(arr, lenSimbolos*sizeof(Simbolo));  // Agregamos un elemento al arreglo de simbolos
    arr[lenSimbolos - 1] = new;
  }
  return arr;
};

/* ======================================
  Funciones de linea de codigo a analizar
======================================*/

codAnaliza *agregaCodAnaliza(codAnaliza *arr,codAnaliza ca){
	//printf("Len Codigo Analiza: %d, %s\n", lenTablaCodigo,ca.codigo);
  	if(lenTablaCodigo == 1){
    		arr = (codAnaliza *)realloc(arr, lenTablaCodigo * sizeof(codAnaliza));
		arr[0] = ca;
  	}else{
    		arr = (codAnaliza *)realloc(arr, lenTablaCodigo * sizeof(codAnaliza));
    		arr[lenTablaCodigo - 1] = ca;
  	}

  return arr;
}

/* ======================================
    Funciones de impresion
======================================*/
void imprimeTokens(Token *arr){
  	char i;
  	fprintf(logs, "===============TOKENS===============\n");
  	for(i = 0; i < lenTokens; i++)
    		fprintf(logs, "token(%d,%d)\n", arr[i].clase, arr[i].valor);
  
}

void imprimeLineaCodigo(){
  	char i;
  	fprintf(logs, "===============Lineas a analizar===============\n");
  	for(i = 0; i < lenTablaCodigo; i++)
    		fprintf(logs, "|%d , '%s'\t|\n",i, tablaCodigoAnalizar[i].codigo);
}

void imprimeCteSim(CteSimbolica *arr){
	char i;
  	fprintf(logs, "===============Constantes Simbolicas===============\n");
  	for(i = 0; i < lenCteSimbolicas; i++)
   		fprintf(logs, "|%d,'%s'\t|\n",i, arr[i].constante);
}
/* ======================================
    Función principal
======================================*/
void main(int argc, char *argv[]){
  	if ( argc != 2 )  // Se ingresa solo un argumento
		  printf( "El programa: %s requiere el nombre del archivo como segundo argumento.\n", argv[0] );
	else{
    		tokens = (Token *)malloc(1*sizeof(Token));  // Inicializado a un elemento token. Al menos debe existir uno
    		simbolos = (Simbolo *)malloc(1*sizeof(Simbolo));  // Inicializando a un elemento simbolo. Al menos debe existir uno
    		tablaCteS = (CteSimbolica *)malloc(1*sizeof(CteSimbolica));
		yyin = fopen(argv[1], "r");  // yyin por defecto es el archivo de entrada
    		salida = fopen("salida.txt", "w");
    		logs = fopen("logs.txt", "w");
    		yylex();
    		imprimeTokens(tokens);
   		imprimeLineaCodigo();
		imprimeCteSim(tablaCteS);
    		free(simbolos);
    		free(tokens);
    		free(tablaCteS);
		free(tablaCodigoAnalizar);
    		fclose(salida);
    		fclose(logs);
	}
}
