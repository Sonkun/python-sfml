# PySFML - Python bindings for SFML
# Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
#
# This file is part of PySFML project and is available under the zlib
# license.

from libcpp.vector cimport vector
from libcpp.string cimport string

cimport sfml as sf
from sfml cimport Int8, Int16, Int32, Int64
from sfml cimport Uint8, Uint16, Uint32, Uint64

cdef extern from "pysfml/graphics/DerivableDrawable.hpp":
    cdef cppclass DerivableDrawable:
        DerivableDrawable(object)

    const Uint8* getPixelsPtr(object)

cdef extern from "pysfml/graphics/DerivableRenderWindow.hpp":
    cdef cppclass DerivableRenderWindow:
        DerivableRenderWindow(object)

        void createWindow()
        void resizeWindow()

from libc.stdlib cimport malloc, free

__all__ = ['BlendMode', 'PrimitiveType', 'Color', 'Rect', 'Transform',
            'Image', 'Texture', 'Glyph', 'Font', 'Shader',
            'RenderStates', 'Drawable', 'Transformable', 'Sprite',
            'Text', 'Shape', 'CircleShape', 'ConvexShape',
            'RectangleShape', 'Vertex', 'VertexArray', 'View',
            'RenderTarget', 'RenderTexture', 'RenderWindow',
            'HandledWindow', 'TransformableDrawable']

__all__ += ['BLEND_ALPHA', 'BLEND_ADD', 'BLEND_MULTIPLY', 'BLEND_NONE']

string_type = [bytes, unicode, str]
numeric_type = [int, long, float, long]

import sys
from copy import copy, deepcopy
from enum import IntEnum

from pysfml.system cimport NumericObject
from pysfml.system cimport Vector2, Vector3
from pysfml.system cimport to_vector2i, to_vector2f
from pysfml.system cimport to_string, wrap_string
from pysfml.system cimport popLastErrorMessage, import_sfml__system
from pysfml.window cimport VideoMode, ContextSettings, Window

import_sfml__system()

class PrimitiveType:
    POINTS = sf.primitivetype.Points
    LINES = sf.primitivetype.Lines
    LINES_STRIP = sf.primitivetype.LinesStrip
    TRIANGLES = sf.primitivetype.Triangles
    TRIANGLES_STRIP = sf.primitivetype.TrianglesStrip
    TRIANGLES_FAN = sf.primitivetype.TrianglesFan
    QUADS = sf.primitivetype.Quads


cdef public class Rect[type PyRectType, object PyRectObject]:
    cdef sf.Rect[NumericObject] *p_this

    def __cinit__(self):
        self.p_this = new sf.Rect[NumericObject]()

    def __dealloc__(self):
        del self.p_this

    def __init__(self, position=(0, 0), size=(0, 0)):
        left, top = position
        width, height = size
        self.left = left
        self.top = top
        self.width = width
        self.height = height

    def __repr__(self):
        return "Rect(left={0}, top={1}, width={2}, height={3})".format(self.left, self.top, self.width, self.height)

    def __str__(self):
        return "({0}, {1}, {2}, {3})".format(self.left, self.top, self.width, self.height)

    def __richcmp__(Rect self, other_, op):
        cdef Rect other

        if isinstance(other_, Rect):
            other = <Rect>other_
        else:
            left, top, width, height = other_
            other = Rect((left, top), (width, height))

        if op == 2:
            return self.p_this[0] == other.p_this[0]
        elif op == 3:
            return self.p_this[0] != other.p_this[0]
        else:
            raise NotImplemented

    def __iter__(self):
        return iter((self.left, self.top, self.width, self.height))

    def __copy__(self):
        cdef sf.Rect[NumericObject] *p = new sf.Rect[NumericObject](self.p_this[0])
        return wrap_rect(p)

    property left:
        def __get__(self):
            return self.p_this.left.get()

        def __set__(self, left):
            self.p_this.left.set(left)

    property top:
        def __get__(self):
            return self.p_this.top.get()

        def __set__(self, top):
            self.p_this.top.set(top)

    property width:
        def __get__(self):
            return self.p_this.width.get()

        def __set__(self, width):
            self.p_this.width.set(width)

    property height:
        def __get__(self):
            return self.p_this.height.get()

        def __set__(self, height):
            self.p_this.height.set(height)

    def contains(self, point):
        if isinstance(point, Vector2):
            return self.p_this.contains((<Vector2>point).p_this[0])
        else:
            x, y = point
            return self.p_this.contains(Vector2(x, y).p_this[0])

    def intersects(self, rectangle):
        cdef Rect intersection = Rect()

        if isinstance(rectangle, Rect):
            self.p_this.intersects((<Rect>rectangle).p_this[0], intersection.p_this[0])
        else:
            left, top, width, height = rectangle
            self.p_this.intersects(Rect((left, top), (width, height)).p_this[0], intersection.p_this[0])

        return intersection


cdef api Rect wrap_rect(sf.Rect[NumericObject]* p):
    cdef Rect r = Rect.__new__(Rect)
    r.p_this = p
    return r

cdef api Rect wrap_intrect(sf.IntRect* p):
    cdef Rect r = Rect.__new__(Rect)
    r.left = p.left
    r.top = p.top
    r.width = p.width
    r.height = p.height
    return r

cdef api Rect wrap_floatrect(sf.FloatRect* p):
    cdef Rect r = Rect.__new__(Rect)
    r.left = p.left
    r.top = p.top
    r.width = p.width
    r.height = p.height
    return r

cdef api sf.FloatRect to_floatrect(rectangle):
    l, t, w, h = rectangle
    return sf.FloatRect(l, t, w, h)

cdef api sf.IntRect to_intrect(rectangle):
    l, t, w, h = rectangle
    return sf.IntRect(l, t, w, h)

cdef public class Color [type PyColorType, object PyColorObject]:
    BLACK = Color(0, 0, 0)
    WHITE = Color(255, 255, 255)
    RED = Color(255, 0, 0)
    GREEN = Color(0, 255, 0)
    BLUE = Color(0, 0, 255)
    YELLOW = Color(255, 255, 0)
    MAGENTA = Color(255, 0, 255)
    CYAN = Color(0, 255, 255)
    TRANSPARENT = Color(0, 0, 0, 0)

    cdef sf.Color *p_this

    def __cinit__(self, Uint8 r=0, Uint8 g=0, Uint8 b=0, Uint8 a=255):
        self.p_this = new sf.Color(r, g, b, a)

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "Color(red={0}, green={1}, blue={2}, alpha={3})".format(self.r, self.g, self.b, self.a)

    def __str__(self):
        return "(R={0}, G={1}, B={2}, A={3})".format(self.r, self.g, self.b, self.a)

    def __int__(self):
        return (((self.r & 0xFF) << 24) | ((self.g & 0xFF) << 16) | ((self.b & 0xFF) << 8) | (self.a & 0xFF))

    def __iter__(self):
        return iter((self.r, self.g, self.b, self.a))

    def __richcmp__(Color x, Color y, int op):
        if op == 2:
            return x.p_this[0] == y.p_this[0]
        elif op == 3:
            return x.p_this[0] != y.p_this[0]
        else:
            return NotImplemented

    def __add__(Color x, Color y):
        r = Color(0, 0, 0)
        r.p_this[0] = x.p_this[0] + y.p_this[0]
        return r

    def __mul__(Color x, Color y):
        r = Color(0, 0, 0)
        r.p_this[0] = x.p_this[0] * y.p_this[0]
        return r

    def __iadd__(self, Color x):
        self.p_this[0] = self.p_this[0] + x.p_this[0]
        return self

    def __imul__(self, Color x):
        self.p_this[0] = self.p_this[0] * x.p_this[0]
        return self

    property r:
        def __get__(self):
            return self.p_this.r

        def __set__(self, Uint8 r):
            self.p_this.r = r

    property g:
        def __get__(self):
            return self.p_this.g

        def __set__(self, Uint8 g):
            self.p_this.g = g

    property b:
        def __get__(self):
            return self.p_this.b

        def __set__(self, Uint8 b):
            self.p_this.b = b

    property a:
        def __get__(self):
            return self.p_this.a

        def __set__(self, unsigned int a):
            self.p_this.a = a

    def __copy__(self):
        cdef Color p = Color.__new__(Color)
        p.r, p.g, p.b, p.a = self
        return p

