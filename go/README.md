#Go platform

The Go platform supports two kinds of deployment: binary deployment and code
deployment, where tsuru will build your application in the target.

##Binary deployment

For binary deployment, ensure your binary is named "tsuru-app" (``go build -o
tsuru-app`` should do the trick) and matches the target platform (usually
linux_amd64), you can have a customized name if you also deploy a Procfile,
something like:

	% ls
	Procfile main.go
	% GOOS=linux GOARCH=amd64 go build -o myapp main.go
	% cat Procfile
	web: ./myapp
	% tsuru app-deploy -a [app-name] myapp Procfile

##Code deployment

If you just run a ``git push`` of your code, tsuru will try to download all of
your dependencies using ``go get`` and build your application. You can
customize this behavior, see the next section for more details.

Suppose that you have this code structure:

	% ls
	main.go
	% cat main.go
	# some code that starts a "hello world" webserver
	% git add main.go
	% git commit -m "add my webserver"
	% git push tsuru master

After invoking ``git push``, tsuru will receive your code and tell the platform
to follow the setup process, that will:

- download all the dependencies using ``go get``
- build the application, expecting the root of your project to be a main
  package

##Code deployment with customized compilation step

You can also use tsuru hooks to customize the compilation and a Procfile to
customize the execution of your application, here's an example:

	% tree
	.
	├── Procfile
	├── src
	│   └── main.go
	└── tsuru.yaml

	1 directory, 3 files
	% cat tsuru.yaml
	hooks:
	  build:
	    - go get github.com/bmizerany/pat
	    - go build -o $HOME/myapp src/main.go
	% cat Procfile
	web: $HOME/myapp -host 0.0.0.0 -port $PORT
	% git push tsuru master

At this point, tsuru will parse the tsuru.yaml file and invoke the build hooks
to build your application, and then use the command specified in the Procfile
to start it.
