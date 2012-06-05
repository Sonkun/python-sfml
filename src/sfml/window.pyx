#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# pySFML2 - Cython SFML Wrapper for Python
# Copyright 2012, Jonathan De Wachter <dewachter.jonathan@gmail.com>
#
# This software is released under the GPLv3 license.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

from sfml.system.position import Position
from sfml.system.size import Size
from sfml.system.rectangle import Rectangle

cdef class Style:
	NONE = dwindow.style.None
	TITLEBAR = dwindow.style.Titlebar
	RESIZE = dwindow.style.Resize
	CLOSE = dwindow.style.Close
	FULLSCREEN = dwindow.style.Fullscreen
	DEFAULT = dwindow.style.Default


cdef class Event:
	CLOSED = dwindow.event.Closed
	RESIZED = dwindow.event.Resized
	LOST_FOCUS = dwindow.event.LostFocus
	GAINED_FOCUS = dwindow.event.GainedFocus
	TEXT_ENTERED = dwindow.event.TextEntered
	KEY_PRESSED = dwindow.event.KeyPressed
	KEY_RELEASED = dwindow.event.KeyReleased
	MOUSE_WHEEL_MOVED = dwindow.event.MouseWheelMoved
	MOUSE_BUTTON_PRESSED = dwindow.event.MouseButtonPressed
	MOUSE_BUTTON_RELEASED = dwindow.event.MouseButtonReleased
	MOUSE_MOVED = dwindow.event.MouseMoved
	MOUSE_ENTERED = dwindow.event.MouseEntered
	MOUSE_LEFT = dwindow.event.MouseLeft
	JOYSTICK_BUTTON_PRESSED = dwindow.event.JoystickButtonPressed
	JOYSTICK_BUTTON_RELEASED = dwindow.event.JoystickButtonReleased
	JOYSTICK_MOVED = dwindow.event.JoystickMoved
	JOYSTICK_CONNECTED = dwindow.event.JoystickConnected
	JOYSTICK_DISCONNECTED = dwindow.event.JoystickDisconnected
	COUNT = dwindow.event.Count

	cdef dwindow.Event *p_this

	def __init__(self):
		self.p_this = new dwindow.Event()

	def __dealloc__(self):
		del self.p_this

	def __repr__(self):
		return ("sf.Event({0})".format(self))

	def __str__(self):
		if self.type == Event.CLOSED:
			return "The window requested to be closed"
		elif self.type == Event.LOST_FOCUS:
			return "The window lost the focus"
		elif self.type == Event.GAINED_FOCUS:
			return "The window gained the focus"
		elif self.type == Event.MOUSE_ENTERED:
			return "The mouse cursor entered the area of the window"
		elif self.type == Event.MOUSE_LEFT:
			return "The mouse cursor left the area of the window"

	property type:
		def __get__(self):
			return self.p_this.type
			
		def __set__(self, dwindow.event.EventType type):
			self.p_this.type = type


cdef class SizeEvent(Event):
	def __str__(self):
		return "The window was resized"
		
	property width:
		def __get__(self):
			return self.p_this.size.width
			
		def __set__(self, unsigned int width):
			self.p_this.size.width = width
		
	property height:
		def __get__(self):
			return self.p_this.size.height
			
		def __set__(self, unsigned int height):
			self.p_this.size.height = height
		
	property size:
		def __get__(self):
			return Size(self.width, self.height)
			
		def __set__(self, size):
			self.width, self.height = size


cdef class KeyEvent(Event):
	def __str__(self):
		if self.type == Event.KEY_PRESSED:
			return "A key was pressed"
		elif self.type == Event.KEY_RELEASED:
			return "A key was released"
		
	property code:
		def __get__(self):
			return self.p_this.key.code
			
		def __set__(self, dwindow.keyboard.Key code):
			self.p_this.key.code = code
		
	property alt:
		def __get__(self):
			return self.p_this.key.alt
			
		def __set__(self, bint alt):
			self.p_this.key.alt = alt
			
	property control:
		def __get__(self):
			return self.p_this.key.control
			
		def __set__(self, bint control):
			self.p_this.key.control = control
			
	property shift:
		def __get__(self):
			return self.p_this.key.shift
			
		def __set__(self, bint shift):
			self.p_this.key.shift = shift
			
	property system:
		def __get__(self):
			return self.p_this.key.system
			
		def __set__(self, bint system):
			self.p_this.key.system = system