cdef api Color wrap_color(sf.Color *p):
    cdef Color r = Color.__new__(Color)
    r.p_this = p
    return r


cdef class Transform:
    cdef sf.Transform *p_this
    cdef bint          delete_this

    IDENTITY = wrap_transform(<sf.Transform*>&sf.transform.Identity)

    def __init__(self):
        self.p_this = new sf.Transform()
        self.delete_this = True

    def __dealloc__(self):
        if self.delete_this:
            del self.p_this

    def __repr__(self):
        cdef float *p = <float*>self.p_this.getMatrix()
        return "Transform({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})".format(
                            p[0], p[4], p[12], p[1], p[5], p[13], p[3], p[7], p[15])

    def __str__(self):
        cdef float *p = <float*>self.p_this.getMatrix()
        return "[{0}, {1}, {2}]\n[{3}, {4}, {5}]\n[{6}, {7}, {8}]".format(
                            str(p[0])[:3], str(p[4])[:3], str(p[12])[:3],
                            str(p[1])[:3], str(p[5])[:3], str(p[13])[:3],
                            str(p[3])[:3], str(p[7])[:3], str(p[15])[:3])

    def __mul__(Transform x, Transform y):
        r = Transform()
        r.p_this[0] = x.p_this[0] * y.p_this[0]
        return r

    def __imul__(self, Transform x):
        self.p_this[0] = self.p_this[0] * x.p_this[0]
        return self

    @classmethod
    def from_values(cls, float a00, float a01, float a02, float a10, float a11, float a12, float a20, float a21, float a22):
        cdef Transform r = Transform.__new__(Transform)
        r.p_this = new sf.Transform(a00, a01, a02, a10, a11, a12, a20, a21, a22)
        return r

    property matrix:
        def __get__(self):
            return <long>self.p_this.getMatrix()

    property inverse:
        def __get__(self):
            cdef sf.Transform *p = new sf.Transform()
            p[0] = self.p_this.getInverse()
            return wrap_transform(p)

    def transform_point(self, point):
        cdef sf.Vector2f p = self.p_this.transformPoint(to_vector2f(point))
        return Vector2(p.x, p.y)

    def transform_rectangle(self, rectangle):
        cdef sf.FloatRect p = self.p_this.transformRect(to_floatrect(rectangle))
        return Rect((p.left, p.top), (p.width, p.height))

    def combine(self, Transform transform):
        self.p_this.combine(transform.p_this[0])
        return self

    def translate(self, offset):
        self.p_this.translate(to_vector2f(offset))
        return self

    def rotate(self, float angle, center=None):
        if not center:
            self.p_this.rotate(angle)
        else:
            self.p_this.rotate(angle, to_vector2f(center))

        return self

    def scale(self, factor, center=None):
        if not center:
            self.p_this.scale(to_vector2f(factor))
        else:
            self.p_this.scale(to_vector2f(factor), to_vector2f(center))

        return self

cdef Transform wrap_transform(sf.Transform *p, bint d=True):
    cdef Transform r = Transform.__new__(Transform)
    r.p_this = p
    r.delete_this = d
    return r

class Factor(IntEnum):
    ZERO = sf.blendmode.Zero
    ONE = sf.blendmode.One
    SRC_COLOR = sf.blendmode.SrcColor
    ONE_MINUS_SRC_COLOR = sf.blendmode.OneMinusSrcColor
    DST_COLOR = sf.blendmode.DstColor
    ONE_MINUS_DST_COLOR = sf.blendmode.OneMinusDstColor
    SRC_ALPHA = sf.blendmode.SrcAlpha
    ONE_MINUS_SRC_ALPHA = sf.blendmode.OneMinusSrcAlpha
    DST_ALPHA = sf.blendmode.DstAlpha
    ONE_MINUS_DST_ALPHA = sf.blendmode.OneMinusDstAlpha

class Equation(IntEnum):
    ADD = sf.blendmode.Add
    SUBTRACT = sf.blendmode.Subtract

cdef public class BlendMode[type PyBlendModeType, object PyBlendModeObject]:
    cdef sf.BlendMode *p_this

    def __cinit__(self,
        sf.blendmode.Factor color_source_factor = sf.blendmode.SrcAlpha,
        sf.blendmode.Factor color_destination_factor = sf.blendmode.OneMinusSrcAlpha,
        sf.blendmode.Equation color_blend_equation = sf.blendmode.Add,
        sf.blendmode.Factor alpha_source_factor = sf.blendmode.One,
        sf.blendmode.Factor alpha_destination_factor = sf.blendmode.OneMinusSrcAlpha,
        sf.blendmode.Equation alpha_blend_equation = sf.blendmode.Add):
        self.p_this = new sf.BlendMode(color_source_factor, color_destination_factor, color_blend_equation,
            alpha_source_factor, alpha_destination_factor, alpha_blend_equation)

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "BlendMode({0}, {1}, {2}, {3}, {4}, {5})".format(self.color_src_factor, self.color_dst_factor, self.color_equation,
            self.alpha_src_factor, self.alpha_dst_factor, self.alpha_equation)

    def __richcmp__(BlendMode x, BlendMode y, int op):
        if op == 2:
            return x.p_this[0] == y.p_this[0]
        elif op == 3:
            return x.p_this[0] != y.p_this[0]

        raise NotImplementedError

    property color_src_factor:
        def __get__(self):
            return self.p_this[0].colorSrcFactor

        def __set__(self, sf.blendmode.Factor color_src_factor):
            self.p_this[0].colorSrcFactor = color_src_factor

    property color_dst_factor:
        def __get__(self):
            return self.p_this[0].colorDstFactor

        def __set__(self, sf.blendmode.Factor color_dst_factor):
            self.p_this[0].colorDstFactor = color_dst_factor

    property color_equation:
        def __get__(self):
            return self.p_this[0].colorEquation

        def __set__(self, sf.blendmode.Equation color_equation):
            self.p_this[0].colorEquation = color_equation

    property alpha_src_factor:
        def __get__(self):
            return self.p_this[0].alphaSrcFactor

        def __set__(self, sf.blendmode.Factor alpha_src_factor):
            self.p_this[0].alphaSrcFactor = alpha_src_factor

    property alpha_dst_factor:
        def __get__(self):
            return self.p_this[0].alphaDstFactor

        def __set__(self, sf.blendmode.Factor alpha_dst_factor):
            self.p_this[0].alphaDstFactor = alpha_dst_factor

    property alpha_equation:
        def __get__(self):
            return self.p_this[0].alphaEquation

        def __set__(self, sf.blendmode.Equation alpha_equation):
            self.p_this[0].alphaEquation = alpha_equation

cdef api BlendMode wrap_blendmode(sf.BlendMode *p):
    cdef BlendMode blendmode = BlendMode()
    blendmode.p_this[0] = p[0]
    return blendmode

BLEND_ALPHA = wrap_blendmode(<sf.BlendMode*>&sf.BlendAlpha)
BLEND_ADD = wrap_blendmode(<sf.BlendMode*>&sf.BlendAdd)
BLEND_MULTIPLY = wrap_blendmode(<sf.BlendMode*>&sf.BlendMultiply)
BLEND_NONE = wrap_blendmode(<sf.BlendMode*>&sf.BlendNone)

