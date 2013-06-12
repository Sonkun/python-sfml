Window
======
.. module:: sfml.window
.. contents:: :local:
   :depth: 1


Style
^^^^^

.. class:: Style

   This class defines the following constants:

   +------------+--------------------------------------------------------------------------+
   | Style      | Description                                                              |
   +============+==========================================================================+
   | NONE       | No border / title bar (this flag and all others are mutually exclusive). |
   +------------+--------------------------------------------------------------------------+
   | TITLEBAR   | Title bar + fixed border.                                                |
   +------------+--------------------------------------------------------------------------+
   | RESIZE     | Titlebar + close button.                                                 |
   +------------+--------------------------------------------------------------------------+
   | CLOSE      | Request a page's header only.                                            |
   +------------+--------------------------------------------------------------------------+
   | FULLSCREEN | Fullscreen mode (this flag and all others are mutually exclusive)        |
   +------------+--------------------------------------------------------------------------+
   | DEFAULT    | Default window style.                                                    |
   +------------+--------------------------------------------------------------------------+

Event
^^^^^

.. contents:: :local:

.. class:: Event

   Defines a system event and its parameters.

   :class:`Event` holds all the information about a system
   event that just happened.

   Events are retrieved using the :meth:`Window.poll_event` and
   :meth:`Window.wait_event` functions. You can also retreive
   a generator that iterates over the pending events the property
   :attr:`Window.events`.

   An :class:`Event` instance contains the data of the event.

   Usage example::

      for event in window.events:
         # request for closing the window
         if type(event) is sf.CloseEvent:
            window.close()

         # the escape key was pressed
         if type(event) is sf.KeyEvent and event.code is sf.Keyboard.ESCAPE:
            window.close()

         # the window was resized
         if type(event) is sf.ResizeEvent:
            do_something_with_the_new_size(event.size)

         # ...

CloseEvent
----------
.. class:: CloseEvent(Event)

   The window requested to be closed.

ResizeEvent
-----------
.. class:: ResizeEvent(Event)

   The window was resized.

   .. attribute:: size

      Tell you the new window size.

      :rtype: :class:`sfml.system.Vector2`

FocusEvent
----------
.. class:: FocusEvent(Event)

   The window gained or lost the focus, :attr:`gained` and :attr:`lost`
   return boolean.

   .. attribute:: gained
   .. attribute:: lost

MouseEvent
----------
.. class:: MouseEvent

   The mouse cursor entered or left the area of the window,
   :attr:`entered` and :attr:`left` return boolean.

   .. attribute:: entered
   .. attribute:: left

TextEvent
---------
.. class:: TextEvent(Event)

   A character was entered. :attr:`unicode` return the ASCII code (integer).

   .. attribute:: unicode

KeyEvent
--------
.. class:: KeyEvent(Event)

   A key was pressed or released. :attr:`pressed` and :attr:`released`
   return boolean.

   .. attribute:: pressed

      Tell whether the key has been pressed.

   .. attribute:: released

      Tell whether the key has been released.

   .. attribute:: code

      Tell you the code of the key that has been pressed.
      You'll find the list in :class:`Keyboard`.

   .. attribute:: alt

      Tell you if the **Alt** key was pressed.

   .. attribute:: control

      Tell you if the **Control** key was pressed.

   .. attribute:: shift

      Tell you if the **Shift** key was pressed.

   .. attribute:: system

      Tell you if the **System** key was pressed.

MouseWheelEvent
---------------
.. class:: MouseWheelEvent

   The mouse wheel was scrolled.

   .. attribute:: delta

      Number of ticks the wheel has moved (positive is up, negative is down)

      :rtype: integer

   .. attribute:: position

      Position of the mouse pointer, relative to the left of the owner window.

      :rtype: :class:`sfml.system.Vector2`

MouseButtonEvent
----------------
.. class:: MouseButtonEvent

   A mouse button was pressed or released.

   .. attribute:: pressed

      Tell whether the button has been pressed.

   .. attribute:: released

      Tell whether the button has been released.

   .. attribute:: button

      Code of the button that has been presssed of released. You'll
      find the list in :class:`Mouse`.

   .. attribute:: position

      Position of the mouse pointer, relative to the left of the owner window.

      :rtype: :class:`sfml.system.Vector2`

