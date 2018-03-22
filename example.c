#undef
#define B "0"
#ifdef B
#if B>0
#define Pi "3.14159"
main() {
  printf("Programa con B>0\n");
#undef PI
  float pi = 3.14159;
} //fin del primer programa
#elif B<0
main() {
  printf("Programa con B<0\n");
} // fin del segundo programa
#else
main() {
  printf("Programa con B==0\n");
} // fin del tercer programa
#endif
#endif
