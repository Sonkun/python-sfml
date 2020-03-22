/*
* PySFML - Python bindings for SFML
* Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
*
* This file is part of PySFML project and is available under the zlib
* license.
*/

#ifndef PYSFML_AUDIO_DERIVABLESOUNDRECORDER_HPP
#define PYSFML_AUDIO_DERIVABLESOUNDRECORDER_HPP

#include "Python.h"
#include <SFML/Audio.hpp>
#include "sfml/audio/audio_api.h"

class DerivableSoundRecorder : public sf::SoundRecorder
{
public :
    DerivableSoundRecorder(void* pyThis);

protected:
    virtual bool onStart();
    virtual bool onProcessSamples(const sf::Int16* samples, std::size_t sampleCount);
    virtual void onStop();

    PyObject* m_pyobj;
};


#endif // PYSFML_AUDIO_DERIVABLESOUNDRECORDER_HPP
