What is the interest to have modules ?
======================================

Seriously ? Ok.
A better structured and readable code! Like lot of other programmation languages.

What is the interest to avoid module ?
======================================

What is this question ?! Hmm.... ok!

There is some limited kind of situation where you want to have a standalone program without librarie, module, or any kind of external dependencies.
In my case I got :
 * A old game that support lua but only one file to load.
 * When you want to make some tool to automated task (like shell script) and you want deploy it by coping the script, no more.

What is currently a lua module ?
================================

I see to way to define a lua module.

## 1) The old module definition

Lot of (old) module code use the `module` function introduce in [Lua 5.1](https://tst2005.github.io/manual/lua/5.1/manual.html#pdf-module), depreated in [Lua 5.2](https://tst2005.github.io/manual/lua/5.2/manual.html#8.2).

## 2) The current module definition

The current [module definition](http://lua-users.org/wiki/ModulesTutorial) is done with :
 * a separated file where the name and path will be used to load it
 * the content of the module end by a return of a single value. This value will the got as result of a `require("modulename")`

Some convention exists
 * `name` , `version`, `license`, `homepage`, `description` : [ulua](http://ulua.io/specs.html)
 * `_VERSION`, `_DESCRIPTION`, `_URL`, `_LICENSE` : [kikito/middleclass](https://github.com/kikito/middleclass/blob/master/middleclass.lua#L2-L5)
but no one is mandatory...


Current Lua module returned values
==================================

Usualy, it is a table!

A simple table value
--------------------

Because :
 * it is as easy to define as easy to use.
 * you can store lot of functions inside.

* file "foo.lua":
```lua
local function foo(self, x)
  return "foo: "..tostring(x)
end
local M = {
  foo = foo,
}
return M
```

* file "main.lua":
```lua
local foo = require "foo"
assert(foo.foo)
print(foo.foo("FOO")) -- print: foo: FOO
```

A function value
----------------

* file "foo.lua":
```lua
local function foo(self, x)
  return "foo: "..tostring(x)
end
return foo
```

* file "main.lua":
```lua
local foo = require "foo"
print(foo("FOO")) -- print: foo: FOO
```


A callabled table value
-----------------------

Like all table in lua we should add some extra handler in his metatable.
The most used is probably the `__call` handler.
It is a merge of simple table and function module.

Because it allow you to call the module directly for his main/usual task without to remember the name of the key to use to got the good function, without additionnal existance check of this function.

I think it the most powerfull but also the most complicated to define.

### Sample 1 :

* file "foo.lua":
```lua
local function foo(self, x)
  return "foo: "..tostring(x)
end
local M = {
  foo = foo,
}
setmetatable(M, {__call = foo})
return M
```

* file "main.lua":
```lua
local foo = require "foo"
print(foo("FOO")) -- print: foo: FOO
-- but also
print(foo.foo("FOO")) -- print: foo: FOO
```


### Sample 2:

* file "foo.lua":
```lua
local function foo(self, x)
  return "foo: "..tostring(x)
end
local M = {
  foo = foo,
}
setmetatable(M, {__call = foo})
M._VERSION = "0.1.0"
return M
```

* file "main.lua":
```lua
local foo = require "foo"
print(foo._VERSION) -- print: 0.1.0

print(foo("FOO")) -- print: foo: FOO
-- but also
print(foo.foo("FOO")) -- print: foo: FOO
```


A boolean value
===============

If a module return `true` this value is store.
It is also the case when the module returns anything (`nil`) or `false`(?).
It is usualy the case when you use a quiet old module that returns anything.


Any other value
===============

In some (very rare?) case you should got any other value : `userdata` or `number`.


My needs/goal about lua modules
===============================

Be able to manage them cleanly like package manager :
 * (basic) by Name
 * (basic) by Version
 * by License / Author / URL / ...
 
Some advanced managment need informations :
 * by API : be able to check easily that functions will or will not be available
 * by Feature/Behavior : be able to check easily that feature/behavior will or will not be available

All of those points needs to attach information to each module.
Some usual current module definition can not support to store more information.


Need a new module definition ?
==============================

Not at all ! Stop breaking existing module definition !
A returned value and a `require` function is enough to build some better stuff and stay compatible with current way to do.


Need some additionnal specs and helper to make powerfull module ?
=================================================================

I think so!


My wrond way
-------------

I tried to follow the idea : each lua module should be a table with all appropriate fields filled !
But defining all the fields, all the time, for all modules is a pain!


The maybe better way
--------------------

I think we should have a hybride module definition, and automated tool to setup modules...

I started to put name on some told way to define modules.
 * single function value : a `micro module`
 * single table or callable table value : a `mini module`
 * a full filled table (with all version, license, author, ... fields filled) : a `module`
 * a boolean value : something to fix!
 * other value : I don't know for now...


lua micro module
================

This module is usually the most minimal code possible : return a single function, nothing more.

It is usefull to split the code in lot of part to be able to choose which one is really needed and which one should be dropped.

Main idea: return something callable.


lua mini module
===============

## like a simple table

Return nothing callable, but an additionnal content (a table)
```lua
local function foo(self, x)
  return "foo: "..tostring(x)
end
local M = { foo = foo }
return nil, M
```

## a callable table

like a lua module except all meta information, and meta stuff should be done my a module helper

mini module should only return a table like :
```
local function foo(self, x)
  return "foo: "..tostring(x)
end
local M = { foo = foo }
return foo, M
```

lua embedding approach
======================

I experiment a new approch to build module.
 * split each parts in `micro module`
 * Fill the module information separatly
 * use some util to build the final result!


unloading capability
--------------------

The only way I found...


lua module helper/proxy
=======================



experimental code for module helper
===================================

