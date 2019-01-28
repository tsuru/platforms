function sleep(s)
    local ntime = os.clock() + s
    repeat until os.clock() > ntime
end
  
while(true)
do
    print("Hello world from tsuru")
    sleep(2)
end