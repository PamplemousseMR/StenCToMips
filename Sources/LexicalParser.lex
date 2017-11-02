%{

#include <string.h>
#include <stdio.h>

#include "y.tab.h"

#define STATE_NORMAL 0
#define STATE_DEFINE 1

int state = STATE_NORMAL;

%}

DEFINE            (#define)[ ]
ENDLINE           (\n)
FOR               (for)
WHILE             (while)
IF                (if)
ELSE              (else)
RETURN            (return)
MAIN              (main)
PRINTF            (printf)
PRINTI            (printi)
ID                [a-zA-Z_][0-9a-zA-Z_]*
CHIFFRE           ([0-9]+[0-9]*)
TYPE              (int)[ ]
STENCIL           (stencil)[ ]
OPERATOR          (\+|-|\/|%)
OPERATOR_STENCIL  ($)
INCREMENT         (\+\+|--)
EQUALS            (=)
AFFECT            (\+=|-=|\*=|\/=|%=)
COMPARATOR        (<=|>=|==|!=|>|<)
LBRA              (\()
RBRA              (\))
LHOO              (\[)
RHOO              (\])
LEMB              (\{)
REMB              (\})
COMMA             (\,)
SEMI              (\;)
COM_SINGLE        (\/\/[^\n]*)
COM_MULTI         (\/\*(.|\n)*\*\/)
STRING            (\"([^\"\n]|\\(.|\n))*\")
USELESS           [ |\t]
UNKNOW            .

%%

{DEFINE} {

  state = STATE_DEFINE;
  printf("\t\tDEFINE : %s\n",yytext);

}

{ENDLINE} {

  if(state == STATE_DEFINE)
  {
    printf("\t\tENDLINE : %s\n",yytext);
    state = STATE_NORMAL;
  }

}

{FOR} {

  printf("\t\tFOR : %s\n",yytext);

}

{WHILE} {

  printf("\t\tWHILE : %s\n",yytext);

}

{IF} {

  printf("\t\tIF : %s\n",yytext);

}

{RETURN} {

  printf("\t\tRETURN : %s\n",yytext);

}

{MAIN} {

  printf("\t\tMAIN : %s\n",yytext);

}

{PRINTF} {
  
  printf("\t\tPRINTF : %s\n",yytext);
  yylval.String = strdup(yytext);
  return PRINTF;
  
}

{PRINTI} {
  
  printf("\t\tPRINTI : %s\n",yytext);
  yylval.String = strdup(yytext);
  return PRINTI;
  
}

{ID} {
  
  printf("\t\tID : %s\n",yytext);

}

{CHIFFRE} {

  printf("\t\tCHIFFRE : %s\n",yytext);
  yylval.String = strdup(yytext);
  return CHIFFRE;

}

{TYPE} {

  printf("\t\tTYPE : %s\n",yytext);

}

{STENCIL} {

  printf("\t\tSTENCIL : %s\n",yytext);

}

{OPERATOR} {
  
  printf("\t\tOPERATOR : %s\n",yytext);
  yylval.String = strdup(yytext);
  return OPERATOR;

}

{OPERATOR_STENCIL} {
  
  printf("\t\tOPERATOR_STENCIL : %s\n",yytext);

}

{INCREMENT} {
  
  printf("\t\tINCREMENT : %s\n",yytext);
  yylval.String = strdup(yytext);
  return INCREMENT;

}

{EQUALS} {
  
  printf("\t\tEQUALS : %s\n",yytext);

}

{AFFECT} {
  
  printf("\t\tAFFECT : %s\n",yytext);

}

{COMPARATOR} {
  
  printf("\t\tCOMPARATOR : %s\n",yytext);
  yylval.String = strdup(yytext);
  return COMPARATOR;

}

{LBRA} {

  printf("\t\tLBRA : %s\n",yytext);
  yylval.String = strdup(yytext);
  return LBRA;

}

{RBRA} {
  
  printf("\t\tRBRA : %s\n",yytext);
  yylval.String = strdup(yytext);
  return RBRA;

}

{LHOO} {
  
  printf("\t\tLHOO : %s\n",yytext);

}

{RHOO} {
  
  printf("\t\tRHOO : %s\n",yytext);

}

{LEMB} {
  
  printf("\t\tLEMB : %s\n",yytext);

}

{REMB} {
  
  printf("\t\tRBRA : %s\n",yytext);

}

{COMMA} {
  
  printf("\t\tCOMMA : %s\n",yytext);

}

{SEMI} {
  
  printf("\t\tSEMI : %s\n",yytext);

}

{COM_SINGLE} {

  printf("\t\tCOM_SINGLE : %s\n",yytext);

}

{COM_MULTI} {

  printf("\t\tCOM_MULTI : %s\n",yytext);

}

{STRING} {
  
  printf("\t\tSTRING : %s\n",yytext);
  yylval.String = strdup(yytext);
  return STRING;
  
}

{USELESS} {}

{UNKNOW} 
{
  
  printf("\t\t\x1b[31mUNKNOW : \x1b[0m%s\n",yytext);

}

%%

int yywrap()
{

  return 1;
  
}