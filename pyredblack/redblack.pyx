# -*- coding: utf-8 -*-

'''
redblack.pyx
(c) Will Roberts  25 February, 2015

Cython source to make red-black tree-based containers.
'''

include "config.pxi"
from libcpp cimport bool
from cpython.ref cimport PyObject
from cython.operator import dereference, preincrement

#cdef extern from "<utility>" namespace "std":
#    cdef cppclass pair[K,V]:
#        pair(const K& a, const V& b) except +
#        K first
#        V second

cdef extern from "pyredblack.h":
    cdef cppclass ObjectRBTreeIterator:
        ObjectRBTreeIterator() except +
        ObjectRBTreeIterator& equals "operator="(const ObjectRBTreeIterator&)
        ObjectRBTreeIterator& operator++()
        PyObject* operator*() const
        bool operator==(const ObjectRBTreeIterator&)
        bool operator!=(const ObjectRBTreeIterator&)
        int getDir()

    cdef cppclass ObjectRBTree:
        ObjectRBTree() except +
        ObjectRBTreeIterator find(object obj)
        #bool insert(pyobjpairw value)
        #bool remove(pyobjpairw value)
        bool del_obj(object obj)
        bool add_obj(object obj)
        bool pop_first_save_obj(object obj)
        ObjectRBTreeIterator begin()
        ObjectRBTreeIterator end()
        void clear_objs()

    cdef cppclass pyobjpairw:
        pyobjpairw() except +
        pyobjpairw(object a, object b) except +
        PyObject* getFirst() const
        PyObject* getSecond() const

    cdef cppclass PairRBTreeIterator:
        PairRBTreeIterator() except +
        PairRBTreeIterator& equals "operator="(const PairRBTreeIterator&)
        PairRBTreeIterator& operator++()
        pyobjpairw& operator*() const
        bool operator==(const PairRBTreeIterator&)
        bool operator!=(const PairRBTreeIterator&)
        int getDir()

    cdef cppclass PairRBTree:
        PairRBTree() except +
        PairRBTreeIterator find(pyobjpairw in_Value)
        #bool insert(pyobjpairw value)
        #bool remove(pyobjpairw value)
        bool del_key(object key)
        bool del_key_save_value(object key, object value)
        object get_value_for_key(object key, bool &found)
        bool set_key(object key, object value)
        bool pop_first_save_item(object key, object value)
        PairRBTreeIterator begin()
        PairRBTreeIterator end()
        void clear_objs()

