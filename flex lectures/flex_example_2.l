%{
/*Programa que recibe números decimel, octal y hexadecimal e imprimie su representación en decimal, octal y hexadecimal*/
#include<stdio.h>
#include<stdlib.h>
%}

octal       0[0-7]+
decimal     0|[1-9][0-9]*
hexadecimal 0[xX][0-9a-fA-F]+

%%
{octal} {EscribeOctal(yytext);}
{decimal} {EscribeDecimal(yytext);}
{hexadecimal} {EscribeHexadecimal(yytext);}
%%

void EscribeOctal(char *cad){
	int num = atoi(cad);
	printf("\n%s es octal\n equivale a %d en decimal\ny a %x en hexadecimal", cad, num, num);
}

void EscribeDecimal(char *cad){
	int num = atoi(cad);
	printf("\n%s es decimal\n equivale a %o en octal\ny a %x en hexadecimal", cad, num, num);
}

void EscribeHexadecimal(char *cad){
	int num = atoi(cad);
	printf("\n%s es hexadecimal\n equivale a %d en decimal\ny a %o en octal", cad, num, num);
}

main(){
	yylex();
}
