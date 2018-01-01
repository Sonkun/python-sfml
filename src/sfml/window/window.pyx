# PySFML - Python bindings for SFML
# Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
#
# This file is part of PySFML project and is available under the zlib
# license.

cimport cython
from cython.operator cimport dereference as deref, preincrement as inc
from cpython.version cimport PY_VERSION_HEX

from libcpp.vector cimport vector

import collections
from enum import IntEnum

cimport sfml as sf
from sfml cimport Int8, Int16, Int32, Int64
from sfml cimport Uint8, Uint16, Uint32, Uint64

from pysfml.system cimport Vector2, Vector3
from pysfml.system cimport to_vector2i, to_vector2u
from pysfml.system cimport wrap_vector2i
from pysfml.system cimport to_string, wrap_string
from pysfml.system cimport popLastErrorMessage, import_sfml__system

import_sfml__system()

cdef extern from "pysfml/window/DerivableWindow.hpp":
    cdef cppclass DerivableWindow:
        DerivableWindow(object)

from libc.stdlib cimport malloc, free

__all__ = ['Style', 'VideoMode', 'ContextSettings', 'SizeEvent',
            'KeyEvent', 'TextEvent', 'MouseMoveEvent', 'MouseButtonEvent',
            'MouseWheelEvent', 'MouseWheelScrollEvent', 'JoystickMoveEvent',
            'JoystickButtonEvent', 'JoystickConnectEvent', 'TouchEvent',
            'SensorEvent', 'Event', 'Window', 'Keyboard', 'Joystick',
            'Mouse', 'Touch', 'Sensor', 'Context']

if PY_VERSION_HEX >= 0x03000000:
    unichr = chr

class Style(IntEnum):
    NONE = sf.style.None
    TITLEBAR = sf.style.Titlebar
    RESIZE = sf.style.Resize
    CLOSE = sf.style.Close
    FULLSCREEN = sf.style.Fullscreen
    DEFAULT = sf.style.Default


cdef class SizeEvent:
    cdef sf.SizeEvent* p_this
    cdef bint          p_owned

    def __init__(self):
        self.p_this = new sf.SizeEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "SizeEvent(width={0}, height={1})".format(self.width, self.height)

    property width:
        def __get__(self):
            return self.p_this.width

        def __set__(self, unsigned int  width):
            self.p_this.width = width

    property height:
        def __get__(self):
            return self.p_this.height

        def __set__(self, unsigned int  height):
            self.p_this.height = height


cdef class KeyEvent:
    cdef sf.KeyEvent* p_this
    cdef bint         p_owned

    def __init__(self):
        self.p_this = new sf.KeyEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "KeyEvent(code={0}, alt={1}, control={2}, shift={3}, system={4})".format(self.code,
            self.alt, self.control, self.shift, self.system)

    property code:
        def __get__(self):
            return self.p_this.code

        def __set__(self, sf.keyboard.Key code):
            self.p_this.code = code

    property alt:
        def __get__(self):
            return self.p_this.alt

        def __set__(self, bint alt):
            self.p_this.alt = alt

    property control:
        def __get__(self):
            return self.p_this.control

        def __set__(self, bint control):
            self.p_this.control = control

    property shift:
        def __get__(self):
            return self.p_this.shift

        def __set__(self, bint shift):
            self.p_this.shift = shift

    property system:
        def __get__(self):
            return self.p_this.system

        def __set__(self, bint system):
            self.p_this.system = system


cdef class TextEvent:
    cdef sf.TextEvent* p_this
    cdef bint          p_owned

    def __init__(self):
        self.p_this = new sf.TextEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "TextEvent(unicode={0})".format(self.unicode)

    property unicode:
        def __get__(self):
            return unichr(self.p_this.unicode)

        def __set__(self, Py_UNICODE _unicode):
            self.p_this.unicode = _unicode


cdef class MouseMoveEvent:
    cdef sf.MouseMoveEvent* p_this
    cdef bint               p_owned

    def __init__(self):
        self.p_this = new sf.MouseMoveEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "MouseMoveEvent(x={0}, y={1})".format(self.x, self.y)

    property x:
        def __get__(self):
            return self.p_this.x

        def __set__(self, int x):
            self.p_this.x = x

    property y:
        def __get__(self):
            return self.p_this.y

        def __set__(self, int y):
            self.p_this.y = y


cdef class MouseButtonEvent:
    cdef sf.MouseButtonEvent* p_this
    cdef bint                 p_owned

    def __init__(self):
        self.p_this = new sf.MouseButtonEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "MouseButtonEvent(button={0}, x={1}, y={2})".format(self.button,
            self.x, self.y)

    property button:
        def __get__(self):
            return self.p_this.button

        def __set__(self, sf.mouse.Button button):
            self.p_this.button = button

    property x:
        def __get__(self):
            return self.p_this.x

        def __set__(self, int x):
            self.p_this.x = x

    property y:
        def __get__(self):
            return self.p_this.y

        def __set__(self, int y):
            self.p_this.y = y


