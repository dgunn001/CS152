%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
%}
   #include "y.tab.h"
   int row = 1;
   int col = 1;


%%



function {col += yyleng; return FUNCTION;}
beginparams {col += yyleng; return BEGIN_PARAMS;}
endparams   {col += yyleng; return END_PARAMS;}
beginlocals {col += yyleng; return BEGIN_LOCALS;}
endlocals   {col += yyleng; return END_LOCALS;}
beginbody   {col += yyleng; return BEGIN_BODY;}
endbody     {col += yyleng; return END_BODY;}
integer     {col += yyleng; return INTEGER;}
array    {col += yyleng; return ARRAY;}
of    {col += yyleng; return OF;}
if    {col += yyleng; return IF;}
then     {col += yyleng; return THEN;}
endif    {col += yyleng; return ENDIF;}
else     {col += yyleng; return ELSE;}
while    {col += yyleng; return WHILE;}
do    {col += yyleng; return DO;}
for {col += yyleng; return FOR;}
beginloop   {col += yyleng; return BEGINLOOP;}
endloop     {col += yyleng; return ENDLOOP;}
continue {col += yyleng; return CONTINUE;}
read     {col += yyleng; return READ;}
write    {col += yyleng; return WRITE;}
and      {col += yyleng; return AND;}
or    {col += yyleng; return OR;}




not      {col += yyleng; return NOT;}
true     {col += yyleng; return TRUE;}
false    {col += yyleng; return FALSE;}
return    {col += yyleng; return RETURN;}
"-"      {col += yyleng; return SUB;}
"+"      {col += yyleng; return ADD;}
"*"      {col += yyleng; return MULT;}
"/"      {col += yyleng; return DIV;}
"%"      {col += yyleng; return MOD;}
"=="     {col += yyleng; return EQ;}
"<>"     {col += yyleng; return NEQ;}
"<"      {col += yyleng; return LT;}
">"      {col += yyleng; return GT;}
"<="     {col += yyleng; return LTE;}
">="     {col += yyleng; return GTE;}


[0-9]+   {col += yyleng;  return NUMBER;}
[a-zA-Z][a-zA-Z0-9]* {col += yyleng; return IDENT;}
[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]   {col += yyleng; return IDENT;}


";"      {col += yyleng; return SEMICOLON;}
":"      {col += yyleng; return COLON;}
","      {col += yyleng; return COMMA;}
"("      {col += yyleng; return L_PAREN;}
")"      {col += yyleng; return R_PAREN;}
"["      {col += yyleng; return L_SQUARE_BRACKET;}
"]"      {col += yyleng; return R_SQUARE_BRACKET;}
":="     {col += yyleng; return ASSIGN;}
##.*     col++;
[ ]      col++;
[\t]     col++;
[\n]     {row++;col=1;}

.     {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", row, col, yytext);}

%%
