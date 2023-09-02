local awful = require("awful")
local config = require("config")
local beautiful = require("beautiful")

return awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = awful.menu({
        items = {
            {
                { "Reload", awesome.restart },
                { "Quit",   awesome.quit() }

            },
            { "Open Terminal", config.terminal },
        }
    })

})
