Getting started
===============
These bindings are easy to apprehend and learn if you come from the C++
library; class, methods and functions names are the same. We'll see here
step by step everything you need to know to get started with pySFML!

Of course, you need first to have pySFML downloaded and installed on
your computer. To do that, read the :doc:`download </download>`  section, it
provides all explanations you'll need to install on your favourite platform.
At worst, you'll need to compile.

After reading this you can jump to the single :ref:`tutorials-reference` that
summarizes all the large, potentially surprising, changes that you
should be aware of. You'll be able to start coding serious project with
the documentation at hand.

Diving In
---------
.. note::

    On Windows, typing these commands directly in a console might cause the
    console to freeze, in which case it is better to save the lines of code
    (without the '>>>' prompt) to a file to run later.

Open a terminal and run the Python interpreter. Now we can experiment::

   >>> from sfml import sf
   >>> w = sf.RenderWindow(sf.VideoMode(640, 480), "My first pySFML Window - or not ?")
   >>> w.clear(sf.Color.BLUE)
   >>> w.display()
   >>> w.size = (800, 600)
   >>> w.clear(sf.Color.GREEN)
   >>> w.display()
   >>> w.title = "Yes, it's my first PySFML Window"
   >>> w.display()
   >>> w.capture().show()
   >>> w.close()
   >>> exit()

Short Example
-------------
As a start, let's compare the python short example with the C++ one.
Here it is:

.. code-block:: python
   :linenos:

   from sfml import sf


   # create the main window
   window = sf.RenderWindow(sf.VideoMode(640, 480), "pySFML Window")

   try:
      # load a sprite to display
      texture = sf.Texture.from_file("cute_image.png")
      sprite = sf.Sprite(texture)

      # create some graphical text to display
      font = sf.Font.from_file("arial.ttf")
      text = sf.Text("Hello SFML", font, 50)

      # load music to play
      music = sf.Music.from_file("nice_music.ogg")

   except IOError: exit(1)

   # play the music
   music.play()

   # start the game loop
   while window.is_open:
      # process events
      for event in window.events:
         # close window: exit
         if type(event) is sf.CloseEvent:
            window.close()

      window.clear() # clear screen
      window.draw(sprite) # draw the sprite
      window.draw(text) # draw the string
      window.display() # update the window

First, you can notice the interface is not far different from the
original and remains quite the same; the interface has been pythonized.

Importing
^^^^^^^^^
The module hierarchy in pySFML models the C++ API rather closely. As such, you
may import them directly::

   import sfml.system

As with any other python package, you may find yourself using aliases to more
conveniently access the API::

   import sfml.system as sf

   sf.sleep(sf.seconds(5)

The problem with this approach is that it breaks down rather quickly when you
want to start to use mutiple submodules from the sfml package. For this reason,
we provide a convenience module named sf, which imports all of the other
submodules::

   import sf

   sf.sleep(sf.seconds(5)

For the sake of keeping examples brief, the rest of the documentation uses this
convenience module. However, should you ever become curious as to where a
particular object resides, their fully qualified names linked. 

Window Creation
^^^^^^^^^^^^^^^
There's no difference here. if you want to give a style:

.. code-block:: python

   window = sf.RenderWindow(sf.VideoMode(640, 480), "pySFML Window", sf.Style.TITLEBAR | sf.Style.RESIZE)

Loading Resources
^^^^^^^^^^^^^^^^^
Instead of checking every time if the resource has effectively been loaded,
pySFML takes advantages of the Python mechanisms. Just enclose
your resource loading processes in a try-except bloc and Python will tell
you when something goes wrong.

As you can see in the code, it will trigger an exception :exc:`IOError` in
accordance with the Python's exception rules.

To follow the same convention as the standard Python library and so,
offer a better integration, `openFromFile` and `loadFromFile` have been
renamed into `from_file`.

Event Handling
^^^^^^^^^^^^^^
To iterate over the pending events, use the generator that Window.events
return. It's similar to the polling event process.

.. code-block:: python

   for event in window.events:
       print(event)

.. note::

   :meth:`sfml.window.Window.poll_event` and :meth:`sfml.window.Window.wait_event` do exist.

Once you get an event you need to process it. To do that, you need to
check its type as you would do in C++. pysfml2 doesn't provides
the attribute **type** that tells you what event it is (keyboard event,
mouse event, mouse move event, etc). Therefore you need to use the
built-in function :func:`type` to determine its type.

.. code-block:: python

         if type(event) is sf.CloseEvent:
            window.close()

You can get a list of the event class in the documentation, section
window, as event handling is located in the window module ;).

Updating the Screen
^^^^^^^^^^^^^^^^^^^
Don't forget to clear, draw and update the screen.

.. code-block:: python

      window.clear() # clear screen
      window.draw(sprite) # draw the sprite
      window.draw(text) # draw the string
      window.display() # update the window

Vectors
-------
As Python is not a typed language, you don't have to care about the
type when you use sf::Vector<T>. Python just needs to know if it's a
two or three dimensional vector, after, you can store any numeric type
inside.

.. code-block:: python

   vector2 = sf.Vector2()
   vector2.x = 5
   vector2.y = 1.16

   vector3 = sf.Vector3()
   vector3.x = Decimal(0.333333333)

   x, y, z = vector3 # you can unpack the vector
