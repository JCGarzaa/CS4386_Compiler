main: lex.yy.c parser.tab.c structs.h
	gcc lex.yy.c parser.tab.c structs.h -o main -lfl
parser.tab.c: parser.y
	bison -d parser.y
lex.yy.c: lexer.l
	flex lexer.l
clean: 
	rm main lex.yy.c parser.tab.c parser.tab.h
