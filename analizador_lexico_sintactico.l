%{
/*Analizador léxico para la materia de compilaldores 2018-2
Barriga Martínez Diego Alberto
Bustos Ramírez Luis Enrique*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
FILE *salida;

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

typedef struct{
  char car;
}Atomo;


/* Prototipos de funciones */
Token *agregaToken(Token *, Token);
Simbolo *agregaSimbolo(Simbolo *, Simbolo);
CteSimbolica *agregaConstanteS(CteSimbolica *, CteSimbolica);
codAnaliza *agregaCodAnaliza(codAnaliza *, codAnaliza);
Atomo *agregaAtomo(Atomo *, Atomo);

Token *tokens; // Arreglo (tabla) de tokens
Simbolo *simbolos; // Arreglo (tabla) de símbolos
CteSimbolica *tablaCteS;  // Arreglo de strings para constantes simbolicas
codAnaliza *tablaCodigoAnalizar;  // Arreglo de strings para código
Atomo *cadAtomix;  // Cadena de atomos

int lenTokens = 0; // Longitud de la tabla de tokens
int lenSimbolos = 0;  // Longitud de  la tabla de simbolos
int lenCteSimbolicas = 0;  // Longitud de la  tabla de constantes simbolicas
int lenTablaCodigo = 0;  // Longitud de tabla de código a analizar
int lenAtomos = 0;  // Longitud de la cadena de átomos

char *clase0[] = {"#define","#elif","#else","#endif","#if","#ifdef","#ifndef","#undef"};
char *clase4[] = {">",">=","<","<=","==","!="};
char *clase6[] = {"(",")"};
char *clase7[] = {"+","-","*","/","%"};

/* Para el parser */
char caracter;  // Variable para leer caracteres de la cadena de atomos

/* Átomos por clase*/

char atomos0[8] = {'d','f','l','n','i','t','m','u'};
char atomos4[6] = {'>','g','<','p','q','r'};
char atomos7[5] = {'+','-','*','/','%'};
/*char *atomos0[] = {"d","f","l","n","i","t","m","u"};
char *atomo1 = "a";
char *atomo2 = "s";
char *atomo3 = "e";
char *atomos4[] = {">", "g", "<", "p", "q", "r"};
char *atomo5 = "c";
char *atomos6[] = {"(", ")"};
char *atomos7[] = {"+", "-", "*", "/", "%"};*/

%}

