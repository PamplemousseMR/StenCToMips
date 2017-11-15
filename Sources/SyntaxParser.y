%code requires {
    #include "InstructionsList.h"
}

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#include "InstructionsList.h"
	#include "SymbolesTable.h"

	unsigned long long labelCounter = 0;
	unsigned long long variableCounter = 0;

	int yylex();
	void yyerror (char const *s);

	FILE* outputFile;
	List symboleTable;
	InstructionsList rootTree; 
%}

%union {

	char* String;
	Instruction* tree;

}


%start programme

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
%type<String> preprocessor_instructions_serie
%type<String> preprocessor_instruction
%type<String> functions_serie
%type<String> main
%type<String> instructions_serie
%type<String> ligne
%type<String> return
%type<String> variable
%type<String> hooks
%type<String> initialisation
%type<String> variables_init_serie
%type<String> variable_init
%type<String> affectation
%type<String> for
%type<String> while
%type<String> if
%type<String> else
%type<String> evaluation
%type<String> variable_incr
%type<String> chiffre

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

programme :
// ------------------------------------------------------------------
preprocessor_instructions_serie functions_serie {
	printf("preprocessor_instructions_serie functions_serie -> programme\n");
}
;

//__________________________________________________________________________________

preprocessor_instructions_serie :
// ------------------------------------------------------------------
preprocessor_instruction preprocessor_instructions_serie {
	printf("preprocessor_instruction preprocessor_instructions_serie -> preprocessor_instructions_serie\n");
}
// ------------------------------------------------------------------
| {
}
;

//__________________________________________________________________________________

preprocessor_instruction :
// ------------------------------------------------------------------
DEFINE ID chiffre ENDLINE {
	printf("DEFINE ID chiffre ENDLINE -> preprocessor_instruction\n");
}
;

//__________________________________________________________________________________

functions_serie :
// ------------------------------------------------------------------
main {
	printf("main -> functions_serie\n");
}
;

//__________________________________________________________________________________

main :
// ------------------------------------------------------------------
TYPE MAIN LBRA RBRA LEMB instructions_serie REMB {
	printf("TYPE MAIN LBRA RBRA LEMB instructions_serie REMB -> main\n");
}
;

//__________________________________________________________________________________

instructions_serie :
// ------------------------------------------------------------------
ligne instructions_serie {
	printf("ligne instructions_serie -> instructions_serie\n");
}
// ------------------------------------------------------------------
| {
}
;

//__________________________________________________________________________________

ligne :
// ------------------------------------------------------------------
for {
	printf("for -> ligne\n");
}
// ------------------------------------------------------------------
| while {
	printf("while -> ligne\n");
}
// ------------------------------------------------------------------
| if {
	printf("if -> ligne\n");
}
// ------------------------------------------------------------------
| LEMB instructions_serie REMB {
	printf("LEMB instructions_serie REMB -> ligne\n");
}
// ------------------------------------------------------------------
| initialisation SEMI {
	printf("initialisation SEMI -> ligne\n");
}
// ------------------------------------------------------------------
| affectation SEMI {
	printf("affectation SEMI -> ligne\n");
}
// ------------------------------------------------------------------
| return SEMI {
	printf("return SEMI -> ligne\n");
}
// ------------------------------------------------------------------
| evaluation SEMI {
	printf("evaluation SEMI -> ligne\n");
}
;

//__________________________________________________________________________________

return :
// ------------------------------------------------------------------
RETURN evaluation {
	printf("RETURN evaluation -> return\n");
}
;

//=================================================================================================
//				Les variables
//=================================================================================================

stencil :
// ------------------------------------------------------------------
ID LEMB CHIFFRE COMMA CHIFFRE REMB {
	printf("ID LEMB CHIFFRE COMA CHIFFRE REMB -> stencil\n");
}

//__________________________________________________________________________________

variable :
// ------------------------------------------------------------------
ID hooks {
	printf("ID hooks -> variable\n");
}
;

//__________________________________________________________________________________

hooks :
// ------------------------------------------------------------------
LHOO evaluation RHOO hooks {
	printf("LHOO evaluation RHOO -> hooks\n");
}
// ------------------------------------------------------------------
| {
}
;

//__________________________________________________________________________________

