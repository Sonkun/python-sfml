/*
* PySFML - Python bindings for SFML
* Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
*
* This file is part of PySFML project and is available under the zlib
* license.
*/

#include "sfml/audio/DerivableSoundStream.hpp"

DerivableSoundStream::DerivableSoundStream(void* pyobj):
sf::SoundStream (),
m_pyobj         (static_cast<PyObject*>(pyobj))
{
    PyEval_InitThreads();
    import_sfml__system();
    import_sfml__audio();
};

void DerivableSoundStream::initialize(unsigned int channelCount, unsigned int sampleRate)
{
    sf::SoundStream::initialize(channelCount, sampleRate);
}

bool DerivableSoundStream::onGetData(sf::SoundStream::Chunk &data)
{
    PyGILState_STATE gstate;
    gstate = PyGILState_Ensure();

    static char method[] = "on_get_data";
    static char format[] = "O";

    PyObject* pyChunk = (PyObject*)(create_chunk());
    PyObject* r = PyObject_CallMethod(m_pyobj, method, format, pyChunk);

    if(!r)
        PyErr_Print();

    data.samples = static_cast<const sf::Int16*>(terminate_chunk(pyChunk));
    data.sampleCount = PyObject_Length(pyChunk);

    Py_DECREF(pyChunk);

    PyGILState_Release(gstate);

    return PyObject_IsTrue(r);
}

void DerivableSoundStream::onSeek(sf::Time timeOffset)
{
    PyGILState_STATE gstate;
    gstate = PyGILState_Ensure();

    static char method[] = "on_seek";
    static char format[] = "O";

    sf::Time* copyTimeOffset = new sf::Time;
    *copyTimeOffset = timeOffset;

    PyObject* pyTime = (PyObject*)(wrap_time(copyTimeOffset));
    PyObject* success = PyObject_CallMethod(m_pyobj, method, format, pyTime);

    if(!success)
        PyErr_Print();

    Py_DECREF(pyTime);

    PyGILState_Release(gstate);
}

