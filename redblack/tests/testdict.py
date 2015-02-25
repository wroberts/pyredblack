#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
testdict.py
(c) Will Roberts  25 February, 2015

Unit tests for the redblack.dict class.
'''

import random
import unittest
from .. import redblack

class TestDict(unittest.TestCase):

    @unittest.expectedFailure
    def test_ctor_none(self):
        # dict(None) raises TypeError
        # redblack.dict does not
        self.assertRaises(TypeError, redblack.dict, None)

    def test_ctor1(self):
        # dict(2) raises TypeError
        self.assertRaises(TypeError, redblack.dict, 2)

    def test_ctor2(self):
        # dict([1,2,3]) raises TypeError
        self.assertRaises(TypeError, redblack.dict, [1,2,3],)

    def test_ctor3(self):
        # dict('abc') raises ValueError
        self.assertRaises(ValueError, redblack.dict, 'abc')

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
                          [(1,2,1), (2,3,2), (3,3,2)])

    def test_ctor6(self):
        # dict(one=3,two=2,three=1) raises no error
        d = redblack.dict(one=3,two=2,three=1)
        self.assertEqual(len(d), 3)
        self.assertEqual(sorted(d.keys()), ['one', 'three', 'two'])
        self.assertEqual(sorted(d.values()), [1, 2, 3])
        self.assertEqual(sorted(d.items()),
                         [('one', 3), ('three', 1), ('two', 2)])

    def test_bool(self):
        d = redblack.dict()
        self.assertFalse(bool(d))
        d[2] = 'something'
        self.assertTrue(bool(d))

    def test_len(self):
        d = redblack.dict()
        self.assertEqual(len(d), 0)
        d[2] = 'something'
        self.assertEqual(len(d), 1)
        del d[2]
        self.assertEqual(len(d), 0)

    def test_missingkey(self):
        d = redblack.dict()
        self.assertRaises(KeyError, d.__getitem__, 2,)
        self.assertRaises(KeyError, d.__delitem__, 2,)

    def test_set(self):
        for _try in range(15):
            d1 = dict()
            d2 = redblack.dict()
            for _iter in range(5000):
                num = random.randint(0, 10000)
                key = 'big string key value {}'.format(num)
                val = 'big string value value {}'.format(num)
                d1[key] = val
                d2[key] = val
            self.assertEqual(len(d1), len(d2))
            self.assertEqual(sorted(d1.keys()), sorted(d2.keys()))
            self.assertEqual(sorted(d1.values()), sorted(d2.values()))
            self.assertEqual(sorted(d1.items()), sorted(d2.items()))

    def test_ops(self):
        for _try in range(15):
            d1 = dict()
            d2 = redblack.dict()
            for _iter in range(50000):
                num = random.randint(0, 10000)
                key = 'big string key value {}'.format(num)
                val = 'big string value value {}'.format(num)
                op = random.randint(0,1)
                if op == 0:
                    d1[key] = val
                    d2[key] = val
                elif op == 1:
                    d1.pop(key, None)
                    d2.pop(key, None)
            self.assertEqual(len(d1), len(d2))
            self.assertEqual(sorted(d1.keys()), sorted(d2.keys()))
            self.assertEqual(sorted(d1.values()), sorted(d2.values()))
            self.assertEqual(sorted(d1.items()), sorted(d2.items()))
