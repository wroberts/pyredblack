from libcpp cimport bool
#from cpython.ref cimport PyObject
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
        object getFirst() const
        object getSecond() const

    cdef cppclass PairNode:
        pyobjpairw value

    cdef cppclass PairRBTreeIterator:
        PairRBTreeIterator() except +
        PairRBTreeIterator(PairNode *s) except +
        PairRBTreeIterator& equals "operator="(const PairRBTreeIterator&)
        PairRBTreeIterator& operator++()
        PairNode& operator*() const
        bool operator==(const PairRBTreeIterator&)
        bool operator!=(const PairRBTreeIterator&)

    cdef cppclass PairRBTree:
        PairRBTree() except +
        void find(pyobjpairw in_Value, PairNode* &out_pNode, int &dir)
        #bool insert(pyobjpairw value)
        #bool remove(pyobjpairw value)
        bool del_key(object key)
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

    def __getitem__(self, key):
        cdef bool found = False
        value = self._tree.get_value_for_key(key, found)
        if not found:
            raise KeyError(key)
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
        raise NotImplementedError

    def __iter__(self):
        return self.iterkeys()

    def keys(self):
        return list(self.iterkeys())

    def values(self):
        return list(self.itervalues())

    def items(self):
        return list(self.iteritems())

    def has_key(self):
        raise NotImplementedError

    def get(self):
        raise NotImplementedError

    def clear(self):
        self._tree.clear_objs()
        self._num_nodes = 0

    def setdefault(self):
        raise NotImplementedError

    def iterkeys(self):
        cdef PairRBTreeIterator it = self._tree.begin()
        while it != self._tree.end():
            yield dereference(it).value.getFirst()
            preincrement(it)

    def itervalues(self):
        cdef PairRBTreeIterator it = self._tree.begin()
        while it != self._tree.end():
            yield dereference(it).value.getSecond()
            preincrement(it)

    def iteritems(self):
        cdef PairRBTreeIterator it = self._tree.begin()
        while it != self._tree.end():
            yield (dereference(it).value.getFirst(),
                   dereference(it).value.getSecond())
            preincrement(it)

    def pop(self):
        raise NotImplementedError

    def popitem(self):
        raise NotImplementedError

    def copy(self):
        raise NotImplementedError

    def update(self):
        raise NotImplementedError
