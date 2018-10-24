.PHONEY: all parser goyacc

all: parser.go

parser.go: parser.y
	make parser

parser: goyacc
	bin/goyacc -o /dev/null parser.y
	bin/goyacc -o parser.go parser.y 2>&1 | egrep "(shift|reduce)/reduce" | awk '{print} END {if (NR > 0) {print "Find conflict in parser.y. Please check y.output for more information."; exit 1;}}'
	rm -f y.output

	@if [ $(ARCH) = $(LINUX) ]; \
	then \
		sed -i -e 's|//line.*||' -e 's/yyEofCode/yyEOFCode/' parser.go; \
	elif [ $(ARCH) = $(MAC) ]; \
	then \
		/usr/bin/sed -i "" 's|//line.*||' parser.go; \
		/usr/bin/sed -i "" 's/yyEofCode/yyEOFCode/' parser.go; \
	fi

	@awk 'BEGIN{print "// Code generated by goyacc"} {print $0}' parser.go > tmp_parser.go && mv tmp_parser.go parser.go;

goyacc:
	go build -o bin/goyacc goyacc/main.go
