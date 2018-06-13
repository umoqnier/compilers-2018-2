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
Simbolo *asignaValor(Simbolo *, int, int);
CteSimbolica *agregaConstanteS(CteSimbolica *, CteSimbolica);
codAnaliza *agregaCodAnaliza(codAnaliza *, codAnaliza);
Atomo *agregaAtomo(Atomo *, Atomo);
char obtenerAtomo(Atomo *);
void agregaFinCadena();
Atomo *actualizaAtomos(Atomo *);
void imprimeAtomosConsola(Atomo *);
char SimboloInicial(char);
char CPrep(char);
char CompCond(char);
char lineaIf(char);
char texto(char);
char elseOp(char);
char define(char);
char undef(char);
char expConstante(char);
char E(char);
char EP(char);
char T(char);
char TP(char);
char F(char);
char operadorRel(char);
void parser(Atomo *);
char error(char);
void aceptar();
void rechazar();


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
valCteSimbol   \"({mantReal}|{entero}|[a-zA-Z]+)\"
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
  lenTablaCodigo++;
  tablaCodigoAnalizar = agregaCodAnaliza(tablaCodigoAnalizar, ca);
  t.valor = lenTablaCodigo - 1;
  lenTokens++;
  tokens = agregaToken(tokens, t);
  lenAtomos++;
  cadAtomix = agregaAtomo(cadAtomix, a);
  /*Para agregar el numero a la cadena de atomos*/
  lenAtomos++;
  a.car = tokens[lenTokens - 1].valor + '0';
  cadAtomix = agregaAtomo(cadAtomix, a);
}

{reservadas} {
  uint8_t iguales, i;
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
       lenAtomos++;
       cadAtomix = agregaAtomo(cadAtomix, at);
       break;
    }
  }
}

{cteSimbol} {
  printf("\nConstante simbolica **%s** encontrada", yytext);
  uint8_t i, iguales, tamSimb, bandera = 0;
  Token t;
  Simbolo s;
  Atomo a;
  int aux = 0;
  char digit;
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
  lenAtomos++;
  cadAtomix = agregaAtomo(cadAtomix, a);
  /*Para agregar el numero a la cadena de atomos*/
  aux = t.valor;
  lenAtomos++;
  a.car = tokens[lenTokens - 1].valor + '0';
  cadAtomix = agregaAtomo(cadAtomix, a);
}

{valCteSimbol} {
  printf("\nValor constante simbolica **%s** encontrada", yytext);
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
  lenAtomos++;
  cadAtomix = agregaAtomo(cadAtomix, a);
  /*Para agregar el numero a la cadena de atomos*/
  lenAtomos++;
  a.car = tokens[lenTokens - 1].valor + '0';
  cadAtomix = agregaAtomo(cadAtomix, a);
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
  lenAtomos++;
  cadAtomix = agregaAtomo(cadAtomix, a);
  /*Para agregar el numero a la cadena de atomos*/
  lenAtomos++;
  a.car = tokens[lenTokens - 1].valor + '0';
  cadAtomix = agregaAtomo(cadAtomix, a);
}

{opAri} {
  printf("\nOperador aritmetico|  %s  |encontrado", yytext);
  uint8_t iguales, i;
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
        lenAtomos++;
        cadAtomix = agregaAtomo(cadAtomix, a);
        break;
    }
  }
}

{opRel} {
  printf("\nOperador relacional|  %s  |encontrado", yytext);
  uint8_t iguales, i;
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
      lenAtomos++;
      cadAtomix = agregaAtomo(cadAtomix, a);
  		break;
	  }
  }
}

{especial} {
	printf("\nSimbolo especial|  %s  |encontrado",yytext);
	Token t;
  Atomo a;
	uint8_t iguales = strcmp(clase6[0], yytext);
	t.clase = 6;
  lenAtomos++;
	if(!iguales){
		t.valor = 0;
    a.car = '(';
    cadAtomix = agregaAtomo(cadAtomix, a);
  }
	else{
		t.valor = 1;
    a.car = ')';
    cadAtomix = agregaAtomo(cadAtomix, a);
  }
	lenTokens++;
  tokens = agregaToken(tokens, t);
}
%%