cdef public class Image[type PyImageType, object PyImageObject]:
    cdef sf.Image *p_this

    def __init__(self):
        raise UserWarning("Use a specific constructor")

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "Image(size={0})".format(self.size)

    def __getitem__(self, tuple v):
        cdef sf.Color *p = new sf.Color()
        p[0] = self.p_this.getPixel(v[0], v[1])
        return wrap_color(p)

    def __setitem__(self, tuple k, Color v):
        self.p_this.setPixel(k[0], k[1], v.p_this[0])

    def __copy__(self):
        cdef sf.Image *p = new sf.Image()
        p[0] = self.p_this[0]
        return wrap_image(p)

    def __getbuffer__(self, Py_buffer *buffer, int flags):
        buffer.buf = <char*>self.p_this.getPixelsPtr()
        buffer.format = 'c'
        buffer.internal = NULL
        buffer.itemsize = 1
        buffer.len = self.p_this.getSize().x * self.p_this.getSize().y * 4
        buffer.ndim = 1
        buffer.obj = self
        buffer.readonly = 1
        buffer.shape = NULL
        buffer.strides = NULL
        buffer.suboffsets = NULL

    def __releasebuffer__(self, Py_buffer *buffer):
        pass

    @classmethod
    def create(cls, unsigned int width, unsigned int height, Color color=None):
        cdef sf.Image *p = new sf.Image()

        if not color:
            p.create(width, height)
        else:
            p.create(width, height, color.p_this[0])

        return wrap_image(p)

    @classmethod
    def from_size(cls, unsigned int width, unsigned int height, Color color=None):
        cdef sf.Image *p = new sf.Image()

        if not color:
            p.create(width, height)
        else:
            p.create(width, height, color.p_this[0])

        return wrap_image(p)

    @classmethod
    def from_pixels(cls, int width, int height, pixels):
        cdef sf.Image *p = new sf.Image()
        cdef const sf.Uint8* pixels_ptr = getPixelsPtr(memoryview(pixels))

        p.create(width, height, pixels_ptr)
        return wrap_image(p)

    @classmethod
    def from_file(cls, basestring filename):
        cdef sf.Image *p = new sf.Image()

        if p.loadFromFile(filename.encode('UTF-8')):
            return wrap_image(p)

        del p
        raise IOError(popLastErrorMessage())

    @classmethod
    def from_memory(cls, bytes data):
        cdef sf.Image *p = new sf.Image()

        if p.loadFromMemory(<char*>data, len(data)):
            return wrap_image(p)

        del p
        raise IOError(popLastErrorMessage())

    def to_file(self, basestring filename):
        if not self.p_this.saveToFile(filename.encode('UTF-8')):
            raise IOError(popLastErrorMessage())

    property size:
        def __get__(self):
            return Vector2(self.p_this.getSize().x, self.p_this.getSize().y)

    property width:
        def __get__(self):
            return self.size.x

    property height:
        def __get__(self):
            return self.size.y

    def create_mask_from_color(self, Color color, Uint8 alpha=0):
        self.p_this.createMaskFromColor(color.p_this[0], alpha)

    def blit(self, Image source, dest, source_rect=None, bint apply_alpha=False):
        x, y = dest

        if not source_rect:
            self.p_this.copy(source.p_this[0], x, y, sf.IntRect(0, 0, 0, 0), apply_alpha)
        else:
            self.p_this.copy(source.p_this[0], x, y, to_intrect(source_rect), apply_alpha)

    property pixels:
        def __get__(self):
            return memoryview(self)

    def flip_horizontally(self):
        self.p_this.flipHorizontally()

    def flip_vertically(self):
        self.p_this.flipVertically()


cdef api Image wrap_image(sf.Image *p):
    cdef Image r = Image.__new__(Image)
    r.p_this = p
    return r

class CoordinateType(IntEnum):
    NORMALIZED = sf.texture.Normalized
    PIXELS = sf.texture.Pixels

cdef public class Texture[type PyTextureType, object PyTextureObject]:
    cdef sf.Texture *p_this
    cdef bint delete_this

    cdef object __weakref__

    def __init__(self):
        raise UserWarning("Use a specific constructor")

    def __dealloc__(self):
        if self.delete_this:
            del self.p_this

    def __repr__(self):
        return "Texture(size={0}, smooth={1}, repeated={2})".format(self.size, self.smooth, self.repeated)

    def __copy__(self):
        cdef sf.Texture *p = new sf.Texture()
        p[0] = self.p_this[0]
        return wrap_texture(p, True)

    @classmethod
    def create(cls, unsigned int width, unsigned int height):
        cdef sf.Texture *p = new sf.Texture()

        if p.create(width, height):
            return wrap_texture(p, True)

        del p
        raise ValueError(popLastErrorMessage())

    @classmethod
    def from_size(cls, unsigned int width, unsigned int height):
        cdef sf.Texture *p = new sf.Texture()

        if p.create(width, height):
            return wrap_texture(p, True)

        del p
        raise ValueError(popLastErrorMessage())

    @classmethod
    def from_file(cls, basestring filename, area=None):
        cdef sf.Texture *p = new sf.Texture()

        if not area:
            if p.loadFromFile(filename.encode('UTF-8')):
                return wrap_texture(p, True)
        else:
            l, t, w, h = area
            if p.loadFromFile(filename.encode('UTF-8'), sf.IntRect(l, t, w, h)):
                return wrap_texture(p, True)

        del p
        raise IOError(popLastErrorMessage())

    @classmethod
    def from_memory(cls, bytes data, area=None):
        cdef sf.Texture *p = new sf.Texture()

        if not area:
            if p.loadFromMemory(<char*>data, len(data)):
                return wrap_texture(p, True)
        else:
            l, t, w, h = area
            if p.loadFromMemory(<char*>data, len(data), sf.IntRect(l, t, w, h)):
                return wrap_texture(p, True)

        del p
        raise IOError(popLastErrorMessage())

    @classmethod
    def from_image(cls, Image image, area=None):
        cdef sf.Texture *p = new sf.Texture()

        if not area:
            if p.loadFromImage(image.p_this[0]):
                return wrap_texture(p, True)
        else:
            l, t, w, h = area
            if p.loadFromImage(image.p_this[0], sf.IntRect(l, t, w, h)):
                return wrap_texture(p, True)

        del p
        raise IOError(popLastErrorMessage())

    property size:
        def __get__(self):
            return Vector2(self.p_this.getSize().x, self.p_this.getSize().y)

        def __set__(self, size):
            raise NotImplemented

    property width:
        def __get__(self):
            return self.size.x

        def __set__(self, width):
            raise NotImplemented

    property height:
        def __get__(self):
            return self.size.y

        def __set__(self, height):
            raise NotImplemented

    def copy_to_image(self):
        cdef sf.Image *p = new sf.Image()
        p[0] = self.p_this.copyToImage()
        return wrap_image(p)

    def to_image(self):
        cdef sf.Image *p = new sf.Image()
        p[0] = self.p_this.copyToImage()
        return wrap_image(p)

    def update(self, *args, **kwargs):
        if len(args) == 0:
            raise UserWarning("No arguments provided. It requires at least one.")

        if len(args) > 2:
            raise UserWarning("Too much arguments provided. It requires at most two.")

        if type(args[0]) is Image:
            if len(args) == 2:
                if type(args[1]) in [Vector2, tuple]:
                    self.update_from_image(args[0], args[1])
                else:
                    raise UserWarning("The second argument must be either a sf.Vector2 or a tuple")
            else:
                self.update_from_image(args[0])

        elif isinstance(args[0], Window):
            if len(args) == 2:
                if type(args[1]) in [Vector2, tuple]:
                    self.update_from_window(args[0], args[1])
                else:
                    raise UserWarning("The second argument must be either a sf.Vector2 or a tuple")
            else:
                self.update_from_window(args[0])

        else:
            raise UserWarning("The first argument must be either sf.Pixels, sf.Image or sf.Window")

    def update_from_pixels(self, pixels, *args):
        cdef const sf.Uint8* pixels_ptr = getPixelsPtr(memoryview(pixels))

        if not args:
            self.p_this.update(pixels_ptr)
        else:
            width, height, x, y = args
            self.p_this.update(pixels_ptr, width, height, x, y)

    def update_from_image(self, Image image, position=None):
        if not position:
            self.p_this.update(image.p_this[0])
        else:
            x, y = position
            self.p_this.update(image.p_this[0], <unsigned int>x, <unsigned int>y)

    def update_from_window(self, Window window, position=None):
        if not position:
            self.p_this.update(window.p_window[0])
        else:
            x, y = position
            self.p_this.update(window.p_window[0], <unsigned int>x, <unsigned int>y)

    @staticmethod
    def bind(Texture texture=None, sf.texture.CoordinateType coordinate_type=sf.texture.Normalized):
        if not texture:
            sf.texture.bind(NULL, coordinate_type)
        else:
            sf.texture.bind(texture.p_this, coordinate_type)

    property smooth:
        def __get__(self):
            return self.p_this.isSmooth()

        def __set__(self, bint smooth):
            self.p_this.setSmooth(smooth)

    property repeated:
        def __get__(self):
            return self.p_this.isRepeated()

        def __set__(self, bint repeated):
            self.p_this.setRepeated(repeated)

    property native_handle:
        def __get__(self):
            return self.p_this.getNativeHandle()

    @staticmethod
    def get_maximum_size():
        return sf.texture.getMaximumSize()


