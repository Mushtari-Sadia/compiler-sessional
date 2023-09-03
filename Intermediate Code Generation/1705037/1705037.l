%option noyywrap

%x STRINGSTATE
%x COMMENTSTATE

%{
#include<bits/stdc++.h>
#include "symbolTable.h"
#include "y.tab.h"

using namespace std;

//ofstream tokenFile("1705037_token.txt");

//extern YYSTYPE yylval;
extern SymbolTable *st;
int line_count=1;
extern void yyerror(string s, int ln=line_count);
int error=0;
//int line_count=1;
//int errorcount = 0;
//int strlineno=0;
//SymbolTable *st = new SymbolTable(7);

//string text = "";
//string orgtext = "";

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
incop \+\+
decop \-\-
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
//outputFile << "\nLine no "<< line_count <<": Token <IF> Lexeme if found\n";
//cout << "\nLine no "<< line_count <<": Token <IF> Lexeme if found\n";
//tokenFile << "<IF> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return IF;
}
for {
//outputFile << "\nLine no "<< line_count <<": Token <FOR> Lexeme for found\n";
//cout << "\nLine no "<< line_count <<": Token <FOR> Lexeme for found\n";
//tokenFile << "<FOR> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return FOR;
}

do {
//outputFile << "\nLine no "<< line_count <<": Token <DO> Lexeme do found\n";
//cout << "\nLine no "<< line_count <<": Token <DO> Lexeme do found\n";
//tokenFile << "<DO> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return DO;
}

int {
//outputFile << "\nLine no "<< line_count <<": Token <INT> Lexeme int found\n";
//cout << "\nLine no "<< line_count <<": Token <INT> Lexeme int found\n";
//tokenFile << "<INT> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return INT;
}
float {
//outputFile << "\nLine no "<< line_count <<": Token <FLOAT> Lexeme float found\n";
//cout << "\nLine no "<< line_count <<": Token <FLOAT> Lexeme float found\n";
//tokenFile << "<FLOAT> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return FLOAT;
}

void {
//outputFile << "\nLine no "<< line_count <<": Token <VOID> Lexeme void found\n";
//cout << "\nLine no "<< line_count <<": Token <VOID> Lexeme void found\n";
//tokenFile << "<VOID> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return VOID;
}

switch {
//outputFile << "\nLine no "<< line_count <<": Token <SWITCH> Lexeme switch found\n";
//cout << "\nLine no "<< line_count <<": Token <SWITCH> Lexeme switch found\n";
//tokenFile << "<SWITCH> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return SWITCH;
}

default {
//outputFile << "\nLine no "<< line_count <<": Token <DEFAULT> Lexeme default found\n";
//cout << "\nLine no "<< line_count <<": Token <DEFAULT> Lexeme default found\n";
//tokenFile << "<DEFAULT> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return DEFAULT;
}

else {
//outputFile << "\nLine no "<< line_count <<": Token <ELSE> Lexeme else found\n";
//cout << "\nLine no "<< line_count <<": Token <ELSE> Lexeme else found\n";
//tokenFile << "<ELSE> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return ELSE;
}

while {
//outputFile << "\nLine no "<< line_count <<": Token <WHILE> Lexeme while found\n";
//cout << "\nLine no "<< line_count <<": Token <WHILE> Lexeme while found\n";
//tokenFile << "<WHILE> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return WHILE;
}

break {
//outputFile << "\nLine no "<< line_count <<": Token <BREAK> Lexeme break found\n";
//cout << "\nLine no "<< line_count <<": Token <BREAK> Lexeme break found\n";
//tokenFile << "<BREAK> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return BREAK;
}

char {
//outputFile << "\nLine no "<< line_count <<": Token <CHAR> Lexeme char found\n";
//cout << "\nLine no "<< line_count <<": Token <CHAR> Lexeme char found\n";
//tokenFile << "<CHAR> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return CHAR;
}

