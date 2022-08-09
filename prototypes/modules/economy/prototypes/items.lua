local ROOT = '__MultiplayerTeams__'

data:extend({{
    type = "item",
    name = "shop-buy",
    icon = "__MultiplayerTeams__/graphics/icons/shop-buy/shop.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "storage",
    order = "a[items]-b[iron-chest]",
    place_result = "shop-buy",
    stack_size = 10
}})