cdef api Texture wrap_texture(sf.Texture *p, bint d):
    cdef Texture r = Texture.__new__(Texture)
    r.p_this = p
    r.delete_this = d
    return r


cdef class Glyph:
    cdef sf.Glyph *p_this

    def __init__(self):
        self.p_this = new sf.Glyph()

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "Glyph(advance={0}, bounds={1}, texture_rectangle={2})".format(self.advance, self.bounds, self.texture_rectangle)

    property advance:
        def __get__(self):
            return self.p_this.advance

        def __set__(self, int advance):
            self.p_this.advance = advance

    property bounds:
        def __get__(self):
            return wrap_floatrect(&self.p_this.bounds)

        def __set__(self, bounds):
            self.p_this.bounds = to_floatrect(bounds)

    property texture_rectangle:
        def __get__(self):
            return wrap_intrect(&self.p_this.textureRect)

        def __set__(self, texture_rectangle):
            self.p_this.textureRect = to_intrect(texture_rectangle)

cdef Glyph wrap_glyph(sf.Glyph *p):
    cdef Glyph r = Glyph.__new__(Glyph)
    r.p_this = p
    return r

cdef class Font:
    cdef sf.Font *p_this
    cdef bint     delete_this
    cdef Texture  m_texture

    def __init__(self):
        raise UserWarning("Use a specific constructor")

    def __dealloc__(self):
        if self.delete_this: del self.p_this

    def __repr__(self):
        return "Font()"

    @classmethod
    def from_file(cls, basestring filename):
        cdef sf.Font *p = new sf.Font()

        if p.loadFromFile(filename.encode('UTF-8')):
            return wrap_font(p)

        del p
        raise IOError(popLastErrorMessage())

    @classmethod
    def from_memory(cls, bytes data):
        cdef sf.Font *p = new sf.Font()

        if p.loadFromMemory(<char*>data, len(data)):
            return wrap_font(p)

        del p
        raise IOError(popLastErrorMessage())

    def get_glyph(self, Uint32 code_point, unsigned int character_size, bint bold):
        cdef sf.Glyph *p = new sf.Glyph()
        p[0] = self.p_this.getGlyph(code_point, character_size, bold)
        return wrap_glyph(p)

    def get_kerning(self, Uint32 first, Uint32 second, unsigned int character_size):
        return self.p_this.getKerning(first, second, character_size)

    def get_line_spacing(self, unsigned int character_size):
        return self.p_this.getLineSpacing(character_size)

    def get_texture(self, unsigned int character_size):
        cdef sf.Texture *p
        p = <sf.Texture*>&self.p_this.getTexture(character_size)
        return wrap_texture(p, False)

    property info:
        def __get__(self):
            cdef sf.font.Info info
            info = self.p_this[0].getInfo()
            return info.family


cdef Font wrap_font(sf.Font *p, bint d=True):
    cdef Font r = Font.__new__(Font)
    r.p_this = p
    r.delete_this = d
    return r

cdef class Shader:
    cdef sf.Shader *p_this
    cdef bint              delete_this

    def __init__(self):
        raise UserWarning("Use a specific constructor")

    def __dealloc__(self):
        if self.delete_this: del self.p_this

    def __repr__(self):
        return "Shader()"

    @classmethod
    def from_file(cls, basestring vertex=None, basestring fragment=None):
        cdef sf.Shader *p = new sf.Shader()

        if vertex and fragment:
            if p.loadFromFile(<string>vertex.encode('UTF-8'), <string>fragment.encode('UTF-8')):
                return wrap_shader(p)
        elif vertex:
            if p.loadFromFile(<string>vertex.encode('UTF-8'), <sf.shader.Type>sf.shader.Vertex):
                return wrap_shader(p)
        elif fragment:
            if p.loadFromFile(<string>fragment.encode('UTF-8'), <sf.shader.Type>sf.shader.Fragment):
                return wrap_shader(p)
        else:
            raise TypeError("This method takes at least 1 argument (0 given)")

        del p
        raise IOError(popLastErrorMessage())

    @classmethod
    def from_memory(cls, char* vertex=NULL, char* fragment=NULL):
        cdef sf.Shader *p = new sf.Shader()

        if vertex is NULL and fragment is NULL:
            raise TypeError("This method takes at least 1 argument (0 given)")

        if vertex and fragment:
            if p.loadFromMemory(vertex, fragment):
                return wrap_shader(p)
        elif vertex:
            if p.loadFromMemory(vertex, sf.shader.Vertex):
                return wrap_shader(p)
        elif fragment:
            if p.loadFromMemory(fragment, sf.shader.Fragment):
                return wrap_shader(p)

        del p
        raise IOError(popLastErrorMessage())

    def set_parameter(self, *args, **kwargs):
        if len(args) == 0:
            raise UserWarning("No arguments provided. It requires at least one string.")

        if type(args[0]) not in [bytes, unicode, str]:
            raise UserWarning("The first argument must be a string (bytes, unicode or str)")

        if len(args) == 1:
            self.set_currenttexturetype_parameter(args[0])
        elif len(args) == 2:
            if type(args[1]) in [Vector2, tuple]:
                if type(args[1]) is Vector2:
                    self.set_vector2_paramater(args[0], args[1])
                    return
                elif len(args[1]) == 2:
                    self.set_vector2_paramater(args[0], args[1])
                elif len(args[1]) == 3:
                    self.set_vector3_paramater(args[0], args[1])
                else:
                    raise UserWarning("The second argument must be a tuple of length 2 or 3")
            elif type(args[1]) is Color:
                self.set_color_parameter(args[0], args[1])
            elif type(args[1]) is Transform:
                self.set_transform_parameter(args[0], args[1])
            elif type(args[1]) is Texture:
                self.set_texture_parameter(args[0], args[1])
            elif type(args[1]) in numeric_type:
                self.set_1float_parameter(args[0], args[1])
            else:
                raise UserWarning("The second argument type must be a number, an sf.Position, an sf.Color, an sf.Transform or an sf.Texture")
        else:
            if len(args) > 5:
                raise UserWarning("Wrong number of argument.")
            for i in range(1, len(args)):
                if type(args[i]) not in numeric_type:
                    raise UserWarning("Argument {0} must be a number".format(i+1))
            if len(args) == 3:
                self.set_2float_parameter(args[0], args[1], args[2])
            elif len(args) == 4:
                self.set_3float_parameter(args[0], args[1], args[2], args[3])
            else:
                self.set_4float_parameter(args[0], args[1], args[2], args[3], args[4])

    def set_1float_parameter(self, name, float x):
        cdef char* encoded_name

        encoded_name_temporary = name.encode('UTF-8')
        encoded_name = encoded_name_temporary

        self.p_this.setParameter(encoded_name, x)

    def set_2float_parameter(self, name, float x, float y):
        cdef char* encoded_name

        encoded_name_temporary = name.encode('UTF-8')
        encoded_name = encoded_name_temporary

        self.p_this.setParameter(encoded_name, x, y)

    def set_3float_parameter(self, name, float x, float y, float z):
        cdef char* encoded_name

        encoded_name_temporary = name.encode('UTF-8')
        encoded_name = encoded_name_temporary

        self.p_this.setParameter(encoded_name, x, y, z)

    def set_4float_parameter(self, name, float x, float y, float z, float w):
        cdef char* encoded_name

        encoded_name_temporary = name.encode('UTF-8')
        encoded_name = encoded_name_temporary

        self.p_this.setParameter(encoded_name, x, y, z, w)

    def set_vector2_paramater(self, name, vector):
        cdef char* encoded_name

        encoded_name_temporary = name.encode('UTF-8')
        encoded_name = encoded_name_temporary

        x, y = vector
        self.p_this.setParameter(encoded_name, sf.Vector2f(x, y))

    def set_vector3_paramater(self, name, vector):
        cdef char* encoded_name

        encoded_name_temporary = name.encode('UTF-8')
        encoded_name = encoded_name_temporary

        x, y, z = vector
        self.p_this.setParameter(encoded_name, sf.Vector3f(x, y, z))

    def set_color_parameter(self, name, Color color):
        cdef char* encoded_name

        encoded_name_temporary = name.encode('UTF-8')
        encoded_name = encoded_name_temporary

        self.p_this.setParameter(encoded_name, color.p_this[0])

    def set_transform_parameter(self, name, Transform transform):
        cdef char* encoded_name

        encoded_name_temporary = name.encode('UTF-8')
        encoded_name = encoded_name_temporary

        self.p_this.setParameter(encoded_name, transform.p_this[0])

    def set_texture_parameter(self, name, Texture texture):
        cdef char* encoded_name

        encoded_name_temporary = name.encode('UTF-8')
        encoded_name = encoded_name_temporary

        self.p_this.setParameter(encoded_name, texture.p_this[0])

    def set_currenttexturetype_parameter(self, name):
        cdef char* encoded_name

        encoded_name_temporary = name.encode('UTF-8')
        encoded_name = encoded_name_temporary

        self.p_this.setParameter(encoded_name, sf.shader.CurrentTexture)

    @staticmethod
    def bind(Shader shader=None):
        if not shader:
            sf.shader.bind(NULL)
        else:
            sf.shader.bind(shader.p_this)

    @staticmethod
    def is_available():
        return sf.shader.isAvailable()