MouseMoveEvent
--------------
.. class:: MouseMoveEvent

   The mouse cursor moved. To know the offset, you must take care of
   saving the previous value and compare with the next one.

   .. attribute:: position

      Position of the mouse pointer, relative to the left of the owner window.

      :rtype: :class:`sfml.system.Vector2`

JoystickMoveEvent
-----------------
.. class:: JoystickMoveEvent

   The joystick moved along an axis.

	.. attribute:: joystick_id
	.. attribute:: axis
	.. attribute:: position

JoystickButtonEvent
-------------------
.. class:: JoystickButtonEvent

   A joystick button was pressed or released.

	.. attribute:: pressed
	.. attribute:: released
	.. attribute:: joystick_id
	.. attribute:: button

JoystickConnectEvent
--------------------
.. class:: JoystickConnectEvent

   A joystick was connected or disconnected.

	.. attribute:: connected
	.. attribute:: disconnected
	.. attribute:: joystick_id


VideoMode
^^^^^^^^^
.. class:: VideoMode

	:class:`VideoMode` defines a video mode (width, height, bpp)

	A video mode is defined by a width and a height (in pixels) and a depth
	(in bits per pixel).

	Video modes are used to setup windows (sfml.graphics.Window) at creation time.

	The main usage of video modes is for fullscreen mode: indeed you must
	use one of the valid video modes allowed by the OS (which are defined
	by what the monitor and the graphics card support), otherwise your
	window creation will just fail.

	:class:`VideoMode` provides a class method for retrieving the list
	of all the video modes supported by the system:
	:func:`get_fullscreen_modes()`.

	A custom video mode can also be checked directly for fullscreen
	compatibility with its :func:`is_valid()` function.

	Additionnally, :class:`VideoMode` provides a class method to get the
	mode currently used by the desktop: :func:`get_desktop_mode()`. This
	allows to build windows with the same size or pixel depth as the
	current resolution.

	Usage example::

		# display the list of all the video modes available for fullscreen
		i = 0
		modes = sf.VideoMode.get_fullscreen_modes()
		for mode in modes:
			print("Mode #{0}: {1}".format(i, mode))
			i += 1

		# create a window with the same pixel depth as the desktop
		desktop = sf.VideoMode.get_desktop_mode()
		width, bpp = desktop
		window = sf.Window(sf.VideoMode(1024, 768, bpp), "pySFML Window")


   .. py:method:: VideoMode(width, height[, bits_per_pixel=32])

      Construct the video mode with its attributes.

      :param integer width: Width in pixels
      :param integer height: Height in pixels
      :param integer bits_per_pixel: Pixel depths in bits per pixel

   .. py:attribute:: size

		Video mode size, in pixels.

		:type: :class:`sfml.system.Vector2`

   .. py:attribute:: width

		Video mode width, in pixels.

		:type: integer

   .. py:attribute:: height

		Video mode height, in pixels.

		:type: integer

   .. py:attribute:: bpp

		Video mode pixel depth, in bits per pixels.

		:type: integer

   .. py:classmethod:: get_desktop_mode()

		Get the current desktop video mode.

		:type: :class:`sfml.window.VideoMode`

   .. py:classmethod:: get_fullscreen_modes()

		Retrieve all the video modes supported in fullscreen mode.

		When creating a fullscreen window, the video mode is restricted
		to be compatible with what the graphics driver and monitor
		support. This function returns the complete list of all video
		modes that can be used in fullscreen mode. The returned array
		is sorted from best to worst, so that the first element will
		always give the best mode (higher width, height and
		bits-per-pixel).

		:rtype: list of :class:`sfml.window.VideoMode`

   .. py:method:: is_valid()

      Tell whether or not the video mode is valid.

      The validity of video modes is only relevant when using
      fullscreen windows; otherwise any video mode can be used with no
      restriction.

      :rtype: bool


ContextSettings
^^^^^^^^^^^^^^^

