#include<stdio.h>

char OP_REL[6][2] = {">", ">=", "<", "<=", "==", "!="}; 
char OP_ARI[5] = {'+', '-', '*', '/', '%'};

void lexLuthor(char, char, FILE*);
void error404(char);

void main(int argc, char *argv[]){
	char estado = 'I';
	char caracter;
	if ( argc != 2 ){
	        printf( "Usando el programa: %s. Se requiere el nombre del archivo como argumento.", argv[0] );
	}
	else{
		FILE *arch = fopen(argv[1], "r");
		if( arch == 0 ) 
			printf("Error al abrir archivo %s\n", argv[1]);
		else{
			while((caracter = fgetc(arch)) != EOF){
				printf("%c", caracter);
				lexLuthor(estado, caracter, arch);
			}
			fclose(arch);
		}
	}
}

void lexLuthor(char edo, char car_actual, FILE *arch){
	switch(edo){
		case 'I':
			switch(car_actual){
				case '~':
					edo = 'A';
					break;
				case '>':
					edo = 'B';
					break;
				default:
					error404(car_actual);
					edo = 'I';
					car_actual = fgetc(arch);
					break;
			}
			break;

	}
	printf("\nEstado: %c\n", edo);
}

void error404(char car){
	printf("CARACTER %c NO PERTENCE\n", car);
}
