local ROOT = '__MultiplayerTeams__'
local prefix = 'multiplayer-teams'

styles = data.raw["gui-style"].default

styles[prefix..'-verical-flow'] = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
}

styles[prefix.."-controls-textfield"] = {
    type = "textbox_style",
    width = 56
}

styles[prefix.."-deep-frame"] = {
    type = "frame_style",
    parent = "slot_button_deep_frame",
    vertically_stretchable = "on",
    horizontally_stretchable = "on",
    top_margin = 16,
    left_margin = 8,
    right_margin = 8,
    bottom_margin = 4
}

styles["icon_count"] = {
    type = "label_style",
    parent = "count_label",
    size = 36,
    width = 36,
    horizontal_align = "right",
    vertical_align = "bottom",
    right_padding = 2,
  }