%start ligne

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

suite_instructions : ligne suite_instructions				{ printf("suite_instructions -> ligne suite_instructions \n"); }		//checked
					| ligne									{ printf("suite_instructions -> ligne\n"); }							//checked
					;

ligne : for 												{ printf("ligne -> for\n"); }											//checked
		| while												{ printf("ligne -> while\n"); }											//checked
		| if 												{ printf("ligne -> if\n"); }											//checked
		| LEMB suite_instructions REMB 						{ printf("ligne -> LEMB suite_instructions REMB\n"); }					//checked
		| evaluation SEMI									{ printf("ligne -> evaluation\n"); }									//checked
		;

//-------------------------------------------------------------------------------------------------


variable : 	ID 	hooks 										{ printf("variable -> ID hooks\n"); };									//checked

hooks : LHOO evaluation RHOO hooks							{ printf("hooks -> LHOO evaluation RHOO\n"); }							//checked
		| ;																															//checked

//-------------------------------------------------------------------------------------------------

for : FOR LBRA SEMI SEMI RBRA ligne							{ printf("for -> FOR LBRA SEMI SEMI RBRA ligne\n"); };					//checked
	
while : WHILE LBRA evaluation RBRA ligne 					{ printf("while -> WHILE LBRA evaluation RBA ligne\n"); };				//checked

if : IF LBRA evaluation RBRA ligne else						{ printf("if -> IF LBRA evaluation RBRA ligne else\n"); };				//checked

else : ELSE ligne											{ printf("else -> ELSE ligne\n"); }										//checked
	   | ;


//-------------------------------------------------------------------------------------------------

evaluation : 	LBRA evaluation RBRA  						{ printf("evaluation -> LBRA evaluation RBRA\n"); }						//checked
				| PRINTF LBRA STRING RBRA  					{ printf("evaluation -> PRINTF LBRA STRING RBRA\n"); }					//checked
				| PRINTI LBRA evaluation RBRA  				{ printf("evaluation -> PRINTI LBRA evaluation RBRA\n"); }				//checked
				| evaluation_valeur COMPARATOR evaluation  	{ printf("evaluation -> evaluation_valeur COMPARATOR evaluation \n"); }	//checked
				| evaluation_valeur OPERATOR evaluation  	{ printf("evaluation -> evaluation_valeur OPERATOR evaluation\n"); }	//checked
				| evaluation_valeur INCREMENT  				{ printf("evaluation -> evaluation_valeur INCREMENT\n"); }				//checked
				| INCREMENT evaluation  					{ printf("evaluation -> INCREMENT evaluation\n"); }						//checked
				| CHIFFRE 									{ printf("evaluation -> CHIFFRE\n"); }									//checked
				| variable									{ printf("evaluation -> variable\n"); }
				;

evaluation_valeur : evaluation ;																									//checked

%% //==============================================================================================

int main(void) 
{
  yyparse();
  return 0;
}