cdef Shader wrap_shader(sf.Shader *p, bint d=True):
    cdef Shader r = Shader.__new__(Shader)
    r.p_this = p
    r.delete_this = d
    return r


cdef public class RenderStates[type PyRenderStatesType, object PyRenderStatesObject]:
    DEFAULT = wrap_renderstates(<sf.RenderStates*>&sf.renderstates.Default, False)

    cdef sf.RenderStates *p_this
    cdef bint                    delete_this
    cdef Transform               m_transform
    cdef Texture                 m_texture
    cdef Shader                  m_shader

    def __init__(self, BlendMode blendmode=BLEND_ALPHA, Transform transform=None, Texture texture=None, Shader shader=None):
        self.p_this = new sf.RenderStates()

        self.m_transform = wrap_transform(&self.p_this.transform, False)
        self.m_texture = None
        self.m_shader = None

        self.blendmode = blendmode
        if transform:
            self.transform = transform

        if texture:
            self.texture = texture

        if shader:
            self.shader = shader

    def __dealloc__(self):
        if self.delete_this:
            del self.p_this

    def __repr__(self):
        return "RenderStates(blendmode={0}, transform={1}, texture={2}, shader={3})".format(id(self.blendmode), id(self.transform), id(self.texture), id(self.shader))

    property blendmode:
        def __get__(self):
            return wrap_blendmode(&self.p_this.blendMode)

        def __set__(self, BlendMode blendmode):
            self.p_this.blendMode = blendmode.p_this[0]

    property transform:
        def __get__(self):
            return self.m_transform

        def __set__(self, Transform transform):
            self.p_this.transform = transform.p_this[0]

    property texture:
        def __get__(self):
            return self.m_texture

        def __set__(self, Texture texture):
            self.p_this.texture = texture.p_this
            self.m_texture = texture

    property shader:
        def __get__(self):
            return self.m_shader

        def __set__(self, Shader shader):
            self.p_this.shader = shader.p_this
            self.m_shader = shader

cdef api RenderStates wrap_renderstates(sf.RenderStates *p, bint d):
    cdef RenderStates r = RenderStates.__new__(RenderStates)
    r.p_this = p
    r.delete_this = d

    r.m_transform = wrap_transform(&p.transform, False)
    if p.texture:
        r.m_texture = wrap_texture(<sf.Texture*>p.texture, False)
    else:
        r.m_texture = None
    if p.shader:
        r.m_shader = wrap_shader(<sf.Shader*>p.shader, False)
    else:
        r.m_shader = None

    return r

cdef public class Drawable[type PyDrawableType, object PyDrawableObject]:
    cdef sf.Drawable *p_drawable

    def __init__(self, *args, **kwargs):
        if self.__class__ == Drawable:
            raise NotImplementedError('Drawable is abstact')

        if self.p_drawable is NULL:
            self.p_drawable = <sf.Drawable*>new DerivableDrawable(self)

    def __dealloc__(self):
        if self.p_drawable is not NULL:
            del self.p_drawable

    def draw(self, RenderTarget target, RenderStates states):
        pass

cdef class Transformable:
    cdef sf.Transformable *p_this

    def __cinit__(self):
        self.p_this = new sf.Transformable()

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "Transformable(position={0}, rotation={1}, ratio={2}, origin={3})".format(self.position, self.rotation, self.ratio, self.origin)

    property position:
        def __get__(self):
            return Vector2(self.p_this.getPosition().x, self.p_this.getPosition().y)

        def __set__(self, position):
            self.p_this.setPosition(to_vector2f(position))

    property rotation:
        def __get__(self):
            return self.p_this.getRotation()

        def __set__(self, float angle):
            self.p_this.setRotation(angle)

    property ratio:
        def __get__(self):
            return Vector2(self.p_this.getScale().x, self.p_this.getScale().y)

        def __set__(self, factor):
            self.p_this.setScale(to_vector2f(factor))

    property origin:
        def __get__(self):
            return Vector2(self.p_this.getOrigin().x, self.p_this.getOrigin().y)

        def __set__(self, origin):
            self.p_this.setOrigin(to_vector2f(origin))

    def move(self, offset):
        self.p_this.move(to_vector2f(offset))

    def rotate(self, float angle):
        self.p_this.rotate(angle)

    def scale(self, factor):
        self.p_this.scale(to_vector2f(factor))

    property transform:
        def __get__(self):
            cdef sf.Transform *p = new sf.Transform()
            p[0] = self.p_this.getTransform()
            return wrap_transform(p)

    property inverse_transform:
        def __get__(self):
            cdef sf.Transform *p = new sf.Transform()
            p[0] = self.p_this.getInverseTransform()
            return wrap_transform(p)

cdef Transformable wrap_transformable(sf.Transformable *p):
    cdef Transformable r = Transformable.__new__(Transformable)
    r.p_this = p
    return r

cdef public class TransformableDrawable(Drawable)[type PyTransformableDrawableType, object PyTransformableDrawableObject]:
    cdef sf.Transformable *p_transformable

    def __init__(self, *args, **kwargs):
        if self.__class__ == TransformableDrawable:
            raise NotImplementedError('TransformableDrawable is not meant to be used')

    def __repr__(self):
        return "TransformableDrawable(position={0}, rotation={1}, ratio={2}, origin={3})".format(self.position, self.rotation, self.ratio, self.origin)

    property position:
        def __get__(self):
            return Vector2(self.p_transformable.getPosition().x, self.p_transformable.getPosition().y)

        def __set__(self, position):
            self.p_transformable.setPosition(to_vector2f(position))

    property rotation:
        def __get__(self):
            return self.p_transformable.getRotation()

        def __set__(self, float angle):
            self.p_transformable.setRotation(angle)

    property ratio:
        def __get__(self):
            return Vector2(self.p_transformable.getScale().x, self.p_transformable.getScale().y)

        def __set__(self, factor):
            self.p_transformable.setScale(to_vector2f(factor))

    property origin:
        def __get__(self):
            return Vector2(self.p_transformable.getOrigin().x, self.p_transformable.getOrigin().y)

        def __set__(self, origin):
            self.p_transformable.setOrigin(to_vector2f(origin))

    def move(self, offset):
        self.p_transformable.move(to_vector2f(offset))

    def rotate(self, float angle):
        self.p_transformable.rotate(angle)

    def scale(self, factor):
        self.p_transformable.scale(to_vector2f(factor))

    property transform:
        def __get__(self):
            cdef sf.Transform *p = new sf.Transform()
            p[0] = self.p_transformable.getTransform()
            return wrap_transform(p)

    property inverse_transform:
        def __get__(self):
            cdef sf.Transform *p = new sf.Transform()
            p[0] = self.p_transformable.getInverseTransform()
            return wrap_transform(p)

    property transformable:
        def __get__(self):
            return wrap_transformable(self.p_transformable)


