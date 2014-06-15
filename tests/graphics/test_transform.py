#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# pySFML - Python bindings for SFML
# Copyright 2012-2013, Edwin Marshall <emarshall85@gmail.com>
#
# This software is released under the LGPLv3 license.
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


import pytest
from sfml import Transform

def test_transform_repr():
    t = Transform().translate((2, 3))
    assert repr(t) == 'Transform(1.0, 0.0, 2.0, 0.0, 1.0, 3.0, 0.0, 0.0, 1.0)'
    t = Transform.from_values(1, 2, 3, 4, 5, 6, 7, 8, 9)
    assert repr(t) == 'Transform(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)'

def test_transform_str():
    t = Transform.from_values(1, 2, 3, 4, 5, 6, 7, 8, 9)
    assert str(t) == '[1.0, 2.0, 3.0]\n[4.0, 5.0, 6.0]\n[7.0, 8.0, 9.0]'
