#-------------------------------------------------------------------------------
# PySFML - Python bindings for SFML
# Copyright (c) 2012-2014, Jonathan De Wachter <dewachter.jonathan@gmail.com>
#                          Edwin Marshall <emarshall85@gmail.com>
#
# This software is provided 'as-is', without any express or implied warranty.
# In no event will the authors be held liable for any damages arising from the
# use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software in a
#    product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
#
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
#
# 3. This notice may not be removed or altered from any source distribution.
#-------------------------------------------------------------------------------

from __future__ import division

cimport cython

from libcpp.string cimport string
from libcpp.vector cimport vector

cimport sfml as sf
from sfml cimport Int8, Int16, Int32, Int64
from sfml cimport Uint8, Uint16, Uint32, Uint64
from pysfml.system cimport NumericObject

cdef extern from *:
    ctypedef int wchar_t
    ctypedef void* PyUnicodeObject
    object PyUnicode_FromWideChar(const wchar_t *w, Py_ssize_t size)

cdef extern from "error.hpp":
    void restorePythonErrorBuffer()
    object getLastErrorMessage()

cdef extern from "hacks.h":
    sf.Time Time_div_int(sf.Time left, Int64)
    sf.Time Time_div_float(sf.Time left, float)
    float Time_div_Time(sf.Time, sf.Time)
    void Time_idiv_int(sf.Time&, Int64)
    void Time_idiv_float(sf.Time&, float)

__all__ = ['Time', 'sleep', 'Clock', 'seconds', 'milliseconds', 'microseconds',
            'Vector2', 'Vector3']

# expose a function to restore the error handler
cdef api void restoreErrorHandler():
    restorePythonErrorBuffer()

# expose a function to retrieve the last SFML error
cdef api object popLastErrorMessage():
    error = getLastErrorMessage()

    # remove the extra \n character (if any)
    if error[-1] == '\n':
        error = error[:-1]

    return error

# redirect SFML errors to our stream buffer
restoreErrorHandler()

from cpython.string cimport PyString_AsString

cdef api sf.String to_string(object string):
    cdef char* cstring = NULL

    string = string + "\0"
    string = string.encode("utf-32")

    cstring = PyString_AsString(string)
    return sf.String(<Uint32*>cstring)

cdef api object wrap_string(const sf.String* p):
    return PyUnicode_FromWideChar(p.toWideString().c_str(), p.getSize())

