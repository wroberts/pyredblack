#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
testdict.py
(c) Will Roberts  25 February, 2015

Unit tests for the redblack.dict class.
'''

import unittest
from .. import redblack

class TestDict(unittest.TestCase):

    @unittest.expectedFailure
    def test_ctor_none(self):
        # dict(None) raises TypeError
        # redblack.dict does not
        self.assertRaises(TypeError, redblack.dict, (None,))

    def test_ctor1(self):
        # dict(2) raises TypeError
        self.assertRaises(TypeError, redblack.dict, (2,))

    def test_ctor2(self):
        # dict([1,2,3]) raises TypeError
        self.assertRaises(TypeError, redblack.dict, ([1,2,3],))

    def test_ctor3(self):
        # dict('abc') raises ValueError
        self.assertRaises(ValueError, redblack.dict, ('abc',))

    def test_ctor4(self):
        # dict([(1,2), (2,3), (3,3)]) raises no error
        d = redblack.dict([(1,2), (2,3), (3,3)])
        self.assertEqual(len(d), 3)
        self.assertEqual(sorted(d.keys()), [1, 2, 3])
        self.assertEqual(sorted(d.values()), [2, 3, 3])
        self.assertEqual(sorted(d.items()), [(1, 2), (2, 3), (3, 3)])

    def test_ctor5(self):
        # dict([(1,2,1), (2,3,2), (3,3,2)]) raises ValueError
        self.assertRaises(ValueError, redblack.dict,
                          ([(1,2,1), (2,3,2), (3,3,2)],))

    def test_ctor6(self):
        # dict(one=3,two=2,three=1) raises no error
        d = redblack.dict(one=3,two=2,three=1)
        self.assertEqual(len(d), 3)
        self.assertEqual(sorted(d.keys()), ['one', 'three', 'two'])
        self.assertEqual(sorted(d.values()), [1, 2, 3])
        self.assertEqual(sorted(d.items()),
                         [('one', 3), ('three', 1), ('two', 2)])
