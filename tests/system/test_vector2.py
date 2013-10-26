#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# pySFML - Python bindings for SFML
# Copyright 2012-2013, Edwin Marshall <emarshall85@gmail.com>
#
# This software is released under the LGPLv3 license.
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


from __future__ import division
import pytest
from sfml import sf

@pytest.fixture
def vector():
    return [sf.Vector2(2, 5), sf.Vector2(5, 2)]

def test_x(vector):
    assert vector[0].x == 2

def test_y(vector):
    assert vector[0].y == 5