blank          [\n\t\r]+
comentario     (\/\/.*|\/\*(.|\n)+\*\/)$
especial       [()]
lineaCodigo    ^([^#].*)
dig            [0-9]
mantReal       ({dig}*\.{dig}+|{dig}+\.{dig})
entero         ([1-9]{dig}*|0)
opRel          >|>=|<|<=|==|!=
opAri          \+|\-|\*|\/|%
reservadas     ^(#define|#elif|#else|#endif|#if|#ifdef|#ifndef|#undef)
valCteSimbol   \"({mantReal}|{entero})\"
cteSimbol      [A-Z]{1,8}

%%

{blank} {printf("\nLinea en blanco descartada\n");}

{lineaCodigo} {
  printf("\nCodigo a analizar **%s** encontrado", yytext);
  Token t;
  Atomo a;
  codAnaliza ca;
  t.clase = 5;
  ca.codigo = (char *)malloc(strlen(yytext)*sizeof(char));
  strcpy(ca.codigo, yytext);
  a.car = 'c';
  printf("\nATOMO: %c", a.car);
  lenTablaCodigo++;
  tablaCodigoAnalizar = agregaCodAnaliza(tablaCodigoAnalizar, ca);
  t.valor = lenTablaCodigo - 1;
  lenTokens++;
  tokens = agregaToken(tokens, t);
  lenAtomos++;
  printf("\nLEN ATOMOS: %d", lenAtomos);
  cadAtomix = agregaAtomo(cadAtomix, a);
  printf("\nCADENA: %c", cadAtomix[lenAtomos-1].car);
}

{reservadas} {
  short i, j;
  char iguales;
  Token t; // Declaración de un token
  Atomo at;  // Declaración de un atomo
  t.clase = 0;
  for(i = 0; i < 8; i++){
    iguales = strcmp(clase0[i], yytext);
    if(iguales == 0){
       printf("Palabra Reservada **%s** encontrada", clase0[i]);
       t.valor = i;
       lenTokens++;
       tokens = agregaToken(tokens, t);
       at.car = atomos0[i];
       printf("\nATOMO: %c", at.car);
       lenAtomos++;
       printf("\nLEN ATOMOS: %d", lenAtomos);
       cadAtomix = agregaAtomo(cadAtomix, at);
       printf("\nCADENA: %c", cadAtomix[lenAtomos-1].car);
       break;
    }
  }
}

{cteSimbol} {
  printf("\nConstante simbolica **%s** encontrada", yytext);
  Token t;
  Simbolo s;
  Atomo a;
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
      t.valor = i;
      bandera = 1;
      break;
    }
  }
  if(bandera == 0){  // La constante no esta en la tabla de simbolos. Se agrega
    tamSimb = strlen(yytext);
    s.nombre = (char *)malloc(tamSimb * sizeof(char));  // Asigna memoria para guardar una cadena del tamaño del simbolo
    strcpy(s.nombre, yytext);
    lenSimbolos++;
    simbolos = agregaSimbolo(simbolos, s);
    t.valor = lenSimbolos - 1;  // El ultimo agregado
  }
  lenTokens++;
  tokens = agregaToken(tokens, t);
  a.car = 'a';
  printf("\nATOMO: %c", a.car);
  lenAtomos++;
  printf("\nLEN ATOMOS: %d", lenAtomos);
  cadAtomix = agregaAtomo(cadAtomix, a);
  printf("\nCADENA: %c", cadAtomix[lenAtomos - 1].car);
}

{valCteSimbol} {
  printf("\nValor constante simbolica **%s** encontrada", yytext);
  char i, iguales, bandera = 0;
  Token t;
  CteSimbolica cs;
  Atomo a;
  t.clase = 2;
  cs.constante = (char *)malloc(strlen(yytext)*sizeof(char));
  strcpy(cs.constante, yytext);
  lenCteSimbolicas++;
  tablaCteS = agregaConstanteS(tablaCteS, cs);
  t.valor = lenSimbolos - 1;
  lenTokens++;
  tokens = agregaToken(tokens, t);
  a.car = 's';
  printf("\nATOMO: %c", a.car);
  lenAtomos++;
  printf("\nLEN ATOMOS: %d", lenAtomos);
  cadAtomix = agregaAtomo(cadAtomix, a);
  printf("\nCADENA: %c", cadAtomix[lenAtomos - 1].car);
}

{entero} {
  printf("\nEntero **%s** encontrado", yytext);
  Token t;
  Atomo a;
  lenTokens++;
  t.clase = 3;
  t.valor = atoi(yytext);
  tokens = agregaToken(tokens, t);
  a.car = 'e';
  printf("\nATOMO: %c", a.car);
  lenAtomos++;
  printf("\nLEN ATOMOS: %d", lenAtomos);
  cadAtomix = agregaAtomo(cadAtomix, a);
  printf("\nCADENA: %c", cadAtomix[lenAtomos - 1].car);
}

{opAri} {
  printf("\nOperador aritmetico|  %s  |encontrado", yytext);
  char iguales, i;
  Token t;
  Atomo a;
  t.clase = 7;
  for(i = 0; i < 5; i++){
    iguales = strcmp(clase7[i], yytext);
    if(!iguales){
        t.valor = i;
        lenTokens++;
        tokens = agregaToken(tokens, t);
        a.car = atomos7[i];
        printf("\nATOMO: %c", a.car);
        lenAtomos++;
        printf("\nLEN ATOMOS: %d", lenAtomos);
        cadAtomix = agregaAtomo(cadAtomix, a);
        printf("\nCADENA: %c", cadAtomix[lenAtomos - 1].car);
        break;
    }
  }
}

{opRel} {
  printf("\nOperador relacional|  %s  |encontrado", yytext);
  char iguales, i;
  Token t;
  Atomo a;
  t.clase = 4;
  for(i = 0; i < 7 ;i++){
	iguales = strcmp(clase4[i],yytext);
	  if(!iguales){
		  t.valor = i;
      lenTokens++;
      tokens = agregaToken(tokens, t);
      a.car = atomos4[i];
      printf("\nATOMO: %c", a.car);
      lenAtomos++;
      printf("\nLEN ATOMOS: %d", lenAtomos);
      cadAtomix = agregaAtomo(cadAtomix, a);
      printf("\nCADENA: %c", cadAtomix[lenAtomos - 1].car);
  		break;
	  }
  }
}

{especial} {
	printf("\nSimbolo especial|  %s  |encontrado",yytext);
	Token t;
  Atomo a;
	char iguales = strcmp(clase6[0], yytext);
	t.clase = 6;
  lenAtomos++;
  printf("\nLEN ATOMOS: %d", lenAtomos);
	if(!iguales){
		t.valor = 0;
    a.car = '(';
    printf("\nATOMO: %c", a.car);
    cadAtomix = agregaAtomo(cadAtomix, a);
    printf("\nCADENA: %c", cadAtomix[lenAtomos - 1].car);
  }
	else{
		t.valor = 1;
    a.car = ')';
    printf("\nATOMO: %c", a.car);
    cadAtomix = agregaAtomo(cadAtomix, a);
    printf("\nCADENA: %c", cadAtomix[lenAtomos - 1].car);
  }
	lenTokens++;
  tokens = agregaToken(tokens, t);
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


/* ===================================
    Funciones para Tabla de simbolos
======================================*/

Simbolo *agregaSimbolo(Simbolo *arr, Simbolo new){
  //printf("Len simbolos: %d\n", lenSimbolos);

  if(lenSimbolos == 1){ // No se necesita( realloc por que se inicializa el arreglo de simbolos en main()
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

codAnaliza *agregaCodAnaliza(codAnaliza *arr, codAnaliza ca){
	//printf("Len Codigo Analiza: %d, %s\n", lenTablaCodigo,ca.codigo);
  	if(lenTablaCodigo == 1){
		    arr[0] = ca;
  	}else{
        arr = (codAnaliza *)realloc(arr, lenTablaCodigo*sizeof(codAnaliza));
    		arr[lenTablaCodigo - 1] = ca;
  	}

  return arr;
}

/* ======================================
    Funcion que manjea la cadena de atomos
======================================*/
Atomo *agregaAtomo(Atomo *arr, Atomo at){
  if(lenAtomos == 1){
    arr[0] = at;
  }else{
    printf("\nAT SECOND ADD ATOM");
    arr = (Atomo *)realloc(arr, (lenAtomos)*sizeof(Atomo));
    arr[lenAtomos - 1] = at;
  }
}

/* ======================================
    Funciones de escritura
======================================*/
void imprimeTokens(Token *arr){
  char i;
  fprintf(salida, "===============TOKENS===============\n");
  for(i = 0; i < lenTokens; i++){
    fprintf(salida, "token(%d, %d)\n", arr[i].clase, arr[i].valor);
  }
}

void imprimeLineaCodigo(){
  	char i;
  	fprintf(salida, "===============Lineas a analizar===============\n");
  	for(i = 0; i < lenTablaCodigo; i++)
    		fprintf(salida, "|%d, %s|\n",i, tablaCodigoAnalizar[i].codigo);
}

void imprimeCteSim(CteSimbolica *arr){
	char i;
  	fprintf(salida, "===============Constantes Simbolicas===============\n");
  	for(i = 0; i < lenCteSimbolicas; i++)
   		fprintf(salida, "|%d, %s|\n",i, arr[i].constante);
}

void imprimeSimbolos(Simbolo *arr){
  char i;
  fprintf(salida, "===============Simbolos===============\n");
  for(i = 0; i < lenSimbolos; i++)
      fprintf(salida, "|%d , %s, %d, %d|\n", i, arr[i].nombre, arr[i].valor, arr[i].alcance);
}

/* ======================================
    COMIENZA ANALIZADOR SINTACTICO
======================================*/

void imprimeAtomos(Atomo *arr){
  char i;
  printf("IMPRIME ATOMOS %d", lenAtomos);
  fprintf(salida, "===============Atomos===============\n");
  for(i = 0; i < lenAtomos; i++)
      fprintf(salida, "|%c|\n", arr[i].car);
}

/* ======================================
    Simbolo inicial de la gramatica
======================================*/

/*void SimboloInicial(){

  if(caracter == 'c'){
    caracter = getchar(cadAtomix);
    CPrep();
    return;
  }else{
    if(caracter == 'i' || caracter == 't' || caracter == 'm'){
      CompCond();
      CPrep();
      return;
    }else{
      if(caracter == 'd'){
        define();
        CPrep();
        return;
      }else{
        if(caracter == 'u'){
          undef();
          CPrep();
          return;
        }else
          error();
      }
    }
  }
  return;
}

void CPrep(){
  if(caracter == 'c' || caracter == 'i' || caracter == 't' || caracter == 'm' || caracter == 'd' || caracter == 'u'){
    SimboloInicial();
  }else{
    if(caracter == '\0')
      return;
    else
      error();
  }
  return;
}


 void CompCond(){
  if(caracter == 'i' || caracter == 't' || caracter == 'm' ){
    lineaIf();
    texto();
    elseOp();
    if(caracter == 'n'){
      caracter = getchar(cadAtomix);
      return;
    }else{
      error();
    }
  }else
    error();
  return;
 }

void lineaIf(){
  if(caracter == 'i'){
    caracter = getchar(cadAtomix);
    expConstante();
    return;
  }else{
    if(caracter == 't'){
      caracter = getchar(cadAtomix);
      if(caracter == 'a'){
        caracter = getchar(cadAtomix);
        return;
      }else
        error();
    }else{
      if(caracter == 'm'){
        caracter = getchar(cadAtomix);
        if(caracter == 'a'){
          caracter = getchar(cadAtomix);
          return;
        }else
          error();
      }else
        error();
    }
  }
  return;
}

void texto(){
  if(caracter=='c'){
    caracter = getchar(cadAtomix);
    texto();
    return;
  }else{
    if(caracter == 'd'){
      define();
      texto();
      return;
    }else{
      if(caracter == 'n'|| caracter == 'f' || caracter == 'l'){
        return;
      }else{
        if(caracter == 'u'){
          undef();
          texto();
          return;
        }else{
          if(caracter == 'i' || caracter == 't' || caracter == 'm'){
            CompCond();
            texto();
            return;
          }else
            error();
        }
      }
    }
  }

}


void elseOp(){
  if(caracter == 'n')
    return;
  else{
    if(caracter == 'f'){
      caracter = getchar(cadAtomix);
      expConstante();
      texto();
      elseOp();
      return;
    }else{
      if(caracter == 'l'){
        caracter = getchar(cadAtomix);
        texto();
        return;
      }else
        error();
    }
    return;
  }
}
*/

/* ======================================
    Función define
======================================*/

/*void define(){
  if(caracter == 'd'){
    caracter = getchar(cadAtomix);
    if(caracter == 'a')
      caracter = getchar(cadAtomix);
    else
      error();
    if(caracter == 's')
      caracter = getchar(cadAtomix);
    else
      error();
  }else
    error();
    return;
}*/

/* ======================================
    Función undef
======================================*/

/*void undef(){
  if(caracter == 'u'){
    caracter = getchar(cadAtomix);
    if(caracter == 'a')
      caracter = getchar(cadAtomix);
    else
      error();
  }else
    error();
    return;
}*/


/* ======================================
   Funcion expresion constante
======================================*/

/*void expConstante(){
  if(caracter == '(' || caracter == 'a' || caracter == 'e'){
    E();
    operadorRel();
    E();
  }else
    error();
  return;
}*/


/* ======================================
    Funciones de aritmetica
======================================*/

/*void E(){
  char caracter = getchar(cadAtomix);
  E();
  if (caracter == '(' || caracter == 'a'){
      T();
      EP();
  }
  else
      error();
  return;
}

void EP(){
  if (caracter == '+'){
    caracter = getchar(cadAtomix);
    T();
    EP();
    return;
  }else if(caracter == ')' || caracter == '\0')
          return;
        else
          error();
}

void T(){
  if(caracter == '(' || caracter == 'a' || caracter == 'e'){
    F();
    TP();
  }else
    error();
  return;
}

void TP(){
  if(caracter == '*' || caracter == '/' || caracter == '%'){
    caracter = getchar(cadAtomix);
    F();
    TP();
  }else{
    if(caracter == '+' || caracter == '-' || caracter == ')' || caracter == '>' || caracter == 'g' || caracter == '<' || caracter == 'p' || caracter == 'q' || caracter == 'r' || caracter == ')' || caracter == 'c' || caracter == 'd' || caracter == 'u' || caracter == 'i' || caracter == 't' || caracter == 'm' || caracter == 'n' || caracter == 'f' || caracter == 'l'){
      return;
    }else
      error();
  }
  return;
}


void F(){
    if(caracter == '(' ){
      caracter = getchar(cadAtomix);
      E();
      if(caracter == ')' )
        caracter = getchar(cadAtomix);
      else
        error();
    }else {
      if(caracter == 'a' ||   caracter == 'e')
        caracter = getchar(cadAtomix);
      else
        error();
    }
    return;
}*/



/* ======================================
    Funciones operadores relacionales
======================================*/

/*void operadorRel(){
  if(caracter == '>' || caracter == 'g' || caracter == '<' || caracter == 'q' || caracter == 'r' || caracter == 'p')
    caracter = getchar(cadAtomix);
  else
    error();
    return;
}*/

/* ======================================
    Función parser
    Variable cadAtomix y caracter deben de ser GLOBALES
======================================*/

/*void parser(char *cadAtomix){
  char caracter = getchar(cadAtomix);
  SimboloInicial();
  if (caracter == '\0')
    aceptar();
  else
    rechazar();
}*/

/* ======================================
    Funcion error
======================================*/
/*void error(){
  printf("Ha ocurrido un error con el caracter: %c", caracter);
  caracter = getchar(cadAtomix);
  return;
}*/

/* ======================================
    Funcion aceptar y rechazar
======================================*/
/*void aceptar(){
  printf("La cadena de atomos es aceptada");
  return;
}

void rechazar(){
  printf("La cadena de atomos es rechazada");
}*/


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
    tablaCodigoAnalizar = (codAnaliza *)malloc(1*sizeof(codAnaliza));
    cadAtomix = (Atomo *)malloc(1*sizeof(Atomo));
		yyin = fopen(argv[1], "r");  // yyin por defecto es el archivo de entrada
    salida = fopen("salida.txt", "w");
    yylex();
    imprimeTokens(tokens);
    imprimeSimbolos(simbolos);
   	imprimeLineaCodigo();
		imprimeCteSim(tablaCteS);
    imprimeAtomos(cadAtomix);

    //parser();

    free(simbolos);
    free(tokens);
    free(tablaCteS);
		free(tablaCodigoAnalizar);
    free(cadAtomix);
    fclose(salida);

	}
}
