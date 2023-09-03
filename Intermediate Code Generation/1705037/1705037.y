%{
#include<bits/stdc++.h>
using namespace std;

#include "symbolTable.h"
ofstream outputFile("log.txt");
ofstream errorFile("error.txt");
ofstream codeFile("code.asm");
ofstream opcodeFile("optimized_code.asm");
//#define YYSTYPE SymbolInfo*



int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
extern int error;
bool inside_funcdef;
string current_func_id = "";
int temp_ln;
vector<SymbolInfo*> function_parameters_temp;
//ofstream outputFile("1705037_log.txt");
SymbolTable *st = new SymbolTable(30);


vector<string>* asm_vars = new vector<string>();
vector<string>* asm_arrs = new vector<string>();
string codes = "";
int labelCount = 0;
int tempCount = 0;


void declare_var(string name)
{
	for (auto i = asm_vars->begin(); i != asm_vars->end(); ++i)
	{
		if((*i)==name+st->cur->id)
		{
			return;
		}
	}
	asm_vars->push_back(name+st->cur->id);
}
string newLabel()
{
	return "LABEL"+to_string(++labelCount);
}

string newTemp()
{
	string var = "T"+to_string(++tempCount);
	asm_vars->push_back(var);
	return var;
}

string commentCode(vector<SymbolInfo*>* v)
{
	string code="";
	code += "\t;";
	for (auto i = v->begin(); i != v->end(); ++i)
	{
		if((*i)->getName()==";\n" || (*i)->getName()=="}\n" || (*i)->getName()=="{\n" || (*i)->getName()=="\n}" || (*i)->getName()=="\n{")
		{
			code += (*i)->getName()+"\t;";
		}
		else
		{
			code += (*i)->getName();
		}
	}
	code += "\n";
	return code;
}

void new_array_var(string name,int size)
{
	asm_arrs->push_back("\t"+name+st->cur->id + " DW "+to_string(size) +" DUP(0)\n");
}


SymbolInfo* getParameterID(string name)
{
	for (auto i = function_parameters_temp.begin(); i != function_parameters_temp.end(); ++i)
		{
			//cout << (*i)->getName() << endl;
			if((*i)->getName()==name)
			{
				return (*i);
			}
		}
	return NULL;
}
void peephole_optimization()
{
	string cur;
	string prev;
	string codes2 = codes;
	string temp,part,part2;
	int pos,t,t2,t3,t4;
	pos = codes2.find("\n");
	prev = codes2.substr(0,pos);
	codes2 = codes2.substr(pos+1,codes2.length()-pos);

	// opcodeFile << prev << endl;

	while(codes2!="")
	{
		pos = codes2.find("\n");
		cur = codes2.substr(0,pos);
		codes2 = codes2.substr(pos+1,codes2.length()-pos);
		part = "MOV ";
		part2 = ",AX";
		t = prev.find(part);
		t2 = prev.find(part2);
		if( t != string::npos &&  t2 != string::npos)
		{
			temp = prev.substr(part.length()+1,t2-part.length()-1);
			if(cur.find("MOV AX,"+temp+" ") != string::npos)
			{
				// cout << prev << endl;
				// cout << cur << endl;
				opcodeFile << prev << endl;
				pos = codes2.find("\n");
				cur = codes2.substr(0,pos);
				codes2 = codes2.substr(pos+1,codes2.length()-pos);
				prev = cur;
				continue;
			}
		}

		t3 = cur.find(part);
		t4 = cur.find(part2);
		if( t3 != string::npos &&  t4 != string::npos)
		{
			temp = cur.substr(part.length()+1,t4-part.length()-1);
			if(prev.find("MOV AX,"+temp+" ") != string::npos)
			{
				opcodeFile << prev << endl;
				pos = codes2.find("\n");
				cur = codes2.substr(0,pos);
				codes2 = codes2.substr(pos+1,codes2.length()-pos);
				prev = cur;
				continue;
			}
		}



		opcodeFile << prev << endl;
		
		
		prev = cur;


	}
opcodeFile << prev << endl;
	
	
}
void initialize_asm()
{
	
	codeFile << ".MODEL SMALL" << endl;
	codeFile << ".STACK 100H" << endl;
	codeFile << ".DATA" << endl;
	codeFile << "\tCR EQU 0DH" << endl;
	codeFile << "\tLF EQU 0AH" << endl;
	codeFile << "\tP DW ?" << endl;
	codeFile << "\tSTORE_RET DW ?" << endl;
	for (auto i = asm_arrs->begin(); i != asm_arrs->end(); ++i)
	{
		codeFile <<  (*i);
	}

	for (auto i = asm_vars->begin(); i != asm_vars->end(); ++i)
	{
		codeFile << "\t" << (*i) << " DW ?" << endl;
	}
	codeFile << ".CODE" << endl;
	codeFile << "PRINT PROC" << endl;
	codeFile << "\tPUSH AX" << endl;
	codeFile << "\tPUSH BX" << endl;
	codeFile << "\tPUSH CX" << endl;
	codeFile << "\tPUSH DX" << endl;
	codeFile << "\tXOR AX,AX" << endl;
	codeFile << "\tXOR BX,BX" << endl;
	codeFile << "\tXOR CX,CX" << endl;
	codeFile << "\tXOR DX,DX" << endl;
	codeFile << "\tWHILE:" << endl;
	codeFile << "\t\tMOV AX,P" << endl;
	codeFile << "\t\tCWD" << endl;
	codeFile << "\t\tMOV BX,10" << endl;
	codeFile << "\t\tDIV BX" << endl;
	codeFile << "\t\tMOV P,AX" << endl;
	codeFile << "\t\tPUSH DX" << endl;
	codeFile << "\t\tINC CX" << endl;
	codeFile << "\t\tXOR DX,DX" << endl;
	codeFile << "\t\tXOR AX,AX" << endl;
	codeFile << "\t\tCMP P,0" << endl;
	codeFile << "\t\tJE END_WHILE" << endl;
	codeFile << "\t\tJMP WHILE" << endl;
	codeFile << "\tEND_WHILE:" << endl;
	codeFile << "\tMOV AH,2" << endl;
	codeFile << "\tTOP:" << endl;
	codeFile << "\t\tPOP DX" << endl;
	codeFile << "\t\tADD DX,030H" << endl;
	codeFile << "\t\tINT 21H" << endl;
	codeFile << "\t\tLOOP TOP" << endl;
	codeFile << "\tMOV AH,2" << endl;
	codeFile << "\tMOV DL,' '" << endl;
	codeFile << "\tINT 21H" << endl;
	codeFile << "\tPOP DX" << endl;
	codeFile << "\tPOP CX" << endl;
	codeFile << "\tPOP BX" << endl;
	codeFile << "\tPOP AX" << endl;
	codeFile << "\tRET" << endl;
	codeFile << "PRINT ENDP" << endl;
	codeFile << "" << endl;
	//all procs goes here
	codeFile << codes << endl;



	opcodeFile << ".MODEL SMALL" << endl;
	opcodeFile << ".STACK 100H" << endl;
	opcodeFile << ".DATA" << endl;
	opcodeFile << "\tCR EQU 0DH" << endl;
	opcodeFile << "\tLF EQU 0AH" << endl;
	opcodeFile << "\tP DW ?" << endl;
	opcodeFile << "\tSTORE_RET DW ?" << endl;
	for (auto i = asm_arrs->begin(); i != asm_arrs->end(); ++i)
	{
		opcodeFile <<  (*i);
	}

	for (auto i = asm_vars->begin(); i != asm_vars->end(); ++i)
	{
		opcodeFile << "\t" << (*i) << " DW ?" << endl;
	}

	opcodeFile << ".CODE" << endl;
	opcodeFile << "PRINT PROC" << endl;
	opcodeFile << "\tPUSH AX" << endl;
	opcodeFile << "\tPUSH BX" << endl;
	opcodeFile << "\tPUSH CX" << endl;
	opcodeFile << "\tPUSH DX" << endl;
	opcodeFile << "\tXOR AX,AX" << endl;
	opcodeFile << "\tXOR BX,BX" << endl;
	opcodeFile << "\tXOR CX,CX" << endl;
	opcodeFile << "\tXOR DX,DX" << endl;
	opcodeFile << "\tWHILE:" << endl;
	opcodeFile << "\t\tMOV AX,P" << endl;
	opcodeFile << "\t\tCWD" << endl;
	opcodeFile << "\t\tMOV BX,10" << endl;
	opcodeFile << "\t\tDIV BX" << endl;
	opcodeFile << "\t\tMOV P,AX" << endl;
	opcodeFile << "\t\tPUSH DX" << endl;
	opcodeFile << "\t\tINC CX" << endl;
	opcodeFile << "\t\tXOR DX,DX" << endl;
	opcodeFile << "\t\tXOR AX,AX" << endl;
	opcodeFile << "\t\tCMP P,0" << endl;
	opcodeFile << "\t\tJE END_WHILE" << endl;
	opcodeFile << "\t\tJMP WHILE" << endl;
	opcodeFile << "\tEND_WHILE:" << endl;
	opcodeFile << "\tMOV AH,2" << endl;
	opcodeFile << "\tTOP:" << endl;
	opcodeFile << "\t\tPOP DX" << endl;
	opcodeFile << "\t\tADD DX,030H" << endl;
	opcodeFile << "\t\tINT 21H" << endl;
	opcodeFile << "\t\tLOOP TOP" << endl;
	opcodeFile << "\tMOV AH,2" << endl;
	opcodeFile << "\tMOV DL,' '" << endl;
	opcodeFile << "\tINT 21H" << endl;
	opcodeFile << "\tPOP DX" << endl;
	opcodeFile << "\tPOP CX" << endl;
	opcodeFile << "\tPOP BX" << endl;
	opcodeFile << "\tPOP AX" << endl;
	opcodeFile << "\tRET" << endl;
	opcodeFile << "PRINT ENDP" << endl;
	opcodeFile << "" << endl;
	peephole_optimization();
	delete asm_vars;
	delete asm_arrs;
}



void yyerror(string s, int ln=line_count)
{
	outputFile << "Error at line " << ln << ": " << s << endl;
	errorFile << "Error at line " << ln << ": " << s << "\n\n";
	error++;
}

void yylog(string s)
{

	outputFile << "Line " << line_count << ": " << s << endl;

}

Reducible* reduce(Reducible* obj)
{
	Reducible* x = new Reducible();
	outputFile << endl;
	//outputFile << "enters function" << endl;
	for (auto i = obj->v->begin(); i != obj->v->end(); ++i)
	{
		outputFile << (*i)->getName() ;
		// obj->code;
		x->v->push_back(*i);
	}
	x->code = obj->code;
	x->symbol = obj->symbol;
	// codes+=obj->code;
	outputFile << "\n" << endl;
	delete obj;
	return x;

}


void matchParameters(vector<SymbolInfo*>* r, SymbolInfo* this_func_id,bool declared,int line_no=line_count)
{
	int paramIndex=0;
	int paramCount;
	if(declared)
	{
		paramCount = this_func_id->fnInfo->parameterCount;
		////////////////cout << "paramcount dec" << paramCount << endl;
	}
	
	for (auto i = r->begin(); i != r->end(); ++i)
	{
		if( (*i)->getType()=="COMMA" || (*i)->getType()=="ID")
		{
			continue;
		}
		else
		{
			auto j = i;
			string type = (*j)->getType();			
			++j;
			if(j== r->end())
			{
				yyerror(to_string(paramIndex+1)+"th parameter's name not given in function definition of "+this_func_id->getName(),line_no);
				break;
			}
			else if((*j)->getType()!="ID")
			{
				yyerror(to_string(paramIndex+1)+"th parameter's name not given in function definition of "+this_func_id->getName(),line_no);
			}
			else
			{
				string id = (*j)->getName();
				string symb = (*j)->getSymbol();
				if(declared)
				{
					if(paramIndex<paramCount)
					{
						string declared_type = this_func_id->fnInfo->parameter_list.at(paramIndex).first;
						string declared_id = this_func_id->fnInfo->parameter_list.at(paramIndex).second;
						if(declared_type!=type)
						{
							yyerror("Type of parameter does not match with declaration",line_no);
						}
					}
					else
					{
						yyerror("Total number of arguments mismatch with declaration in function "+id,line_no);
					}
					paramIndex++;
					////////////////cout << "Type,id,paramindex : " << type << id << paramIndex << endl;
					
				}
				else
				{
					if(symb=="")
						this_func_id->fnInfo->addParameter(type,id);
					else
						this_func_id->fnInfo->addParameter(type,id,symb);
				}				
			}
			
		}
	}
	
	if(declared && paramIndex<paramCount) //the #parameters on the definition is less than #parameters on the declaration
	{
		string id = this_func_id->getName();
		yyerror("Total number of arguments mismatch with declaration in function "+id,line_no);
	}


}

void setAndCheckArraySize(SymbolInfo* var_st_entry,SymbolInfo* array_size)
{
	
	if(array_size->getType()!="CONST_INT")
	{
		yyerror("Array size must be of integer type"); 
	}
	else
	{
		bool valid_size = var_st_entry->setArraySize(array_size->getName());
		if(!valid_size)
		{
			yyerror("Array size cannot be zero");
		}
		else
		{
			var_st_entry->setSymbol(var_st_entry->getName()+st->cur->id);
			new_array_var(var_st_entry->getName(),stoi(array_size->getName()));
		}
	}
}


%}

