CC = g++ -std=c++11

all: lex.yy.c
	$(CC) lex.yy.c -ll -o mylex

lex.yy.c: program.l
	lex program.l
remove:
	rm mylex;rm lex.yy.c