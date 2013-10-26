#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# pySFML - Python bindings for SFML
# Copyright 2012-2013, Jonathan De Wachter <dewachter.jonathan@gmail.com>
#
# This software is released under the LGPLv3 license.
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

from sfml import sf

import pyximport; pyximport.install()
import extension

window = sf.RenderWindow(sf.VideoMode(640, 480), "sfml")

image = sf.Image.from_file("image.jpg")
extension.flip_image(image)

texture = sf.Texture.from_image(image)

window.clear()
window.draw(sf.Sprite(texture))
window.display()

sf.sleep(sf.seconds(5))