char pos, valor;
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
}


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
}

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
    arr = (Atomo *)realloc(arr, lenAtomos*sizeof(Atomo));
    arr[lenAtomos - 1] = at;
  }
  return arr;
}

/* ======================================
    Funciones de escritura
======================================*/
void imprimeTokens(Token *arr){
  uint8_t i;
  fprintf(salida, "===============TOKENS===============\n");
  for(i = 0; i < lenTokens; i++){
    fprintf(salida, "token(%d, %d)\n", arr[i].clase, arr[i].valor);
  }
}

void imprimeLineaCodigo(){
  	uint8_t i;
  	fprintf(salida, "===============Lineas a analizar===============\n");
  	for(i = 0; i < lenTablaCodigo; i++)
    		fprintf(salida, "|%d, %s|\n",i, tablaCodigoAnalizar[i].codigo);
}

void imprimeCteSim(CteSimbolica *arr){
	uint8_t i;
  fprintf(salida, "===============Constantes Simbolicas===============\n");
  	for(i = 0; i < lenCteSimbolicas; i++)
   		fprintf(salida, "|%d, %s|\n",i, arr[i].constante);
}

void imprimeSimbolos(Simbolo *arr){
  uint8_t i;
  fprintf(salida, "===============Simbolos===============\n");
  for(i = 0; i < lenSimbolos; i++)
      fprintf(salida, "|%d , %s, %d, %d|\n", i, arr[i].nombre, arr[i].valor, arr[i].alcance);
}

/* ======================================
    COMIENZA ANALIZADOR SINTACTICO - SEMANTICO
======================================*/

void imprimeAtomos(Atomo *arr){
  uint8_t i;
  fprintf(salida, "===============Atomos===============\n");
  fprintf(salida, "|");
  for(i = 0; i < lenAtomos; i++)
      fprintf(salida, "%c", arr[i].car);
  fprintf(salida, "|\n");
}

void imprimeAtomosConsola(Atomo *arr){
  uint8_t i;
  for(i = 0; i < lenAtomos; i++)
      printf("%c", arr[i].car);
  printf("\n");
}

void agregaFinCadena(){
  Atomo a;
  a.car = '$';
  lenAtomos++;
  cadAtomix = agregaAtomo(cadAtomix, a);
}

Atomo *actualizaAtomos(Atomo *arr){
   uint8_t i;
   for(i = 0; i < lenAtomos - 1; i++)
       arr[i] = arr[i+1];
   lenAtomos--;
   return arr;
}

char obtenerAtomo(Atomo *arr){
  char aux = arr[0].car;
  return aux;
}

/* ======================================
    Simbolo inicial de la gramatica
======================================*/

char SimboloInicial(char caracter){
  if(caracter == 'c'){
    caracter = obtenerAtomo(cadAtomix);
    cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento
    caracter = CPrep(caracter);
    return caracter;
  }else{
    if(caracter == 'i' || caracter == 't' || caracter == 'm'){
      caracter = CompCond(caracter);
      caracter = CPrep(caracter);
      return caracter;
    }else{
      if(caracter == 'd'){
        caracter = define(caracter);
        caracter = CPrep(caracter);
        return caracter;
      }else{
        if(caracter == 'u'){
          caracter = undef(caracter);
          caracter = CPrep(caracter);
          return caracter;
        }else
          caracter = error(caracter);
      }
    }
  }
  return caracter;
}


char CPrep(char caracter){
  if(caracter == 'c' || caracter == 'i' || caracter == 't' || caracter == 'm' || caracter == 'd' || caracter == 'u'){
    caracter = SimboloInicial(caracter);
  }else{
    if(caracter == '$')
      return caracter;
    else
      caracter = error(caracter);
  }
  return caracter;
}


 char CompCond(char caracter){
  if(caracter == 'i' || caracter == 't' || caracter == 'm' ){
    caracter = lineaIf(caracter);
    caracter = texto(caracter);
    caracter = elseOp(caracter);
    if(caracter == 'n'){
      caracter = obtenerAtomo(cadAtomix);
			cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
      return caracter;
    }else{
      caracter = error(caracter);
    }
  }else
    caracter = error(caracter);
  return caracter;
 }


