# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

import os

import flask

app = flask.Flask(__name__)


@app.route("/")
def hello():
    return "Hello world from tsuru"

app.run(port=int(os.environ.get("PORT", "5000")), host="0.0.0.0")