.. class:: ContextSettings(int depth=0, int stencil=0, int antialiasing=0, int major=2, int minor=0)

   Structure defining the settings of the OpenGL context attached to a window.

   ContextSettings allows to define several advanced settings of the OpenGL context attached to a window.

   All these settings have no impact on the regular SFML rendering (graphics module) -- except the anti-aliasing level, so you may need to use this structure only if you're using SFML as a windowing system for custom OpenGL rendering.

   The depth_bits and stencil_bits properties define the number of bits per pixel requested for the (respectively) depth and stencil buffers.

   antialiasing_level represents the requested number of multisampling levels for anti-aliasing.

   major_version and minor_version define the version of the OpenGL context that you want. Only versions greater or equal to 3.0 are relevant; versions lesser than 3.0 are all handled the same way (i.e. you can use any version < 3.0 if you don't want an OpenGL 3 context).

   Please note that these values are only a hint. No failure will be reported if one or more of these values are not supported by the system; instead, SFML will try to find the closest valid match. You can then retrieve the settings that the window actually used to create its context, with sfml.graphics.Window.settings.


   .. attribute:: depth_bits

      Bits of the depth buffer.

   .. attribute:: stencil_bits

      Bits of the stencil buffer.

   .. attribute:: antialiasing_level

      Level of antialiasing.

   .. attribute:: major_version

      Major number of the context version to create.

   .. attribute:: minor_version

      Minor number of the context version to create.


Pixels
^^^^^^

.. py:class:: Pixels

	Utility class to manipulate pixels, more precisely, an array of
	unsigned char that represents an image.

	This could have been handled with the built-in type "bytes" for
	python3 or a simple string coded on 8-bits for python2 but as an
	image has two dimensions, it has to tell its width (and its height)
	too.

	Usage examples::

		image = sf.Image.from_file("icon.png")
		window = sf.Window(sf.VideoMode(640, 480), "pySFML")

		window.icon = image.pixels

		x, y, w, h = 86, 217, image.size
		pixels = image.pixels

		assert pixels[w*y+x+0] == image[x, y].r
		assert pixels[w*y+x+1] == image[x, y].g
		assert pixels[w*y+x+2] == image[x, y].b
		assert pixels[w*y+x+3] == image[x, y].a

	.. py:attribute:: width

		Get its width.

	.. py:attribute:: height

		Get its height.

	.. py:attribute:: data

		Return a copy of the data inside.

		:rtype: bytes or string


Window
^^^^^^

.. class:: Window

	Window that serves as a target for OpenGL rendering.

	:class:`Window` is the main class of the Window module.

	It defines an OS window that is able to receive an OpenGL rendering.

	A :class:`Window` can create its own new window, or be embedded into
	an already existing control using the create(handle) function. This can
	be useful for embedding an OpenGL rendering area into a view which is
	part of a bigger GUI with existing windows, controls, etc. It can also
	serve as embedding an OpenGL rendering area into a window created by
	another (probably richer) GUI library like Qt or wxWidgets.

	The :class:`Window` class provides a simple interface for
	manipulating the window: :meth:`move`, :meth:`resize`, :func:`show`/:func:`hide`, control mouse cursor,
	etc. It also provides event handling through its :func:`poll_event` and
	:func:`wait_event` functions.

	Note that OpenGL experts can pass their own parameters (antialiasing
	level, bits for the depth and stencil buffers, etc.) to the OpenGL
	context attached to the window, with the :class:`ContextSettings`
	structure which is passed as an optional argument when creating the
	window.

	Usage example::

		# declare and create a new window
		window = sf.Window(sf.VideoMode(800, 600), "pySFML Window")

		# limit the framerate to 60 frames per second (this step is optional)
		window.framerate_limit = 60

		# the main loop - ends as soon as the window is closed
		while window.is_open:
			# event processing
			for event in window.events:
				# request for closing the window
				if type(event) is sf.CloseEvent:
					window.close()

				# activate the window for OpenGL rendering
				window.active = True

				# openGL drawing commands go here...

				# end the current frame and display its contents on screen
				window.display()

   .. method:: Window(mode, title[, style[, settings]])

      Construct a new window.

      This creates the window with the size and pixel depth defined in
      mode. An optional style can be passed to customize the look and
      behaviour of the window (borders, title bar, resizable, closable,
      ...). If style contains :const:`sfml.window.Style.FULLSCREEN`, then mode
      must be a valid video mode.

      The fourth parameter is an optional structure specifying advanced
      OpenGL context settings such as antialiasing, depth-buffer bits,
      etc.

      :param sfml.window.VideoMode mode: Video mode to use (defines the width, height and depth of the rendering area of the window)
      :param string title: Title of the window
      :param sfml.window.Style style: Window style
      :param sfml.window.ContextSettings settings: Additional settings for the underlying OpenGL context

   .. method:: recreate(mode, title[, style[, settings]])

      Recreate the window.

      :param sfml.window.VideoMode mode: Video mode to use (defines the width, height and depth of the rendering area of the window)
      :param string title: Title of the window
      :param sfml.window.Style style: Window style
      :param sfml.window.ContextSettings settings: Additional settings for the underlying OpenGL context

   .. method:: close()

      Close the window and destroy all the attached resources.

      After calling this function, the :class:`Window` instance
      remains valid and you can call :func:`recreate` to recreate the
      window. All other functions such as :func:`poll_event` or
      :func:`display` will still work (i.e. you don't have to test
      :attr:`is_open` every time), and will have no effect on closed
      windows.

   .. attribute:: is_open

      Tell whether or not the window is open.

      This attribute returns whether or not the window exists. Note
      that a hidden window (:func:`hide`) is open (therefore this
      property would return **True**).

      :type: bool

   .. attribute:: opened

      .. deprecated :: 1.2

      See and use :meth:`is_open` instead. This method is kept for
      backward compatibilities.

   .. attribute:: settings

      Get the settings of the OpenGL context of the window.

      Note that these settings may be different from what was passed to
      the constructor or the :func:`recreate` function, if one or more
      settings were not supported. In this case, SFML chose the closest
      match.

      :type: :class:`sfml.window.ContextSettings`

   .. attribute:: events

      Return a generator that iterates over new events.

      :type: generator

   .. method:: poll_event()

      Pop the event on top of events stack, if any, and return it.

      This function is not blocking: if there's no pending event then
      it will return false and leave event unmodified. Note that more
      than one event may be present in the events stack, thus you
      should always call this function in a loop to make sure that you
      process every pending event.

      :return: Returns an event if any otherwhise None
      :rtype: :class:`sfml.window.Event` or None

   .. method:: wait_event()

      Wait for an event and return it.

      This function is blocking: if there's no pending event then it
      will wait until an event is received. After this function returns
      (and no error occured), the event object is always valid. This
      function is typically used when you have a thread that is
      dedicated to events handling: you want to make this thread sleep
      as long as no new event is received.

      :return: Returns an event or None if an error occured.
      :rtype: :class:`sfml.window.Event`

   .. attribute:: position

      Return or change the position of the window on screen.

      This function only works for top-level windows (i.e. it will be
      ignored for windows created from the handle of a
      child window/control).

      :type: :class:`sfml.system.Vector2`

   .. attribute:: size

      Return or change the size of the rendering region of the window.

      :type: :class:`sfml.system.Vector2`

   .. attribute:: icon

      Allow to change the window's icon.

      The OS default icon is used by default.

      :type: :class:`sfml.window.Pixels`

   .. attribute:: visible

      Set or get the window's visibility status. You shouldn't rely on the getter.

      The window is shown by default.

      :type: bool

   .. method:: show()

      Show the window.

      It has no effect if the window was already shown.

   .. method:: hide()

      Hide the window.

      It has no effect if the window was already hidden.

   .. attribute:: vertical_synchronization

      Get or set the vertical synchronization.

      Activating vertical synchronization will limit the number of
      frames displayed to the refresh rate of the monitor. This can
      avoid some visual artifacts, and limit the framerate to a good
      value (but not constant across different computers).. You
      shouldn't rely on the getter.

      Vertical synchronization is disabled by default

      :type: bool

   .. attribute:: mouse_cursor_visible

      Show or hide the mouse cursor.

      The mouse cursor is visible by default

      :type: bool

   .. attribute:: key_repeat_enabled

      Enable or disable automatic key-repeat.

      If key repeat is enabled, you will receive repeated
      :class:`KeyPressed` events while keeping a key pressed. If it is
      disabled, you will only get a single event when the key is
      pressed.

      Key repeat is enabled by default.

      :type: bool

   .. attribute:: framerate_limit

      Limit the framerate to a maximum fixed frequency.

      If a limit is set, the window will use a small delay after each
      call to :func:`display` to ensure that the current frame lasted
      long enough to match the framerate limit. pySFML will try to
      match the given limit as much as it can, but since it internally
      uses :func:`.sleep`, whose precision depends on the underlying
      OS, the results may be a little unprecise as well (for example,
      you can get 65 FPS when requesting 60).

      :type: integer

   .. attribute:: joystick_threshold

      Change the joystick threshold.

      The joystick threshold is the value below which no
      :class:`JoystickMoveEvent` will be generated.

      The threshold value is 0.1 by default.

      :type: float

   .. attribute:: active

      Activate or deactivate the window as the current target for
      OpenGL rendering.

      A window is active only on the current thread, if you want to
      make it active on another thread you have to deactivate it on the
      previous thread first if it was active. Only one window can be
      active on a thread at a time, thus the window previously active
      (if any) automatically gets deactivated.

   .. method:: display()

      Display on screen what has been rendered to the window so far.

      This function is typically called after all OpenGL rendering has
      been done for the current frame, in order to show it on screen.

   ..
      .. attribute:: system_handle

         Get the OS-specific handle of the window.

         The type of the returned handle is :class`sfml.graphics.WindowHandle`, which
         is a typedef to the handle type defined by the OS. You shouldn't
         need to use this function, unless you have very specific stuff to
         implement that SFML doesn't support, or implement a temporary
         workaround until a bug is fixed.

   .. method:: on_create

      Function called after the window has been created.

      This function is called so that derived classes can perform their
      own specific initialization as soon as the window is created.

      Usage examples::

         class MyWindow(sf.Window):
            def __init__(self):
               sf.Window.__init__(self, sf.VideoMode(640, 480), "pySFML")

            def on_create(self):
               print("Window created or recreated...")
               do_something()

      Reimplemented in :class:`sfml.graphics.RenderWindow`

   .. method:: on_resize

      Function called after the window has been resized.

      This function is called so that derived classes can perform
      custom actions when the size of the window changes.

      Usage examples::

         class MyWindow(sf.Window):
            def __init__(self):
               sf.Window.__init__(self, sf.VideoMode(640, 480), "pySFML")

            def on_resize(self):
               print("Window size changed")
               do_something()

      Reimplemented in :class:`sf.RenderWindow`


Keyboard
^^^^^^^^

.. class:: Keyboard

   Give access to the real-time state of the keyboard.

   :class:`Keyboard` provides an interface to the state of the
   keyboard.

   It only contains class methods (a single keyboard is assumed), so
   it's not meant to be instanciated.

   This class allows users to query the keyboard state at any time and
   directly, without having to deal with a window and its events.
   Compared to :class:`MouseButtonEvent`
   events, :class:`Keyboard` can retrieve the state of a key at any
   time (you don't need to store and update a boolean on your side in
   order to know if a key is pressed or released), and you always get
   the real state of the keyboard, even if keys are pressed or released
   when your window is out of focus and no event is triggered.

   Usage example::

      if sf.Keyboard.is_key_pressed(sf.Keyboard.LEFT)
         # move left...
      elif sf.Keyboard.is_key_pressed(sf.Keyboard.RIGHT):
         # move right...
      elif sf.Keyboard.is_key_pressed(sf.Keyboard.ESCAPE):
         # quit...

   +------------+-----------------------------------------------------------------------------+
   | Key        | Description                                                                 |
   +============+=============================================================================+
   | A          | The A key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | B          | The B key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | C          | The C key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | D          | The D key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | E          | The E key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | F          | The F key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | G          | The G key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | H          | The H key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | I          | The I key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | J          | The J key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | K          | The K key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | L          | The L key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | M          | The M key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | N          | The N key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | O          | The O key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | P          | The P key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | Q          | The Q key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | R          | The R key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | S          | The S key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | T          | The T key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | U          | The U key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | V          | The V key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | W          | The W key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | X          | The X key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | Y          | The Y key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | Z          | The Z key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | NUM0       | The 0 key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | NUM1       | The 1 key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | NUM2       | The 2 key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | NUM3       | The 3 key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | NUM4       | The 4 key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | NUM5       | The 5 key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | NUM6       | The 6 key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | NUM7       | The 7 key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | NUM8       | The 8 key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | NUM9       | The 9 key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | ESCAPE     | The Escape key.                                                             |
   +------------+-----------------------------------------------------------------------------+
   | L_CONTROL  | The left Control key.                                                       |
   +------------+-----------------------------------------------------------------------------+
   | L_SHIFT    | The left Shift key.                                                         |
   +------------+-----------------------------------------------------------------------------+
   | L_ALT      | The left Alt key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | L_SYSTEM   | The left OS specific key: window (Windows and Linux), apple (MacOS X), ...  |
   +------------+-----------------------------------------------------------------------------+
   | R_CONTROL  | The right Control key.                                                      |
   +------------+-----------------------------------------------------------------------------+
   | R_SHIFT    | The right Shift key.                                                        |
   +------------+-----------------------------------------------------------------------------+
   | R_ALT      | The right Alt key.                                                          |
   +------------+-----------------------------------------------------------------------------+
   | R_SYSTEM   | The right OS specific key: window (Windows and Linux), apple (MacOS X), ... |
   +------------+-----------------------------------------------------------------------------+
   | MENU       | The Menu key.                                                               |
   +------------+-----------------------------------------------------------------------------+
   | L_BRACKET  | The [ key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | R_BRACKET  | The ] key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | SEMI_COLON | The ; key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | COMMA      | The , key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | PERIOD     | The . key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | QUOTE      | The ' key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | SLASH      | The / key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | BACK_SLASH | The \ key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | TILDE      | The ~ key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | EQUAL      | The = key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | DASH       | The - key.                                                                  |
   +------------+-----------------------------------------------------------------------------+
   | SPACE      | The Space key.                                                              |
   +------------+-----------------------------------------------------------------------------+
   | RETURN     | The Return key.                                                             |
   +------------+-----------------------------------------------------------------------------+
   | BACK_SPACE | The Backspace key.                                                          |
   +------------+-----------------------------------------------------------------------------+
   | TAB        | The Tabulation key.                                                         |
   +------------+-----------------------------------------------------------------------------+
   | PAGE_UP    | The Page up key.                                                            |
   +------------+-----------------------------------------------------------------------------+
   | PAGE_DOWN  | The Page down key.                                                          |
   +------------+-----------------------------------------------------------------------------+
   | END        | The End key.                                                                |
   +------------+-----------------------------------------------------------------------------+
   | HOME       | The Home key.                                                               |
   +------------+-----------------------------------------------------------------------------+
   | INSERT     | The Insert key.                                                             |
   +------------+-----------------------------------------------------------------------------+
   | DELETE     | The Delete key.                                                             |
   +------------+-----------------------------------------------------------------------------+
   | ADD        | \+                                                                          |
   +------------+-----------------------------------------------------------------------------+
   | SUBTRACT   | \-                                                                          |
   +------------+-----------------------------------------------------------------------------+
   | MULTIPLY   | \*                                                                          |
   +------------+-----------------------------------------------------------------------------+
   | DIVIDE     | /                                                                           |
   +------------+-----------------------------------------------------------------------------+
   | LEFT       | Left arrow.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | RIGHT      | Right arrow.                                                                |
   +------------+-----------------------------------------------------------------------------+
   | UP         | Up arrow.                                                                   |
   +------------+-----------------------------------------------------------------------------+
   | DOWN       | Down arrow.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | NUMPAD0    | The numpad 0 key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | NUMPAD1    | The numpad 1 key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | NUMPAD2    | The numpad 2 key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | NUMPAD3    | The numpad 3 key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | NUMPAD4    | The numpad 4 key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | NUMPAD5    | The numpad 5 key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | NUMPAD6    | The numpad 6 key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | NUMPAD7    | The numpad 7 key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | NUMPAD8    | The numpad 8 key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | NUMPAD9    | The numpad 9 key.                                                           |
   +------------+-----------------------------------------------------------------------------+
   | F1         | The F1 key.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | F2         | The F2 key.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | F3         | The F3 key.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | F4         | The F4 key.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | F5         | The F5 key.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | F6         | The F6 key.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | F7         | The F7 key.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | F8         | The F8 key.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | F9         | The F9 key.                                                                 |
   +------------+-----------------------------------------------------------------------------+
   | F10        | The F10 key.                                                                |
   +------------+-----------------------------------------------------------------------------+
   | F11        | The F11 key.                                                                |
   +------------+-----------------------------------------------------------------------------+
   | F12        | The F12 key.                                                                |
   +------------+-----------------------------------------------------------------------------+
   | F13        | The F13 key.                                                                |
   +------------+-----------------------------------------------------------------------------+
   | F14        | The F14 key.                                                                |
   +------------+-----------------------------------------------------------------------------+
   | F15        | The F15 key.                                                                |
   +------------+-----------------------------------------------------------------------------+
   | PAUSE      | The Pause key.                                                              |
   +------------+-----------------------------------------------------------------------------+
   | KEY_COUNT  | The total number of keyboard keys                                           |
   +------------+-----------------------------------------------------------------------------+

   .. classmethod:: is_key_pressed(key)

      Check if a key is pressed.

      :param key: Key to check
      :type key: :class:`sfml.window.Keyboard`'s constant


Joystick
^^^^^^^^

.. class:: Joystick

   Give access to the real-time state of the joysticks.

   :class:`Joystick` provides an interface to the state of the
   joysticks.

   It only contains class methods, so it's not meant to be instanciated.
   Instead, each joystick is identified by an index that is passed to
   the functions of this class.

   This class allows users to query the state of joysticks at any time
   and directly, without having to deal with a window and its events.
   Compared to the :class:`JoystickButtonEvent` and
   :class:`JoystickMoveEvent` events, :class:`Joystick` can
   retrieve the state of axes and buttons of joysticks at any time (you
   don't need to store and update a boolean on your side in order to
   know if a button is pressed or released), and you always get the
   real state of joysticks, even if they are moved, pressed or released
   when your window is out of focus and no event is triggered.

   SFML supports:

       * 8 joysticks (:const:`Joystick.COUNT`)
       * 32 buttons per joystick (:const:`Joystick.BUTTON_COUNT`)
       * 8 axes per joystick (:const:`Joystick.AXIS_COUNT`)

   Unlike the keyboard or mouse, the state of joysticks is sometimes
   not directly available (depending on the OS), therefore an
   :func:`update` function must be called in order to update the
   current state of joysticks. When you have a window with event
   handling, this is done automatically, you don't need to call
   anything. But if you have no window, or if you want to check
   joysticks state before creating one, you must call
   :func:`Joystick.update` explicitely.

   Usage example::

      # is joystick #0 connected ?
      connected = sf.Joystick.is_connected(0)

      # how many button does joystick #0 support ?
      buttons = sf.Joystick.get_button_count(0)

      # does joystick # define a X axis ?
      has_X = sf.Joystick.has_axis(0, sf.Joystick.X)

      # is button #2 pressed on joystick #0 ?
      pressed = sf.Joystick.is_button_pressed(0, 2)

      # what's the current position of the Y axis on joystick #0?
      position = sf.Joystick.get_axis_position(0, sf.Joystick.Y)

   +-------+--------------------------------------+
   | Axis  | Description                          |
   +=======+======================================+
   | X     | The X axis.                          |
   +-------+--------------------------------------+
   | Y     | The X axis.                          |
   +-------+--------------------------------------+
   | Z     | The X axis.                          |
   +-------+--------------------------------------+
   | R     | The X axis.                          |
   +-------+--------------------------------------+
   | U     | The X axis.                          |
   +-------+--------------------------------------+
   | V     | The X axis.                          |
   +-------+--------------------------------------+
   | POV_X | The X axis of the point-of-view hat. |
   +-------+--------------------------------------+
   | POV_Y | The Y axis of the point-of-view hat. |
   +-------+--------------------------------------+

   .. data:: COUNT

         Maximum number of supported joysticks.
   .. data:: BUTTON_COUNT

         Maximum number of supported buttons.
   .. data:: AXIS_COUNT

         Maximum number of supported axes.

   .. classmethod:: is_connected(joystick)

      Check if a joystick is connected.

      If the joystick is not connected, this function returns false.

      :param integer joystick: Index of the joystick to check
      :rtype: boolean

   .. classmethod:: get_button_count(joystick)

      Return the number of buttons supported by a joystick.

      If the joystick is not connected, this function returns 0.

      :param integer joystick: Index of the joystick
      :rtype: integer

   .. classmethod:: has_axis(joystick, axis)

      Check if a joystick supports a given axis.

      If the joystick is not connected, this function returns false.

      :param integer joystick: Index of the joystick
      :param integer axis: Axis to check
      :rtype: boolean

   .. classmethod:: is_button_pressed(joystick, button)

      Check if a joystick button is pressed.

      If the joystick is not connected, this function returns false.

      :param integer joystick: Index of the joystick
      :param integer axis: Button to check
      :rtype: boolean

   .. classmethod:: get_axis_position(joystick, axis)

      Get the current position of a joystick axis.

      If the joystick is not connected, this function returns 0.

      :param integer joystick: Index of the joystick
      :param integer axis: Axis to check
      :rtype: boolean

   .. classmethod:: update()

      Update the states of all joysticks.

      This function is used internally by SFML, so you normally don't
      have to call it explicitely. However, you may need to call it if
      you have no window yet (or no window at all): in this case the
      joysticks states are not updated automatically.


Mouse
^^^^^

.. class:: Mouse

   Give access to the real-time state of the mouse.

   :class:`Mouse` provides an interface to the state of the mouse.

   It only contains class methods (a single mouse is assumed), so it's
   not meant to be instanciated.

   This class allows users to query the mouse state at any time and
   directly, without having to deal with a window and its events.
   Compared to the :class:`MouseMoveEvent`, :class:`MouseButtonEvent`
   events, :class:`Mouse` can retrieve
   the state of the cursor and the buttons at any time (you don't need
   to store and update a boolean on your side in order to know if a
   button is pressed or released), and you always get the real state of
   the mouse, even if it is moved, pressed or released when your window
   is out of focus and no event is triggered.

   The :func:`set_position` and :func:`get_position` functions can be
   used to change or retrieve the current position of the mouse
   pointer. There are two versions: one that operates in global
   coordinates (relative to the desktop) and one that operates in
   window coordinates (relative to a specific window).

   Usage example::

      if sf.Mouse.is_button_pressed(sf.Mouse.LEFT):
         # left click...

      # get global mouse position
      position = sf.Mouse.position
      # or: position = sf.Mouse.get_position()

      # set mouse position relative to a window
      sf.Mouse.set_position(sf.Vector2(100, 200), window)

   +--------------+------------------------------------+
   | Button       | Description                        |
   +==============+====================================+
   | LEFT         | The left mouse button.             |
   +--------------+------------------------------------+
   | RIGHT        | The right mouse button.            |
   +--------------+------------------------------------+
   | MIDDLE       | The middle (wheel) mouse button.   |
   +--------------+------------------------------------+
   | X_BUTTON1    | The first extra mouse button.      |
   +--------------+------------------------------------+
   | X_BUTTON2    | The second extra mouse button.     |
   +--------------+------------------------------------+
   | BUTTON_COUNT | The total number of mouse buttons. |
   +--------------+------------------------------------+

   .. classmethod:: is_button_pressed(button)

      Check if a mouse button is pressed.

      :param integer button: Button to check
      :type button: integer (an :class:`sfml.window.Mouse`'s constant)
      :rtype: bool


   .. classmethod:: get_position([relativ_to])

      Get the current position of the mouse in window coordinates.

      This function returns the current position of the mouse cursor,
      relative to the given window.

      :param sfml.window.Window relativ_to: Reference window
      :rtype: bool

   .. classmethod:: set_position(position[, relativ_to])

      Set the current position of the mouse in window coordinates.

      This function sets the current position of the mouse cursor,
      relative to the given window.

      :param sfml.system.Vector2 position: New position of the mouse
      :param sfml.window.Window relativ_to: Reference window


Context
^^^^^^^

.. class:: Context

   Class holding a valid drawing context.

   If you need to make OpenGL calls without having an active window
   (like in a thread), you can use an instance of this class to get a
   valid context.

   Having a valid context is necessary for *every* OpenGL call.

   Note that a context is only active in its current thread, if you
   create a new thread it will have no valid context by default.

   To use an :class:`Context` instance, just construct it and let it
   live as long as you need a valid context. No explicit activation is
   needed, all it has to do is to exist. Its destructor will take care
   of deactivating and freeing all the attached resources.

   Usage example::

      def thread_function():
         context = sf.Context()
         # from now on, you have a valid context

         # you can make OpenGL calls
         glClear(GL_DEPTH_BUFFER_BIT)

      # the context is automatically deactivated and destroyed by the
      # sf.Context destructor