char lineaIf(char caracter){
  if(caracter == 'i'){
    caracter = obtenerAtomo(cadAtomix);
		cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
    caracter = expConstante(caracter);
    return caracter;
  }else{
    if(caracter == 't'){
      caracter = obtenerAtomo(cadAtomix);
			cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
      if(caracter == 'a'){
        caracter = obtenerAtomo(cadAtomix);
			  cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
        return caracter;
      }else
        caracter = error(caracter);
    }else{
      if(caracter == 'm'){
        caracter = obtenerAtomo(cadAtomix);
			  cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
        if(caracter == 'a'){
          caracter = obtenerAtomo(cadAtomix);
			    cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
          return caracter;
        }else
          caracter = error(caracter);
      }else
        caracter = error(caracter);
    }
  }
  return caracter;
}


char texto(char caracter){
  if(caracter=='c'){
    caracter = obtenerAtomo(cadAtomix);
		cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
    caracter = texto(caracter);
    return caracter;
  }else{
    if(caracter == 'd'){
      caracter = define(caracter);
      caracter = texto(caracter);
      return caracter;
    }else{
      if(caracter == 'n'|| caracter == 'f' || caracter == 'l'){
        return caracter;
      }else{
        if(caracter == 'u'){
          caracter = undef(caracter);
          caracter = texto(caracter);
          return caracter;
        }else{
          if(caracter == 'i' || caracter == 't' || caracter == 'm'){
            caracter = CompCond(caracter);
            caracter = texto(caracter);
            return caracter;
          }else
            caracter = error(caracter);
        }
      }
    }
    return caracter;
  }
}


char elseOp(char caracter){
  if(caracter == 'n'){
    return caracter;
  }else{
    if(caracter == 'f'){
      caracter = obtenerAtomo(cadAtomix);
			cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
      caracter = expConstante(caracter);
      caracter = texto(caracter);
      caracter = elseOp(caracter);
      return caracter;
    }else{
      if(caracter == 'l'){
        caracter = obtenerAtomo(cadAtomix);
			  cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
        caracter = texto(caracter);
        return caracter;
      }else
        caracter = error(caracter);
    }
    return caracter;
  }
}

/* ======================================
    Función define
======================================*/

char define(char caracter){
  if(caracter == 'd'){
    caracter = obtenerAtomo(cadAtomix);
    cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
      if(caracter == 'a'){
        caracter = obtenerAtomo(cadAtomix);
        cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
        if(caracter == 's'){
          caracter = obtenerAtomo(cadAtomix);
          cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
        }else
          caracter = error(caracter);
      }else
      caracter = error(caracter);
  }else{
    caracter = error(caracter);
  }
  return caracter;
}

/* ======================================
    Función undef
======================================*/

char undef(char caracter){
  if(caracter == 'u'){
    caracter = obtenerAtomo(cadAtomix);
		cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
    if(caracter == 'a'){
      caracter = obtenerAtomo(cadAtomix);
			cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
    }else{
      caracter = error(caracter);
    }
  }else{
    caracter = error(caracter);
  }
  return caracter;
}


/* ======================================
   Funcion expresion constante
======================================*/

char expConstante(char caracter){
  if(caracter == '(' || caracter == 'a' || caracter == 'e'){
    caracter = E(caracter);
    caracter = operadorRel(caracter);
    caracter = E(caracter);
  }else
    caracter = error(caracter);
  return caracter;
}


/* ======================================
    Funciones de aritmetica
======================================*/

char E(char caracter){
  if(caracter == '(' || caracter == 'a' || caracter == 'e'){
    caracter = T(caracter);
    caracter = EP(caracter);
  }else
      caracter = error(caracter);
  return caracter;
}

