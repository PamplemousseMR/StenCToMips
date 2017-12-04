int main() 
{
	stencil gx{1,2} = {{ 1, 0, -1 }, { 2, 0, 2 }, { -1, 0, -1 }}; 
	stencil gy{2,2} = 	{{1, 2,1, 2,1},
						{1,1 ,1, 1,1} 
							,{1,1 ,5, 1,1},
						{1,1 ,1, 1,1},
						{1,3 ,1, 3,1}};

	gy[2][2] += 5;

	int i,j;
	for(i=0 ; i<5 ; ++i)
	{
		for(j=0 ; j<5 ; ++j)
		{
			printi(gy[i][j]);
			printf(" ");
		} 
		printf("\n");
	} 
	return 0;
}
