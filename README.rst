============
 pyredblack
============

.. image:: https://travis-ci.org/wroberts/pyredblack.svg?branch=master
    :target: https://travis-ci.org/wroberts/pyredblack

.. image:: https://coveralls.io/repos/wroberts/pyredblack/badge.svg?branch=master
  :target: https://coveralls.io/r/wroberts/pyredblack?branch=master
     :alt: Test code coverage

.. image:: https://img.shields.io/pypi/v/pyredblack.svg
    :target: https://pypi.python.org/pypi/pyredblack/
    :alt: Latest Version

Copyright (c) 2015 Will Roberts <wildwilhelm@gmail.com>

Licensed under the MIT License (see ``LICENSE.rst`` for details).

Cython interface to red-black trees implemented in C++.

`Red-black trees`_ are a kind of `self-balancing binary tree`_.  They
maintain their entries in sorted order and have O(log n) for
insertion, lookup, and deletion.  You can `read more about red-black
trees`_ and `see animations of insertion, lookup, and deletion`_.

.. _`Red-black trees`: http://en.wikipedia.org/wiki/Red%E2%80%93black_tree
.. _`self-balancing binary tree`: http://en.wikipedia.org/wiki/Self-balancing_binary_search_tree
.. _`read more about red-black trees`: http://www.eternallyconfuzzled.com/tuts/datastructures/jsw_tut_rbtree.aspx
.. _`see animations of insertion, lookup, and deletion`: https://www.cs.usfca.edu/~galles/visualization/RedBlack.html

This package provides dictionary and set objects based on
red-black-trees; these can be used as drop-in replacements for the
built-in ``dict`` and ``set`` types, except that they maintain their
contents in sorted order.

Dictionary (``rbdict``)::

    >>> import pyredblack
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
    ['Sofia', 'Nicosia', 'Berlin', 'Nuuk', 'Budapest',
     'Reykjavik', 'Dublin', 'Skopje', 'Lisbon', 'Stockholm']
    >>> d.popitem()
    ('Bulgaria', 'Sofia')
    >>> d.popitem()
    ('Cyprus', 'Nicosia')
    >>> d.popitem()
    ('Germany', 'Berlin')

Set (``rbset``)::

    >>> fruit = pyredblack.rbset(['apple', 'orange', 'apple', 'pear',
                                  'orange', 'banana'])
    >>> 'orange' in fruit
    True
    >>> 'crabgrass' in fruit
    False
    >>> a = pyredblack.rbset('abracadabra')
    >>> b = pyredblack.rbset('alacazam')
    >>> list(a)
    ['a', 'b', 'c', 'd', 'r']
    >>> list(a - b)
    ['b', 'd', 'r']
    >>> list(a | b)
    ['a', 'b', 'c', 'd', 'l', 'm', 'r', 'z']
    >>> list(a & b)
    ['a', 'c']
    >>> list(a ^ b)
    ['b', 'd', 'l', 'm', 'r', 'z']
    >>> a.pop()
    'a'
    >>> a.pop()
    'b'
    >>> a.pop()
    'c'

Requirements
------------

- Python 2.7, Python 3.2+
- Cython (and a C++ compiler)

Todo
----

- implement slicing on dictionaries
