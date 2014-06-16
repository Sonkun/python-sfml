""" A convenience module that imports all other modules.

    Example::

        from sfml import sf

        window = sf.RenderWindow(sf.VideoMode(w, h), "pySFML - Pong")
"""

from sfml.system import *
from sfml.window import *
from sfml.graphics import *
from sfml.audio import *
from sfml.network import *
