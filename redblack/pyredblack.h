#ifndef _PYREDBLACK_H_
#define _PYREDBLACK_H_

#include <Python.h>
#include "redblack.h"
#include <utility>
using namespace std;

typedef pair<PyObject*,PyObject*> pyobjpair;

// wrappers : (

struct _pyobjpairw : pyobjpair
{
    _pyobjpairw() : pyobjpair() { };
    _pyobjpairw(PyObject* a, PyObject* b) : pyobjpair(a,b) { };
    PyObject* getFirst() const {return first;};
    PyObject* getSecond() const {return second;};
};
typedef struct _pyobjpairw pyobjpairw;

typedef Node<pyobjpairw> PairNode;

struct pyobjpaircmp
{
    bool operator()(pyobjpairw &o1, pyobjpairw &o2)
    {
        return (PyObject_RichCompareBool(o1.first, o2.first, Py_LT) == 1);
    }
};

typedef RedBlackTreeIterator<pyobjpairw> PairRBTreeIterator;

#ifdef DEBUG
string
pyobjrepr(PyObject *o)
{
    PyObject *reprstr = PyObject_Repr(o);
    string rv(PyString_AsString(reprstr));
    Py_XDECREF(reprstr);
    return rv;
}
#endif // DEBUG

class PairRBTree : public RedBlackTree<pyobjpairw, pyobjpaircmp>
{
public:
    bool del_key(PyObject *key)
    {
#ifdef DEBUG
        cout << "del_key begin " << to_string() << endl;
#endif // DEBUG
        pyobjpairw probe(key, Py_None);
        pyobjpairw found;
        if (remove(probe, found))
        {
            Py_XDECREF(found.first);
            Py_XDECREF(found.second);
#ifdef DEBUG
            cout << "del_key end " << to_string() << endl;
#endif // DEBUG
            return true;
        }
#ifdef DEBUG
        cout << "del_key end " << to_string() << endl;
#endif // DEBUG
        return false;
    };
    PyObject* get_value_for_key(PyObject *key, bool &out_found)
    {
#ifdef DEBUG
        cout << "get_key begin " << to_string() << endl;
#endif // DEBUG
        PairNode* current;
        int dir;
        pyobjpairw probe(key, Py_None);
        find(probe, current, dir);
        if (dir == 0)
        {
            out_found = true;
            return current->value.second;
        }
        out_found = false;
        return Py_None;
    };
    bool set_key(PyObject *key, PyObject *value)
    {
#ifdef DEBUG
        cout << "set_key begin " << to_string() << endl;
#endif // DEBUG
        pyobjpairw probe(key, value);
        pyobjpairw *found = 0;
        if (insert(probe, found))
        {
            // storing a value
            Py_XINCREF(key);
            Py_XINCREF(value);
#ifdef DEBUG
            cout << "set_key end " << to_string() << endl;
#endif // DEBUG
            return true;
        }
        else
        {
#ifdef DEBUG
            cout << "found existing value " << pyobjrepr(found->second)
                 << " for key " << pyobjrepr(key) << endl;
#endif // DEBUG
            // overwriting a value
            Py_XDECREF(found->second);
            found->second = value;
            Py_XINCREF(value);
#ifdef DEBUG
            cout << "set_key end " << to_string() << endl;
#endif // DEBUG
            return false;
        }
    };
};

#ifdef DEBUG
template<>
string
RedBlackTree<pyobjpairw, pyobjpaircmp>::_to_string(PairNode *node)
{
    string result = "[";
    if (node)
    {
        if (node->left)
            result += _to_string(node->left) + " ";
        result = result + (node->red ? "R" : "B") + " " + "*";
        if (node->right)
            result += " " + _to_string(node->right);
    }
    result += "]";
    return result;
};
#endif // DEBUG

#endif /* _PYREDBLACK_H_ */
