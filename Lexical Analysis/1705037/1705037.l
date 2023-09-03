%option noyywrap

%x STRINGSTATE
%x COMMENTSTATE

%{
#include<bits/stdc++.h>
#include "symbolTable.h"
using namespace std;

ofstream tokenFile("1705037_token.txt");

int line_count=1;
int errorcount = 0;
int strlineno=0;
SymbolTable *st = new SymbolTable(7);

string text = "";
string orgtext = "";

%}
delim (\\[nt\'\"afrbv0])
ws [ \t\v\r]+
digit [0-9]
integer {digit}+
decimal \.{digit}+
exp [Ee][+-]?{digit}+
float {integer}{decimal}?{exp}?
number {integer}|{float}
numbererr1 {integer}{decimal}{decimal}+
numbererr2 ({integer}{exp}({decimal}|{exp})+)|({integer}\.)
letter [a-zA-Z]
any [^\n\t\v\a\f\r\b\0\'\"\\]|{delim}
char \'{any}\'
multichar \'({any}|[ ])({any}|[ ])+\'
emptychar \'\'
nonchar (\'{any})|(\') 
addop [+-]
mulop [*/%]
incop \+\+|\-\-
relop <|<=|>|>=|==|!=
assignop =
logicop &&|\|\|
not !
LPAREN \(
RPAREN \)
LCURL \{
RCURL \}
LTHIRD \[
RTHIRD \]
COMMA \,
SEMICOLON \;

identifier [a-zA-Z_][a-zA-Z_0-9]*
non_identifier ({number}[a-zA-Z_]+)|({integer}\.[a-zA-Z_]+)
any_ws {any}|[ ]
multiline .*(\\\n.*)*
string \"[^\"\n\r\t\\\']*



sl_comment \/\/{multiline}
comment \/\*
noncomment \/\*((\n)*.*)*




%%
{ws} {}
[\n] {line_count++;}

if {
outputFile << "\nLine no "<< line_count <<": Token <IF> Lexeme if found\n";
cout << "\nLine no "<< line_count <<": Token <IF> Lexeme if found\n";
tokenFile << "<IF> ";
}
for {
outputFile << "\nLine no "<< line_count <<": Token <FOR> Lexeme for found\n";
cout << "\nLine no "<< line_count <<": Token <FOR> Lexeme for found\n";
tokenFile << "<FOR> ";
}

do {
outputFile << "\nLine no "<< line_count <<": Token <DO> Lexeme do found\n";
cout << "\nLine no "<< line_count <<": Token <DO> Lexeme do found\n";
tokenFile << "<DO> ";
}

int {
outputFile << "\nLine no "<< line_count <<": Token <INT> Lexeme int found\n";
cout << "\nLine no "<< line_count <<": Token <INT> Lexeme int found\n";
tokenFile << "<INT> ";
}

float {
outputFile << "\nLine no "<< line_count <<": Token <FLOAT> Lexeme float found\n";
cout << "\nLine no "<< line_count <<": Token <FLOAT> Lexeme float found\n";
tokenFile << "<FLOAT> ";
}

void {
outputFile << "\nLine no "<< line_count <<": Token <VOID> Lexeme void found\n";
cout << "\nLine no "<< line_count <<": Token <VOID> Lexeme void found\n";
tokenFile << "<VOID> ";
}

switch {
outputFile << "\nLine no "<< line_count <<": Token <SWITCH> Lexeme switch found\n";
cout << "\nLine no "<< line_count <<": Token <SWITCH> Lexeme switch found\n";
tokenFile << "<SWITCH> ";
}

default {
outputFile << "\nLine no "<< line_count <<": Token <DEFAULT> Lexeme default found\n";
cout << "\nLine no "<< line_count <<": Token <DEFAULT> Lexeme default found\n";
tokenFile << "<DEFAULT> ";
}

else {
outputFile << "\nLine no "<< line_count <<": Token <ELSE> Lexeme else found\n";
cout << "\nLine no "<< line_count <<": Token <ELSE> Lexeme else found\n";
tokenFile << "<ELSE> ";
}

while {
outputFile << "\nLine no "<< line_count <<": Token <WHILE> Lexeme while found\n";
cout << "\nLine no "<< line_count <<": Token <WHILE> Lexeme while found\n";
tokenFile << "<WHILE> ";
}

break {
outputFile << "\nLine no "<< line_count <<": Token <BREAK> Lexeme break found\n";
cout << "\nLine no "<< line_count <<": Token <BREAK> Lexeme break found\n";
tokenFile << "<BREAK> ";
}

char {
outputFile << "\nLine no "<< line_count <<": Token <CHAR> Lexeme char found\n";
cout << "\nLine no "<< line_count <<": Token <CHAR> Lexeme char found\n";
tokenFile << "<CHAR> ";
}

double {
outputFile << "\nLine no "<< line_count <<": Token <DOUBLE> Lexeme double found\n";
cout << "\nLine no "<< line_count <<": Token <DOUBLE> Lexeme double found\n";
tokenFile << "<DOUBLE> ";
}

return {
outputFile << "\nLine no "<< line_count <<": Token <RETURN> Lexeme return found\n";
cout << "\nLine no "<< line_count <<": Token <RETURN> Lexeme return found\n";
tokenFile << "<RETURN> ";
}

case {
outputFile << "\nLine no "<< line_count <<": Token <CASE> Lexeme case found\n";
cout << "\nLine no "<< line_count <<": Token <CASE> Lexeme case found\n";
tokenFile << "<CASE> ";
}

continue {
outputFile << "\nLine no "<< line_count <<": Token <CONTINUE> Lexeme continue found\n";
cout << "\nLine no "<< line_count <<": Token <CONTINUE> Lexeme continue found\n";
tokenFile << "<CONTINUE> ";
}



{integer} {
		cout << "\nLine no "<< line_count <<": Token <CONST_INT> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <CONST_INT> Lexeme "<< yytext <<" found\n";
		tokenFile << "<CONST_INT,"<< yytext << "> ";
		if(st->Insert(new SymbolInfo(yytext,"CONST_INT")))
		{
			st->printAllScopeTable();	
		}
	   }
{float} {
		cout << "\nLine no "<< line_count <<": Token <CONST_FLOAT> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <CONST_FLOAT> Lexeme "<< yytext <<" found\n";
		tokenFile << "<CONST_FLOAT,"<< yytext << "> ";
		if(st->Insert(new SymbolInfo(yytext,"CONST_FLOAT")))
		{
			st->printAllScopeTable();
		}
}
{numbererr1} {
		cout << "\nError at line no "<< line_count <<": Too many decimal points " << yytext << "\n";
		outputFile << "\nError at line no "<< line_count <<": Too many decimal points " << yytext << "\n";
		errorcount++;
}
{numbererr2} {
		cout << "\nError at line no "<< line_count <<": Ill formed number " << yytext << "\n";
		outputFile << "\nError at line no "<< line_count <<": Ill formed number " << yytext << "\n";
		errorcount++;
}
	   


{char} {
	string newyytext = "";
	for(int i=1;i<yyleng-1;i++) 
		{
			if(yytext[i]=='\\')
			{
				i++;
				if(yytext[i]=='n')
					newyytext += '\n';
				else if(yytext[i]=='t')
					newyytext += '\t';
				else if(yytext[i]=='r')
					newyytext += '\r';
				else if(yytext[i]=='\"')
					newyytext += '\"';
				else if(yytext[i]=='\'')
					newyytext += '\'';
				else
					newyytext += yytext[i];
				
				break;	
			}
			newyytext += yytext[i];
		}
		
	
	cout << "\nLine no "<< line_count <<": Token <CONST_CHAR> Lexeme "<< yytext <<" found --> <CHAR_CONST, " << newyytext << ">\n";
	outputFile << "\nLine no "<< line_count <<": Token <CONST_CHAR> Lexeme "<< yytext <<" found --> <CHAR_CONST, " << newyytext << ">\n";
	tokenFile << "<CONST_CHAR,"<< newyytext << "> ";
	if(st->Insert(new SymbolInfo(yytext,"CONST_CHAR")))
		{
			st->printAllScopeTable();
		}
	   }
{multichar} {
		cout<< "\nError at line no "<< line_count <<": Multi character constant error "<< yytext << "\n";
		outputFile<< "\nError at line no "<< line_count <<": Multi character constant error "<< yytext << "\n";
		errorcount++;
		}
{nonchar} {
		cout<< "\nError at line no "<< line_count <<": Unterminated character "<< yytext << "\n";
		outputFile<< "\nError at line no "<< line_count <<": Unterminated character "<< yytext << "\n";
		errorcount++;
		}
{emptychar} {
		cout<< "\nError at line no "<< line_count <<": Empty character constant error "<< yytext << "\n";
		outputFile<< "\nError at line no "<< line_count <<": Empty character constant error "<< yytext << "\n";
		errorcount++;
		}

{addop} {
		cout << "\nLine no "<< line_count <<": Token <ADDOP> Lexeme "<< yytext <<" found\n"; 
		outputFile << "\nLine no "<< line_count <<": Token <ADDOP> Lexeme "<< yytext <<" found\n";
		tokenFile << "<ADDOP,"<< yytext << "> "; 
	}
{mulop} { 
		cout << "\nLine no "<< line_count <<": Token <MULOP> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <MULOP> Lexeme "<< yytext <<" found\n";
		tokenFile << "<MULOP,"<< yytext << "> ";  
	}
	
{incop} { 
		cout << "\nLine no "<< line_count <<": Token <INCOP> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <INCOP> Lexeme "<< yytext <<" found\n";
		tokenFile << "<INCOP,"<< yytext << "> ";  
	}
{relop} { 
		cout << "\nLine no "<< line_count <<": Token <RELOP> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <RELOP> Lexeme "<< yytext <<" found\n";
		tokenFile << "<RELOP,"<< yytext << "> "; 
		
	}
{assignop} { 
		cout << "\nLine no "<< line_count <<": Token <ASSIGNOP> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <ASSIGNOP> Lexeme "<< yytext <<" found\n";
		tokenFile << "<ASSIGNOP,"<< yytext << "> "; 
	 }
{logicop} { 
		cout << "\nLine no "<< line_count <<": Token <LOGICOP> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <LOGICOP> Lexeme "<< yytext <<" found\n";
		tokenFile << "<LOGICOP,"<< yytext << "> ";  
	}

{not} { 
	cout << "\nLine no "<< line_count <<": Token <NOT> Lexeme "<< yytext <<" found\n";
	outputFile << "\nLine no "<< line_count <<": Token <NOT> Lexeme "<< yytext <<" found\n";
	tokenFile << "<NOT,"<< yytext << "> "; 
	}
{LPAREN} { 
		cout << "\nLine no "<< line_count <<": Token <LPAREN> Lexeme "<< yytext <<" found\n"; 
		outputFile << "\nLine no "<< line_count <<": Token <LPAREN> Lexeme "<< yytext <<" found\n";
		tokenFile << "<LPAREN,"<< yytext << "> "; 
	}
{RPAREN} { 
		cout << "\nLine no "<< line_count <<": Token <RPAREN> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <RPAREN> Lexeme "<< yytext <<" found\n";
		tokenFile << "<RPAREN,"<< yytext << "> "; 
	 }
{LCURL} { 
		cout << "\nLine no "<< line_count <<": Token <LCURL> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <LCURL> Lexeme "<< yytext <<" found\n";
		tokenFile << "<LCURL,"<< yytext << "> "; 
		st->enterScope(7);
	}
{RCURL} { 
		cout << "\nLine no "<< line_count <<": Token <RCURL> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <RCURL> Lexeme "<< yytext <<" found\n";
		tokenFile << "<RCURL,"<< yytext << "> "; 
		st->exitScope();
	}
{LTHIRD} { 
		cout << "\nLine no "<< line_count <<": Token <LTHIRD> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <LTHIRD> Lexeme "<< yytext <<" found\n";
		tokenFile << "<LTHIRD,"<< yytext << "> "; 
	}
{RTHIRD} { 
		cout << "\nLine no "<< line_count <<": Token <RTHIRD> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <RTHIRD> Lexeme "<< yytext <<" found\n";
		tokenFile << "<RTHIRD,"<< yytext << "> "; 
	 }
{COMMA} { 
		cout << "\nLine no "<< line_count <<": Token <COMMA> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <COMMA> Lexeme "<< yytext <<" found\n";
		tokenFile << "<COMMA,"<< yytext << "> "; 
	 }
{SEMICOLON} { 
		cout << "\nLine no "<< line_count <<": Token <SEMICOLON> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <SEMICOLON> Lexeme "<< yytext <<" found\n";
		tokenFile << "<SEMICOLON,"<< yytext << "> "; 
	}

{identifier} {
		cout << "\nLine no "<< line_count <<": Token <ID> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <ID> Lexeme "<< yytext <<" found\n";
		tokenFile << "<ID,"<< yytext << "> "; 
		if(st->Insert(new SymbolInfo(yytext,"ID")))
		{
			st->printAllScopeTable();
		}
	   }
{non_identifier} {
		cout << "\nError at line no "<< line_count <<": Invalid prefix on ID or invalid suffix on Number " << yytext <<"\n";
		outputFile << "\nError at line no "<< line_count <<": Invalid prefix on ID or invalid suffix on Number " << yytext <<"\n";
		errorcount++;
		}

{string} { text += yytext;
	   orgtext += yytext;
	   strlineno = line_count;
		
	BEGIN STRINGSTATE;
	}

<STRINGSTATE>\\[n] {
	text += '\n';
	orgtext += yytext;
}
<STRINGSTATE>\\[t] {
	text += '\t';
	orgtext += yytext;
}
<STRINGSTATE>\\[r] {
	text += '\r';
	orgtext += yytext;
}
<STRINGSTATE>\\\" {
	text += '\"';
	orgtext += yytext;
}
<STRINGSTATE>\\\' {
	text += '\'';
	orgtext += yytext;
}
<STRINGSTATE>[^\"\n\r\t\\\']* { text += yytext;
			orgtext += yytext;
	}

<STRINGSTATE>\" {
	orgtext += yytext;
	text += yytext;
	cout << "\nLine no "<< strlineno <<": Token <STRING> Lexeme "<< orgtext <<" found --> <STRING," << text << ">\n";
	outputFile << "\nLine no "<< strlineno <<": Token <STRING> Lexeme "<< orgtext <<" found --> <STRING," << text << ">\n";
	tokenFile << "<STRING,"<< text << "> "; 
	text = "";
	orgtext = "";
	strlineno = 0;
	BEGIN INITIAL;
}

<STRINGSTATE>\\\n {
	line_count++;
	orgtext += yytext;
}
<STRINGSTATE>\\\r {
	orgtext += yytext;
}
<STRINGSTATE>[\n\r] {
	
	orgtext += yytext;
	cout << "\nError at line no "<< strlineno <<": Unterminated String "<< orgtext ;
   	outputFile << "\nError at line no "<< strlineno <<": Unterminated String "<< orgtext ;
   	line_count++;
   	errorcount++;
   	text = "";
	orgtext = "";
	strlineno = 0;
	BEGIN INITIAL;
}



{sl_comment} {
	cout << "\nLine no "<< line_count <<": Token <COMMENT> Lexeme "<< yytext <<" found\n";
	outputFile << "\nLine no "<< line_count <<": Token <COMMENT> Lexeme "<< yytext <<" found\n";
	for(int i=0;i<yyleng;i++)
		{
			if(yytext[i]=='\n')
				line_count++;
	  	}
  	}
{comment} {
		text += yytext;
		strlineno = line_count;
		BEGIN COMMENTSTATE;
  	}


<COMMENTSTATE>\n {
	line_count++;
	text += yytext;
}
<COMMENTSTATE>\r\n {
	line_count++;
	text += yytext;
}

<COMMENTSTATE>.*\*\/ {
	text += yytext;
	cout << "\nLine no "<< strlineno <<": Token <COMMENT> Lexeme "<< text <<" found\n";
	outputFile << "\nLine no "<< strlineno <<": Token <COMMENT> Lexeme "<< text <<" found\n";
	
	text = "";
	orgtext = "";
	strlineno = 0;
	BEGIN INITIAL;
	
	
}
<COMMENTSTATE>.* {
		text += yytext;
	}
<COMMENTSTATE><<EOF>> {
	text += yytext;
	cout << "\nError at line no "<< strlineno <<": Unterminated Comment "<< text ;
   	outputFile << "\nError at line no "<< strlineno <<": Unterminated Comment "<< text ;
   	errorcount++;
   	
   	text = "";
	orgtext = "";
	strlineno = 0;
	
	st->printAllScopeTable();
	cout << "\nTotal lines: " << line_count-1 ;
	outputFile << "\nTotal lines: " << line_count-1 ; 
	cout << "\nTotal errors: " << errorcount ;
	outputFile << "\nTotal errors: " << errorcount ;
	
	
	return 0;
}





. {
   cout << "\nError at line no "<< line_count <<": Unrecognized character " << yytext << endl ;
   outputFile << "\nError at line no "<< line_count <<": Unrecognized character " << yytext << endl ;
   errorcount++;	
	}
<<EOF>> {
	st->printAllScopeTable();
	cout << "\nTotal lines: " << line_count-1 ;
	outputFile << "\nTotal lines: " << line_count-1 ; 
	cout << "\nTotal errors: " << errorcount ;
	outputFile << "\nTotal errors: " << errorcount ;
	
	
	return 0;}
%%



int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	

	yyin= fin;
	yylex();
	fclose(yyin);
	return 0;
}