cdef class TextEvent(Event):
	def __str__(self):
		return "A character was entered"
		
	property unicode:
		def __get__(self):
			return self.p_this.text.unicode
			
		def __set__(self, Uint32 unicode):
			self.p_this.text.unicode = unicode


cdef class MouseMoveEvent(Event):
	def __str__(self):
		return "The mouse cursor moved"
		
	property x:
		def __get__(self):
			return self.p_this.mouseMove.x
			
		def __set__(self, int x):
			self.p_this.mouseMove.x = x
		
	property y:
		def __get__(self):
			return self.p_this.mouseMove.y
			
		def __set__(self, int y):
			self.p_this.mouseMove.y = y
		
	property position:
		def __get__(self):
			return Position(self.x, self.y)
			
		def __set__(self, position):
			self.x, self.y = position


cdef class MouseButtonEvent(Event):
	def __str__(self):
		if self.type == Event.MOUSE_BUTTON_PRESSED:
			return "A mouse button was pressed"
		elif self.type == Event.MOUSE_BUTTON_RELEASED:
			return "A mouse button was released"

	property button:
		def __get__(self):
			return self.p_this.mouseButton.button

		def __set__(self, dwindow.mouse.Button button):
			self.p_this.mouseButton.button = button

	property x:
		def __get__(self):
			return self.p_this.mouseButton.x

		def __set__(self, int x):
			self.p_this.mouseButton.x = x

	property y:
		def __get__(self):
			return self.p_this.mouseButton.y

		def __set__(self, int y):
			self.p_this.mouseButton.y = y

	property position:
		def __get__(self):
			return Position(self.x, self.y)

		def __set__(self, position):
			self.x, self.y = position


cdef class MouseWheelEvent(Event):
	def __str__(self):
		return "The mouse wheel was scrolled"

	property delta:
		def __get__(self):
			return self.p_this.mouseWheel.delta
			
		def __set__(self, int delta):
			self.p_this.mouseWheel.delta = delta

	property x:
		def __get__(self):
			return self.p_this.mouseWheel.x
			
		def __set__(self, int x):
			self.p_this.mouseWheel.x = x

	property y:
		def __get__(self):
			return self.p_this.mouseWheel.y

		def __set__(self, int y):
			self.p_this.mouseWheel.y = y

	property position:
		def __get__(self):
			return Position(self.x, self.y)
			
		def __set__(self, position):
			self.x, self.y = position


cdef class JoystickMoveEvent(Event):
	def __str__(self):
		return "The joystick moved along an axis"
		
	property joystick_id:
		def __get__(self):
			return self.p_this.joystickMove.joystickId
			
		def __set__(self, unsigned int joystick_id):
			self.p_this.joystickMove.joystickId = joystick_id
		
	property axis:
		def __get__(self):
			return self.p_this.joystickMove.axis
			
		def __set__(self, dwindow.joystick.Axis axis):
			self.p_this.joystickMove.axis = axis
		
	property position:
		def __get__(self):
			return self.p_this.joystickMove.position
			
		def __set__(self, float position):
			self.p_this.joystickMove.position = position

	property x:
		def __get__(self): pass
		def __set__(self, x): pass
		
	property y:
		def __get__(self): pass
		def __set__(self, y): pass
		
cdef class JoystickButtonEvent(Event):
	def __str__(self):
		if self.type == Event.JOYSTICK_BUTTON_PRESSED:
			return "A joystick button was pressed"
		elif self.type == Event.JOYSTICK_BUTTON_RELEASED:
			return "A joystick button was released"
		
	property joystick_id:
		def __get__(self):
			return self.p_this.joystickButton.joystickId
			
		def __set__(self, unsigned int joystick_id):
			self.p_this.joystickButton.joystickId = joystick_id
			
	property button:
		def __get__(self):
			return self.p_this.joystickButton.button
			
		def __set__(self, unsigned int button):
			self.p_this.joystickButton.button = button
			

cdef class JoystickConnectEvent(Event):
	def __str__(self):
		if self.type == Event.JOYSTICK_CONNECTED:
			return "A joystick was connected"
		elif self.type == Event.JOYSTICK_DISCONNECTED:
			return "A joystick was disconnected"
		
	property joystick_id:
		def __get__(self):
			return self.p_this.joystickConnect.joystickId
			
		def __set__(self, unsigned int joystick_id):
			self.p_this.joystickConnect.joystickId = joystick_id


