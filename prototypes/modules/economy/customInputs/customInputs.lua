local prefix = configService.config.prefix

data:extend({
    {
        type = "custom-input",
        name = prefix .. "_E_closeGUI",
        key_sequence = "E",
        consuming = "none"
    }
})

data:extend({
    {
        type = "custom-input",
        name = prefix .. "_ESCAPE_closeGUI",
        key_sequence = "ESCAPE",
        consuming = "none"
    }
})