cdef class MouseWheelEvent:
    cdef sf.MouseWheelEvent* p_this
    cdef bint                p_owned

    def __init__(self):
        self.p_this = new sf.MouseWheelEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "MouseWheelEvent(delta={0}, x={1}, y={2})".format(self.delta,
            self.x, self.y)

    property delta:
        def __get__(self):
            return self.p_this.delta

        def __set__(self, int delta):
            self.p_this.delta = delta

    property x:
        def __get__(self):
            return self.p_this.x

        def __set__(self, int x):
            self.p_this.x = x

    property y:
        def __get__(self):
            return self.p_this.y

        def __set__(self, int y):
            self.p_this.y = y


cdef class MouseWheelScrollEvent:
    cdef sf.MouseWheelScrollEvent* p_this
    cdef bint                      p_owned

    def __init__(self):
        self.p_this = new sf.MouseWheelScrollEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "MouseWheelScrollEvent(wheel={0}, delta={1}, x={2}, y={3})".format(self.wheel,
            self.delta, self.x, self.y)

    property wheel:
        def __get__(self):
            return self.p_this.wheel

        def __set__(self, sf.mouse.Wheel wheel):
            self.p_this.wheel = wheel

    property delta:
        def __get__(self):
            return self.p_this.delta

        def __set__(self, float delta):
            self.p_this.delta = delta

    property x:
        def __get__(self):
            return self.p_this.x

        def __set__(self, int x):
            self.p_this.x = x

    property y:
        def __get__(self):
            return self.p_this.y

        def __set__(self, int y):
            self.p_this.y = y


cdef class JoystickMoveEvent:
    cdef sf.JoystickMoveEvent* p_this
    cdef bint                  p_owned

    def __init__(self):
        self.p_this = new sf.JoystickMoveEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "JoystickMoveEvent(joystick_id={0}, axis={1}, position={2})".format(self.joystick_id,
            self.axis, self.position)

    property joystick_id:
        def __get__(self):
            return self.p_this.joystickId

        def __set__(self, unsigned int joystick_id):
            self.p_this.joystickId = joystick_id

    property axis:
        def __get__(self):
            return self.p_this.axis

        def __set__(self, sf.joystick.Axis axis):
            self.p_this.axis = axis

    property position:
        def __get__(self):
            return self.p_this.position

        def __set__(self, float position):
            self.p_this.position = position


cdef class JoystickButtonEvent:
    cdef sf.JoystickButtonEvent* p_this
    cdef bint                    p_owned

    def __init__(self):
        self.p_this = new sf.JoystickButtonEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "JoystickButtonEvent(joystick_id={0}, button={1})".format(self.joystick_id,
            self.button)

    property joystick_id:
        def __get__(self):
            return self.p_this.joystickId

        def __set__(self, unsigned int joystick_id):
            self.p_this.joystickId = joystick_id

    property button:
        def __get__(self):
            return self.p_this.button

        def __set__(self, unsigned int button):
            self.p_this.button = button


cdef class JoystickConnectEvent:
    cdef sf.JoystickConnectEvent* p_this
    cdef bint                     p_owned

    def __init__(self):
        self.p_this = new sf.JoystickConnectEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "JoystickConnectEvent(joystick_id={0})".format(self.joystick_id)

    property joystick_id:
        def __get__(self):
            return self.p_this.joystickId

        def __set__(self, unsigned int joystick_id):
            self.p_this.joystickId = joystick_id


cdef class TouchEvent:
    cdef sf.TouchEvent* p_this
    cdef bint           p_owned

    def __init__(self):
        self.p_this = new sf.TouchEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "TouchEvent(finger={0}, x={1}, y={2})".format(self.finger,
            self.x, self.y)

    property finger:
        def __get__(self):
            return self.p_this.finger

        def __set__(self, int finger):
            self.p_this.finger = finger

    property x:
        def __get__(self):
            return self.p_this.x

        def __set__(self, int x):
            self.p_this.x = x

    property y:
        def __get__(self):
            return self.p_this.y

        def __set__(self, int y):
            self.p_this.y = y


cdef class SensorEvent:
    cdef sf.SensorEvent* p_this
    cdef bint            p_owned

    def __init__(self):
        self.p_this = new sf.SensorEvent()
        self.p_owned = True

    def __dealloc__(self):
        if self.p_owned:
            del self.p_this

    def __repr__(self):
        return "SensorEvent(type={0}, x={1}, y={2}, z={3})".format(self.type,
            self.x, self.y, self.z)

    property type:
        def __get__(self):
            return self.p_this.type

        def __set__(self, sf.sensor.Type type):
            self.p_this.type = type

    property x:
        def __get__(self):
            return self.p_this.x

        def __set__(self, float x):
            self.p_this.x = x

    property y:
        def __get__(self):
            return self.p_this.y

        def __set__(self, float y):
            self.p_this.y = y

    property z:
        def __get__(self):
            return self.p_this.z

        def __set__(self, float z):
            self.p_this.z = z


