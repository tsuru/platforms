# Nodejs platform

The Nodejs platform uses nvm to run your code and you can choose what node
version you want to run it. To define node version you have three ways:

    * .nvmrc
        $ cat .nvmrc
        4.4.0
    * .node-version
        $ cat .node-version
        4.4.0
    * package.json
        $ cat package.json
        ...
        "engines": {
            "node": "4.2.6",
        },
        ...

This file should be in the root of deploy files.

    $ ls
    Procfile     app.js       hook.js      package.json

We use npm to install your dependencies, so you have to list it in
``package.json`` file.

    $ cat package.json
    ...    
    "dependencies": {
        "express": "3.x"
    }
    ...

You can also cache your node_modules by setting environment variable
``KEEP_NODE_MODULES=true``.
