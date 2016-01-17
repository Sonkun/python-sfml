#include "hacks.h"

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