cdef class rbset(object):
    '''Red-black-tree-based set.'''

    cdef ObjectRBTree *_tree
    cdef int _num_nodes

    def __cinit__(self):
        '''C Constructor.'''
        self._tree = new ObjectRBTree()
        self._num_nodes = 0

    def __init__(self, iterable = None):
        '''Python Constructor.'''
        self.update(iterable)

    def __dealloc__(self):
        '''Destructor.'''
        if self._tree is not NULL:
            self._tree.clear_objs()
            del self._tree

    def __len__(self):
        '''Return the number of items in the set.'''
        return self._num_nodes

    def __contains__(self, elem):
        '''Return `True` if the set has a member `elem`, else `False`.'''
        _hash = hash(elem)
        cdef ObjectRBTreeIterator it = self._tree.find(elem)
        if it.getDir() == 0:
            return True
        return False

    def __iter__(self):
        '''Return an iterator over the items in the set.'''
        cdef ObjectRBTreeIterator it = self._tree.begin()
        while it != self._tree.end():
            yield <object>dereference(it)
            preincrement(it)

    def add(self, elem):
        '''Add element `elem` to the set.'''
        _hash = hash(elem)
        if self._tree.add_obj(elem):
            self._num_nodes += 1

    def remove(self, elem):
        '''
        Remove element `elem` from the set. Raises `KeyError` if `elem` is
        not contained in the set.
        '''
        _hash = hash(elem)
        if self._tree.del_obj(elem):
            self._num_nodes -= 1
        else:
            raise KeyError(elem)

    def discard(self, elem):
        '''Remove element `elem` from the set if it is present.'''
        _hash = hash(elem)
        if self._tree.del_obj(elem):
            self._num_nodes -= 1

    def pop(self):
        '''
        Remove and return an arbitrary element from the set. Raises
        `KeyError` if the set is empty.
        '''
        cdef object obj = None
        if self._tree.pop_first_save_obj(obj):
            self._num_nodes -= 1
            return obj
        else:
            raise KeyError('pop from an empty set')

    def clear(self):
        '''Remove all items from the set.'''
        self._tree.clear_objs()
        self._num_nodes = 0

    def isdisjoint(self, other):
        '''
        Return True if the set has no elements in common with
        `other`. Sets are disjoint if and only if their intersection
        is the empty set.
        '''
        try:
            otherhas = other.__contains__
        except AttributeError:
            otherhas = rbset(other).__contains__
        for elem in self:
            if otherhas(elem):
                return False
        return True

    def issubset(self, other):
        '''Test whether every element in the set is in `other`.'''
        return self.__richcmp__(rbset(other), 1)

    def issuperset(self, other):
        '''Test whether every element in `other` is in the set.'''
        return self.__richcmp__(rbset(other), 5)

    def __richcmp__(self, other, op):
        if not isinstance(other, (set, frozenset, rbset)):
            return False
        if op == 0:
            # LT: Test whether the set is a proper subset of `other`,
            # that is, `set <= other` and `set != other`.
            raise NotImplementedError
        elif op == 1:
            # LE: Test whether every element in the set is in `other`.
            otherhas = other.__contains__
            for elem in self:
                if not otherhas(elem):
                    return False
            return True
        elif op == 2:
            # EQ: Test for equality
            raise NotImplementedError
        elif op == 3:
            # NEQ: Test for inequality
            return not self.__richcmp(other, 2)
        elif op == 4:
            # GT: Test whether the set is a proper superset of
            # `other`, that is, `set >= other` and `set != other`.
            raise NotImplementedError
        elif op == 5:
            # GE: Test whether every element in `other` is in the set.
            for elem in other:
                if not elem in self:
                    return False
            return True
        raise NotImplementedError

    def union(self, other, *others):
        '''Return a new set with elements from the set and all others.'''
        rv = rbset(self)
        rv.update(other, others)
        return rv

    def __or__(self, other):
        '''Return a new set with elements from the set and all others.'''
        if not isinstance(other, (set, frozenset, rbset)):
            raise TypeError('unsupported operand type(s) for |')
        return rbset(self, other)

    def intersection(self, other, *others):
        '''
        Return a new set with elements common to the set and all others.
        '''
        return self.__and__(rbset(other))

    def __and__(self, other):
        '''
        Return a new set with elements common to the set and all others.
        '''
        if not isinstance(other, (set, frozenset, rbset)):
            raise TypeError('unsupported operand type(s) for &')
        return rbset(elem for elem in self if elem in other)

    def difference(self, other, *others):
        '''
        Return a new set with elements in the set that are not in the
        others.
        '''
        return self.__sub__(rbset(other))

    def __sub__(self, other):
        '''
        Return a new set with elements in the set that are not in the
        others.
        '''
        if not isinstance(other, (set, frozenset, rbset)):
            raise TypeError('unsupported operand type(s) for -')
        return rbset(elem for elem in self if elem not in other)

    def symmetric_difference(self, other):
        '''
        Return a new set with elements in either the set or `other` but
        not both.
        '''
        return self.__xor__(rbset(other))

    def __xor__(self, other):
        '''
        Return a new set with elements in either the set or `other` but
        not both.
        '''
        if not isinstance(other, (set, frozenset, rbset)):
            raise TypeError('unsupported operand type(s) for ^')
        raise NotImplementedError

    def copy(self):
        '''Return a new set with a shallow copy of the set.'''
        return rbset(self)

    def update(self, other, *others):
        '''Update the set, adding elements from all others.'''
        for elem in other:
            self.add(elem)
        for other in others:
            for elem in other:
                self.add(elem)

    def __ior__(self, other):
        '''Update the set, adding elements from all others.'''
        if not isinstance(other, (set, frozenset, rbset)):
            raise TypeError('unsupported operand type(s) for |=')
        for elem in other:
            self.add(elem)

    def intersection_update(self, other, *others):
        '''
        Update the set, keeping only elements found in it and all others.
        '''
        self.__iand__(rbset(other))
        for other in others:
            self.__iand__(rbset(other))

    def __iand__(self, other):
        '''
        Update the set, keeping only elements found in it and all others.
        '''
        if not isinstance(other, (set, frozenset, rbset)):
            raise TypeError('unsupported operand type(s) for &=')
        raise NotImplementedError

    def difference_update(self, other, *others):
        '''Update the set, removing elements found in others.'''
        self.__iand__(rbset(other))
        for other in others:
            self.__iand__(rbset(other))

    def __isub__(self, other):
        '''Update the set, removing elements found in others.'''
        if not isinstance(other, (set, frozenset, rbset)):
            raise TypeError('unsupported operand type(s) for -=')
        raise NotImplementedError

    def symmetric_difference_update(self, other):
        '''
        Update the set, keeping only elements found in either set, but not
        in both.
        '''
        self.__ixor__(rbset(other))

    def __ixor__(self, other):
        '''
        Update the set, keeping only elements found in either set, but not
        in both.
        '''
        if not isinstance(other, (set, frozenset, rbset)):
            raise TypeError('unsupported operand type(s) for ^=')
        raise NotImplementedError


