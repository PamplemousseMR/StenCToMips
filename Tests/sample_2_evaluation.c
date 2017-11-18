#define LOL 12

int main() 
{
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
		int b = 5+8*1+(4*3+(5-6));
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

	const int c,d,e = 3,f;
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
	// must throw error
	/* 
	c = 2;		// const
	d++;		// const
	printi(e);	// non initailise
	printi(h);	// existe pas
	printf(LOL); // int et pas string
	*/
}
