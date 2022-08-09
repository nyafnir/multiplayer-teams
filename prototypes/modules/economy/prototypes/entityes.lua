local ROOT = '__MultiplayerTeams__'
ShopEntityPrototype = {}
setmetatable(ShopEntityPrototype, {
    __index = LuaEntity
})

ShopEntity = {}
setmetatable(ShopEntity, {
    __index = LuaEntity
})

function ShopEntity:new()
end


data:extend{
    {
    type = 'container',
    name = "shop-buy",
    icon = ROOT.."/graphics/icons/shop-buy/shop.jpg",
    icon_size = 64,
    icon_mipmaps = 4,
    -- enable_inventory_bar = false,
    flags = {"placeable-neutral", "player-creation"},
    minable = {
        mining_time = 0.5,
        result = "shop-buy"
    },
    max_health = 800,
    corpse = "iron-chest-remnants",
    dying_explosion = "iron-chest-explosion",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    -- damaged_trigger_effect = hit_effects.entity(),
    inventory_size = 64,
    -- vehicle_impact_sound = sounds.generic_impact,
    picture = {
        layers = {{
            filename = ROOT.."/graphics/entity/shop-buy/shop.jpg",
            priority = "extra-high",
            width = 240,
            height = 240,
            hr_version = {
                filename = ROOT.."/graphics/entity/shop-buy/shop.jpg",
                priority = "extra-high",
                width = 1200,
                height = 800,
                scale = 0.1
            }
        }}
    },
}}