cdef class VideoMode:
	cdef dwindow.VideoMode *p_this
	cdef bint delete_this

	def __init__(self, unsigned int width, unsigned int height, unsigned int bpp=32):
		self.p_this = new dwindow.VideoMode(width, height, bpp)
		self.delete_this = True
		
	def __dealloc__(self):
		if self.delete_this: del self.p_this

	def __repr__(self):
		return ("VideoMode({0})".format(self))

	def __str__(self):
		return "{0}x{1}x{2}".format(self.width, self.height, self.bpp)

	def __richcmp__(VideoMode x, VideoMode y, int op):
		if op == 0:   return x.p_this[0] <  y.p_this[0]
		elif op == 2: return x.p_this[0] == y.p_this[0]
		elif op == 4: return x.p_this[0] >  y.p_this[0]
		elif op == 1: return x.p_this[0] <= y.p_this[0]
		elif op == 3: return x.p_this[0] != y.p_this[0]
		elif op == 5: return x.p_this[0] >= y.p_this[0]

	def __iter__(self):
		return iter((self.size, self.bpp))
		
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

	property size:
		def __get__(self):
			return Size(self.p_this.width, self.p_this.height)
			
		def __set__(self, value):
			width, height = value
			self.p_this.width = width
			self.p_this.height = height

	property bpp:
		def __get__(self):
			return self.p_this.bitsPerPixel

		def __set__(self, unsigned int bpp):
			self.p_this.bitsPerPixel = bpp

	@classmethod
	def get_desktop_mode(cls):
		cdef dwindow.VideoMode *p = new dwindow.VideoMode()
		p[0] = dwindow.videomode.getDesktopMode()
		
		return wrap_videomode(p, True)
		
	@classmethod
	def get_fullscreen_modes(cls):
		cdef list modes = []
		cdef vector[dwindow.VideoMode] *v = new vector[dwindow.VideoMode]()
		v[0] = dwindow.videomode.getFullscreenModes()
		
		cdef vector[dwindow.VideoMode].iterator it = v.begin()
		cdef dwindow.VideoMode vm
		
		while it != v.end():
			vm = deref(it)
			modes.append(VideoMode(vm.width, vm.height, vm.bitsPerPixel))
			inc(it)

		return modes
		
	def is_valid(self):
		return self.p_this.isValid()


cdef class ContextSettings:
	cdef dwindow.ContextSettings *p_this

	def __init__(self, unsigned int depth=0, unsigned int stencil=0, unsigned int antialiasing=0, unsigned int major=2, unsigned int minor=0):
		self.p_this = new dwindow.ContextSettings(depth, stencil, antialiasing, major, minor)

	def __dealloc__(self):
		del self.p_this

	def __repr__(self):
		return ("ContextSettings({0})".format(self))

	def __str__(self):
		return "{0}db, {1}sb, {2}al, version {3}.{4}".format(self.depth_bits, self.stencil_bits, self.antialiasing_level, self.major_version, self.minor_version)

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


