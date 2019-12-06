data:extend{
    {
        type = "int-setting",
        name = "lw-sync-ticks",
        setting_type = "runtime-global",
        default_value = 5,
        minimum_value = 1,
        maximum_value = 30,
        order = "a"
    },
    {
        type = "bool-setting",
        name = "lw-wagons-match-chests",
        setting_type = "startup",
        default_value = true,
        order = "b"
    },
    {
        type = "bool-setting",
        name = "lw-use-multipliers",
        setting_type = "startup",
        default_value = true,
        order = "c"
    },
    {
        type = "bool-setting",
        name = "lw-adjust-vanilla-wagons",
        setting_type = "startup",
        default_value = true,
        order = "d"
    },
    {
        type = "bool-setting",
        name = "lw-use-chests-in-recipes",
        setting_type = "startup",
        default_value = true,
        order = "e"
    },
    {
        type = "int-setting",
        name = "lw-cargo-wagon-multiplier",
        setting_type = "startup",
        default_value = 6,
        minimum_value = 1,
        order = "f"
    },
    {
        type = "int-setting",
        name = "lw-fluid-wagon-multiplier",
        setting_type = "startup",
        default_value = 3,
        minimum_value = 1,
        order = "g"
    },
    {
        type = "int-setting",
        name = "lw-wagon-steel-plate-base",
        setting_type = "startup",
        default_value = 16,
        minimum_value = 10,
        order = "h"
    }
}
