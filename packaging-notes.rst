=================
 Packaging Notes
=================

python setup.py --with-cython sdist
python setup.py --with-cython bdist_wheel
python3.4 setup.py --with-cython bdist_wheel
twine upload dist/*
