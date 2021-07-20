


%{
#include <stdio.h>
#include <stdlib.h>

//INNCLUDE THE HEADER FILE FOR SOMETHING I FORGOT BUT WILL FIN LATER ITS IN MY NOTES SORDA AADUWGHBDYUHAWGDWIAUDHGAWIUDGWAID
// #include "HEADER FILE"
        //BISON FILE
#include "y.tab.h"

 extern const char* yytext;
 extern int row;
 extern int col;
 void yyerror(const char *msg);
 int yylex();
%}

%union{
                char* cval;
                int ival;
}


%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD
%nonassoc UMINUS
%token <int> NUMBER
%token <cval> IDENT
%token L_SQUARE_BRACKET R_SQUARE_BRACKET COLON COMMA L_PAREN  R_PAREN SEMICOLON
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN
%start program

%%

program: /* epsilon */ {printf("program -> epsilon\n");}
        |program function {printf("program -> function\n");}
        ;

function: FUNCTION identifier SEMICOLON BEGIN_PARAMS declaration-loop END_PARAMS BEGIN_LOCALS declaration-loop END_LOCALS BEGIN_BODY statement-loop END_BODY {printf("function -> FUNCTION identifier SEMICOLON BEGINPARAMS declaration-loop ENDPARAMS BEGINLOCALS declaration-loop ENDLOCALS BEGIN_BODY statement-loop ENDBODY \n" );}
                  ;





expression-loop2: /* epislon */  {printf("expression-loop2 -> epislon\n");}
                                | expression {printf("expression-loop2 -> expression\n");}
                                | expression-loop2 expression COMMA  {printf("expression-loop2 -> expression-loop2 expression COMMA\n");}




