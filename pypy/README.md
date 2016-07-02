# Pypy platform

The Pypy platform supports Python 2.7.x.

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

You can also define the setup script to list your depencies, here's an example:

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
to install all the depencies using ``pip install -r requirements.txt`` or ``pip instal -e ./``.
