Threads
=======

.. contents:: :local:

What is a thread?
-----------------

Most of you should already know what a thread is, but here is however a little
explanation for those who are really new to this concept.

A thread is basically a sequence of instructions that run in parallel of other
threads. Every program is made of at least one thread: the main one, which runs
your Python script. Programs that only use the main thread are monothreaded, if
you add one or more threads they become multithreaded.

So, in short, threads are a way to do multiple things at the same time. This
can be useful, for example, to display an animation and reacting to user input
while loading images or sounds. Threads are also widely used in network
programming, to wait for data to be received while continuing to update and
draw the application.

pySFML threads or the *threading* module
----------------------------------------
The standard Python library contains everything you need for threading and
should be used instead. However, pySFML still provide some classes to match its
C++ version API and for those who wants to translate C++ code, piece by piece,
without caring about the interface differences.

Creating a thread with pySFML
-----------------------------

Enough talk, let's see some code. The class that makes it possible to create
threads in pySFML is :class:`.Thread`, and here is what it looks like in action::

   from sfml import sf

   def func():
      # this function is started when thread.launch() is called

      for i in range(10):
          print("I'm thread number 1")


   # create a thread with func() as entry point
   thread = sf.Thread(func)

   # run it
   thread.launch()

   # the main thread continues to run...

   for i in range(10):
       print("I'm the main thread")


In this code, both main and func run in parallel, after thread.launch() has
been called. The result is that text from both functions should be mixed in
the console.

.. image:: system-thread-mixed.png

The entry point of the thread, ie. the function that will be run in the
thread, must be passed to the constructor of :class:`Thread` as well as its
arguments. ::

   def func(a, b, c):
      print(a)
      print(b)
      print(c)

   mythread = sf.Thread(func, 50, -32, 1.8)
   mythread.launch()
   mythread.wait()


Starting threads
----------------

Once you've created a :class:`Thread` instance, you must start it with the
launch function. ::

   thread = sf.Thread(func)
   thread.launch()

:meth:`.launch` calls the function that you passed to the constructor in a new
thread, and returns immediately so that the calling thread can continue to run.

Stopping threads
----------------

A thread automatically stops when its function returns. If you want to wait for
a thread to finish from another thread, you can call its wait function. ::

   thread = sf.Thread(func)

   # start the thread
   thread.launch()

   # block execution until the thread is finished
   thread.wait()

The wait function is also implicitly called by the destructor of
:class:`.Thread`, so that a thread cannot remain alive (and out of control)
after its owner :class:`Thread` instance is destroyed. Keep this in mind when
you manage your threads (see the last section of this tutorial).

Pausing threads
---------------

There's no function in :class:`Thread` that allows another thread to pause it,
the only way to pause a thread is to do it from the code that it runs. In other
words, you can only pause the current thread. To do so, you can call the
:func:`.sleep` function: ::

   def func():
      # ...
      sf.sleep(sf.milliseconds(10))
      #...


:func:`.sleep` has one argument, which is the time to sleep. This duration can
be given with any unit/precision, as seen in the time tutorial. Note that you
can make any thread sleep with this function, even the main one.

:func:`.sleep` is the most efficient way to pause a thread: as long as the
thread sleeps, it requires zero CPU. Pauses based on active waiting, like empty
while loops, would consume 100% CPU just to do... nothing. However, keep in
mind that the sleep duration is just a hint, depending on the OS it will be
more or less accurate. So don't rely on it for very precise timing.

Protecting shared data
----------------------

All the threads of a program share the same memory, they can access all the
variables of the program. It is very convenient but also dangerous: since
threads run in parallel, it means that a variable or function might be used
concurrently from several threads at the same time. And if the operation is not
thread-safe, the result is undefined (ie. it might crash or corrupt data).

Several programming tools exist to help you protect shared data and make your
code thread-safe, these are called synchronization primitives. Common ones are
mutexes, semaphores, wait conditions and spin locks. They are all variants of
the same concept: they protect a piece of code by allowing only certain threads
to access it while blocking the others.

The most basic (and used) primitive is the mutex. :class:`.Mutex` stands for
"MUTual EXclusion": it allows only one thread at a time to access the pieces of
code that it surrounds. Let's see how they can bring some order to the example
above: ::

   mutex = sf.Mutex()

   def func():
      mutex.lock()

      for i in range(10):
         print("I'm thread number 1")

      mutex.unlock()


   thread = sf.Thread(func)
   thread.launch()

   mutex.lock()

   for i in range(10):
      print("I'm the main thread")

   mutex.unlock()

This code uses a shared resource (print), and as we've seen it produces
unwanted results -- everything is mixed in the console. To make sure that
complete lines are properly printed instead of being randomly mixed, we protect
the corresponding region of the code with a mutex.

The first thread that reaches its *mutex.lock()* line succeeds to lock the
mutex, directly gains access to the code that follows and prints its text. When
the other thread reaches its mutex.lock() line, the mutex is already locked and
thus the thread is put to sleep (similarly to :func:`.sleep`, no CPU is
consumed by the sleeping thread). When the first thread finally unlocks the
mutex, the second thread is awoken and is allowed to lock the mutex and print
its text bloc in turn. Thus lines of text appear sequentially in the console
instead of being mixed.

.. image:: system-thread-ordered.png

Mutexes are not the only primitive that you can use to protect your shared
variables, but it should be enough for most cases. However if your application
does complicated things with threads, and you feel like it is not enough, don't
hesitate to look at the threading module from the standard Python library.

Protecting mutexes
------------------
Don't worry: mutexes are already thread-safe, there's no need to protect them.
But they are not exception-safe! What happens if an exception is thrown while a
mutex is locked? It never gets a chance to be unlocked, and remains locked
forever. And all threads that will try to lock it will block forever; your
whole application could freeze. Pretty bad result.

To make sure that mutexes are always unlocked in an environment where
exceptions can be thrown, pySFML provides a RAII class to wrap them:
:class:`.Lock`. It locks the mutex in its constructor, and unlocks it in its
destructor. Simple and efficient. ::

	mutex = sf.Mutex()

	def func():
		lock = sf.Lock(mutex)
		function_that_might_throw_an_exception() #  mutex.unlock() if this function throws
		# mutex.unlock()

Note that :class:`.Lock` can also be useful in a function that has multiple
return statements. ::

	mutex = sf.Mutex()

	def func():
		lock = sf.Lock(mutex) # mutex.lock()

		if (condition1):
			return False # mutex.unlock()

		if (condition2):
			return False # mutex.unlock()

		if (condition3):
			return False # mutex.unlock()

		return True
		# mutex.unlock()


Common mistakes
---------------
One thing that is often overlooked by programmers is that a thread cannot live
without its corresponding :class:`.Thread` instance.

The following code is often seen on the forums: ::

	def start_thread():
		thread = sf.Thread(func_to_run_in_thread)
		thread.launch()

	start_thread()

Programmers who write this kind of code expect the *start_thread* function to
start a thread that will live on its own and be destroyed when the threaded
function ends. But it is not what happens: the threaded function appears to
block the main thread, as if the thread wasn't working.

The reason? The :class:`.Thread` instance is local to the *start_thread()*
function and is therefore immediately destroyed, when the function returns. The
destructor of :class:`.Thread` is invoked, which calls :meth:`.wait` as we've
learned above, and the result is that the main thread blocks and waits for the
threaded function to be finished instead of continuing to run in parallel.

So, don't forget this: you must manage your :class:`.Thread` instance so that it
lives as long as the threaded function runs.
