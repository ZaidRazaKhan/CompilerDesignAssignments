%{
#include<stdio.h>
#include<stdlib.h>
#include<bits/stdc++.h>
#include<fstream>
#include<string>
using namespace std;
  
int numberOfFinalStates; // number of final states in the finite state automata
int numberOfSymbols; // size of the input alphabet
bool is_e_nfa; // indicates the presence or absence of E-transitions
map <char,int> alphabet_map; // maps the input alphabets onto their indices in the table
vector <char> alphabet;
vector <int> states; // vector of states
vector <int> finalStates; // vector of final states
vector <vector <string> > NTrans; // NFA Transition Table
vector <vector <string> > TransConstruct; // DFA Transition Table
map <int,string> newDfaStates; // For the newly constructed DFA

  // Function declaration
void subsetConstruction();
void readNFA ();
int move_DFA (int, char);
vector <int> moveNFA (vector <int>, char);
vector <int> Eclosure (vector <int>);
void DFA (string);
char* toChar(string);
void printNewDFA();  
  // Function definitions
bool isFinalInNewDFA (string state){
    // Checks whether input state of DFA is final state or not   
  for(int i=0;i<finalStates.size(); i++){
    char ch=finalStates[i]+48;
    for(int j=0;j<state.size(); j++){
      if (state[j]==ch)
        return true;
    } 
  }  
  return false;
}
void printNewDFA(){
  cout<<"Newly constructed DFA"<<endl;
  for(int i = 0 ; i < newDfaStates.size() ; i ++){
    cout<<newDfaStates[i]<<" ";
  }
  cout<<endl;
  for(int i = 0 ; i  < newDfaStates.size() ; i ++){
    if(isFinalInNewDFA(newDfaStates[i]))cout<<newDfaStates[i]<<" ";
  }
  cout<<endl;
  for(int i = 0 ; i < numberOfSymbols ; i++){
    for (map<char,int>::iterator it=alphabet_map.begin(); it!=alphabet_map.end(); ++it){
      if(it == alphabet_map.begin())continue;
      cout << it->first << " ";
    }
  }
  cout<<endl;
  for(int i = 0 ; i < TransConstruct.size() ; i ++){
    for(int j = 0  ; j < alphabet.size() ; j++ ){
      cout<<TransConstruct[i][j]<<" ";
    }
    cout<<endl;
  }

  
}

// Code for finding the eclosure
vector <int> Eclosure (vector <int> T){
    /* Function Eclosure computes the epsilon closure of the set given as input
       
       Algorithm: Eclosure recursively computes the epsilon neighbours of the states in T.
    */

  vector <int> Etrans;
  for (int i = 0; i < T.size (); i++){
	  Etrans.push_back(T[i]); // any set is a subset of its epsilon closure
  }
  if(!is_e_nfa) // no epsilon transtions 
  {
    return Etrans; 
  }
  while (T.size () != 0){
	  int state = T[T.size () - 1];
	  T.pop_back ();
	  vector <int> state_vector;
	  state_vector.push_back (state);
    vector <int> Eneighbours = moveNFA (state_vector, '$'); // returns the immediate epsilon neighbours
    while (Eneighbours.size () != 0){
	    int current = Eneighbours[Eneighbours.size () - 1];
	    Eneighbours.pop_back ();
	    vector < int >::iterator it;
	    it = find (T.begin (), T.end (), current);
	    if (it == T.end ()) // element is pushed if it is not present already
	    {
		    T.push_back (current);
		    Etrans.push_back (current);
	    }
	  }
  }
  return Etrans;
}

char* toChar (string str){
  // A utility function to convert a string to char*

  char *cstr = new char[str.length() + 1];
  strcpy(cstr, str.c_str());
  return cstr;
}
string move_DFA (string state, char input_char){
     // returns the state to which the DFA transitions from a given state on input_char
  int index;
  for(int i=0; i<newDfaStates.size(); i++){
    if(newDfaStates[i]==state)
    index=i;
  } 
  return TransConstruct[index][alphabet_map[input_char]];
}

vector <int> moveNFA (vector <int> state, char input_char){
     // returns the set of states to which the NFA transitions from a given set of states on a given input

  vector <int> transition_states;
  vector <int>::iterator it;
  for (int i = 0; i < state.size (); i++){
    string entry = NTrans[state[i]][alphabet_map[input_char]];
 	  if(entry=="^") // no transition defined for this state
      continue;
    char *token;
    if (entry.length()==1) // transitions to a single state
    {
      transition_states.push_back(stoi(entry)); 
    }
    else // transition to a set of states
    {
 	    token=strtok (toChar(entry), ",");
      while (token != NULL){
	      it = find (transition_states.begin (), transition_states.end (), stoi (token));
	      if (it == transition_states.end ()){
		      transition_states.push_back (stoi (token));
		      token = strtok (NULL, ",");
	      }
	    }
    }
  }
  return transition_states;
}

void readNFA (){
     // readNFA function will read the specifications of the NFA into the global variables
 
  ifstream file;
  file.open ("specification.txt");
  vector <string> line;
  while (!file.eof ()){
	  string s;
    getline (file, s);
    line.push_back (s);
  }
  file.close ();
    
    // processing the states of the NFA

  char* token = strtok (toChar(line[0]), " ");
  while (token != NULL){
	  states.push_back (stoi (string (token)));
	  token = strtok (NULL, " ");
  }
    
    // processing the final states of the NFA

  token = strtok (toChar(line[1]), " ");
  while (token != NULL){
	  finalStates.push_back (stoi (string (token)));
	  token = strtok (NULL, " ");
  }
    
    // processing the input symbols

  token = strtok (toChar(line[2]), " ");
  int counter = 0;
  while (token != NULL){
	  alphabet_map.insert(pair <char,int> (token[0],counter));
    alphabet.push_back(token[0]);
    token = strtok (NULL, " ");
	  counter++;
  }
  alphabet_map.insert(pair <char,int> ('$',counter)); // for epsilon transitions
    
    // processing the transition table

  for (int i = 3; i < line.size(); i++){
    token = strtok (toChar(line[i]), " ");
    counter = 0;
    vector<string> col;
 	  while (token != NULL){
      col.push_back(string(token));
	    token = strtok (NULL, " ");
	    counter++;
	  }
    NTrans.push_back(col);
  }
    
  if(counter==numberOfSymbols){
    is_e_nfa=false;
  }
  else {
    is_e_nfa=true;
  }
}

string convertVectorToString(vector<int> state){
  string str_state = "";
  for(int i=0;i<state.size();i++){
    char ch=state[i]+48;
    str_state+=ch;
  }
  return str_state;
}

bool isPresentInTheVector(vector< vector <int> > list_of_states, vector<int> state){
  // Checks whether the given vector is inside of vector of vector
  sort(state.begin(),state.end());
  for(int i=0;i<list_of_states.size();i++){
    sort(list_of_states[i].begin(),list_of_states[i].end()); 
    if(list_of_states[i]==state)
      return true;
    }
  return false;
}

void subsetConstruction (){
/*
We merge together NFA states by looking at them from the point of view of the input characters:

From the point of view of the input, any two states that are connected by an  e-transition may as well be the same, since we can move from one to the other without consuming any character. Thus states which are connected by an e-transition will be represented by the same states in the DFA.
If it is possible to have multiple transitions based on the same symbol, then we can regard a transition on a symbol as moving from a state to a set of states (ie. the union of all those states reachable by a transition on the current symbol). Thus these states will be combined into a single DFA state.
To perform this operation, let us define two functions:

The e-closure function takes a state and returns the set of states reachable from it based on (one or more) e-transitions. Note that this will always include the state tself. We should be able to get from a state to any state in its e-closure without consuming any input.
The function move takes a state and a character, and returns the set of states reachable by one transition on this character.
We can generalise both these functions to apply to sets of states by taking the union of the application to individual states. 

*/

  vector <int> start;
  int counter=0;
  start.push_back (states[0]);
  start=Eclosure(start);
  vector <vector <int> > marked_states;
  vector <vector <int> > unmarked_states;
  sort(start.begin(), start.end());
  unmarked_states.push_back(start); 
  while (!unmarked_states.empty()){
    vector <int> state = unmarked_states.back();
    unmarked_states.pop_back();
    marked_states.push_back(state);
    string stateString = convertVectorToString(state);
    newDfaStates.insert(make_pair(counter,stateString));
    vector<string> trans;
    for(int i=0;i<alphabet.size();i++){
      char ch = alphabet[i];
      vector <int> new_state = Eclosure(moveNFA(state,ch));
      sort(new_state.begin(), new_state.end());
      bool flag=isPresentInTheVector(marked_states,new_state)||isPresentInTheVector(unmarked_states,new_state);
      if(!flag){
        unmarked_states.push_back(new_state);
      }
      counter++;
      trans.push_back(convertVectorToString(new_state)); 
    }
    TransConstruct.push_back(trans);
  } 
}

void DFA (string str){
    // to parse over an input string and check whether it is accepted or rejected 
  string state = newDfaStates[0];
  int i=0;
  for (; i < str.length (); i++){
    if (alphabet_map.find(str.at(i))==alphabet_map.end()){
      cout<<"ERROR"; 
      break;
    }
	  state = move_DFA (state, str.at (i));
  }
  if (isFinalInNewDFA (state) && i==str.length())
    cout << "MATCHED";
  if (!isFinalInNewDFA (state) && i==str.length())
    cout << "ERROR";
}

%}



%%

.* {  
      DFA(yytext);
   } 

%%



int main (int argc, char *argv[])
{
  extern FILE *yyin;
  yyin = fopen("input.txt","r");
  numberOfFinalStates = stoi (argv[2]);
  numberOfSymbols = stoi (argv[3]);
  readNFA();
  subsetConstruction();
  printNewDFA();
  // yylex ();  
  return 0;
}
