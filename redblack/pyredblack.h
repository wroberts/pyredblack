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
        return (PyObject_RichCompareBool(o1.first, o2.first, Py_LE) == 1);
    }
};

typedef RedBlackTreeIterator<pyobjpairw> PairRBTreeIterator;

class PairRBTree : RedBlackTree<pyobjpairw, pyobjpaircmp>
{
public:
    bool del_key(PyObject *key)
    {
        pyobjpairw probe(key, Py_None);
        pyobjpairw found;
        if (remove(probe, found))
        {
            Py_XDECREF(found.first);
            Py_XDECREF(found.second);
            return true;
        }
        return false;
    };
    PyObject* get_value_for_key(PyObject *key, bool &out_found)
    {
        PairNode* current;
        int dir;
        pyobjpairw probe(key, Py_None);
        find(probe, current, dir);
        if (dir == 0)
        {
            out_found = true;
            return current->value.first;
        }
        out_found = false;
        return Py_None;
    };
    bool set_key(PyObject *key, PyObject *value)
    {
        pyobjpairw probe(key, value);
        pyobjpairw found;
        if (insert(probe, found))
        {
            // storing a value
            Py_XINCREF(key);
            Py_XINCREF(value);
            return true;
        }
        else
        {
            // overwriting a value
            Py_XDECREF(found.second);
            found.second = value;
            Py_XINCREF(value);
            return false;
        }
    };
};

#endif /* _PYREDBLACK_H_ */
