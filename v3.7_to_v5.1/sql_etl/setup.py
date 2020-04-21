from setuptools import setup

with open('requirements.txt') as f:
    install_requires = f.readline()

setup(
    name='Loading',
    version='1.0',
    py_modules=['loading'],
    install_requires=[
        install_requires
    ],
    entry_points='''
	    [console_scripts]
	    loading=loading.main:cli
	'''
)