class EventData(collections.Mapping):
    def __init__(self, event, attributes):
        self.event = event
        self.attributes = attributes

    def __getitem__(self, name):
        if name not in self.attributes:
            raise KeyError("Event has no {0} attribute".format(name))

        return self.event.__class__.__dict__[name].__get__(self.event)

    def __setitem__(self, name, value):
        if name not in self.attributes:
            raise KeyError("Event has no {0} attribute".format(name))

        self.event.__class__.__dict__[name].__set__(self.event, value)

    def __iter__(self):
        return iter(self.attributes)

    def __len__(self):
        return len(self.attributes)

class EventType(IntEnum):
    CLOSED = sf.event.Closed
    RESIZED = sf.event.Resized
    LOST_FOCUS = sf.event.LostFocus
    GAINED_FOCUS = sf.event.GainedFocus
    TEXT_ENTERED = sf.event.TextEntered
    KEY_PRESSED = sf.event.KeyPressed
    KEY_RELEASED = sf.event.KeyReleased
    MOUSE_WHEEL_MOVED = sf.event.MouseWheelMoved
    MOUSE_WHEEL_SCROLLED = sf.event.MouseWheelScrolled
    MOUSE_BUTTON_PRESSED = sf.event.MouseButtonPressed
    MOUSE_BUTTON_RELEASED = sf.event.MouseButtonReleased
    MOUSE_MOVED = sf.event.MouseMoved
    MOUSE_ENTERED = sf.event.MouseEntered
    MOUSE_LEFT = sf.event.MouseLeft
    JOYSTICK_BUTTON_PRESSED = sf.event.JoystickButtonPressed
    JOYSTICK_BUTTON_RELEASED = sf.event.JoystickButtonReleased
    JOYSTICK_MOVED = sf.event.JoystickMoved
    JOYSTICK_CONNECTED = sf.event.JoystickConnected
    JOYSTICK_DISCONNECTED = sf.event.JoystickDisconnected
    TOUCH_BEGAN = sf.event.TouchBegan
    TOUCH_MOVED = sf.event.TouchMoved
    TOUCH_ENDED = sf.event.TouchEnded
    SENSOR_CHANGED = sf.event.SensorChanged
    COUNT = sf.event.Count