double {
//outputFile << "\nLine no "<< line_count <<": Token <DOUBLE> Lexeme double found\n";
//cout << "\nLine no "<< line_count <<": Token <DOUBLE> Lexeme double found\n";
//tokenFile << "<DOUBLE> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return DOUBLE;
}

return {
//outputFile << "\nLine no "<< line_count <<": Token <RETURN> Lexeme return found\n";
//cout << "\nLine no "<< line_count <<": Token <RETURN> Lexeme return found\n";
//tokenFile << "<RETURN> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return RETURN;
}

case {
//outputFile << "\nLine no "<< line_count <<": Token <CASE> Lexeme case found\n";
//cout << "\nLine no "<< line_count <<": Token <CASE> Lexeme case found\n";
//tokenFile << "<CASE> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return CASE;
}

continue {
//outputFile << "\nLine no "<< line_count <<": Token <CONTINUE> Lexeme continue found\n";
//cout << "\nLine no "<< line_count <<": Token <CONTINUE> Lexeme continue found\n";
//tokenFile << "<CONTINUE> ";
//outputFile << endl;
//outputFile << yytext << endl;
//outputFile << endl;
return CONTINUE;
}

println {
return PRINTLN;
}



{integer} {
		//cout << "\nLine no "<< line_count <<": Token <CONST_INT> Lexeme "<< yytext <<" found\n";
		//outputFile << "\nLine no "<< line_count <<": Token <CONST_INT> Lexeme "<< yytext <<" found\n";
		//tokenFile << "<CONST_INT,"<< yytext << "> ";
		//if(st->Insert(new SymbolInfo(yytext,"CONST_INT")))
		//{
		//	st->printAllScopeTable();	
		//}
		SymbolInfo *n = new SymbolInfo(yytext,"CONST_INT");
		yylval.sp = n;
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return CONST_INT;
	   }

{float} {
		//cout << "\nLine no "<< line_count <<": Token <CONST_FLOAT> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <CONST_FLOAT> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<CONST_FLOAT,"<< yytext << "> ";
//		if(st->Insert(new SymbolInfo(yytext,"CONST_FLOAT")))
//		{
//			st->printAllScopeTable();
//		}
		SymbolInfo *n = new SymbolInfo(yytext,"CONST_FLOAT");
		yylval.sp = n;
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return CONST_FLOAT;

}/*
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
*/
{addop} {
		//cout << "\nLine no "<< line_count <<": Token <ADDOP> Lexeme "<< yytext <<" found\n"; 
		//outputFile << "\nLine no "<< line_count <<": Token <ADDOP> Lexeme "<< yytext <<" found\n";
		//tokenFile << "<ADDOP,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		SymbolInfo *n = new SymbolInfo(yytext,"ADDOP");
		yylval.sp = n;
		return ADDOP;
	}
{mulop} { 
//		cout << "\nLine no "<< line_count <<": Token <MULOP> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <MULOP> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<MULOP,"<< yytext << "> ";  
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		SymbolInfo *n = new SymbolInfo(yytext,"MULOP");
		yylval.sp = n;
		return MULOP;
	}
	
{incop} { 
//		cout << "\nLine no "<< line_count <<": Token <INCOP> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <INCOP> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<INCOP,"<< yytext << "> ";  
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return INCOP;
	}
{decop} { 
//		cout << "\nLine no "<< line_count <<": Token <INCOP> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <INCOP> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<INCOP,"<< yytext << "> ";  
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return DECOP;
	}
{relop} { 
//		cout << "\nLine no "<< line_count <<": Token <RELOP> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <RELOP> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<RELOP,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		SymbolInfo *n = new SymbolInfo(yytext,"RELOP");
		yylval.sp = n;
		return RELOP;
		
	}
	
