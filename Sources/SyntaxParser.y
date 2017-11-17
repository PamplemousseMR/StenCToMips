%code requires {
    #include "InstructionsList.h"
    #include "SymbolsTable.h"
}

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#include "InstructionsList.h"
	#include "SymbolsTable.h"

	#ifdef DEBUG
	#define printf(args...) printf(args);
	#else
	#define printf(...)
	#endif

	#define PUSH_BACK(dest, indent, code...) 	snprintf(instructionTempo,BUFFER_SIZE,code);\
												instructionPushBack(dest,instructionTempo,indent)

	#define PUSH_FORWARD(dest, indent, code...) snprintf(instructionTempo,BUFFER_SIZE,code);\
												instructionPushForward(dest,instructionTempo,indent)
														
	unsigned long long labelCounter = 0;
	unsigned long long variableCounter = 0;

	int yylex();
	void yyerror (char const *s);

	FILE* outputFile;
	SymbolsTable symbolsTable;
	InstructionsList rootTree;
	char instructionTempo[BUFFER_SIZE];
	
%}

%union {

	char* String;
	InstructionsList Instruction;
	Symbol Sym;
	
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

%type<Instruction> programme
//%type<Instruction> preprocessor_instructions_serie		ne renvoie rien car ecriture dans rootTree 
//%type<Instruction> preprocessor_instruction				via créetion de variable constante dans la table symbole
%type<Instruction> functions_serie
%type<Instruction> main
%type<Instruction> instructions_serie
%type<Instruction> ligne
%type<Instruction> return
%type<Sym> variable			
%type<Instruction> hooks
%type<Instruction> initialisation
%type<Instruction> variables_init_serie
%type<Instruction> variable_init
%type<Instruction> hooks_init			
%type<Instruction> affectation
%type<Instruction> for
%type<Instruction> while
%type<Instruction> if
%type<Instruction> else
%type<Instruction> evaluation
%type<Instruction> variable_incr
%type<String> chiffre 			//cas particulier renvoie un String contenant "i"|"+i"|"-i" 

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
// ------------------------------------------------------------------ DONE
	preprocessor_instructions_serie functions_serie {
		printf("preprocessor_instructions_serie functions_serie -> programme\n");
		
		PUSH_FORWARD(rootTree,0,".data");
		PUSH_BACK(rootTree,0,".text");
		PUSH_BACK(rootTree,0,".golbl __main\n\n#####\n");
		
		instructionConcat(rootTree,$2);
		
		PUSH_BACK(rootTree,0,"\n#####\n\nExit :");
		PUSH_BACK(rootTree,1,"li $v0 10");
		PUSH_BACK(rootTree,1,"syscall");
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
// ------------------------------------------------------------------ DONE
	DEFINE ID chiffre ENDLINE {
		printf("DEFINE ID chiffre ENDLINE -> preprocessor_instruction\n");
		
		if(symbolsTableGetSymbolById(symbolsTable,$2) != NULL){
			yyerror("La variable existe deja !"); 	
		}
		symbolsTableAddSymbolConst(symbolsTable,$2,atoi($3));
	}
	;

//__________________________________________________________________________________

functions_serie :
// ------------------------------------------------------------------ DONE
	main {
		printf("main -> functions_serie\n");
		
		$$ = $1;
	}
	;

//__________________________________________________________________________________

main :
// ------------------------------------------------------------------ DONE
	TYPE MAIN LBRA RBRA LEMB instructions_serie REMB {
		printf("TYPE MAIN LBRA RBRA LEMB instructions_serie REMB -> main\n");
		
		$$ = $6;
		PUSH_FORWARD($$,0,"__main :");
		PUSH_BACK($$,1,"j Exit");
	}
	;

//__________________________________________________________________________________

instructions_serie :
// ------------------------------------------------------------------ DONE
	ligne instructions_serie {
		printf("ligne instructions_serie -> instructions_serie\n");
		
		$$ = $1;
		instructionConcat($$,$2);
	}
// ------------------------------------------------------------------ DONE
	| {
		instructionListMalloc(&$$);
	}
	;

//__________________________________________________________________________________

ligne :
// ------------------------------------------------------------------
	for {
		printf("for -> ligne\n");
		
		instructionListMalloc(&$$); // pour evité les core dumped
	}
// ------------------------------------------------------------------
	| while {
		printf("while -> ligne\n");
		
		instructionListMalloc(&$$); // pour evité les core dumped
	}
// ------------------------------------------------------------------
	| if {
		printf("if -> ligne\n");
		
		instructionListMalloc(&$$); // pour evité les core dumped
	}
// ------------------------------------------------------------------ DONE
	| LEMB instructions_serie REMB {
		printf("LEMB instructions_serie REMB -> ligne\n");
		
		$$ = $2;
		instructionIncr($$,1);
	}
// ------------------------------------------------------------------ DONE
	| initialisation SEMI {
		printf("initialisation SEMI -> ligne\n");
		
		$$ = $1;
	}
// ------------------------------------------------------------------
	| affectation SEMI {
		printf("affectation SEMI -> ligne\n");
		
		instructionListMalloc(&$$); // pour evité les core dumped
	}
// ------------------------------------------------------------------
	| return SEMI {
		printf("return SEMI -> ligne\n");
		
		instructionListMalloc(&$$); // pour evité les core dumped
	}
// ------------------------------------------------------------------ DONE
	| evaluation SEMI {
		printf("evaluation SEMI -> ligne\n");
		
		$$ = $1;
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

		Symbol s;
		if( (s=symbolsTableGetSymbolById(symbolsTable,$1)) == NULL){
			yyerror("La variable n'existe pas !"); 
		}

		$$ = s;
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
// ------------------------------------------------------------------ DONE
	TYPE variables_init_serie {
		printf("TYPE variables_init_serie -> initialisation\n");
		
		$$ = $2;
	}
// ------------------------------------------------------------------
	| STENCIL suite_stencil_init {
		printf("STENCIL suite_stencil_init -> initialisation\n");
		
		instructionListMalloc(&$$);
	}
	;

//__________________________________________________________________________________

variables_init_serie :
// ------------------------------------------------------------------ DONE
	variable_init COMMA variables_init_serie {
		printf("variable_init COMA variables_init_serie -> variables_init_serie\n");
		
		$$ = $1;
		instructionConcat($$,$3);
	}
// ------------------------------------------------------------------ DONE
	| variable_init {
		printf("variable_init -> variables_init_serie\n");
		
		$$ = $1;
	}
	;

//__________________________________________________________________________________

suite_stencil_init :
// ------------------------------------------------------------------
	stencil_init COMMA suite_stencil_init {
		printf("stencil_init COMA suite_stencil_init -> suite_stencil_init\n");
	}
// ------------------------------------------------------------------
	| stencil_init {
		printf("stencil_init -> suite_stencil_init\n");
	}
	;

//__________________________________________________________________________________ TODO hook en mips ?? (changer les false en true)

variable_init :
// ------------------------------------------------------------------ DONE
	ID hooks_init EQUALS evaluation {
		printf("ID hooks_init EQUALS evaluation -> variable_init\n");
		
		if(symbolsTableGetSymbolById(symbolsTable,$1) != NULL){
			yyerror("La variable existe deja !"); 
		}
		Symbol result = symbolsTableAddSymbol(symbolsTable,$1,true,false);
		$$ = $4;
		PUSH_BACK($$,1,"sw $t0 %s",result->mipsId);
		
	}
// ------------------------------------------------------------------
	| ID hooks_init {
		printf("ID hooks_init -> variable_init\n");
		
		if(symbolsTableGetSymbolById(symbolsTable,$1) != NULL){
			yyerror("La variable existe deja !"); 				
		}
		symbolsTableAddSymbol(symbolsTable,$1,false,false);
		instructionListMalloc(&$$);
	}
	;
	
//__________________________________________________________________________________	TODO hook en mips ??

hooks_init :
// ------------------------------------------------------------------ 
	LHOO ID RHOO hooks_init {
		printf("LHOO ID RHOO -> hooks_init\n");
		
		Symbol node1;
		if((node1 = symbolsTableGetSymbolById(symbolsTable,$1)) == NULL || !node1->constante){
			yyerror("définition de tableau non constant !");
		}
		//que renvoyer ?   une structure ? (avec nb dimention nb ligne nb colonne ...) surement une liste(encore ??) vu que ça s'enchaine !
	}
// ------------------------------------------------------------------
	| LHOO CHIFFRE RHOO hooks_init {
		printf("LHOO CHIFFRE RHOO -> hooks_init\n");
		
		// que renvoyer . cf 6ligne plus haut 
	}
// ------------------------------------------------------------------
	| {
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
	evaluation COMPARATOR_OR evaluation {
		printf("evaluation COMPARATOR_OR evaluation -> evaluation\n");

		$$ = $1;
		PUSH_BACK($$,1,"bne $0 $t0 COMP_OR_%llu_RETURN_TRUE",labelCounter); //si $t0 != 0 => TRUE
		instructionConcat($$,$3);
		PUSH_BACK($$,1,"bne $0 $t0 COMP_OR_%llu_RETURN_TRUE",labelCounter); //si $t0 != 0 => TRUE
		PUSH_BACK($$,1,"li $t0 0");	
		PUSH_BACK($$,1,"j COMP_OR_%llu_FIN",labelCounter);
		PUSH_BACK($$,1,"COMP_OR_%llu_RETURN_TRUE :",labelCounter);
		PUSH_BACK($$,1,"li $t0 1");	
		PUSH_BACK($$,1,"COMP_OR_%llu_FIN :",labelCounter);	
		++labelCounter;
	}
// ------------------------------------------------------------------ DONE
	| evaluation COMPARATOR_AND evaluation {
		printf("evaluation COMPARATOR_AND evaluation -> evaluation\n");
		
		$$ = $1;
		PUSH_BACK($$,1,"beq $0 $t0 COMP_AND_%llu_RETURN_FALSE",labelCounter); //si $t0 == 0 => FALSE
		instructionConcat($$,$3);
		PUSH_BACK($$,1,"beq $0 $t0 COMP_AND_%llu_RETURN_FALSE",labelCounter); //si $t0 == 0 => FALSE
		PUSH_BACK($$,1,"li $t0 1");	
		PUSH_BACK($$,1,"j COMP_AND_%llu_FIN",labelCounter);
		PUSH_BACK($$,1,"COMP_AND_%llu_RETURN_FALSE :",labelCounter);
		PUSH_BACK($$,1,"li $t0 0");	
		PUSH_BACK($$,1,"COMP_AND_%llu_FIN :",labelCounter);
		++labelCounter;	
	}
// ------------------------------------------------------------------ DONE 
	| evaluation COMPARATOR_EQUALITY evaluation {
		printf("evaluation COMPARATOR_EQUALITY evaluation -> evaluation\n");

		$$ = $1;
		PUSH_BACK($$,1,"move $t7 $t0");
		instructionConcat($$,$3);
		char inst[4];
		if(!strcmp($2,"==")){
			strcpy(inst,"beq");
		}else if(!strcmp($2,"!=")){
			strcpy(inst,"bne");
		}
		PUSH_BACK($$,1,"%s $t7 $t0 COMP_EQUALITY_%llu_RETURN_TRUE",inst,labelCounter);
		PUSH_BACK($$,1,"li $t0 0");
		PUSH_BACK($$,1,"j COMP_EQUALITY_%llu_FIN",labelCounter);
		PUSH_BACK($$,1,"COMP_EQUALITY_%llu_RETURN_TRUE :",labelCounter);
		PUSH_BACK($$,1,"li $t0 1");	
		PUSH_BACK($$,1,"COMP_EQUALITY_%llu_FIN :",labelCounter);
		++labelCounter;	
	}
// ------------------------------------------------------------------ DONE 
	| evaluation COMPARATOR_SUPREMACY evaluation {
		printf("evaluation COMPARATOR_SUPREMACY evaluation -> evaluation\n");
		char inst[4];

		$$ = $1;
		PUSH_BACK($$,1,"move $t6 $t0");
		instructionConcat($$,$3);
		if(!strcmp($2,"<")){
			strcpy(inst,"blt");
		}else if(!strcmp($2,"<=")){
			strcpy(inst,"ble");
		}else if(!strcmp($2,">")){
			strcpy(inst,"bgt");
		}else if(!strcmp($2,">=")){
			strcpy(inst,"bge");
		}
		PUSH_BACK($$,1,"%s $t6 $t0 COMP_SUPREMACY_%llu_RETURN_TRUE",inst,labelCounter);
		PUSH_BACK($$,1,"li $t0 0");
		PUSH_BACK($$,1,"j COMP_SUPREMACY_%llu_FIN",labelCounter);
		PUSH_BACK($$,1,"COMP_SUPREMACY_%llu_RETURN_TRUE :",labelCounter);
		PUSH_BACK($$,1,"li $t0 1");	
		PUSH_BACK($$,1,"COMP_SUPREMACY_%llu_FIN :",labelCounter);
		++labelCounter;	
	}
// ------------------------------------------------------------------ DONE
	| evaluation OPERATOR_ADDITION evaluation {
		printf("evaluation OPERATOR_ADDITION evaluation -> evaluation\n");

		$$ = $1;
		PUSH_FORWARD($3,1,"move $t5 $t0");
		instructionConcat($$,$3);
		if($2[0] == '+'){
			PUSH_BACK($$,1,"add $t0 $t5 $t0");
		}else{
			PUSH_BACK($$,1,"sub $t0 $t5 $t0");
		}
	}
// ------------------------------------------------------------------ DONE
	| evaluation OPERATOR_MULTI evaluation {
		printf("evaluation OPERATOR_MULTI evaluation -> evaluation\n");
		
		$$ = $1;
		PUSH_FORWARD($3,1,"move $t4 $t0");
		instructionConcat($$,$3);
		if($2[0] == '*'){
			PUSH_BACK($$,1,"mul $t0 $t4 $t0");
		}else{
			PUSH_BACK($$,1,"div $t0 $t4 $t0");
		}
	}
// ------------------------------------------------------------------ DONE
	| LBRA evaluation RBRA {
		printf("LBRA evaluation RBRA -> evaluation\n");
		int i;

		instructionListMalloc(&$$);
		PUSH_BACK($$,1,"subi $sp $sp %d",4*9);
		for(i=1 ; i<=9 ; ++i)
		{
			PUSH_BACK($$,1,"sw $t%d %d($sp)",i,i*4);
		}
		instructionIncr($2,1);
		instructionConcat($$,$2);
		for(i=1 ; i<=9 ; ++i)
		{
			PUSH_BACK($$,1,"lw $t%d %d($sp)",i,i*4);
		}
		PUSH_BACK($$,1,"addi $sp $sp %d",4*9);
	}
// ------------------------------------------------------------------ DONE
	| PRINTI LBRA evaluation RBRA {
		printf("PRINTI LBRA evaluation RBRA -> evaluation\n");
		
		$$ = $3;
		PUSH_BACK($$,1,"move $a0 $t0");
		PUSH_BACK($$,1,"li $v0 1");
		PUSH_BACK($$,1,"syscall");
	}
// ------------------------------------------------------------------ DONE
	| PRINTF LBRA STRING RBRA {
		printf("PRINTF LBRA STRING RBRA -> evaluation\n");

		instructionListMalloc(&$$);

		PUSH_BACK(rootTree,1,"string_%llu : .asciiz %s",variableCounter,$3);
		PUSH_BACK($$,1,"la $a0 string_%llu",variableCounter++);
		PUSH_BACK($$,1,"li $v0 4");
		PUSH_BACK($$,1,"syscall");
	}
// ------------------------------------------------------------------ DONE
	| OPERATOR_NEGATION evaluation {
		printf("OPERATOR_NEGATION evaluation -> evaluation\n");
		
		$$ = $2;
		PUSH_BACK($$,1,"beq $0 $t0 OPPE_NEG_%llu",labelCounter);
		PUSH_BACK($$,1,"li $t0 0");
		PUSH_BACK($$,1,"j OPPE_NEG_%llu_FIN",labelCounter);
		PUSH_BACK($$,1,"OPPE_NEG_%llu :",labelCounter);
		PUSH_BACK($$,1,"li $t0 1");
		PUSH_BACK($$,1,"OPPE_NEG_%llu_FIN :",labelCounter);
		++labelCounter;
	}
// ------------------------------------------------------------------ DONE
	| chiffre {
		printf("chiffre -> evaluation\n");
		
		instructionListMalloc(&$$);
		PUSH_BACK($$,1,"li $t0 %s",$1);
	}
// ------------------------------------------------------------------ DONE
	| variable_incr	{
		printf("variable_incr -> evaluation\n");
		
		$$ = $1;
	}
	;

//__________________________________________________________________________________

variable_incr :
// ------------------------------------------------------------------ DONE
	OPERATOR_INCREMENT variable	{
		printf("OPERATOR_INCREMENT variable -> variable_incr\n");

		if( $2->init == false ){
				yyerror("La variable est utilise mais pas initialise !"); 				
		}

		instructionListMalloc(&$$);
		PUSH_BACK($$,1,"lw $t0 %s",$2->mipsId);
		PUSH_BACK($$,1,"addi $t0 $t0 1");
		PUSH_BACK($$,1,"sw $t0 %s",$2->mipsId);
	}
// ------------------------------------------------------------------ DONE
	| variable OPERATOR_INCREMENT {
		printf("variable OPERATOR_INCREMENT -> variable_incr\n");

		if( $1->init == false ){
				yyerror("La variable est utilise mais pas initialise !"); 				
		}

		instructionListMalloc(&$$);
		PUSH_BACK($$,1,"lw $t0 %s",$1->mipsId);
		PUSH_BACK($$,1,"addi $t0 $t0 1");
		PUSH_BACK($$,1,"sw $t0 %s",$1->mipsId);
		PUSH_BACK($$,1,"subi $t0 $t0 1");

	// pour ++
	// move $t0 $variable
	// addi $varibale 1
	}
// ------------------------------------------------------------------ DONE
	| variable {
		printf("variable -> variable_incr\n");

		if( $1->init == false ){
			yyerror("La variable est utilise mais pas initialise !"); 				
		}

		instructionListMalloc(&$$);
		PUSH_BACK($$,1,"lw $t0 %s",$1->mipsId);
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

void clearProg()
{
	if(outputFile!=NULL)fclose(outputFile);
	if(symbolsTable!=NULL)symbolsTableFree(symbolsTable);
	if(rootTree!=NULL)instructionListFree(rootTree);
}

int main(void)
{
	if(atexit(clearProg) != 0)
    {
        perror("[main] Probleme lors de l'enregistrement ");
        exit(EXIT_FAILURE);
    }

	symbolsTableMalloc(&symbolsTable);
	instructionListMalloc(&rootTree);
	
	yyparse();
	
	outputFile = fopen("output.mips","w");
	instructionListPrintFILE(rootTree,outputFile);	

	return EXIT_SUCCESS;
}

void yyerror (char const *s)
{
	printf("error : %s %d\n",s, yychar);
	exit(EXIT_FAILURE);
}