cdef public class Event[type PyEventType, object PyEventObject]:
    cdef sf.Event *p_this
    cdef object data

    CLOSED = EventType.CLOSED
    RESIZED = EventType.RESIZED
    LOST_FOCUS = EventType.LOST_FOCUS
    GAINED_FOCUS = EventType.GAINED_FOCUS
    TEXT_ENTERED = EventType.TEXT_ENTERED
    KEY_PRESSED = EventType.KEY_PRESSED
    KEY_RELEASED = EventType.KEY_RELEASED
    MOUSE_WHEEL_MOVED = EventType.MOUSE_WHEEL_MOVED
    MOUSE_WHEEL_SCROLLED = EventType.MOUSE_WHEEL_SCROLLED
    MOUSE_BUTTON_PRESSED = EventType.MOUSE_BUTTON_PRESSED
    MOUSE_BUTTON_RELEASED = EventType.MOUSE_BUTTON_RELEASED
    MOUSE_MOVED = EventType.MOUSE_MOVED
    MOUSE_ENTERED = EventType.MOUSE_ENTERED
    MOUSE_LEFT = EventType.MOUSE_LEFT
    JOYSTICK_BUTTON_PRESSED = EventType.JOYSTICK_BUTTON_PRESSED
    JOYSTICK_BUTTON_RELEASED = EventType.JOYSTICK_BUTTON_RELEASED
    JOYSTICK_MOVED = EventType.JOYSTICK_MOVED
    JOYSTICK_CONNECTED = EventType.JOYSTICK_CONNECTED
    JOYSTICK_DISCONNECTED = EventType.JOYSTICK_DISCONNECTED
    TOUCH_BEGAN = EventType.TOUCH_BEGAN
    TOUCH_MOVED = EventType.TOUCH_MOVED
    TOUCH_ENDED = EventType.TOUCH_ENDED
    SENSOR_CHANGED = EventType.SENSOR_CHANGED
    COUNT = EventType.COUNT

    def __init__(self, type=EventType.CLOSED):
        self.p_this = new sf.Event()
        self.type = type

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "Event(type={0}, data={1})".format(self.type, self.items())

    def __contains__(self, item):
        return self.data.__contains__(item)

    def __richcmp__(self, other, int op):
        if op == 2:
            return self.type == other
        elif op == 3:
            return self.type != other
        else:
            return NotImplemented

    def __getitem__(self, name):
        if not self.data:
            raise KeyError("Event has no data")

        return self.data[name]

    def __setitem__(self, name, value):
        if not self.data:
            raise KeyError("Event has no data")

        self.data[name] = value

    property type:
        def __get__(self):
            return self.p_this.type

        def __set__(self, sf.event.EventType type):
            self.p_this.type = type

            if type == self.RESIZED:
                event = SizeEvent.__new__(SizeEvent)
                (<SizeEvent>event).p_this = &self.p_this.size
                (<SizeEvent>event).p_owned = False
                self.data = EventData(event,  ['width', 'height'])
            elif type == self.KEY_PRESSED or type == self.KEY_RELEASED:
                event = KeyEvent.__new__(KeyEvent)
                (<KeyEvent>event).p_this = &self.p_this.key
                self.data = EventData(event,  ['code', 'alt', 'control', 'shift', 'system'])
            elif type == self.TEXT_ENTERED:
                event = TextEvent.__new__(TextEvent)
                (<TextEvent>event).p_this = &self.p_this.text
                self.data = EventData(event,  ['unicode'])
            elif type == self.MOUSE_MOVED:
                event = MouseMoveEvent.__new__(MouseMoveEvent)
                (<MouseMoveEvent>event).p_this = &self.p_this.mouseMove
                self.data = EventData(event,  ['x', 'y'])
            elif type == self.MOUSE_BUTTON_PRESSED or type == self.MOUSE_BUTTON_RELEASED:
                event = MouseButtonEvent.__new__(MouseButtonEvent)
                (<MouseButtonEvent>event).p_this = &self.p_this.mouseButton
                self.data = EventData(event,  ['button', 'x', 'y'])
            elif type == self.MOUSE_WHEEL_MOVED:
                event = MouseWheelEvent.__new__(MouseWheelEvent)
                (<MouseWheelEvent>event).p_this = &self.p_this.mouseWheel
                self.data = EventData(event,  ['delta', 'x', 'y'])
            elif type == self.MOUSE_WHEEL_SCROLLED:
                event = MouseWheelScrollEvent.__new__(MouseWheelScrollEvent)
                (<MouseWheelScrollEvent>event).p_this = &self.p_this.mouseWheelScroll
                self.data = EventData(event,  ['wheel', 'delta', 'x', 'y'])
            elif type == self.JOYSTICK_MOVED:
                event = JoystickMoveEvent.__new__(JoystickMoveEvent)
                (<JoystickMoveEvent>event).p_this = &self.p_this.joystickMove
                self.data = EventData(event,  ['joystick_id', 'axis', 'position'])
            elif type == self.JOYSTICK_BUTTON_PRESSED or type == self.JOYSTICK_BUTTON_RELEASED:
                event = JoystickButtonEvent.__new__(JoystickButtonEvent)
                (<JoystickButtonEvent>event).p_this = &self.p_this.joystickButton
                self.data = EventData(event,  ['joystick_id', 'button'])
            elif type == self.JOYSTICK_CONNECTED or type == self.JOYSTICK_DISCONNECTED:
                event = JoystickConnectEvent.__new__(JoystickConnectEvent)
                (<JoystickConnectEvent>event).p_this = &self.p_this.joystickConnect
                self.data = EventData(event,  ['joystick_id'])
            elif type == self.TOUCH_BEGAN or type == self.TOUCH_MOVED or type == self.TOUCH_ENDED:
                event = TouchEvent.__new__(TouchEvent)
                (<TouchEvent>event).p_this = &self.p_this.touch
                self.data = EventData(event,  ['finger', 'x', 'y'])
            elif type == self.SENSOR_CHANGED:
                event = SensorEvent.__new__(SensorEvent)
                (<SensorEvent>event).p_this = &self.p_this.sensor
                self.data = EventData(event,  ['type', 'x', 'y', 'z'])
            else:
                self.data = None

    def get(self, key, default=None):
        if not self.data:
            return None

        return self.data.get(key, default)

    def items(self):
        if not self.data:
            return []

        return self.data.items()

    def keys(self):
        if not self.data:
            return []

        return self.data.keys()

    def values(self):
        if not self.data:
            return []

        return self.data.values()

cdef api Event wrap_event(sf.Event *p):
    cdef Event event = Event.__new__(Event)

    event.p_this = p
    event.data = None

    event.type = p.type

    return event

cdef public class VideoMode[type PyVideoModeType, object PyVideoModeObject]:
    cdef sf.VideoMode *p_this
    cdef bint delete_this

    def __init__(self, unsigned int mode_width, unsigned int mode_height, unsigned int mode_bits_per_pixel=32):
        self.p_this = new sf.VideoMode(mode_width, mode_height, mode_bits_per_pixel)
        self.delete_this = True

    def __dealloc__(self):
        if self.delete_this:
            del self.p_this

    def __repr__(self):
        return "VideoMode(size={0}, size={1}, bits_per_pixel={2})".format(self.width, self.height, self.bits_per_pixel)

    def __str__(self):
        return "{0}x{1}x{2}".format(self.width, self.height, self.bits_per_pixel)

    def __richcmp__(VideoMode x, VideoMode y, int op):
        if op == 0:
            return x.p_this[0] <  y.p_this[0]
        elif op == 2:
            return x.p_this[0] == y.p_this[0]
        elif op == 4:
            return x.p_this[0] >  y.p_this[0]
        elif op == 1:
            return x.p_this[0] <= y.p_this[0]
        elif op == 3:
            return x.p_this[0] != y.p_this[0]
        elif op == 5:
            return x.p_this[0] >= y.p_this[0]

    def __iter__(self):
        return iter((self.width, self.height, self.bits_per_pixel))

    property width:
        def __get__(self):
            return self.p_this.width

        def __set__(self, unsigned int width):
            self.p_this.width = width

    property height:
        def __get__(self):
            return self.p_this.height

        def __set__(self, unsigned int height):
            self.p_this.height = height

    property bits_per_pixel:
        def __get__(self):
            return self.p_this.bitsPerPixel

        def __set__(self, unsigned int bits_per_pixel):
            self.p_this.bitsPerPixel = bits_per_pixel

    @staticmethod
    def get_desktop_mode():
        cdef sf.VideoMode *p = new sf.VideoMode()
        p[0] = sf.videomode.getDesktopMode()

        return wrap_videomode(p, True)

    @staticmethod
    def get_fullscreen_modes():
        cdef list modes = []
        cdef vector[sf.VideoMode] *v = new vector[sf.VideoMode]()
        v[0] = sf.videomode.getFullscreenModes()

        cdef vector[sf.VideoMode].iterator it = v.begin()
        cdef sf.VideoMode vm

        while it != v.end():
            vm = deref(it)
            modes.append(VideoMode(vm.width, vm.height, vm.bitsPerPixel))
            inc(it)

        return modes

    def is_valid(self):
        return self.p_this.isValid()

