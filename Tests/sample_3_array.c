#define WIDTH  42
#define HEIGHT 26
	
int main(){
	//must work
	int i;
	int j;

	const int tabfgh[4] = {{{1},{2}},{{1+1+1*1+2*4},{2}}};
	for(i=0 ; i<4 ;++i)
	{
		printi(tabfgh[i]);
		printf("\n");
	}
	printf("\n");

	int tab[3] = {1,2,3};
	for(i=0 ; i<3 ;++i)
	{
		printi(tab[i]);
		printf("\n");
	}
	printf("\n");


	int tabb[2][2] = {{1,2},{3,4}};
	for(i=0 ; i<2 ;++i)
	{
		for(j=0 ; j<2 ; ++j)
		{
			printi(tabb[i][j]);
			printf("\t");
		}
		printf("\n");
	}
	printf("\n");

	int jj=1, ii[2],kk[2][2] = {{1,2},{1,2}};

	int array[5][2];
	for(i=0 ; i<5 ;++i)
	{
		for(j=0 ; j<2 ; ++j)
		{
			array[i][j] = i+j;
		}
	}

	for(i=0 ; i<5 ;++i)
	{
		for(j=0 ; j<2 ; ++j)
		{
			printi(array[i][j]);
			printf("\t");
		}
		printf("\n");
	}
	printf("\n");

	for(i=0 ; i<5 ;++i)
	{
		for(j=0 ; j<2 ; ++j)
		{
			printi(++array[i][j]);
			printf("\t");
		}
		printf("\n");
	}
	printf("\n");

	int rec[array[4][1]][array[2][0]];  // 6 3
	for(i=0 ; i<array[4][1] ;++i)
	{
		for(j=0 ; j<array[2][0] ; ++j)
		{
			rec[i][j] = 5;
			printi(rec[i][j]);
			printf("\t");
		}
		printf("\n");
	}
	printf("\n");
	
	int test[2][3][2] = {2,2,2,2,tabb[0][1]+5,2,5,6,3,5,8,9000};  
	int k;
	for(i=0 ; i<2 ;++i)
	{
		for(j=0 ; j<3 ; ++j)
		{
			for(k=0 ; k<2 ; ++k)
			{
				printi(test[i][j][k]);
				printf(" ");
			}
			printf("\n");
		}
		printf("\n");
	}
	printf("\n");

	return 0;
}
