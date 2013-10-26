#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# pySFML - Python bindings for SFML
# Copyright 2012-2013, Jonathan De Wachter <dewachter.jonathan@gmail.com>
#
# This software is released under the LGPLv3 license.
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import sys

try:
    from PyQt4.QtCore import *
    from PyQt4.QtGui import *
except ImportError:
    print("Install PyQt4 from Riverbank.")

from sfml import sf
from qsfml_canvas import QSFMLCanvas


class MyCyanCanvas(QSFMLCanvas):
    def __init__(self, parent, position, size):
        QSFMLCanvas.__init__(self, parent, position, size)

    def onInit(self):
        self.image = sf.Image.from_file("data/head_kid.png")
        self.texture = sf.Texture.from_image(self.image)
        self.sprite = sf.Sprite(self.texture)
        self.sprite.position = self.texture.size // (2, 2)

    def onUpdate(self):
        self.clear(sf.Color.CYAN)
        self.sprite.rotate(0.05)
        self.sprite.origin = self.texture.size // (2, 2)
        self.draw(self.sprite)

app = QApplication(sys.argv)

# create the main frame
mainFrame = QFrame()
mainFrame.setWindowTitle("pySFML - Qt")
mainFrame.resize(400, 400)
mainFrame.show()

# create a SFML view inside the main frame
SFMLView = MyCyanCanvas(mainFrame, QPoint(20, 20), QSize(360, 360))
SFMLView.show()

app.exec_()
sys.exit()
