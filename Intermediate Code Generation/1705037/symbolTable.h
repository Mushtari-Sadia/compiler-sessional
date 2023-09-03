#include<bits/stdc++.h>
#include<iostream>
#include<string>
#include <time.h>
using namespace std;


//extern ofstream outputFile;
extern ofstream outputFile;

#ifndef FUNCTIONINFO
#define FUNCTIONINFO
class FunctionInfo
{
	public :
	string returnType;
	vector< pair <string,string> > parameter_list;
	vector<string> parameter_list_symbols;
	int parameterCount;
	bool isFunction;
	FunctionInfo(){
		parameterCount=0;
		isFunction = false;
	}
	
	void addParameter(string type,string id)
	{
		isFunction = true;
		parameterCount++;
		parameter_list.push_back( make_pair(type,id) );
		parameter_list_symbols.push_back("");
	}
	void addParameter(string type,string id,string symbol)
	{
		isFunction = true;
		parameterCount++;
		parameter_list.push_back( make_pair(type,id) );
		parameter_list_symbols.push_back(symbol);
	}
	
	void setReturnType(string rt)
	{
		isFunction = true;
		returnType = rt;
	}
	
	string getParamType(int index)
	{
		if(index>=parameterCount)
			return "";
		return parameter_list.at(index).first;
	}
	string getParamSymbol(int index)
	{
		if(index>=parameterCount)
			return "";
		if(parameter_list_symbols.at(index)=="")
			return parameter_list.at(index).second;
		return parameter_list_symbols.at(index);
	}
		
};
#endif //FUNCTIONINFO



#ifndef SYMBOLINFO
#define SYMBOLINFO

class SymbolInfo
{
    string name;
    string type;
    string datatype;
    int array_size;
	string symbol;
    
    public:
        SymbolInfo* next;
        FunctionInfo* fnInfo;
		string code;
        int erred_line=-1;
        SymbolInfo(string name,string type)
        {
            this->name = name;
            this->type = type;
            datatype = "";
            next = NULL;
            fnInfo = new FunctionInfo();
            array_size=0;
			code = "";
			symbol = "";
        }
		SymbolInfo(string name,string type,string symbol)
        {
            this->name = name;
            this->type = type;
            datatype = "";
            next = NULL;
            fnInfo = new FunctionInfo();
            array_size=0;
			code = "";
			this->symbol = symbol;
        }
        void setName(string name)
        {
            this->name = name;
        }
        string getName()
        {
            return name;
        }

        void setType(string type)
        {
            this->type = type;
        }
        string getType()
        {
            return type;
        }
		void setSymbol(string symbol)
        {
            this->symbol = symbol;
        }
        string getSymbol()
        {
            return symbol;
        }
        
        void setDataType(string type)
        {
            this->datatype = type;
        }
        string getDataType()
        {
            return datatype;
        } 
        
        bool setArraySize(string sz)
        {
            array_size = stoi(sz);
            if(array_size==0)
            	return false;
            return true;
        }
        int getArraySize()
        {
            return array_size;
        } 
		string getCode()
		{
			return code;
		}
//        ~SymbolInfo()
//        {
//            delete next;
//        }


};

#endif //SYMBOLINFO

#ifndef REDUCIBLE
#define REDUCIBLE
class Reducible{
	public :
	vector<SymbolInfo*>* v;
	string code;
	string symbol;

	Reducible()
	{
		v = new vector<SymbolInfo*>();
		code = "";
		symbol = "";

	}
	Reducible(vector<SymbolInfo*>* r,string code)
	{
		this->v = r;
		this->code = code;
	}
	Reducible(vector<SymbolInfo*>* r,string code,string symbol)
	{
		this->v = r;
		this->code = code;
		this->symbol = symbol;
	}
	~Reducible()
	{
		delete v;
	}
};
#endif

#ifndef SCOPETABLE
#define SCOPETABLE

/**CHAINING METHOD**/
class ScopeTable
{
    SymbolInfo **T;
    int total_buckets;
    public :
        string id;
        int count_popped_tables;
        ScopeTable* parentScope;
        //string id = did not understand

        ScopeTable(int N)
        {
            //outputFile << "New ScopeTable Created"<<endl;
            parentScope = NULL;
            total_buckets = N;
            count_popped_tables = 0;
            T = new SymbolInfo*[N];
            for(int i=0;i<N;i++)
            {
                T[i] = NULL;
            }
        }
        
        int Hash(string name)
        {
	    int sum_ascii=0;
	    for(int i=0;i<name.length();i++)
	    {
		sum_ascii+=(int)name[i];
	    }
	//    if(sum_ascii%total_buckets==0)
	//        return 1; //why?
	    return sum_ascii%total_buckets;
	}
	
