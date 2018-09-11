#define HEIGHT 128
#define WIDTH 128

int sqrt(int i){
	int result = 0;
	if(i<=0)i*=-1;
	while(i >= result*result)
		result++;
	return (result-1);
}

int pow(int i,int j){
	int result = 1;
	while(j-- > 0)
		result *= i;
	return result;
}

int main() { 
	int i, j; 
	int image[HEIGHT][WIDTH]; 
	// Image originale en niveaux de gris. 
	int sobel[HEIGHT][WIDTH]; 
	// Image transformée. 
	stencil gx{1,2} = {{ 1, 0, -1 }, { 2, 0, -2 }, { 1, 0, -1 }}; 
	stencil gy{1,2} = {{ 1, 2, 1 }, { 0, 0, 0 }, { -1, -2, -1 }};

	
	
	// Filtre Sobel 
	for (i = 1; i < HEIGHT - 1; i++){
		for (j = 1; j < WIDTH - 1; j++) {
			sobel[i][j] = sqrt((pow(gx $ image[i][j], 2) 
							+ pow(gy $ image[i][j], 2)) / 4); 
							
		}
		printi(i*100/HEIGHT);
		printf("%\n");
	}
	
return 0;
}
