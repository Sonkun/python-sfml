/*
* PySFML - Python bindings for SFML
* Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
*
* This file is part of PySFML project and is available under the zlib
* license.
*/

#include <SFML/System.hpp>
#include "error.hpp"
#include <sstream>

static std::stringbuf buffer;

// Insert our own buffer to retrieve and forward errors to Python
// exceptions. This function allows to restore the Python buffer in case people
// would interface Python with C++ code and so reredirect the error output.
void restorePythonErrorBuffer()
{
    sf::err().rdbuf(&buffer);
}

// Return the last error (if any) then clear the buffer to welcome the next one.
PyObject* getLastErrorMessage()
{
    // Get the error message then clean the buffer
#if PY_MAJOR_VERSION >= 3
    PyObject* error = PyBytes_FromString(buffer.str().c_str());
#else
    PyObject* error = PyString_FromString(buffer.str().c_str());
#endif

    buffer.str("");

    return error;
}
