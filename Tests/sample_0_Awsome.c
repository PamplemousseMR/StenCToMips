#define CONST_VAR_NULLE 5

int fonctionNulle() {
    
    int tab[3];
    int k;
    
    tab[0] = 1;
    tab[1] = 5;
    tab[2] = 8;    
    
    for (k = 0; k < 3; ++k) {
    
        printi(tab[k]);
    
    }
	
	printf("\n");
    
    return 0;
}

int fonctionNulle2() {
	
	return 50;
	
}

int main() {

    fonctionNulle();
    int i;
    int k = 20;
    
    for (i=0; i<CONST_VAR_NULLE && 1 == 1; i+=1) {
    
        if (i%3 == 1) {
        
            printi(i);
			printf("\n");
        
        } else {
        
            if (i%3 == 2) {
            
                printf("trololol\n");
            
            } else {
				
				printf("oui\n");
				
			}
        
        }
    
    }
    
    while (k != 0) {
		
		if (k == 3 || (k%4 == 0 && k != 8)) {
			
			printi(k);
			printf("\n");
			
		}
    
        k--;
    
    }
	
	printi(fonctionNulle2());
	printf("\n");
    
    if (1) {
		
		return 0;
		
	} else {
		
		return 1;
		/* mdr */
		
	}

}