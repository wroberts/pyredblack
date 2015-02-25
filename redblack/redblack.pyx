# -*- coding: utf-8 -*-

'''
redblack.pyx
(c) Will Roberts  25 February, 2015

Cython source to make red-black tree-based containers.
'''

from libcpp cimport bool
from cpython.ref cimport PyObject
from cython.operator import dereference, preincrement

#cdef extern from "<utility>" namespace "std":
#    cdef cppclass pair[K,V]:
#        pair(const K& a, const V& b) except +
#        K first
#        V second

cdef extern from "pyredblack.h":
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
        PairRBTreeIterator begin()
        PairRBTreeIterator end()
        void clear_objs()

cdef class dict(object):
    '''Red-black-tree-based associative array.'''

    cdef PairRBTree *_tree
    cdef int _num_nodes

    def __cinit__(self, mapping = None, **kwargs):
        '''Constructor.'''
        self._tree = new PairRBTree()
        self._num_nodes = 0
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
        return list(self.iterkeys())

    def values(self):
        '''Return a copy of the dictionary’s list of values.'''
        return list(self.itervalues())

    def items(self):
        '''Return a copy of the dictionary’s list of `(key, value)` pairs.'''
        return list(self.iteritems())

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
        raise NotImplementedError

    def copy(self):
        '''Return a shallow copy of the dictionary.'''
        return dict(self)

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
                                         'has length 1; 2 is required')
                    except TypeError:
                        raise TypeError('cannot convert dictionary update '
                                        'sequence element to a sequence')
                    self[key] = val
        for key, val in kwargs.items():
            self[key] = val