%union{
	int ival;
	SymbolInfo* sp;
	Reducible* vsp;
}
%token IF ELSE FOR WHILE INT ASSIGNOP SEMICOLON LPAREN RPAREN COMMA LCURL RCURL
%token FLOAT VOID LTHIRD RTHIRD PRINTLN RETURN NOT INCOP DECOP CONTINUE CHAR
%token DO SWITCH DEFAULT BREAK DOUBLE CASE
%token <sp> ID CONST_INT CONST_FLOAT ADDOP MULOP RELOP LOGICOP
%type <vsp> declaration_list start program unit var_declaration func_declaration func_definition type_specifier parameter_list compound_statement statements statement expression_statement expression logic_expression variable rel_expression simple_expression term unary_expression factor argument_list arguments id id2 id3
//%left 
//%right
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
{
	
	yylog("start : program\n\n");
	codes+=$1->code;
	////////////cout << codes << endl;
	//$$ = reduce(new Reducible($1->v,code));

		
}
;

program : program unit 
{
	yylog("program : program unit");
	
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
	}
	symbol += $1->symbol+$2->symbol;
	code += $1->code+$2->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| unit 
{
	yylog("program : unit");
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
;
	
unit : var_declaration 
{
	yylog("unit : var_declaration");
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
| func_declaration 
{
	
	yylog("unit : func_declaration");
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
| func_definition 
{
	
	yylog("unit : func_definition");
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
     ;
     
func_declaration : type_specifier id3 LPAREN parameter_list RPAREN SEMICOLON 
{
	string retType;
	SymbolInfo* this_func_id;
	yylog("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		retType = (*i)->getType();
		////////////////cout << "Returntype : " << retType << endl; 
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);

		this_func_id = st->LookUp((*i)->getName());
		this_func_id->fnInfo->setReturnType(retType);
		////////////////cout << "function name : " << this_func_id->getName() << endl;
		////////////////cout << "Returntype : " << this_func_id->fnInfo->returnType << endl; 
	}
	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);
		
		//following part adds all the parameters in the function name symboltable entry
		if( (*i)->getType()=="COMMA" || (*i)->getType()=="ID")
		{
			continue;
		}
		else
		{
			auto j = i;
			string type = (*j)->getType();			
			++j;
			if(j!= $4->v->end())
			{
				string id = (*j)->getName();
				string symb = (*j)->getSymbol();
				if(symb=="")
						this_func_id->fnInfo->addParameter(type,id);
					else
						this_func_id->fnInfo->addParameter(type,id,symb);
			}
			else
			{
				yyerror("Parameter name unspecified");
				break;
			}
			
		}
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	symbol += $1->symbol+$2->symbol+ $4->symbol;
	code += $1->code+$2->code+ $4->code;
	$$ = reduce(new Reducible(r,code,symbol));
	
	for (auto i = this_func_id->fnInfo->parameter_list.begin(); i != this_func_id->fnInfo->parameter_list.end(); ++i)
	{
		////////////////cout <<(*i).first << " " <<(*i).second << endl;
	}
	
		
}
| type_specifier id3 LPAREN parameter_list error RPAREN SEMICOLON 
{
	string retType;
	SymbolInfo* this_func_id;
	yylog("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		retType = (*i)->getType();
		////////////////cout << "Returntype : " << retType << endl; 
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);

		this_func_id = st->LookUp((*i)->getName());
		this_func_id->fnInfo->setReturnType(retType);
		////////////////cout << "function name : " << this_func_id->getName() << endl;
		////////////////cout << "Returntype : " << this_func_id->fnInfo->returnType << endl; 
	}
	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);
		
		//following part adds all the parameters in the function name symboltable entry
		if( (*i)->getType()=="COMMA" || (*i)->getType()=="ID")
		{
			continue;
		}
		else
		{
			auto j = i;
			string type = (*j)->getType();			
			++j;
			if(j!= $4->v->end())
			{
				string id = (*j)->getName();
				
				string symb = (*j)->getSymbol();
				if(symb=="")
						this_func_id->fnInfo->addParameter(type,id);
					else
						this_func_id->fnInfo->addParameter(type,id,symb);
			}
			else
			{
				yyerror("Parameter name unspecified");
				break;
			}
			
		}
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	$$ = reduce(new Reducible(r,code,symbol));
	
	for (auto i = this_func_id->fnInfo->parameter_list.begin(); i != this_func_id->fnInfo->parameter_list.end(); ++i)
	{
		////////////////cout <<(*i).first << " " <<(*i).second << endl;
	}
	
		
}
| type_specifier id3 LPAREN parameter_list RPAREN error SEMICOLON 
{
	string retType;
	SymbolInfo* this_func_id;
	yylog("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		retType = (*i)->getType();
		////////////////cout << "Returntype : " << retType << endl; 
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);

		this_func_id = st->LookUp((*i)->getName());
		this_func_id->fnInfo->setReturnType(retType);
		////////////////cout << "function name : " << this_func_id->getName() << endl;
		////////////////cout << "Returntype : " << this_func_id->fnInfo->returnType << endl; 
	}
	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);
		
		//following part adds all the parameters in the function name symboltable entry
		if( (*i)->getType()=="COMMA" || (*i)->getType()=="ID")
		{
			continue;
		}
		else
		{
			auto j = i;
			string type = (*j)->getType();			
			++j;
			if(j!= $4->v->end())
			{
				string id = (*j)->getName();
				
				string symb = (*j)->getSymbol();
				if(symb=="")
						this_func_id->fnInfo->addParameter(type,id);
					else
						this_func_id->fnInfo->addParameter(type,id,symb);
			}
			else
			{
				yyerror("Parameter name unspecified");
				break;
			}
			
		}
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	
	$$ = reduce(new Reducible(r,code,symbol));
	
	for (auto i = this_func_id->fnInfo->parameter_list.begin(); i != this_func_id->fnInfo->parameter_list.end(); ++i)
	{
		////////////////cout <<(*i).first << " " <<(*i).second << endl;
	}
	
		
}
| type_specifier id3 LPAREN RPAREN SEMICOLON 
{
	string retType;
	SymbolInfo* this_func_id;
	
	yylog("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		
		retType = (*i)->getType();
		////////////////cout << "Returntype : " << retType << endl; 
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
		
		this_func_id = st->LookUp((*i)->getName());
		if(this_func_id->fnInfo->isFunction)
		{
			yyerror("Multiple declaration of function "+(*i)->getName());
		}
		this_func_id->fnInfo->setReturnType(retType);
		////////////////cout << "function name : " << this_func_id->getName() << endl;
		////////////////cout << "Returntype : " << this_func_id->fnInfo->returnType << endl; 
	}
	r->push_back(new SymbolInfo("(","LPAREN"));
	r->push_back(new SymbolInfo(")","RPAREN"));
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	symbol += $1->symbol+$2->symbol;
	code += $1->code+$2->code;
	$$ = reduce(new Reducible(r,code,symbol));
}
| type_specifier id3 LPAREN RPAREN error SEMICOLON 
{
	string retType;
	SymbolInfo* this_func_id;
	
	yylog("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		
		retType = (*i)->getType();
		////////////////cout << "Returntype : " << retType << endl; 
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
		
		this_func_id = st->LookUp((*i)->getName());
		if(this_func_id->fnInfo->isFunction)
		{
			yyerror("Multiple declaration of function "+(*i)->getName());
		}
		this_func_id->fnInfo->setReturnType(retType);
		////////////////cout << "function name : " << this_func_id->getName() << endl;
		////////////////cout << "Returntype : " << this_func_id->fnInfo->returnType << endl; 
	}
	r->push_back(new SymbolInfo("(","LPAREN"));
	r->push_back(new SymbolInfo(")","RPAREN"));
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	
	$$ = reduce(new Reducible(r,code,symbol));
}
// type_specifier id LPAREN error RPAREN SEMICOLON 
;
		 
