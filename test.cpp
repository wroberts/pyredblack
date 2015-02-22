#include "redblack/redblack.h"

#include <iostream>
#include <vector>
#include <algorithm>
#include <ctime>
#include <cstdlib>

void printTreeValues(RedBlackTree<int> &t)
{
    cout << "values: ";
    for (RedBlackTreeIterator<int> i = t.begin(); i != t.end(); ++i)
    {
        cout << (*i).value << " ";
    }
    cout << endl;
}

int main ( int argc, char **argv )
{
    cout << "Hello, world!" << endl;

    vector<int> myvector;
    for (int i=1; i<=10; ++i) myvector.push_back(i);
    srand ( unsigned ( time(0) ) );
    //random_shuffle ( myvector.begin(), myvector.end() );

    RedBlackTree<int> tree;
    cout << "empty tree: " << tree.to_string() << endl;

    for (vector<int>::iterator it=myvector.begin(); it!=myvector.end(); ++it)
    {
        cout << "inserting " << (*it) << "..." << endl;
        int foundVal;
        tree.insert(*it, foundVal);
        cout << "tree: " << tree.to_string() << endl;
        printTreeValues(tree);
    }

    random_shuffle ( myvector.begin(), myvector.end() );
    for (vector<int>::iterator it=myvector.begin(); it!=myvector.end(); ++it)
    {
        cout << "removing " << (*it) << "..." << endl;
        int foundVal;
        tree.remove(*it, foundVal);
        cout << "tree: " << tree.to_string() << endl;
        printTreeValues(tree);
    }
/*
  cout << "inserting 1..." << endl;
  tree.insert(1);
  cout << "tree: " << tree.to_string() << endl;
  cout << "inserting 2..." << endl;
  tree.insert(2);
  cout << "tree: " << tree.to_string() << endl;
  cout << "inserting 3..." << endl;
  tree.insert(3);
  cout << "tree: " << tree.to_string() << endl;
  cout << "inserting 4..." << endl;
  tree.insert(4);
  cout << "tree: " << tree.to_string() << endl;
  cout << "inserting 5..." << endl;
  tree.insert(5);
  cout << "tree: " << tree.to_string() << endl;
  cout << "inserting 7..." << endl;
  tree.insert(7);
  cout << "tree: " << tree.to_string() << endl;
  cout << "inserting 8..." << endl;
  tree.insert(8);
  cout << "tree: " << tree.to_string() << endl;
  cout << "inserting 9..." << endl;
  tree.insert(9);
  cout << "tree: " << tree.to_string() << endl;
  cout << "inserting 6..." << endl;
  tree.insert(6);
  cout << "tree: " << tree.to_string() << endl;*/

    return 0;
}