cdef class rbdict(object):
    '''Red-black-tree-based associative array.'''

    cdef PairRBTree *_tree
    cdef int _num_nodes

    def __cinit__(self):
        '''C Constructor.'''
        self._tree = new PairRBTree()
        self._num_nodes = 0

    def __init__(self, mapping = None, **kwargs):
        '''Python Constructor.'''
        self.update(mapping, **kwargs)

    def __dealloc__(self):
        '''Destructor.'''
        if self._tree is not NULL:
            self._tree.clear_objs()
            del self._tree

    def __len__(self):
        '''Return the number of items in the dictionary.'''
        return self._num_nodes

    def __missing__(self, key):
        '''
        Called by `__getitem__()` to implement `self[key]` for dict
        subclasses when `key` is not in the dictionary.
        '''
        _hash = hash(key)
        raise KeyError(key)

    def __getitem__(self, key):
        '''
        Return the item of the dictionary with key `key`. Raises a
        `KeyError` if `key` is not in the map.
        '''
        _hash = hash(key)
        cdef bool found = False
        value = self._tree.get_value_for_key(key, found)
        if not found:
            return self.__missing__(key)
        return value

    def __setitem__(self, key, value):
        '''Associates `key` with `value`.'''
        _hash = hash(key)
        if self._tree.set_key(key, value):
            self._num_nodes += 1

    def __delitem__(self, key):
        '''
        Removes `key` from the dictionary. Raises a `KeyError` if `key` is
        not in the map.
        '''
        _hash = hash(key)
        if self._tree.del_key(key):
            self._num_nodes -= 1
        else:
            raise KeyError(key)

    def __contains__(self, key):
        '''Return `True` if the dictionary has a key `key`, else `False`.'''
        _hash = hash(key)
        cdef pyobjpairw probe
        probe = pyobjpairw(key, None)
        cdef PairRBTreeIterator it = self._tree.find(probe)
        if it.getDir() == 0:
            return True
        return False

    def __iter__(self):
        '''Return an iterator over the keys of the dictionary.'''
        return self.iterkeys()

    def keys(self):
        '''Return a copy of the dictionary’s list of keys.'''
        IF PYTHON_VERSION2 == 1:
            return list(self.iterkeys())
        ELSE:
            return self.iterkeys()

    def values(self):
        '''Return a copy of the dictionary’s list of values.'''
        IF PYTHON_VERSION2 == 1:
            return list(self.itervalues())
        ELSE:
            return self.itervalues()

    def items(self):
        '''Return a copy of the dictionary’s list of `(key, value)` pairs.'''
        IF PYTHON_VERSION2 == 1:
            return list(self.iteritems())
        ELSE:
            return self.iteritems()

    def has_key(self, key):
        '''Test for the presence of `key` in the dictionary.'''
        _hash = hash(key)
        return self.__contains__(key)

    def get(self, key, default=None):
        '''
        Return the value for `key` if `key` is in the dictionary, else
        `default`. If `default` is not given, it defaults to None, so
        that this method never raises a `KeyError`.
        '''
        _hash = hash(key)
        cdef bool found = False
        value = self._tree.get_value_for_key(key, found)
        if not found:
            return default
        return value

    def clear(self):
        '''Remove all items from the dictionary.'''
        self._tree.clear_objs()
        self._num_nodes = 0

    def setdefault(self, key, default = None):
        '''
        If `key` is in the dictionary, return its value. If not, insert
        `key` with a value of `default` and return
        `default`. `default` defaults to None.
        '''
        _hash = hash(key)
        # TODO: this could be one tree access instead of two
        try:
            return self.__getitem__(key)
        except KeyError:
            self.__setitem__(key, default)
            return default

    def iterkeys(self):
        '''Return an iterator over the dictionary’s keys.'''
        cdef PairRBTreeIterator it = self._tree.begin()
        while it != self._tree.end():
            yield <object>dereference(it).getFirst()
            preincrement(it)

    def itervalues(self):
        '''Return an iterator over the dictionary’s values.'''
        cdef PairRBTreeIterator it = self._tree.begin()
        while it != self._tree.end():
            yield <object>dereference(it).getSecond()
            preincrement(it)

    def iteritems(self):
        '''Return an iterator over the dictionary’s `(key, value)` pairs.'''
        cdef PairRBTreeIterator it = self._tree.begin()
        while it != self._tree.end():
            yield (<object>dereference(it).getFirst(),
                   <object>dereference(it).getSecond())
            preincrement(it)

    def pop(self, key, default=None):
        '''
        If `key` is in the dictionary, remove it and return its value,
        else return `default`.
        '''
        _hash = hash(key)
        cdef object value = default
        if self._tree.del_key_save_value(key, value):
            self._num_nodes -= 1
        return value

    def popitem(self):
        '''
        Remove and return an arbitrary `(key, value)` pair from the
        dictionary.
        '''
        cdef object key = None
        cdef object value = None
        if self._tree.pop_first_save_item(key, value):
            self._num_nodes -= 1
            return (key, value)
        raise KeyError('popitem(): dictionary is empty')

    def copy(self):
        '''Return a shallow copy of the dictionary.'''
        return rbdict(self)

    def update(self, mapping = None, **kwargs):
        '''
        Update the dictionary with the key/value pairs from `mapping`
        and/or `kwargs`, overwriting existing keys.

        `update()` accepts either another dictionary object or an
        iterable of key/value pairs (as tuples or other iterables of
        length two). If keyword arguments are specified, the
        dictionary is then updated with those key/value pairs.
        '''
        if mapping is not None:
            # try mapping as a dict first
            items = None
            try:
                items = mapping.iteritems()
            except AttributeError:
                try:
                    items = mapping.items()
                except AttributeError:
                    pass
            if items:
                for key, val in items:
                    self[key] = val
            else:
                # raises TypeError if not iterable
                for item in mapping:
                    try:
                        key, val = item
                    except ValueError:
                        raise ValueError('dictionary update sequence element '
                                         'must have length 2')
                    except TypeError:
                        raise TypeError('cannot convert dictionary update '
                                        'sequence element to a sequence')
                    self[key] = val
        for key, val in kwargs.items():
            self[key] = val
