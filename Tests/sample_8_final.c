int main() 
{
	const int neig = 1;
	const int dim = 2;

	const int x = 5;
	const int y = 5;

	stencil gx{neig,dim} = {{ 2, 1, 2 }, { 1, 1, 1 }, { 2, 1, 2 }}; 

	int res[x][y];
	int tab[x][y]= {1,1,1,1,1,1,2,5,2,1,1,2,10,2,1,1,2,5,2,1,1,1,1,1,1};
	for(int i = 0 ; i < x ; ++i)
	{
		for(int j = 0 ; j < y ; ++j)
		{
			res[i][j] = 0;
		}
	}


	int wil = 1;
	while(wil)
	{
		printf("ajouter au tableau  : 1\n");
		printf("affectuer le cacule : 2\n");
		printf("quite               : 3\n");
		int cho = scani();
		if(cho == 1)
		{
			int chox = -1;
			while(chox<0 || chox>=x)
			{
				printf("valeur en x :");
				chox = scani();
			}
			int choy = -1;
			while(choy<0 || choy>=y)
			{
				printf("valeur en y :");
				choy = scani();
			}
			printf("valeur a entrer :");
			int val = scani();
			tab[chox][choy] = val;
			
			printf("tableau :\n");
			for(int i = 0 ; i < x ; ++i)
			{
				for(int j = 0 ; j < y ; ++j)
				{
					printi(tab[i][j]);
					printf(" ");
				}
				printf("\n");
			}
		}
		else if(cho == 2)
		{
			for(int i = neig ; i < x-neig ; ++i)
			{
				for(int j = neig ; j < y-neig ; ++j)
				{
					res[i][j] = tab[i][j] $ gx;
				}
			}
			for(int i = 0 ; i < x ; ++i)
			{
				for(int j = 0 ; j < y ; ++j)
				{
					printi(res[i][j]);
					printf(" ");
				}
				printf("\n");
			}
		}
		else if(cho == 3)
		{
			wil = 0;
		}

		if(tab[x/2][y/2] == 0)
		{
			wil = 0;
			printf("wololo\n");
		}
	}

	for(int i = 0 ; i<10 ; printi(i++))
	{
		printf("\n");
	}

	for(int i = 0 ; i < neig*2+1 ; ++i)
	{
		for(int j = 0 ; j < neig*2+1 ; ++j)
		{
			res[i][j] = tab[i][j];
		}
	}
	printf("\n");

	for(int i = 0 ; i < neig*2+1 ; ++i)
	{
		for(int j = 0 ; j < neig*2+1 ; ++j)
		{
			printi(res[i][j]);
			printf(" ");
		}
		printf("\n");
	}

	return 0;
}
