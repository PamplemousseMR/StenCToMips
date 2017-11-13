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
%type<String> chiffre

%{
	#include <stdio.h>
	#include <stdlib.h>
	
	int yylex();
	void yyerror (char const *s);
	
	FILE * outputFile;
%}


%% //==============================================================================================

//-------------------------------------------------------------------------------------------------
//				La structure d'un programme 
//-------------------------------------------------------------------------------------------------

programme : suite_instructions_preprocesseurs suite_fonctions { printf("suite_instructions_preprocesseurs suite_fonctions -> programme\n"); }; 

suite_instructions_preprocesseurs : instruction_preprocesseur suite_instructions_preprocesseurs { printf("instruction_preprocesseur suite_instructions_preprocesseurs -> suite_instructions_preprocesseurs\n"); } 
								    | 						{}
								    ;
									
instruction_preprocesseur : DEFINE ID chiffre ENDLINE		{ printf("DEFINE ID chiffre ENDLINE -> instruction_preprocesseur\n"); }; 

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

return : RETURN evaluation									{ printf("RETURN evaluation -> return\n"); };							

//-------------------------------------------------------------------------------------------------
//				Les variables
//-------------------------------------------------------------------------------------------------

stencil : ID LEMB CHIFFRE COMMA CHIFFRE REMB				{ printf("ID LEMB CHIFFRE COMA CHIFFRE REMB -> stencil\n"); };

variable : 	ID hooks 										{ printf("ID hooks -> variable\n"); };									

hooks : LHOO evaluation RHOO hooks							{ printf("LHOO evaluation RHOO -> hooks\n"); }	
		| {}
		;
		
initialisation : TYPE suite_variable_init 					{ printf("TYPE suite_variable_init -> initialisation\n"); }
				 | STENCIL suite_stencil_init				{ printf("STENCIL suite_stencil_init -> initialisation\n"); }
				 ;			

suite_variable_init : variable_init COMMA suite_variable_init {printf("variable_init COMA suite_variable_init -> suite_variable_init\n"); } 
					  | variable_init						{ printf("variable_init -> suite_variable_init\n"); }					
					  ;

suite_stencil_init : stencil_init COMMA suite_stencil_init  {printf("stencil_init COMA suite_stencil_init -> suite_stencil_init\n"); } 
					 | stencil_init							{ printf("stencil_init -> suite_stencil_init\n"); }					
					 ;
					  
variable_init : variable EQUALS evaluation					{ printf("variable EQUALS evaluation -> variable_init\n"); }	
				| variable EQUALS LEMB suite_chiffre REMB	{ printf("variable EQUALS LEMB suite_int REMB -> variable_init\n"); }	
				| variable									{ printf("variable -> variable_init\n"); }								
				;

stencil_init :  stencil EQUALS LEMB suite_suite_chiffre REMB { printf("stencil EQUALS LEMB suite_suite_chiffre REMB -> stencil_init\n"); }
				| stencil EQUALS LEMB suite_chiffre REMB 	{ printf("stencil EQUALS LEMB suite_chiffre REMB -> stencil_init\n"); }
				| stencil 									{ printf("stencil -> stencil_init\n"); }
				;

suite_suite_chiffre : LEMB suite_chiffre REMB COMMA suite_suite_chiffre { printf("LEMB suite_chiffre REMB COMMA suite_suite_chiffre -> suite_suite_chiffre\n"); }
					  | LEMB suite_chiffre REMB				{ printf("LEMB suite_chiffre REMB -> suite_suite_chiffre\n"); }
					  ;

suite_chiffre : chiffre COMMA suite_chiffre					{ printf("chiffre COMMA suite_chiffre -> suite_chiffre\n"); }	
				| chiffre 									{ printf("chiffre -> suite_chiffre\n"); }	
				;

affectation : variable EQUALS evaluation					{ printf("variable EQUALS evaluation -> affectation\n"); }				
			  | variable AFFECT evaluation					{ printf("variable AFFECT evaluation -> affectation\n"); }				
			  ;

//-------------------------------------------------------------------------------------------------
//				Les instructions conditionnelles
//-------------------------------------------------------------------------------------------------

for : FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne	{ printf("FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne -> for\n"); };
	
while : WHILE LBRA evaluation RBRA ligne 								{ printf("WHILE LBRA evaluation RBA ligne -> while\n"); };				

if : IF LBRA evaluation RBRA ligne else									{ printf("IF LBRA evaluation RBRA ligne else -> if\n"); };				

else : ELSE ligne														{ printf("ELSE ligne -> else\n"); }										
	   | {}
	   ;

