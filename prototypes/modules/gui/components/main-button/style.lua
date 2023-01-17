local guiStyle = data.raw["gui-style"].default

---https://lua-api.factorio.com/latest/LuaStyle.html
guiStyle['main_button'] = {
    type = 'button_style',
    size = 55, ---Устанавливает ширину и высоту в заданное значение.
    color = colorService.list.grey,
}
