%start programme

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
%token<String> STENCIL				
%token<String> TYPE				
%token<String> ID					
%token<String> CHIFFRE				
%token<String> OPERATOR_NEGATION	
%token<String> OPERATOR_INCREMENT	
%token<String> OPERATOR_MULTI		
%token<String> OPERATOR_ADDITION	
%token<String> COMPARATOR_SUPREMACY 
%token<String> COMPARATOR_EQUALITY 
%token<String> COMPARATOR_AND		
%token<String> COMPARATOR_OR		
%token<String> EQUALS				
%token<String> AFFECT				
%token<String> OPERATOR_STENCIL	
%token<String> LBRA				
%token<String> RBRA				
%token<String> LHOO				
%token<String> RHOO				
%token<String> LEMB				
%token<String> REMB				
%token<String> COMMA				
%token<String> SEMI				
%token<String> STRING				

%type<String> programme           
%type<String> suite_instructions_preprocesseurs           
%type<String> instruction_preprocesseur           
%type<String> suite_fonctions           
%type<String> main           
%type<String> suite_instructions           
%type<String> ligne           
%type<String> return           
%type<String> variable           
%type<String> hooks           
%type<String> initialisation           
%type<String> suite_variable_init           
%type<String> variable_init           
%type<String> affectation           
%type<String> for           
%type<String> while
%type<String> if
%type<String> else
%type<String> evaluation
%type<String> evaluation_B
%type<String> evaluation_C
%type<String> evaluation_D
%type<String> evaluation_E
%type<String> evaluation_F
%type<String> evaluation_G
%type<String> variable_incr

%{
	#include <stdio.h>
	#include <stdlib.h>

	#define KNRM  "\x1B[0m"
	#define KRED  "\x1B[31m"
	#define KGRN  "\x1B[32m"
	#define KYEL  "\x1B[33m"
	#define KBLU  "\x1B[34m"
	#define KMAG  "\x1B[35m"
	#define KCYN  "\x1B[36m"
	#define KWHT  "\x1B[37m"
	
	int yylex();
	void yyerror (char const *s);
%}

%% //==============================================================================================

//-------------------------------------------------------------------------------------------------
//				La structure d'un programme 
//-------------------------------------------------------------------------------------------------

programme : suite_instructions_preprocesseurs suite_fonctions { printf("suite_instructions_preprocesseurs suite_fonctions -> programme\n"); }; 

suite_instructions_preprocesseurs : instruction_preprocesseur suite_instructions_preprocesseurs { printf("instruction_preprocesseur suite_instructions_preprocesseurs -> suite_instructions_preprocesseurs\n"); } 
								    | 						{}
								    ;
									
instruction_preprocesseur : DEFINE ID CHIFFRE ENDLINE		{ printf("DEFINE ID CHIFFRE ENDLINE -> instruction_preprocesseur\n"); }; 

suite_fonctions : main										{ printf("main -> suite_fonctions\n"); } ; 								

main : TYPE MAIN LBRA RBRA LEMB suite_instructions REMB 	{ printf("TYPE MAIN LBRA RBRA LEMB suite_instructions REMB -> main\n"); }; 

suite_instructions : ligne suite_instructions				{ printf("ligne suite_instructions  -> suite_instructions\n"); }		
					| 										{}							
					;

ligne : for 												{ printf("for -> ligne\n"); }											
		| while												{ printf("while -> ligne\n"); }											
		| if 												{ printf("if -> ligne\n"); }											
		| LEMB suite_instructions REMB 						{ printf("LEMB suite_instructions REMB -> ligne\n"); }					
		| initialisation SEMI								{ printf("initialisation SEMI -> ligne\n"); }							
		| affectation SEMI									{ printf("affectation SEMI -> ligne\n"); }								
		| return SEMI										{ printf("return SEMI -> ligne\n"); }									
		| evaluation SEMI									{ printf("evaluation SEMI -> ligne\n"); }								
		;

return : RETURN evaluation									{ printf("RETURN evaluation -> return : %s%s %s%s\n", KYEL, $1, $2, KNRM); };							

//-------------------------------------------------------------------------------------------------
//				Les variables
//-------------------------------------------------------------------------------------------------

variable : 	ID hooks 										{ printf("ID hooks -> variable\n"); };									

hooks : LHOO evaluation RHOO hooks							{ printf("LHOO evaluation RHOO -> hooks\n"); }							
		| {}
		;
		
