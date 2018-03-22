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

/* Prototipos de funciones */
Token *agregaToken(Token *, Token);
Simbolo *agregaSimbolo(Simbolo *, Simbolo);

Token *tokens; // Arreglo (tabla) de tokens
int lenTokens;
Simbolo *simbolos; // Arreglo (tabla) de símbolos
int lenSimbolos;
char **tablaCteSimbolicas;  // Arreglo de strings para constantes simbolicas
int lenTablaCteS;
char **tablaCodigoAnalizar;  // Arreglo de strings para codigo
int lenTablaCodigo;

char *clase0[] = {"#define","#elif","#else","#endif","#if","#ifdef","#ifndef","#undef"};
char *clase4[] = {">",">=","<","<=","==","!="};
char *clase6[] = {"(",")"};
char *clase7[] = {"+","-","*","/","%"};

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

{lineaCodigo} {
  fprintf(salida, "=== %s === codigo a analizar\n", yytext);
}

{reservadas} {
  fprintf(salida, "=== %s === reservada\n", yytext);
  short i, j;
  char iguales;
  Token t, *aux; // Declaración de un token
  t.clase = 0;
  for(i = 0; i < 8; i++){
    iguales = strcmp(clase0[i], yytext);
    if(!iguales){
       printf("Reservada **%s** encontrada\n", clase0[i]);
       t.valor = i;
       aux = agregaToken(tokens, t);
       tokens = aux;
       printf("Current state --> token(0,%d)\n", t.valor);
       fprintf(salida, "Current state --> token(0,%d)\n", i);
       printf("despues de archivo reserva\n");
       break;
    }
  }
}

{cteSimbol} {
  printf("En constante simbolica");
  short i, tamSimb;
  char iguales;
  char bandera = 0;
  Token t, *auxT;
  Simbolo s, *auxS;
  s.valor = -1;
  s.alcance = -1;
  t.clase = 1;
  for(i = 0; i < lenSimbolos; i++){  // Busqueda del simbolo en la tabla
    iguales = strcmp(simbolos[i].nombre, yytext);
    if(!iguales)
      printf("Simbolo %s ya esta en la tabla\n", yytext);
      t.valor = i;
      bandera = 1;
      fprintf(salida, "Current state --> token(1,%d)\n", i);
      break;
  }
  printf("%s no esta en la tabla de simbolos\n", yytext);
  if(!bandera){  // La constante no esta en la tabla de simbolos. Se agrega
    fprintf(salida, "Nuevo simbolo %s encontrado\n", yytext);
    printf("despues de archivo\n");
    tamSimb = strlen(yytext);
    s.nombre = (char *)malloc(tamSimb * sizeof(char));  // Asigna memoria para guardar una cadena del tamaño del simbolo
    strcpy(s.nombre, yytext);
    printf("despues de archivo\n");
    auxS = agregaSimbolo(simbolos, s);
    simbolos = auxS;
    t.valor = lenSimbolos;  // El ultimo agregado
  }
  auxT = agregaToken(tokens, t);
  tokens = auxT;
  fprintf(salida, "Current state --> token(1, %d)\n", t.valor);
}

{valCteSimbol} {
  printf("En VAL CONTE SiMB\n");
  fprintf(salida, "=== %s === es valor de constante simbolica\n", yytext);
}

{entero} {
  printf("En entero\n");
  fprintf(salida, "=== %s === es entero\n", yytext);
  fprintf(salida, "token(3,%d)\n",atoi(yytext));
}

{opAri} {
  printf("En OP ARIT");
  fprintf(salida, "=== %s === es operador aritmetico\n", yytext);
  int i=0;
  char iguales;
  for(i;i<5;i++){
    iguales = strcmp(clase7[i],yytext);
    if(!iguales){
        fprintf(salida,"token(7,%d)\n", i);
        break;
    }
  }
}

{opRel} {
  printf("En OP REL");
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

/* ======================================
    Funciones para estructura tokens
======================================*/
int verificaTokens(Token *t){
  /* Verifica que exista un token en el arreglo de tokens*/
  if(t)
    return 1;
  else;
    return 0;
};


Token *agregaToken(Token *t, Token n){
  Token *aux;
  printf("LEN TOKEN %d\n", lenTokens);
  ++lenTokens;
  aux = (Token *)realloc(t, 1 * sizeof(Token));
  t = aux;
  t[lenTokens] = n;
  return t;
}

/* ======================================
    Funciones para manejo de Tablas
(Constantes simbolicas y codigo a analizar)
======================================*/

/*char *agregaElementoTabla(char *t, char n){

};

void agregaLineaCodigo(char *t, char *codigo){
  ++lenTablaCodigo;
  t[lenTablaCodigo] = (char *)malloc(strlen(codigo)*sizeof(char));  // Crea el espacio necesario para el string del codigo
  strcpy(t[lenTablaCodigo], codigo);
}*/

/* ======================================
    Funciones para Tabla de simbolos
======================================*/

Simbolo *agregaSimbolo(Simbolo *s, Simbolo n){
  ++lenSimbolos;
  s = (Simbolo *)realloc(s, 1*sizeof(Simbolo));
  s[lenSimbolos] = n;
  return s;
};

/* ======================================
    Funciones de impresion
======================================*/
void imprimeTokens(Token *t){
  char i, j;
  for(i = 0; i < lenTokens; i++){
    fprintf(logs, "token(%d, %d)", t[i].clase, t[i].valor);
  }
}

/* ======================================
    Función principal
======================================*/
void main(int argc, char *argv[]){
  if ( argc != 2 )  // Se ingresa solo un argumento
	  printf( "El programa: %s requiere el nombre del archivo como segundo argumento.\n", argv[0] );
	else{
    tokens = (Token *)malloc(1*sizeof(Token));  // Inicializado a un elemento token. Al menos debe existir uno
    lenTokens = 1;
    simbolos = (Simbolo *)malloc(1*sizeof(Simbolo));  // Inicializando a un elemento simbolo. Al menos debe existir uno
    lenSimbolos = 1;
		yyin = fopen(argv[1], "r");  // yyin por defecto es el archivo de entrada
    salida = fopen("salida.txt", "w");
    logs = fopen("logs.txt", "w");
    yylex();
    fclose(salida);
    fclose(logs);
	}
}
