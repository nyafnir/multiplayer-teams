local guiStyle = data.raw["gui-style"].default

--- https://lua-api.factorio.com/latest/LuaStyle.html
guiStyle['main_button'] = {
    type = 'button_style',
    size = 55, --- Sets both width and height to the given value. 
    color = colors.grey,
}
