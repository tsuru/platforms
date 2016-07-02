# Copyright 2016 tsuru authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

class Mock < BasicObject
  ENV = ::ENV
  def method_missing(name, *args)
  end
  def ruby(*args)
    ::Kernel.puts args[0]
  end
end

Mock.new.instance_eval(File.read(ARGV[0]))
