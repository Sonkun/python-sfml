import sys, os, platform
import os.path, shutil
from glob import glob
from subprocess import call
from setuptools import setup, Command, Extension


if platform.architecture()[0] == "32bit":
    arch = "x86"
elif platform.architecture()[0] == "64bit":
    arch = "x64"


modules = ['system', 'window', 'graphics', 'audio', 'network']

extension = lambda name, files, libs: Extension(
    name='sfml.' + name,
    sources= [os.path.join('src', 'sfml', name, filename) for filename in files],
    include_dirs=[os.path.join('include', 'Includes'), 'src'],
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
    classifiers=[
        'Development Status :: 5 - Production/Stable',
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
    test_requirements=[
        'pytest',
    ],
    setup_requires=['cython'],
)

setup(**kwargs)
