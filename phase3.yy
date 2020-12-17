
%{
%}

%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define api.token.constructor
%define api.value.type variant
%define parse.error verbose
%locations

%code requires
{
        /* you may need these header files
         * add more header file if you need more
         */
#include <list>
#include <string>
#include <functional>
#include <vector>
using namespace std;
 extern int row;
 extern int col;
 

        /* define the sturctures using as types for non-terminals */
    struct dec_type{
                string code;
                list<string> ids;
        };
    struct var_type{
                string code;
                string code2;
                bool is_array;
                bool is_2d;
                string arrayName;
                string id;
                bool is_number;
                bool is_param;
                
    };
    struct boolexpr_type{
                string code;
                string id;
                string label;
    };

        /* end the structures for non-terminal types */

}


%code
{
#include "y.tab.hh"
struct tests
{
        string name;
        yy::location loc;
};

        /* you may need these header files
         * add more header file if you need more
         */
#include <sstream>
#include <map>
#include <regex>
#include <set>
yy::parser::symbol_type yylex();
void yyerror(const char *msg);
int labelCount = 0;
int tempCount = 0;
string newLabel(){
        string label = "__label__";
        label += to_string(labelCount);
        labelCount ++;
        return label;
      }
string newTemp(){
      string temp = "__temp__";
      temp += to_string(tempCount);
      tempCount ++;
      return temp;
    }        

}



%token END 0 "end of file";

%token <string> IDENT
%token <int> NUMBER
%token L_SQUARE_BRACKET R_SQUARE_BRACKET COLON COMMA L_PAREN  R_PAREN SEMICOLON
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN


%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD
%right UMINUS
%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left L_PAREN R_PAREN

%type <string> program function identifier 
%type <dec_type> declaration-loop declaration comp 
%type <list<string>> id-loop
%type <var_type> term var var-loop
%type <boolexpr_type> bool-exp relation-and-expr relation-expr statement-loop statement expression expression-loop2 multiplicative-expr statement-loop3




%start start_prog
%%


start_prog: program {cout<<$1<<endl;}
                    ;

program: /* epsilon */ {$$ = "";}
                        | program function {$$ = $1 + "\n" + $2;}
        ;

function: FUNCTION identifier SEMICOLON BEGIN_PARAMS declaration-loop END_PARAMS BEGIN_LOCALS declaration-loop END_LOCALS BEGIN_BODY statement-loop3 END_BODY
                    {


                            $$ = "func " + $2 + "\n";
                            $$ += $5.code;
                            int i = 0;
                            for(list<string>::iterator it = $5.ids.begin(); it != $5.ids.end(); it++){
                                $$ += "= " + *it + ", $" + to_string(i) + "\n";
                                i++;
                            }
                            
                            $$ += $8.code;
                            
                            $$ += $11.code;

                    }
                    ;





declaration-loop: /* epsilon */ {$$.code = ""; $$.ids = list<string>();}
                                | declaration SEMICOLON declaration-loop
                                    {   $$.code = $1.code + "\n" + $3.code;
                                        $$.ids = $1.ids;
                                        for(list<string>::iterator it = $3.ids.begin(); it != $3.ids.end(); it++){
                                            $$.ids.push_back(*it);
                                        }
                                    }
                                ;

