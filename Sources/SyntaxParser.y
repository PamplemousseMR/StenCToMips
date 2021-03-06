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

	#define PUSH_BACK(dest, indent, code...) 	snprintf(instructionTempo,INSTRUCTION_SIZE,code);\
												instructionPushBack(dest,instructionTempo,indent)

	#define PUSH_FORWARD(dest, indent, code...) snprintf(instructionTempo,INSTRUCTION_SIZE,code);\
												instructionPushForward(dest,instructionTempo,indent)

	#define ERROR(msg...) 	snprintf(instructionTempo,INSTRUCTION_SIZE,msg);\
							yyerror(instructionTempo)

	extern int yylineno;

	unsigned long long labelCounter = 0;
	unsigned long long variableCounter = 0;
	bool constanteZone = false;
	int maxStencilVar = 0;

	int yylex();
	void yyerror(char const*);
	void yylex_destroy();

	FILE* outputFile;
	SymbolsTable symbolsTable;
	SymbolsTable functionsTable;
	InstructionsList rootTree;
	char instructionTempo[INSTRUCTION_SIZE];
	Array* actualArrayInit;
	Function* actualFunction;
	bool mainFound = false;
	
	void ** funCallStack;
	int funCallLength = 0;
	
	void checkNULLSymbol(Symbol);

	int powYacc(int a, int b)
	{
	  if(b<0)      
        return 1 / powYacc (a,-b);
      else if(b==0)
        return 1;
      else if(b==1)
        return a;
      else
        return a*powYacc(a,b-1);
	}
%}

%union {

	char* String;
	int Integer;
	bool Boolean;
	InstructionsList Instruction;
	Symbol Sym;

	struct s_eval{
		InstructionsList instructionEval;
		Symbol symbolEval;
		bool constEval;
		int constInt;
	} Eval;

	struct s_arrayAffect{
		InstructionsList instructionArray;
		bool empty;
		int nbValue;
	} ArrayAffect;

	struct s_hooksInit{
		InstructionsList instructionHooksInit;
		bool constHooksInit;
		int nbValue;
	} HooksInit;

	struct s_number{
		InstructionsList instructionNumber;
		int nbValue;
	} Number;

	struct s_line {
		InstructionsList instructionLine;
		bool willReturn;
	} Line;
	
	struct s_Args{
		InstructionsList instructionArgs;
		int nbArgs;
	}Args;
	
}

%start programme

%token<String>		DEFINE
%token<String>		ENDLINE
%token<String>		FOR
%token<String>		WHILE
%token<String>		IF
%token<String>		ELSE
%token<String>		RETURN		
%token<String>		PRINTF
%token<String>		PRINTI
%token<String>		SCANI
%token<String>		STENCIL
%token<String>		TYPE
%token<String>		ID
%token<String>		CONST
%token<String>		NUMBER
%token<String>		OPERATOR_NEGATION
%token<String>		OPERATOR_INCREMENT
%token<String>		OPERATOR_MULTI
%token<String>		OPERATOR_ADDITION
%token<String>		COMPARATOR_SUPREMACY
%token<String>		COMPARATOR_EQUALITY
%token<String>		COMPARATOR_AND
%token<String>		COMPARATOR_OR
%token<String>		EQUALS
%token<String>		AFFECT
%token<String>		OPERATOR_STENCIL
%token<String>		LBRA
%token<String>		RBRA
%token<String>		LHOO
%token<String>		RHOO
%token<String>		LEMB
%token<String>		REMB
%token<String>		COMMA
%token<String>		SEMI
%token<String>		STRING

%type<Instruction>	functions_serie
%type<Instruction>	function
%type<Integer>		argument_init_hooks
%type<Line>			instructions_serie
%type<Line>			ligne
%type<Instruction>	write_ligne_number
%type<Instruction>	return
%type<Sym>			variable				//cas particulier renvoie le symbole de la table des symbole
%type<Number>		hooks
%type<Instruction>	initialisation
%type<Instruction>	variables_init_serie
%type<Boolean>		const
%type<Instruction>	variable_init
%type<Number>		number_serie_serie
%type<Number>		number_serie_comma
%type<Number>		number_serie
%type<Instruction>	unit_init
%type<Instruction>	array_init
%type<ArrayAffect>	array_affect	
%type<Instruction>  stencils_init_serie
%type<Instruction>  stencil_init
%type<HooksInit>	hooks_init
%type<Instruction>	affectation
%type<Instruction>	for
%type<Instruction>	for_init_serie
%type<Instruction>	affectations_serie
%type<Instruction>	evaluations_serie
%type<Instruction>	while
%type<Line>			if
%type<Line>			else
%type<Eval>			evaluation				//cas particulier permet de différentier les evaluations constantes ou non
%type<Eval>			variable_incr			// et de simplifier les expressions constantes ex : 3+4 ->7
%type<Integer>	 	number					//cas particulier renvoie un String contenant "i"|"+i"|"-i" 
%type<Args>			arguments
%type<Args>			arguments_serie


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
// -1-------------------------------2-------------------------------- DONE
	preprocessor_instructions_serie functions_serie {
		printf("preprocessor_instructions_serie functions_serie -> programme\n");
		
		if(!mainFound){
			ERROR("référence indéfinie vers « main »");
		}
		PUSH_FORWARD(rootTree,0,".data");
		PUSH_BACK(rootTree,1,"string_outOfBound : .asciiz \"\\nExeption : Array index out of bound !\\n\" ");
		PUSH_BACK(rootTree,1,"division_by_zero : .asciiz \"\\nExeption : Division by zero forbidden !\\n\" ");

		PUSH_BACK(rootTree,0,"\n#####\n\n.globl main");
		PUSH_BACK(rootTree,0,"\n#####\n\n.text");
		PUSH_BACK(rootTree,0,"\n#####\n\nmain :");
		PUSH_BACK(rootTree,1,"jal FUN_MAIN");
		PUSH_BACK(rootTree,1,"move $a0 $t0");
		PUSH_BACK(rootTree,1,"j EXIT");
		
		instructionConcat(rootTree,$2);
		$2 = NULL;
		
		PUSH_BACK(rootTree,0,"\n#####\n\nOUTOFBOUND :");
		PUSH_BACK(rootTree,1,"la $a0 string_outOfBound");
		PUSH_BACK(rootTree,1,"li $v0 4");
		PUSH_BACK(rootTree,1,"syscall");
		PUSH_BACK(rootTree,1,"li $a0 -1"); //exit failure !
		PUSH_BACK(rootTree,1,"j EXIT");

		PUSH_BACK(rootTree,0,"\n#####\n\nDIVIDEBYZERO :");
		PUSH_BACK(rootTree,1,"la $a0 division_by_zero");
		PUSH_BACK(rootTree,1,"li $v0 4");
		PUSH_BACK(rootTree,1,"syscall");
		PUSH_BACK(rootTree,1,"li $a0 -1"); //exit failure !
		PUSH_BACK(rootTree,1,"j EXIT");
		
		PUSH_BACK(rootTree,0,"\n#####\n\nEXIT :");
		PUSH_BACK(rootTree,1,"li $v0 10");
		PUSH_BACK(rootTree,1,"syscall");
	}
	;

//__________________________________________________________________________________

preprocessor_instructions_serie :
// -1------------------------2--------------------------------------- DONE
	preprocessor_instruction preprocessor_instructions_serie {
		printf("preprocessor_instruction preprocessor_instructions_serie -> preprocessor_instructions_serie\n");
	}
// ------------------------------------------------------------------ DONE
	| {
	}
	;

//__________________________________________________________________________________

preprocessor_instruction :
// -1------2--3------4----------------------------------------------- DONE
	DEFINE ID number ENDLINE {
		printf("DEFINE ID number ENDLINE -> preprocessor_instruction\n");
		
		if(symbolsTableGetSymbolById(symbolsTable,$2) != NULL){
			ERROR("La variable '%s' existe deja",$2); 
		}
		symbolsTableAddSymbolDefine(symbolsTable,$2,$3);

		free($1);
		free($2);
		free($4);
	}
	;

//__________________________________________________________________________________

functions_serie :
// -1--------2------------------------------------------------------- DONE
	function functions_serie {
		printf("function functions_serie -> functions_serie\n");
		
		$$ = $1;
		PUSH_BACK($$,0,"\n");
		instructionConcat($$,$2);
		$2 = NULL;
	}
// ------------------------------------------------------------------ DONE
	| function {
		$$ = $1;
	} 
	;

//__________________________________________________________________________________
	
function : 	
// -1--------------2----3----------4-------------5----6----7------------------8--------9 DONE
	function_begin LBRA step_begin argument_list RBRA LEMB instructions_serie step_end REMB {
		printf("TYPE ID LBRA RBRA LEMB instructions_serie REMB -> function\n");
		
		if(!$7.willReturn){
			ERROR("La fonction %s n'a pas de retour",actualFunction->id);
		}
		$$ = $7.instructionLine;
		PUSH_FORWARD($$,1,"sw $ra 0($sp)");
		PUSH_FORWARD($$,1,"sub $sp $sp 4");
		PUSH_FORWARD($$,1,"#---------- save for return ----------");
		PUSH_FORWARD($$,0,"\n%s :",actualFunction->mipsId);

		free($2);
		free($5);
		free($6);
		free($9);
	}
	;

//__________________________________________________________________________________

argument_list : 
// -1---------------------------------------------------------------- DONE
	argument_init_serie {
		//ARGS
	}
// ---1-------------------------------------------------------------- DONE
	| { //NO ARGS
	} 
	;

//__________________________________________________________________________________

argument_init_serie :
// -1-------------2-----3-------------------------------------------- DONE
    argument_init_serie COMMA argument_init {
        printf("argument_init COMMA argument_init_serie -> argument_init_serie\n");
		free($2);
    }
// ---1-------------------------------------------------------------- DONE
    | argument_init {
        printf("argument_init -> argument_init_serie\n");
    }
    ;

//__________________________________________________________________________________

argument_init :
// -1----2--3-------------------------------------------------------- DONE
    TYPE ID argument_init_hooks {
        printf("TYPE ID argument_init_hooks-> argument_init\n");
		
		if(symbolsTableGetSymbolById(symbolsTable,$2) != NULL){
			ERROR("La variable %s existe déja",$2);
		}
		
		Symbol save;
		Array* arr;
		if($3 == 0){ //param unit
			save = symbolsTableAddSymbolUnit(symbolsTable,$2,true);
			
			PUSH_FORWARD(actualFunction->stackInstructions,1,"sw $t1 0($sp)");
			PUSH_FORWARD(actualFunction->stackInstructions,1,"lw $t1 %s",((Unit*)save->data)->mipsId);
			PUSH_FORWARD(actualFunction->stackInstructions,1,"sub $sp $sp 4");
			
			PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 0($sp)");
			PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s",((Unit*)save->data)->mipsId);
			PUSH_BACK(actualFunction->unStackInstructions,1,"add $sp $sp 4");
		}else{ //param array
			save = symbolsTableAddArray(symbolsTable,$2);
			arr = (Array*)save->data;
			arr->nbDimension = $3;
			
			PUSH_BACK(rootTree,1,"%s_verificator : .word 0",arr->mipsId);
			PUSH_BACK(rootTree,1,"%s_multiplicator : .word 0",arr->mipsId);
			PUSH_BACK(rootTree,1,"%s_accesTable : .word 0",arr->mipsId);
			
			//BEGIN STACK
			InstructionsList temp;
			instructionListMalloc(&temp);
			PUSH_BACK(temp,1,"sub $sp $sp %d",3*4);	
			PUSH_BACK(temp,1,"lw $t1 %s_multiplicator",arr->mipsId);
			PUSH_BACK(temp,1,"sw $t1 0($sp)");
			PUSH_BACK(temp,1,"lw $t1 %s_verificator",arr->mipsId);
			PUSH_BACK(temp,1,"sw $t1 4($sp)");
			PUSH_BACK(temp,1,"lw $t1 %s_accesTable",arr->mipsId);
			PUSH_BACK(temp,1,"sw $t1 8($sp)");
			instructionConcat(temp,actualFunction->stackInstructions);
			actualFunction->stackInstructions = NULL;
			actualFunction->stackInstructions = temp;
			//END STACK
			
			//BEGIN UNSTACK
			//POUR INFO on pourrait free ici
			PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 0($sp)");
			PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_multiplicator",arr->mipsId);
			PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 4($sp)");
			PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_verificator",arr->mipsId);
			PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 8($sp)");
			PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_accesTable",arr->mipsId);
			PUSH_BACK(actualFunction->unStackInstructions,1,"add $sp $sp %d",3*4);
			//END UNSTACK
		}
		symbolsTableAddSymboleAlreadyExist(actualFunction->argumentsTable,save);
		actualFunction->nbArgs++;
		
		free($1);
		free($2);
    }
