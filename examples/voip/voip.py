#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# pySFML - Python bindings for SFML
# Copyright 2012-2013, Jonathan De Wachter <dewachter.jonathan@gmail.com>
#
# This software is released under the LGPLv3 license.
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import client, server

# python 2.* compatability
try: input = raw_input
except NameError: pass

# choose a random port for opening sockets (ports < 1024 are reserved)
PORT = 2435

# client or server ?
print("Do you want to be a server (s) or a client (c) ?")
who = input()

if who == 's':
	server.do_server(PORT)
else:
	client.do_client(PORT)

input("Press any key to exit...")
