/*
* PySFML - Python bindings for SFML
* Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
*
* This file is part of PySFML project and is available under the zlib
* license.
*/

#include "sfml/window/DerivableWindow.hpp"

DerivableWindow::DerivableWindow(PyObject* object) :
m_object(object)
{
}

void DerivableWindow::onCreate()
{
    static char method[] = "on_create";
    PyObject* success = PyObject_CallMethod(m_object, method, NULL);

    if(!success)
        PyErr_Print();
}

void DerivableWindow::onResize()
{
    static char method[] = "on_resize";
    PyObject* success = PyObject_CallMethod(m_object, method, NULL);

    if(!success)
        PyErr_Print();
}