// ---1-------2------------------------------------------------------ DONE
	| STENCIL ID {
		
		if(symbolsTableGetSymbolById(symbolsTable,$2) != NULL){
			ERROR("La variable %s existe déja",$2);	
		}
		
		Symbol save = symbolsTableAddStencil(symbolsTable,$2);
		Stencil* sten = (Stencil*) save->data;
		PUSH_BACK(rootTree,1,"%s_verificator : .word 0",sten->mipsId);
		PUSH_BACK(rootTree,1,"%s_multiplicator : .word 0",sten->mipsId);
		PUSH_BACK(rootTree,1,"%s_accesTable : .word 0",sten->mipsId);
		PUSH_BACK(rootTree,1,"%s_nbDimension : .word 0",sten->mipsId);
		PUSH_BACK(rootTree,1,"%s_nbNeighbourg : .word 0",sten->mipsId);
				
		symbolsTableAddSymboleAlreadyExist(actualFunction->argumentsTable,save);
		actualFunction->nbArgs++;
		
		//BEGIN STACK
		InstructionsList temp;
		instructionListMalloc(&temp);
		PUSH_BACK(temp,1,"sub $sp $sp %d",5*4);	
		PUSH_BACK(temp,1,"lw $t1 %s_nbDimension",sten->mipsId);
		PUSH_BACK(temp,1,"sw $t1 0($sp)");
		PUSH_BACK(temp,1,"lw $t1 %s_nbNeighbourg",sten->mipsId);
		PUSH_BACK(temp,1,"sw $t1 4($sp)");
		PUSH_BACK(temp,1,"lw $t1 %s_multiplicator",sten->mipsId);
		PUSH_BACK(temp,1,"sw $t1 8($sp)");
		PUSH_BACK(temp,1,"lw $t1 %s_verificator",sten->mipsId);
		PUSH_BACK(temp,1,"sw $t1 12($sp)");
		PUSH_BACK(temp,1,"lw $t1 %s_accesTable",sten->mipsId);
		PUSH_BACK(temp,1,"sw $t1 16($sp)");
		instructionConcat(temp,actualFunction->stackInstructions);
		actualFunction->stackInstructions = NULL;
		actualFunction->stackInstructions = temp;
		//END STACK
		
		//BEGIN UNSTACK
		//POUR INFO on pourrait free ici
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 0($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_nbDimension",sten->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 4($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_nbNeighbourg",sten->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 8($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_multiplicator",sten->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 12($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_verificator",sten->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 16($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_accesTable",sten->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"add $sp $sp %d",5*4);
		//END UNSTACK
		
		free($1);
		free($2);
	}
    ;

//__________________________________________________________________________________

argument_init_hooks :
// -1----2----3------------------------------------------------------ DONE
    LHOO RHOO argument_init_hooks {
        printf("LHOO RHOO argument_init_hooks -> argument_init_hooks\n");
		$$ = $3+1;
		
		free($1);
		free($2);
    }
// ---1----2--------------------------------------------------------- DONE
    | {
		$$ = 0;
    }
    ;

//__________________________________________________________________________________

function_begin :
// -1----2----------------------------------------------------------- DONE
	TYPE ID {
		if( symbolsTableGetSymbolById(functionsTable,$2) != NULL){
			ERROR("La fonction '%s' existe déja",$2);
		}
		actualFunction = symbolsTableAddFunction(functionsTable,$2)->data;

		free($1);
		free($2);
	}

//__________________________________________________________________________________

instructions_serie :
// -1-----2---------------------------------------------------------- DONE
	ligne instructions_serie {
		printf("ligne instructions_serie -> instructions_serie\n");
		
		$$ = $1;
		instructionConcat($$.instructionLine,$2.instructionLine);
		$2.instructionLine = NULL;
		$$.willReturn = $1.willReturn || $2.willReturn;
	}
// ------------------------------------------------------------------ DONE
	| ligne {
		$$ = $1;
	}
	;

//__________________________________________________________________________________

ligne :
// -1------------------2--------------------------------------------- DONE
	write_ligne_number for {
		printf("for -> ligne\n");
		
		$$.instructionLine = $1;
		instructionConcat($$.instructionLine,$2);
		$2 = NULL;
		$$.willReturn = false;
	}
// ---1------------------2------------------------------------------- DONE
	| write_ligne_number while {
		printf("while -> ligne\n");
		
		$$.instructionLine = $1;
		instructionConcat($$.instructionLine,$2);
		$2 = NULL;
		$$.willReturn = false;
	}
// ---1------------------2------------------------------------------- DONE
	| write_ligne_number if {
		printf("if -> ligne\n");
		
		$$.instructionLine = $1;
		instructionConcat($$.instructionLine,$2.instructionLine);
		$2.instructionLine = NULL;
		$$.willReturn = $2.willReturn;
	}
// ---1----2----------3------------------4--------5------------------ DONE
	| LEMB step_begin instructions_serie step_end REMB {
		printf("LEMB instructions_serie REMB -> ligne\n");
		
		$$ = $3;
		instructionIncr($$.instructionLine,1);
		PUSH_FORWARD($$.instructionLine,1,"#{");
		PUSH_BACK($$.instructionLine,1,"#}");

		free($1);
		free($5);
	}
// ---1------------------2--------------3---------------------------- DONE
	| write_ligne_number initialisation SEMI {
		printf("initialisation SEMI -> ligne\n");
		
		$$.instructionLine = $1;
		instructionConcat($$.instructionLine,$2);
		$2 = NULL;
		$$.willReturn = false;

		free($3);
	}
// ---1------------------2-----------3------------------------------- DONE
	| write_ligne_number affectation SEMI {
		printf("affectation SEMI -> ligne\n");
		
		$$.instructionLine = $1;
		instructionConcat($$.instructionLine,$2);
		$2 = NULL;
		$$.willReturn = false;

		free($3);
	}
// ---1------------------2------3------------------------------------ DONE
	| write_ligne_number return SEMI {
		printf("return SEMI -> ligne\n");
		
		$$.instructionLine = $1;
		instructionConcat($$.instructionLine,$2);
		$2 = NULL;
		$$.willReturn = true;

		free($3);
	}
// ---1------------------2----------3-------------------------------- DONE
	| write_ligne_number evaluation SEMI {
		printf("evaluation SEMI -> ligne\n");
		
		checkNULLSymbol($2.symbolEval);
		$$.instructionLine = $1;
		instructionConcat($$.instructionLine,$2.instructionEval);
		$2.instructionEval = NULL;
		$$.willReturn = false;

		free($3);
	}
	;

//__________________________________________________________________________________

step_begin : 
// ------------------------------------------------------------------ DONE
	{ 
		symbolsTableAddStep(symbolsTable); 
	}
	;
	
//__________________________________________________________________________________

step_end : 
// ------------------------------------------------------------------ DONE
	{ 
		symbolsTableRemoveUntilStep(symbolsTable); 
	}
	;

//__________________________________________________________________________________

write_ligne_number : 
// ------------------------------------------------------------------ DONE
	{ 
		instructionListMalloc(&$$);
		PUSH_FORWARD($$,1,"#---------- : %d ----------",yylineno);
	}
	;

//__________________________________________________________________________________

return :
// -1------2--------------------------------------------------------- DONE
	RETURN evaluation {
		printf("RETURN evaluation -> return\n");

		checkNULLSymbol($2.symbolEval);
		$$ = $2.instructionEval;
		PUSH_BACK($$,1,"lw $ra 0($sp)");
		PUSH_BACK($$,1,"add $sp $sp 4");
		PUSH_BACK($$,1,"jr $ra");

		free($1);
	}
	;

//=================================================================================================
//				Les variables
//=================================================================================================

variable :
// -1---------------------------------------------------------------- DONE
	ID {
		printf("ID -> variable\n");

		Symbol s;
		if( (s=symbolsTableGetSymbolById(symbolsTable,$1)) == NULL){
			ERROR("La variable '%s' n'existe pas",$1); 
		}
		Array* arr = NULL;
		Stencil* sten = NULL;
		switch(s->type){
			case unit :
			case constUnit :
				break;
			case stencil : 	
				sten = (Stencil*)s->data;
				if(sten->stepsToAcces != NULL){
					instructionListFree(sten->stepsToAcces);
					sten->stepsToAcces = NULL;
				}
				break;		
			case array :
				arr = (Array*)s->data;
				if(arr->stepsToAcces != NULL){
					instructionListFree(arr->stepsToAcces);
					arr->stepsToAcces = NULL;
				}	
				break;
			default :
				ERROR("Symbole inatendu '%s'",$1);
				break;
		}
		$$ = s;

		free($1);
	}
// ---1--2----3------------------------------------------------------ DONE
	| ID LHOO hooks{
		printf("ID LHOO hooks -> variable\n");

		Symbol s;
		if( (s=symbolsTableGetSymbolById(symbolsTable,$1)) == NULL){
			ERROR("La variable '%s' n'existe pas",$1); 
		}
		Array* arr = NULL;
		Stencil* sten = NULL;
		switch(s->type){
			case unit :
			case constUnit : 
				ERROR("La variable '%s' n'est pas un tableau",$1);				
				break;
			case array :
				arr = (Array*)s->data;
				if($3.nbValue > arr->nbDimension){
					ERROR("Trop de dimmension pour le tableau '%s', attendu : %d, actuel : %d",arr->id, arr->nbDimension, $3.nbValue);			
				}else if($3.nbValue < arr->nbDimension){
					ERROR("Pas assez de dimmension pour le tableau '%s', attendu : %d, actuel : %d",arr->id, arr->nbDimension, $3.nbValue);			
				}
			
				instructionListMalloc(&(arr->stepsToAcces));
				
				PUSH_BACK(arr->stepsToAcces,1,"li $s4 0");
				PUSH_BACK(arr->stepsToAcces,1,"lw $s5 %s_multiplicator",arr->mipsId);
				PUSH_BACK(arr->stepsToAcces,1,"lw $s6 %s_verificator",arr->mipsId);
				PUSH_BACK(arr->stepsToAcces,1,"li $s7 %d",arr->nbDimension);
				PUSH_BACK(arr->stepsToAcces,1,"lw $t8 %s_accesTable",arr->mipsId);
				
				instructionConcat(arr->stepsToAcces,$3.instructionNumber);
				$3.instructionNumber = NULL;

				PUSH_BACK(arr->stepsToAcces,1,"sll $s4 $s4 2");
				PUSH_BACK(arr->stepsToAcces,1,"lw $t1 %s",arr->mipsId);
				PUSH_BACK(arr->stepsToAcces,1,"add $s4 $s4 $t1");
				break;
			case stencil :
				sten = (Stencil*)s->data;
				if(sten->constEval && $3.nbValue > sten->nbDimension){
					ERROR("Trop de dimmension pour le stencil '%s', attendu : %d, actuel : %d",sten->id, sten->nbDimension, $3.nbValue);			
				}else if(sten->constEval &&  $3.nbValue < sten->nbDimension){
					ERROR("Pas assez de dimmension pour le stencil '%s', attendu : %d, actuel : %d",sten->id, sten->nbDimension, $3.nbValue);			
				}

				if(sten->stepsToAcces != NULL){
					instructionListFree(sten->stepsToAcces);
					sten->stepsToAcces = NULL;
				}
				instructionListMalloc(&(sten->stepsToAcces));
				
				PUSH_BACK(sten->stepsToAcces,1,"li $s4 0");
				PUSH_BACK(sten->stepsToAcces,1,"lw $s5 %s_multiplicator",sten->mipsId);
				PUSH_BACK(sten->stepsToAcces,1,"lw $s6 %s_verificator",sten->mipsId);
				PUSH_BACK(sten->stepsToAcces,1,"lw $s7 %s_nbDimension",sten->mipsId);
				PUSH_BACK(sten->stepsToAcces,1,"lw $t8 %s_accesTable",sten->mipsId);
				
				instructionConcat(sten->stepsToAcces,$3.instructionNumber);
				$3.instructionNumber = NULL;

				PUSH_BACK(sten->stepsToAcces,1,"sll $s4 $s4 2");
				PUSH_BACK(sten->stepsToAcces,1,"lw $t1 %s",sten->mipsId);
				PUSH_BACK(sten->stepsToAcces,1,"add $s4 $s4 $t1");
				break;
			default :
				ERROR("Symbole inatendu '%s'",$1);
				break;
		}
		$$ = s;

		free($1);
		free($2);
	}
	;

//__________________________________________________________________________________

hooks :
// -1-----2----3----------4------------------------------------------ DONE
	hooks LHOO evaluation RHOO {
		printf("hooks LHOO evaluation RHOO -> hooks\n");
		
		checkNULLSymbol($3.symbolEval);
		$$.nbValue = $1.nbValue + 1;
		$$.instructionNumber = $1.instructionNumber;
		instructionConcat($$.instructionNumber,$3.instructionEval);
		$3.instructionEval = NULL;
		PUSH_BACK($$.instructionNumber,1,"ble $s7 $0 OUTOFBOUND");
		PUSH_BACK($$.instructionNumber,1,"sub $s7 $s7 1");
		PUSH_BACK($$.instructionNumber,1,"lw $t1 0($s6)");
		PUSH_BACK($$.instructionNumber,1,"add $s6 $s6 4");
		PUSH_BACK($$.instructionNumber,1,"blt $t0 $0 OUTOFBOUND");
		PUSH_BACK($$.instructionNumber,1,"bge $t0 $t1 OUTOFBOUND");
		PUSH_BACK($$.instructionNumber,1,"lw $t1 0($s5)");
		PUSH_BACK($$.instructionNumber,1,"add $s5 $s5 4");
		PUSH_BACK($$.instructionNumber,1,"mul $t1 $t1 $t0");
		PUSH_BACK($$.instructionNumber,1,"add $s4 $s4 $t1");	
		PUSH_BACK($$.instructionNumber,1,"sw $t0 0($t8)");
		PUSH_BACK($$.instructionNumber,1,"add $t8 $t8 4");
		
		free($2);
		free($4);
	}
// ---1----------2--------------------------------------------------- DONE
	| evaluation RHOO {
		printf("evaluation RHOO -> hooks\n");
		
		checkNULLSymbol($1.symbolEval);
		$$.nbValue = 1;
		$$.instructionNumber = $1.instructionEval;
		PUSH_BACK($$.instructionNumber,1,"ble $s7 $0 OUTOFBOUND");
		PUSH_BACK($$.instructionNumber,1,"sub $s7 $s7 1");
		PUSH_BACK($$.instructionNumber,1,"lw $t1 0($s6)");
		PUSH_BACK($$.instructionNumber,1,"add $s6 $s6 4");
		PUSH_BACK($$.instructionNumber,1,"blt $t0 $0 OUTOFBOUND");
		PUSH_BACK($$.instructionNumber,1,"bge $t0 $t1 OUTOFBOUND");
		PUSH_BACK($$.instructionNumber,1,"lw $t1 0($s5)");
		PUSH_BACK($$.instructionNumber,1,"add $s5 $s5 4");
		PUSH_BACK($$.instructionNumber,1,"mul $t1 $t1 $t0");
		PUSH_BACK($$.instructionNumber,1,"add $s4 $s4 $t1");	
		PUSH_BACK($$.instructionNumber,1,"sw $t0 0($t8)");
		PUSH_BACK($$.instructionNumber,1,"add $t8 $t8 4");

		free($2);
	}
	;

//=================================================================================================
//				Les initialisations de variables
//=================================================================================================

initialisation :
// -1-----2----3----------------------------------------------------- DONE
	const TYPE variables_init_serie {
		printf("const TYPE variables_init_serie -> initialisation\n");
		
		constanteZone = false;
		$$ = $3;
		free($2);
	}
// ---1-----2-------3------------------------------------------------ DONE
	| const STENCIL stencils_init_serie {
		printf("const STENCIL stencils_init_serie -> initialisation\n");
		
		constanteZone = false;
		$$ = $3;
		free($2);
	}
	;

//__________________________________________________________________________________

const :
// -1---------------------------------------------------------------- DONE
	CONST {
		printf("const -> CONST\n");

		constanteZone = true;
		$$ = true;

		free($1);
	}
// ------------------------------------------------------------------ DONE
	| {
		$$ = false;
	}
	;

//__________________________________________________________________________________

variables_init_serie :
// -1-------------2-----3-------------------------------------------- DONE
	variable_init COMMA variables_init_serie {
		printf("variable_init COMA variables_init_serie -> variables_init_serie\n");
		
		$$ = $1;
		instructionConcat($$,$3);
		$3 = NULL;

		free($2);
	}
// ---1-------------------------------------------------------------- DONE
	| variable_init {
		printf("variable_init -> variables_init_serie\n");
		
		$$ = $1;
	}
	;

//__________________________________________________________________________________ 

variable_init :		
// -1---------------------------------------------------------------- DONE
	unit_init {
		$$ = $1;
	}
// ---1-------------------------------------------------------------- DONE 
	| array_init {
		$$ = $1;
	}
	;

//__________________________________________________________________________________

unit_init :
// -1--2------3------------------------------------------------------ DONE
	ID EQUALS evaluation {
		printf("ID EQUALS evaluation -> variable_init\n");

		checkNULLSymbol($3.symbolEval);
		if(symbolsTableGetSymbolById(symbolsTable,$1) != NULL){
			ERROR("La variable '%s' existe deja",$1); 	
		}
		if(!constanteZone){
			Symbol result = symbolsTableAddSymbolUnit(symbolsTable,$1,true);
			$$ = $3.instructionEval;
			PUSH_BACK($$,1,"sw $t0 %s",((Unit*)result->data)->mipsId);
			
			PUSH_FORWARD(actualFunction->stackInstructions,1,"sw $t1 0($sp)");
			PUSH_FORWARD(actualFunction->stackInstructions,1,"lw $t1 %s",((Unit*)result->data)->mipsId);
			PUSH_FORWARD(actualFunction->stackInstructions,1,"sub $sp $sp 4");
			
			PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 0($sp)");
			PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s",((Unit*)result->data)->mipsId);
			PUSH_BACK(actualFunction->unStackInstructions,1,"add $sp $sp 4");
		}else{
			if(!$3.constEval){
				ERROR("La variable '%s' a besoin d'une valeur constante",$1); 
			}
			symbolsTableAddSymbolDefine(symbolsTable,$1,$3.constInt);
			instructionListFree($3.instructionEval);
			$3.instructionEval = NULL;
			instructionListMalloc(&$$);
		}
		
		free($1);
		free($2);
	}
// ---1-------------------------------------------------------------- DONE
	| ID {
		Symbol s;
		printf("ID -> variable_init\n");

		if(symbolsTableGetSymbolById(symbolsTable,$1) != NULL){
			ERROR("La variable '%s' existe deja",$1); 	
		}
		if(!constanteZone){
			s = symbolsTableAddSymbolUnit(symbolsTable,$1,false);
			instructionListMalloc(&$$);
			
			PUSH_FORWARD(actualFunction->stackInstructions,1,"sw $t1 0($sp)");
			PUSH_FORWARD(actualFunction->stackInstructions,1,"lw $t1 %s",((Unit*)s->data)->mipsId);
			PUSH_FORWARD(actualFunction->stackInstructions,1,"sub $sp $sp 4");
			
			PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 0($sp)");
			PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s",((Unit*)s->data)->mipsId);
			PUSH_BACK(actualFunction->unStackInstructions,1,"add $sp $sp 4");
		}else{
			ERROR("La variable '%s' est declaré constante mais n'est pas initialisé",$1); 
		}

		free($1);
	}
	;
	
//__________________________________________________________________________________

array_init :	
// -1----------------2----------3------------------------------------ DONE
	array_init_begin hooks_init array_affect {
		printf("array_init_begin hooks_init array_affect -> array_init\n");

		if(!$2.constHooksInit && !$3.empty){
			ERROR("Impossible d'affecte des valeurs au tableau '%s' de taille dynamique",actualArrayInit->id);
		}else if($3.empty && constanteZone){
			ERROR("Le tableau '%s' est declaré constant mais n'est pas initialisé",actualArrayInit->id); 
		}else if(!$3.empty && $2.nbValue > $3.nbValue){
			ERROR("Pas assez de valeur dans l'initialisation du tableau '%s', attendu : %d, actuel : %d",actualArrayInit->id, $2.nbValue, $3.nbValue);
		}else if(!$3.empty && $2.nbValue < $3.nbValue){
			ERROR("Trop de valeur dans l'initialisation du tableau '%s', attendu : %d, actuel : %d",actualArrayInit->id, $2.nbValue, $3.nbValue);
		}else if(!$3.empty && constanteZone){
			actualArrayInit->constant = true;	
		}
			
		instructionListMalloc(&$$);
		PUSH_BACK(rootTree,1,"%s_verificator : .word 0",actualArrayInit->mipsId);
		PUSH_BACK($$,1,"li $a0 %d",actualArrayInit->nbDimension*4);
		PUSH_BACK($$,1,"li $v0 9");
		PUSH_BACK($$,1,"syscall");
		PUSH_BACK($$,1,"sw $v0 %s_verificator",actualArrayInit->mipsId);
		
		PUSH_BACK(rootTree,1,"%s_multiplicator : .word 0",actualArrayInit->mipsId);
		PUSH_BACK($$,1,"li $a0 %d",actualArrayInit->nbDimension*4);
		PUSH_BACK($$,1,"li $v0 9");
		PUSH_BACK($$,1,"syscall");
		PUSH_BACK($$,1,"sw $v0 %s_multiplicator",actualArrayInit->mipsId);
		
		PUSH_BACK(rootTree,1,"%s_accesTable : .word 0",actualArrayInit->mipsId);
		PUSH_BACK($$,1,"li $a0 %d",actualArrayInit->nbDimension*4);
		PUSH_BACK($$,1,"li $v0 9");
		PUSH_BACK($$,1,"syscall");
		PUSH_BACK($$,1,"sw $v0 %s_accesTable",actualArrayInit->mipsId);
		
		PUSH_BACK($$,1,"lw $s6 %s_verificator",actualArrayInit->mipsId);
		
		instructionConcat($$,$2.instructionHooksInit);
		$2.instructionHooksInit = NULL;
		
		PUSH_BACK($$,1,"sll $a0 $s4 2"); 
		PUSH_BACK($$,1,"li $v0 9");
		PUSH_BACK($$,1,"syscall");
		PUSH_BACK($$,1,"sw $v0 %s",actualArrayInit->mipsId);
		
		PUSH_BACK($$,1,"li $t1 0");
		PUSH_BACK($$,1,"li $t3 %d",actualArrayInit->nbDimension*4);
		PUSH_BACK($$,1,"lw $s5 %s_multiplicator",actualArrayInit->mipsId);		
		PUSH_BACK($$,1,"ARRAY_INIT_LOOP_1_%llu_BEGIN :",labelCounter);
		PUSH_BACK($$,1,"bge $t1 $t3 ARRAY_INIT_LOOP_1_%llu_END",labelCounter);
		
			PUSH_BACK($$,1,"add $t2 $t1 4");
			PUSH_BACK($$,1,"lw $s6 %s_verificator",actualArrayInit->mipsId);
			PUSH_BACK($$,1,"add $s6 $s6 $t2");
			PUSH_BACK($$,1,"li $t4 1");
			
			PUSH_BACK($$,1,"ARRAY_INIT_LOOP_2_%llu_BEGIN :",labelCounter);
			PUSH_BACK($$,1,"bge $t2 $t3 ARRAY_INIT_LOOP_2_%llu_END",labelCounter);
			
			PUSH_BACK($$,1,"lw $t5 0($s6)");
			PUSH_BACK($$,1,"add $s6 $s6 4");
			PUSH_BACK($$,1,"mul $t4 $t4 $t5");
			
			PUSH_BACK($$,1,"add $t2 $t2 4");
			PUSH_BACK($$,1,"j ARRAY_INIT_LOOP_2_%llu_BEGIN",labelCounter);
			PUSH_BACK($$,1,"ARRAY_INIT_LOOP_2_%llu_END :",labelCounter);	
			
			PUSH_BACK($$,1,"sw $t4 0($s5)");
			PUSH_BACK($$,1,"add $s5 $s5 4");
			
			PUSH_BACK($$,1,"add $t1 $t1 4");
		PUSH_BACK($$,1,"j ARRAY_INIT_LOOP_1_%llu_BEGIN",labelCounter);
		PUSH_BACK($$,1,"ARRAY_INIT_LOOP_1_%llu_END :",labelCounter);
		labelCounter++;

		instructionConcat($$,$3.instructionArray);
		$3.instructionArray = NULL;

		//BEGIN STACK
		InstructionsList temp;
		instructionListMalloc(&temp);
		PUSH_BACK(temp,1,"sub $sp $sp %d",3*4);	
		PUSH_BACK(temp,1,"lw $t1 %s_multiplicator",actualArrayInit->mipsId);
		PUSH_BACK(temp,1,"sw $t1 0($sp)");
		PUSH_BACK(temp,1,"lw $t1 %s_verificator",actualArrayInit->mipsId);
		PUSH_BACK(temp,1,"sw $t1 4($sp)");
		PUSH_BACK(temp,1,"lw $t1 %s_accesTable",actualArrayInit->mipsId);
		PUSH_BACK(temp,1,"sw $t1 8($sp)");
		instructionConcat(temp,actualFunction->stackInstructions);
		actualFunction->stackInstructions = NULL;
		actualFunction->stackInstructions = temp;
		//END STACK
		
		//BEGIN UNSTACK
		//POUR INFO on pourrait free ici
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 0($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_multiplicator",actualArrayInit->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 4($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_verificator",actualArrayInit->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 8($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_accesTable",actualArrayInit->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"add $sp $sp %d",3*4);
		//END UNSTACK
	}
	;

//__________________________________________________________________________________

array_affect :
// -1------2--------------------------------------------------------- DONE
	EQUALS number_serie_serie {
		printf("EQUALS LEMB number_serie_serie REMB -> array_affect\n");

		PUSH_FORWARD($2.instructionNumber,1,"sub $v0 $v0 $t1");
		PUSH_FORWARD($2.instructionNumber,1,"li $t1 4");

		$$.nbValue = $2.nbValue;
		$$.instructionArray = $2.instructionNumber;
		$$.empty = false;

		free($1);
	}
// ------------------------------------------------------------------ DONE
	| {
		instructionListMalloc(&$$.instructionArray);
		$$.empty = true;
	}
	;

//__________________________________________________________________________________

array_init_begin : 
// -1--2------------------------------------------------------------- DONE
	ID LHOO {
		if(symbolsTableGetSymbolById(symbolsTable,$1) != NULL){
			ERROR("La variable '%s' existe deja",$1); 	
		}
		actualArrayInit = symbolsTableAddArray(symbolsTable,$1)->data;

		free($1);
		free($2);
	}
	;
	
//__________________________________________________________________________________

hooks_init :
// -1----------2----3----------4------------------------------------- DONE
	hooks_init LHOO evaluation RHOO{
		printf("LHOO evaluation RHOO hooks_init -> hooks_init\n");
		
		checkNULLSymbol($3.symbolEval);
		$$.instructionHooksInit = $1.instructionHooksInit;
		if(!$3.constEval){
			$$.constHooksInit = false;
		}else{
			$$.nbValue = $1.nbValue*$3.constInt;
		}
		instructionConcat($$.instructionHooksInit,$3.instructionEval);
		$3.instructionEval = NULL;
		PUSH_BACK($$.instructionHooksInit,1,"mul $s4 $s4 $t0"); //la taille du tableau
		PUSH_BACK($$.instructionHooksInit,1,"li $t1 %d",actualArrayInit->nbDimension*4);
		PUSH_BACK($$.instructionHooksInit,1,"sw $t0 ($s6)");
		PUSH_BACK($$.instructionHooksInit,1,"add $s6 $s6 4");
		
		actualArrayInit->nbDimension++;

		free($2);
		free($4);
	}
// ---1----------2--------------------------------------------------- DONE
	| evaluation RHOO {
		printf("LHOO evaluation RHOO -> hooks_init\n");
		
		checkNULLSymbol($1.symbolEval);
		$$.instructionHooksInit = $1.instructionEval;
		if($1.constEval){
			$$.constHooksInit = true;
			$$.nbValue = $1.constInt;
		}
		PUSH_BACK($$.instructionHooksInit,1,"move $s4 $t0"); //la taille du tableau
		PUSH_BACK($$.instructionHooksInit,1,"li $t1 %d",actualArrayInit->nbDimension*4);
		PUSH_BACK($$.instructionHooksInit,1,"sw $t0 ($s6)");
		PUSH_BACK($$.instructionHooksInit,1,"add $s6 $s6 4");
				
		actualArrayInit->nbDimension++;

		free($2);
	}
	;

//__________________________________________________________________________________

number_serie_serie :
// -1----2------------------3---------------------------------------- DONE
	LEMB number_serie_comma REMB {	
		$$ = $2;
		
		free($1);
		free($3);
	}
// ---1----2------------3-------------------------------------------- DONE
	| LEMB number_serie REMB {
		printf("LEMB number_serie REMB -> number_serie_serie\n");

		$$ = $2;

		free($1);
		free($3);
	}
	;

number_serie_comma : 
// -1------------------2-----3--------------------------------------- DONE
	number_serie_serie COMMA number_serie_comma {
		$$ = $1;
		$$.nbValue += $3.nbValue;
		instructionConcat($$.instructionNumber,$3.instructionNumber);
		$3.instructionNumber = NULL;

		free($2);
	}
// ---1-------------------------------------------------------------- DONE
	| number_serie_serie {
		$$ = $1;
	}
	;
	
//__________________________________________________________________________________

number_serie :
// -1------------2-----3--------------------------------------------- DONE
	number_serie COMMA evaluation {
		printf("number COMMA number_serie -> number_serie\n");

		checkNULLSymbol($3.symbolEval);
		$$.nbValue = $1.nbValue+1;

		instructionConcat($$.instructionNumber,$3.instructionEval);
		$3.instructionEval = NULL;

		PUSH_BACK($$.instructionNumber,1,"li $t1 4");
		PUSH_BACK($$.instructionNumber,1,"add $v0 $v0 $t1");
		PUSH_BACK($$.instructionNumber,1,"sw $t0 0($v0)");

		free($2);
	}
// ---1-------------------------------------------------------------- DONE
	| evaluation {
		printf("number -> number_serie\n");

		checkNULLSymbol($1.symbolEval);
		$$.nbValue = 1;

		PUSH_BACK($$.instructionNumber,1,"li $t1 4");
		PUSH_BACK($$.instructionNumber,1,"add $v0 $v0 $t1");
		PUSH_BACK($$.instructionNumber,1,"sw $t0 0($v0)");
	}
	;

//=================================================================================================
//				Les initialisations de stencil
//=================================================================================================

stencils_init_serie :
// -1------------2-----3--------------------------------------------- DONE
	stencil_init COMMA stencils_init_serie {
		printf("stencil_init COMA stencils_init_serie -> stencils_init_serie\n");
		
		$$ = $1;
		instructionConcat($$,$3);
		$3 = NULL;
		
		free($2);
	}
// ---1-------------------------------------------------------------- DONE
	| stencil_init {
		printf("stencil_init -> stencils_init_serie\n");
		
		$$ = $1;
	}
	;	
//__________________________________________________________________________________

stencil_init :
// -1--2----3----------4-----5----------6----7----------------------- DONE
	ID LEMB evaluation COMMA evaluation REMB array_affect {
		printf("stencil EQUALS LEMB suite_number REMB stencil_affect -> stencil_init\n");

		checkNULLSymbol($3.symbolEval);checkNULLSymbol($5.symbolEval);
		if(symbolsTableGetSymbolById(symbolsTable,$1) != NULL){
			ERROR("La variable '%s' existe deja",$1); 
		}
		Stencil* sten = (Stencil*)(symbolsTableAddStencil(symbolsTable,$1)->data);

		if((!$3.constEval || !$5.constEval) && !$7.empty){
			ERROR("Impossible d'affecte des valeurs au stencil '%s' de taille dynamique",$1);
		}else if($7.empty && constanteZone){
			ERROR("Le stencil '%s' est declaré constant mais n'est pas initialisé",$1); ;	
		}else if(!$7.empty && $3.constEval && $5.constEval && 
					powYacc( ($3.constInt*2+1), $5.constInt ) > $7.nbValue 
				)
		{
			ERROR("Pas assez de valeur dans l'initialisation, attendu : %d, actuel : %d",powYacc( ($3.constInt*2+1), $5.constInt ), $7.nbValue );
		}else if(!$7.empty && $3.constEval && $5.constEval && 
					powYacc( ($3.constInt*2+1), $5.constInt ) < $7.nbValue 
				){
			ERROR("Trop de valeur dans l'initialisation, attendu : %d, actuel : %d",powYacc( ($3.constInt*2+1), $5.constInt ), $7.nbValue );
		}else if(!$7.empty && constanteZone){
			sten->nbNeighbour = $3.constInt;
			sten->nbDimension = $5.constInt;
			sten->constant = true;	
			sten->constEval = true;	
		}else if($3.constEval && $5.constEval){
			sten->nbNeighbour = $3.constInt;
			sten->nbDimension = $5.constInt;
			sten->constEval = true;	
		}
		
		$$ = $3.instructionEval;

		PUSH_BACK(rootTree,1,"%s_nbNeighbourg : .word 0",sten->mipsId);
		PUSH_BACK($$,1,"sw $t0 %s_nbNeighbourg",sten->mipsId);

		PUSH_BACK($$,1,"li $t1 2");
		PUSH_BACK($$,1,"li $t2 1");
		PUSH_BACK($$,1,"mul $s4 $t0 $t1");
		PUSH_BACK($$,1,"add $s4 $s4 $t2"); // value

		instructionConcat($$,$5.instructionEval);
		$5.instructionEval = NULL;

		PUSH_BACK($$,1,"move $s5 $t0");	// dim
		PUSH_BACK(rootTree,1,"%s_nbDimension : .word 0",sten->mipsId);
		PUSH_BACK($$,1,"sw $s5 %s_nbDimension",sten->mipsId);

		PUSH_BACK(rootTree,1,"%s_multiplicator : .word 0",sten->mipsId);
		PUSH_BACK($$,1,"sll $a0 $s5 2"); 
		PUSH_BACK($$,1,"li $v0 9");
		PUSH_BACK($$,1,"syscall");
		PUSH_BACK($$,1,"sw $v0 %s_multiplicator",sten->mipsId);

		PUSH_BACK(rootTree,1,"%s_verificator : .word 0",sten->mipsId);
		PUSH_BACK($$,1,"sll $a0 $s5 2"); 
		PUSH_BACK($$,1,"li $v0 9");
		PUSH_BACK($$,1,"syscall");
		PUSH_BACK($$,1,"sw $v0 %s_verificator",sten->mipsId);

		PUSH_BACK(rootTree,1,"%s_accesTable : .word 0",sten->mipsId);
		PUSH_BACK($$,1,"sll $a0 $s5 2"); 
		PUSH_BACK($$,1,"li $v0 9");
		PUSH_BACK($$,1,"syscall");
		PUSH_BACK($$,1,"sw $v0 %s_accesTable",sten->mipsId);

		PUSH_BACK($$,1,"lw $t1 %s_multiplicator",sten->mipsId);
		PUSH_BACK($$,1,"lw $t4 %s_verificator",sten->mipsId);
		PUSH_BACK($$,1,"sll $t2 $s5 2");
		PUSH_BACK($$,1,"add $t2 $t2 $t1");
		PUSH_BACK($$,1,"sub $t2 $t2 4");
		PUSH_BACK($$,1,"li $t3 1");
		PUSH_BACK($$,1,"STENCIL_INIT_LOOP_%llu_BEGIN :",labelCounter);
		PUSH_BACK($$,1,"blt $t2 $t1 STENCIL_INIT_LOOP_%llu_END",labelCounter);
			PUSH_BACK($$,1,"sw $s4 0($t4)");
			PUSH_BACK($$,1,"add $t4 $t4 4");
			PUSH_BACK($$,1,"sw $t3 0($t2)");
			PUSH_BACK($$,1,"sub $t2 $t2 4");
			PUSH_BACK($$,1,"mul $t3 $t3 $s4");
		PUSH_BACK($$,1,"j STENCIL_INIT_LOOP_%llu_BEGIN",labelCounter);
		PUSH_BACK($$,1,"STENCIL_INIT_LOOP_%llu_END :",labelCounter);

		PUSH_BACK($$,1,"sll $a0 $t3 2"); 
		PUSH_BACK($$,1,"li $v0 9");
		PUSH_BACK($$,1,"syscall");
		PUSH_BACK($$,1,"sw $v0 %s",sten->mipsId);
		labelCounter++;

		instructionConcat($$,$7.instructionArray);
		$7.instructionArray = NULL;

		free($1);
		free($2);
		free($4);
		free($6);
		
		//BEGIN STACK
		InstructionsList temp;
		instructionListMalloc(&temp);
		PUSH_BACK(temp,1,"sub $sp $sp %d",5*4);	
		PUSH_BACK(temp,1,"lw $t1 %s_nbDimension",sten->mipsId);
		PUSH_BACK(temp,1,"sw $t1 0($sp)");
		PUSH_BACK(temp,1,"lw $t1 %s_nbNeighbourg",sten->mipsId);
		PUSH_BACK(temp,1,"sw $t1 4($sp)");
		PUSH_BACK(temp,1,"lw $t1 %s_multiplicator",sten->mipsId);
		PUSH_BACK(temp,1,"sw $t1 8($sp)");
		PUSH_BACK(temp,1,"lw $t1 %s_verificator",sten->mipsId);
		PUSH_BACK(temp,1,"sw $t1 12($sp)");
		PUSH_BACK(temp,1,"lw $t1 %s_accesTable",sten->mipsId);
		PUSH_BACK(temp,1,"sw $t1 16($sp)");
		instructionConcat(temp,actualFunction->stackInstructions);
		actualFunction->stackInstructions = NULL;
		actualFunction->stackInstructions = temp;
		//END STACK
		
		//BEGIN UNSTACK
		//POUR INFO on pourrait free ici
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 0($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_nbDimension",sten->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 4($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_nbNeighbourg",sten->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 8($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_multiplicator",sten->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 12($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_verificator",sten->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"lw $t1 16($sp)");
		PUSH_BACK(actualFunction->unStackInstructions,1,"sw $t1 %s_accesTable",sten->mipsId);
		PUSH_BACK(actualFunction->unStackInstructions,1,"add $sp $sp %d",5*4);
		//END UNSTACK
	}
	;

//=================================================================================================
//				Les affectations de variables
//=================================================================================================

affectation :
// -1--------2------3------------------------------------------------ DONE
	variable EQUALS evaluation {
		printf("variable EQUALS evaluation -> affectation\n");

		checkNULLSymbol($3.symbolEval);
		Array* arr = NULL;
		Stencil* sten = NULL;
		Unit* uni = NULL;
		ConstUnit* cons = NULL;
		switch($1->type){
			case unit :
				uni = (Unit*)$1->data;
				$$ = $3.instructionEval;
				PUSH_BACK($$,1,"sw $t0 %s",uni->mipsId);
				uni->init = true;
				break;
			case constUnit :
				cons = (ConstUnit*)$1->data;
				ERROR("La variable '%s' a ete declare constante",cons->id); 
				break;
			case array :
				arr = (Array*)$1->data;
				$$ = arr->stepsToAcces;
				if(arr->constant){
					ERROR("Le tableau '%s' a ete declare constante",arr->id); 	
				}

				instructionConcat($$,$3.instructionEval);
				$3.instructionEval = NULL;
				
				PUSH_BACK($$,1,"sw $t0 0($s4)");
				
				$$ = instructionStackUnstackS4S5S6S7T8($$,$1);
				break;
			case stencil :
				sten = (Stencil*)$1->data;
				if(sten->stepsToAcces == NULL){
					ERROR("Le stencil '%s' a besoin de crochet",sten->id); 	
				}
				$$ = sten->stepsToAcces;
				sten->stepsToAcces = NULL;
				if(sten->constant){
					ERROR("Le stencil '%s' a ete declare constante",sten->id); 	
				}

				instructionConcat($$,$3.instructionEval);
				$3.instructionEval = NULL;
				
				PUSH_BACK($$,1,"sw $t0 0($s4)");
				
				$$ = instructionStackUnstackS4S5S6S7T8($$,$1);
				break;
			default :
				ERROR("Symbole inatendu '%u'",$1->type);
				break;
		}

		free($2);
	}
// ---1--------2------3---------------------------------------------- DONE
	| variable AFFECT evaluation {
		printf("variable AFFECT evaluation -> affectation\n");

		checkNULLSymbol($3.symbolEval);
		Array* arr = NULL;
		Stencil* sten = NULL;
		Unit* uni = NULL;
		ConstUnit* cons = NULL;
		switch($1->type){
			case unit :
				uni = (Unit*)$1->data;
				$$ = $3.instructionEval;
				if(uni->init == false){
					ERROR("La variable '%s' est utilise mais pas initialise",uni->id); 
				}
				PUSH_BACK($$,1,"lw $t1 %s",uni->mipsId);
				if(!strcmp($2,"+=")){
					PUSH_BACK($$,1,"add $t0 $t1 $t0");
				}else if(!strcmp($2,"-=")){
					PUSH_BACK($$,1,"sub $t0 $t1 $t0");
				}else if(!strcmp($2,"*=")){
					PUSH_BACK($$,1,"mul $t0 $t1 $t0");
				}else if(!strcmp($2,"/=")){
					PUSH_BACK($$,1,"div $t0 $t1 $t0");
				}else if(!strcmp($2,"%=")){
					PUSH_BACK($$,1,"div $t2 $t1 $t0");
					PUSH_BACK($$,1,"mul $t2 $t2 $t0");
					PUSH_BACK($$,1,"sub $t0 $t1 $t2");
				}
				PUSH_BACK($$,1,"sw $t0 %s",uni->mipsId);
				break;
			case constUnit :
				cons = (ConstUnit*)$1->data;
				ERROR("La variable '%s' a ete declare constante",cons->id); 
				break;
			case array :
				arr = (Array*)$1->data;
				$$ = arr->stepsToAcces;
				if(arr->constant){
					ERROR("Le tableau '%s' a ete declare constante",arr->id); 
				}
				instructionConcat($$,$3.instructionEval);
				$3.instructionEval = NULL;
				
				PUSH_BACK($$,1,"lw $t1 0($s4)");
				if(!strcmp($2,"+=")){
					PUSH_BACK($$,1,"add $t0 $t1 $t0");
				}else if(!strcmp($2,"-=")){
					PUSH_BACK($$,1,"sub $t0 $t1 $t0");
				}else if(!strcmp($2,"*=")){
					PUSH_BACK($$,1,"mul $t0 $t1 $t0");
				}else if(!strcmp($2,"/=")){
					PUSH_BACK($$,1,"div $t0 $t1 $t0");
				}else if(!strcmp($2,"%=")){
					PUSH_BACK($$,1,"div $t2 $t1 $t0");
					PUSH_BACK($$,1,"mul $t2 $t2 $t0");
					PUSH_BACK($$,1,"sub $t0 $t1 $t2");
				}
				PUSH_BACK($$,1,"sw $t0 0($s4)");
				
				$$ = instructionStackUnstackS4S5S6S7T8($$,$1);
				break;
			case stencil :
				sten = (Stencil*)$1->data;
				if(sten->stepsToAcces == NULL){
					ERROR("Le stencil '%s' a besoin de crochet",sten->id); 	
				}
				$$ = sten->stepsToAcces;
				sten->stepsToAcces = NULL;
				if(sten->constant){
					ERROR("Le stencil '%s' a ete declare constante",sten->id); 
				}
				instructionConcat($$,$3.instructionEval);
				$3.instructionEval = NULL;
				
				PUSH_BACK($$,1,"lw $t1 0($s4)");
				if(!strcmp($2,"+=")){
					PUSH_BACK($$,1,"add $t0 $t1 $t0");
				}else if(!strcmp($2,"-=")){
					PUSH_BACK($$,1,"sub $t0 $t1 $t0");
				}else if(!strcmp($2,"*=")){
					PUSH_BACK($$,1,"mul $t0 $t1 $t0");
				}else if(!strcmp($2,"/=")){
					PUSH_BACK($$,1,"div $t0 $t1 $t0");
				}else if(!strcmp($2,"%=")){
					PUSH_BACK($$,1,"div $t2 $t1 $t0");
					PUSH_BACK($$,1,"mul $t2 $t2 $t0");
					PUSH_BACK($$,1,"sub $t0 $t1 $t2");
				}
				PUSH_BACK($$,1,"sw $t0 0($s4)");
				
				$$ = instructionStackUnstackS4S5S6S7T8($$,$1);
				break;
			default :
				ERROR("Symbole inatendu '%u'",$1->type);
				break;
		}

		free($2);
	}
	;

//=================================================================================================
//				Les instructions conditionnelles
//=================================================================================================

for :
// -1---2----------3----4--------------5----6----------7----8-----------------9----10----11-- DONE
	FOR step_begin LBRA for_init_serie SEMI evaluation SEMI evaluations_serie RBRA ligne step_end {
		printf("FOR LBRA affectations_serie SEMI evaluation SEMI evaluation RBRA ligne -> for\n");
		
		checkNULLSymbol($6.symbolEval);
		if($6.constEval){
			if($6.constInt){
				fprintf(stdout,"WARNING boucle infini à la ligne %d\n",yylineno);
				$$ = $4;
				PUSH_BACK($$,1,"LOOP_FOR_%llu_BEGIN :",labelCounter);
				instructionConcat($$,$10.instructionLine);
				$10.instructionLine = NULL;
				instructionConcat($$,$8);
				$8 = NULL;
				PUSH_BACK($$,1,"j LOOP_FOR_%llu_BEGIN",labelCounter);
				labelCounter++;
				instructionListFree($6.instructionEval);
				$6.instructionEval = NULL;
			}else{
				$$ = $4;
				instructionListFree($6.instructionEval);
				$6.instructionEval = NULL;
				instructionListFree($8);
				$8 = NULL;
				instructionListFree($10.instructionLine);
				$10.instructionLine = NULL;
			}
		}else{
			$$ = $4;	
			PUSH_BACK($$,1,"LOOP_FOR_%llu_BEGIN :",labelCounter);
			instructionConcat($$,$6.instructionEval);
			$6.instructionEval = NULL;
			PUSH_BACK($$,1,"beq $0 $t0 LOOP_FOR_%llu_END",labelCounter);
			instructionConcat($$,$10.instructionLine);
			$10.instructionLine = NULL;
			instructionConcat($$,$8);
			$8 = NULL;
			PUSH_BACK($$,1,"j LOOP_FOR_%llu_BEGIN",labelCounter);
			PUSH_BACK($$,1,"LOOP_FOR_%llu_END :",labelCounter);
			labelCounter++;
		}
		
		free($1);
		free($3);
		free($5);
		free($7);
		free($9);
	}
	;

//__________________________________________________________________________________

for_init_serie :
// -1---------------------------------------------------------------- DONE
	affectations_serie {
		$$ = $1;
	}
// ---1-----2----3--------------------------------------------------- DONE
	| const TYPE variables_init_serie {
		printf("const TYPE variables_init_serie -> affectations_serie\n");
		
		constanteZone = false;
		$$ = $3;

		free($2);
	}
	;
//__________________________________________________________________________________

affectations_serie :
// -1------------------2-----3--------------------------------------- DONE
	affectations_serie COMMA affectation{
		printf("affectations_serie affectation COMMA -> affectations_serie\n");

		$$ = $1;
		instructionConcat($$,$3);
		$3 = NULL;

		free($2);
	}
// ---1-------------------------------------------------------------- DONE
	| affectation {
		printf("affectation -> affectations_serie\n");

		$$ = $1;
	}
	;

//__________________________________________________________________________________

evaluations_serie :
// -1-----------------2-----3---------------------------------------- DONE
	evaluations_serie COMMA evaluation {
		printf("evaluations_serie evaluation COMMA -> evaluations_serie\n");

		checkNULLSymbol($3.symbolEval);
		$$ = $1;
		instructionConcat($$,$3.instructionEval);
		$3.instructionEval = NULL;

		free($2);
	}
// ---1-----------------2-----3-------------------------------------- DONE
	| evaluations_serie COMMA affectation {
		printf("evaluations_serie evaluation COMMA -> evaluations_serie\n");

		$$ = $1;
		instructionConcat($$,$3);
		$3 = NULL;

		free($2);
	}
// ---1-------------------------------------------------------------- DONE
	| evaluation {
		printf("evaluation -> evaluations_serie\n");

		checkNULLSymbol($1.symbolEval);
		$$ = $1.instructionEval;
	}
// ---1-------------------------------------------------------------- DONE
	| affectation {
		printf("affectation -> evaluations_serie\n");

		$$ = $1;
	}
	;

//__________________________________________________________________________________

while :
// -1-----2----3----------4----5----------6-----7-------------------- DONE
	WHILE LBRA evaluation RBRA step_begin ligne step_end {
		printf("WHILE LBRA evaluation RBA ligne -> while\n");
		
		checkNULLSymbol($3.symbolEval);
		if($3.constEval){
			if($3.constInt){
				fprintf(stdout,"WARNING boucle infini à la ligne %d\n",yylineno);
				$$ = $6.instructionLine;
				PUSH_FORWARD($$,1,"LOOP_WHILE_%llu_BEGIN :",labelCounter);
				PUSH_BACK($$,1,"j LOOP_WHILE_%llu_BEGIN",labelCounter);
				instructionListFree($3.instructionEval);
				$3.instructionEval = NULL;
			}else{
				instructionListFree($3.instructionEval);
				$3.instructionEval = NULL;
				instructionListFree($6.instructionLine);
				$6.instructionLine = NULL;
				instructionListMalloc(&$$);
			}
		}else{
			$$ = $3.instructionEval;
			PUSH_FORWARD($$,1,"LOOP_WHILE_%llu_BEGIN :",labelCounter);
			PUSH_BACK($$,1,"beq $0 $t0 LOOP_WHILE_%llu_END",labelCounter);
			instructionConcat($$,$6.instructionLine);
			$6.instructionLine = NULL;
			PUSH_BACK($$,1,"j LOOP_WHILE_%llu_BEGIN",labelCounter);
			PUSH_BACK($$,1,"LOOP_WHILE_%llu_END :",labelCounter);		
			labelCounter++;
		}

		free($1);
		free($2);
		free($4);
	}
	;

//__________________________________________________________________________________

if :
// -1--2----3----------4----5----------6-----7--------8-------------- DONE
	IF LBRA evaluation RBRA step_begin ligne step_end else {
		printf("IF LBRA evaluation RBRA ligne else -> if\n");
		
		checkNULLSymbol($3.symbolEval);
		if($3.constEval){
			instructionListFree($3.instructionEval);
			$3.instructionEval = NULL;
			if($3.constInt){
				$$.instructionLine = $6.instructionLine;
				$$.willReturn = $6.willReturn;
				instructionListFree($8.instructionLine);
				$8.instructionLine = NULL;
			}else{
				$$.instructionLine = $8.instructionLine;
				$$.willReturn = $8.willReturn;
				instructionListFree($6.instructionLine);
				$6.instructionLine = NULL;
			}
		}else{
			$$.instructionLine = $3.instructionEval;
			PUSH_BACK($$.instructionLine,1,"beq $0 $t0 IF_COND_%llu_FALSE",labelCounter);
			instructionConcat($$.instructionLine,$6.instructionLine);
			$6.instructionLine = NULL;
			PUSH_BACK($$.instructionLine,1,"j IF_COND_%llu_END",labelCounter);
			PUSH_BACK($$.instructionLine,1,"IF_COND_%llu_FALSE :",labelCounter);
			instructionConcat($$.instructionLine,$8.instructionLine);
			$8.instructionLine = NULL;
			PUSH_BACK($$.instructionLine,1,"IF_COND_%llu_END :",labelCounter);
			labelCounter++;
			$$.willReturn = $6.willReturn && $8.willReturn;
		}

		free($1);
		free($2);
		free($4);
	} 
	; 
 
//__________________________________________________________________________________ 
 
else : 
// -1----2----------3-----4------------------------------------------ DONE 
	ELSE step_begin ligne step_end { 
		printf("ELSE ligne -> else\n"); 
		
		$$ = $3;

		free($1);
	} 
// ------------------------------------------------------------------ DONE 
	| { 
		instructionListMalloc(&$$.instructionLine);
		$$.willReturn = false;
	} 
	; 	

//=================================================================================================
//				Le retour des valeurs
//=================================================================================================

evaluation :
// -1----------2-------------3--------------------------------------- DONE
	evaluation COMPARATOR_OR evaluation {
		printf("evaluation COMPARATOR_OR evaluation -> evaluation\n");

		checkNULLSymbol($1.symbolEval);checkNULLSymbol($3.symbolEval);
		$$ = $1;
		if($1.constEval && $3.constEval){
			instructionReAlloc(&$$.instructionEval);
			instructionListFree($3.instructionEval);
			$3.instructionEval = NULL;
			$$.constInt = $1.constInt || $1.constInt;
			PUSH_BACK($$.instructionEval,1,"li $t0 %d",$$.constInt);
		}else{
			PUSH_BACK($$.instructionEval,1,"bne $0 $t0 COMP_OR_%llu_RETURN_TRUE",labelCounter); //si $t0 != 0 => TRUE
			instructionConcat($$.instructionEval,$3.instructionEval);
			$3.instructionEval = NULL;
			PUSH_BACK($$.instructionEval,1,"bne $0 $t0 COMP_OR_%llu_RETURN_TRUE",labelCounter); //si $t0 != 0 => TRUE
			PUSH_BACK($$.instructionEval,1,"li $t0 0");	
			PUSH_BACK($$.instructionEval,1,"j COMP_OR_%llu_FIN",labelCounter);
			PUSH_BACK($$.instructionEval,1,"COMP_OR_%llu_RETURN_TRUE :",labelCounter);
			PUSH_BACK($$.instructionEval,1,"li $t0 1");	
			PUSH_BACK($$.instructionEval,1,"COMP_OR_%llu_FIN :",labelCounter);	
			++labelCounter;
		}
		$$.constEval = $1.constEval && $3.constEval; 
		
		$$.symbolEval = NULL;
		free($2);
	}
// ---1----------2--------------3------------------------------------ DONE
	| evaluation COMPARATOR_AND evaluation {
		printf("evaluation COMPARATOR_AND evaluation -> evaluation\n");
		
		checkNULLSymbol($1.symbolEval);checkNULLSymbol($3.symbolEval);
		$$ = $1;
		if($1.constEval && $3.constEval){
			instructionReAlloc(&$$.instructionEval);
			instructionListFree($3.instructionEval);
			$3.instructionEval = NULL;
			$$.constInt = $1.constInt && $1.constInt;
			PUSH_BACK($$.instructionEval,1,"li $t0 %d",$$.constInt);
		}else{
			PUSH_BACK($$.instructionEval,1,"beq $0 $t0 COMP_AND_%llu_RETURN_FALSE",labelCounter); //si $t0 == 0 => FALSE
			instructionConcat($$.instructionEval,$3.instructionEval);
			$3.instructionEval = NULL;
			PUSH_BACK($$.instructionEval,1,"beq $0 $t0 COMP_AND_%llu_RETURN_FALSE",labelCounter); //si $t0 == 0 => FALSE
			PUSH_BACK($$.instructionEval,1,"li $t0 1");	
			PUSH_BACK($$.instructionEval,1,"j COMP_AND_%llu_FIN",labelCounter);
			PUSH_BACK($$.instructionEval,1,"COMP_AND_%llu_RETURN_FALSE :",labelCounter);
			PUSH_BACK($$.instructionEval,1,"li $t0 0");	
			PUSH_BACK($$.instructionEval,1,"COMP_AND_%llu_FIN :",labelCounter);
			++labelCounter;	
		}
		$$.constEval = $1.constEval && $3.constEval; 
		
		$$.symbolEval = NULL;
		free($2);
	}
// ---1----------2-------------------3------------------------------- DONE 
	| evaluation COMPARATOR_EQUALITY evaluation {
		printf("evaluation COMPARATOR_EQUALITY evaluation -> evaluation\n");

		checkNULLSymbol($1.symbolEval);checkNULLSymbol($3.symbolEval);
		$$ = $1;
		if($1.constEval && $3.constEval){
			instructionReAlloc(&$$.instructionEval);
			instructionListFree($3.instructionEval);
			$3.instructionEval = NULL;
			if(!strcmp($2,"==")){
				$$.constInt = $1.constInt == $1.constInt;
			}else if(!strcmp($2,"!=")){
				$$.constInt = $1.constInt != $1.constInt;
			}
			PUSH_BACK($$.instructionEval,1,"li $t0 %d",$$.constInt);
		}else{
			PUSH_BACK($$.instructionEval,1,"move $s3 $t0");
			instructionConcat($$.instructionEval,$3.instructionEval);
			$3.instructionEval = NULL;
			char inst[4];
			if(!strcmp($2,"==")){
				strcpy(inst,"beq");
			}else if(!strcmp($2,"!=")){
				strcpy(inst,"bne");
			}
			PUSH_BACK($$.instructionEval,1,"%s $s3 $t0 COMP_EQUALITY_%llu_RETURN_TRUE",inst,labelCounter);
			PUSH_BACK($$.instructionEval,1,"li $t0 0");
			PUSH_BACK($$.instructionEval,1,"j COMP_EQUALITY_%llu_FIN",labelCounter);
			PUSH_BACK($$.instructionEval,1,"COMP_EQUALITY_%llu_RETURN_TRUE :",labelCounter);
			PUSH_BACK($$.instructionEval,1,"li $t0 1");	
			PUSH_BACK($$.instructionEval,1,"COMP_EQUALITY_%llu_FIN :",labelCounter);
			++labelCounter;	
		}
		$$.constEval = $1.constEval && $3.constEval; 

		$$.symbolEval = NULL;
		free($2);
	}
// ---1----------2--------------------3------------------------------ DONE 
	| evaluation COMPARATOR_SUPREMACY evaluation {
		printf("evaluation COMPARATOR_SUPREMACY evaluation -> evaluation\n");
		char inst[4];

		checkNULLSymbol($1.symbolEval);checkNULLSymbol($3.symbolEval);
		$$ = $1;
		if($1.constEval && $3.constEval){
			instructionReAlloc(&$$.instructionEval);
			instructionListFree($3.instructionEval);
			$3.instructionEval = NULL;
			if(!strcmp($2,"<")){
				$$.constInt = $1.constInt < $3.constInt;
			}else if(!strcmp($2,"<=")){
				$$.constInt = $1.constInt <= $3.constInt;
			}else if(!strcmp($2,">")){
				$$.constInt = $1.constInt > $3.constInt;
			}else if(!strcmp($2,">=")){
				$$.constInt = $1.constInt >= $3.constInt;
			}
			PUSH_BACK($$.instructionEval,1,"li $t0 %d",$$.constInt);
		}else{
			PUSH_BACK($$.instructionEval,1,"move $s2 $t0");
			instructionConcat($$.instructionEval,$3.instructionEval);
			$3.instructionEval = NULL;
			if(!strcmp($2,"<")){
				strcpy(inst,"blt");
			}else if(!strcmp($2,"<=")){
				strcpy(inst,"ble");
			}else if(!strcmp($2,">")){
				strcpy(inst,"bgt");
			}else if(!strcmp($2,">=")){
				strcpy(inst,"bge");
			}
			PUSH_BACK($$.instructionEval,1,"%s $s2 $t0 COMP_SUPREMACY_%llu_RETURN_TRUE",inst,labelCounter);
			PUSH_BACK($$.instructionEval,1,"li $t0 0");
			PUSH_BACK($$.instructionEval,1,"j COMP_SUPREMACY_%llu_FIN",labelCounter);
			PUSH_BACK($$.instructionEval,1,"COMP_SUPREMACY_%llu_RETURN_TRUE :",labelCounter);
			PUSH_BACK($$.instructionEval,1,"li $t0 1");	
			PUSH_BACK($$.instructionEval,1,"COMP_SUPREMACY_%llu_FIN :",labelCounter);
			++labelCounter;	
		}
		$$.constEval = $1.constEval && $3.constEval; 
		
		$$.symbolEval = NULL;
		free($2);
	}
// ---1----------2-----------------3--------------------------------- DONE
	| evaluation OPERATOR_ADDITION evaluation {
		printf("evaluation OPERATOR_ADDITION evaluation -> evaluation\n");

		checkNULLSymbol($1.symbolEval);checkNULLSymbol($3.symbolEval);
		$$ = $1;
		if($1.constEval && $3.constEval){
			instructionReAlloc(&$$.instructionEval);
			instructionListFree($3.instructionEval);
			$3.instructionEval = NULL;
			if($2[0] == '+'){
				$$.constInt += $3.constInt;
			}else{
				$$.constInt -= $3.constInt;
			}
			PUSH_BACK($$.instructionEval,1,"li $t0 %d",$$.constInt);
		}else{
			PUSH_FORWARD($3.instructionEval,1,"move $s1 $t0");
			instructionConcat($$.instructionEval,$3.instructionEval);
			$3.instructionEval = NULL;
			if($2[0] == '+'){
				PUSH_BACK($$.instructionEval,1,"add $t0 $s1 $t0");
			}else{
				PUSH_BACK($$.instructionEval,1,"sub $t0 $s1 $t0");
			}
		}
		$$.constEval = $1.constEval && $3.constEval; 
		$$.symbolEval = NULL;

		free($2);
	}
// ---1----------2--------------3------------------------------------ DONE
	| evaluation OPERATOR_MULTI evaluation {
		printf("evaluation OPERATOR_MULTI evaluation -> evaluation\n");
		
		checkNULLSymbol($1.symbolEval);checkNULLSymbol($3.symbolEval);
		$$ = $1;
		if($1.constEval && $3.constEval){
			instructionReAlloc(&$$.instructionEval);

			instructionListFree($3.instructionEval);
			$3.instructionEval = NULL;
			if($2[0] == '*'){
				$$.constInt *= $3.constInt;
			}else if($2[0] == '/') {
				if($3.constInt == 0){
					ERROR("Division par zero interdite");
				}
				$$.constInt /= $3.constInt;
			}else{
				if($3.constInt == 0){
					ERROR("Modulo par zero interdit");
				}
				$$.constInt %= $3.constInt;
			}
			PUSH_BACK($$.instructionEval,1,"li $t0 %d",$$.constInt);
		}else{
			PUSH_FORWARD($3.instructionEval,1,"move $s0 $t0");
			instructionConcat($$.instructionEval,$3.instructionEval);
			$3.instructionEval = NULL;
			if($2[0] == '*'){
				PUSH_BACK($$.instructionEval,1,"mul $t0 $s0 $t0");
			}else if($2[0] == '/') {
				PUSH_BACK($$.instructionEval,1,"beq $0 $t0 DIVIDEBYZERO");
				PUSH_BACK($$.instructionEval,1,"div $t0 $s0 $t0");
			}else{
				PUSH_BACK($$.instructionEval,1,"beq $0 $t0 DIVIDEBYZERO");
				PUSH_BACK($$.instructionEval,1,"div $t1 $s0 $t0");
				PUSH_BACK($$.instructionEval,1,"mul $t1 $t1 $t0");
				PUSH_BACK($$.instructionEval,1,"sub $t0 $s0 $t1");
			}			
		}
		$$.constEval = $1.constEval && $3.constEval; 
		$$.symbolEval = NULL;
		free($2);
	}
// ---1----2----------3---------------------------------------------- DONE
	| LBRA evaluation RBRA {
		printf("LBRA evaluation RBRA -> evaluation\n");
		int i;
		
		if($2.constEval){
			$$ = $2;
		}else{
			instructionListMalloc(&$$.instructionEval);
			PUSH_BACK($$.instructionEval,1,"sub $sp $sp %d",4*4);
			for(i=0 ; i<=3 ; ++i)
			{
				PUSH_BACK($$.instructionEval,1,"sw $s%d %d($sp)",i,i*4);
			}
			instructionIncr($2.instructionEval,1);
			PUSH_FORWARD($2.instructionEval,1,"#(");
			PUSH_BACK($2.instructionEval,1,"#)");
			instructionConcat($$.instructionEval,$2.instructionEval);
			$2.instructionEval = NULL;
			for(i=0 ; i<=3 ; ++i)
			{
				PUSH_BACK($$.instructionEval,1,"lw $s%d %d($sp)",i,i*4);
			}
			PUSH_BACK($$.instructionEval,1,"add $sp $sp %d",4*4);
		}

		$$.symbolEval = NULL;
		free($1);
		free($3);
	}
// ---1------2----3----------4--------------------------------------- DONE
	| PRINTI LBRA evaluation RBRA {
		printf("PRINTI LBRA evaluation RBRA -> evaluation\n");
		
		checkNULLSymbol($3.symbolEval);
		$$ = $3;
		PUSH_BACK($$.instructionEval,1,"move $a0 $t0");
		PUSH_BACK($$.instructionEval,1,"li $v0 1");
		PUSH_BACK($$.instructionEval,1,"syscall");
		PUSH_BACK($$.instructionEval,1,"li $t0 0");
		$$.constEval = false;

		$$.symbolEval = NULL;
		free($1);
		free($2);
		free($4);
	}
// ---1-----2----3--------------------------------------------------- DONE
	| SCANI LBRA RBRA {
		printf("PRINTI LBRA RBRA -> evaluation\n");
		
		instructionListMalloc(&$$.instructionEval);
		PUSH_BACK($$.instructionEval,1,"li $v0 5");
		PUSH_BACK($$.instructionEval,1,"syscall");
		PUSH_BACK($$.instructionEval,1,"move $t0 $v0");
		$$.constEval = false;

		$$.symbolEval = NULL;
		free($1);
		free($2);
		free($3);
	}
// ---1------2----3------4------------------------------------------- DONE
	| PRINTF LBRA STRING RBRA {
		printf("PRINTF LBRA STRING RBRA -> evaluation\n");

		instructionListMalloc(&$$.instructionEval);

		PUSH_BACK(rootTree,1,"string_%llu : .asciiz %s",variableCounter,$3);
		PUSH_BACK($$.instructionEval,1,"la $a0 string_%llu",variableCounter++);
		PUSH_BACK($$.instructionEval,1,"li $v0 4");
		PUSH_BACK($$.instructionEval,1,"syscall");
		PUSH_BACK($$.instructionEval,1,"li $t0 0");
		$$.constEval = false;

		$$.symbolEval = NULL;
		free($1);
		free($2);
		free($3);
		free($4);
	}
// ---1-----------------2-------------------------------------------- DONE
	| OPERATOR_NEGATION evaluation {
		printf("OPERATOR_NEGATION evaluation -> evaluation\n");
		
		checkNULLSymbol($2.symbolEval);
		$$ = $2;
		if($$.constEval){
			$$.constInt = !$$.constInt;
			instructionReAlloc(&$$.instructionEval);
			PUSH_BACK($$.instructionEval,1,"li $t0 %d",$$.constInt);
		}else{
			PUSH_BACK($$.instructionEval,1,"beq $0 $t0 OPPE_NEG_%llu",labelCounter);
			PUSH_BACK($$.instructionEval,1,"li $t0 0");
			PUSH_BACK($$.instructionEval,1,"j OPPE_NEG_%llu_FIN",labelCounter);
			PUSH_BACK($$.instructionEval,1,"OPPE_NEG_%llu :",labelCounter);
			PUSH_BACK($$.instructionEval,1,"li $t0 1");
			PUSH_BACK($$.instructionEval,1,"OPPE_NEG_%llu_FIN :",labelCounter);
			++labelCounter;		
		}
		
		$$.symbolEval = NULL;
		free($1);
	}
// ---1-------------------------------------------------------------- DONE
	| number {
		printf("number -> evaluation\n");
		
		instructionListMalloc(&$$.instructionEval);
		PUSH_BACK($$.instructionEval,1,"li $t0 %d",$1);
		$$.constEval = true;
		$$.constInt = $1;
		$$.symbolEval = NULL;
	}
// ---1-------------------------------------------------------------- DONE
	| variable_incr	{
		printf("variable_incr -> evaluation\n");
		
		$$ = $1;
	}
// ---1-------------2---------3-------------------------------------- DONE
	| function_call arguments RBRA {
		printf("variable -> variable_incr\n");
		
		instructionListMalloc(&$$.instructionEval);
		$$.constEval = false;
		$$.symbolEval = NULL;
		Function* fun = funCallStack[funCallLength-1];
		
		//stack les variables utiliser dans la fonction
		instructionCopy($$.instructionEval,fun->stackInstructions);
		instructionConcat($$.instructionEval,$2.instructionArgs);
		$2.instructionArgs = NULL;
		PUSH_BACK($$.instructionEval,1,"jal %s",fun->mipsId);
		//unstack les variables utiliser dans la fonction
		instructionCopy($$.instructionEval,fun->unStackInstructions);
		
		instructionStackUnstackUsedRegister($$.instructionEval);

		funCallStack = (void*)realloc(funCallStack,(--funCallLength)*sizeof(void*));
		
		free($3);
	}
	;

//__________________________________________________________________________________

variable_incr :
// -1------------------2--------------------------------------------- DONE
	OPERATOR_INCREMENT variable	{
		printf("OPERATOR_INCREMENT variable -> variable_incr\n");

		instructionListMalloc(&$$.instructionEval);
		$$.constEval = false;
		Array* arr = NULL;
		Stencil* sten = NULL;
		Unit* uni = NULL;
		ConstUnit* cons = NULL;
		switch($2->type){
			case unit :
				uni = (Unit*)$2->data;
				if( uni->init == false ){
					ERROR("La variable '%s' est utilise mais pas initialise",uni->id);
				}
				PUSH_BACK($$.instructionEval,1,"lw $t0 %s",uni->mipsId);
				if(!strcmp($1, "++")){
					PUSH_BACK($$.instructionEval,1,"add $t0 $t0 1");
				}else{
					PUSH_BACK($$.instructionEval,1,"sub $t0 $t0 1");
				}
				PUSH_BACK($$.instructionEval,1,"sw $t0 %s",uni->mipsId);
				break;
			case constUnit :
				cons = (ConstUnit*)$2->data;
				ERROR("La variable '%s' a ete declare constante",cons->id); 
				break;
			case array :
				arr = (Array*)$2->data;
				if(arr->constant){
					ERROR("Le tebleau '%s' a ete declare constante",arr->id); 
				}
				instructionConcat($$.instructionEval, arr->stepsToAcces);
				arr->stepsToAcces = NULL;
				PUSH_BACK($$.instructionEval,1,"lw $t0 0($s4)");
				if(!strcmp($1, "++")){
					PUSH_BACK($$.instructionEval,1,"add $t0 $t0 1");
				}else{
					PUSH_BACK($$.instructionEval,1,"sub $t0 $t0 1");
				}
				PUSH_BACK($$.instructionEval,1,"sw $t0 0($s4)");
				
				$$.instructionEval = instructionStackUnstackS4S5S6S7T8($$.instructionEval,$2);
				break;
			case stencil :
				sten = (Stencil*)$2->data;
				if(sten->constant){
					ERROR("Le stencil '%s' a ete declare constante",arr->id); 
				}
				if(sten->stepsToAcces == NULL){
					ERROR("Le stencil '%s' a besoin de crochet",sten->id); 	
				}
				instructionConcat($$.instructionEval, sten->stepsToAcces);
				sten->stepsToAcces = NULL;
				PUSH_BACK($$.instructionEval,1,"lw $t0 0($s4)");
				if(!strcmp($1, "++")){
					PUSH_BACK($$.instructionEval,1,"add $t0 $t0 1");
				}else{
					PUSH_BACK($$.instructionEval,1,"sub $t0 $t0 1");
				}
				PUSH_BACK($$.instructionEval,1,"sw $t0 0($s4)");
				
				$$.instructionEval = instructionStackUnstackS4S5S6S7T8($$.instructionEval,$2);
				break;
			default :
				ERROR("Symbole inatendu '%u'",$2->type);
				break;
		}

		$$.symbolEval = NULL;
		free($1);
	}
// ---1--------2----------------------------------------------------- DONE
	| variable OPERATOR_INCREMENT {
		printf("variable OPERATOR_INCREMENT -> variable_incr\n");
		
		instructionListMalloc(&$$.instructionEval);
		$$.constEval = false;
		Array* arr = NULL;
		Stencil* sten = NULL;
		Unit* uni = NULL;
		ConstUnit* cons = NULL;
		switch($1->type){
			case unit :
				uni = (Unit*)$1->data;
				if( uni->init == false ){
					ERROR("La variable '%s' est utilise mais pas initialise",uni->id); 	
				}
				PUSH_BACK($$.instructionEval,1,"lw $t0 %s",uni->mipsId);
				if(!strcmp($2, "++")){
					PUSH_BACK($$.instructionEval,1,"add $t0 $t0 1");
				}else{
					PUSH_BACK($$.instructionEval,1,"sub $t0 $t0 1");
				}
				PUSH_BACK($$.instructionEval,1,"sw $t0 %s",uni->mipsId);
				if(!strcmp($2, "++")){
					PUSH_BACK($$.instructionEval,1,"sub $t0 $t0 1");
				}else{
					PUSH_BACK($$.instructionEval,1,"add $t0 $t0 1");
				}
				break;
			case constUnit :
				cons = (ConstUnit*)$1->data;
				ERROR("La variable '%s' a ete declare constante",cons->id);
				break;
			case array :
				arr = (Array*)$1->data;
				if(arr->constant){
					ERROR("Le tableau '%s' a ete declare constante",arr->id); 
				}
				instructionConcat($$.instructionEval, arr->stepsToAcces);
				arr->stepsToAcces = NULL;
				PUSH_BACK($$.instructionEval,1,"lw $t0 0($s4)");
				PUSH_BACK($$.instructionEval,1,"lw $t1 0($s4)");
				if(!strcmp($2, "++")){
					PUSH_BACK($$.instructionEval,1,"add $t1 $t1 1");
				}else{
					PUSH_BACK($$.instructionEval,1,"sub $t1 $t1 1");
				}
				PUSH_BACK($$.instructionEval,1,"sw $t1 0($s4)");
				
				$$.instructionEval = instructionStackUnstackS4S5S6S7T8($$.instructionEval,$1);
				break;
			case stencil :
				sten = (Stencil*)$1->data;
				if(sten->constant){
					ERROR("Le stencil '%s' a ete declare constante",arr->id); 
				}
				if(sten->stepsToAcces == NULL){
					ERROR("Le stencil '%s' a besoin de crochet",sten->id); 	
				}
				instructionConcat($$.instructionEval, sten->stepsToAcces);
				sten->stepsToAcces = NULL;
				PUSH_BACK($$.instructionEval,1,"lw $t0 0($s4)");
				PUSH_BACK($$.instructionEval,1,"lw $t1 0($s4)");
				if(!strcmp($2, "++")){
					PUSH_BACK($$.instructionEval,1,"add $t1 $t1 1");
				}else{
					PUSH_BACK($$.instructionEval,1,"sub $t1 $t1 1");
				}
				PUSH_BACK($$.instructionEval,1,"sw $t1 0($s4)");
				
				$$.instructionEval = instructionStackUnstackS4S5S6S7T8($$.instructionEval,$1);
				break;
			default :
				ERROR("Symbole inatendu '%u'",$1->type);
				break;
		}

		$$.symbolEval = NULL;
		free($2);
	}
// ---1--------2----------------3------------------------------------ DONE
	| variable OPERATOR_STENCIL variable {
		printf("variable OPERATOR_STENCIL variable -> variable_incr\n");

		Symbol sArr;
		Array* arr = NULL;
		Stencil* sten = NULL;
		int i;

		if($1->type == stencil && $3->type == array){
			sten = (Stencil*)$1->data;
			arr = (Array*)$3->data; 
			sArr = $3;
		}else if($1->type == array && $3->type == stencil){
			sten = (Stencil*)$3->data;
			arr = (Array*)$1->data;
			sArr = $1;
		}else{
			ERROR("Les variables ne peuvent pas utilise l'operateur stencil "); 
		}		
		
		if(sten->stepsToAcces != NULL){
			ERROR("Le stencil '%s' a des crochets",sten->id); 	
		}

		$$.instructionEval = arr->stepsToAcces;	
		$$.constEval = false;

		PUSH_FORWARD($$.instructionEval,1,"bne $t0 $t1 OUTOFBOUND");
		PUSH_FORWARD($$.instructionEval,1,"lw $t0 %s_nbDimension",sten->mipsId);
		PUSH_FORWARD($$.instructionEval,1,"li $t1 %d",arr->nbDimension);

		for(i=0 ; i<arr->nbDimension ; ++i){
			if(i>=maxStencilVar){
				snprintf(instructionTempo,BUFFER_SIZE,"stencil_var_%i_end : .word 0",i);
				instructionPushBack(rootTree,instructionTempo,1);

				snprintf(instructionTempo,BUFFER_SIZE,"stencil_var_%i_beg : .word 0",i);
				instructionPushBack(rootTree,instructionTempo,1);
				maxStencilVar = i+1;
			}
		}

		PUSH_BACK($$.instructionEval,1,"lw $t3 %s",sten->mipsId);
		PUSH_BACK($$.instructionEval,1,"li $t2 0");

		for(i=0 ; i<arr->nbDimension ; ++i){
			PUSH_BACK($$.instructionEval,1,"lw $t0 %s_nbNeighbourg",sten->mipsId);	
			PUSH_BACK($$.instructionEval,1,"sub $t1 $zero $t0");
			PUSH_BACK($$.instructionEval,1,"add $t0 $t0 1");
			PUSH_BACK($$.instructionEval,1,"sw $t0 stencil_var_%d_end",i);	
			PUSH_BACK($$.instructionEval,1,"sw $t1 stencil_var_%d_beg",i);

			PUSH_BACK($$.instructionEval,1,"LOOP_FOR_%llu_BEGIN :",labelCounter);
			PUSH_BACK($$.instructionEval,1,"lw $t0 stencil_var_%d_end",i);	
			PUSH_BACK($$.instructionEval,1,"lw $t1 stencil_var_%d_beg",i);

			PUSH_BACK($$.instructionEval,1,"beq $t0 $t1 LOOP_FOR_%llu_END",labelCounter++);
		}

		int temp = labelCounter;

		{	
			PUSH_BACK($$.instructionEval,1,"li $s4 0");
			PUSH_BACK($$.instructionEval,1,"lw $s5 %s_multiplicator",arr->mipsId);
			PUSH_BACK($$.instructionEval,1,"lw $s6 %s_verificator",arr->mipsId);
			PUSH_BACK($$.instructionEval,1,"li $s7 %d",arr->nbDimension);
			PUSH_BACK($$.instructionEval,1,"lw $t8 %s_accesTable",arr->mipsId);
			for(i=0 ; i<arr->nbDimension ; ++i)
			{
				PUSH_BACK($$.instructionEval,1,"lw $t0 0($t8)");
				PUSH_BACK($$.instructionEval,1,"lw $t1 stencil_var_%d_beg",i);
				PUSH_BACK($$.instructionEval,1,"add $t0 $t0 $t1");
				PUSH_BACK($$.instructionEval,1,"add $t8 $t8 4");
				PUSH_BACK($$.instructionEval,1,"ble $s7 $0 OUTOFBOUND");
				PUSH_BACK($$.instructionEval,1,"sub $s7 $s7 1");
				PUSH_BACK($$.instructionEval,1,"lw $t1 0($s6)");
				PUSH_BACK($$.instructionEval,1,"add $s6 $s6 4");
				PUSH_BACK($$.instructionEval,1,"blt $t0 $0 OUTOFBOUND");
				PUSH_BACK($$.instructionEval,1,"bge $t0 $t1 OUTOFBOUND");
				PUSH_BACK($$.instructionEval,1,"lw $t1 0($s5)");
				PUSH_BACK($$.instructionEval,1,"add $s5 $s5 4");
				PUSH_BACK($$.instructionEval,1,"mul $t1 $t1 $t0");
				PUSH_BACK($$.instructionEval,1,"add $s4 $s4 $t1");		
			}
			PUSH_BACK($$.instructionEval,1,"sll $s4 $s4 2");
			PUSH_BACK($$.instructionEval,1,"lw $t1 %s",arr->mipsId);
			PUSH_BACK($$.instructionEval,1,"add $s4 $s4 $t1");

			PUSH_BACK($$.instructionEval,1,"lw $t0 0($s4)");
			PUSH_BACK($$.instructionEval,1,"lw $t1 0($t3)");
			PUSH_BACK($$.instructionEval,1,"mul $t0 $t0 $t1");
			PUSH_BACK($$.instructionEval,1,"add $t2 $t2 $t0");
			PUSH_BACK($$.instructionEval,1,"add $t3 $t3 4");
		}

		for(i=arr->nbDimension-1 ; i>=0 ; --i){
			PUSH_BACK($$.instructionEval,1,"lw $t1 stencil_var_%d_beg",i);
			PUSH_BACK($$.instructionEval,1,"add $t1 $t1 1");
			PUSH_BACK($$.instructionEval,1,"sw $t1 stencil_var_%d_beg",i);
			PUSH_BACK($$.instructionEval,1,"j LOOP_FOR_%llu_BEGIN",--labelCounter);
			PUSH_BACK($$.instructionEval,1,"LOOP_FOR_%llu_END :",labelCounter);
		}
		labelCounter = temp;

		PUSH_BACK($$.instructionEval,1,"move $t0 $t2");
		
		//unstack sten
		$$.instructionEval = instructionStackUnstackS4S5S6S7T8($$.instructionEval,sArr);

		$$.symbolEval = NULL;
		free($2);
	}
// ---1-------------------------------------------------------------- DONE
	| variable {
		printf("variable -> variable_incr\n");

		instructionListMalloc(&$$.instructionEval);
		$$.constEval = false;
		$$.symbolEval = NULL;
		Array* arr = NULL;
		Stencil* sten = NULL;
		Unit* uni = NULL;
		ConstUnit* cons = NULL;
		switch($1->type){
			case unit :
				uni = (Unit*)$1->data;
				if( uni->init == false ){
					ERROR("La variable '%s' est utilise mais pas initialise",uni->id); 
				}
				PUSH_BACK($$.instructionEval,1,"lw $t0 %s",uni->mipsId);
				break;
			case constUnit :
				cons = (ConstUnit*)$1->data;
				PUSH_BACK($$.instructionEval,1,"li $t0 %d",cons->value);
				$$.constEval = true;
				$$.constInt = cons->value;
				break;
			case array :
				arr = (Array*)$1->data;
				if(arr->stepsToAcces == NULL){
					$$.symbolEval = $1;
				}else{
					instructionConcat($$.instructionEval,arr->stepsToAcces);
					arr->stepsToAcces = NULL;
					PUSH_BACK($$.instructionEval,1,"lw $t0 0($s4)");
					$$.instructionEval = instructionStackUnstackS4S5S6S7T8($$.instructionEval,$1);
					$$.symbolEval = NULL;
				}break;
			case stencil :
				sten = (Stencil*)$1->data;
				if(sten->stepsToAcces == NULL){
					$$.symbolEval = $1;
				}else{
					instructionConcat($$.instructionEval,sten->stepsToAcces);
					sten->stepsToAcces = NULL;
					PUSH_BACK($$.instructionEval,1,"lw $t0 0($s4)");
					$$.instructionEval = instructionStackUnstackS4S5S6S7T8($$.instructionEval,$1);
					$$.symbolEval = NULL;
				}
				break;
			default :
				ERROR("Symbole inatendu '%u'",$1->type);
				break;
		}
	}
	;

//__________________________________________________________________________________

number :
// -1---------------------------------------------------------------- DONE
	NUMBER {
		printf("NUMBER -> number\n");
		$$ = atoi($1);

		free($1);
	}
// ---1-----------------2-------------------------------------------- DONE
	| OPERATOR_ADDITION NUMBER {
		printf("OPERATOR_ADDITION NUMBER -> number\n");
		
		if($1[0] == '-')
			$$ = -atoi($2);
		free($1);
		free($2);
	}
	;

//=================================================================================================
//				Les fonctions
//=================================================================================================
	
function_call :
// -1--2------------------------------------------------------------- DONE
	ID LBRA {
		Symbol sym = symbolsTableGetSymbolById(functionsTable,$1);
		if( sym == NULL){
			ERROR("Référence inconue vers la fonction '%s' ",$1);	
		}
		Function* fun = sym->data;
		if( sym->type != function ){
			ERROR("Symbole inatendu '%s'",$1);
		}
		
		if(funCallLength == 0){
			funCallStack = (void**) malloc(sizeof(void*));
			funCallStack[funCallLength++] = fun;
		}else{
			funCallStack = (void **)realloc(funCallStack,(funCallLength+1)*sizeof(void*));
			funCallStack[funCallLength++] = fun;
		}
		
		free($1);
		free($2);
	}
	;
	
//__________________________________________________________________________________

arguments :
// -1---------------------------------------------------------------- DONE
	arguments_serie {
		$$.instructionArgs = $1.instructionArgs;
		$$.nbArgs = $1.nbArgs;
		Function* fun = funCallStack[funCallLength-1];
		if(fun->nbArgs != $1.nbArgs){
			ERROR("Pas suffisamment d'arguments pour la fonction %s",fun->id);
		}
	}
// ------------------------------------------------------------------ DONE
	| { 
		instructionListMalloc(&$$.instructionArgs);
		$$.nbArgs = 0;
	}
	;

//__________________________________________________________________________________

arguments_serie : 
// -1---------------2-----3------------------------------------------ DONE
	arguments_serie COMMA evaluation {
		$$.instructionArgs = $1.instructionArgs;
		$$.nbArgs = $1.nbArgs;
		
		
		Function* fun = funCallStack[funCallLength-1];
		Symbol symFun = getSymbolByIdx(fun->argumentsTable,$$.nbArgs);
		Symbol symEval = $3.symbolEval;
		Array* arr = NULL;
		Stencil* sten = NULL;
		Unit* unitFun = NULL;
		Array* arrFun = NULL;
		Stencil* stenFun = NULL;
		if(symFun == NULL){
			ERROR("Trop d'arguments pour la fonction %s",fun->id);
		}
		switch(symFun->type){
			case unit :
				if(symEval == NULL){
					unitFun = (Unit*)symFun->data;
					
					instructionConcat($$.instructionArgs,$3.instructionEval);
					$3.instructionEval = NULL;
					PUSH_BACK($$.instructionArgs,1,"sw $t0 %s",unitFun->mipsId);
				}else if(symEval->type == array){
					ERROR("Erreur de parametre n°%d de la fonction %s : attendu int recu tableau",$$.nbArgs+1,fun->id);
				}else{ //stencil 
					ERROR("Erreur de parametre n°%d de la fonction %s : attendu int recu stencil",$$.nbArgs+1,fun->id);
				}
				break;
			case array :
				if(symEval == NULL){
						ERROR("Erreur de parametre n°%d de la fonction %s : attendu tableau recu int",$$.nbArgs+1,fun->id);
				}else if(symEval->type == array){
					arr = (Array*)symEval->data;
					arrFun = (Array*)symFun->data;
					
					instructionListFree($3.instructionEval);
					$3.instructionEval = NULL;
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s",arr->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s",arrFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_multiplicator",arr->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_multiplicator",arrFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_verificator",arr->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_verificator",arrFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_accesTable",arr->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_accesTable",arrFun->mipsId);
				}else{ //stencil 
					ERROR("Erreur de parametre n°%d de la fonction %s : attendu tableau recu stencil",$$.nbArgs+1,fun->id);
				}
				break;
			case stencil :
				if(symEval == NULL){
					ERROR("Erreur de parametre n°%d de la fonction %s : attendu stencil recu int",$$.nbArgs+1,fun->id);
				}else if(symEval->type == array){
					ERROR("Erreur de parametre n°%d de la fonction %s : attendu stencil recu tableau",$$.nbArgs+1,fun->id);
				}else{ //stencil 
					sten = (Stencil*)symEval->data;
					stenFun = (Stencil*)symFun->data;
					
					instructionListFree($3.instructionEval);
					$3.instructionEval = NULL;
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s",stenFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_multiplicator",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_multiplicator",stenFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_verificator",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_verificator",stenFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_accesTable",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_accesTable",stenFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_nbDimension",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_nbDimension",stenFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_nbNeighbourg",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_nbNeighbourg",stenFun->mipsId);
				}
				break;
			default :
				ERROR("Symbole Inatendu");
		}
	
		$$.nbArgs++;
		free($2);
	}
// ---1-------------------------------------------------------------- DONE
	| evaluation {
		$$.nbArgs = 0;
		Function* fun = funCallStack[funCallLength-1];
		Symbol symFun = getSymbolByIdx(fun->argumentsTable,$$.nbArgs);
		Symbol symEval = $1.symbolEval;
		Array* arr = NULL;
		Stencil* sten = NULL;
		Unit* unitFun = NULL;
		Array* arrFun = NULL;
		Stencil* stenFun = NULL;
		if(symFun == NULL){
			ERROR("Trop d'arguments pour la fonction %s",fun->id);
		}
		switch(symFun->type){
			case unit :
				if(symEval == NULL){
					unitFun = (Unit*)symFun->data;
					
					$$.instructionArgs = $1.instructionEval;
					PUSH_BACK($$.instructionArgs,1,"sw $t0 %s",unitFun->mipsId);
				}else if(symEval->type == array){
					ERROR("Erreur de parametre n°%d de la fonction %s : attendu int recu tableau",$$.nbArgs+1,fun->id);
				}else{ //stencil 
					ERROR("Erreur de parametre n°%d de la fonction %s : attendu int recu stencil",$$.nbArgs+1,fun->id);
				}
				break;
			case array :
				if(symEval == NULL){
						ERROR("Erreur de parametre n°%d de la fonction %s : attendu tableau recu int",$$.nbArgs+1,fun->id);
				}else if(symEval->type == array){
					arr = (Array*)symEval->data;
					arrFun = (Array*)symFun->data;
					
					if(arr->nbDimension != arrFun->nbDimension){
						ERROR("Erreur de parametre n°%d de la fonction %s : dimention incompatible attendu %d recu %d",$$.nbArgs+1,fun->id,arrFun->nbDimension,arr->nbDimension);
					}
					
					instructionListFree($1.instructionEval);
					$1.instructionEval = NULL;
					instructionListMalloc(&$$.instructionArgs);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s",arr->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s",arrFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_multiplicator",arr->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_multiplicator",arrFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_verificator",arr->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_verificator",arrFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_accesTable",arr->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_accesTable",arrFun->mipsId);
				}else{ //stencil 
					ERROR("Erreur de parametre n°%d de la fonction %s : attendu tableau recu stencil",$$.nbArgs+1,fun->id);
				}
				break;
			case stencil :
				if(symEval == NULL){
					ERROR("Erreur de parametre n°%d de la fonction %s : attendu stencil recu int",$$.nbArgs+1,fun->id);
				}else if(symEval->type == array){
					ERROR("Erreur de parametre n°%d de la fonction %s : attendu stencil recu tableau",$$.nbArgs+1,fun->id);
				}else{ //stencil 
					sten = (Stencil*)symEval->data;
					stenFun = (Stencil*)symFun->data;
					
					instructionListFree($1.instructionEval);
					$1.instructionEval = NULL;
					instructionListMalloc(&$$.instructionArgs);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s",stenFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_multiplicator",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_multiplicator",stenFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_verificator",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_verificator",stenFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_accesTable",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_accesTable",stenFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_nbDimension",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_nbDimension",stenFun->mipsId);
					PUSH_BACK($$.instructionArgs,1,"lw $t1 %s_nbNeighbourg",sten->mipsId);
					PUSH_BACK($$.instructionArgs,1,"sw $t1 %s_nbNeighbourg",stenFun->mipsId);
				}
				break;
			default :
				ERROR("Symbole Inatendu");
		}
		
		$$.nbArgs++;
	}
	;	
	
%%//==============================================================================================

void clearProg()
{
	if(outputFile!=NULL)fclose(outputFile);
	if(symbolsTable!=NULL)symbolsTableFree(symbolsTable);
	if(functionsTable!=NULL)symbolsTableFree(functionsTable);
	if(rootTree!=NULL)instructionListFree(rootTree);

	yylex_destroy();
}

int main(void)
{
	if(atexit(clearProg) != 0)
	{
		perror("[main] Probleme lors de l'enregistrement ");
		exit(EXIT_FAILURE);
	}

	symbolsTableMalloc(&symbolsTable);
	symbolsTableMalloc(&functionsTable);
	instructionListMalloc(&rootTree);
	
	yyparse();
	
	outputFile = fopen("output.mips","w");
	instructionListPrintFILE(rootTree,outputFile);	

	return EXIT_SUCCESS;
}

void yyerror (char const *s)
{
	fprintf(stderr,"erreur : %s a la ligne %d\n",s,yylineno);
	exit(EXIT_SUCCESS);
}

void checkNULLSymbol(Symbol s){
	if(s != NULL){
		if(s->type == array){
			ERROR("Utilisation incorrect du tableau %s",((Array*)s->type)->id);
		}else{//stencil
			ERROR("Utilisation incorrect du stencil %s",((Stencil*)s->type)->id);
		}
	}
}