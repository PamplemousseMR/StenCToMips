%start evaluation

%union {

  char* String;
  
}

%token<String> DEFINE
%token<String> ENDLINE
%token<String> FOR
%token<String> WHILE
%token<String> IF
%token<String> ELSE 
%token<String> RETURN      
%token<String> MAIN        
%token<String> PRINTF        
%token<String> PRINTI        
%token<String> ID           
%token<String> CHIFFRE      
%token<String> TYPE       
%token<String> STENCIL      
%token<String> OPERATOR        
%token<String> OPERATOR_STENCIL      
%token<String> INCREMENT        
%token<String> EQUALS        
%token<String> AFFECT        
%token<String> COMPARATOR   
%token<String> LBRA        
%token<String> RBRA        
%token<String> LHOO        
%token<String> RHOO        
%token<String> LEMB        
%token<String> REMB        
%token<String> COMMA        
%token<String> SEMI        
%token<String> STRING        

%{
	#include <stdio.h>
	#include <stdlib.h>
%}

%% //==============================================================================================

evaluation : 	LBRA evaluation RBRA  						{ printf("LBRA evaluation RBRA\n"); }						//checked
				| PRINTF LBRA STRING RBRA  					{ printf("PRINTF LBRA STRING RBRA\n"); }					//checked
				| PRINTI LBRA evaluation RBRA  				{ printf("PRINTI LBRA evaluation RBRA\n"); }				//checked
				| evaluation_valeur COMPARATOR evaluation  	{ printf("evaluation_valeur COMPARATOR evaluation \n"); }	//checked
				| evaluation_valeur OPERATOR evaluation  	{ printf("evaluation_valeur OPERATOR evaluation\n"); }		//checked
				| evaluation_valeur INCREMENT  				{ printf("evaluation_valeur INCREMENT\n"); }				//checked
				| INCREMENT evaluation  					{ printf("INCREMENT evaluation\n"); }						//checked
				| CHIFFRE 									{ printf("CHIFFRE\n"); }									//checked
				;

evaluation_valeur : evaluation

%% //==============================================================================================

int main(void) 
{
  yyparse();
  return 0;
}