cdef VideoMode wrap_videomode(sf.VideoMode *p, bint d):
    cdef VideoMode r = VideoMode.__new__(VideoMode, 640, 480, 32)
    r.p_this = p
    r.delete_this = d
    return r


class Attribute(IntEnum):
    DEFAULT = sf.contextsettings.Default
    CORE = sf.contextsettings.Core
    DEBUG = sf.contextsettings.Debug

cdef public class ContextSettings[type PyContextSettingsType, object PyContextSettingsObject]:
    cdef sf.ContextSettings *p_this

    def __init__(self, unsigned int depth=0, unsigned int stencil=0, unsigned int antialiasing=0, unsigned int major=1, unsigned int minor=1, int attributes=Attribute.DEFAULT):
        self.p_this = new sf.ContextSettings(depth, stencil, antialiasing, major, minor, attributes)

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "ContextSettings(depth_bits={0}, stencil_bits={1}, antialiasing_level={2}, major_version={3}, minor_version={4})".format(self.depth_bits, self.stencil_bits, self.antialiasing_level, self.major_version, self.minor_version)

    def __iter__(self):
        return iter((self.depth_bits, self.stencil_bits, self.antialiasing_level, self.major_version, self.minor_version))

    property depth_bits:
        def __get__(self):
            return self.p_this.depthBits

        def __set__(self, unsigned int depth_bits):
            self.p_this.depthBits = depth_bits

    property stencil_bits:
        def __get__(self):
            return self.p_this.stencilBits

        def __set__(self, unsigned int stencil_bits):
            self.p_this.stencilBits = stencil_bits

    property antialiasing_level:
        def __get__(self):
            return self.p_this.antialiasingLevel

        def __set__(self, unsigned int antialiasing_level):
            self.p_this.antialiasingLevel = antialiasing_level

    property major_version:
        def __get__(self):
            return self.p_this.majorVersion

        def __set__(self, unsigned int major_version):
            self.p_this.majorVersion = major_version

    property minor_version:
        def __get__(self):
            return self.p_this.minorVersion

        def __set__(self, unsigned int minor_version):
            self.p_this.minorVersion = minor_version

    property attribute_flags:
        def __get__(self):
            return self.p_this.attributeFlags

        def __set__(self, int attribute_flags):
            self.p_this.attributeFlags = attribute_flags

cdef ContextSettings wrap_contextsettings(sf.ContextSettings *v):
    cdef ContextSettings r = ContextSettings.__new__(ContextSettings)
    r.p_this = v
    return r