cdef public class Sprite(TransformableDrawable)[type PySpriteType, object PySpriteObject]:
    cdef sf.Sprite *p_this
    cdef Texture    m_texture

    def __init__(self, Texture texture, rectangle=None):
        if self.p_this is NULL:
            if not rectangle:
                self.p_this = new sf.Sprite(texture.p_this[0])
            else:
                l, t, w, h = rectangle
                self.p_this = new sf.Sprite(texture.p_this[0], sf.IntRect(l, t, w, h))

            self.p_drawable = <sf.Drawable*>self.p_this
            self.p_transformable = <sf.Transformable*>self.p_this

            self.m_texture = texture

    def __dealloc__(self):
        self.p_drawable = NULL
        self.p_transformable = NULL

        if self.p_this is not NULL:
            del self.p_this

    def __repr__(self):
        return "Sprite(texture={0}, texture_rectangle={1}, color={2})".format(id(self.texture), self.texture_rectangle, self.color)

    property texture:
        def __get__(self):
            return self.m_texture

        def __set__(self, Texture texture):
            self.p_this.setTexture(texture.p_this[0], True)
            self.m_texture = texture

    property texture_rectangle:
        def __get__(self):
            return wrap_intrect(<sf.IntRect*>(&self.p_this.getTextureRect()))

        def __set__(self, rectangle):
            self.p_this.setTextureRect(to_intrect(rectangle))

    property color:
        def __get__(self):
            cdef sf.Color* p = new sf.Color()
            p[0] = self.p_this.getColor()
            return wrap_color(p)

        def __set__(self, Color color):
            self.p_this.setColor(color.p_this[0])

    property local_bounds:
        def __get__(self):
            cdef sf.FloatRect p = self.p_this.getLocalBounds()
            return wrap_floatrect(&p)

    property global_bounds:
        def __get__(self):
            cdef sf.FloatRect p = self.p_this.getGlobalBounds()
            return wrap_floatrect(&p)


class Style(IntEnum):
    REGULAR    = sf.text.Regular
    BOLD       = sf.text.Bold
    ITALIC     = sf.text.Italic
    UNDERLINED = sf.text.Underlined
    STRIKE_THROUGH = sf.text.StrikeThrough

cdef class Text(TransformableDrawable):
    cdef sf.Text *p_this
    cdef Font     m_font

    def __init__(self, unicode string=None, Font font=None, unsigned int character_size=30):
        if self.p_this is NULL:
            self.p_this = new sf.Text()
            self.p_drawable = <sf.Drawable*>self.p_this
            self.p_transformable = <sf.Transformable*>self.p_this

            if string:
                self.string = string
            if font:
                self.font = font

            self.character_size = character_size

    def __dealloc__(self):
        self.p_drawable = NULL
        self.p_transformable = NULL

        if self.p_this is not NULL:
            del self.p_this

    def __repr__(self):
        return "Text(string={0}, font={1}, character_size={2}, style={3}, color={4})".format(self.string[:10], id(self.font), self.character_size, self.style, self.color)

    property string:
        def __get__(self):
            return wrap_string(&self.p_this.getString())

        def __set__(self, unicode string):
            self.p_this.setString(to_string(string))

    property font:
        def __get__(self):
            return self.m_font

        def __set__(self, Font font):
            self.p_this.setFont(font.p_this[0])
            self.m_font = font

    property character_size:
        def __get__(self):
            return self.p_this.getCharacterSize()

        def __set__(self, unsigned int size):
            self.p_this.setCharacterSize(size)

    property style:
        def __get__(self):
            return self.p_this.getStyle()

        def __set__(self, Uint32 style):
            self.p_this.setStyle(style)

    property color:
        def __get__(self):
            cdef sf.Color* p = new sf.Color()
            p[0] = self.p_this.getColor()
            return wrap_color(p)

        def __set__(self, Color color):
            self.p_this.setColor(color.p_this[0])

    property local_bounds:
        def __get__(self):
            cdef sf.FloatRect p = self.p_this.getLocalBounds()
            return wrap_floatrect(&p)

    property global_bounds:
        def __get__(self):
            cdef sf.FloatRect p = self.p_this.getGlobalBounds()
            return wrap_floatrect(&p)

    def find_character_pos(self, size_t index):
        cdef sf.Vector2f p = self.p_this.findCharacterPos(index)
        return Vector2(p.x, p.y)


cdef public class Shape(TransformableDrawable)[type PyShapeType, object PyShapeObject]:
    cdef sf.Shape *p_shape
    cdef Texture   m_texture

    def __init__(self, *args, **kwargs):
        if self.__class__ == Shape:
            raise NotImplementedError('Shape is abstact')

    def __dealloc__(self):
        self.p_drawable = NULL
        self.p_transformable = NULL

    property texture:
        def __get__(self):
            return self.m_texture

        def __set__(self, Texture texture):
            if texture:
                self.p_shape.setTexture(texture.p_this, True)
                self.m_texture = texture
            else:
                self.p_shape.setTexture(NULL)
                self.m_texture = None

    property texture_rectangle:
        def __get__(self):
            return wrap_intrect(<sf.IntRect*>(&self.p_shape.getTextureRect()))

        def __set__(self, rectangle):
            self.p_shape.setTextureRect(to_intrect(rectangle))

    property fill_color:
        def __get__(self):
            cdef sf.Color* p = new sf.Color()
            p[0] = self.p_shape.getFillColor()
            return wrap_color(p)

        def __set__(self, Color color):
            self.p_shape.setFillColor(color.p_this[0])

    property outline_color:
        def __get__(self):
            cdef sf.Color* p = new sf.Color()
            p[0] = self.p_shape.getOutlineColor()
            return wrap_color(p)

        def __set__(self, Color color):
            self.p_shape.setOutlineColor(color.p_this[0])

    property outline_thickness:
        def __get__(self):
            return self.p_shape.getOutlineThickness()

        def __set__(self, float thickness):
            self.p_shape.setOutlineThickness(thickness)

    property local_bounds:
        def __get__(self):
            cdef sf.FloatRect p = self.p_shape.getLocalBounds()
            return wrap_floatrect(&p)

    property global_bounds:
        def __get__(self):
            cdef sf.FloatRect p = self.p_shape.getGlobalBounds()
            return wrap_floatrect(&p)

    property point_count:
        def __get__(self):
            return self.p_shape.getPointCount()

    def get_point(self, unsigned int index):
        return Vector2(self.p_shape.getPoint(index).x, self.p_shape.getPoint(index).y)


cdef class CircleShape(Shape):
    cdef sf.CircleShape *p_this

    def __init__(self, float radius=0, unsigned int point_count=30):
        if self.p_this is NULL:
            self.p_this = new sf.CircleShape(radius, point_count)

            self.p_drawable = <sf.Drawable*>self.p_this
            self.p_transformable = <sf.Transformable*>self.p_this
            self.p_shape = <sf.Shape*>self.p_this

    def __dealloc__(self):
        self.p_shape = NULL

        if self.p_this is not NULL:
            del self.p_this

    def __repr__(self):
        return "CircleShape(texture={0}, texture_rectangle={1}, fill_color={2}, outline_color={3}, outline_thickness={4}, radius={5}, point_count={6})".format(id(self.texture), self.texture_rectangle, self.fill_color, self.outline_color, self.outline_thickness, self.radius, self.point_count)

    property radius:
        def __get__(self):
            return self.p_this.getRadius()

        def __set__(self, float radius):
            self.p_this.setRadius(radius)

    property point_count:
        def __get__(self):
            return self.p_this.getPointCount()

        def __set__(self, unsigned int count):
            self.p_this.setPointCount(count)

