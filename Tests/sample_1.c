#include <math.h>
#define HEIGHT 128
#define WIDTH 128
int main() {
	int i, j;
	int gx, gy;
	int image[HEIGHT][WIDTH]; // Image originale en niveaux de gris.
	int sobel[HEIGHT][WIDTH]; // Image transformée.
	
	// Filtre Sobel
	for (i = 1; i < HEIGHT - 1; i++) {
		for (j = 1; j < WIDTH - 1; j++) {

			gx = 	1 * image[i-1][j-1] + 0 * image[i-1][j] - 1 * image[i-1][j+1] +
					2 * image[i ][j-1] + 0 * image[i ][j] - 2 * image[i ][j+1] +
					1 * image[i+1][j-1] + 0 * image[i+1][j] - 1 * image[i+1][j+1];

			gy = 	1 * image[i-1][j-1] + 2 * image[i-1][j] + 1 * image[i-1][j+1] +
					0 * image[i ][j-1] + 0 * image[i ][j] - 0 * image[i ][j+1] +
					-1 * image[i+1][j-1] - 2 * image[i+1][j] - 1 * image[i+1][j+1];
					
			sobel[i][j] = sqrt((pow(gx, 2) + pow(gy, 2)) / 4.);
		}
	}
	return 0;
}