cdef public class Window[type PyWindowType, object PyWindowObject]:
    cdef sf.Window *p_window

    def __init__(self, VideoMode mode, unicode title, Uint32 style=sf.style.Default, ContextSettings settings=ContextSettings()):
        if self.p_window == NULL:
            self.p_window = <sf.Window*>new DerivableWindow(self)
            self.p_window.create(mode.p_this[0], to_string(title), style, settings.p_this[0])

    def __dealloc__(self):
        if self.p_window != NULL:
            del self.p_window

    def __repr__(self):
        return "Window(position={0}, size={1}, is_open={2})".format(self.position, self.size, self.is_open)

    def create(self, VideoMode mode, title, Uint32 style=sf.style.Default, ContextSettings settings=ContextSettings()):
        self.p_window.create(mode.p_this[0], to_string(title), style, settings.p_this[0])

    def close(self):
        self.p_window.close()

    property is_open:
        def __get__(self):
            return self.p_window.isOpen()

    property settings:
        def __get__(self):
            cdef sf.ContextSettings *p = new sf.ContextSettings()
            p[0] = self.p_window.getSettings()
            return wrap_contextsettings(p)

        def __set__(self, settings):
            raise NotImplemented

    property events:
        def __get__(self):
            return Window.events_generator(self)

    def events_generator(window):
        cdef sf.Event  event
        cdef sf.Event* p

        while window.p_window.pollEvent(event):
            p = new sf.Event()
            p[0] = event
            yield wrap_event(p)


    def poll_event(self):
        cdef sf.Event *p = new sf.Event()

        if self.p_window.pollEvent(p[0]):
            return wrap_event(p)

    def wait_event(self):
        cdef sf.Event *p = new sf.Event()

        if self.p_window.waitEvent(p[0]):
            return wrap_event(p)

    property position:
        def __get__(self):
            return wrap_vector2i(self.p_window.getPosition())

        def __set__(self, position):
            self.p_window.setPosition(to_vector2i(position))

    property size:
        def __get__(self):
            return Vector2(self.p_window.getSize().x, self.p_window.getSize().y)

        def __set__(self, size):
            self.p_window.setSize(to_vector2u(size))

    property title:
        def __set__(self, unicode title):
            self.p_window.setTitle(to_string(title))

    def set_icon(self, int width, int height, bytes pixels):
        self.p_window.setIcon(width, height, <sf.Uint8*>pixels)

    property visible:
        def __set__(self, bint visible):
            self.p_window.setVisible(visible)

    def show(self):
        self.visible = True

    def hide(self):
        self.visible = False

    property vertical_synchronization:
        def __set__(self, bint vertical_synchronization):
            self.p_window.setVerticalSyncEnabled(vertical_synchronization)

    property mouse_cursor_visible:
        def __set__(self, bint mouse_cursor_visible):
            self.p_window.setMouseCursorVisible(mouse_cursor_visible)

    property key_repeat_enabled:
        def __set__(self, bint key_repeat_enabled):
            self.p_window.setKeyRepeatEnabled(key_repeat_enabled)

    property framerate_limit:
        def __set__(self, unsigned int framerate_limit):
            self.p_window.setFramerateLimit(framerate_limit)

    property joystick_threshold:
        def __set__(self, float joystick_threshold):
            self.p_window.setJoystickThreshold(joystick_threshold)

    property active:
        def __set__(self, bint active):
            self.p_window.setActive(active)

    def request_focus(self):
        self.p_window.requestFocus()

    def has_focus(self):
        return self.p_window.hasFocus()

    def display(self):
        self.p_window.display()

    property system_handle:
        def __get__(self):
            return <unsigned long>self.p_window.getSystemHandle()

    def on_create(self):
        pass

    def on_resize(self):
        pass


class Key(IntEnum):
    UNKNOWN = sf.keyboard.Unknown
    A = sf.keyboard.A
    B = sf.keyboard.B
    C = sf.keyboard.C
    D = sf.keyboard.D
    E = sf.keyboard.E
    F = sf.keyboard.F
    G = sf.keyboard.G
    H = sf.keyboard.H
    I = sf.keyboard.I
    J = sf.keyboard.J
    K = sf.keyboard.K
    L = sf.keyboard.L
    M = sf.keyboard.M
    N = sf.keyboard.N
    O = sf.keyboard.O
    P = sf.keyboard.P
    Q = sf.keyboard.Q
    R = sf.keyboard.R
    S = sf.keyboard.S
    T = sf.keyboard.T
    U = sf.keyboard.U
    V = sf.keyboard.V
    W = sf.keyboard.W
    X = sf.keyboard.X
    Y = sf.keyboard.Y
    Z = sf.keyboard.Z
    NUM0 = sf.keyboard.Num0
    NUM1 = sf.keyboard.Num1
    NUM2 = sf.keyboard.Num2
    NUM3 = sf.keyboard.Num3
    NUM4 = sf.keyboard.Num4
    NUM5 = sf.keyboard.Num5
    NUM6 = sf.keyboard.Num6
    NUM7 = sf.keyboard.Num7
    NUM8 = sf.keyboard.Num8
    NUM9 = sf.keyboard.Num9
    ESCAPE = sf.keyboard.Escape
    L_CONTROL = sf.keyboard.LControl
    L_SHIFT = sf.keyboard.LShift
    L_ALT = sf.keyboard.LAlt
    L_SYSTEM = sf.keyboard.LSystem
    R_CONTROL = sf.keyboard.RControl
    R_SHIFT = sf.keyboard.RShift
    R_ALT = sf.keyboard.RAlt
    R_SYSTEM = sf.keyboard.RSystem
    MENU = sf.keyboard.Menu
    L_BRACKET = sf.keyboard.LBracket
    R_BRACKET = sf.keyboard.RBracket
    SEMI_COLON = sf.keyboard.SemiColon
    COMMA = sf.keyboard.Comma
    PERIOD = sf.keyboard.Period
    QUOTE = sf.keyboard.Quote
    SLASH = sf.keyboard.Slash
    BACK_SLASH = sf.keyboard.BackSlash
    TILDE = sf.keyboard.Tilde
    EQUAL = sf.keyboard.Equal
    DASH = sf.keyboard.Dash
    SPACE = sf.keyboard.Space
    RETURN = sf.keyboard.Return
    BACK_SPACE = sf.keyboard.BackSpace
    TAB = sf.keyboard.Tab
    PAGE_UP = sf.keyboard.PageUp
    PAGE_DOWN = sf.keyboard.PageDown
    END = sf.keyboard.End
    HOME = sf.keyboard.Home
    INSERT = sf.keyboard.Insert
    DELETE = sf.keyboard.Delete
    ADD = sf.keyboard.Add
    SUBTRACT = sf.keyboard.Subtract
    MULTIPLY = sf.keyboard.Multiply
    DIVIDE = sf.keyboard.Divide
    LEFT = sf.keyboard.Left
    RIGHT = sf.keyboard.Right
    UP = sf.keyboard.Up
    DOWN = sf.keyboard.Down
    NUMPAD0 = sf.keyboard.Numpad0
    NUMPAD1 = sf.keyboard.Numpad1
    NUMPAD2 = sf.keyboard.Numpad2
    NUMPAD3 = sf.keyboard.Numpad3
    NUMPAD4 = sf.keyboard.Numpad4
    NUMPAD5 = sf.keyboard.Numpad5
    NUMPAD6 = sf.keyboard.Numpad6
    NUMPAD7 = sf.keyboard.Numpad7
    NUMPAD8 = sf.keyboard.Numpad8
    NUMPAD9 = sf.keyboard.Numpad9
    F1 = sf.keyboard.F1
    F2 = sf.keyboard.F2
    F3 = sf.keyboard.F3
    F4 = sf.keyboard.F4
    F5 = sf.keyboard.F5
    F6 = sf.keyboard.F6
    F7 = sf.keyboard.F7
    F8 = sf.keyboard.F8
    F9 = sf.keyboard.F9
    F10 = sf.keyboard.F10
    F11 = sf.keyboard.F11
    F12 = sf.keyboard.F12
    F13 = sf.keyboard.F13
    F14 = sf.keyboard.F14
    F15 = sf.keyboard.F15
    PAUSE = sf.keyboard.Pause
    KEY_COUNT = sf.keyboard.KeyCount


