#define LOL 12

int main() 
{
	int ii,jj;
	int test;

	const int je = 5;
	printi(je);
	printf("\n");

	ii = 1;
	jj = 2;

	ii++;
	printi(ii);

	int a = 0;
	printi(a++);
	printf("\n");
	printi(a--);
	printf("\n");
	printi(--a);
	printf("\n");
	printi(++a);
	printf("\n");

	{
		int b = 5+8*1+(4*a+(5-6));
		printf("b = ");
		printi(b);
		printf("\n");
	}

	int b = 5+8*9+(5*3+(5-6));
	printf("b = ");
	printi(b);
	printf("\n");
	
	printf("LOL = ");
	printi(LOL);
	printf("\n"); 

	int c,d,e = 3,f;
	printf("c = ");
	printi(e);
	printf("\n");

	int mo = 5;
	mo %= 2; 
	printi(mo);
	printf("\n");
	mo = 9;
	mo %= 2;
	printi(mo);
	printf("\n");
	mo = 10;
	mo %= 2;
	printi(mo);
	printf("\n");
	mo = 10;
	mo %= 4;
	printi(mo);
	printf("\n");
	mo = -10;
	mo %= 4;
	printi(mo);
	printf("\n");

	printf("\n");
	printi(5%2);
	printf("\n");
	printi(11%3);
	printf("\n");
	printi(10%5);
	printf("\n");
	printi(-10%3);
	printf("\n");

	return 0;
		
	// must throw error
	
	
	// printi(kk);
	// d++;
	// printf(e);
	// printi(h);
	// printf(LOL);
	

	// return 0;
}
