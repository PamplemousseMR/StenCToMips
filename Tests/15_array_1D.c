//#include <stdio.h>
//#define printf(X) fprintf(stdout, "%s", (X))
//#define printi(X) fprintf(stdout, "%d", (X))

int main() {
  int a[10];
  int i;
  a[0] = 1;

  for(i = 1; i < 10; i = i + 1) {
	a[i] = a[2];
    printi(a[i]);
  }
  return 0;
}