cdef public class Vector2[type PyVector2Type, object PyVector2Object]:
    cdef sf.Vector2[NumericObject] *p_this

    def __cinit__(self):
        self.p_this = new sf.Vector2[NumericObject]()

    def __dealloc__(self):
        del self.p_this

    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y

    def __repr__(self):
        return "Vector2(x={0}, y={1})".format(self.x, self.y)

    def __str__(self):
        return "({0}, {1})".format(self.x, self.y)

    def __richcmp__(Vector2 self, other_, op):
        cdef Vector2 other

        if isinstance(other_, Vector2):
            other = <Vector2>other_
        else:
            x, y = other_
            other = Vector2(x, y)

        if op == 2:
            return self.p_this[0] == other.p_this[0]
        elif op == 3:
            return self.p_this[0] != other.p_this[0]
        else:
            raise NotImplemented

    def __iter__(self):
        return iter((self.x, self.y))

    def __add__(Vector2 self, other):
        cdef sf.Vector2[NumericObject] *p = new sf.Vector2[NumericObject]()

        if isinstance(other, Vector2):
            p[0] = self.p_this[0] + (<Vector2>other).p_this[0]
        else:
            x, y = other
            p[0] = self.p_this[0] + Vector2(x, y).p_this[0]

        return wrap_vector2(p)

    def __sub__(Vector2 self, other):
        cdef sf.Vector2[NumericObject] *p = new sf.Vector2[NumericObject]()

        if isinstance(other, Vector2):
            p[0] = self.p_this[0] - (<Vector2>other).p_this[0]
        else:
            x = other
            y = other
            p[0] = self.p_this[0] - Vector2(x, y).p_this[0]

        return wrap_vector2(p)

    def __mul__(Vector2 self, other):
        v = Vector2(self.x, self.y)
        if isinstance(other, Vector2):
            v.x *= other.x
            v.y *= other.y
        else:
            v.x *= other
            v.y *= other

        return v

    # Todo: I couldn't get the / operator working and as a workaround, I
    # reimplemented the logic in Python (I have to report this bug)
    def __truediv__(Vector2 self, other):
        v = Vector2(self.x, self.y)
        if isinstance(other, Vector2):
            v.x /= float(other.x)
            v.y /= float(other.y)
        else:
            v.x /= other
            v.y /= other

        return v

    def __iadd__(Vector2 self, other):
        if isinstance(other, Vector2):
            self.x += other.x
            self.y += other.y
        else:
            self.x += other
            self.y += other

        return self

    def __isub__(Vector2 self, other):
        if isinstance(other, Vector2):
            self.x -= other.x
            self.y -= other.y
        else:
            self.x -= other
            self.y -= other
        return self

    def __imul__(self, other):
        if isinstance(other, Vector2):
            self.x *= other.x
            self.y *= other.y
        else:
            self.x *= other
            self.y *= other

        return self

    # Todo: I couldn't get the =/ operator working and as a workaround, I
    # reimplemented the logic in Python (I have to report this bug)
    def __itruediv__(Vector2 self, other):
        if isinstance(other, Vector2):
            self.x /= float(other.x)
            self.y /= float(other.y)
        else:
            self.x /= other
            self.y /= other

        return self

    def __neg__(self):
        cdef sf.Vector2[NumericObject] *p = new sf.Vector2[NumericObject]()
        p[0] = -self.p_this[0]
        return wrap_vector2(p)

    def __copy__(self):
        cdef sf.Vector2[NumericObject] *p = new sf.Vector2[NumericObject](self.p_this[0])
        return wrap_vector2(p)

    property x:
        def __get__(self):
            return self.p_this.x.get()

        def __set__(self, object x):
            self.p_this.x.set(x)

    property y:
        def __get__(self):
            return self.p_this.y.get()

        def __set__(self, object y):
            self.p_this.y.set(y)

cdef api Vector2 wrap_vector2(sf.Vector2[NumericObject]* p):
    cdef Vector2 r = Vector2.__new__(Vector2)
    r.p_this = p
    return r

cdef api object wrap_vector2i(sf.Vector2i p):
    cdef Vector2 r = Vector2.__new__(Vector2)
    r.x = p.x
    r.y = p.y
    return r

cdef api object wrap_vector2u(sf.Vector2u p):
    cdef Vector2 r = Vector2.__new__(Vector2)
    r.x = p.x
    r.y = p.y
    return r

cdef api object wrap_vector2f(sf.Vector2f p):
    cdef Vector2 r = Vector2.__new__(Vector2)
    r.x = p.x
    r.y = p.y
    return r

cdef api sf.Vector2i to_vector2i(vector):
    x, y = vector
    return sf.Vector2i(x, y)

cdef api sf.Vector2u to_vector2u(vector):
    x, y = vector
    return sf.Vector2u(x, y)

cdef api sf.Vector2f to_vector2f(vector):
    x, y = vector
    return sf.Vector2f(x, y)

