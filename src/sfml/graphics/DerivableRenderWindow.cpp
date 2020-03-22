/*
* PySFML - Python bindings for SFML
* Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
*
* This file is part of PySFML project and is available under the zlib
* license.
*/

#include "sfml/graphics/DerivableRenderWindow.hpp"

DerivableRenderWindow::DerivableRenderWindow(PyObject* object) :
m_object(object)
{
}

void DerivableRenderWindow::createWindow()
{
    sf::RenderWindow::onCreate();
}

void DerivableRenderWindow::resizeWindow()
{
    sf::RenderWindow::onResize();
}

void DerivableRenderWindow::onCreate()
{
    static char method[] = "on_create";
    PyObject* success = PyObject_CallMethod(m_object, method, NULL);

    if(!success)
        PyErr_Print();
}

void DerivableRenderWindow::onResize()
{
    static char method[] = "on_resize";
    PyObject* success = PyObject_CallMethod(m_object, method, NULL);

    if(!success)
        PyErr_Print();
}