func_definition : type_specifier id3 LPAREN parameter_list RPAREN dummystate compound_statement
{
	string retType;
	string funcname;
	SymbolInfo* this_func_id;
	bool declared;
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		//finding symboltable entry for the name of function
		funcname = (*i)->getName();
		this_func_id = st->LookUp(funcname);
		if(this_func_id!=NULL)
			funcname = this_func_id->getSymbol();
		//checking if this function was declared before
		declared = this_func_id->fnInfo->isFunction;
	}
	
	
	yylog("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
	
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		
		retType = (*i)->getType();
		if(declared)
		{
			string declared_retType = this_func_id->fnInfo->returnType;
			if(declared_retType!=retType)
			{
				yyerror("Return type mismatch with function declaration in function " + this_func_id->getName(),temp_ln);
			}
		}
		else
		{
			//if the function was not declared before, set the return type
			this_func_id->fnInfo->setReturnType(retType);
		}	
		
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);	
	}
	
	matchParameters($4->v,this_func_id,declared,temp_ln);
	
	r->push_back(new SymbolInfo(")","RPAREN"));
	for (auto i = $7->v->begin(); i != $7->v->end(); ++i)
	{
		r->push_back(*i);
	}
	symbol += $1->symbol+$2->symbol+$4->symbol+$7->symbol;
	
	
	code += "PROCEDURE_"+funcname+ " PROC\n";
	code += "\tPUSH AX\n";
	code += "\tPUSH BX\n";
	code += "\tPUSH CX\n";
	code += "\tPUSH DX\n";
	// code += "\tXOR AX,AX\n";
	// code += "\tXOR BX,BX\n";
	// code += "\tXOR CX,CX\n";
	// code += "\tXOR DX,DX\n";
	code += $7->code;
	code += "PROCEDURE_"+funcname+ " ENDP\n";


	$$ = reduce(new Reducible(r,code,symbol));
	inside_funcdef = false;
	current_func_id = "";
		
}
| type_specifier id3 LPAREN parameter_list error RPAREN dummystate compound_statement
{
	string retType;
	SymbolInfo* this_func_id;
	bool declared;
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		//finding symboltable entry for the name of function
		this_func_id = st->LookUp((*i)->getName());
		//checking if this function was declared before
		declared = this_func_id->fnInfo->isFunction;
	}
	
	
	yylog("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
	
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		
		retType = (*i)->getType();
		if(declared)
		{
			string declared_retType = this_func_id->fnInfo->returnType;
			if(declared_retType!=retType)
			{
				yyerror("Return type mismatch with function declaration in function " + this_func_id->getName(),temp_ln);
			}
		}
		else
		{
			//if the function was not declared before, set the return type
			this_func_id->fnInfo->setReturnType(retType);
		}	
		
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);	
	}
	
	matchParameters($4->v,this_func_id,declared,temp_ln);
	
	r->push_back(new SymbolInfo(")","RPAREN"));
	for (auto i = $8->v->begin(); i != $8->v->end(); ++i)
	{
		r->push_back(*i);
	}
	
	$$ = reduce(new Reducible(r,code,symbol));
	inside_funcdef = false;
		
}
| type_specifier id3 LPAREN RPAREN compound_statement 
{
	yylog("func_definition : type_specifier ID LPAREN RPAREN compound_statement");
	//string reduced =    $1->getName()+$2->getName()+"("+")"+$5->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	string name="";

	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
		name = (*i)->getName();
	}
	r->push_back(new SymbolInfo("(","LPAREN"));
	r->push_back(new SymbolInfo(")","RPAREN"));
	for (auto i = $5->v->begin(); i != $5->v->end(); ++i)
	{
		r->push_back(*i);
	}
	symbol += $1->symbol+$2->symbol+$5->symbol;


	if(name=="main")
	{
		code += "MAIN PROC\n";
		code += "\tMOV AX, @DATA\n";
		code += "\tMOV DS, AX\n";
		//all code goes here
		code += $5->code;

		code += "\tMOV AH,4CH\n";
		code += "\tINT 21H\n";
		code += "MAIN ENDP\n";
		code += "END MAIN\n";
	}
	else
	{
		code += $5->code;
	}


	
	$$ = reduce(new Reducible(r,code,symbol));
		
}
;				
dummystate :
{
	inside_funcdef = true;
	temp_ln = line_count;
	
}