declaration: id-loop COLON INTEGER
                                {
                                    for(list<string>::iterator it = $1.begin(); it != $1.end(); it++){
                                                $$.code += ". " + *it;
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

//double check
                         | id-loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
                         {

                            for(list<string>::iterator it = $1.begin(); it != $1.end(); it++){
                                            $$.code += ".[] " + *it + ", " + to_string($5) + "[] " + to_string($8) + "\n";
                                            $$.ids.push_back(*it);
                                    }


                         }
                         ;


id-loop: identifier {$$.push_back($1);}
        |  identifier COMMA id-loop {$$ = $3; $$.push_front($1);}
        ;

identifier: IDENT {$$ = $1;}
            ;




statement-loop3: statement SEMICOLON statement-loop3
                  {
                    $$.code = $1.code + $3.code;
                  }
                | 
                  {
                    $$.code = "endfunc\n";
                  }





statement: var ASSIGN expression 
              {
                if($1.is_array){
                  $$.code = $1.code;
                  $$.code += $3.code;
                  $$.code += "=[] " + $1.arrayName + ", " + $1.id; + ", " + $3.id + "\n";   // =[] destination, srs, index =[]arrayName, expresion , arrayindex
                }
                //else if($1.is_array && $1.is_2d){ //2d array

               // }
                else{ //normal variable     = dst, src
                    $$.code = $3.code;
                    $$.code += "= " + $1.id + ", " + $3.code +  "\n"; 
                }
              }

             
             | IF bool-exp THEN statement-loop ENDIF 
             {
                
                string truefalse = newLabel();
                string branchLocation = newLabel();
                $$.code = $2.code;
                $$.code += "?:= " + truefalse + ", " + $2.id + "\n"; //if predicate is true go to label
                $$.code += ":= " + branchLocation + "\n";             //go to label
                $$.code += ": " + truefalse + "\n";
                $$.code += $4.code;
                $$.code += ": " + branchLocation + "\n";
             
             }

             | IF bool-exp THEN statement-loop ELSE statement-loop ENDIF 
             {
                string label1 = newLabel();
                string label2 = newLabel();
                $$.code = $2.code;
                $$.code += "?:= " + label1 + ", " + $2.id + "\n";
                $$.code += ":= " + label2 + "\n";
                $$.code += ": " + label1 + "\n";
                $$.code += $4.code;
                $$.code += ": " + label2 + "\n";
                $$.code += $6.code;
                
            }

             | WHILE bool-exp BEGINLOOP statement-loop  ENDLOOP { printf("statement -> WHILE bool-exp BEGINLOOP statement-loop  ENDLOOP\n");}

             | DO BEGINLOOP statement-loop ENDLOOP WHILE bool-exp {printf("statement -> DO BEGINLOOP statement-loop ENDLOOP WHILE bool-exp\n");}

             | FOR var ASSIGN NUMBER SEMICOLON bool-exp SEMICOLON var ASSIGN expression BEGINLOOP statement-loop ENDLOOP {printf("statement -> FOR var ASSIGN number SEMICOLON bool-exp SEMICOLON var ASSIGN expression BEGINLOOP statement-loop ENDLOOP\n");}

             | READ var-loop 
              {
                $$.code = $2.code;
                size_t found = $2.id.find(" ");
                
                if(found == string::npos){
                    if($2.is_array){
                      $$.code += ".[]< " + $2.arrayName + ", " + $2.code + "\n";
                      $$.id = $2.id; 
                    }
                    else{
                      $$.code += ".< " + $2.id + "\n";
                      $$.id = $2.id;
                    }
                }
                else{
                    
                    int spaceindex = 0;
                    string list = $2.id;
                    vector<string> v;
                    

                    while(found != string::npos)
                    {
                      found = list.find(" ");
                      v.push_back(list.substr(0,found));
                      list.erase(0,found+1);
                    }
                    $$.code = ".< " + v.at(0) + "\n";
                    for(int i = 1; i < v.size(); ++i){
                      $$.code += ".< " + v.at(i) + "\n";
                    }
                  }

                }
                
              

             | WRITE var-loop               {
                $$.code = $2.code;
                size_t found = $2.id.find(" ");
                
                if(found == string::npos){
                    if($2.is_array){
                      $$.code += ".[]> " + $2.arrayName + ", " + $2.code + "\n";
                      $$.id = $2.id; 
                    }
                    else{
                      $$.code += ".> " + $2.id + "\n";
                      $$.id = $2.id;
                    }
                }
                else{
                    
                    int spaceindex = 0;
                    string list = $2.id;
                    vector<string> v;
                    

                    while(found != string::npos)
                    {
                      found = list.find(" ");
                      v.push_back(list.substr(0,found));
                      list.erase(0,found+1);
                    }
                    $$.code = ".> " + v.at(0) + "\n";
                    for(int i = 1; i < v.size(); ++i){
                      $$.code += ".> " + v.at(i) + "\n";
                    }
                  }

                }

             | CONTINUE 
              {
                  string label = newLabel();
                  $$.code = ":= " + label + "\n";
                  $$.label = label;
                  $$.id = label;        
              }

             | RETURN expression 
              {
                $$.code = $2.code;
                $$.code += "ret " + $2.id + "\n";
              }
                 ;

statement-loop:           statement SEMICOLON statement-loop 
                          {
                            $$.code = $1.code + $3.code;
                            
                            if($1.label.length() > 0){
                              $$.label = $1.label;
                            }
                            else{
                              $$.label = $3.label;
                            }
                          }
                          

                          | statement SEMICOLON 
                            {
                              $$.code = $1.code;
                              $$.id = $1.id;
                              
                              if($1.label.length() > 0){
                                $$.label = $1.label;
                              }
                              else{
                                $$.label = "";
                              }

                            }



var-loop:   var //id name code is index 
                //.[]< dst, index
                  {
                    if($1.is_array){
                      $$.code = $1.code;
                      $$.id = $1.id;
                      $$.is_array = $1.is_array;
                      $$.arrayName = $1.arrayName;
                    }
                    else{
                      $$.code = $1.code;
                      $$.id = $1.id;
                      $$.is_array = 0;
                    }
                  }
            |  var COMMA var-loop
                  {
                    $$.id = $1.id + " " + $3.id;
                  }
                ;

bool-exp:       relation-and-expr 
                {
                  $$.code = $1.code;
                  $$.id = $1.id;
                }
                
                | relation-and-expr OR bool-exp 
                  { //|| dst, src1, src2 
                   string temp = newTemp();
                   $$.code = $1.code + $3.code;
                   $$.code += ". " + temp + "\n";
                   $$.code += "|| " + temp + ", " + $1.id + ", " + $3.id + "\n";
                   $$.id = temp;
                  }
                ;

relation-and-expr: relation-expr 
                    {
                        $$.code = $1.code;
                        $$.id = $1.id;
                    }          
                | relation-expr AND relation-and-expr  
                    {
                      string temp = newTemp();  //&& dst, src1, src2
                      $$.code = $1.code + $3.code;
                      $$.code += ". " + temp + "\n";
                      $$.code += "&& " + temp + ", " + $1.id + ", " + $3.id + "\n";
                      $$.id = temp;
                    }
                ;


relation-expr:           expression comp expression 
                            {
                              string temp = newTemp();
                              $$.code = $1.code + $3.code;
                              $$.code += ". " + temp + "\n";
                              $$.code += $2.code + " " + temp + ", " + $1.id + ", " + $3.id + "\n";
                              $$.id = temp;
                            }

                         | TRUE 
                            {
                              $$.code = "";
                              $$.id = "1";
                            }

                         | FALSE 
                            {
                              $$.code = "";
                              $$.id = "0";
                            }

                         | L_PAREN bool-exp R_PAREN 
                         {
                            $$.code = $2.code;
                            $$.id = $2.id;
                         }
                         | NOT expression comp expression 
                            {
                              string temp = newTemp();
                              $$.code = $2.code + $4.code;
                              $$.code += "!. " + temp + "\n";
                              $$.code += $3.code + " " + temp + $2.id + ", " + $4.id + "\n"; //< dst, src1, src2
                              $$.id = temp;
                            }
                         | NOT TRUE 
                            {
                              $$.code = "";
                              $$.id = "!1";
                            }

                         | NOT FALSE 
                            {
                              $$.code = "";
                              $$.id = "!0";
                            }

                         | NOT L_PAREN bool-exp R_PAREN 
                         {//! dst, src
                            $$.id = "! " + $3.id;
                            $$.code = $3.code;
                         }

                         ;

comp:  EQ {$$.code = "==";}
        | NEQ {$$.code = "<>";}
        | LT {$$.code = "<";}
        | GT {$$.code = ">";}
        | LTE {$$.code = "<=";}
        | GTE {$$.code = ">=";}
        ;



expression:         multiplicative-expr
                    {
                        $$.code = $1.code;
                        $$.id = $1.id;
                    }

                |   multiplicative-expr ADD expression
                    {
                        string temp = newTemp();
                        $$.code = $1.code + $3.code;
                        $$.code += ". " + temp + "\n";       
                        $$.code += "+ " + temp + ", " + $1.id + ", " + $3.id + "\n";    //+ dst, src1, src2
                        $$.id = temp;
                    }

                |   multiplicative-expr SUB expression
                    {
                        string temp = newTemp();
                        $$.code = $1.code + $3.code;
                        $$.code += ". " + temp + "\n";       
                        $$.code += "- " + temp + ", " + $1.id + ", " + $3.id + "\n";    //+ dst, src1, src2
                        $$.id = temp;
                    }
                ;




multiplicative-expr:                      term
                                          {
                                            if($1.code.length() > 0){

                                              if($1.is_array){
                                                string temp = newTemp();
                                                $$.code = $1.code;
                                                $$.code += ". " + temp + "\n";
                                                $$.code += "=[] " + temp + ", " + $1.arrayName + ", " + $1.id + "\n";
                                                $$.id = temp;
                                              }
                                              else if ($1.is_param){
                                                $$.code = $1.code;
                                                $$.id = $1.id;
                                              }
                                              else{
                                                string temp2 = newTemp();
                                                $$.code = ". " + temp2 + "\n";
                                                $$.code += "= " + temp2 + ", " + $1.id + "\n";
                                                $$.id = temp2;

                                              }

                                            }
                                            
                                            else{
                                              string temp2 = newTemp();
                                              $$.code = ". " + temp2 + "\n";
                                              $$.code += "= " + temp2 + ", " + $1.id + "\n";
                                              $$.id = temp2;
                                            }    

                                          }

                                          | term MOD multiplicative-expr
                                          {
                                            $$.code = $1.code + $3.code;
                                            string temp3 = newTemp();
                                            $$.code += ". " + temp3 + "\n";
                                            $$.code += "% " + temp3 + ", " + $1.id + ", " + $3.id + "\n";
                                            $$.id = temp3;
                                          }

                                          | term DIV multiplicative-expr
                                          {
                                            $$.code = $1.code + $3.code;
                                            string temp4 = newTemp();
                                            $$.code += ". " + temp4 + "\n";
                                            $$.code += "/ " + temp4 + ", " + $1.id + ", " + $3.id + "\n";
                                            $$.id = temp4;
                                          }

                                          | term MULT multiplicative-expr
                                          {
                                            $$.code = $1.code + $3.code;
                                            string temp5 = newTemp();
                                            $$.code += ". " + temp5 + "\n";
                                            $$.code += "* " + temp5 + ", " + $1.id + ", " + $3.id + "\n";
                                            $$.id = temp5;
                                          }
                                        ;




term: SUB var 
        {
          $$.id = "- " + $2.id + "\n";
          $$.is_number = 0;
          $$.is_array = $2.is_array;
          $$.is_2d = $2.is_2d;
          $$.arrayName = $2.arrayName;

        }

        | SUB NUMBER
        {
          $$.id = "- " + to_string($2) + "\n";
          $$.code = "";
          $$.is_number = 1;
          $$.is_array = 0;
        }

        | SUB L_PAREN expression R_PAREN
        {
          $$.code = $3.code;
          $$.id = "- "+ $3.id + "\n"; 
          $$.is_number = 0;
          $$.is_array = 0;
        }

        | var 
        {
          $$.id = $1.id;
          $$.is_number = 0;
          $$.is_array = $1.is_array;
          $$.is_2d = $1.is_2d;
          $$.arrayName = $1.arrayName;
        }

        | NUMBER
        { 
          $$.code = "";
          $$.id = to_string($1);
          $$.is_number = 1;
          $$.is_array = 0;
        }

        | L_PAREN expression R_PAREN
        {
          $$.code = $2.code;
          $$.id = $2.id; 
          $$.is_number = 0;
          $$.is_array = 0;
        }

        | identifier L_PAREN expression-loop2 R_PAREN
        {

          $$.code = $3.code;
          string temp = newTemp();
          $$.code += "param " + $3.id + "\n";
          $$.code += ". " + temp + "\n";
          $$.code += "call " + $1 + ", " + temp + "\n";
          $$.id = temp;
          $$.is_number = 0;
          $$.is_array = 0;
          $$.is_param = 1;

        }

        ;

expression-loop2:  expression COMMA expression-loop2 
                    {
                      $$.code = $1.code + $3.code;

                    }
                    | expression 
                    {
                      $$.code = $1.code;
                      $$.id = $1.id;
                    }
                    | {
                      $$.code = "";
                      $$.id = "";
                    }

                  ;




var:        identifier //id name code is index
            {
                $$.code = "";
                $$.id = $1 ;
                $$.is_array = 0;
            }

        | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET
            {   
               $$.arrayName = $1;
               $$.id = $3.id;
               $$.is_array = 1;
               $$.code = $3.code;
            }

        | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET L_SQUARE_BRACKET expression R_SQUARE_BRACKET
            {   
               $$.is_array = 1;
               $$.is_2d = 1; 
               $$.code = $3.code;
               $$.code2 = $6.code;
            }
        ;

%%

int main(int argc, char *argv[])
{
        yy::parser p;
        return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m)
{
        std::cerr << l << ": " << m << std::endl;
}
