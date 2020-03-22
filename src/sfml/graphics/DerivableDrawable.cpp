/*
* PySFML - Python bindings for SFML
* Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
*
* This file is part of PySFML project and is available under the zlib
* license.
*/

#include <SFML/Graphics.hpp>

#include "sfml/graphics/DerivableDrawable.hpp"
#include "sfml/graphics/NumericObject.hpp"
#include "sfml/graphics/graphics_api.h"

const sf::Uint8* getPixelsPtr(PyObject* memoryview)
{
    Py_buffer* buffer = PyMemoryView_GET_BUFFER(memoryview);
    return static_cast<const sf::Uint8*>(buffer->buf);
}

DerivableDrawable::DerivableDrawable(PyObject* object) :
m_object(object)
{
    import_sfml__graphics();
};

void DerivableDrawable::draw(sf::RenderTarget& target_, sf::RenderStates states_) const
{
    static char format[] = "(O, O)";
    static char methodName[] = "draw";

    PyObject* target = (PyObject*)(wrap_rendertarget(&target_));
    PyObject* states = (PyObject*)(wrap_renderstates(&states_, false));

    PyObject* success = PyObject_CallMethod(m_object, methodName, format, target, states);

    if(!success)
        PyErr_Print();

    Py_DECREF(target);
    Py_DECREF(states);
}
