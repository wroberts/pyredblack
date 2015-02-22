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
        object get_value_for_key(object key)
        bool set_key(object key, object value)
        PairRBTreeIterator begin()
        PairRBTreeIterator end()

def myfunc():
    print 'hello world'

cdef class redblackdict(object):
    '''Red-black-tree-based associative array.'''

    cdef PairRBTree *_tree

    def __cinit__(self):
        '''Constructor.'''
        self._tree = new PairRBTree()

    def __dealloc__(self):
        if self._tree is not NULL:
            del self._tree

    def __len__(self):
        return None

    def __getitem__(self, key):
        return None

    def __setitem__(self, key, value):
        pass

    def __delitem__(self, key):
        pass

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
