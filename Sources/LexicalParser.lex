%{

#include <string.h>
#include <stdio.h>

%}

FOR					    (?i:for)
WHILE				    (?i:while)
IF              (?i:if)
RETURN 			    (?i:return)
MAIN				    (main)
VARIABLE 			  [a-zA-Z_][0-9a-zA-Z_]*
CHIFFRE  			  ([0-9]+[0-9]*)
TYPE				    (void|int)[ \*]*
OPERATOR        (\+|-|\/|%)
INCREMENT       (\+\+|--)
AFFECT			    (\+=|-=|\*=|\/=|%=|=)
COMPARATOR      (<=|>=|==|!=|>|<|&&|\|\||!)
LBRA				    (\()
RBRA 				    (\))
LHOO				    (\[)
RHOO				    (\])
LEMB				    (\{)
REMB				    (\})
COMMA				    (\,)
SEMI				    (\;)

%%

{FOR} {

	printf("FOR : %s\n",yytext);

}

{WHILE} {

	printf("WHILE : %s\n",yytext);

}

{IF} {

  printf("IF : %s\n",yytext);

}

{RETURN} {

  printf("RETURN : %s\n",yytext);

}

{MAIN} {

  printf("MAIN : %s\n",yytext);

}

{VARIABLE} {
  
  printf("VARIABLE : %s\n",yytext);

}

{CHIFFRE} {

  printf("CHIFFRE : %s\n",yytext);

}

{TYPE} {

	printf("TYPE : %s\n",yytext);

}

{OPERATOR} {
  
  printf("OPERATOR : %s\n",yytext);

}

{INCREMENT} {
  
  printf("INCREMENT : %s\n",yytext);

}

{AFFECT} {
  
  printf("AFFECT : %s\n",yytext);

}

{COMPARATOR} {
  
  printf("COMPARATOR : %s\n",yytext);

}

{LBRA} {
  
  printf("LBRA : %s\n",yytext);

}

{RBRA} {
  
  printf("RBRA : %s\n",yytext);

}

{LHOO} {
  
  printf("LHOO : %s\n",yytext);

}

{RHOO} {
  
  printf("RHOO : %s\n",yytext);

}

{LEMB} {
  
  printf("LEMB : %s\n",yytext);

}

{REMB} {
  
  printf("RBRA : %s\n",yytext);

}

{COMMA} {
  
  printf("COMMA : %s\n",yytext);

}

{SEMI} {
  
  printf("SEMI : %s\n",yytext);

}

%%

int main()
{

  yylex();

  return 1;
  
}

int yywrap()
{

  return 1;
  
}