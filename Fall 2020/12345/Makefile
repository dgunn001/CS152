parse: phase2.lex phase2.y
    bison -v -d --file-prefix=y phase2.y
    flex phase2.lex
    gcc -o phase2 y.tab.c lex.yy.c -lfl

clean:
    rm -f lex.yy.c y.tab.* y.output *.o phase2