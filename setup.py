import sys, os, platform
import os.path, shutil
from glob import glob
from subprocess import call
from setuptools import setup, Command, Extension

try:
    from Cython.Distutils import build_ext
except ImportError:
    print("Please install cython and try again.")
    raise SystemExit

if platform.architecture()[0] == "32bit":
	arch = "x86"
elif platform.architecture()[0] == "64bit":
	arch = "x64"

class CythonBuildExt(build_ext):
    """ Updated version of cython build_ext command to deal with the
        generated API headers. C/C++ header files are all moved to the
        temporary build directory before being properly installed on
        the system.
    """

    def cython_sources(self, sources, extension):

        # cythonize .pxd source files
        ret = build_ext.cython_sources(self, sources, extension)

        # should result the module name; e.g, graphics[.pyx]
        module = os.path.basename(sources[0])[:-4]

        # prepare a list with all header files related to the module (*.hpp, *_api.h, *.h)
        header_files = glob(os.path.join('src', 'sfml', module, '*.hpp'))

        header_files.append(os.path.join('src', 'sfml', module, module + '.h'))
        header_files.append(os.path.join('src', 'sfml', module, module + '_api.h'))

        # deal with exceptions
        if module == "network":
            header_files.remove(os.path.join('src', 'sfml', module, module + '.h'))
            header_files.remove(os.path.join('src', 'sfml', module, module + '_api.h'))

        # create the temporary destination in the build directory
        destination = os.path.join(self.build_temp, 'include', 'pysfml', module)

        if not os.path.exists(destination):
            os.makedirs(destination)

        # move all header files to the build directory
        for header_file in header_files:
            if os.path.isfile(header_file):
                try:
                    shutil.copy(header_file, destination)
                except shutil.Error:
                    pass

        # add the temporary header directory to compilation options
        self.compiler.include_dirs.append(os.path.join(self.build_temp, 'include'))

        # update data_files to install the files on the system

        # On Windows: C:\Python27\include\pysfml\*_api.h
        # On Unix: /usr/local/include/pysfml/*_api.h
        install_directory = os.path.join(sys.exec_prefix, 'include', 'pysfml', module)
        files_to_install = [os.path.join(self.build_temp, 'include', 'pysfml', module, os.path.basename(header_file)) for header_file in header_files]
        data_files.append((install_directory, files_to_install))

        return ret

modules = ['system', 'window', 'graphics', 'audio', 'network']

extension = lambda name, files, libs: Extension(
	name='sfml.' + name,
	sources= [os.path.join('src', 'sfml', name, filename) for filename in files],
	include_dirs=[os.path.join('include', 'Includes')],
	library_dirs=[os.path.join('extlibs', 'libs-msvc-universal', arch)] if sys.hexversion >= 0x03050000 else [],
	language='c++',
	libraries=libs,
	define_macros=[('SFML_STATIC', '1')] if platform.system() == 'Windows' else [])

if platform.system() == 'Windows':
	system_libs   = ['winmm', 'sfml-system-s']
	window_libs   = ['user32', 'advapi32', 'winmm', 'sfml-system-s', 'gdi32', 'opengl32', 'sfml-window-s']
	graphics_libs = ['user32', 'advapi32', 'winmm', 'sfml-system-s', 'gdi32', 'opengl32', 'sfml-window-s', 'freetype', 'jpeg', 'sfml-graphics-s']
	audio_libs    = ['winmm', 'sfml-system-s', 'flac', 'vorbisenc', 'vorbisfile', 'vorbis', 'ogg', 'openal32', 'sfml-audio-s']
	network_libs  = ['ws2_32', 'sfml-system-s', 'sfml-network-s']
else:
	system_libs   = ['sfml-system']
	window_libs   = ['sfml-system', 'sfml-window']
	graphics_libs = ['sfml-system', 'sfml-window', 'sfml-graphics']
	audio_libs    = ['sfml-system', 'sfml-audio']
	network_libs  = ['sfml-system', 'sfml-network']


system = extension(
    'system',
    ['system.pyx', 'error.cpp', 'hacks.cpp', 'NumericObject.cpp'],
    system_libs)

window = extension(
    'window',
    ['window.pyx', 'DerivableWindow.cpp'],
    window_libs)

graphics = extension(
    'graphics',
    ['graphics.pyx', 'DerivableRenderWindow.cpp', 'DerivableDrawable.cpp', 'NumericObject.cpp'],
    graphics_libs)

audio = extension(
    'audio',
    ['audio.pyx', 'DerivableSoundRecorder.cpp', 'DerivableSoundStream.cpp'],
    audio_libs)

network = extension(
    'network',
    ['network.pyx'],
    network_libs)

major, minor, _, _ , _ = sys.version_info

data_files = []
if platform.system() == 'Windows':
    dlls = [("Lib\\site-packages\\sfml", glob('extlibs\\' + arch + '\\openal32.dll'))]
    data_files += dlls

with open('README.md', 'r') as f:
    long_description = f.read()

ext_modules=[system, window, graphics, audio, network]

install_requires = []

if sys.version_info < (3, 4):
    install_requires.append('enum34')

kwargs = dict(
            name='pySFML',
            ext_modules=ext_modules,
            package_dir={'': 'src'},
            packages=['sfml'],
            data_files=data_files,
            version='2.3.2.dev1',
            description='Python bindings for SFML',
            long_description=long_description,
            author='Jonathan de Wachter',
            author_email='dewachter.jonathan@gmail.com',
            url='http://python-sfml.org',
            classifiers=['Development Status :: 5 - Production/Stable',
                        'Intended Audience :: Developers',
                        'License :: OSI Approved :: zlib/libpng License',
                        'Operating System :: OS Independent',
                        'Programming Language :: Python :: 2',
                        'Programming Language :: Python :: 3',
                        'Programming Language :: Cython',
                        'Programming Language :: C++',
                        'Programming Language :: Python',
                        'Programming Language :: Python :: Implementation :: CPython',
                        'Topic :: Games/Entertainment',
                        'Topic :: Multimedia',
                        'Topic :: Software Development :: Libraries :: Python Modules'],
            keywords='sfml SFML simple fast multimedia system window graphics audio network pySFML PySFML python-sfml',
            install_requires=install_requires,
            cmdclass={'build_ext': CythonBuildExt})

setup(**kwargs)