cdef public class Vector3[type PyVector3Type, object PyVector3Object]:
    cdef sf.Vector3[NumericObject] *p_this

    def __cinit__(self):
        self.p_this = new sf.Vector3[NumericObject]()

    def __dealloc__(self):
        del self.p_this

    def __init__(self, x=0, y=0, z=0):
        self.x = x
        self.y = y
        self.z = z

    def __repr__(self):
        return "Vector3(x={0}, y={1}, z={2})".format(self.x, self.y, self.z)

    def __str__(self):
        return "({0}, {1}, {2})".format(self.x, self.y, self.z)

    def __richcmp__(Vector3 self, other_, op):
        cdef Vector3 other

        if isinstance(other_, Vector3):
            other = <Vector3>other_
        else:
            x, y, z = other_
            other = Vector3(x, y, z)

        if op == 2:
            return self.p_this[0] == other.p_this[0]
        elif op == 3:
            return self.p_this[0] != other.p_this[0]
        else:
            raise NotImplemented

    def __iter__(self):
        return iter((self.x, self.y, self.z))

    def __add__(Vector3 self, other):
        cdef sf.Vector3[NumericObject] *p = new sf.Vector3[NumericObject]()

        if isinstance(other, Vector3):
            p[0] = self.p_this[0] + (<Vector3>other).p_this[0]
        else:
            x, y, z = other
            p[0] = self.p_this[0] + Vector3(x, y, z).p_this[0]

        return wrap_vector3(p)

    def __sub__(Vector3 self, other):
        cdef sf.Vector3[NumericObject] *p = new sf.Vector3[NumericObject]()

        if isinstance(other, Vector3):
            p[0] = self.p_this[0] - (<Vector3>other).p_this[0]
        else:
            x, y, z = other
            p[0] = self.p_this[0] - Vector3(x, y, z).p_this[0]

        return wrap_vector3(p)

    def __mul__(Vector3 self, other):
        cdef sf.Vector3[NumericObject] *p = new sf.Vector3[NumericObject]()
        p[0] = self.p_this[0] * NumericObject(other)

        return wrap_vector3(p)

    # Todo: I couldn't get the / operator working and as a workaround, I
    # reimplemented the logic in Python (I have to report this bug)
    def __truediv__(Vector3 self, other):
        return Vector3(self.x / other, self.y / other, self.z / other)

    def __iadd__(Vector3 self, other):
        if isinstance(other, Vector3):
            self.p_this[0] += (<Vector3>other).p_this[0]
        else:
            x, y, z = other
            self.p_this[0] += Vector3(x, y, z).p_this[0]

        return self

    def __isub__(Vector3 self, other):
        if isinstance(other, Vector3):
            self.p_this[0] -= (<Vector3>other).p_this[0]
        else:
            x, y, z = other
            self.p_this[0] -= Vector3(x, y, z).p_this[0]

        return self

    def __imul__(self, other):
        self.p_this[0] *= NumericObject(other)

        return self

    # Todo: I couldn't get the =/ operator working and as a workaround, I
    # reimplemented the logic in Python (I have to report this bug)
    def __itruediv__(Vector3 self, other):
        self.x /= other
        self.y /= other
        self.z /= other

        return self

    def __neg__(self):
        cdef sf.Vector3[NumericObject] *p = new sf.Vector3[NumericObject]()
        p[0] = -self.p_this[0]
        return wrap_vector3(p)

    def __copy__(self):
        cdef sf.Vector3[NumericObject] *p = new sf.Vector3[NumericObject](self.p_this[0])
        return wrap_vector3(p)

    property x:
        def __get__(self):
            return self.p_this.x.get()

        def __set__(self, object x):
            self.p_this.x.set(x)

    property y:
        def __get__(self):
            return self.p_this.y.get()

        def __set__(self, object y):
            self.p_this.y.set(y)

    property z:
        def __get__(self):
            return self.p_this.z.get()

        def __set__(self, object z):
            self.p_this.z.set(z)

cdef api object wrap_vector3(sf.Vector3[NumericObject]* p):
    cdef Vector3 r = Vector3.__new__(Vector3)
    r.p_this = p
    return r

cdef api object wrap_vector3i(sf.Vector3i p):
    cdef Vector3 r = Vector3.__new__(Vector3)
    r.x = p.x
    r.y = p.y
    r.z = p.z
    return r

cdef api object wrap_vector3f(sf.Vector3f p):
    cdef Vector3 r = Vector3.__new__(Vector3)
    r.x = p.x
    r.y = p.y
    r.z = p.z
    return r

cdef api sf.Vector3i to_vector3i(vector):
    x, y, z = vector
    return sf.Vector3i(x, y, z)

cdef api sf.Vector3f to_vector3f(vector):
    x, y, z = vector
    return sf.Vector3f(x, y, z)

cdef public class Time[type PyTimeType, object PyTimeObject]:
    ZERO = wrap_time(<sf.Time*>&sf.time.Zero)

    cdef sf.Time *p_this

    def __cinit__(self):
        self.p_this = new sf.Time()

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "Time(milliseconds={0})".format(self.milliseconds)

    def __str__(self):
        return "{0} milliseconds".format(self.milliseconds)

    def __richcmp__(Time x, Time y, int op):
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

    def __add__(Time x, Time y):
        cdef sf.Time* p = new sf.Time()
        p[0] = x.p_this[0] + y.p_this[0]
        return wrap_time(p)

    def __sub__(Time x, Time y):
        cdef sf.Time* p = new sf.Time()
        p[0] = x.p_this[0] - y.p_this[0]
        return wrap_time(p)

    def __mul__(Time self, other):
        cdef sf.Time* p = new sf.Time()

        if isinstance(other, (int, long)):
            p[0] = self.p_this[0] * <Int64>other
        elif isinstance(other, float):
            p[0] = self.p_this[0] * <float>other
        else:
            return NotImplemented

        return wrap_time(p)

    def __truediv__(Time self, other):
        cdef sf.Time* p

        if isinstance(other, Time):
