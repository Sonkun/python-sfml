#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# pySFML - Python bindings for SFML
# Copyright 2012-2013, Jonathan De Wachter <dewachter.jonathan@gmail.com>,
#                 Edwin Marshall <emarshall85@gmail.com>
#
# This software is released under the LGPLv3 license.
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import sys, os, platform
import os.path, shutil
from glob import glob
from subprocess import call
from distutils.core import setup, Command, Extension

# python 2.* compatability
try: input = raw_input
except NameError: pass

# check if cython is installed somewhere
try:
	from Cython.Distutils import build_ext as _build_ext
	CYTHON_AVAILABLE = True
except ImportError:
	# on unix platforms, check if cython isn't installed in another
	# python version, then compile manually
	if platform.system() == 'Linux':
		call('cython --cplus src/sfml/system.pyx -Iinclude', shell=True)
		call('mv src/sfml/system.h include/pysfml', shell=True)
		call('mv src/sfml/system_api.h include/pysfml', shell=True)
		call('cython --cplus src/sfml/window.pyx -Iinclude', shell=True)
		call('mv src/sfml/window.h include/pysfml', shell=True)
		call('cython --cplus src/sfml/graphics.pyx -Iinclude', shell=True)
		call('mv src/sfml/graphics.h include/pysfml', shell=True)
		call('mv src/sfml/graphics_api.h include/pysfml', shell=True)
		call('cython --cplus src/sfml/audio.pyx -Iinclude', shell=True)
		call('mv src/sfml/audio_api.h include/pysfml', shell=True)
		call('cython --cplus src/sfml/network.pyx -Iinclude', shell=True)

	from distutils.command import build_ext
	CYTHON_AVAILABLE = False

# a current Cython issue prevents generate API headers from being
# generated if its cpp file exists
# by deleting its cpp file, it forces cython to generate the headers
system_h = "include/pysfml/system.h"
system_api_h = "include/pysfml/system_api.h"
if not os.path.isfile(system_h) or not os.path.isfile(system_api_h):
	try:
		os.remove("src/sfml/system.cpp")
	except OSError:
		pass

window_h = "include/pysfml/window.h"
if not os.path.isfile(window_h):
	try:
		os.remove("src/sfml/window.cpp")
	except OSError:
		pass

graphics_h = "include/pysfml/graphics.h"
graphics_api_h = "include/pysfml/graphics_api.h"
if not os.path.isfile(graphics_h) or not os.path.isfile(graphics_api_h):
	try:
		os.remove("src/sfml/graphics_api.cpp")
	except OSError:
		pass

audio_api_h = "include/pysfml/audio_api.h"
if not os.path.isfile(audio_api_h):
	try:
		os.remove("src/sfml/audio.cpp")
	except OSError:
		pass


class PyTest(Command):
	user_options = []

	def initialize_options(self): pass
	def finalize_options(self): pass
	def run(self):
		errno = call([sys.executable, 'runtests.py'])
		raise SystemExit(errno)

sources = dict(
	system = 'src/sfml/system.pyx',
	window = 'src/sfml/window.pyx',
	graphics = 'src/sfml/graphics.pyx',
	audio = 'src/sfml/audio.pyx',
	network = 'src/sfml/network.pyx')

# check if cython is needed (if c++ files are generated or not)
cpp_sources = dict(
	system = 'src/sfml/system.cpp',
	window = 'src/sfml/window.cpp',
	graphics = 'src/sfml/graphics.cpp',
	audio = 'src/sfml/audio.cpp',
	network = 'src/sfml/network.cpp')
NEED_CYTHON = not all(map(os.path.exists, cpp_sources.values()))

if NEED_CYTHON and not CYTHON_AVAILABLE:
	print("Please install cython and try again. Or use an official release with pre-generated source")
	raise SystemExit

if not CYTHON_AVAILABLE:
	sources = {k: v.replace('pyx', 'cpp') for k, v in sources.items()}

if CYTHON_AVAILABLE:
	class build_ext(_build_ext):
		""" Updated version of cython build_ext command to move
		the generated API headers to includ/pysfml directory
		"""

		def cython_sources(self, sources, extension):
			ret = _build_ext.cython_sources(self, sources, extension)

			# should result the module name; e.g, graphics[.pyx]
			module = os.path.basename(sources[0])[:-4]

			# move its headers (foo.h and foo_api.h) to include/pysfml
			destination = "include/pysfml"

			source = "src/sfml/{0}.h".format(module)
			if os.path.isfile(source):
				try:
					shutil.move(source, destination)
				except shutil.Error:
					pass

			source = "src/sfml/{0}_api.h".format(module)
			if os.path.isfile(source):
				try:
					shutil.move(source, destination)
				except shutil.Error:
					pass

			return ret

