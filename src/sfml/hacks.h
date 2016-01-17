//------------------------------------------------------------------------------
// PySFML - Python bindings for SFML
// Copyright (c) 2012-2014, Jonathan De Wachter <dewachter.jonathan@gmail.com>
//                          Edwin Marshall <emarshall85@gmail.com>
//
// This software is provided 'as-is', without any express or implied warranty.
// In no event will the authors be held liable for any damages arising from the
// use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software in a
//    product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
//
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
//
// 3. This notice may not be removed or altered from any source distribution.
//------------------------------------------------------------------------------

#ifndef PYSFML_HACKS_HPP
#define PYSFML_HACKS_HPP

#include <Python.h>
#include <SFML/System.hpp>

#define PyString_AsString PyBytes_AsString

sf::Time Time_div_int(sf::Time left, sf::Int64 right);
sf::Time Time_div_float(sf::Time left, float right);
float Time_div_Time(sf::Time left, sf::Time right);

void Time_idiv_int(sf::Time& left, sf::Int64 right);
void Time_idiv_float(sf::Time& left, float right);

#endif // PYSFML_HACKS_HPP