cdef class Window:
	cdef dwindow.Window *p_window
	cdef bint            m_visible
	cdef bint            m_vertical_synchronization
	
	def __cinit__(self, *args, **kwargs):
		self.m_visible = True
		self.m_vertical_synchronization = False
		
	def __init__(self, VideoMode mode, title, Uint32 style=dwindow.style.Default, ContextSettings settings=None):
		cdef char* encoded_title
		
		if self.__class__ is not RenderWindow:
			encoded_title_temporary = title.encode(u"ISO-8859-1")
			encoded_title = encoded_title_temporary
			
			if self.__class__ is Window:
				if not settings: self.p_window = new dwindow.Window(mode.p_this[0], encoded_title, style)
				else: self.p_window = new dwindow.Window(mode.p_this[0], encoded_title, style, settings.p_this[0])		
				
			else:
				if not settings: self.p_window = <dwindow.Window*>new dwindow.DerivableWindow(mode.p_this[0], encoded_title, style)
				else: self.p_window = <dwindow.Window*>new dwindow.DerivableWindow(mode.p_this[0], encoded_title, style, settings.p_this[0])
				(<dwindow.DerivableWindow*>self.p_window).set_pyobj(<void*>self)		

	def __dealloc__(self):
		if self.__class__ is not RenderWindow: del self.p_window
			
	def __iter__(self):
		return self

	def __next__(self):
		cdef dwindow.Event *p = new dwindow.Event()

		if self.p_window.pollEvent(p[0]):
			return wrap_event(p)

		raise StopIteration

	def close(self):
		self.p_window.close()

	property opened:
		def __get__(self):
			return self.p_window.isOpen()

	property settings:
		def __get__(self):
			cdef dwindow.ContextSettings *p = new dwindow.ContextSettings()
			p[0] = self.p_window.getSettings()
			return wrap_contextsettings(p)

		def __set__(self, settings):
			raise NotImplemented

	property events:
		def __get__(self):
			return self

	def poll_event(self):
		cdef dwindow.Event *p = new dwindow.Event()

		if self.p_window.pollEvent(p[0]):
			return wrap_event(p)
			
	def wait_event(self):
		cdef dwindow.Event *p = new dwindow.Event()
		
		if self.p_window.waitEvent(p[0]):
			return wrap_event(p)

	property position:
		def __get__(self):
			return Position(self.p_window.getPosition().x, self.p_window.getPosition().y)

		def __set__(self, position):
			self.p_window.setPosition(position_to_vector2i(position))

	property size:
		def __get__(self):
			return Size(self.p_window.getSize().x, self.p_window.getSize().y)

		def __set__(self, size):
			self.p_window.setSize(size_to_vector2u(size))

	property title:
		def __set__(self, title):
			encoded_title = title.encode(u"ISO-8859-1")
			self.p_window.setTitle(encoded_title)

	property icon:
		def __set__(self, Pixels icon):
			self.p_window.setIcon(icon.m_width, icon.m_height, icon.p_array)

	property visible:
		def __get__(self):
			return self.m_visible
			
		def __set__(self, bint visible):
			self.p_window.setVisible(visible)
			self.m_visible = visible
			
	def show(self):
		self.visible = True
			
	def hide(self):
		self.visible = False

	property vertical_synchronization:
		def __get__(self):
			return self.m_vertical_synchronization
			
		def __set__(self, bint vertical_synchronization):
			self.p_window.setVerticalSyncEnabled(vertical_synchronization)
			self.m_vertical_synchronization = vertical_synchronization

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

	def display(self):
		self.p_window.display()

	property system_handle:
		def __get__(self):
			return <unsigned long>self.p_window.getSystemHandle()

	def on_create(self): pass
	def on_resize(self): pass


