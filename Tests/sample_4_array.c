#define WIDTH  42
#define HEIGHT 26
	
int main(){
	//must work
	int i;
	int j;

	int tabfgh[4] = {{{1},{2}},{{3},{2}}};

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

	int rec[array[4][1]][array[2][0]];  // 5 2
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
	
	int test[2][3] = {2,2,2,2,tabb[0][2]+5,2};  // 5 2

	//must throws error
	// tab = 10;
	// tabb[1] = 5;
	// int tabbb[5] = {1}
}