cdef public class ConvexShape(Shape)[type PyConvexShapeType, object PyConvexShapeObject]:
    cdef sf.ConvexShape *p_this

    def __init__(self, unsigned int point_count=0):
        if self.p_this is NULL:
            self.p_this = new sf.ConvexShape(point_count)

            self.p_drawable = <sf.Drawable*>self.p_this
            self.p_transformable = <sf.Transformable*>self.p_this
            self.p_shape = <sf.Shape*>self.p_this

    def __dealloc__(self):
        self.p_shape = NULL

        if self.p_this is not NULL:
            del self.p_this

    def __repr__(self):
        return "ConvexShape(texture={0}, texture_rectangle={1}, fill_color={2}, outline_color={3}, outline_thickness={4}, point_count={5})".format(id(self.texture), self.texture_rectangle, self.fill_color, self.outline_color, self.outline_thickness, self.point_count)

    property point_count:
        def __get__(self):
            return self.p_this.getPointCount()

        def __set__(self, unsigned int count):
            self.p_this.setPointCount(count)

    def set_point(self, unsigned int index, point):
        self.p_this.setPoint(index, to_vector2f(point))


cdef api object wrap_convexshape(sf.ConvexShape *p):
    cdef ConvexShape r = ConvexShape.__new__(ConvexShape)
    r.p_this = p
    r.p_drawable = <sf.Drawable*>p
    r.p_transformable = <sf.Transformable*>p
    r.p_shape = <sf.Shape*>p

    return r

cdef class RectangleShape(Shape):
    cdef sf.RectangleShape *p_this

    def __init__(self, size=(0, 0)):
        if self.p_this is NULL:
            self.p_this = new sf.RectangleShape(to_vector2f(size))

            self.p_drawable = <sf.Drawable*>self.p_this
            self.p_transformable = <sf.Transformable*>self.p_this
            self.p_shape = <sf.Shape*>self.p_this

    def __dealloc__(self):
        self.p_shape = NULL

        if self.p_this is not NULL:
            del self.p_this

    def __repr__(self):
        return "RectangleShape(texture={0}, texture_rectangle={1}, fill_color={2}, outline_color={3}, outline_thickness={4}, size={5}, point_count={6})".format(id(self.texture), self.texture_rectangle, self.fill_color, self.outline_color, self.outline_thickness, self.size, self.point_count)

    property size:
        def __get__(self):
            return Vector2(self.p_this.getSize().x, self.p_this.getSize().y)

        def __set__(self, size):
            self.p_this.setSize(to_vector2f(size))

    property point_count:
        def __get__(self):
            return self.p_this.getPointCount()

cdef class Vertex:
    cdef sf.Vertex *p_this
    cdef bint              delete_this

    def __init__(self, position=None, Color color=None, tex_coords=None):
        self.p_this = new sf.Vertex()
        self.delete_this = True

        if position:
            self.position = position

        if color:
            self.color = color

        if tex_coords:
            self.tex_coords = tex_coords

    def __dealloc__(self):
        if self.delete_this:
            del self.p_this

    def __repr__(self):
        return "Vertex(position={0}, color={1}, tex_coords={2})".format(self.position, self.color, self.tex_coords)

    property position:
        def __get__(self):
            return Vector2(self.p_this.position.x, self.p_this.position.y)

        def __set__(self, position):
            self.p_this.position.x, self.p_this.position.y = position

    property color:
        def __get__(self):
            cdef sf.Color *p = new sf.Color()
            p[0] = self.p_this.color
            return wrap_color(p)

        def __set__(self, Color color):
            self.p_this.color = color.p_this[0]

    property tex_coords:
        def __get__(self):
            return Vector2(self.p_this.texCoords.x, self.p_this.texCoords.y)

        def __set__(self, tex_coords):
            self.p_this.texCoords.x, self.p_this.texCoords.y = tex_coords

cdef Vertex wrap_vertex(sf.Vertex* p, bint d=True):
    cdef Vertex r = Vertex.__new__(Vertex)
    r.p_this = p
    r.delete_this = d
    return r


cdef class VertexArray(Drawable):
    cdef sf.VertexArray *p_this

    def __init__(self, sf.primitivetype.PrimitiveType type = sf.primitivetype.Points, unsigned int vertex_count=0):
        if self.p_this is NULL:
            self.p_this = new sf.VertexArray(type, vertex_count)
            self.p_drawable = <sf.Drawable*>self.p_this

    def __dealloc__(self):
        self.p_drawable = NULL

        if self.p_this is not NULL:
            del self.p_this

    def __repr__(self):
        return "VertexArray(length={0}, primitive_type={1}, bounds={2})".format(len(self), self.primitive_type, self.bounds)

    def __len__(self):
        return self.p_this.getVertexCount()

    def __getitem__(self, unsigned int index):
        if index < len(self):
            return wrap_vertex(&self.p_this[0][index], False)
        else:
            raise IndexError

    def __setitem__(self, unsigned int index, Vertex key):
        self.p_this[0][index] = key.p_this[0]

    def clear(self):
        self.p_this.clear()

    def resize(self, unsigned int vertex_count):
        self.p_this.resize(vertex_count)

    def append(self, Vertex vertex):
        self.p_this.append(vertex.p_this[0])

    property primitive_type:
        def __get__(self):
            return self.p_this.getPrimitiveType()

        def __set__(self, sf.primitivetype.PrimitiveType primitive_type):
            self.p_this.setPrimitiveType(primitive_type)

    property bounds:
        def __get__(self):
            cdef sf.FloatRect p = self.p_this.getBounds()
            return wrap_floatrect(&p)


cdef class View:
    cdef sf.View      *p_this
    cdef RenderWindow  m_renderwindow
    cdef RenderTarget  m_rendertarget

    def __init__(self, rectangle=None):
        if not rectangle:
            self.p_this = new sf.View()
        else:
            self.p_this = new sf.View(to_floatrect(rectangle))

    def __dealloc__(self):
        del self.p_this

    def __repr__(self):
        return "View(center={0}, size={1}, rotation={2}, viewport={3})".format(self.center, self.size, self.rotation, self.viewport)

    property center:
        def __get__(self):
            return Vector2(self.p_this.getCenter().x, self.p_this.getCenter().y)

        def __set__(self, center):
            self.p_this.setCenter(to_vector2f(center))
            self._update_target()

    property size:
        def __get__(self):
            return Vector2(self.p_this.getSize().x, self.p_this.getSize().y)

        def __set__(self, size):
            self.p_this.setSize(to_vector2f(size))
            self._update_target()

    property rotation:
        def __get__(self):
            return self.p_this.getRotation()

        def __set__(self, float angle):
            self.p_this.setRotation(angle)
            self._update_target()

    property viewport:
        def __get__(self):
            return wrap_floatrect(<sf.FloatRect*>(&self.p_this.getViewport()))

        def __set__(self, viewport):
            self.p_this.setViewport(to_floatrect(viewport))
            self._update_target()

    def reset(self, rectangle):
        self.p_this.reset(to_floatrect(rectangle))
        self._update_target()

    def move(self, float x, float y):
        self.p_this.move(sf.Vector2f(x, y))
        self._update_target()

    def rotate(self, float angle):
        self.p_this.rotate(angle)
        self._update_target()

    def zoom(self, float factor):
        self.p_this.zoom(factor)
        self._update_target()

    property transform:
        def __get__(self):
            cdef sf.Transform *p = new sf.Transform()
            p[0] = self.p_this.getTransform()
            return wrap_transform(p)

    property inverse_transform:
        def __get__(self):
            cdef sf.Transform *p = new sf.Transform()
            p[0] = self.p_this.getInverseTransform()
            return wrap_transform(p)

    def _update_target(self):
        if self.m_renderwindow:
            self.m_renderwindow.view = self

        if self.m_rendertarget:
            self.m_rendertarget.view = self

cdef View wrap_view(sf.View *p):
    cdef View r = View.__new__(View)
    r.p_this = p
    return r