cdef class Keyboard:
	A = dwindow.keyboard.A
	B = dwindow.keyboard.B
	C = dwindow.keyboard.C
	D = dwindow.keyboard.D
	E = dwindow.keyboard.E
	F = dwindow.keyboard.F
	G = dwindow.keyboard.G
	H = dwindow.keyboard.H
	I = dwindow.keyboard.I
	J = dwindow.keyboard.J
	K = dwindow.keyboard.K
	L = dwindow.keyboard.L
	M = dwindow.keyboard.M
	N = dwindow.keyboard.N
	O = dwindow.keyboard.O
	P = dwindow.keyboard.P
	Q = dwindow.keyboard.Q
	R = dwindow.keyboard.R
	S = dwindow.keyboard.S
	T = dwindow.keyboard.T
	U = dwindow.keyboard.U
	V = dwindow.keyboard.V
	W = dwindow.keyboard.W
	X = dwindow.keyboard.X
	Y = dwindow.keyboard.Y
	Z = dwindow.keyboard.Z
	NUM0 = dwindow.keyboard.Num0
	NUM1 = dwindow.keyboard.Num1
	NUM2 = dwindow.keyboard.Num2
	NUM3 = dwindow.keyboard.Num3
	NUM4 = dwindow.keyboard.Num4
	NUM5 = dwindow.keyboard.Num5
	NUM6 = dwindow.keyboard.Num6
	NUM7 = dwindow.keyboard.Num7
	NUM8 = dwindow.keyboard.Num8
	NUM9 = dwindow.keyboard.Num9
	ESCAPE = dwindow.keyboard.Escape
	L_CONTROL = dwindow.keyboard.LControl
	L_SHIFT = dwindow.keyboard.LShift
	L_ALT = dwindow.keyboard.LAlt
	L_SYSTEM = dwindow.keyboard.LSystem
	R_CONTROL = dwindow.keyboard.RControl
	R_SHIFT = dwindow.keyboard.RShift
	R_ALT = dwindow.keyboard.RAlt
	R_SYSTEM = dwindow.keyboard.RSystem
	MENU = dwindow.keyboard.Menu
	L_BRACKET = dwindow.keyboard.LBracket
	R_BRACKET = dwindow.keyboard.RBracket
	SEMI_COLON = dwindow.keyboard.SemiColon
	COMMA = dwindow.keyboard.Comma
	PERIOD = dwindow.keyboard.Period
	QUOTE = dwindow.keyboard.Quote
	SLASH = dwindow.keyboard.Slash
	BACK_SLASH = dwindow.keyboard.BackSlash
	TILDE = dwindow.keyboard.Tilde
	EQUAL = dwindow.keyboard.Equal
	DASH = dwindow.keyboard.Dash
	SPACE = dwindow.keyboard.Space
	RETURN = dwindow.keyboard.Return
	BACK = dwindow.keyboard.Back
	TAB = dwindow.keyboard.Tab
	PAGE_UP = dwindow.keyboard.PageUp
	PAGE_DOWN = dwindow.keyboard.PageDown
	END = dwindow.keyboard.End
	HOME = dwindow.keyboard.Home
	INSERT = dwindow.keyboard.Insert
	DELETE = dwindow.keyboard.Delete
	ADD = dwindow.keyboard.Add
	SUBTRACT = dwindow.keyboard.Subtract
	MULTIPLY = dwindow.keyboard.Multiply
	DIVIDE = dwindow.keyboard.Divide
	LEFT = dwindow.keyboard.Left
	RIGHT = dwindow.keyboard.Right
	UP = dwindow.keyboard.Up
	DOWN = dwindow.keyboard.Down
	NUMPAD0 = dwindow.keyboard.Numpad0
	NUMPAD1 = dwindow.keyboard.Numpad1
	NUMPAD2 = dwindow.keyboard.Numpad2
	NUMPAD3 = dwindow.keyboard.Numpad3
	NUMPAD4 = dwindow.keyboard.Numpad4
	NUMPAD5 = dwindow.keyboard.Numpad5
	NUMPAD6 = dwindow.keyboard.Numpad6
	NUMPAD7 = dwindow.keyboard.Numpad7
	NUMPAD8 = dwindow.keyboard.Numpad8
	NUMPAD9 = dwindow.keyboard.Numpad9
	F1 = dwindow.keyboard.F1
	F2 = dwindow.keyboard.F2
	F3 = dwindow.keyboard.F3
	F4 = dwindow.keyboard.F4
	F5 = dwindow.keyboard.F5
	F6 = dwindow.keyboard.F6
	F7 = dwindow.keyboard.F7
	F8 = dwindow.keyboard.F8
	F9 = dwindow.keyboard.F9
	F10 = dwindow.keyboard.F10
	F11 = dwindow.keyboard.F11
	F12 = dwindow.keyboard.F12
	F13 = dwindow.keyboard.F13
	F14 = dwindow.keyboard.F14
	F15 = dwindow.keyboard.F15
	PAUSE = dwindow.keyboard.Pause
	KEY_COUNT = dwindow.keyboard.KeyCount

	def __init__(self):
		raise NotImplementedError("This class is not meant to be instantiated!")
		
	@classmethod
	def is_key_pressed(cls, int key):
		return dwindow.keyboard.isKeyPressed(<dwindow.keyboard.Key>key)


cdef class Joystick:
	COUNT = dwindow.joystick.Count
	BUTTON_COUNT = dwindow.joystick.ButtonCount
	AXIS_COUNT = dwindow.joystick.AxisCount

	X = dwindow.joystick.X
	Y = dwindow.joystick.Y
	Z = dwindow.joystick.Z
	R = dwindow.joystick.R
	U = dwindow.joystick.U
	V = dwindow.joystick.V
	POV_X = dwindow.joystick.PovX
	POV_Y = dwindow.joystick.PovY

	def __init__(self):
		raise NotImplementedError("This class is not meant to be instantiated!")
		
	@classmethod
	def is_connected(cls, unsigned int joystick):
		return dwindow.joystick.isConnected(joystick)

	@classmethod
	def get_button_count(cls, unsigned int joystick):
		return dwindow.joystick.getButtonCount(joystick)

	@classmethod
	def has_axis(cls, unsigned int joystick, int axis):
		return dwindow.joystick.hasAxis(joystick, <dwindow.joystick.Axis>axis)

	@classmethod
	def is_button_pressed(cls, unsigned int joystick, unsigned int button):
		return dwindow.joystick.isButtonPressed(joystick, button)

	@classmethod
	def get_axis_position(cls, unsigned int joystick, int axis):
		return dwindow.joystick.getAxisPosition(joystick, <dwindow.joystick.Axis> axis)

	@classmethod
	def update(cls):
		dwindow.joystick.update()


