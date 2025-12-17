# Python platform

The Python platform uses python `3.14.2` by default (based on Ubuntu 24.04) and gets your dependencies
with pip, either by `Pipfile.lock`, `requirements.txt` or `setup.py`.

## Defining Python version

You can define which python version you want using one of the following methods (in priority order):

1. **PYTHON_VERSION environment variable** - set via `tsuru env-set`
2. **Pipfile.lock** - if present, the `python_version` field in `_meta.requires` will be used
3. **.python-version file** - a file in your project root containing the version number
4. **Default version** - if none of the above are specified, the latest Python 3.x version will be used

Always use full version numbers (e.g., `3.14.2`) or partial versions (e.g., `3.14` for latest 3.14.x, or `3.14.x`).

Example `.python-version` file:
```
3.14.2
```

## Available Python versions

Python versions are automatically fetched from [python.org](https://www.python.org) during platform installation, ensuring the latest releases are always available. The platform supports all actively maintained Python 3.x versions.

To see the exact versions available in your platform installation, check the generated versions file at `/var/lib/tsuru/python/latest_versions.sh` on the platform image.

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
