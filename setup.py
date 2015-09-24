import sys, os, platform
import os.path, shutil
from glob import glob
from subprocess import call
from distutils.core import setup, Command, Extension

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
    """ Updated version of cython build_ext command to move
    the generated API headers to include/pysfml directory
    """

    def cython_sources(self, sources, extension):
        ret = build_ext.cython_sources(self, sources, extension)

        # should result the module name; e.g, graphics[.pyx]
        module = os.path.basename(sources[0])[:-4]

        # move its headers (foo.h and foo_api.h) to include/pysfml
        destination = os.path.join('include', 'pysfml')

        source = os.path.join('src', 'sfml', module + '.h')
        if os.path.isfile(source):
            try:
                shutil.move(source, destination)
            except shutil.Error:
                pass

        source = os.path.join('src', 'sfml', module + '_api.h')
        if os.path.isfile(source):
            try:
                shutil.move(source, destination)
            except shutil.Error:
                pass

        return ret


modules = ['system', 'window', 'graphics', 'audio', 'network']

sources = {module: os.path.join('src', 'sfml', module + '.pyx') for module in modules}
headers = {module: os.path.join('include', 'pysfml', module + '.h') for module in modules}
api_headers = {module: os.path.join('include', 'pysfml', module + '._api.h') for module in modules}

include_path = os.path.join('include', 'pysfml')
source_path = os.path.join('src', 'sfml')


# clean the directory (remove generated C++ files by Cython)
def remove_if_exist(filename):
    if os.path.isfile(filename):
        try:
            os.remove(filename)
        except OSError:
            pass

for module in modules:
    remove_if_exist(os.path.join(include_path, module + '.h'))
    remove_if_exist(os.path.join(include_path, module + '._api.h'))
    remove_if_exist(os.path.join(source_path, module + '.cpp'))

# use extlibs on Windows only
if platform.system() == 'Windows':
    extension = lambda name, files, libs: Extension(
        name='sfml.' + name,
        sources=files,
        include_dirs=['include', os.path.normpath('extlibs/sfml/include')],
        library_dirs=[os.path.normpath('extlibs/sfml/lib/' + arch)],
        language='c++',
        libraries=libs,
        extra_compile_args=['-fpermissive']
        )
else:
    extension = lambda name, files, libs: Extension(
        name='sfml.' + name,
        sources=files,
        include_dirs=['include', 'include/Includes'],
        language='c++',
        libraries=libs,
        extra_compile_args=['-fpermissive']
        )

system = extension(
    'system',
    [sources['system'], 'src/sfml/error.cpp', 'src/sfml/NumericObject.cpp'],
    ['sfml-system'])

window = extension(
    'window', [sources['window'], 'src/sfml/DerivableWindow.cpp'],
    ['sfml-system', 'sfml-window'])

graphics = extension(
    'graphics',
    [sources['graphics'], 'src/sfml/DerivableRenderWindow.cpp', 'src/sfml/DerivableDrawable.cpp', 'src/sfml/NumericObject.cpp'],
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

files = []

# Install C headers
c_api_headers = []
c_api_headers.append(os.path.join(include_path, 'system.h'))
c_api_headers.append(os.path.join(include_path, 'system_api.h'))
c_api_headers.append(os.path.join(include_path, 'NumericObject.hpp'))
c_api_headers.append(os.path.join(include_path, 'window.h'))
c_api_headers.append(os.path.join(include_path, 'window_api.h'))
c_api_headers.append(os.path.join(include_path, 'graphics.h'))
c_api_headers.append(os.path.join(include_path, 'graphics_api.h'))
c_api_headers.append(os.path.join(include_path, 'audio_api.h'))

if platform.system() == 'Windows':
    # On Windows: C:\Python27\include\pysfml\*_api.h
    files = [(sys.exec_prefix +'\\include\\pysfml', c_api_headers)]
else:
    # On Unix: /usr/local/include/pysfml/*_api.h
    files = [(sys.exec_prefix + '/include/pysfml', c_api_headers)]

if platform.system() == 'Windows':
    dlls = [("Lib\\site-packages\\sfml", glob('extlibs/sfml/bin/' + arch + '/*.dll'))]
    files += dlls

with open('README.rst', 'r') as f:
    long_description = f.read()

ext_modules=[system, window, graphics, audio, network]

kwargs = dict(
            name='pySFML',
            ext_modules=ext_modules,
            package_dir={'': 'src'},
            packages=['sfml'],
            data_files=files,
            version='2.2.0',
            description='Python bindings for SFML',
            long_description=long_description,
            author='Jonathan de Wachter, Edwin O Marshall',
            author_email='dewachter.jonathan@gmail.com, emarshall85@gmail.com',
            url='http://python-sfml.org',
            classifiers=['Development Status :: 5 - Production/Stable',
                        'Intended Audience :: Developers',
                        'License :: OSI Approved :: zlib/libpng License',
                        'Operating System :: OS Independent',
                        'Programming Language :: Cython',
                        'Programming Language :: C++',
                        'Programming Language :: Python',
                        'Topic :: Games/Entertainment',
                        'Topic :: Multimedia',
                        'Topic :: Software Development :: Libraries :: Python Modules'],
            cmdclass={'build_ext': CythonBuildExt})

setup(**kwargs)
