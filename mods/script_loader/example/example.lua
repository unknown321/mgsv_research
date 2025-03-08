--this is an example mod to be used with script_loader
--https://unknown321.github.io/mgsv_research/loader.html
local helpers = require("helpers")
local example = {}

function example.test()
    TppUiCommand.AnnounceLogView('Hello from example mod!')
end

function example.log_example()
    helpers.log('This string will be in the log', true, 'i')
end

function example.arguments(a,b,c)
    helpers.log(string.format('This is a function with arguments %s %s %s',a,b,c), true, 'w')
end

function example.wrapper()
    example.arguments('a','b','c')
    helpers.log('But we have to call it using a wrapper')
end

return example