{assignop} { 
		//cout << "\nLine no "<< line_count <<": Token <ASSIGNOP> Lexeme "<< yytext <<" found\n";
		//outputFile << "\nLine no "<< line_count <<": Token <ASSIGNOP> Lexeme "<< yytext <<" found\n";
		//tokenFile << "<ASSIGNOP,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return ASSIGNOP;
	 }
	 
{logicop} { 
//		cout << "\nLine no "<< line_count <<": Token <LOGICOP> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <LOGICOP> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<LOGICOP,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		SymbolInfo *n = new SymbolInfo(yytext,"LOGICOP");
		yylval.sp = n;
		return LOGICOP;
	}

{not} { 
	//	cout << "\nLine no "<< line_count <<": Token <NOT> Lexeme "<< yytext <<" found\n";
	//	outputFile << "\nLine no "<< line_count <<": Token <NOT> Lexeme "<< yytext <<" found\n";
	//	tokenFile << "<NOT,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return NOT;
	}
{LPAREN} { 
//		cout << "\nLine no "<< line_count <<": Token <LPAREN> Lexeme "<< yytext <<" found\n"; 
//		outputFile << "\nLine no "<< line_count <<": Token <LPAREN> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<LPAREN,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return LPAREN;
	}
{RPAREN} { 
//		cout << "\nLine no "<< line_count <<": Token <RPAREN> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <RPAREN> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<RPAREN,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return RPAREN;
	 }
{LCURL} { 
//		cout << "\nLine no "<< line_count <<": Token <LCURL> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <LCURL> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<LCURL,"<< yytext << "> "; 
		
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return LCURL;
	}
{RCURL} { 
//		cout << "\nLine no "<< line_count <<": Token <RCURL> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <RCURL> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<RCURL,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return RCURL;
	}
{LTHIRD} { 
//		cout << "\nLine no "<< line_count <<": Token <LTHIRD> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <LTHIRD> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<LTHIRD,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return LTHIRD;
	}
{RTHIRD} { 
//		cout << "\nLine no "<< line_count <<": Token <RTHIRD> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <RTHIRD> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<RTHIRD,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return RTHIRD;
	 }
{COMMA} { 
//		cout << "\nLine no "<< line_count <<": Token <COMMA> Lexeme "<< yytext <<" found\n";
//		outputFile << "\nLine no "<< line_count <<": Token <COMMA> Lexeme "<< yytext <<" found\n";
//		tokenFile << "<COMMA,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return COMMA;
	 }

{SEMICOLON} { 
		//cout << "\nLine no "<< line_count <<": Token <SEMICOLON> Lexeme "<< yytext <<" found\n";
		//outputFile << "\nLine no "<< line_count <<": Token <SEMICOLON> Lexeme "<< yytext <<" found\n";
		//tokenFile << "<SEMICOLON,"<< yytext << "> "; 
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return SEMICOLON;
	}

{identifier} {
		/*cout << "\nLine no "<< line_count <<": Token <ID> Lexeme "<< yytext <<" found\n";
		outputFile << "\nLine no "<< line_count <<": Token <ID> Lexeme "<< yytext <<" found\n";
		tokenFile << "<ID,"<< yytext << "> "; 
		if(st->Insert(new SymbolInfo(yytext,"ID")))
		{
			st->printAllScopeTable();
		}*/
		SymbolInfo *n = new SymbolInfo(yytext,"ID");
		yylval.sp = n;
		//outputFile << endl;
		//outputFile << yytext << endl;
		//outputFile << endl;
		return ID;
		
		
	   }/*
	   
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




*/
. {
   yyerror("Unrecognized character " + (string)yytext 	);
	}
	/*
<<EOF>> {
	st->printAllScopeTable();
	cout << "\nTotal lines: " << line_count-1 ;
	outputFile << "\nTotal lines: " << line_count-1 ; 
	cout << "\nTotal errors: " << errorcount ;
	outputFile << "\nTotal errors: " << errorcount ;
	
	return 0;}*/
%%

