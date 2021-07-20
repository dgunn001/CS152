 


%{
#include <stdio.h>
#include <stdlib.h>

//INNCLUDE THE HEADER FILE FOR SOMETHING I FORGOT BUT WILL FIN LATER ITS IN MY NOTES SORDA AADUWGHBDYUHAWGDWIAUDHGAWIUDGWAID
// #include "HEADER FILE"
        //BISON FILE
#include "y.tab.h"
#include <list>
#include <string>
#include <functional>
#include <sstream>
#include <map>
#include <regex>
#include <set>
using namespace std;
struct dec_type{
        string code;
        list<string> ids;
    };
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
%token <string> IDENT
%token L_SQUARE_BRACKET R_SQUARE_BRACKET COLON COMMA L_PAREN  R_PAREN SEMICOLON
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN




%type <string> program function identifier statement-loop
%type <dec_type> declaration-loop declaration
%type <list<string>> id-loop



%start start_prog
%%


start_prog: program {cout<<$1<<endl;}
                    ;

program: /* epsilon */ {$$ = "";}
                        | program function {$$ = $1 + "\n" + $2;}
        ;

function: FUNCTION identifier SEMICOLON BEGIN_PARAMS declaration-loop END_PARAMS BEGIN_LOCALS declaration-loop END_LOCALS BEGIN_BODY statement-loop END_BODY 
                    {


                            $$ = "func " + $2 + "\n";
                            $$ += $5.code;
                            int i = 0;
                            for(list<string>::iterator it = $5.ids.begin(); it != $5.ids.end(); it++){
                                $$ += *it + " $" + to_string(i) + "\n";
                                i++;
                            }
                            $$ += $8.code;
                            $$ += $11;
                            $$ += "endfunc";
                        
                    }
                    ;





expression-loop2: /* epislon */  {printf("expression-loop2 -> epislon\n");}
                                | expression {printf("expression-loop2 -> expression\n");}
                                | expression-loop2 expression COMMA  {printf("expression-loop2 -> expression-loop2 expression COMMA\n");}




declaration-loop: /* epsilon */ {$$.code = ""; $$.ids = list<string>();}
                                | declaration SEMICOLON declaration-loop 
                                    {   $$.code = $1.code + "\n" + $3.code;
                                        $$.ids = $1.ids;
                                        for(list<string>::iterator it = $3.ids.begin(); it != $3.ids.end(); it++){
                                            $$.ids.push_back(*it);
                                        }
                                    }
                                ;




id-loop: identifier {$$.push_back($1);}
        |  identifier COMMA id-loop {$$ = $3; $$.push_front($1);}
        ;




var-loop:   /* epsilon */ {printf("var-loop -> epsilon\n");}
            | var {printf("var-loop -> var\n");}
            | var-loop var COMMA {printf("var-loop -> var-loop var COMMA\n");}
                ;
statement-loop:           /* epsilon */ {printf("statement-loop -> epsilon\n");}
                          | statement SEMICOLON {printf("statement-loop -> statement SEMICOLON\n");}
                          | statement-loop statement SEMICOLON  {printf("statement-loop -> statement-loop statement SEMICOLON \n");}

identifier: IDENT {$$ = $1;}
            ;






declaration: id-loop COLON INTEGER 
                                {    
                                    for(list<string>::iterator it = $1.begin(); it != $1.end(); it++){
                                                $$.code += ". " + *it + "\n";
                                                $$.ids.push_back(*it);
                                    }
                                }
                         

                        | id-loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
                                {
                                    for(list<string>::iterator it = $1.begin(); it != $1.end(); it++){
                                            $$.code += ".[] " + *it + ", " + to_string($5) +"\n";
                                            $$.ids.push_back(*it);
                                    }   
                                 }
                         

                         | id-loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> id-loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
                         ;











statement: var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}

             | IF bool-exp THEN statement-loop ENDIF {printf("statement -> IF bool-exp THEN statement-loop ENDIF\n");}

             | IF bool-exp THEN statement-loop ELSE statement-loop ENDIF {printf("statement -> IF bool-exp THEN statement-loop  ELSE statement-loop  ENDIF\n");}

             | WHILE bool-exp BEGINLOOP statement-loop  ENDLOOP { printf("statement -> WHILE bool-exp BEGINLOOP statement-loop  ENDLOOP\n");}

             | DO BEGINLOOP statement-loop ENDLOOP WHILE bool-exp {printf("statement -> DO BEGINLOOP statement-loop ENDLOOP WHILE bool-exp\n");}

             | FOR var ASSIGN NUMBER SEMICOLON bool-exp SEMICOLON var ASSIGN expression BEGINLOOP statement-loop ENDLOOP {printf("statement -> FOR var ASSIGN number SEMICOLON bool-exp SEMICOLON var ASSIGN expression BEGINLOOP statement-loop ENDLOOP\n");}

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

        | UMINUS NUMBER{printf("term -> UMINUS number\n");}

        | UMINUS L_PAREN expression R_PAREN{printf("term -> UMINUS L_PAREN  expression R_PAREN \n"); }

        | var {printf("term -> var\n");}

        | NUMBER{ printf("term -> number \n");}

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

