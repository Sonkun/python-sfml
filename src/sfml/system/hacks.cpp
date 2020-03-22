/*
* PySFML - Python bindings for SFML
* Copyright (c) 2012-2017, Jonathan De Wachter <dewachter.jonathan@gmail.com>
*
* This file is part of PySFML project and is available under the zlib
* license.
*/

#include "hacks.hpp"

sf::Time Time_div_int(sf::Time left, sf::Int64 right)
{
    return left / right;
}

sf::Time Time_div_float(sf::Time left, float right)
{
    return left / right;
}

float Time_div_Time(sf::Time left, sf::Time right)
{
    return left / right;
}

void Time_idiv_int(sf::Time& left, sf::Int64 right)
{
    left /= right;
}

void Time_idiv_float(sf::Time& left, float right)
{
    left /= right;
}
