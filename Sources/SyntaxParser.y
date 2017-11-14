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
%type<String> variable_incr
%type<String> chiffre

%{
	#include <stdio.h>
	#include <stdlib.h>
	
	#include "SymbolesTable.h"

	int yylex();
	void yyerror (char const *s);
	
	FILE* outputFile;
	List symboleTable;
%}

%left COMPARATOR_OR
%left COMPARATOR_AND		
%left COMPARATOR_EQUALITY 
%left COMPARATOR_SUPREMACY
%left OPERATOR_ADDITION
%left OPERATOR_MULTI	
%left OPERATOR_INCREMENT
%left OPERATOR_NEGATION			

%%

//=================================================================================================
//				La structure d'un programme 
//=================================================================================================

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

//=================================================================================================
//				Les variables
//=================================================================================================

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

//=================================================================================================
//				Les instructions conditionnelles
//=================================================================================================

for : FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne	{ printf("FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne -> for\n"); };
	
while : WHILE LBRA evaluation RBRA ligne 								{ printf("WHILE LBRA evaluation RBA ligne -> while\n"); };				

if : IF LBRA evaluation RBRA ligne else									{ printf("IF LBRA evaluation RBRA ligne else -> if\n"); };				

else : ELSE ligne														{ printf("ELSE ligne -> else\n"); }										
	   | {}
	   ;

//=================================================================================================
//				Le retour des valeurs 
//=================================================================================================

evaluation : 
// ---------------------------------------------------------------- OR 
evaluation COMPARATOR_OR { 
	fprintf(outputFile,"move $t9 $t0\n"); 
} evaluation { 
	printf("evaluation COMPARATOR_OR evaluation -> evaluation\n");
}
// ---------------------------------------------------------------- AND
| evaluation COMPARATOR_AND { 
	fprintf(outputFile,"move $t8 $t0\n"); 
} evaluation { 															
	printf("evaluation COMPARATOR_AND evaluation -> evaluation\n"); 
}
// ---------------------------------------------------------------- EQUALITY
| evaluation COMPARATOR_EQUALITY { 
	fprintf(outputFile,"move $t7 $t0\n");
} evaluation { 
	printf("evaluationOMPARATOR_EQUALITY evaluation -> evaluation\n");
}
// ---------------------------------------------------------------- SUPREMACY
| evaluation COMPARATOR_SUPREMACY { 
	fprintf(outputFile,"move $t6 $t0\n"); 
} evaluation {
	printf("evaluation COMPARATOR_SUPREMACY evaluation -> evaluation\n"); 
}
// ---------------------------------------------------------------- ADDITION 		DONE
| evaluation  OPERATOR_ADDITION { 
	fprintf(outputFile,"move $t5 $t0\n"); 
} evaluation { 
	printf("evaluation OPERATOR_ADDITION evaluation -> evaluation\n");
	if($2[0] == '+'){
		fprintf(outputFile,"add $t0 $t5 $t0\n");
	}else{
		fprintf(outputFile,"sub $t0 $t5 $t0\n");
	}
}
// ---------------------------------------------------------------- MULTI 			DONE
| evaluation  OPERATOR_MULTI { 
	fprintf(outputFile,"move $t4 $t0\n"); 
} evaluation { 
	printf("evaluation OPERATOR_MULTI evaluation -> evaluation\n"); 
	if($2[0] == '*'){
		fprintf(outputFile,"mul $t0 $t4 $t0\n");
	}else{
		fprintf(outputFile,"div $t0 $t4 $t0\n");
	}
}
// ---------------------------------------------------------------- LBRA RBRA
| LBRA {
	fprintf(outputFile,"subi $sp $sp %d\n",4*9); 
	for(int i=1 ; i<=9 ; ++i)
	{
		fprintf(outputFile,"sw $t%d %d($sp)\n",i,i*4); 
	}
} evaluation RBRA{ 
	printf("LBRA evaluation RBRA -> evaluation\n"); 
	for(int i=9 ; i<=9 ; ++i)
	{
		fprintf(outputFile,"lw $t%d %d($sp)\n",i,i*4); 
	}
	fprintf(outputFile,"addi $sp $sp %d\n",4*9); 
}
// ---------------------------------------------------------------- PRINTI			DONE
| PRINTI LBRA evaluation RBRA { 
	printf("PRINTI LBRA evaluation RBRA -> evaluation\n");
	fprintf(outputFile,"move $a0 $t0\nli $v0 1\nsyscall\n");
}
// ---------------------------------------------------------------- PRINTF
| PRINTF LBRA STRING RBRA { 	
	printf("PRINTF LBRA STRING RBRA -> evaluation\n"); 
}
// ---------------------------------------------------------------- NEGATION 		DONE
| OPERATOR_NEGATION evaluation { 
	printf("OPERATOR_NEGATION evaluation -> evaluation\n");
	fprintf(outputFile,"beq $0 $t0 OPPE_NEG\n");
	fprintf(outputFile,"li $t0 0\nj OPPE_NEG_FIN\n");
	fprintf(outputFile,"OPPE_NEG :\nli $t0 1\nOPPE_NEG_FIN :\n");
}
// ---------------------------------------------------------------- CHIFFRE 		DONE
| chiffre {
	printf("chiffre -> evaluation\n");
	fprintf(outputFile,"li $t0 %s\n",$1);
}
// ---------------------------------------------------------------- INCR
| variable_incr	{ 
	printf("variable_incr -> evaluation\n"); 
}
;


variable_incr : 
// ---------------------------------------------------------------- INCR
OPERATOR_INCREMENT variable	{ 
	printf("OPERATOR_INCREMENT variable -> variable_incr\n");
	// pour ++
	// addi $variable 1
	// move $t0 $variable
}
// ---------------------------------------------------------------- INCR
| variable OPERATOR_INCREMENT { 
	printf("variable OPERATOR_INCREMENT -> variable_incr\n"); 
	// pour ++
	// move $t0 $variable
	// addi $varibale 1
}
// ---------------------------------------------------------------- variable
| variable { 
	printf("variable -> variable_incr\n");
	// move $t0 $variable
}
;

chiffre : 
// ---------------------------------------------------------------- CHIFFRE 	DONE
CHIFFRE { 
	printf("CHIFFRE -> chiffre\n"); 
	sprintf($$,"%s",$1);
}
// ---------------------------------------------------------------- OPERATOR 	DONE
| OPERATOR_ADDITION CHIFFRE { 
	printf("OPERATOR_ADDITION CHIFFRE -> chiffre\n");
	sprintf($$,"%s%s",$1,$2); 
}
;
			   
%% //==============================================================================================

int main(void) 
{
	
	symboleTable = mallocList();
	outputFile = fopen("output.mips","w");

	fprintf(outputFile,".data\n.text\n.globl main\n\nmain :\n");

	yyparse();

	fprintf(outputFile,"\nExit :\nla $v0 10\nsyscall\n");

	fclose(outputFile);
	freeList(symboleTable);

	return 0;
}

void yyerror (char const *s)
{
	printf("error : %s %d\n",s, yychar);

	fclose(outputFile);
	freeList(symboleTable);
}