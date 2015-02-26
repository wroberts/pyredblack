#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
testdict.py
(c) Will Roberts  25 February, 2015

Unit tests for the redblack.rbdict class.
'''

import random
import unittest
from .. import redblack

class TestDict(unittest.TestCase):

    @unittest.expectedFailure
    def test_ctor_none(self):
        # dict(None) raises TypeError
        # redblack.rbdict does not
        self.assertRaises(TypeError, redblack.rbdict, None)

    def test_ctor1(self):
        # dict(2) raises TypeError
        self.assertRaises(TypeError, redblack.rbdict, 2)

    def test_ctor2(self):
        # dict([1,2,3]) raises TypeError
        self.assertRaises(TypeError, redblack.rbdict, [1,2,3],)

    def test_ctor3(self):
        # dict('abc') raises ValueError
        self.assertRaises(ValueError, redblack.rbdict, 'abc')

    def test_ctor4(self):
        # dict([(1,2), (2,3), (3,3)]) raises no error
        d = redblack.rbdict([(1,2), (2,3), (3,3)])
        self.assertEqual(len(d), 3)
        self.assertEqual(sorted(d.keys()), [1, 2, 3])
        self.assertEqual(sorted(d.values()), [2, 3, 3])
        self.assertEqual(sorted(d.items()), [(1, 2), (2, 3), (3, 3)])

    def test_ctor5(self):
        # dict([(1,2,1), (2,3,2), (3,3,2)]) raises ValueError
        self.assertRaises(ValueError, redblack.rbdict,
                          [(1,2,1), (2,3,2), (3,3,2)])

    def test_ctor6(self):
        # dict(one=3,two=2,three=1) raises no error
        d = redblack.rbdict(one=3,two=2,three=1)
        self.assertEqual(len(d), 3)
        self.assertEqual(sorted(d.keys()), ['one', 'three', 'two'])
        self.assertEqual(sorted(d.values()), [1, 2, 3])
        self.assertEqual(sorted(d.items()),
                         [('one', 3), ('three', 1), ('two', 2)])

    def test_bool(self):
        d = redblack.rbdict()
        self.assertFalse(bool(d))
        d[2] = 'something'
        self.assertTrue(bool(d))

    def test_len(self):
        d = redblack.rbdict()
        self.assertEqual(len(d), 0)
        d[2] = 'something'
        self.assertEqual(len(d), 1)
        del d[2]
        self.assertEqual(len(d), 0)

    def test_missingkey(self):
        d = redblack.rbdict()
        self.assertRaises(KeyError, d.__getitem__, 2,)
        self.assertRaises(KeyError, d.__delitem__, 2,)

    def test_set(self):
        for _try in range(15):
            d1 = dict()
            d2 = redblack.rbdict()
            for _iter in range(5000):
                num = random.randint(0, 1000)
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
            d2 = redblack.rbdict()
            for _iter in range(5000):
                num = random.randint(0, 1000)
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

    def test_popitem(self):
        d = redblack.rbdict()
        for _iter in range(5000):
            num = random.randint(0, 1000)
            key = 'big string key value {}'.format(num)
            val = 'big string value value {}'.format(num)
            d[key] = val
        items = list(d.items())
        items2 = []
        while d:
            items2.append(d.popitem())
        self.assertEqual(items, items2)

    def test_hashable(self):
        d = redblack.rbdict()
        # dict[[1,2]] raises TypeError
        self.assertRaises(TypeError, d.__setitem__, [1,2], 'stringval')

    def test_popitem(self):
        d = redblack.rbdict(Germany = 'Berlin',
                            Hungary = 'Budapest',
                            Ireland = 'Dublin',
                            Portugal = 'Lisbon',
                            Cyprus = 'Nicosia',
                            Greenland = 'Nuuk',
                            Iceland = 'Reykjavik',
                            Macedonia = 'Skopje',
                            Bulgaria = 'Sofia',
                            Sweden = 'Stockholm')
        for _try in range(5):
            self.assertEqual(d['Ireland'], 'Dublin')
        (k, v) = d.popitem()
        self.assertEqual(k, 'Bulgaria')
        self.assertEqual(v, 'Sofia')