extension = lambda name, files, libs: Extension(
	'sfml.' + name,
	files,
	['include'], language='c++',
	libraries=libs)

system = extension(
	'system',
	[sources['system'], 'src/sfml/error.cpp'],
	['sfml-system', 'sfml-graphics'])

window = extension(
	'window', [sources['window'], 'src/sfml/DerivableWindow.cpp'],
	['sfml-system', 'sfml-window'])

graphics = extension(
	'graphics',
	[sources['graphics'], 'src/sfml/DerivableRenderWindow.cpp', 'src/sfml/DerivableDrawable.cpp'],
	['sfml-system', 'sfml-window', 'sfml-graphics'])

audio = extension(
	'audio',
	[sources['audio'], 'src/sfml/DerivableSoundRecorder.cpp', 'src/sfml/DerivableSoundStream.cpp'],
	['sfml-system', 'sfml-audio'])

network = extension(
	'network',
	[sources['network']],
	['sfml-system', 'sfml-network'])


major, minor, _, _ , _ = sys.version_info
import cython
cython_path = os.path.dirname(cython.__file__) + '/Cython'

# Install Cython headers (if possible)
if CYTHON_AVAILABLE:
	# Path: {CYTHON_DIR}/Includes/libcpp/sfml.pxd
	cython_headers = []

	if platform.system() in ['Linux', 'Darwin']:
		pxd_files = glob('include/libcpp/*')
		pxd_files.remove('include/libcpp/http')
		pxd_files.remove('include/libcpp/ftp')
	else:
		pxd_files = glob('include\\libcpp\\*')
		pxd_files.remove('include\\libcpp\\http')
		pxd_files.remove('include\\libcpp\\ftp')
		
	cython_headers.append((cython_path + '/Includes/libcpp', pxd_files))

	pxd_files = glob('include/libcpp/http/*')
	cython_headers.append((cython_path + '/Includes/libcpp/http', pxd_files))

	pxd_files = glob('include/libcpp/ftp/*')
	cython_headers.append((cython_path + '/Includes/libcpp/ftp', pxd_files))
else:
	cython_headers = []
	
# Install the C API
if platform.system() == 'Windows':
	# On Windows: C:\Python27\include\pysfml\*_api.h
	c_api = [(sys.prefix +'\\include\\pysfml', glob('include/pysfml/*.h'))]
else:
	# On Unix: /usr/include/pysfml/*_api.h
	c_api = [('/usr/include/pysfml', glob('include/pysfml/*.h'))]

# Install the Cython API
if platform.system() == 'Windows':
	# On Windows: C:\Python27\Lib\pysfml\*.pxd
	cython_api = [(sys.prefix + '\\Lib\\pysfml', glob('include/pysfml/*.pxd'))]
else:
	# On Unix: /usr/lib/pythonX.Y/pysfml/*.pxd
	cython_api = [('/usr/lib/python{0}.{1}/pysfml'.format(major, minor), glob('include/pysfml/*.pxd'))]

files = cython_headers + c_api + cython_api

with open('README.rst', 'r') as f:
	long_description = f.read()

ext_modules=[system, window, graphics, audio, network]

kwargs = dict(
			name='pySFML',
			ext_modules=ext_modules,
			package_dir={'': 'src'},
			packages=['sfml'],
			data_files=files,
			version='1.2.0',
			description='Python bindings for SFML',
			long_description=long_description,
			author='Jonathan de Wachter, Edwin O Marshall',
			author_email='dewachter.jonathan@gmail.com, emarshall85@gmail.com',
			url='http://python-sfml.org',
			license='LGPLv3',
			classifiers=['Development Status :: 5 - Production/Stable',
						'Intended Audience :: Developers',
						'License :: OSI Approved :: GNU Lesser General Public License v3 (LGPLv3)',
						'Operating System :: OS Independent',
						'Programming Language :: Cython',
						'Programming Language :: C++',
						'Programming Language :: Python',
						'Topic :: Games/Entertainment',
						'Topic :: Multimedia',
						'Topic :: Software Development :: Libraries :: Python Modules'],
			cmdclass={'test': PyTest})

if CYTHON_AVAILABLE:
	kwargs['cmdclass'].update({'build_ext': build_ext})

setup(**kwargs)
