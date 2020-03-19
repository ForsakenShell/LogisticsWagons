require( "debugLog" )


function make_logistics_wagon_items( wName, wFilePath )
    local item =
    {
        type = "item",
        name = wName,
        icon = "__LogisticsWagons__/resources/icons/" .. wFilePath .. ".png",
        icon_size = 32,
        subgroup = "transport",
        order = "a[train-system]-z[" .. wName .. "]",
        place_result = wName,
        stack_size = 5
    }
    data:extend( { item } )
end


make_logistics_wagon_items( "lw-cargo-wagon-passive"  , "wagon-passive-provider" )
make_logistics_wagon_items( "lw-cargo-wagon-active"   , "wagon-active-provider"  )
make_logistics_wagon_items( "lw-cargo-wagon-requester", "wagon-requester"        )
make_logistics_wagon_items( "lw-cargo-wagon-storage"  , "wagon-storage"          )
make_logistics_wagon_items( "lw-cargo-wagon-buffer"   , "wagon-buffer"           )