parameter_list : parameter_list COMMA type_specifier ID
{
	yylog("parameter_list  : parameter_list COMMA type_specifier ID");
	//string reduced =    $1->getName()+","+$3->getName()+$4->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	string type;
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	
	r->push_back(new SymbolInfo(",","COMMA"));
	
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}

	
	//saving all function parameters in this vector
	if(type!="VOID")
					$4->setDataType(type);
	else if(type=="VOID")
					yyerror("Variable type cannot be void");

	
	declare_var($4->getName());
	$4->setSymbol($4->getName()+st->cur->id);
	r->push_back($4);
	function_parameters_temp.push_back($4);
	symbol += $1->symbol+$3->symbol;
	code += $1->code+$3->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| parameter_list error COMMA type_specifier ID
{
	yylog("parameter_list  : parameter_list COMMA type_specifier ID");
	//string reduced =    $1->getName()+","+$3->getName()+$4->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	
	r->push_back(new SymbolInfo(",","COMMA"));
	
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);
	}

	r->push_back($5);
	//saving all function parameters in this vector
	function_parameters_temp.push_back($5);
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| parameter_list COMMA type_specifier
{
	yylog("parameter_list  : parameter_list COMMA type_specifier");
//	//string reduced =    $1->getName()+","+$3->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	
	r->push_back(new SymbolInfo(",","COMMA"));
	
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}
	symbol += $1->symbol+$3->symbol;
	code += $1->code+$3->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| parameter_list error COMMA type_specifier
{
	yylog("parameter_list  : parameter_list COMMA type_specifier");
//	//string reduced =    $1->getName()+","+$3->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	
	r->push_back(new SymbolInfo(",","COMMA"));
	
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);
	}

	$$ = reduce(new Reducible(r,code,symbol));
		
}
| type_specifier ID
{
	yylog("parameter_list : type_specifier ID");
	//string reduced =    $1->getName()+$2->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	string type;
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		type = (*i)->getType();
	}

	
	//saving all function parameters in this vector
	function_parameters_temp.clear();
	
	if(type!="VOID")
					$2->setDataType(type);
	else if(type=="VOID")
					yyerror("Variable type cannot be void");
	
	
	declare_var($2->getName());
	$2->setSymbol($2->getName()+st->cur->id);
	r->push_back($2);
	function_parameters_temp.push_back($2);
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| type_specifier
{
	yylog("parameter_list : type_specifier");
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
;

 		
compound_statement : LCURL enterscopestate statements RCURL
{
	yylog("compound_statement : LCURL statements RCURL");
//	//string reduced = "{\n"+$3->getName()+"}\n";

	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	
	r->push_back(new SymbolInfo("{\n","LCURL"));
	
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo("}\n","RCURL"));
	symbol += $3->symbol;
	code += $3->code;
	$$ = reduce(new Reducible(r,code,symbol));
	
	st->exitScope();		
}
| LCURL enterscopestate statements error RCURL
{
	yylog("compound_statement : LCURL statements RCURL");
//	//string reduced = "{\n"+$3->getName()+"}\n";

	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	
	r->push_back(new SymbolInfo("{\n","LCURL"));
	
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo("}\n","RCURL"));

	$$ = reduce(new Reducible(r,code,symbol));
		
	
	st->exitScope();		
}
| LCURL enterscopestate RCURL
{
	yylog("compound_statement : LCURL RCURL");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	
	r->push_back(new SymbolInfo("{\n","LCURL"));

	r->push_back(new SymbolInfo("}\n","RCURL"));

	$$ = reduce(new Reducible(r,code,symbol));
		
}
| LCURL enterscopestate error RCURL
{
	yylog("compound_statement : LCURL RCURL");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	
	r->push_back(new SymbolInfo("{\n","LCURL"));

	r->push_back(new SymbolInfo("}\n","RCURL"));

	$$ = reduce(new Reducible(r,code,symbol));
		
}
;
enterscopestate : {
	st->enterScope(30);
		
	if(inside_funcdef){
		for (auto i = function_parameters_temp.begin(); i != function_parameters_temp.end(); ++i)
		{
			//cout <<  "temp parameters name " << (*i)->getName() << endl;
			//cout <<  "temp parameters symbol " << (*i)->getSymbol() << endl;
			//cout << st->cur->id << endl;

			// (*i)->setSymbol((*i)->getName()+st->cur->id);
			if(!st->Insert(*i))
			{
				yyerror("Multiple declaration of "+(*i)->getName()+" in parameter");
			}

			SymbolInfo* x = st->LookUp((*i)->getName());
			//cout << "temp parameters symbol after inserting table " <<  x->getSymbol() << endl;
		}
		function_parameters_temp.clear();
		inside_funcdef  = false;
	}
}
;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
{
	yylog("var_declaration : type_specifier declaration_list SEMICOLON");

	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	
	string type;
	
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		type = (*i)->getType();
		
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		if((*i)->getType()!="COMMA")
		{	
			SymbolInfo* st_id_entry = st->LookUp((*i)->getName());
			if(st_id_entry!=NULL)
			{
				if(type!="VOID" && st_id_entry->getDataType()=="")
					st_id_entry->setDataType(type);
				else if(type=="VOID")
					yyerror("Variable type cannot be void");
			}
		}
		
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	symbol += $1->symbol+$2->symbol;
	code += $1->code+$2->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}
|type_specifier declaration_list error SEMICOLON
{
	yylog("var_declaration : type_specifier declaration_list SEMICOLON");

	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	
	string type;
	
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		type = (*i)->getType();
		
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		if((*i)->getType()!="COMMA")
		{	
			SymbolInfo* st_id_entry = st->LookUp((*i)->getName());
			if(st_id_entry!=NULL)
			{
				if(type!="VOID" && st_id_entry->getDataType()=="")
					st_id_entry->setDataType(type);
				else if(type=="VOID")
					yyerror("Variable type cannot be void");
			}
		}
		
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	symbol += $1->symbol+$2->symbol;
	code += $1->code+$2->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}
;
 		 
type_specifier : INT
{
	yylog("type_specifier : INT");
//	//string reduced =    "int"+(string)" ";
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("int ","INT"));
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| FLOAT 
{
	yylog("type_specifier : FLOAT");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("float ","FLOAT"));
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| VOID 
{
	yylog("type_specifier : VOID");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("void ","VOID"));
	$$ = reduce(new Reducible(r,code,symbol));
		
}
;
		
declaration_list : declaration_list COMMA id
{
	yylog("declaration_list : declaration_list COMMA ID ");
	////string reduced =    $1->getName()+","+$3->getName();
	
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(",","COMMA"));
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}
	symbol += $1->symbol+$3->symbol;
	code += $1->code+$3->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| declaration_list error COMMA id
{
	yylog("declaration_list : declaration_list COMMA ID ");
	////string reduced =    $1->getName()+","+$3->getName();
	
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(",","COMMA"));
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);
	}
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| declaration_list COMMA id2 LTHIRD CONST_INT RTHIRD
{
	SymbolInfo* this_id;
	yylog("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
//	//string reduced =    $1->getName()+","+$3->getName()+"["+$5->getName()+"]";
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(",","COMMA"));
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
		this_id = st->LookUp((*i)->getName());
	}
	r->push_back(new SymbolInfo("[","LTHIRD"));
	r->push_back($5);
		
	setAndCheckArraySize(this_id,$5);
	r->push_back(new SymbolInfo("]","RTHIRD"));
	symbol += $1->symbol+$3->symbol;
	code += $1->code+$3->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| declaration_list error COMMA id2 LTHIRD CONST_INT RTHIRD
{
	SymbolInfo* this_id;
	yylog("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
//	//string reduced =    $1->getName()+","+$3->getName()+"["+$5->getName()+"]";
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(",","COMMA"));
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);
		this_id = st->LookUp((*i)->getName());
	}
	r->push_back(new SymbolInfo("[","LTHIRD"));
	r->push_back($6);
		
	setAndCheckArraySize(this_id,$6);
	r->push_back(new SymbolInfo("]","RTHIRD"));

	$$ = reduce(new Reducible(r,code,symbol));
		
}
| id 
{
	yylog("declaration_list : ID");
//	//string reduced =  $1->getName();
	string code = "";
	string symbol = "";
	$$ = reduce(new Reducible($1->v,code));
	
	
}
| id2 LTHIRD CONST_INT RTHIRD
{
	SymbolInfo* this_id;
	yylog("declaration_list : ID LTHIRD CONST_INT RTHIRD");
	////string reduced =    $1->getName()+"["+$3->getName()+"]";
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		this_id = st->LookUp((*i)->getName());
		
	}
	r->push_back(new SymbolInfo("[","LTHIRD"));
	r->push_back($3);
	
	setAndCheckArraySize(this_id,$3);
	
	r->push_back(new SymbolInfo("]","RTHIRD"));

	$$ = reduce(new Reducible(r,code,symbol));

		
}
;

id : ID
{
	$1->setSymbol($1->getName()+st->cur->id);
	if(!st->Insert($1))
	{
	    SymbolInfo* s = st->LookUp($1->getName());
	    if(!s->fnInfo->isFunction)
		    yyerror("Multiple declaration of "+$1->getName());
	}
	else
	{
		SymbolInfo* s = st->LookUp($1->getName());
		if(!s->fnInfo->isFunction && $1->getName()!="main" )
		{
			declare_var($1->getName());
			s->setSymbol($1->getName()+st->cur->id);
		}
		
	}
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	
	r->push_back($1);

	$$ = reduce(new Reducible(r,code,symbol));
};

id2 : ID
{
	$1->setSymbol($1->getName()+st->cur->id);
	if(!st->Insert($1))
	{
	    SymbolInfo* s = st->LookUp($1->getName());
	    if(!s->fnInfo->isFunction)
		    yyerror("Multiple declaration of "+$1->getName());
	}
	else
	{
		SymbolInfo* s = st->LookUp($1->getName());
		
	}
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	
	r->push_back($1);

	$$ = reduce(new Reducible(r,code,symbol));
};

id3 : ID
{
	//cout << $1->getName() << " is the function name " << endl;
	$1->setSymbol($1->getName()+st->cur->id);
	if(!st->Insert($1))
	{
	    SymbolInfo* s = st->LookUp($1->getName());
	    if(!s->fnInfo->isFunction)
		    yyerror("Multiple declaration of "+$1->getName());
	}
	else
	{
		SymbolInfo* s = st->LookUp($1->getName());
		if(!s->fnInfo->isFunction && $1->getName()!="main" )
		{
			declare_var($1->getName());
			s->setSymbol($1->getName()+st->cur->id);
		}
		
	}
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";

	current_func_id=$1->getName();
	
	r->push_back($1);

	$$ = reduce(new Reducible(r,code,symbol));
};
	  
statements : statement
{
	yylog("statements : statement");
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
| statements statement 
{
	yylog("statements : statements statement");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
	}
	symbol += $1->symbol+$2->symbol;

	// code += "\t;";
	// for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	// {
	// 	code += (*i)->getName() ;
	// }
	// code += "\n";

	code += $1->code + $2->code;
	$$ = reduce(new Reducible(r,code,symbol));

		
}
;
	   
