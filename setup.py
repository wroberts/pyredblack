from setuptools import setup, find_packages, Extension
from codecs import open  # To use a consistent encoding
from os import path
import sys

HERE = path.abspath(path.dirname(__file__))

with open(path.join(HERE, 'pyredblack', 'VERSION'), encoding='utf-8') as f:
    VERSION = f.read().strip()

# Get the long description from the relevant file
with open(path.join(HERE, 'README.rst'), encoding='utf-8') as f:
    LONG_DESCRIPTION = f.read()

with open(path.join(HERE, 'pyredblack', 'prbconfig.h'), 'w') as f:
    f.write('int PYTHON_VERSION2 = {};\n'.format(int(sys.version_info[0] == 2)))

USE_CYTHON = False
try:
    from Cython.Build import cythonize
    USE_CYTHON = True
except ImportError:
    pass

PYREDBLACK_EXTENSIONS = [Extension(
    "pyredblack.redblack",
    ['pyredblack/redblack' + ('.pyx' if USE_CYTHON else '.cpp')],
    language="c++")]
if USE_CYTHON:
    PYREDBLACK_EXTENSIONS = cythonize(PYREDBLACK_EXTENSIONS)

setup(
    name='pyredblack',

    # Versions should comply with PEP440.  For a discussion on single-sourcing
    # the version across setup.py and the project code, see
    # https://packaging.python.org/en/latest/single_source_version.html
    version=VERSION,

    description='Red/black trees in C++ for Python',
    long_description=LONG_DESCRIPTION,

    # The project's main homepage.
    url='https://github.com/wroberts/pyredblack',

    # Author details
    author='Will Roberts',
    author_email='wildwilhelm@gmail.com',

    # Choose your license
    license='MIT',

    # See https://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        # How mature is this project? Common values are
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        'Development Status :: 3 - Alpha',

        # Indicate who your project is intended for
        'Intended Audience :: Developers',
        'Topic :: Software Development :: Build Tools',

        # Pick your license as you wish (should match "license" above)
        'License :: OSI Approved :: MIT License',

        # Specify the Python versions you support here. In particular, ensure
        # that you indicate whether you support Python 2, Python 3 or both.
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.2',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
    ],

    # What does your project relate to?
    keywords='data structure algorithm',

    # You can just specify the packages manually here if your project is
    # simple. Or you can use find_packages().
    packages=find_packages(exclude=['testcpp']),

    ext_modules = PYREDBLACK_EXTENSIONS,

    # List run-time dependencies here.  These will be installed by pip when your
    # project is installed. For an analysis of "install_requires" vs pip's
    # requirements files see:
    # https://packaging.python.org/en/latest/requirements.html
    #install_requires=['peppercorn'],

    # List additional groups of dependencies here (e.g. development dependencies).
    # You can install these using the following syntax, for example:
    # $ pip install -e .[dev,test]
    #extras_require = {
    #    'dev': ['check-manifest'],
    #    'test': ['coverage'],
    #},

    # If there are data files included in your packages that need to be
    # installed, specify them here.  If using Python 2.6 or less, then these
    # have to be included in MANIFEST.in as well.
    #package_data={
    #    'sample': ['package_data.dat'],
    #},

    # Although 'package_data' is the preferred approach, in some case you may
    # need to place data files outside of your packages.
    # see http://docs.python.org/3.4/distutils/setupscript.html#installing-additional-files
    # In this case, 'data_file' will be installed into '<sys.prefix>/my_data'
    #data_files=[('my_data', ['data/data_file'])],

    # To provide executable scripts, use entry points in preference to the
    # "scripts" keyword. Entry points provide cross-platform support and allow
    # pip to create the appropriate form of executable for the target platform.
    #entry_points={
    #    'console_scripts': [
    #        'sample=sample:main',
    #    ],
    #},
    test_suite='nose.collector',
    tests_require=['nose'],
)
