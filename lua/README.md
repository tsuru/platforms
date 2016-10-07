# Lua Platform

The Lua platform uses Lua 5.1 and latest LuaRocks available.

## Code deployment with dependencies

We're using Luarocks to manage packages for Lua, and tsuru will expect
for a file called `tsuru.rockspec` for dependencies definitions.
