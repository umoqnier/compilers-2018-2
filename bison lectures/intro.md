# Uso de Yacc/Bison
Estructura de un programa ectrito en Yacc/Bison

definicion de tokens y directiva de preprocesador
%%
definicion de gramatica (LR)
%%
funciones auxiliares

## Ejemplo

<command>--> <expr>r{EscribeRes}r1  r1<--r
<expr>r1--> <expr>e+<term>t{Suma}e1,t1,r e1<--e, t1<--t, r<--e1+t1, r1<--r
<expr>r1--> <expr>e-<term>t{Resta}e1,t1,r e1<--e, t1<--t, r<--e1-t1, r1<--r
<expr>r1--> <term>t r1<--t
<term>t2--> <tern>t*<factor>f{Multi}t1,f1,r t1<--t, f1<--f, r<--t1*f1, t2<--r
<term>t--> <factor>f t<--f
<factor>f--> *e* e f<--e
<factor>f--> (<expr>e) f<--e

command : exp {printf("Resultado %d\n", $1);}
        ;
expr    : expr '+' term {$$=$1+$3;}
        | expr '-' term {$$=$1-$3;}
        | term {$$=$1;}
        ;
term    : term '\*' factor {$$=$1*$3;}
        | factor {$$=$1;}
        ;
factor  : NUMBER {$$=$1;}
        | '('expr')' {$$=$2;}
        ;