        bool Insert(SymbolInfo* obj)
        {
	     //need to do a search here, repeat symbol not allowed. if search true return false from insert
	     SymbolInfo* x = lookUp(obj->getName());
	     if(x!=NULL)
	     {
		 return false;
	     }

	     int h=Hash(obj->getName());
	     SymbolInfo* prev = NULL; //creating empty because we will store prev pointer here
	     SymbolInfo* cur = T[h]; //taking whatever is in hash index of table
	     int pos_in_chain = 0;

	     string name = obj->getName();
	     string type = obj->getType();
		 string symbol = obj->getSymbol();


	     while(cur!=NULL)
	     {
		 prev = cur;
		 cur = cur->next; // moving forward in list
		 pos_in_chain++;
	     }
	     if(cur==NULL) //location found
	     {
		 cur = new SymbolInfo(name,type,symbol);
		 if(prev==NULL) //no previous entries at this location
		 {
		     T[h] = cur;
		 }
		 else
		 {
		     prev->next = cur; // inserted node is inserted at end of list
		 }
	//         outputFile << "I " << obj->getName() << " " << obj->getType() << endl;
		 //outputFile << obj->getName() << " Inserted at ScopeTable#" << id << " at position " << h << "," << pos_in_chain << endl;
		 
		 return true;
	     }
	     return false;
	}

        SymbolInfo* lookUp(string name)
        {
	    int h=Hash(name);

	    SymbolInfo *x = T[h];
	    int pos_in_chain = 0;
	    while(x!=NULL)
	    {
		if(x->getName() == name)
		{
		    //outputFile << " Found in ScopeTable# " << id << " at position " << h << "," << pos_in_chain << endl;
		    //outputFile << "\n" << name << " already exists in current ScopeTable" << endl;
		    return x;
		}
		x = x->next;
		pos_in_chain++;
	    }
	    return NULL;
	}

        bool deleteEntry(string name)
        {
	    SymbolInfo* a = lookUp(name);
	     if(a==NULL)
	     {
		 return false;
	     }
	    int h=Hash(name);
	    SymbolInfo *prev = NULL;
	    SymbolInfo* x = T[h];
	    int pos_in_chain=0;
	    while(x!=NULL)
	    {
		if(x->getName() == name)
		{
	//            //outputFile << x->key << " exists at hash " << h << endl;
		    if(prev!=NULL)
		    {
		        prev->next = x->next; /**POINTING previous in list to next in list thus removing key from list, if there is a previous pointer**/
		        delete x;
		    }
		    else
		    {
		        T[h]=x->next;/**x was head of list**/
		        delete x;
		    }

		    //outputFile << "Deleted key from ScopeTable#" << id << " at position " << h << "," << pos_in_chain << endl;
		    return true;
		}
		prev = x;
		x = x->next;
		pos_in_chain++;
	    }
	    return false;

	}
        void printScopeTable()
        {
	    outputFile<< "\nScopeTable # " << id;
	    for(int i=0;i<total_buckets;i++)
	    {
		SymbolInfo *x = T[i];
		if(x==NULL)
			continue;
		outputFile<<"\n "<< i << " --> " ;
		while(x!=NULL)
		{
		    outputFile << "< " << x->getName() << " : " << x->getType() <<"> ";
		    x=x->next;
		}
		//outputFile << endl;
	    }
	}
        ~ScopeTable()
        {
            for(int i=0;i<total_buckets;i++)
             {
                if (T[i] != NULL)
                   delete T[i];
             }
            delete[] T;
        }

};
#endif //SCOPETABLE


#ifndef SYMBOLTABLE
#define SYMBOLTABLE
class SymbolTable
{
    public:
        ScopeTable* cur;

        SymbolTable(int N)
        {
            cur = new ScopeTable(N);
            cur->id = "1";
//            outputFile << "New ScopeTable with id " << cur->id << " created" << endl;
        }

        void enterScope(int total_buckets)
	{
	    ScopeTable* t = new ScopeTable(total_buckets);

	    if(!t)
	    {
		outputFile << "Stack Overflow" << endl;
		return;
	    }

	    t->parentScope = cur;
	    cur = t;
	    cur->id = cur->parentScope->id + "_" + to_string(cur->parentScope->count_popped_tables + 1);

	   // outputFile << "New ScopeTable with id " << cur->id << " created" << endl;

	}
        void exitScope()
	{
  	    printAllScopeTable();
	    ScopeTable* t;
	    string id;
	    if(cur==NULL)
	    {
		outputFile << "Stack Underflow" << endl;
		return;
	    }
	    else
	    {
		t = cur;
		cur = cur->parentScope;
		t->parentScope = NULL;
		id = t->id;
		delete t;

		cur->count_popped_tables++;
	    }
	    
	   // outputFile << "ScopeTable with id " << id << " removed" << endl;
	}

        bool Insert(SymbolInfo* obj)
	{
	    return cur->Insert(obj);
	}
        bool Remove(string name)
        {
	    return cur->deleteEntry(name);
	}
        SymbolInfo* LookUp(string name)
        {
	//    outputFile << "Look up happening" << endl;
	    ScopeTable* temp = cur;
	    SymbolInfo* x = NULL;
	    while(x==NULL)
	    {
		x = temp->lookUp(name);
		temp = temp->parentScope;
		if(temp==NULL)
		    break;
	    }
	    return x;

	}

	void printCurrentScopeTable()
	{
	    cur->printScopeTable();
	}

	void printAllScopeTable()
	{
	    ScopeTable* temp = cur;
	    while(temp!=NULL)
	    {
		temp->printScopeTable();
		outputFile << endl;
		temp = temp->parentScope;
	    }
	}

        ~SymbolTable()
        {
            delete cur;
        }

};
#endif //SYMBOLTABLE
