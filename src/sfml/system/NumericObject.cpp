/*
* PySFML - Python bindings for SFML
* Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
*
* This file is part of PySFML project and is available under the zlib
* license.
*/

#include "NumericObject.hpp"

NumericObject::NumericObject()
: m_object(NULL)
{
}

NumericObject::NumericObject(const NumericObject& copy)
{
    m_object = copy.m_object;
    Py_INCREF(m_object);
}

NumericObject::NumericObject(PyObject* object)
: m_object(object)
{
    Py_XINCREF(m_object);
}

NumericObject::~NumericObject()
{
    Py_XDECREF(m_object);
}

PyObject* NumericObject::get()
{
    Py_XINCREF(m_object);
    return m_object;
}

void NumericObject::set(PyObject* object)
{
    if (m_object)
        Py_DECREF(m_object);

    m_object = object;
    Py_INCREF(m_object);
}

NumericObject NumericObject::operator+() const
{
    return PyNumber_Positive(const_cast<PyObject*>(m_object));
}

NumericObject NumericObject::operator-() const
{
    return PyNumber_Negative(const_cast<PyObject*>(m_object));
}

NumericObject NumericObject::operator+(const NumericObject& object) const
{
    return PyNumber_Add(m_object, object.m_object);
}

NumericObject NumericObject::operator-(const NumericObject& object) const
{
    return PyNumber_Subtract(m_object, object.m_object);
}

NumericObject NumericObject::operator*(const NumericObject& object) const
{
    return PyNumber_Multiply(m_object, object.m_object);
}

NumericObject NumericObject::operator/(const NumericObject& object) const
{
    return PyNumber_TrueDivide(m_object, object.m_object);
}

NumericObject NumericObject::operator~() const
{
    return PyNumber_Invert(const_cast<PyObject*>(m_object));
}

NumericObject NumericObject::operator&(const NumericObject& object) const
{
    return PyNumber_And(m_object, object.m_object);
}

NumericObject NumericObject::operator|(const NumericObject& object) const
{
    return PyNumber_Or(m_object, object.m_object);
}

NumericObject NumericObject::operator^(const NumericObject& object) const
{
    return PyNumber_Xor(m_object, object.m_object);
}

NumericObject& NumericObject::operator+=(const NumericObject& b)
{
    m_object = PyNumber_InPlaceAdd(m_object, b.m_object);
    return *this;
}

NumericObject& NumericObject::operator-=(const NumericObject& b)
{
    m_object = PyNumber_InPlaceSubtract(m_object, b.m_object);
    return *this;
}

NumericObject& NumericObject::operator*=(const NumericObject& b)
{
    m_object = PyNumber_InPlaceMultiply(m_object, b.m_object);
    return *this;
}

NumericObject& NumericObject::operator/=(const NumericObject& b)
{
    m_object = PyNumber_InPlaceTrueDivide(m_object, b.m_object);
    return *this;
}

NumericObject& NumericObject::operator&=(const NumericObject& b)
{
    m_object = PyNumber_InPlaceAnd(m_object, b.m_object);
    return *this;
}

NumericObject& NumericObject::operator|=(const NumericObject& b)
{
    m_object = PyNumber_InPlaceOr(m_object, b.m_object);
    return *this;
}

NumericObject& NumericObject::operator^=(const NumericObject& b)
{
    m_object = PyNumber_InPlaceXor(m_object, b.m_object);
    return *this;
}

bool NumericObject::operator==(const NumericObject &b) const
{
    return PyObject_RichCompareBool(m_object, b.m_object, Py_EQ);
}

bool NumericObject::operator!=(const NumericObject &b) const
{
    return PyObject_RichCompareBool(m_object, b.m_object, Py_NE);
}

bool NumericObject::operator<(const NumericObject &b) const
{
    return PyObject_RichCompareBool(m_object, b.m_object, Py_LT);
}

bool NumericObject::operator>(const NumericObject &b) const
{
    return PyObject_RichCompareBool(m_object, b.m_object, Py_GT);
}

bool NumericObject::operator<=(const NumericObject &b) const
{
    return PyObject_RichCompareBool(m_object, b.m_object, Py_LE);
}

bool NumericObject::operator>=(const NumericObject &b) const
{
    return PyObject_RichCompareBool(m_object, b.m_object, Py_GE);
}