cdef View wrap_view_for_renderwindow(sf.View *p, RenderWindow renderwindow):
    cdef View r = View.__new__(View)
    r.p_this = p
    r.m_renderwindow = renderwindow
    return r

cdef View wrap_view_for_rendertarget(sf.View *p, RenderTarget rendertarget):
    cdef View r = View.__new__(View)
    r.p_this = p
    r.m_rendertarget = rendertarget
    return r


cdef public class RenderTarget[type PyRenderTargetType, object PyRenderTargetObject]:
    cdef sf.RenderTarget *p_rendertarget

    def __init__(self, *args, **kwargs):
        if self.__class__ == RenderTarget:
            raise NotImplementedError('RenderTarget is abstact')

    def clear(self, Color color=None):
        if not color:
            self.p_rendertarget.clear()
        else:
            self.p_rendertarget.clear(color.p_this[0])

    property view:
        def __get__(self):
            cdef sf.View *p = new sf.View()
            p[0] = self.p_rendertarget.getView()
            return wrap_view_for_rendertarget(p, self)

        def __set__(self, View view):
            self.p_rendertarget.setView(view.p_this[0])
            view.m_renderwindow = None
            view.m_rendertarget = self

    property default_view:
        def __get__(self):
            cdef sf.View *p = new sf.View()
            p[0] = self.p_rendertarget.getDefaultView()
            return wrap_view_for_rendertarget(p, self)

    def get_viewport(self, View view):
        cdef sf.IntRect p = self.p_rendertarget.getViewport(view.p_this[0])
        return wrap_intrect(&p)

    def map_pixel_to_coords(self, point, View view=None):
        cdef sf.Vector2f ret

        if not view:
            ret = self.p_rendertarget.mapPixelToCoords(to_vector2i(point))
        else:
            ret = self.p_rendertarget.mapPixelToCoords(to_vector2i(point), view.p_this[0])

        return Vector2(ret.x, ret.y)

    def map_coords_to_pixel(self, point, View view=None):
        cdef sf.Vector2i ret

        if not view:
            ret = self.p_rendertarget.mapCoordsToPixel(to_vector2f(point))
        else:
            ret = self.p_rendertarget.mapCoordsToPixel(to_vector2f(point), view.p_this[0])

        return Vector2(ret.x, ret.y)

    def draw(self, Drawable drawable, RenderStates states=None):
        if not states:
            self.p_rendertarget.draw(drawable.p_drawable[0])
        else:
            self.p_rendertarget.draw(drawable.p_drawable[0], states.p_this[0])

    property size:
        def __get__(self):
            return Vector2(self.p_rendertarget.getSize().x, self.p_rendertarget.getSize().y)

    property width:
        def __get__(self):
            return self.size.x

    property height:
        def __get__(self):
            return self.size.y

    def push_GL_states(self):
        self.p_rendertarget.pushGLStates()

    def pop_GL_states(self):
        self.p_rendertarget.popGLStates()

    def reset_GL_states(self):
        self.p_rendertarget.resetGLStates()


cdef api object wrap_rendertarget(sf.RenderTarget* p):
    cdef RenderTarget r = RenderTarget.__new__(RenderTarget)
    r.p_rendertarget = p
    return r


cdef class RenderWindow(Window):
    cdef sf.RenderWindow *p_this

    def __init__(self, VideoMode mode, unicode title, Uint32 style=sf.style.Default, ContextSettings settings=ContextSettings()):
        if self.p_this == NULL:
            self.p_this = <sf.RenderWindow*>new DerivableRenderWindow(self)
            self.p_this.create(mode.p_this[0], to_string(title), style, settings.p_this[0])
            self.p_window = <sf.Window*>self.p_this

    def __dealloc__(self):
        self.p_window = NULL
        if self.p_this != NULL:
            del self.p_this

    def __repr__(self):
        return "RenderWindow(position={0}, size={1}, is_open={2})".format(self.position, self.size, self.is_open)

    def clear(self, Color color=None):
        if not color:
            self.p_this.clear()
        else:
            self.p_this.clear(color.p_this[0])

    property view:
        def __get__(self):
            cdef sf.View *p = new sf.View()
            p[0] = self.p_this.getView()
            return wrap_view_for_renderwindow(p, self)

        def __set__(self, View view):
            self.p_this.setView(view.p_this[0])
            view.m_renderwindow = self
            view.m_rendertarget = None

    property default_view:
        def __get__(self):
            cdef sf.View *p = new sf.View()
            p[0] = self.p_this.getDefaultView()
            return wrap_view_for_renderwindow(p, self)

    def get_viewport(self, View view):
        cdef sf.IntRect p = self.p_this.getViewport(view.p_this[0])
        return wrap_intrect(&p)

    def map_pixel_to_coords(self, point, View view=None):
        cdef sf.Vector2f ret

        if not view:
            ret = self.p_this.mapPixelToCoords(to_vector2i(point))
        else:
            ret = self.p_this.mapPixelToCoords(to_vector2i(point), view.p_this[0])

        return Vector2(ret.x, ret.y)

    def map_coords_to_pixel(self, point, View view=None):
        cdef sf.Vector2i ret

        if not view:
            ret = self.p_this.mapCoordsToPixel(to_vector2f(point))
        else:
            ret = self.p_this.mapCoordsToPixel(to_vector2f(point), view.p_this[0])

        return Vector2(ret.x, ret.y)

    def draw(self, Drawable drawable, RenderStates states=None):
        if not states:
            self.p_this.draw(drawable.p_drawable[0])
        else:
            self.p_this.draw(drawable.p_drawable[0], states.p_this[0])

    def push_GL_states(self):
        self.p_this.pushGLStates()

    def pop_GL_states(self):
        self.p_this.popGLStates()

    def reset_GL_states(self):
        self.p_this.resetGLStates()

    def capture(self):
        cdef sf.Image *p = new sf.Image()
        p[0] = self.p_this.capture()
        return wrap_image(p)

    def on_create(self):
        (<DerivableRenderWindow*>self.p_this).createWindow()

    def on_resize(self):
        (<DerivableRenderWindow*>self.p_this).resizeWindow()

cdef class RenderTexture(RenderTarget):
    cdef sf.RenderTexture *p_this
    cdef Texture m_texture

    def __init__(self, unsigned int width, unsigned int height, bint depthBuffer=False):
        if self.p_this is NULL:
            self.p_this = new sf.RenderTexture()
            self.p_rendertarget = <sf.RenderTarget*>self.p_this

            self.p_this.create(width, height, depthBuffer)

            self.m_texture = wrap_texture(<sf.Texture*>&self.p_this.getTexture(), False)

    def __dealloc__(self):
        self.p_rendertarget = NULL

        if self.p_this is not NULL:
            del self.p_this

    def __repr__(self):
        return "RenderTexture(size={0}, smooth={1}, repeated={2})".format(self.size, self.smooth, self.repeated)

    property smooth:
        def __get__(self):
            return self.p_this.isSmooth()

        def __set__(self, bint smooth):
            self.p_this.setSmooth(smooth)

    property repeated:
        def __get__(self):
            return self.p_this.isRepeated()

        def __set__(self, bint repeated):
            self.p_this.setRepeated(repeated)

    property active:
        def __set__(self, bint active):
            self.p_this.setActive(active)

    def display(self):
        self.p_this.display()

    property texture:
        def __get__(self):
            return self.m_texture

cdef class HandledWindow(RenderTarget):
    cdef sf.RenderWindow *p_this
    cdef sf.Window *p_window

    def __init__(self):
        if self.p_this is NULL:
            self.p_this = new sf.RenderWindow()
            self.p_rendertarget = <sf.RenderTarget*>self.p_this
            self.p_window = <sf.Window*>self.p_this

    def __dealloc__(self):
        self.p_rendertarget = NULL

        if self.p_this is not NULL:
            del self.p_this

    def create(self, unsigned long window_handle, ContextSettings settings=None):
        if not settings:
            self.p_this.create(<sf.WindowHandle>window_handle)
        else:
            self.p_this.create(<sf.WindowHandle>window_handle, settings.p_this[0])

    def display(self):
        self.p_window.display()