cdef class Keyboard:
    A = Key.A
    B = Key.B
    C = Key.C
    D = Key.D
    E = Key.E
    F = Key.F
    G = Key.G
    H = Key.H
    I = Key.I
    J = Key.J
    K = Key.K
    L = Key.L
    M = Key.M
    N = Key.N
    O = Key.O
    P = Key.P
    Q = Key.Q
    R = Key.R
    S = Key.S
    T = Key.T
    U = Key.U
    V = Key.V
    W = Key.W
    X = Key.X
    Y = Key.Y
    Z = Key.Z
    NUM0 = Key.NUM0
    NUM1 = Key.NUM1
    NUM2 = Key.NUM2
    NUM3 = Key.NUM3
    NUM4 = Key.NUM4
    NUM5 = Key.NUM5
    NUM6 = Key.NUM6
    NUM7 = Key.NUM7
    NUM8 = Key.NUM8
    NUM9 = Key.NUM9
    ESCAPE = Key.ESCAPE
    L_CONTROL = Key.L_CONTROL
    L_SHIFT = Key.L_SHIFT
    L_ALT = Key.L_ALT
    L_SYSTEM = Key.L_SYSTEM
    R_CONTROL = Key.R_CONTROL
    R_SHIFT = Key.R_SHIFT
    R_ALT = Key.R_ALT
    R_SYSTEM = Key.R_SYSTEM
    MENU = Key.MENU
    L_BRACKET = Key.L_BRACKET
    R_BRACKET = Key.R_BRACKET
    SEMI_COLON = Key.SEMI_COLON
    COMMA = Key.COMMA
    PERIOD = Key.PERIOD
    QUOTE = Key.QUOTE
    SLASH = Key.SLASH
    BACK_SLASH = Key.BACK_SLASH
    TILDE = Key.TILDE
    EQUAL = Key.EQUAL
    DASH = Key.DASH
    SPACE = Key.SPACE
    RETURN = Key.RETURN
    BACK_SPACE = Key.BACK_SPACE
    TAB = Key.TAB
    PAGE_UP = Key.PAGE_UP
    PAGE_DOWN = Key.PAGE_DOWN
    END = Key.END
    HOME = Key.HOME
    INSERT = Key.INSERT
    DELETE = Key.DELETE
    ADD = Key.ADD
    SUBTRACT = Key.SUBTRACT
    MULTIPLY = Key.MULTIPLY
    DIVIDE = Key.DIVIDE
    LEFT = Key.LEFT
    RIGHT = Key.RIGHT
    UP = Key.UP
    DOWN = Key.DOWN
    NUMPAD0 = Key.NUMPAD0
    NUMPAD1 = Key.NUMPAD1
    NUMPAD2 = Key.NUMPAD2
    NUMPAD3 = Key.NUMPAD3
    NUMPAD4 = Key.NUMPAD4
    NUMPAD5 = Key.NUMPAD5
    NUMPAD6 = Key.NUMPAD6
    NUMPAD7 = Key.NUMPAD7
    NUMPAD8 = Key.NUMPAD8
    NUMPAD9 = Key.NUMPAD9
    F1 = Key.F1
    F2 = Key.F2
    F3 = Key.F3
    F4 = Key.F4
    F5 = Key.F5
    F6 = Key.F6
    F7 = Key.F7
    F8 = Key.F8
    F9 = Key.F9
    F10 = Key.F10
    F11 = Key.F11
    F12 = Key.F12
    F13 = Key.F13
    F14 = Key.F14
    F15 = Key.F15
    PAUSE = Key.PAUSE
    KEY_COUNT = Key.KEY_COUNT

    def __init__(self):
        raise NotImplementedError("This class is not meant to be instantiated!")

    @staticmethod
    def is_key_pressed(int key):
        return sf.keyboard.isKeyPressed(<sf.keyboard.Key>key)

    @staticmethod
    def set_virtual_keyboard_visible(bint visible):
        sf.keyboard.setVirtualKeyboardVisible(visible)

