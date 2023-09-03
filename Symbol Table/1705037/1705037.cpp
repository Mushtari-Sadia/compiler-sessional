#include<bits/stdc++.h>
#include<iostream>
#include<string>
#include <time.h>
using namespace std;

ofstream outputFile("output.txt");

class SymbolInfo
{
    string name;
    string type;
    public:
        SymbolInfo* next;
        SymbolInfo(string name,string type)
        {
            this->name = name;
            this->type = type;
            next = NULL;
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
//        ~SymbolInfo()
//        {
//            delete next;
//        }


};


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
//            outputFile << "New ScopeTable Created"<<endl;
            parentScope = NULL;
            total_buckets = N;
            count_popped_tables = 0;
            T = new SymbolInfo*[N];
            for(int i=0;i<N;i++)
            {
                T[i] = NULL;
            }
        }
        int Hash(string name);
        bool Insert(SymbolInfo* obj);
        SymbolInfo* lookUp(string name);
        bool deleteEntry(string name);
        void printScopeTable();
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

int ScopeTable::Hash(string name)
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

bool ScopeTable::Insert(SymbolInfo* obj)
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


     while(cur!=NULL)
     {
         prev = cur;
         cur = cur->next; // moving forward in list
         pos_in_chain++;
     }
     if(cur==NULL) //location found
     {
         cur = new SymbolInfo(name,type);
         if(prev==NULL) //no previous entries at this location
         {
             T[h] = cur;
         }
         else
         {
             prev->next = cur; // inserted node is inserted at end of list
         }
//         outputFile << "I " << obj->getName() << " " << obj->getType() << endl;
         outputFile << "Inserted at ScopeTable#" << id << " at position " << h << "," << pos_in_chain << endl;
         return true;
     }
}

/***just name or name+type??***/
SymbolInfo* ScopeTable::lookUp(string name)
{
    int h=Hash(name);

    SymbolInfo *x = T[h];
    int pos_in_chain = 0;
    while(x!=NULL)
    {
        if(x->getName() == name)
        {
            outputFile << " Found in ScopeTable# " << id << " at position " << h << "," << pos_in_chain << endl;
            return x;
        }
        x = x->next;
        pos_in_chain++;
    }
    return NULL;
}

bool ScopeTable::deleteEntry(string name)
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
//            outputFile << x->key << " exists at hash " << h << endl;
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

            outputFile << "Deleted key from ScopeTable#" << id << " at position " << h << "," << pos_in_chain << endl;
            return true;
        }
        prev = x;
        x = x->next;
        pos_in_chain++;
    }
    return false;

}

void ScopeTable::printScopeTable()
{
    outputFile<< "\nScopeTable # " << id << endl;
    for(int i=0;i<total_buckets;i++)
    {
        SymbolInfo *x = T[i];
        outputFile<< i << " --> " ;
        while(x!=NULL)
        {
            outputFile << "<" << x->getName() << " : " << x->getType() <<"> ";
            x=x->next;
        }
        outputFile << endl;
    }
}

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

        void enterScope(int total_buckets);
        void exitScope();
        bool Insert(SymbolInfo* obj);
        bool Remove(string name);
        SymbolInfo* LookUp(string name);
        void printCurrentScopeTable();
        void printAllScopeTable();

        ~SymbolTable()
        {
            delete cur;
        }

};

void SymbolTable::enterScope(int total_buckets)
{
    ScopeTable* t = new ScopeTable(total_buckets);

    if(!t)
    {
        outputFile << "Stack Overflow" << endl;
        return;
    }

    t->parentScope = cur;
    cur = t;
    cur->id = cur->parentScope->id + "." + to_string(cur->parentScope->count_popped_tables + 1);

    outputFile << "New ScopeTable with id " << cur->id << " created" << endl;

}


void SymbolTable::exitScope()
{
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
    outputFile << "ScopeTable with id " << id << " removed" << endl;
}

bool SymbolTable::Insert(SymbolInfo* obj)
{
    return cur->Insert(obj);
}

bool SymbolTable::Remove(string name)
{
    return cur->deleteEntry(name);
}

SymbolInfo* SymbolTable::LookUp(string name)
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

void SymbolTable::printCurrentScopeTable()
{
    cur->printScopeTable();
}

void SymbolTable::printAllScopeTable()
{
    ScopeTable* temp = cur;
    while(temp!=NULL)
    {
        temp->printScopeTable();
        outputFile << endl;
        temp = temp->parentScope;
    }
}


int main()
{
    SymbolTable *st;
    ifstream inputFile("input.txt");
    ifstream print_input_file("input.txt");
    int N;

    string l;
    getline(print_input_file,l);//skipping bucket size to match sample output file


    if(inputFile.is_open())
    {

        inputFile >> N;
        st = new SymbolTable(N);
        while(true)
        {
            string line;
            getline(print_input_file,line);
            outputFile << line <<"\n"<< endl;
            string op;
            inputFile>>op;
            if(op=="I")
            {
                string name,type;
                inputFile >> name;
                inputFile >> type;
                if(!st->Insert(new SymbolInfo(name,type)))
                {
                    outputFile << "<" << name << "," << type << ">" << "already exists in current scopeTable." << endl;
                }
            }
            else if(op=="L")
            {
                string name;
                inputFile >> name;
                SymbolInfo* s = st->LookUp(name);
                if(s==NULL)
                {
                    outputFile << "Not found" << endl;
                }
            }
            else if(op=="D")
            {
                string name;
                inputFile >> name;
                if(!st->Remove(name))
                {
                    outputFile<< "Not found" <<endl;
                }
            }
            else if(op=="P")
            {
                string c;
                inputFile >> c;
                if(c=="A")
                {
                    st->printAllScopeTable();
//                    outputFile << "printed All" << endl;
                }
                else if(c=="C")
                {
                    st->printCurrentScopeTable();
                }

            }
            else if(op=="S")
            {
                st->enterScope(N);
            }
            else if(op=="E")
            {
                st->exitScope();
            }

            if(inputFile.eof())
                break;
            outputFile << endl;
        }

        inputFile.close();
        outputFile.close();


    }
    else
    {
        cerr << "Error Opening File" << endl;
        return 0;
    }

}



