require( "debugLog" )


-- Update inventory sizes and fluid capacities to be more inline with the wagons representative size.
MATCH_CHESTS = settings.startup[ "lw-wagons-match-chests" ].value
ADJUST_VANILLA = settings.startup[ "lw-adjust-vanilla-wagons" ].value
USE_MULTIPLIERS = settings.startup[ "lw-use-multipliers" ].value
CHEST_MULTIPLIER = 1
FLUID_MULTIPLIER = 1

if( USE_MULTIPLIERS )then
    CHEST_MULTIPLIER = settings.startup[ "lw-cargo-wagon-multiplier" ].value
    FLUID_MULTIPLIER = settings.startup[ "lw-fluid-wagon-multiplier" ].value
end


function adjust_vanilla_wagon_entities()
    if( not ADJUST_VANILLA )then
        return
    end
    
    local cargo_wagon = data.raw[ "cargo-wagon" ][ "cargo-wagon" ]
    local fluid_wagon = data.raw[ "fluid-wagon" ][ "fluid-wagon" ]
    
    if( MATCH_CHESTS )then
        local steel_chest = data.raw[ "container" ][ "steel-chest" ]
        cargo_wagon.inventory_size = steel_chest.inventory_size * CHEST_MULTIPLIER
        
        local storage_tank = data.raw[ "storage-tank" ][ "storage-tank" ]
        local area = storage_tank.fluid_box.base_area or 1
        local height = storage_tank.fluid_box.height or 1
        fluid_wagon.capacity = ( area * 100 ) * height * FLUID_MULTIPLIER
    else
        cargo_wagon.inventory_size = cargo_wagon.inventory_size * CHEST_MULTIPLIER
        fluid_wagon.capacity = fluid_wagon.capacity * FLUID_MULTIPLIER
    end
    
end


function make_logistics_wagon_entities( wName, pName, wFilePath, lName )
    local wagon = util.table.deepcopy( data.raw[ "cargo-wagon" ][ "cargo-wagon" ] )
    local proxy = util.table.deepcopy( data.raw[ "logistic-container" ][ lName ] )
    
    inventory_size = wagon.inventory_size * CHEST_MULTIPLIER
    if( MATCH_CHESTS )then
        inventory_size = proxy.inventory_size * CHEST_MULTIPLIER
    end
    
    wagon.name = wName
    wagon.icon = "__LogisticsWagons__/resources/icons/" .. wFilePath .. ".png"
    wagon.icon_size = 32
    wagon.inventory_size = inventory_size
    wagon.minable.result = wName
    wagon.pictures =
    {
        layers =
        {
            {
                priority = "very-low",
                width = 285,
                height = 250,
                axially_symmetrical = false,
                direction_count = 256,
                filenames =
                {
                    "__LogisticsWagons__/resources/" .. wFilePath .. "/sprites-0.png",
                    "__LogisticsWagons__/resources/" .. wFilePath .. "/sprites-1.png",
                    "__LogisticsWagons__/resources/" .. wFilePath .. "/sprites-2.png",
                    "__LogisticsWagons__/resources/" .. wFilePath .. "/sprites-3.png",
                    "__LogisticsWagons__/resources/" .. wFilePath .. "/sprites-4.png",
                    "__LogisticsWagons__/resources/" .. wFilePath .. "/sprites-5.png",
                    "__LogisticsWagons__/resources/" .. wFilePath .. "/sprites-6.png",
                    "__LogisticsWagons__/resources/" .. wFilePath .. "/sprites-7.png"
                },
                line_length = 4,
                lines_per_file = 8,
                shift = {0.00, -0.60}
            }
        }
    }
    wagon.horizontal_doors = nil
    wagon.vertical_doors = nil
    
    proxy.name = pName
    proxy.icon = "__LogisticsWagons__/resources/icons/trans-icon.png"
    proxy.icon_size = 32
    proxy.flags = { "placeable-neutral", "placeable-off-grid" }
    proxy.max_health = 10000
    proxy.inventory_size = inventory_size
    proxy.picture =
    {
        filename = "__LogisticsWagons__/resources/trans.png",
        priority = "very-low",
        width = 1,
        height = 1,
        shift = {0, 0}
    }
    proxy.order = "z"
    proxy.minable = nil
    proxy.corpse = nil
    proxy.selection_box = nil
    proxy.collision_box = nil
    proxy.collision_mask = nil -- { "ghost-layer" }
    proxy.fast_replaceable_group = nil
    proxy.animation = nil
    proxy.resistances = nil
    proxy.open_sound = nil
    proxy.close_sound = nil
    proxy.vehicle_impact_sound = nil
    proxy.circuit_wire_connection_point = nil
    proxy.circuit_connector_sprites = nil
    proxy.circuit_wire_max_distance = nil
    
    if( proxy.logistic_slots_count ~= nil )then
        wagon.logistic_slots_count = proxy.logistic_slots_count
    end
    
    if( proxy.logistic_mode ~= nil )then
        wagon.logistic_mode = proxy.logistic_mode
    end
    
    debugLog( 3, "make_logistics_wagon_entities() :: " .. wName .. " :: " .. pName )
    debugLog( 3, serpent.block( wagon ) )
    debugLog( 3, serpent.block( proxy ) )
    
    data:extend( { wagon, proxy } )
end


make_logistics_wagon_entities( "lw-cargo-wagon-passive"  , "lw-logistic-chest-passive-provider-trans", "wagon-passive-provider", "logistic-chest-passive-provider" ) 
make_logistics_wagon_entities( "lw-cargo-wagon-active"   , "lw-logistic-chest-active-provider-trans" , "wagon-active-provider" , "logistic-chest-active-provider"  ) 
make_logistics_wagon_entities( "lw-cargo-wagon-requester", "lw-logistic-chest-requester-trans"       , "wagon-requester"       , "logistic-chest-requester"        ) 
make_logistics_wagon_entities( "lw-cargo-wagon-storage"  , "lw-logistic-chest-storage-provider-trans", "wagon-storage"         , "logistic-chest-storage"          ) 
adjust_vanilla_wagon_entities()
