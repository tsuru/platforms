# Java platform

The Java platform supports two kinds of deployment: binary using default tomcat
server or code deployment.

##Binary deployment

You can send a jar file, and java platform will run it with default Procfile
and tomcat7. Default procfile starts with:

    % cat Procfile
    web: /var/lib/tsuru/java/start-tomcat

You can set ``JAVA_MAX_MEMORY`` enviroment variable to set amount memory to run
tomcat, if you don't it will start with 128MB.


##Code deployment

If you just run a ``tsuru app-deploy`` of your code,
tsuru will try to download all of your dependencies using ``maven``
and build your application.
