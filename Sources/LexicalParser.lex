%{

#include <string.h>
#include <stdio.h>

#include "y.tab.h"

#ifdef _DEBUG
#define OUTPUT(args...) printf(args)
#else
#define OUTPUT(...)
#endif

#define STATE_NORMAL 0
#define STATE_DEFINE 1

int state = STATE_NORMAL;

%}

DEFINE				(#define)[ ]
ENDLINE				(\n)
FOR					(for)
WHILE				(while)
IF					(if)
ELSE				(else)
RETURN				(return)
MAIN				(main)
PRINTF				(printf)
PRINTI				(printi)
STENCIL				(stencil)
TYPE				(int)
ID					[a-zA-Z_][0-9a-zA-Z_]*
CHIFFRE				([0-9]+[0-9]*)
OPERATOR_NEGATION	(!)
OPERATOR_INCREMENT	(\+\+|--)
OPERATOR_MULTI		(\/|\*)
OPERATOR_ADDITION	(\+|-)
COMPARATOR_SUPREMACY (<=|>=|>|<)
COMPARATOR_EQUALITY (==|!=)
COMPARATOR_AND		(&&)
COMPARATOR_OR		(\|\|)
EQUALS				(=)
AFFECT				(\+=|-=|\*=|\/=|%=)
OPERATOR_STENCIL	($)
LBRA				(\()
RBRA				(\))
LHOO				(\[)
RHOO				(\])
LEMB				(\{)
REMB				(\})
COMMA				(\,)
SEMI				(\;)
COM_SINGLE			(\/\/[^\n]*)
COM_MULTI			(\/\*(.|\n)*\*\/)
STRING				(\"([^\"\n]|\\(.|\n))*\")
USELESS				[ |\t]
UNKNOW				.

%%

{DEFINE} {

	state = STATE_DEFINE;
	OUTPUT("\t\tDEFINE : %s\n",yytext);
	yylval.String = strdup(yytext);
	return DEFINE;
}

{ENDLINE} {

	if(state == STATE_DEFINE)
	{
		OUTPUT("\t\tENDLINE : %s\n",yytext);
		state = STATE_NORMAL;
		yylval.String = strdup(yytext);
		return ENDLINE;
	}

}

{FOR} {

	OUTPUT("\t\tFOR : %s\n",yytext);
	yylval.String = strdup(yytext);
	return FOR;

}

{WHILE} {

	OUTPUT("\t\tWHILE : %s\n",yytext);
	yylval.String = strdup(yytext);
	return WHILE;

}

{IF} {

	OUTPUT("\t\tIF : %s\n",yytext);
	yylval.String = strdup(yytext);
	return IF;

}

{ELSE} {
	
	OUTPUT("\t\tELSE : %s", yytext);
	yylval.String = strdup(yytext);
	return ELSE;

}

{RETURN} {

	OUTPUT("\t\tRETURN : %s\n",yytext);
	yylval.String = strdup(yytext);
	return RETURN;

}

{MAIN} {

	OUTPUT("\t\tMAIN : %s\n",yytext);
	yylval.String = strdup(yytext);
	return MAIN;

}

{PRINTF} {
	
	OUTPUT("\t\tPRINTF : %s\n",yytext);
	yylval.String = strdup(yytext);
	return PRINTF;
	
}

{PRINTI} {
	
	OUTPUT("\t\tPRINTI : %s\n",yytext);
	yylval.String = strdup(yytext);
	return PRINTI;
	
}

{STENCIL} {

	OUTPUT("\t\tSTENCIL : %s\n",yytext);
	yylval.String = strdup(yytext);
	return STENCIL;

}

{TYPE} {

	OUTPUT("\t\tTYPE : %s\n",yytext);
	yylval.String = strdup(yytext);
	return TYPE;

}

{ID} {
	
	OUTPUT("\t\tID : %s\n",yytext);
	yylval.String = strdup(yytext);
	return ID;

}

{CHIFFRE} {

	OUTPUT("\t\tCHIFFRE : %s\n",yytext);
	yylval.String = strdup(yytext);
	return CHIFFRE;

}

{OPERATOR_NEGATION} {
	
	OUTPUT("\t\tOPERATOR_NEGATION : %s\n",yytext);
	yylval.String = strdup(yytext);
	return OPERATOR_NEGATION;

}

{OPERATOR_INCREMENT} {
	
	OUTPUT("\t\tOPERATOR_INCREMENT : %s\n",yytext);
	yylval.String = strdup(yytext);
	return OPERATOR_INCREMENT;

}

{OPERATOR_MULTI} {
	
	OUTPUT("\t\tOPERATOR_MULTI : %s\n",yytext);
	yylval.String = strdup(yytext);
	return OPERATOR_MULTI;

}

{OPERATOR_ADDITION} {
	
	OUTPUT("\t\tOPERATOR_ADDITION : %s\n",yytext);
	yylval.String = strdup(yytext);
	return OPERATOR_ADDITION;

}

{COMPARATOR_SUPREMACY} {
	
	OUTPUT("\t\tCOMPARATOR_SUPREMACY : %s\n",yytext);
	yylval.String = strdup(yytext);
	return COMPARATOR_SUPREMACY;

}

{COMPARATOR_EQUALITY} {
	
	OUTPUT("\t\tCOMPARATOR_EQUALITY : %s\n",yytext);
	yylval.String = strdup(yytext);
	return COMPARATOR_EQUALITY;

}

{COMPARATOR_AND} {
	
	OUTPUT("\t\tCOMPARATOR_AND : %s\n",yytext);
	yylval.String = strdup(yytext);
	return COMPARATOR_AND;

}

{COMPARATOR_OR} {
	
	OUTPUT("\t\tCOMPARATOR_OR : %s\n",yytext);
	yylval.String = strdup(yytext);
	return COMPARATOR_OR;

}

{EQUALS} {
	
	OUTPUT("\t\tEQUALS : %s\n",yytext);
	yylval.String = strdup(yytext);
	return EQUALS;

}

{AFFECT} {
	
	OUTPUT("\t\tAFFECT : %s\n",yytext);
	yylval.String = strdup(yytext);
	return AFFECT;

}

{OPERATOR_STENCIL} {
	
	OUTPUT("\t\tOPERATOR_STENCIL : %s\n",yytext);
	yylval.String = strdup(yytext);
	return OPERATOR_STENCIL;

}


{LBRA} {

	OUTPUT("\t\tLBRA : %s\n",yytext);
	yylval.String = strdup(yytext);
	return LBRA;

}

{RBRA} {
	
	OUTPUT("\t\tRBRA : %s\n",yytext);
	yylval.String = strdup(yytext);
	return RBRA;

}

{LHOO} {
	
	OUTPUT("\t\tLHOO : %s\n",yytext);
	yylval.String = strdup(yytext);
	return LHOO;

}

{RHOO} {
	
	OUTPUT("\t\tRHOO : %s\n",yytext);
	yylval.String = strdup(yytext);
	return RHOO;

}

{LEMB} {
	
	OUTPUT("\t\tLEMB : %s\n",yytext);
	yylval.String = strdup(yytext);
	return LEMB;

}

{REMB} {
	
	OUTPUT("\t\tREMB : %s\n",yytext);
	yylval.String = strdup(yytext);
	return REMB;

}

{COMMA} {
	
	OUTPUT("\t\tCOMMA : %s\n",yytext);
	yylval.String = strdup(yytext);
	return COMMA;

}

{SEMI} {
	
	OUTPUT("\t\tSEMI : %s\n",yytext);
	yylval.String = strdup(yytext);
	return SEMI;

}

{COM_SINGLE} {

	OUTPUT("\t\tCOM_SINGLE : %s\n",yytext);

}

{COM_MULTI} {

	OUTPUT("\t\tCOM_MULTI : %s\n",yytext);

}

{STRING} {
	
	OUTPUT("\t\tSTRING : %s\n",yytext);
	yylval.String = strdup(yytext);
	return STRING;
	
}

{USELESS} {}

{UNKNOW} {
	
	printf("\t\t\x1b[31mUNKNOW : \x1b[0m%s\n",yytext);

}

%%

int yywrap()
{

	return 1;
	
}