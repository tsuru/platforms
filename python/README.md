# Python platform

The Python platform uses python 2.7.14 by default and get your dependencies with pip,
either ``requirements.txt`` or ``setup.py``.

You can define which python version you want using ``.python-version``, always use full versions.

ex:
```
3.6.4
```

available python versions:
- 2.7.14
- 3.5.4
- 3.6.4


## Code deployment

If you just run a ``git push``  or ``tsuru app-deploy`` of your code, tsuru will try
to download all of your depencies using ``requirements.txt`` or ``setup script``.
You can customize this behavior, see the next section for more details.

## Code deployment with dependencies

There are two ways to list the applications dependencies: ``requirements.txt`` or ``setup.py``.
The priority order is: requirements -> setup. The file should be in the root of deploy files.

### Using requirements.txt

You can define a file called ``requirements.txt`` that list all pip dependencies of your application,
each line represents one dependency, here's an example:

	$ cat requirements.txt
	Flask==0.10.1
	gunicorn==19.3.0

### Using setup script

You can also define the setup script to list your dependencies, here's an example:

	$ cat setup.py
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

After invokin ``git push`` or ``tsuru app-deploy``, tsuru will receive your code and tell the platform
to install all the dependencies using ``pip install -r requirements.txt`` or ``pip instal -e ./``.