statement : var_declaration 
{
	yylog("statement : var_declaration");
//	//string reduced =    $1->getName();
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	// code += "\t;";
	// for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	// {
	// 	if((*i)->getName()==";\n" || (*i)->getName()=="}\n" || (*i)->getName()=="{\n" || (*i)->getName()=="\n}" || (*i)->getName()=="\n{")
	// 	{
	// 		code += (*i)->getName()+"\t;";
	// 	}
	// 	else
	// 	{
	// 		code += (*i)->getName();
	// 	}
	// }
	// code += "\n";
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
| expression_statement 
{
	yylog("statement : expression_statement  ");
//	//string reduced =    $1->getName();
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code +=	commentCode($1->v);

	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
| compound_statement 
{
	yylog("statement : compound_statement  ");
//	//string reduced =    $1->getName();
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	// code += "\t;";
	// for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	// {
	// 	if((*i)->getName()==";\n" || (*i)->getName()=="}\n" || (*i)->getName()=="{\n" || (*i)->getName()=="\n}" || (*i)->getName()=="\n{")
	// 	{
	// 		code += (*i)->getName()+"\t;";
	// 	}
	// 	else
	// 	{
	// 		code += (*i)->getName();
	// 	}
	// }
	// code += "\n";
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
| FOR LPAREN expression_statement expression_statement expression RPAREN statement
{

	yylog("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
//	//string reduced =    (string)"for"+(string)"("+$3->getName()+$`->getName()+$5->getName()+")"+$7->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("for","FOR"));
	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);
	}
	for (auto i = $5->v->begin(); i != $5->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	for (auto i = $7->v->begin(); i != $7->v->end(); ++i)
	{
		r->push_back(*i);
	}
	code += "\t;";
	for (auto i = r->begin(); i != r->end(); ++i)
	{

		if((*i)->getName()==";\n" || (*i)->getName()=="}\n" || (*i)->getName()=="{\n" || (*i)->getName()=="\n}" || (*i)->getName()=="\n{" || (*i)->getName()=="\n}" || (*i)->getName()=="\n}")
		{
			code += (*i)->getName()+"\t;";
		}
		else
		{
			code += (*i)->getName();
		}
	}
	code += "\n";
	// symbol += $3->symbol+$4->symbol+$5->symbol+$7->symbol;
	// code += $3->code+$4->code+$5->code+$7->code;
	
	
	string l1 = newLabel();
	string l2 = newLabel();
	string l3 = newLabel();

	
	code +=	commentCode($3->v);
	code+= $3->code; //i=0
	//checking if expression is true
	
	code +=	commentCode($4->v);
	code += l2+":\n";
	code+= $4->code;
	code += "\tCMP "+$4->symbol+",0\n";
	code += "\tJNE "+l1+" \n"; //if true goto l1
	code += "\tJMP "+l3+" \n"; //if false goto l3

	//inside loop
	
	code +=	commentCode($7->v);
	code += l1+":\n";
	code += $7->code;
	code += $5->code;
	code += "\tJMP "+l2+" \n";

	//outside loop
	code += l3+":\n";




	$$ = reduce(new Reducible(r,code,symbol));

}
| FOR LPAREN expression_statement expression_statement expression error RPAREN statement
{

	yylog("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
//	//string reduced =    (string)"for"+(string)"("+$3->getName()+$4->getName()+$5->getName()+")"+$7->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("for","FOR"));
	r->push_back(new SymbolInfo("(","LPAREN"));
	
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);
	}
	for (auto i = $5->v->begin(); i != $5->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	
	for (auto i = $8->v->begin(); i != $8->v->end(); ++i)
	{
		r->push_back(*i);
	}
	// code += "\t;";
	// for (auto i = r->begin(); i != r->end(); ++i)
	// {
	// 	if((*i)->getName()==";\n" || (*i)->getName()=="}\n" || (*i)->getName()=="{\n" || (*i)->getName()=="\n}" || (*i)->getName()=="\n{")
	// 	{
	// 		code += (*i)->getName()+"\t;";
	// 	}
	// 	else
	// 	{
	// 		code += (*i)->getName();
	// 	}
	// }
	// code += "\n";
	// symbol += $3->symbol+$4->symbol+$5->symbol+$8->symbol;
	code += $3->code+$4->code+$5->code+$8->code;
	$$ = reduce(new Reducible(r,code,symbol));

}
| IF LPAREN expression RPAREN statement
{
	yylog("statement : IF LPAREN expression RPAREN statement");
	////string reduced =    (string)"if" + (string)"(" + $3->getName() + (string)")" + $5->getName() ;
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("if","IF"));
	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	for (auto i = $5->v->begin(); i != $5->v->end(); ++i)
	{
		r->push_back(*i);
	}
	
	code +=	commentCode(r);
	
	code +=	commentCode($3->v);

	code+=$3->code;
	symbol += $3->symbol+$5->symbol;
	string label1 = newLabel();
	string label2 = newLabel();
	code+="\tMOV AX,"+$3->symbol+" \n";
	code+="\tCMP AX,0\n";
	code+="\tJE "+ label1 +" \n";


	
	code +=	commentCode($5->v);

	code+=$5->code;
	code+=label1+":\n";
	$$ = reduce(new Reducible(r,code,symbol));

}  %prec LOWER_THAN_ELSE ;
| IF LPAREN expression RPAREN statement ELSE statement
{
	yylog("statement : IF LPAREN expression RPAREN statement ELSE statement");
	////string reduced =    (string)"if" + (string)"(" + $3->getName() + (string)")" + $5->getName() + (string)"else" + $7->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("if","IF"));
	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	for (auto i = $5->v->begin(); i != $5->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo("else","ELSE"));
	for (auto i = $7->v->begin(); i != $7->v->end(); ++i)
	{
		r->push_back(*i);
	}
	
	code +=	commentCode(r);
	symbol += $3->symbol+$5->symbol+$7->symbol;
	
	
	string label1 = newLabel();
	string label2 = newLabel();
	code +=	commentCode($3->v);
	code+=$3->code;
	code+="\tMOV AX,"+$3->symbol+" \n";
	code+="\tCMP AX,0\n";
	code+="\tJNE "+ label1 +" \n";
	
	code +=	commentCode($7->v);
	code+=$7->code;
	code+= "\tJMP " + label2+" \n";
	code+=label1+":\n";
	
	code +=	commentCode($5->v);
	code+=$5->code;
	code+=label2+":\n";

	$$ = reduce(new Reducible(r,code,symbol));
		
}
| WHILE LPAREN expression RPAREN statement
{
	yylog("statement : WHILE LPAREN expression RPAREN statement");
//	//string reduced =    (string)"while" + (string)"(" + $3->getName() + (string)")" + $5->getName() ;
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("while","WHILE"));
	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	for (auto i = $5->v->begin(); i != $5->v->end(); ++i)
	{
		r->push_back(*i);
	}
	
	code +=	commentCode(r);
	// symbol += $3->symbol+$5->symbol;
	// code += $3->code+$5->code;
	string l1 = newLabel();
	string l2 = newLabel();
	string l3 = newLabel();
	
	code += l1+":\n";
	
	code +=	commentCode($3->v);
	code += $3->code;

	code += "\tCMP "+$3->symbol+",0\n";
	code += "\tJNE "+l2+" \n"; //if true goto l1
	code += "\tJMP "+l3+" \n"; //if false goto l3

	//inside loop
	code += l2+":\n";
	
	code +=	commentCode($5->v);
	code += $5->code;
	code += "\tJMP "+l1+" \n";

	//outside loop
	code += l3+":\n";


	$$ = reduce(new Reducible(r,code,symbol));
		
}
| PRINTLN LPAREN ID RPAREN SEMICOLON 
{
	yylog("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
//	//string reduced =    (string)"println" + (string)"(" + $3->getName() + (string)")" + (string)";\n";
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("printf","PRINTLN"));
	r->push_back(new SymbolInfo("(","LPAREN"));
	r->push_back($3);
	r->push_back(new SymbolInfo(")","RPAREN"));
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	
	code +=	commentCode(r);
	SymbolInfo* this_id = st->LookUp($3->getName());
	if(this_id==NULL)
	{
		yyerror("Undeclared variable "+$3->getName());
	}
	else
	{
		code += "\tMOV AX,"+this_id->getSymbol()+'\n';
		code += "\tMOV P,AX\n";
		code+= "\tCALL PRINT\n";
	}
	
	$$ = reduce(new Reducible(r,code,symbol));
}
| PRINTLN LPAREN ID RPAREN error SEMICOLON 
{
	yylog("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
//	//string reduced =    (string)"println" + (string)"(" + $3->getName() + (string)")" + (string)";\n";
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("println","PRINTLN"));
	r->push_back(new SymbolInfo("(","LPAREN"));
	r->push_back($3);
	SymbolInfo* this_id = st->LookUp($3->getName());
	if(this_id==NULL)
	{
		yyerror("Undeclared variable "+$3->getName());
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	$$ = reduce(new Reducible(r,code,symbol));
}
| RETURN expression SEMICOLON
{
	yylog("statement : RETURN expression SEMICOLON");
	////string reduced =    (string)"return"+(string)" " + $2->getName() + (string)";\n";
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("return ","RETURN"));
	
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
	}
	
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	symbol = $2->symbol;
	
	code +=	commentCode(r);
	code += $2->code;
	code += "\tMOV AX,"+symbol+" \n";
	code += "\tMOV STORE_RET,AX\n";

	if(current_func_id!="main")
	{
		code += "\tPOP DX\n";
		code += "\tPOP CX\n";
		code += "\tPOP BX\n";
		code += "\tPOP AX\n";
		code += "\tRET\n";
	}
	
	$$ = reduce(new Reducible(r,code,symbol));
}
| RETURN expression error SEMICOLON
{
	yylog("statement : RETURN expression SEMICOLON");
	////string reduced =    (string)"return"+(string)" " + $2->getName() + (string)";\n";
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo("return ","RETURN"));
	
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	$$ = reduce(new Reducible(r,code,symbol));
}
| type_specifier ID LPAREN parameter_list RPAREN compound_statement
{
	yylog("statement : type_specifier id LPAREN parameter_list RPAREN compound_statement");
	yyerror("Invalid scoping");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);		
		
	}
	r->push_back($2);
	
	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $4->v->begin(); i != $4->v->end(); ++i)
	{
		r->push_back(*i);	
	}
	
	r->push_back(new SymbolInfo(")","RPAREN"));
	for (auto i = $6->v->begin(); i != $6->v->end(); ++i)
	{
		r->push_back(*i);
	}
	symbol += $1->symbol+$4->symbol+$6->symbol;
	code += $1->code+$4->code+$6->code;
	$$ = reduce(new Reducible(r,code,symbol));
}
;
	  
