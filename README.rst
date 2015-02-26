==========
 redblack
==========

Cython interface to red-black trees implemented in C++.

`Red-black trees`_ are a kind of `self-balancing binary tree`_.
They maintain their entries in sorted order and have
O(log n) for insertion, lookup, and deletion.

.. _`Red-black trees`: blah
.. _`self-balancing binary tree`: blah

This package provides dictionary and set objects based on
red-black-trees; these can be used as drop-in replacements for the
built-in `dict` and `set` types, except that they maintain their
contents in sorted order::

    >>> d = pyredblack.rbdict(Germany = 'Berlin',
                              Hungary = 'Budapest',
                              Ireland = 'Dublin',
                              Portugal = 'Lisbon',
                              Cyprus = 'Nicosia',
                              Greenland = 'Nuuk',
                              Iceland = 'Reykjavik',
                              Macedonia = 'Skopje',
                              Bulgaria = 'Sofia',
                              Sweden = 'Stockholm')
    >>> len(d)
    10
    >>> d['Ireland']
    'Dublin'
    >>> d.keys()
    ['Bulgaria', 'Cyprus', 'Germany', 'Greenland', 'Hungary',
     'Iceland', 'Ireland', 'Macedonia', 'Portugal', 'Sweden']
    >>> d.values()
    ['Sofia', 'Nicosia', 'Berlin', 'Nuuk', 'Budapest', 'Reykjavik',
     'Dublin', 'Skopje', 'Lisbon', 'Stockholm']
    >>> d.popitem()
    ('Bulgaria', 'Sofia')

Requirements
------------

- Python 2.7, Python 3.2+
- Cython (and a C++ compiler)
