#define B "5"
#define PF "printf"

#ifdef B
main() {
#if B>5
  PF("Programa con B>5\n");
#elif B==5
  PF("Programa con B = 5\n");
#endif
}
#endif