class Axis(IntEnum):
    X = sf.joystick.X
    Y = sf.joystick.Y
    Z = sf.joystick.Z
    R = sf.joystick.R
    U = sf.joystick.U
    V = sf.joystick.V
    POV_X = sf.joystick.PovX
    POV_Y = sf.joystick.PovY

cdef class Joystick:
    COUNT = sf.joystick.Count
    BUTTON_COUNT = sf.joystick.ButtonCount
    AXIS_COUNT = sf.joystick.AxisCount

    def __init__(self):
        raise NotImplementedError("This class is not meant to be instantiated!")

    @staticmethod
    def is_connected(unsigned int joystick):
        return sf.joystick.isConnected(joystick)

    @staticmethod
    def get_button_count(unsigned int joystick):
        return sf.joystick.getButtonCount(joystick)

    @staticmethod
    def has_axis(unsigned int joystick, int axis):
        return sf.joystick.hasAxis(joystick, <sf.joystick.Axis>axis)

    @staticmethod
    def is_button_pressed(unsigned int joystick, unsigned int button):
        return sf.joystick.isButtonPressed(joystick, button)

    @staticmethod
    def get_axis_position(unsigned int joystick, int axis):
        return sf.joystick.getAxisPosition(joystick, <sf.joystick.Axis> axis)

    @staticmethod
    def get_identification(unsigned int joystick):
        cdef sf.joystick.Identification identification
        identification = sf.joystick.getIdentification(joystick)
        return (wrap_string(&identification.name), identification.vendorId, identification.productId)

    @staticmethod
    def update():
        sf.joystick.update()

class Button(IntEnum):
    LEFT = sf.mouse.Left
    RIGHT = sf.mouse.Right
    MIDDLE = sf.mouse.Middle
    X_BUTTON1 = sf.mouse.XButton1
    X_BUTTON2 = sf.mouse.XButton2
    BUTTON_COUNT = sf.mouse.ButtonCount

class Wheel(IntEnum):
    VERTICAL_WHEEL = sf.mouse.VerticalWheel
    HORIZONTAL_WHEEL = sf.mouse.HorizontalWheel

cdef class Mouse:
    def __init__(self):
        raise NotImplementedError("This class is not meant to be instantiated!")

    @staticmethod
    def is_button_pressed(int button):
        return sf.mouse.isButtonPressed(<sf.mouse.Button>button)

    @staticmethod
    def get_position(Window window=None):
        cdef sf.Vector2i p

        if window is None:
            p = sf.mouse.getPosition()
        else:
            p = sf.mouse.getPosition(window.p_window[0])

        return Vector2(p.x, p.y)

    @staticmethod
    def set_position(position, Window window=None):
        cdef sf.Vector2i p
        p.x, p.y = position

        if window is None:
            sf.mouse.setPosition(p)
        else:
            sf.mouse.setPosition(p, window.p_window[0])


cdef class Touch:
    def __init__(self):
        raise NotImplementedError("This class is not meant to be instantiated!")

    @staticmethod
    def is_down(int finger):
        return sf.touch.isDown(finger)

    @staticmethod
    def get_position(int finger, Window window=None):
        cdef sf.Vector2i p

        if window is None:
            p = sf.touch.getPosition(finger)
        else:
            p = sf.touch.getPosition(finger, window.p_window[0])

        return Vector2(p.x, p.y)


class Type(IntEnum):
    ACCELEROMETER = sf.sensor.Accelerometer
    GYROSCOPE = sf.sensor.Gyroscope
    MAGNETOMETER = sf.sensor.Magnetometer
    GRAVITY = sf.sensor.Gravity
    USER_ACCELERATION = sf.sensor.UserAcceleration
    ORIENTATION = sf.sensor.Orientation
    SENSOR_COUNT = sf.sensor.Count

cdef class Sensor:
    def __init__(self):
        raise NotImplementedError("This class is not meant to be instantiated!")

    @staticmethod
    def is_available(int sensor):
        return sf.sensor.isAvailable(<sf.sensor.Type>(sensor))

    @staticmethod
    def set_enabled(int sensor, bint enabled):
        sf.sensor.setEnabled(<sf.sensor.Type>(sensor), enabled)

    @staticmethod
    def get_value(int sensor):
        cdef sf.Vector3f value
        value = sf.sensor.getValue(<sf.sensor.Type>(sensor))
        return Vector3(value.x, value.y, value.z)


cdef class Context:
    cdef sf.Context *p_this

    def __init__(self):
        self.p_this = new sf.Context()

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "Context()"

    property active:
        def __set__(self, bint active):
            self.p_this.setActive(active)
