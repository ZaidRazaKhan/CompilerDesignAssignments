%{
#include<stdio.h> 
#include<stdlib.h> 
#include<string.h>
#include<iostream>
#include<map>
using namespace std;


// Global Variables
char parserInput[10000];
string tokenizedOutput;
char currentToken;
int count=0;

// Function declarations
char nextToken(){
	return parserInput[count++];
}

void tokenize(string);
int K();
int Fprime();
int F();
int Tprime();
int T();
int Eprime();
int E();
int S();
bool inval = true;

%}

%%

.* {
	// Tokenise the input string
	tokenize(yytext);
	// Start Parsing the input
	count=0;
	currentToken=nextToken();
	if(S())
		printf("%-25s%-100s%-10s", tokenizedOutput.c_str(), "VALID STATEMENT", " ");
	else
		printf("INVALID STATEMENT");	
}


%%
char get_token(){
	return parserInput[count++];
}

bool isdigit(char ch) {    
    int ascii=(int)ch;
    if(ascii >= 48 && ascii <= 57)
        return true;
    else 
        return false;    
}

bool isalpha(char ch){
    int ascii=(int)ch;
    if((ascii >= 65 && ascii <= 90)||(ascii >= 97 && ascii <= 122))
    	return true;
    else
        return false;    
}

bool isalnum(char ch){
    return (isalpha(ch) || isdigit(ch));
}
void tokenize(string yytext){
	inval = true;
	unsigned int i=0, c=0;
	tokenizedOutput="";
    int idCount=1;
    map<string,int> identifierMap;
	for(;i<yytext.length();i++){
		// validating identifier
		if(isalpha(yytext[i]) || yytext[i]=='_'){
			string id;
			while(isalnum(yytext[i]) || yytext[i]=='_'){
				id+=yytext[i];
				i++;
			} 
			tokenizedOutput+="id";
			map<string,int>::iterator it=identifierMap.find(id);
			if(it==identifierMap.end())
            {
                identifierMap.insert(pair<string,int> (id, idCount));
                tokenizedOutput+=to_string(idCount);
                idCount++;
            }    
            else
            {
                tokenizedOutput+=to_string(identifierMap[id]);
            }    
			parserInput[c++]='i';
			i--;
		}
		
		// validating intconst & floatconst
		else if(isdigit(yytext[i]) || yytext[i]=='.'){
				bool is_float=false;
            if(yytext[i]=='.')
                is_float=true;
            while(isdigit(yytext[i])) 
                i++;
            if(yytext[i]=='.')
            {
                is_float=true;
                i++;
            }
            while(isdigit(yytext[i])) 
                i++;
            parserInput[c++]='c';
            i--;
            if(is_float)
                tokenizedOutput+="floatconst";
            else
                tokenizedOutput+="intconst";    
		}
	
		// validating arithmetic operators
		else if(yytext[i]=='+'||yytext[i]=='-'||yytext[i]=='*'||yytext[i]=='/'||yytext[i]=='='||yytext[i]=='('||yytext[i]==')'||yytext[i]=='^'){
					tokenizedOutput+=yytext[i];
					parserInput[c++]=yytext[i];
		}

		else if(yytext[i] != ' '){
			inval = false;
			break;
		}
		// else
			
	}
	parserInput[c++]='$'; // To delimite the tokenised string
	parserInput[c]='\0';

}

// Functions for each non-terminals

int S(){
	// Production S --> id = E
	if(!inval)return 0;
	if(currentToken=='i')
		{
			currentToken=nextToken();
			if(currentToken=='='){
				currentToken=nextToken();
				if(E()){ 
					if(currentToken=='$') // End of the string return true
						return 1; 
					else 
						return 0;
				}
			}
			else
				return 0;
		}
	else if(currentToken=='$') // Empty string return true
		return 1;
	else
		return 0;
}

int E(){
	// Production E --> TE`
	if(T())
		return Eprime();
	else
		return 0;
}

int Eprime(){
	// Production E` --> +TE` | -TE` | e
	if(currentToken=='+' || currentToken=='-'){
		currentToken=nextToken();
		if(T())
			return Eprime();
		else
			return 0;
	}
	else if(currentToken==')' || currentToken=='$')
		return 1;
	else
		return 0;
}

int T(){
	// Production T --> FT`
	if(F())
		return Tprime();
	else
		return 0;
}

int Tprime(){
	// Production T` --> *FT` | /FT` | e
	if(currentToken=='*' || currentToken=='/'){
		currentToken=nextToken();
		if(F())
			return Tprime();
		else
			return 0;
		}
	else if(currentToken=='+' || currentToken=='-' ||currentToken==')' || currentToken=='$')
		return 1;
	else
		return 0;
}

int F(){
	// Production F --> KF`
	if(K())
		return Fprime();
	else
		return 0;
}

int Fprime(){
	// Production F` --> ^F | e
	if(currentToken=='^'){
		currentToken=nextToken();
		return F();
	}
	else if(currentToken=='*' || currentToken=='/' ||currentToken=='+' || currentToken=='-' ||currentToken==')' || currentToken=='$')
		return 1;
	else 
		return 0;
}

int K(){
	// Production K --> (E) | id | const
	if(currentToken=='('){
			currentToken=nextToken();
			if(E()){
				if(currentToken==')'){	currentToken=nextToken(); 
					return 1;}
				else return 0;
			}
			else
				return 0;
	}
	else if(currentToken=='i'|| currentToken=='c'){
		currentToken=nextToken();
		return 1;
	}
	else
		return 0;
}

int main(int argc, char** argv){
	extern FILE *yyin;
	yyin = fopen(argv[1], "r"); 
	yylex();
	printf("\n");
	return 0;
}
