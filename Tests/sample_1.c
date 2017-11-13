#define HEIGHT 128
#define WIDTH 128
int main() 
{
	int i, j;
	int gx, gy;
	int image[HEIGHT][WIDTH]; // Image originale en niveaux de gris.
	int sobel[HEIGHT][WIDTH]; // Image transformée.

	stencil gx{1,2} = {{ 1, 0, -1 }, { 2, 0, 2 }, { -1, 0, -1 }}; 
	stencil gy{1,2} = {{ 1, 2, 1 }, { 0, 0, 0 }, { 1, 2, 1 }};

	if(1)
		if(1)
			printf("lol");
		else
			printf("bah nan");

	// Filtre Sobel
	for (i = 1; i < HEIGHT - 1; i++) 
	{
		for (j = 1; j < WIDTH - 1; ++j) 
		{
			sobel[i][j] = 	(((gx $ image[i][j] - 2) + (gy $ image[i][j] * 2)) / 4);
			i++;
		}
		printf("toto tata titi ");
		printf("toto \"tata\" \n titi");
		printf("toto \
		);printf(");
		printi(gx);
	}
	return 5+8;
}
