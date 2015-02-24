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
        object first() const
        object second() const

    cdef cppclass PairNode:
        pyobjpairw value

    cdef cppclass PairRBTreeIterator:
        PairRBTreeIterator(PairNode *s) except +
        PairRBTreeIterator& equals "operator="(const PairRBTreeIterator&)
        PairRBTreeIterator& operator++()
        PairNode& operator*() const
        bool operator==(const PairRBTreeIterator&)
        bool operator!=(const PairRBTreeIterator&)

    cdef cppclass PairRBTree:
        PairRBTree() except +
        #void find(pyobjpairw in_Value, PairNode* &out_pNode, int &dir)
        #bool insert(pyobjpairw value)
        #bool remove(pyobjpairw value)
        bool del_key(object key)
        object get_value_for_key(object key, bool &found)
        bool set_key(object key, object value)
        PairRBTreeIterator begin()
        PairRBTreeIterator end()

cdef class redblackdict(object):
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
        return None

    def __iter__(self):
        return None

    def keys(self):
        return None

    def values(self):
        return None

    def items(self):
        return None

    def has_key(self):
        return None

    def get(self):
        return None

    def clear(self):
        return None

    def setdefault(self):
        return None

    def iterkeys(self):
        return None

    def itervalues(self):
        return None

    def iteritems(self):
        return None

    def pop(self):
        return None

    def popitem(self):
        return None

    def copy(self):
        return None

    def update(self):
        return None