initialisation :
// ------------------------------------------------------------------
TYPE variables_init_serie {
	printf("TYPE variables_init_serie -> initialisation\n");
}
// ------------------------------------------------------------------
| STENCIL suite_stencil_init {
	printf("STENCIL suite_stencil_init -> initialisation\n");
}
;

//__________________________________________________________________________________

variables_init_serie :
// ------------------------------------------------------------------
variable_init COMMA variables_init_serie {printf("variable_init COMA variables_init_serie -> variables_init_serie\n");
}
// ------------------------------------------------------------------
| variable_init {
	printf("variable_init -> variables_init_serie\n");
}
;

//__________________________________________________________________________________

suite_stencil_init :
// ------------------------------------------------------------------
stencil_init COMMA suite_stencil_init {printf("stencil_init COMA suite_stencil_init -> suite_stencil_init\n");
}
// ------------------------------------------------------------------
| stencil_init {
	printf("stencil_init -> suite_stencil_init\n");
}
;

//__________________________________________________________________________________

variable_init :
// ------------------------------------------------------------------
variable EQUALS evaluation {
	printf("variable EQUALS evaluation -> variable_init\n");
}
// ------------------------------------------------------------------
| variable EQUALS LEMB suite_chiffre REMB {
	printf("variable EQUALS LEMB suite_int REMB -> variable_init\n");
}
// ------------------------------------------------------------------
| variable {
	printf("variable -> variable_init\n");
}
;

//__________________________________________________________________________________

stencil_init :
// ------------------------------------------------------------------
stencil EQUALS LEMB suite_suite_chiffre REMB {
	printf("stencil EQUALS LEMB suite_suite_chiffre REMB -> stencil_init\n");
}
// ------------------------------------------------------------------
| stencil EQUALS LEMB suite_chiffre REMB {
	printf("stencil EQUALS LEMB suite_chiffre REMB -> stencil_init\n");
}
// ------------------------------------------------------------------
| stencil {
	printf("stencil -> stencil_init\n");
}
;

//__________________________________________________________________________________

suite_suite_chiffre :
// ------------------------------------------------------------------
LEMB suite_chiffre REMB COMMA suite_suite_chiffre {
	printf("LEMB suite_chiffre REMB COMMA suite_suite_chiffre -> suite_suite_chiffre\n");
}
// ------------------------------------------------------------------
| LEMB suite_chiffre REMB {
	printf("LEMB suite_chiffre REMB -> suite_suite_chiffre\n");
}
;

//__________________________________________________________________________________

suite_chiffre :
// ------------------------------------------------------------------
chiffre COMMA suite_chiffre {
	printf("chiffre COMMA suite_chiffre -> suite_chiffre\n");
}
// ------------------------------------------------------------------
| chiffre {
	printf("chiffre -> suite_chiffre\n");
}
;

//__________________________________________________________________________________

affectation :
// ------------------------------------------------------------------
variable EQUALS evaluation {
	printf("variable EQUALS evaluation -> affectation\n");
}
// ------------------------------------------------------------------
| variable AFFECT evaluation {
	printf("variable AFFECT evaluation -> affectation\n");
}
;

//=================================================================================================
//				Les instructions conditionnelles
//=================================================================================================

for :
// ------------------------------------------------------------------
FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne {
	printf("FOR LBRA affectation SEMI evaluation SEMI evaluation RBRA ligne -> for\n");
}
;

//__________________________________________________________________________________

while :
// ------------------------------------------------------------------
WHILE LBRA evaluation RBRA ligne {
	printf("WHILE LBRA evaluation RBA ligne -> while\n");
}
;

//__________________________________________________________________________________

if :
// ------------------------------------------------------------------
IF LBRA evaluation RBRA ligne else {
	printf("IF LBRA evaluation RBRA ligne else -> if\n");
}
;

//__________________________________________________________________________________

else :
// ------------------------------------------------------------------
ELSE ligne {
	printf("ELSE ligne -> else\n");
}
// ------------------------------------------------------------------
| {
}
;

//=================================================================================================
//				Le retour des valeurs
//=================================================================================================

