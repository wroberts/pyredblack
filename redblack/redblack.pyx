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

    def __cinit__(self):
        '''Constructor.'''
        self._tree = new PairRBTree()
        self._num_nodes = 0

    def __dealloc__(self):
        if self._tree is not NULL:
            self._tree.clear_objs()
            del self._tree

    def __len__(self):
        return self._num_nodes

    def __missing__(self, key):
        raise KeyError(key)

    def __getitem__(self, key):
        cdef bool found = False
        value = self._tree.get_value_for_key(key, found)
        if not found:
            return self.__missing__(key)
        return value

    def __setitem__(self, key, value):
        if self._tree.set_key(key, value):
            self._num_nodes += 1

    def __delitem__(self, key):
        if self._tree.del_key(key):
            self._num_nodes -= 1
        else:
            raise KeyError(key)

    def __contains__(self, key):
        cdef pyobjpairw probe
        probe = pyobjpairw(key, None)
        cdef PairRBTreeIterator it = self._tree.find(probe)
        if it.getDir() == 0:
            return True
        return False

    def __iter__(self):
        return self.iterkeys()

    def keys(self):
        return list(self.iterkeys())

    def values(self):
        return list(self.itervalues())

    def items(self):
        return list(self.iteritems())

    def has_key(self, key):
        return self.__contains__(key)

    def get(self, key, default=None):
        cdef bool found = False
        value = self._tree.get_value_for_key(key, found)
        if not found:
            return default
        return value

    def clear(self):
        self._tree.clear_objs()
        self._num_nodes = 0

    def setdefault(self, key, default = None):
        # TODO: this could be one tree access instead of two
        try:
            return self.__getitem__(key)
        except KeyError:
            self.__setitem__(key, default)
            return default

    def iterkeys(self):
        cdef PairRBTreeIterator it = self._tree.begin()
        while it != self._tree.end():
            yield <object>dereference(it).getFirst()
            preincrement(it)

    def itervalues(self):
        cdef PairRBTreeIterator it = self._tree.begin()
        while it != self._tree.end():
            yield <object>dereference(it).getSecond()
            preincrement(it)

    def iteritems(self):
        cdef PairRBTreeIterator it = self._tree.begin()
        while it != self._tree.end():
            yield (<object>dereference(it).getFirst(),
                   <object>dereference(it).getSecond())
            preincrement(it)

    def pop(self, key, default=None):
        cdef object value = default
        if self._tree.del_key_save_value(key, value):
            self._num_nodes -= 1
        return value

    def popitem(self):
        raise NotImplementedError

    def copy(self):
        raise NotImplementedError

    def update(self):
        raise NotImplementedError
