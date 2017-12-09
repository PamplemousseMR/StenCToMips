#define ABC 123
#define DEF 4
#define GHI 5

int add(stencil ti, int tj[][], int x, int y)
{
	printi(ti $ tj[1][1]);
	printf("\n-------\n");

	for(int i=0 ; i<x ; ++i)
	{
		for(int j=0 ; j<y ; ++j)
		{
			ti[i][j] += tj[i][j];
		}
	}

	for(int i=0 ; i<x ; ++i)
	{
		for(int j=0 ; j<y ; ++j)
		{
			printi(ti[i][j]);
			printf(" ");
		}
		printf("\n");
	}
	return 0; 
}

int pow(int i,int j)
{
	int result = 1;
	for(j = j;j > 0;j--)
		result *= i;
	
	return result; 
}

int fibo(int i)
{
	if(i <= 0) return 0;
	if(i == 1) return 1;
	return fibo(i-1)+fibo(i-2);
}

int test(int i){
	i += i;
	return i;
}


int main()
{
	stencil gx{1,2} = {1,2,3,1,2,3,1,2,3};
	int tab[2][2] = {1,2,3,4};
	int temp = pow(tab[0][1],tab[1][1]);
	printi(temp);
	printf("\n-------\n");

	int tab2[3][3] = {2,2,9,10,5,6,9,7,8};
	add(gx,tab2,3,3);
	printf("\n-------\n");
	int k = 2;
	printi(k);
	printf("\n-------\n");
	printi(test(k));
	printf("\n-------\n");
	printi(k);
	printf("\n-------\n");
	printi(fibo(test(5)));

	return 0;
}