initialisation : TYPE suite_variable_init 					{ printf("TYPE suite_variable_init -> initialisation\n"); };			

suite_variable_init : variable_init COMMA suite_variable_init {printf("variable_init COMA suite_variable_init -> suite_variable_init\n"); } 
					  | variable_init						{ printf("variable_init -> suite_variable_init\n"); }					
					  ;
					  
variable_init : variable EQUALS evaluation					{ printf("variable EQUALS evaluation -> variable_init\n"); }			
				| variable									{ printf("variable -> variable_init\n"); }								
				;

affectation : variable EQUALS evaluation					{ printf("variable EQUALS evaluation -> affectation\n"); }				
			  | variable AFFECT evaluation					{ printf("variable AFFECT evaluation -> affectation\n"); }				
			  ;

//-------------------------------------------------------------------------------------------------
//				Les instructions conditionnelles
//-------------------------------------------------------------------------------------------------

for : FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne	{ printf("FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne -> for\n"); };					//not finish
	
while : WHILE LBRA evaluation RBRA ligne 								{ printf("WHILE LBRA evaluation RBA ligne -> while\n"); };				

if : IF LBRA evaluation RBRA ligne else									{ printf("IF LBRA evaluation RBRA ligne else -> if\n"); };				

else : ELSE ligne														{ printf("ELSE ligne -> else\n"); }										
	   | {}
	   ;

//-------------------------------------------------------------------------------------------------
//				Le retour des valeurs 
//-------------------------------------------------------------------------------------------------

evaluation : evaluation_B COMPARATOR_OR evaluation			{ printf("evaluation_B COMPARATOR_OR evaluation -> evaluation_\n"); }
			   | evaluation_B								{ printf("evaluation_B -> evaluation\n"); }
			   ;
		  
evaluation_B : evaluation_C COMPARATOR_AND evaluation_B		{ printf("evaluation_C COMPARATOR_AND evaluation_B -> evaluation_B\n"); }
			   | evaluation_C								{ printf("evaluation_C -> evaluation_B\n"); }
			   ;

evaluation_C : evaluation_D COMPARATOR_EQUALITY evaluation_C { printf("evaluation_COMPARATOR_EQUALITY evaluation_C -> evaluation_C\n"); }
			   | evaluation_D								{ printf("evaluation_D -> evaluation_C\n"); } 
			   ;
		  
evaluation_D : evaluation_E COMPARATOR_SUPREMACY evaluation_D { printf("evaluation_E COMPARATOR_SUPREMACY evaluation_D -> evaluation_D\n"); }
			   | evaluation_E								{ printf("evaluation_E -> evaluation_D\n"); }
			   ;
		  
evaluation_E : evaluation_F OPERATOR_ADDITION evaluation_E	{ printf("evaluation_F OPERATOR_ADDITION evaluation_E -> evaluation_E\n"); }
			   | evaluation_F								{ printf("evaluation_F -> evaluation_E\n"); }
			   ;
		  
evaluation_F : evaluation_G OPERATOR_MULTI evaluation_F		{ printf("evaluation_G OPERATOR_MULTI evaluation_F -> evaluation_F\n"); }
			   | evaluation_G								{ printf("evaluation_G -> evaluation_F\n"); }
			   ;
		  
evaluation_G : LBRA evaluation RBRA							{ printf("LBRA evaluation RBRA -> evaluation_G\n"); }
			   | PRINTI LBRA evaluation RBRA				{ printf("PRINTI LBRA evaluation RBRA -> evaluation_G\n"); }
			   | PRINTF LBRA STRING RBRA					{ printf("PRINTF LBRA STRING RBRA -> evaluation_G\n"); }
			   | OPERATOR_NEGATION evaluation				{ printf("OPERATOR_NEGATION evaluation -> evaluation_G\n"); }
			   | CHIFFRE									{ printf("CHIFFRE -> evaluation_G\n"); }
			   | variable_incr								{ printf("variable_incr -> evaluation_G\n"); }
			   ;

variable_incr : OPERATOR_INCREMENT variable					{ printf("OPERATOR_INCREMENT variable -> variable_incr\n"); }
				| variable OPERATOR_INCREMENT				{ printf("variable OPERATOR_INCREMENT -> variable_incr\n"); }
				| variable 									{ printf("variable -> variable_incr\n"); }
				;
			   
%% //==============================================================================================

int main(void) 
{
  yyparse();
  return 0;
}