cdef class Mouse:
	LEFT = dwindow.mouse.Left
	RIGHT = dwindow.mouse.Right
	MIDDLE = dwindow.mouse.Middle
	X_BUTTON1 = dwindow.mouse.XButton1
	X_BUTTON2 = dwindow.mouse.XButton2
	BUTTON_COUNT = dwindow.mouse.ButtonCount
	
	def __init__(self):
		raise NotImplementedError("This class is not meant to be instantiated!")
		
	@classmethod
	def is_button_pressed(cls, int button):
		return dwindow.mouse.isButtonPressed(<dwindow.mouse.Button>button)

	@classmethod
	def get_position(cls, Window window=None):
		cdef dsystem.Vector2i p

		if window is None: p = dwindow.mouse.getPosition()
		else: p = dwindow.mouse.getPosition(window.p_window[0])

		return Position(p.x, p.y)

	@classmethod
	def set_position(cls, position, Window window=None):
		cdef dsystem.Vector2i p
		p.x, p.y = position

		if window is None: dwindow.mouse.setPosition(p)
		else: dwindow.mouse.setPosition(p, window.p_window[0])


cdef class Context:
	cdef dwindow.Context *p_this
	
	def __init__(self):
		self.p_this = new dwindow.Context()

	def __dealloc__(self):
		del self.p_this
		
	property active:			
		def __set__(self, bint active):
			self.p_this.setActive(active)
		
	
cdef Event wrap_event(dwindow.Event *p):
	cdef Event event = None
	
	if p.type == dwindow.event.Closed:
		pass
	elif p.type == dwindow.event.Resized:
		event = SizeEvent.__new__(SizeEvent)
	elif p.type == dwindow.event.LostFocus:
		pass
	elif p.type == dwindow.event.GainedFocus:
		pass
	elif p.type == dwindow.event.TextEntered:
		event = TextEvent.__new__(TextEvent)
	elif p.type == dwindow.event.KeyPressed or p.type == dwindow.event.KeyReleased:
		event = KeyEvent.__new__(KeyEvent)
	elif p.type == dwindow.event.MouseWheelMoved:
		event = MouseWheelEvent.__new__(MouseWheelEvent)
	elif p.type == dwindow.event.MouseButtonPressed or p.type == dwindow.event.MouseButtonReleased:
		event = MouseButtonEvent.__new__(MouseButtonEvent)
	elif p.type == dwindow.event.MouseMoved:
		event = MouseMoveEvent.__new__(MouseMoveEvent)
	elif p.type == dwindow.event.MouseEntered:
		pass
	elif p.type == dwindow.event.MouseLeft:
		pass
	elif p.type == dwindow.event.JoystickButtonPressed or p.type == dwindow.event.JoystickButtonReleased:
		event = JoystickButtonEvent.__new__(JoystickButtonEvent)
	elif p.type == dwindow.event.JoystickMoved:
		event = JoystickMoveEvent.__new__(JoystickMoveEvent)
	elif p.type == dwindow.event.JoystickConnected or p.type == dwindow.event.JoystickDisconnected:
		event = JoystickConnectEvent.__new__(JoystickConnectEvent)

	if not event: event = Event.__new__(Event)
	
	event.p_this = p
	return event

cdef VideoMode wrap_videomode(dwindow.VideoMode *p, bint d):
	cdef VideoMode r = VideoMode.__new__(VideoMode, 640, 480, 32)
	r.p_this = p
	r.delete_this = d
	return r

cdef ContextSettings wrap_contextsettings(dwindow.ContextSettings *v):
	cdef ContextSettings r = ContextSettings.__new__(ContextSettings)
	r.p_this = v
	return r