evaluation :
// ------------------------------------------------------------------ DONE
evaluation COMPARATOR_OR {
	fprintf(outputFile,"move $t9 $t0\n");
} evaluation {
	printf("evaluation COMPARATOR_OR evaluation -> evaluation\n");

	fprintf(outputFile,"beq $0 $t9 OPPE_BOOL_%llu\n",labelCounter);
	fprintf(outputFile,"li $t9 1\nj OPPE_BOOL_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"OPPE_BOOL_%llu :\nli $t9 0\nOPPE_BOOL_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;

	fprintf(outputFile,"beq $0 $t0 OPPE_BOOL_%llu\n",labelCounter);
	fprintf(outputFile,"li $t0 1\nj OPPE_BOOL_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"OPPE_BOOL_%llu :\nli $t0 0\nOPPE_BOOL_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;

	fprintf(outputFile,"add $t0 $t9 $t0\n");

	fprintf(outputFile,"beq $0 $t0 COMP_OR_%llu\n",labelCounter);
	fprintf(outputFile,"li $t0 1\nj COMP_OR_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"COMP_OR_%llu :\nli $t0 0\nCOMP_OR_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;
}
// ------------------------------------------------------------------ DONE
| evaluation COMPARATOR_AND {
	fprintf(outputFile,"move $t8 $t0\n");
} evaluation {
	printf("evaluation COMPARATOR_AND evaluation -> evaluation\n");

	fprintf(outputFile,"beq $0 $t8 OPPE_BOOL_%llu\n",labelCounter);
	fprintf(outputFile,"li $t8 1\nj OPPE_BOOL_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"OPPE_BOOL_%llu :\nli $t8 0\nOPPE_BOOL_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;

	fprintf(outputFile,"beq $0 $t0 OPPE_BOOL_%llu\n",labelCounter);
	fprintf(outputFile,"li $t0 1\nj OPPE_BOOL_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"OPPE_BOOL_%llu :\nli $t0 0\nOPPE_BOOL_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;

	fprintf(outputFile,"sub $t0 $t8 $t0\n");

	fprintf(outputFile,"beq $0 $t0 COMP_AND_%llu\n",labelCounter);
	fprintf(outputFile,"li $t0 0\nj COMP_AND_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"COMP_AND_%llu :\nli $t0 1\nCOMP_AND_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;
}
// ------------------------------------------------------------------ DONE
| evaluation COMPARATOR_EQUALITY {
	fprintf(outputFile,"move $t7 $t0\n");
} evaluation {
	char inst[4];
	printf("evaluation COMPARATOR_EQUALITY evaluation -> evaluation\n");
	if(!strcmp($2,"==")){
		strcpy(inst,"beq");
	}else if(!strcmp($2,"!=")){
		strcpy(inst,"bne");
	}
	fprintf(outputFile,"%s $t7 $t0 COMP_EQUALITY_%llu\n",inst,labelCounter);
	fprintf(outputFile,"li $t0 0\nj COMP_EQUALITY_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"COMP_EQUALITY_%llu :\nli $t0 1\nCOMP_EQUALITY_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;
}
// ------------------------------------------------------------------ DONE
| evaluation COMPARATOR_SUPREMACY {
	fprintf(outputFile,"move $t6 $t0\n");
} evaluation {
	char inst[4];
	printf("evaluation COMPARATOR_SUPREMACY evaluation -> evaluation\n");
	if(!strcmp($2,"<")){
		strcpy(inst,"blt");
	}else if(!strcmp($2,"<=")){
		strcpy(inst,"ble");
	}else if(!strcmp($2,">")){
		strcpy(inst,"bgt");
	}else if(!strcmp($2,">=")){
		strcpy(inst,"bge");
	}
	fprintf(outputFile,"%s $t6 $t0 COMP_SUPREMACY_%llu\n",inst,labelCounter);
	fprintf(outputFile,"li $t0 0\nj COMP_SUPREMACY_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"COMP_SUPREMACY_%llu :\nli $t0 1\nCOMP_SUPREMACY_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;
}
// ------------------------------------------------------------------ DONE
| evaluation OPERATOR_ADDITION {
	fprintf(outputFile,"move $t5 $t0\n");
} evaluation {
	printf("evaluation OPERATOR_ADDITION evaluation -> evaluation\n");
	if($2[0] == '+'){
		fprintf(outputFile,"add $t0 $t5 $t0\n");
	}else{
		fprintf(outputFile,"sub $t0 $t5 $t0\n");
	}
}
// ------------------------------------------------------------------ DONE
| evaluation OPERATOR_MULTI {
	fprintf(outputFile,"move $t4 $t0\n");
} evaluation {
	printf("evaluation OPERATOR_MULTI evaluation -> evaluation\n");
	if($2[0] == '*'){
		fprintf(outputFile,"mul $t0 $t4 $t0\n");
	}else{
		fprintf(outputFile,"div $t0 $t4 $t0\n");
	}
}
// ------------------------------------------------------------------ DONE
| LBRA {
	int i;
	fprintf(outputFile,"subi $sp $sp %d\n",4*9);
	for(i=1 ; i<=9 ; ++i)
	{
		fprintf(outputFile,"sw $t%d %d($sp)\n",i,i*4);
	}
} evaluation RBRA{
	int i;
	printf("LBRA evaluation RBRA -> evaluation\n");
	for(i=1 ; i<=9 ; ++i)
	{
		fprintf(outputFile,"lw $t%d %d($sp)\n",i,i*4);
	}
	fprintf(outputFile,"addi $sp $sp %d\n",4*9);
}
// ------------------------------------------------------------------ DONE
| PRINTI LBRA evaluation RBRA {
	printf("PRINTI LBRA evaluation RBRA -> evaluation\n");
	fprintf(outputFile,"move $a0 $t0\nli $v0 1\nsyscall\n");
}
// ------------------------------------------------------------------
| PRINTF LBRA STRING RBRA {
	printf("PRINTF LBRA STRING RBRA -> evaluation\n");
}
// ------------------------------------------------------------------ DONE
| OPERATOR_NEGATION evaluation {
	printf("OPERATOR_NEGATION evaluation -> evaluation\n");
	fprintf(outputFile,"beq $0 $t0 OPPE_NEG_%llu\n",labelCounter);
	fprintf(outputFile,"li $t0 0\nj OPPE_NEG_%llu_FIN\n",labelCounter);
	fprintf(outputFile,"OPPE_NEG_%llu :\nli $t0 1\nOPPE_NEG_%llu_FIN :\n",labelCounter,labelCounter);
	++labelCounter;
}
// ------------------------------------------------------------------ DONE
| chiffre {
	printf("chiffre -> evaluation\n");
	fprintf(outputFile,"li $t0 %s\n",$1);
}
// ------------------------------------------------------------------
| variable_incr	{
	printf("variable_incr -> evaluation\n");
}
;

//__________________________________________________________________________________

variable_incr :
// ------------------------------------------------------------------ 
OPERATOR_INCREMENT variable	{
	printf("OPERATOR_INCREMENT variable -> variable_incr\n");
// pour ++
// addi $variable 1
// move $t0 $variable
}
// ------------------------------------------------------------------
| variable OPERATOR_INCREMENT {
	printf("variable OPERATOR_INCREMENT -> variable_incr\n");
// pour ++
// move $t0 $variable
// addi $varibale 1
}
// ------------------------------------------------------------------
| variable {
	printf("variable -> variable_incr\n");
// move $t0 $variable
}
;

//__________________________________________________________________________________

chiffre :
// ------------------------------------------------------------------ DONE
CHIFFRE {
	printf("CHIFFRE -> chiffre\n");
	sprintf($$,"%s",$1);
}
// ------------------------------------------------------------------ DONE
| OPERATOR_ADDITION CHIFFRE {
	printf("OPERATOR_ADDITION CHIFFRE -> chiffre\n");
	sprintf($$,"%s%s",$1,$2);
}
;

%%//==============================================================================================

int main(void)
{
	symboleTable = mallocList();
	*rootTree = instructionMalloc(".data",0);
	
	outputFile = fopen("output.mips","w");

	fprintf(outputFile,".data\n.text\n.globl main\n\nmain :\n");

	yyparse();

	fprintf(outputFile,"\nExit :\nla $v0 10\nsyscall\n");

	fclose(outputFile);
	freeList(symboleTable);
	instrucitonFree(rootTree);

	return EXIT_SUCCESS;
}

void yyerror (char const *s)
{
	printf("error : %s %d\n",s, yychar);

	// fclose(outputFile);
	// freeList(symboleTable);
}