declaration-loop: /* epsilon */ {$$.code = "";}
                                | declaration SEMICOLON declaration-loop  
                                {	
                                	{$$.code = $1.code + 

                                }
                                ;




id-loop: /* epislon */ {printf("id-loop -< epislon\n");}
        |identifier {printf("id-loop -> identifier\n");}
        | id-loop identifier COMMA  {printf("id-loop -> id-loop identifier COMMA\n");}
        ;




var-loop:   /* epsilon */ {printf("var-loop -> epsilon\n");}
            | var {printf("var-loop -> var\n");}
            | var-loop var COMMA {printf("var-loop -> var-loop var COMMA\n");}
                ;
statement-loop:           /* epsilon */ {printf("statement-loop -> epsilon\n");}
                          | statement SEMICOLON {printf("statement-loop -> statement SEMICOLON\n");}
                          | statement-loop statement SEMICOLON  {printf("statement-loop -> statement-loop statement SEMICOLON \n");}

identifier: IDENT {printf("identifier -> IDENT %s\n",yytext);}
            ;

number:
    NUMBER {printf("number -> NUMBER %s\n",yytext);}
    ;




    declaration: id-loop COLON INTEGER {printf("declaration -> id-loop COLON INTEGER\n");}
                         | id-loop COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER  {printf("declaration -> id-loop COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET\n" );}
                         | id-loop COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER {printf("declaration -> id-loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
                         ;











statement: var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}

             | IF bool-exp THEN statement-loop ENDIF {printf("statement -> IF bool-exp THEN statement-loop ENDIF\n");}

             | IF bool-exp THEN statement-loop ELSE statement-loop ENDIF {printf("statement -> IF bool-exp THEN statement-loop  ELSE statement-loop  ENDIF\n");}

             | WHILE bool-exp BEGINLOOP statement-loop  ENDLOOP { printf("statement -> WHILE bool-exp BEGINLOOP statement-loop  ENDLOOP\n");}

             | DO BEGINLOOP statement-loop ENDLOOP WHILE bool-exp {printf("statement -> DO BEGINLOOP statement-loop ENDLOOP WHILE bool-exp\n");}

             | FOR var ASSIGN number SEMICOLON bool-exp SEMICOLON var ASSIGN expression BEGINLOOP statement-loop ENDLOOP {printf("statement -> FOR var ASSIGN number SEMICOLON bool-exp SEMICOLON var ASSIGN expression BEGINLOOP statement-loop ENDLOOP\n");}

             | READ var-loop {printf("statement -> READ var-loop\n");}

             | WRITE var-loop {printf("statement -> WRITE var-loop\n");}

             | CONTINUE {printf("statement -> CONTINUE\n");}

             | RETURN expression {printf("statement -> return expression\n");}
                 ;


bool-exp: relation-and-expr {printf("bool-exp -> relation-expr\n");} //or loop im confused on we need to make it that it can do relation-and-e or rae or rae or rae rn its just
                | relation-and-expr OR bool-exp { printf("bool-exp -> relation-and-expr OR bool-exp\n");}//rae; rar or rae;
                ;




                          ;
relation-and-expr: relation-expr {printf("relation-and-expr -> relation-expr\n");}          //same loop thing with the or from bool i dont think this will covver the multiple and
                | relation-expr AND relation-and-expr  {printf("relation-and-expr -> relation-and-expr AND relation-expr\n");}
                ;






relation-expr: NOT expression comp expression {printf("relation-expr -> NOT expression comp expression\n");}
                         | NOT TRUE {printf("relation-expr -> NOT TRUE\n" );}

                         | NOT FALSE {printf("relation-expr -> NOT FALSE\n");}

                         | NOT L_PAREN bool-exp R_PAREN {printf("relation-expr -> NOT L_PAREN bool-exp R_PAREN\n");}

                         | expression comp expression {printf("relation-expr -> expression comp expression\n");}

                         | TRUE {printf("relation-expr -> TRUE\n");}

                         | FALSE {printf("relation-expr -> FALSE\n");}

                         | L_PAREN bool-exp R_PAREN {printf("relation-expr -> L_PAREN bool-exp R_PAREN\n");}

                         ;

comp:  EQ {printf("comp -> EQ\n");}
        | NEQ {printf("comp -> NEQ\n");}
        | LT {printf("comp -> LT\n");}
        | GT {printf("comp -> GT\n");}
        | LTE {printf("comp -> LTE\n");}
        | GTE {printf("comp -> GTE\n");}
        ;




expression: multiplicative-expr{ printf("expression -> multiplicative-expr\n");}
        |   multiplicative-expr ADD expression{printf("expression -> expression ADD multiplicative-expr\n");} //samme problem iwth the add add add add as before
        |   multiplicative-expr SUB expression {printf("expression -> expression SUB multiplicative-expr\n");}
        ;






multiplicative-expr:                      term {printf("multiplicative-expr -> term\n");}
                                          | term MOD multiplicative-expr   {printf("multiplicative-expr ->multiplicative-expr mod term\n");}          //same problme
                                          | term DIV multiplicative-expr   {printf("multiplicative-expr ->multiplicative-expr div term\n");}
                                          | term MULT multiplicative-expr  {printf("multiplicative-expr ->multiplicative-expr MULT term\n");}
                                        ;







term: UMINUS var {printf("term -> UMINUS var\n");}

        | UMINUS number{printf("term -> UMINUS number\n");}

        | UMINUS L_PAREN expression R_PAREN{printf("term -> UMINUS L_PAREN  expression R_PAREN \n"); }

        | var {printf("term -> var\n");}

        | number{ printf("term -> number \n");}

        | L_PAREN expression R_PAREN{printf("term -> L_PAREN expression R_PAREN \n"); }

        | identifier L_PAREN expression-loop2 R_PAREN{printf("term -> ident L_PAREN expression R_PAREN \n");}

        ;


var:    identifier { printf("var-> IDENT\n"); }
        | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET{ printf("var -> IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET \n"); }
        | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET L_SQUARE_BRACKET expression R_SQUARE_BRACKET  {printf("var -> IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET L_SQUARE_BRACKET expression R_SQUARE_BRACKET  \n");}
        ;

%%

int main(int argc, char ** argv)
{
        yyparse();
        return 0;
}

void yyerror (const char *s)
{

        printf("At symbol: %s \n Error: row %d, col %d: Error Message: %s\n", yytext, row, col,s);
}