expression_statement : SEMICOLON
{
	yylog("expression_statement : SEMICOLON");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| error SEMICOLON
{
	yylog("expression_statement : SEMICOLON");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	$$ = reduce(new Reducible(r,code,symbol));
		
}			
| expression SEMICOLON 
{
	yylog("expression_statement : expression SEMICOLON");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";

	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| expression error SEMICOLON 
{
	yylog("expression_statement : expression SEMICOLON");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";

	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(";\n","SEMICOLON"));
	$$ = reduce(new Reducible(r,code,symbol));
		
}
;
	  
variable : ID  
{
	yylog("variable : ID");
//	//string reduced =    $1->getName() ;
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back($1);
	
	
	SymbolInfo* var_id;
	string var_name = $1->getName();
	var_id = st->LookUp(var_name);
	if(var_id==NULL)
	{
		yyerror("Undeclared variable "+var_name);
	}

	symbol += var_id->getSymbol();
	//////cout << symbol << " MUL 4" << endl;

	$$ = reduce(new Reducible(r,code,symbol));
		
}
| ID LTHIRD expression RTHIRD  
{
	yylog("variable : ID LTHIRD expression RTHIRD");
//	//string reduced =    $1->getName() + (string)"[" + $3->getName() + (string)"]";

	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	r->push_back($1);
	
	SymbolInfo* this_id = st->LookUp($1->getName());
	int array_size=0;
	if(this_id==NULL)
	{
		yyerror("Undeclared variable");
	}
	else
	{
		array_size = this_id->getArraySize();
		if(array_size==0)
		{
			yyerror($1->getName()+" not an array");
		}
	}
	
	r->push_back(new SymbolInfo("[","LTHIRD"));
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
		if((*i)->getType()!="CONST_INT")
		{
			yyerror("Expression inside third brackets not an integer"); 
		}
		else
		{
			int index = stoi((*i)->getName());
			if(index>=array_size)
			{
				//yyerror("Array index out of range");
			}
			// string temp = newTemp();
			code += "\tMOV DI,"+(*i)->getName()+" \n";
			code += "\tADD DI,DI\n";
			// code += "\tMOV AX,"+$1->getName()+"[DI]\n";
			// code += "\tMOV "+temp+",AX\n";
			// this_id->setSymbol( this_id->getSymbol()+"[DI]");
			symbol+=this_id->getSymbol()+"[DI]";

		
		}
		
	}
	r->push_back(new SymbolInfo("]","RTHIRD"));
	$$ = reduce(new Reducible(r,code,symbol));
}
;
	 
 expression : logic_expression 
{
	yylog("expression : logic_expression");
	//string reduced =    $1->getName() ;
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}	
| variable ASSIGNOP logic_expression 
{
	//checking data type of variable
	SymbolInfo* var_id;
	string var_type;
	int array_size=0;
	bool index_setting = false;
	string var_name = $1->v->at(0)->getName();
	var_id = st->LookUp(var_name);
	if(var_id!=NULL)
	{
		var_type = var_id->getDataType();
		array_size = var_id->getArraySize();
		//////////////cout << var_name << " " << var_type << endl;
	}
	
	yylog("expression : variable ASSIGNOP logic_expression");
//	//string reduced =    $1->getName() + (string)"=" + $3->getName() ;
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	string arr_idx = "";
	string assigned_var_int = "";

	code += $3->code;
	code += $1->code;

	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		if((*i)->getType()=="LTHIRD")
		{
			index_setting = true;
		}
		if((*i)->getType()=="CONST_INT" && index_setting)
		{
			arr_idx=(*i)->getName();
		}
	}
	r->push_back(new SymbolInfo("=","ASSIGNOP"));

	bool exptypefloat=false;
	if($3->symbol!="")
	{
		code += "\tMOV AX,"+$3->symbol+" \n";
	}
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
		if((*i)->getType()=="CONST_FLOAT")
		{
			exptypefloat = true;
		}
		else if((*i)->getType()=="ID")
		{
			SymbolInfo* st_entry_id = st->LookUp((*i)->getName());
			if(st_entry_id!=NULL)
			{
				if(st_entry_id->fnInfo->isFunction)
				{
					////////////////cout << "enters" << endl;
					
					if(st_entry_id->fnInfo->returnType=="VOID")
					{
						if(st_entry_id->erred_line!=line_count)
						{
							yyerror("Void function used in expression");
							st_entry_id->erred_line=line_count;
						}
					}
				
		
					if(st_entry_id->fnInfo->returnType=="FLOAT")
					{
						exptypefloat = true;
					}
				}
			}

		}
	}
	if(var_type=="INT" && exptypefloat)
	{
		if(var_id->erred_line!=line_count)
		{
			yyerror("Type Mismatch");
			var_id->erred_line=line_count;
		}
	}
	else if(array_size>0 and !index_setting)
	{
		if(var_id->erred_line!=line_count)
		{
			yyerror("Type mismatch, "+var_name+" is an array");
			var_id->erred_line=line_count;
		}
		
	}
	if(index_setting)
	{
		code += "\tMOV "+var_id->getSymbol()+"[DI]"+",AX\n";
	}
	else
	{
		code += "\tMOV "+var_id->getSymbol()+",AX\n";
	}
	$$ = reduce(new Reducible(r,code,symbol));
} 	
	   ;
			
logic_expression : rel_expression 
{
	yylog("logic_expression : rel_expression");
//	//string reduced =    $1->getName();
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
} 	
| rel_expression LOGICOP rel_expression 
{
	yylog("logic_expression : rel_expression LOGICOP rel_expression");
//	//string reduced =    $1->getName() + $2->getName() + $3->getName() ;
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	string term1 = $1->symbol;
	string term2 = $3->symbol;
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		if(term1=="")
		{
			term1 = (*i)->getName();
			if((*i)->getType()=="ID")
			{
				SymbolInfo* this_id = st->LookUp(term1);
				if(this_id!=NULL)
				{
					term1 = this_id->getSymbol();
				}
			}
		}
	}
	r->push_back($2);
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
		if(term2=="")
		{
			term2 = (*i)->getName();
			if((*i)->getType()=="ID")
			{
				SymbolInfo* this_id = st->LookUp(term2);
				if(this_id!=NULL)
				{
					term2 = this_id->getSymbol();
				}
			}
		}
	}
	symbol += $1->symbol+$3->symbol;
	code += $1->code+$3->code;
	
	string temp = "";

	if($2->getName()=="&&")
	{
		string label1 = newLabel();
		string label2 = newLabel();
		temp = newTemp();
		code += "\tCMP "+term1+",0\n";
		code += "\tJE "+label1+" \n";
		code += "\tCMP "+term2+",0\n";
		code += "\tJE "+label1+" \n";
		code += "\tMOV "+temp+",1\n";
		code += "\tJMP "+label2+" \n";
		code+=label1+":\n";
		code += "\tMOV "+temp+",0\n";
		code+=label2+":\n";

	}
	symbol = temp;
	$$ = reduce(new Reducible(r,code,symbol));
		
} 	
;
			
rel_expression	: simple_expression 
{
	yylog("rel_expression : simple_expression");
//	//string reduced =    $1->getName();
	string code = "";
	string symbol = "";
	symbol +=$1->symbol;
	code +=$1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
} 
| simple_expression RELOP simple_expression 
{
	yylog("rel_expression : simple_expression RELOP simple_expression");
	////string reduced =    $1->getName() + $2->getName() + $3->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";

	string term1 = $1->symbol;
	string term2 = $3->symbol;


	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		if(term1=="")
		{
			term1 = (*i)->getName();
			if((*i)->getType()=="ID")
			{
				SymbolInfo* this_id = st->LookUp(term1);
				if(this_id!=NULL)
				{
					term1 = this_id->getSymbol();
				}
			}
		}
	}
	r->push_back($2);
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
		if(term2=="")
		{
			term2 = (*i)->getName();
			if((*i)->getType()=="ID")
			{
				SymbolInfo* this_id2 = st->LookUp(term2);
				if(this_id2!=NULL)
				{
					term2 = this_id2->getSymbol();
				}
			}
		}
	}
	// symbol += $1->symbol+$3->symbol;
	code += $1->code+$3->code;
	string jumpcode;
	string temp = newTemp();
	string l1 = newLabel();
	string l2 = newLabel();
	//<|<=|>|>=|==|!=
	if($2->getName()=="<")
	{
		jumpcode = "JL";
	}
	else if($2->getName()=="<=")
	{
		jumpcode = "JLE";
	}
	else if($2->getName()==">")
	{
		jumpcode = "JG";
	}
	else if($2->getName()==">=")
	{
		jumpcode = "JGE";
	}
	else if($2->getName()=="==")
	{
		jumpcode = "JE";
	}
	else if($2->getName()=="!=")
	{
		jumpcode = "JNE";
	}

	code+= "\tMOV AX,"+term1+" \n";
	code+= "\tCMP AX,"+term2+" \n";
	code+="\t"+jumpcode+" "+l1+" \n";
	code+="\tMOV "+temp+",0\n";
	code+="\tJMP "+l2+" \n";
	code += l1+":\n";
	code += "\tMOV "+temp+","+"1\n";
	code+=l2+":\n";

	symbol = temp;

	$$ = reduce(new Reducible(r,code,symbol));
}	
;
				
