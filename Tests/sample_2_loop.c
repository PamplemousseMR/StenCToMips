#define MAX_FOR 10
#define MAX_WHILE 7

int main(){
	int i, j;
	int l,m;

	for (i = 0, l = 3, m = 12; i < MAX_FOR; i++, l--, ++m){
	
		printi(l);
		printf("\n");
		printi(m);
		printf("\n");
		printf("\n");
		j = -6;
		
		while (j < MAX_WHILE){
			int k;
			printf("val de i : ");
			printi(i);
			printf(" val de j : ");
			printi(j);
			if(i%4)
			if(!(j%-2))
				printf(" (pair)");
			else
				printf(" (impair)");
			else
				printf(" nope");
			printf("\n");
			j++;
		}
		
		int k =0;
	}

	return 0;
}