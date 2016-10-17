// Copyright 2016 tsuru authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

var express = require('express');
var app = express();

app.get('/', function(req, res){
	  res.send('Hello world from tsuru');
});

var server = app.listen(process.env.PORT || 5000);
