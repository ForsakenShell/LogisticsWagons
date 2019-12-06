require( "debugLog" )


data:extend(
    {
        {
            type = "technology",
            name = "lw-logistic-wagons",
            icon = "__LogisticsWagons__/resources/icons/wagon-passive-provider.png",
            icon_size = 32,
            effects =
            {
                { type = "unlock-recipe", recipe = "lw-cargo-wagon-passive"   },
                { type = "unlock-recipe", recipe = "lw-cargo-wagon-storage"   },
            },
            prerequisites = { "railway", "construction-robotics", "logistic-robotics" },
            unit =
            {
                count = 200,
                ingredients =
                {
                    { "automation-science-pack", 1 },
                    { "logistic-science-pack", 1 },
                    { "chemical-science-pack", 1 }
                },
                time = 30
            },
            order = "c-k-d-z",
        },
        {
            type = "technology",
            name = "lw-logistic-wagons-2",
            icon = "__LogisticsWagons__/resources/icons/wagon-active-provider.png",
            icon_size = 32,
            effects =
            {
                { type = "unlock-recipe", recipe = "lw-cargo-wagon-active"    },
                { type = "unlock-recipe", recipe = "lw-cargo-wagon-requester" },
            },
            prerequisites = { "lw-logistic-wagons", "logistic-system" },
            unit =
            {
                count = 500,
                ingredients =
                {
                    { "automation-science-pack", 1 },
                    { "logistic-science-pack", 1 },
                    { "chemical-science-pack", 1 },
                    { "utility-science-pack", 1 }
                },
                time = 30
            },
            order = "c-k-d-z",
        }
    }
)