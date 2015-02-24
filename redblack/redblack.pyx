from libcpp cimport bool
#from cpython.ref cimport PyObject

#cdef extern from "<utility>" namespace "std":
#    cdef cppclass pair[K,V]:
#        pair(const K& a, const V& b) except +
#        K first
#        V second

cdef extern from "pyredblack.h":
    cdef cppclass pyobjpairw:
        pyobjpair "pair"(object a, object b) except +
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
            del self._tree

    def __len__(self):
        return self._num_nodes

    def __getitem__(self, key):
        cdef bool found
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
        raise NotImplementedError

    def keys(self):
        raise NotImplementedError

    def values(self):
        raise NotImplementedError

    def items(self):
        raise NotImplementedError

    def has_key(self):
        raise NotImplementedError

    def get(self):
        raise NotImplementedError

    def clear(self):
        raise NotImplementedError

    def setdefault(self):
        raise NotImplementedError

    def iterkeys(self):
        raise NotImplementedError

    def itervalues(self):
        raise NotImplementedError

    def iteritems(self):
        raise NotImplementedError

    def pop(self):
        raise NotImplementedError

    def popitem(self):
        raise NotImplementedError

    def copy(self):
        raise NotImplementedError

    def update(self):
        raise NotImplementedError
