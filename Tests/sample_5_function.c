#define ABC 123
#define DEF 4
#define GHI 5

int pow(){
	int i = 2,j = 4,result = 1;
	for(j = j;j > 0;j--)
		result *= i;
	
	return result; 
}

int main(){
	int temp = pow();
	printi(temp);
	return 0;
}