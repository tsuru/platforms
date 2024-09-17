# Python platform

The Python platform uses python `3.11.3` by default and get your dependencies
with pip, either by `Pipfile.lock`, `requirements.txt` or `setup.py`.

You can define which python version you want using `.python-version`, always
use full versions.

ex:
```
3.11.3
```

Available python versions:
- 2.7.14
- 3.5.10
- 3.6.15
- 3.7.16
- 3.8.16
- 3.9.16
- 3.10.11
- 3.11.3
- pypy2.7-7.3.2
- pypy3.6-7.3.2

when adding new releases, we will retain previous version on the series to
allow time for users update their apps. e,g: when 3.6.3 is released, we will
remove 3.6.1.

## Setting pip version

By default, the latest pip version will be installed. If you want to use a
specific version, set a `PYTHON_PIP_VERSION` environment variable. It accepts
a specific version (`PYTHON_PIP_VERSION=7.1.2`) or a
[requirement specifier](https://pip.pypa.io/en/stable/reference/pip_install/#requirement-specifiers)
(`PYTHON_PIP_VERSION="<10"`).

## Code deployment

If you just run a `tsuru app deploy` of your code, tsuru will try to download
all of your depencies using `requirements.txt` or `setup script`.  You can
customize this behavior, see the next section for more details.

## Code deployment with dependencies

There are two ways to list the applications dependencies: `requirements.txt`
or ``setup.py``.  The priority order is: requirements -> setup. The file should
be in the root of deploy files.

### Using Pipfile.lock

If you have a `Pipfile.lock` file, tsuru will use pipenv to install the
dependencies of your application.

### Using requirements.txt

You can define a file called `requirements.txt` that list all pip
dependencies of your application, each line represents one dependency, here's
an example:

$ cat requirements.txt
```
Flask==0.10.1
gunicorn==19.3.0
```

### Using setup script

You can also define the setup script to list your dependencies, here's an
example:

$ cat setup.py
```python
from setuptools import setup, find_packages
setup(
    name="app-name",
    packages=find_packages(),
    description="example",
    include_package_data=True,
    install_requires=[
        "Flask==0.10.1",
        "gunicorn==19.3.0",
    ],
)
```

After invoking `tsuru app-deploy`, tsuru will receive your code and tell the
platform to install all the dependencies using `pipenv install --system
--deploy`, `pip install -r requirements.txt` or `pip instal -e ./`.