#            return self.p_this[0] / (<Time>other).p_this[0]
            return Time_div_Time(self.p_this[0], (<Time>other).p_this[0])
        else:
            p = new sf.Time()
            if isinstance(other, (int, long)):
#                p[0] = self.p_this[0] / <Int64>other
                p[0] = Time_div_int(self.p_this[0], <Int64>other)
            elif isinstance(other, float):
#                p[0] = self.p_this[0] / <float>other
                p[0] = Time_div_float(self.p_this[0], <float>other)
            else:
                del p
                return NotImplemented

            return wrap_time(p)

    def __mod__(Time x, Time y):
        cdef sf.Time* p = new sf.Time()
        p[0] = x.p_this[0] % y.p_this[0]
        return wrap_time(p)

    def __iadd__(self, Time x):
        self.p_this[0] += x.p_this[0]
        return self

    def __isub__(self, Time x):
        self.p_this[0] -= x.p_this[0]
        return self

    def __imul__(Time self, other):
        if isinstance(other, (int, long)):
            self.p_this[0] *= <Int64>other
        elif isinstance(other, float):
            self.p_this[0] *= <float>other
        else:
            return NotImplemented

        return self

    def __itruediv__(Time self, other):
        if isinstance(other, (int, long)):
#            self.p_this[0] /= <Int64>other
            Time_idiv_int(self.p_this[0], <Int64>other)
        elif isinstance(other, float):
#            self.p_this[0] /= <float>other
            Time_idiv_float(self.p_this[0], <float>other)
        else:
            return NotImplemented

        return self

    def __imod__(self, Time x):
        self.p_this[0] %= x.p_this[0]
        return self

    def __neg__(self):
        cdef sf.Time* p = new sf.Time()
        p[0] = -self.p_this[0]
        return wrap_time(p)

    property seconds:
        def __get__(self):
            return self.p_this.asSeconds()

        def __set__(self, float seconds):
            self.p_this[0] = sf.seconds(seconds)

    property milliseconds:
        def __get__(self):
            return self.p_this.asMilliseconds()

        def __set__(self, Int32 milliseconds):
            self.p_this[0] = sf.milliseconds(milliseconds)

    property microseconds:
        def __get__(self):
            return self.p_this.asMicroseconds()

        def __set__(self, Int64 microseconds):
            self.p_this[0] = sf.microseconds(microseconds)

    def __copy__(self):
        cdef sf.Time* p = new sf.Time()
        p[0] = self.p_this[0]
        return wrap_time(p)


cdef api object wrap_time(sf.Time* p):
    cdef Time r = Time.__new__(Time)
    r.p_this = p
    return r

def sleep(Time duration):
    with nogil: sf.sleep(duration.p_this[0])

cdef class Clock:
    cdef sf.Clock *p_this

    def __cinit__(self):
        self.p_this = new sf.Clock()

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "Clock(elapsed_time={0})".format(self.elapsed_time)

    def __str__(self):
        return "{0}".format(self.elapsed_time)

    property elapsed_time:
        def __get__(self):
            cdef sf.Time* p = new sf.Time()
            p[0] = self.p_this.getElapsedTime()
            return wrap_time(p)

    def restart(self):
        cdef sf.Time* p = new sf.Time()
        p[0] = self.p_this.restart()
        return wrap_time(p)

def seconds(float amount):
    cdef sf.Time* p = new sf.Time()
    p[0] = sf.seconds(amount)
    return wrap_time(p)

def milliseconds(Int32 amount):
    cdef sf.Time* p = new sf.Time()
    p[0] = sf.milliseconds(amount)
    return wrap_time(p)

def microseconds(Int64 amount):
    cdef sf.Time* p = new sf.Time()
    p[0] = sf.microseconds(amount)
    return wrap_time(p)