simple_expression : term  
{
	yylog("simple_expression : term");
//	//string reduced =    $1->getName() ;
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
| simple_expression ADDOP term 
{
	yylog("simple_expression : simple_expression ADDOP term");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	code += $1->code;
	string symbol = "";
	string term="";
	if($3->symbol!="")
	{
		term = $3->symbol;
		// $1->symbol="";
	}

	if($1->symbol!="")
	{
		code += "\tMOV AX,"+$1->symbol+" \n";
	}
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		if($1->symbol=="")
		{
			if((*i)->getType()=="CONST_INT")
			{
				code += "\tMOV AX,"+(*i)->getName()+" \n";
			}
			else if((*i)->getType()=="ID")
			{
				SymbolInfo* this_id = st->LookUp((*i)->getName());
				if(this_id!=NULL)
				{
					if(this_id->getDataType()=="INT")
					{
						code += "\tMOV AX,"+(*i)->getSymbol()+" \n";
					}
				}
			}
		}
		
	}
	r->push_back($2);
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
		string temp = newTemp();

		if(term=="")
		{
			term = (*i)->getName();
		}
		code += "\tADD AX,"+term+" \n";
		
		
		code += "\tMOV "+temp+",AX\n";
		symbol = temp;
	
	}
	
	$$ = reduce(new Reducible(r,code,symbol));
} 
;
					
term :	unary_expression 
{
	yylog("term : unary_expression");
//	//string reduced =    $1->getName() ;
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	//////cout << symbol << " 3" << endl;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
|  term MULOP unary_expression 
{
	yylog("term : term MULOP unary_expression");
	////string reduced =    $1->getName() + $2->getName() + $3->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	string term="";
	SymbolInfo* this_id = NULL;
	if($1->symbol!="")
	{
		term = $1->symbol;
		// $1->symbol="";
	}
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		if(term=="")
		{
			term = (*i)->getName();
		}
		////////////cout << term << endl;
	}
	r->push_back($2);
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		
		if($2->getName()=="%")
		{
			if((*i)->getName()=="0")
			{
				yyerror("Modulus by Zero");
			}
			else if((*i)->getType()=="CONST_FLOAT")
			{
				yyerror("Non-Integer operand on modulus operator");
				(*i)->setType("CONST_INT");
			}
			else if((*i)->getType()=="ID")
			{
				this_id = st->LookUp((*i)->getName());
				if(this_id->erred_line!=line_count)
				{
					if(this_id->getDataType()!="INT")
					{
						yyerror("Non-Integer operand on modulus operator");
						this_id->erred_line=line_count;
					}
				}
			}
			
		}
		r->push_back(*i);
	}
	// symbol += $1->symbol+$3->symbol;
	code += $3->code+$1->code;
	if($2->getName()=="*")
	{
		code+= "\tMOV AX,"+$3->symbol+" \n";
		//////cout << $3->symbol << " 4" << endl;
		code+= "\tMOV BX,"+term+" \n";
		code += "\tMUL BX\n";
		string temp = newTemp();
		code+="\tMOV "+temp+",AX\n";
		symbol = temp;
	}
	else
	{
		code+= "\tMOV AX,"+term+" \n";
		code+= "\tMOV BX,"+$3->symbol+" \n";
		code+="\tXOR DX,DX\n";
		code+= "\tDIV BX\n";
		string temp = newTemp();
		code+="\tMOV "+temp+",DX\n";
		symbol = temp;
	}

	$$ = reduce(new Reducible(r,code,symbol));
}
;

unary_expression : ADDOP unary_expression 
{
	yylog("unary_expression : ADDOP unary_expression");
	////string reduced =    $1->getName() + $2->getName() ;
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";

	r->push_back($1);
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
	}
	symbol += $2->symbol;
	code += $2->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}  
| NOT unary_expression 
{
	yylog("unary_expression : NOT unary_expression");
	////string reduced =    (string)"!" + $2->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";

	r->push_back(new SymbolInfo("!","NOT"));
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
	}
	symbol += $2->symbol;
	code += $2->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
} 
| factor 
{
	yylog("unary_expression : factor");
//	//string reduced =    $1->getName() ;
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	//////cout << symbol << " 2" << endl;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
} 
;
	
