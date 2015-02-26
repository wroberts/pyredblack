#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
testset.py
(c) Will Roberts  26 February, 2015

Unit tests for the redblack.rbdict class.
'''

import random
import unittest
from .. import redblack

def make_random_set(size=1000):
    return set(random.randint(0,10000) for _elem in range(size))

def make_disjoint_sets(size=1000):
    a, b = make_random_set(size), make_random_set(size)
    return a, b-a

def make_overlapping_sets(size=1000):
    a, b = set(), set()
    while not a & b:
        a, b = make_random_set(size), make_random_set(size)
    return a, b

def make_subsets(size=1000):
    a, b = make_random_set(size), make_random_set(size)
    return a, a & b

def make_random_setpair(size=1000):
    op = random.randint(0,4)
    if op == 0:
        return make_disjoint_sets(size)
    elif op == 1:
        return make_overlapping_sets(size)
    elif op == 2:
        return make_subsets(size)
    elif op == 3:
        a, b = make_subsets(size)
        return b, a
    elif op == 4:
        a = make_random_set(size)
        return a, a

class TestSet(unittest.TestCase):

    @unittest.expectedFailure
    def test_ctor_none(self):
        # set(None) raises TypeError
        # redblack.rbset(None) does not
        self.assertRaises(TypeError, redblack.rbset, None)

    def test_ctor_1(self):
        # set(2) raises TypeError
        self.assertRaises(TypeError, redblack.rbset, 2)

    def test_ctor_2(self):
        # set([[1,2],[3,4],[5,6]]) raises TypeError
        self.assertRaises(TypeError, redblack.rbset, [[1,2],[3,4],[5,6]])

    def test_update(self):
        for _try in range(5):
            s1 = redblack.rbset()
            s2 = set()
            for _iter in range(10):
                vals = make_random_set(50)
                s1.update(vals)
                s2.update(vals)
                self.assertEqual(sorted(s1), sorted(s2))

    def test_contains(self):
        for _try in range(5):
            s = make_random_set(1000)
            s2 = redblack.rbset(s)
            for v in range(10000):
                rv1 = v in s
                rv2 = v in s2
                self.assertEqual(rv1, rv2)

    def test_disjoint(self):
        self.run_boolean('isdisjoint')

    def test_subset(self):
        self.run_boolean('issubset')

    def test_superset(self):
        self.run_boolean('issuperset')

    def test_lt(self):
        self.run_boolean('__lt__')

    def test_le(self):
        self.run_boolean('__le__')

    def test_eq(self):
        self.run_boolean('__eq__')

    def test_ne(self):
        self.run_boolean('__ne__')

    def test_gt(self):
        self.run_boolean('__gt__')

    def test_ge(self):
        self.run_boolean('__ge__')

    def run_boolean(self, op):
        for _try in range(10):
            a, b = make_random_setpair()
            rv1 = getattr(a, op)(b)
            rv2 = getattr(redblack.rbset(a), op)(redblack.rbset(b))
            self.assertEqual(rv1, rv2)

    def test_sub(self):
        self.run_algebra('__sub__')

    def test_and(self):
        self.run_algebra('__and__')

    def test_or(self):
        self.run_algebra('__or__')

    def test_xor(self):
        self.run_algebra('__xor__')

    def run_algebra(self, op):
        for _try in range(10):
            a, b = make_random_setpair()
            rv1 = getattr(a, op)(b)
            rv2 = getattr(redblack.rbset(a), op)(redblack.rbset(b))
            self.assertEqual(sorted(rv1), sorted(rv2))
