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

        source_files = [module + '.h', module + '_api.h']
        for source_file in source_files:
            source = os.path.join('src', 'sfml', source_file)
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
        include_dirs=['include'],
        language='c++',
        libraries=libs,
        extra_compile_args=['-fpermissive']
        )

system = extension(
    'system',
    [sources['system'], 'src/sfml/error.cpp'],
    ['sfml-system'])

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

# Distribute Cython API (install cython headers)
# Path: {CYTHON_DIR}/Includes/libcpp/sfml.pxd
import cython
cython_path = os.path.join(os.path.dirname(cython.__file__),'Cython')

cython_headers = []

pxd_files = glob(os.path.join('include', 'libcpp', '*'))
pxd_files.remove(os.path.join('include', 'libcpp', 'http'))
pxd_files.remove(os.path.join('include', 'libcpp', 'ftp'))
cython_headers.append((os.path.join(cython_path, 'Includes', 'libcpp'), pxd_files))

pxd_files = glob(os.path.join('include', 'libcpp', 'http', '*'))
cython_headers.append((os.path.join(cython_path, 'Includes', 'libcpp', 'http'), pxd_files))

pxd_files = glob(os.path.join('include', 'libcpp', 'ftp', '*'))
cython_headers.append((os.path.join(cython_path, 'Includes', 'libcpp', 'ftp'), pxd_files))

# Distribute C API (install C headers)

if platform.system() == 'Windows':
    # On Windows: C:\Python27\include\pysfml\*_api.h
    c_api = [(sys.prefix +'\\include\\pysfml', glob('include/pysfml/*.h'))]
else:
    # On Unix: /usr/include/pysfml/*_api.h
    c_api = [(sys.prefix + '/include/pysfml', glob('include/pysfml/*.h'))]

# Install the Cython API
if platform.system() == 'Windows':
    # On Windows: C:\Python27\Lib\pysfml\*.pxd
    cython_api = [(sys.prefix + '\\Lib\\pysfml', glob('include/pysfml/*.pxd'))]
else:
    # On Unix: /usr/lib/pythonX.Y/pysfml/*.pxd
    cython_api = [(sys.prefix + '/lib/python{0}.{1}/pysfml'.format(major, minor), glob('include/pysfml/*.pxd'))]

misc_files = ['README.rst', 'requirements.txt']

files = cython_headers + c_api + cython_api + misc_files

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
            version='2.2.0.post6',
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
            cmdclass={'build_ext': CythonBuildExt},
            requires=['cython'])

setup(**kwargs)