char EP(char caracter){
  if (caracter == '+'){
    caracter = obtenerAtomo(cadAtomix);
		cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
    caracter = T(caracter);
    caracter = EP(caracter);
    return caracter;
  }else{
      if(caracter == '-'){
        caracter = obtenerAtomo(cadAtomix);
        cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
        caracter = T(caracter);
        caracter = EP(caracter);
        return caracter;
      }else{
        if(caracter == '>' || caracter == 'g' || caracter == '<' || caracter == 'q' || caracter == 'p' || caracter == 'r' || caracter == 'c' || caracter == 'd' || caracter == 'u' || caracter=='i' || caracter == 't' || caracter == 'm' || caracter == 'n' || caracter == 'f' || caracter == 'l' || caracter == ')'){
          return caracter;
        }else
          caracter = error(caracter);
      }
  }
  return caracter;
}

char T(char caracter){
  if(caracter == '(' || caracter == 'a' || caracter == 'e'){
    caracter = F(caracter);
    caracter = TP(caracter);
  }else
    caracter = error(caracter);
  return caracter;
}

char TP(char caracter){
  if(caracter == '*' || caracter == '/' || caracter == '%'){
    caracter = obtenerAtomo(cadAtomix);
		cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
    caracter = F(caracter);
    caracter = TP(caracter);
    return caracter;
  }else{
    if(caracter == '+' || caracter == '-' || caracter == '>' || caracter == 'g' || caracter == '<' || caracter == 'p' || caracter == 'q' || caracter == 'r' || caracter == ')' || caracter == 'c' || caracter == 'd' || caracter == 'u' || caracter == 'i' || caracter == 't' || caracter == 'm' || caracter == 'n' || caracter == 'f' || caracter == 'l'){
      return caracter;
    }else
      caracter = error(caracter);
  }
  return caracter;
}


char F(char caracter){
    if(caracter == '(' ){
      caracter = obtenerAtomo(cadAtomix);
			cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
      caracter = E(caracter);
      if(caracter == ')'){
        caracter = obtenerAtomo(cadAtomix);
			  cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
        return caracter;
      }else{
        caracter = error(caracter);
      }
    }else {
      if(caracter == 'a' ||   caracter == 'e'){
        caracter = obtenerAtomo(cadAtomix);
		  	cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
        return caracter;
      }
      else{
        caracter = error(caracter);
      }
    }
    return caracter;
}



/* ======================================
    Funciones operadores relacionales
======================================*/

char operadorRel(char caracter){
  if(caracter == '>' || caracter == 'g' || caracter == '<' || caracter == 'q' || caracter == 'r' || caracter == 'p'){
    caracter = obtenerAtomo(cadAtomix);
		cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento cadAtomix
  }
  else{
    caracter = error(caracter);
  }
    return caracter;
}

/* ======================================
    Función parser
    Variable cadAtomix y caracter deben de ser GLOBALES
======================================*/

void parser(Atomo *cadAtomix){
  char caracter;
  caracter = obtenerAtomo(cadAtomix);
	cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
  caracter = SimboloInicial(caracter);
  if (caracter == '$')
    aceptar();
  else
    rechazar();
}

/* ======================================
    Funcion error
======================================*/
char error(char caracter){
  printf("\nHa ocurrido un error con el caracter: %c\n", caracter);
  caracter = obtenerAtomo(cadAtomix);
	cadAtomix = actualizaAtomos(cadAtomix); //Remueve el primer elemento(cadAtomix);
  return caracter;
}

/* ======================================
    Funcion aceptar y rechazar
======================================*/
void aceptar(){
  printf("La cadena de atomos es aceptada\n");
}

void rechazar(){
  printf("La cadena de atomos es rechazada\n");
}


/* ======================================
    Función principal
======================================*/
int main(int argc, char *argv[]){
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
    agregaFinCadena();
    printf("\n***************************************");
    printf("\nCOMIENZA PARSER");
    printf("\n***************************************\n");
    printf("\nCadena de atomos --> "); imprimeAtomosConsola(cadAtomix);
    parser(cadAtomix);
    free(simbolos);
    free(tokens);
    free(tablaCteS);
		free(tablaCodigoAnalizar);
    free(cadAtomix);
    fclose(salida);

    return 0;
	}
}
