parse: phase3.lex phase3.yy
	bison -v -d --file-prefix=y phase3.yy
	flex phase3.lex
	g++ -std=c++11 -o parser y.tab.cc  lex.yy.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.o parser

CFLAGS = -g -Wall -ansi -pedantic