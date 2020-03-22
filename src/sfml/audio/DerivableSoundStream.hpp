/*
* PySFML - Python bindings for SFML
* Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
*
* This file is part of PySFML project and is available under the zlib
* license.
*/

#ifndef PYSFML_SYSTEM_DERIVABLESOUNDSTREAM_HPP
#define PYSFML_SYSTEM_DERIVABLESOUNDSTREAM_HPP

#include "Python.h"
#include <SFML/Audio.hpp>
#include "sfml/audio/audio_api.h"
#include "sfml/system/NumericObject.hpp"
#include "sfml/system/system_api.h"

class DerivableSoundStream : public sf::SoundStream
{
public :
    DerivableSoundStream(void* pyThis);

    void initialize(unsigned int channelCount, unsigned int sampleRate);

protected:
    virtual bool onGetData(sf::SoundStream::Chunk &data);
    virtual void onSeek(sf::Time timeOffset);

    PyObject* m_pyobj;
};

#endif // PYSFML_SYSTEM_DERIVABLESOUNDSTREAM_HPP