factor	: variable 
{
	yylog("factor : variable");
//	//string reduced =    $1->getName();
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	//////cout << symbol << " 1" << endl;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
} 
| ID LPAREN argument_list RPAREN 
{
	yylog("factor : ID LPAREN argument_list RPAREN");
//	//string reduced =    $1->getName() + (string)"(" + $3->getName() + (string)")";
	SymbolInfo* this_id;
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	string type="";
	r->push_back($1);
	this_id = st->LookUp($1->getName());
	if($1->getName()=="println")
	{

	}
	else
	{
		if(this_id==NULL)
		{
			yyerror("Undeclared function "+$1->getName());
		}
		else
		{
			if(!this_id->fnInfo->isFunction)
			{
				yyerror($1->getName()+" is not a function.");
			}
			
		}
	}

	
	
	
	r->push_back(new SymbolInfo("(","LPAREN"));
	int idx=0;
	
	int pc=0;
	vector<SymbolInfo*>* call_args = new vector<SymbolInfo*>();
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		if((*i)->getType()=="COMMA")
		{
			pc++;
		}
		else if((*i)->getType()=="ID")
		{
			call_args->push_back((*i));
		}
	}
	
	if(this_id!=NULL)
	{
		if(this_id->fnInfo->isFunction)
		{
			if(pc<this_id->fnInfo->parameterCount-1 || pc>=this_id->fnInfo->parameterCount)
			{
				if(this_id->erred_line!=line_count){
					yyerror("Total number of arguments mismatch in function "+$1->getName());
					this_id->erred_line=line_count;
				}
			}			
		}
	}

	
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
		if(this_id!=NULL)
		{
			if(this_id->fnInfo->isFunction)
			{
				////////cout << (*i)->getName() << " " << (*i)->getType() << endl;
				if((*i)->getType()=="CONST_INT")
				{
					if(this_id->fnInfo->getParamType(idx)!="INT")
					{
						if(this_id->erred_line!=line_count){
							yyerror(to_string(idx+1)+"th argument mismatch in function "+$1->getName());
							this_id->erred_line=line_count;
						}
					}
				}
				else if((*i)->getType()=="CONST_FLOAT")
				{
					if(this_id->fnInfo->getParamType(idx)!="FLOAT")
					{
						if(this_id->erred_line!=line_count){
							yyerror(to_string(idx+1)+"th argument mismatch in function "+$1->getName());
							this_id->erred_line=line_count;
							}
					}
				}
				else if((*i)->getType()=="ID")
				{
					SymbolInfo* p = st->LookUp((*i)->getName());
					if(p==NULL)
					{
						p = getParameterID((*i)->getName());
					}
					type = p->getDataType();
					////////cout << type << " typeif ID " << p->getName() << endl;
					int n = p->getArraySize();
					
					if(n>0)
					{
						auto j=i+1;
						if(j != $3->v->end())
						{
							
							if((*j)->getType()!="LTHIRD")
							{

								if(this_id->erred_line!=line_count){
									yyerror("Type mismatch, "+(*i)->getName()+" is an array");
									this_id->erred_line=line_count;
								}	
							}
						}
						else
						{
							if(this_id->erred_line!=line_count){
									yyerror("Type mismatch, "+(*i)->getName()+" is an array");
									this_id->erred_line=line_count;
								}
						}
						
						
					}
					
					
					// if(this_id->fnInfo->getParamType(idx)!=type)
					// {
					// 	if(this_id->erred_line!=line_count){
					// 		////////cout << this_id->fnInfo->getParamType(idx) << endl;
					// 		////////cout << type << endl;

					// 		yyerror(to_string(idx+1)+"th argument mismatch 3 in function "+$1->getName());
					// 		////////////cout << this_id->fnInfo->getParamType(idx) << " " << type << " " <<line_count<< endl;
					// 		this_id->erred_line=line_count;
					// 		}
					// }
					
				
				}
				if((*i)->getType()=="COMMA")
				{
					idx++;
				}
			}		
		}
		
	}
	
	
	

	if(this_id!=NULL)
	{
		for(int i=0,idx=0;i<pc+1;i++)
		{
			string dec_arg = this_id->fnInfo->getParamSymbol(i);
			string call_arg = call_args->at(i)->getName();
			// //////cout << call_arg << " " << endl;
			if($3->v->at(idx)->getType()!="COMMA")
			{
				//////cout  << " comes here" << endl;
				SymbolInfo* p;
				if(inside_funcdef)
				{
					p = getParameterID(call_arg);
					//cout << "PROCEDURE_"+this_id->getSymbol() << " inside own" << endl;
					//cout << call_arg << endl;
					if(p!=NULL)
					{
						
						//cout << "=====" << endl;
						//cout << p->getSymbol() << endl;
						//cout << "=====" << endl;

					}
				}
				else
				{
					p = st->LookUp(call_arg);
					//cout << "PROCEDURE_"+this_id->getSymbol()  << endl;
					//cout << call_arg << endl;
					//cout << st->cur->id << endl;
					if(p!=NULL)
					{
						//cout << "=====" << endl;
						//cout << p->getName() << endl;
						//cout << p->getSymbol() << endl;
						//cout << "=====" << endl;
					}
				} 
				if(p!=NULL)
					call_arg = p->getSymbol();
				// //////cout << call_arg << " " << this_id->getSymbol() << endl;
				// //////cout << pc << endl;
			}

			code += "\tMOV AX,"+call_arg+" \n";
			code += "\tMOV "+dec_arg+",AX\n";
			idx+=2;
		}

		code+="\tCALL PROCEDURE_"+this_id->getSymbol()+" \n";
		string temp = newTemp();
		code += "\tMOV AX,STORE_RET\n";
		code += "\tMOV "+temp+",AX\n";

		symbol = temp;

	}




	delete call_args;
	r->push_back(new SymbolInfo(")","RPAREN"));
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| ID LPAREN argument_list error RPAREN 
{
	yylog("factor : ID LPAREN argument_list RPAREN");
//	//string reduced =    $1->getName() + (string)"(" + $3->getName() + (string)")";
	SymbolInfo* this_id;
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";

	r->push_back($1);
	this_id = st->LookUp($1->getName());
	if(this_id==NULL)
	{
		yyerror("Undeclared function "+$1->getName());
	}
	else
	{
		if(!this_id->fnInfo->isFunction)
		{
			yyerror($1->getName()+" is not a function.");
		}
		
	}
	
	
	r->push_back(new SymbolInfo("(","LPAREN"));
	int idx=0;
	
	int pc=0;
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		if((*i)->getType()=="COMMA")
		{
			pc++;
		}
	}
	
	if(this_id!=NULL)
	{
		if(this_id->fnInfo->isFunction)
		{
			if(pc<this_id->fnInfo->parameterCount-1 || pc>=this_id->fnInfo->parameterCount)
			{
				if(this_id->erred_line!=line_count){
					yyerror("Total number of arguments mismatch in function "+$1->getName());
					this_id->erred_line=line_count;
				}
			}			
		}
	}

	
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
		if(this_id!=NULL)
		{
			if(this_id->fnInfo->isFunction)
			{
				if((*i)->getType()=="CONST_INT")
				{
					if(this_id->fnInfo->getParamType(idx)!="INT")
					{
						if(this_id->erred_line!=line_count){
							yyerror(to_string(idx+1)+"th argument mismatch in function "+$1->getName());
							this_id->erred_line=line_count;
						}
					}
				}
				else if((*i)->getType()=="CONST_FLOAT")
				{
					if(this_id->fnInfo->getParamType(idx)!="FLOAT")
					{
						if(this_id->erred_line!=line_count){
							yyerror(to_string(idx+1)+"th argument mismatch in function "+$1->getName());
							this_id->erred_line=line_count;
							}
					}
				}
				else if((*i)->getType()=="ID")
				{
					SymbolInfo* p = st->LookUp((*i)->getName());
					string type = p->getDataType();
					int n = p->getArraySize();
					
					if(n>0)
					{
						auto j=i+1;
						if(j != $3->v->end())
						{
							
							if((*j)->getType()!="LTHIRD")
							{

								if(this_id->erred_line!=line_count){
									yyerror("Type mismatch, "+(*i)->getName()+" is an array");
									this_id->erred_line=line_count;
								}	
							}
						}
						else
						{
							if(this_id->erred_line!=line_count){
									yyerror("Type mismatch, "+(*i)->getName()+" is an array");
									this_id->erred_line=line_count;
								}
						}
						
						
					}
					
					
					if(this_id->fnInfo->getParamType(idx)!=type)
					{
						if(this_id->erred_line!=line_count){
							yyerror(to_string(idx+1)+"th argument mismatch in function "+$1->getName());
							////////////cout << this_id->fnInfo->getParamType(idx) << " " << type << " " <<line_count<< endl;
							this_id->erred_line=line_count;
							}
					}
					
				
				}
				if((*i)->getType()=="COMMA")
				{
					idx++;
				}
			}		
		}
		
	}
	
	

	r->push_back(new SymbolInfo(")","RPAREN"));
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| LPAREN expression RPAREN 
{
	yylog("factor : LPAREN expression RPAREN");
	//string reduced =    (string)"(" + $2->getName() + (string)")";

	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";

	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	symbol += $2->symbol;
	code += $2->code;
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| LPAREN expression error RPAREN 
{
	yylog("factor : LPAREN expression RPAREN");
	//string reduced =    (string)"(" + $2->getName() + (string)")";

	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";

	r->push_back(new SymbolInfo("(","LPAREN"));
	for (auto i = $2->v->begin(); i != $2->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(")","RPAREN"));
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| CONST_INT 
{
	yylog("factor : CONST_INT");
	
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	symbol = $1->getName();
	r->push_back($1);
	$$ = reduce(new Reducible(r,code,symbol));
		
} 
| CONST_FLOAT 
{
	yylog("factor : CONST_FLOAT");
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	symbol = $1->getName();
	r->push_back($1);
	$$ = reduce(new Reducible(r,code,symbol));
		
}
| variable INCOP 
{
	yylog("factor : variable INCOP");
//	//string reduced =    $1->getName()+(string)"++";
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	bool index_setting=false;
	string arr_idx="";
	string var_name = $1->v->at(0)->getName();
	SymbolInfo* this_id = st->LookUp(var_name);
	if(this_id!=NULL)
	{
		var_name = this_id->getSymbol();
	}
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		if((*i)->getType()=="LTHIRD")
		{
			index_setting = true;
		}
		if((*i)->getType()=="CONST_INT" && index_setting)
		{
			arr_idx=(*i)->getName();
		}
	}
	r->push_back(new SymbolInfo("++","INCOP"));
	if(arr_idx=="")
	{
		code += "\tINC "+var_name+" \n";
		symbol += var_name;
	}
	else
	{
		code+="\tMOV DI,"+arr_idx+" \n";
		code+="\tADD DI,DI\n";
		code += "\tINC "+var_name+"[DI]\n";
		symbol += var_name+"[DI]";
		//////////cout << code << endl;
	}
	
	$$ = reduce(new Reducible(r,code,symbol));
} 
| variable DECOP 
{
	yylog("factor : variable DECOP");
//	//string reduced =    $1->getName()+(string)"++";
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	bool index_setting=false;
	string arr_idx="";
	string var_name = $1->v->at(0)->getName();
	SymbolInfo* this_id = st->LookUp(var_name);
	if(this_id!=NULL)
	{
		var_name = this_id->getSymbol();
	}
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
		if((*i)->getType()=="LTHIRD")
		{
			index_setting = true;
		}
		if((*i)->getType()=="CONST_INT" && index_setting)
		{
			arr_idx=(*i)->getName();
		}
	}
	r->push_back(new SymbolInfo("--","DECOP"));
	if(arr_idx=="")
	{
		code += "\tDEC "+var_name+" \n";
		symbol += var_name;
	}
	else
	{
		code+="\tMOV DI,"+arr_idx+" \n";
		code+="\tADD DI,DI\n";
		code += "\tDEC "+var_name+"[DI]\n";
		symbol += var_name+"[DI]";
		//////////cout << code << endl;
	}
	
	$$ = reduce(new Reducible(r,code,symbol));
} 
	;
	
argument_list : arguments 
{
	yylog("argument_list : arguments");
//	//string reduced =    $1->getName();
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}	
;
	
arguments : arguments COMMA logic_expression 
{
	yylog("arguments : arguments COMMA logic_expression");
//	//string reduced =    $1->getName() + (string)"," + $3->getName();
	vector<SymbolInfo*>* r = new vector<SymbolInfo*>();
	string code = "";
	string symbol = "";
	for (auto i = $1->v->begin(); i != $1->v->end(); ++i)
	{
		r->push_back(*i);
	}
	r->push_back(new SymbolInfo(",","COMMA"));
	for (auto i = $3->v->begin(); i != $3->v->end(); ++i)
	{
		r->push_back(*i);
	}
	symbol += $1->symbol+$3->symbol;
	code += $1->code+$3->code;
	$$ = reduce(new Reducible(r,code,symbol));
}
| logic_expression 
{
	yylog("arguments : logic_expression");
	////string reduced =    $1->getName();
	string code = "";
	string symbol = "";
	symbol += $1->symbol;
	code += $1->code;
	$$ = reduce(new Reducible($1->v,code,symbol));
		
}
;
 

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
	yyparse();
	fclose(yyin);
	
	st->printAllScopeTable();
	
	outputFile << "\n\nTotal lines : " << line_count-1 << endl;	
	outputFile << "Total errors : " << error << endl;
	
	if(error==0)
	{
		initialize_asm();
	}
	outputFile << endl;
	outputFile.close();
	errorFile.close();
	codeFile.close();
	opcodeFile.close();
	return 0;
}