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

To install your dependencies, first we check if there is a `yarn.lock` file
in the root of your files. If so, we use [yarn](https://yarnpkg.com/);
otherwise, we use [npm](https://www.npmjs.com/package/npm).

You have to list your dependencies in the `package.json` file.

    $ cat package.json
    ...
    "dependencies": {
        "express": "3.x"
    }
    ...

If you want to also install development dependencies, set the environment
variable ``NPM_CONFIG_PRODUCTION=false``. Otherwise, we'll only install
regular dependencies.
You can also cache your node_modules by setting environment variable
``KEEP_NODE_MODULES=true``.