//-------------------------------------------------------------------------------------------------
//				Le retour des valeurs 
//-------------------------------------------------------------------------------------------------

//valeur dans $t1
evaluation : evaluation_B COMPARATOR_OR evaluation			{ 
																printf("evaluation_B COMPARATOR_OR evaluation -> evaluation_\n"); 
															}
			   | evaluation_B								{ 
																printf("evaluation_B -> evaluation\n"); 
																fprintf(outputFile,"move $t1 $t2\n");
															}
			   ;
		  
//valeur dans $t2
evaluation_B : evaluation_C COMPARATOR_AND evaluation_B		{ 
																printf("evaluation_C COMPARATOR_AND evaluation_B -> evaluation_B\n"); 
															}
			   | evaluation_C								{ 	
																printf("evaluation_C -> evaluation_B\n");
																fprintf(outputFile,"move $t2 $t3\n"); 
															}
			   ;

//valeur dans $t3
evaluation_C : evaluation_D COMPARATOR_EQUALITY evaluation_C { 
																printf("evaluation_COMPARATOR_EQUALITY evaluation_C -> evaluation_C\n");
															}
			   | evaluation_D								{ 
																printf("evaluation_D -> evaluation_C\n");
																fprintf(outputFile,"move $t3 $t4\n");
															} 
			   ;
		  
//valeur dans $t4
evaluation_D : evaluation_E COMPARATOR_SUPREMACY evaluation_D { 
																printf("evaluation_E COMPARATOR_SUPREMACY evaluation_D -> evaluation_D\n"); 
															}
			   | evaluation_E								{ 
																printf("evaluation_E -> evaluation_D\n");
																fprintf(outputFile,"move $t4 $t5\n"); 
															}
			   ;
		  
//valeur dans $t5
evaluation_E : evaluation_F OPERATOR_ADDITION evaluation_E	{ 
																printf("evaluation_F OPERATOR_ADDITION evaluation_E -> evaluation_E\n"); 
															}
			   | evaluation_F								{ 
																printf("evaluation_F -> evaluation_E\n"); 
																fprintf(outputFile,"move $t5 $t6\n");
															}
			   ;
		  
//valeur dans $t6
evaluation_F : evaluation_G OPERATOR_MULTI evaluation_F		{ 
																printf("evaluation_G OPERATOR_MULTI evaluation_F -> evaluation_F\n"); 
															}
			   | evaluation_G								{ 
																printf("evaluation_G -> evaluation_F\n");
																fprintf(outputFile,"move $t6 $t7\n");
															}
			   ;

//valeur dans $t7			   
evaluation_G : LBRA evaluation RBRA							{ 
																printf("LBRA evaluation RBRA -> evaluation_G\n"); 
															}
			   | PRINTI LBRA evaluation RBRA				{ 
																printf("PRINTI LBRA evaluation RBRA -> evaluation_G\n");
																fprintf(outputFile,"move $a0 $t1\nli $v0 1\nsyscall\n");
															}
			   | PRINTF LBRA STRING RBRA					{ 	
																printf("PRINTF LBRA STRING RBRA -> evaluation_G\n"); 
															}
			   | OPERATOR_NEGATION evaluation				{ 
																printf("OPERATOR_NEGATION evaluation -> evaluation_G\n"); 
															}
			   | chiffre									{
																printf("chiffre -> evaluation_G\n");
																fprintf(outputFile,"li $t7 %s\n",$1);
															}
			   | variable_incr								{ 
																printf("variable_incr -> evaluation_G\n"); 
															}
			   ;

variable_incr : OPERATOR_INCREMENT variable					{ 
																printf("OPERATOR_INCREMENT variable -> variable_incr\n");
															}
				| variable OPERATOR_INCREMENT				{ 
																printf("variable OPERATOR_INCREMENT -> variable_incr\n"); 
															}
				| variable 									{ 
																printf("variable -> variable_incr\n"); 
															}
				;

chiffre : CHIFFRE 											{ 
																printf("CHIFFRE -> chiffre\n"); 
																sprintf($$,"%s",$1);
															}
		  | OPERATOR_ADDITION CHIFFRE 						{ 
																printf("OPERATOR_ADDITION CHIFFRE -> chiffre\n");
																sprintf($$,"%s%s",$1,$2); 
															}
		  ;
			   
%% //==============================================================================================

int main(void) 
{
	outputFile = fopen("output.mips","w");
	yyparse();
	return 0;
}

void yyerror (char const *s)
{
	printf("error : %s %d\n",s, yychar);
}