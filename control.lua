require "debugLog"
require "wagons.wagon"



function on_init()
    debugLog( 1, "on_init()" )
    global.logisticWagons = global.logisticWagons or {}
end

function on_tick( event )
    local syncTicks = settings.global[ "lw-sync-ticks" ].value
    if( ( event.tick % syncTicks ) ~= 0 )then
        return
    end
    debugLog( 4, "on_tick()" )
    for i, wagon in pairs( global.logisticWagons ) do
        wagon_on_tick( wagon )
    end
end

function on_built_entity( event )
    local entity = event.created_entity or event.entity
    local proxy_name = get_proxy_name( entity.name )
    if( proxy_name ~= nil )then
        debugLog( 1, "on_built_entity() :: entity = " .. event.name .. " :: proxy = " .. proxy_name )
        local wagon = wagon_create( entity, proxy_name )
        if( wagon ~= nil )then
            table.insert( global.logisticWagons, wagon )
        end
    end
end

function on_entity_removed( event )
    local entity = event.entity
    local i = find_wagon_index( entity )
    if( i ~= nil )then
        debugLog( 1, "on_entity_removed() :: wagon_index = " .. i )
        wagon_remove_proxy( global.logisticWagons[ i ] )
        table.remove( global.logisticWagons, i )
    end
end


function on_gui_opened( event )
    local entity = event.entity
    debugLog( 1, "on_gui_opened() :: event = " .. serpent.dump( event ), nil, true )
    dumpWagons()
    local i = find_wagon_index( entity )
    if( i ~= nil )then
        local wagon = global.logisticWagons[ i ]
        debugLog( 1, "on_gui_opened() :: index = " .. i .. " :: wagon = " .. serpent.dump( wagon ), nil, true )
        wagon_on_gui_opened( wagon, event )
    end
end


function get_proxy_name( name )
    if( name == "lw-cargo-wagon-passive" )then
        return "lw-logistic-chest-passive-provider-trans"
    elseif( name == "lw-cargo-wagon-active" )then
        return "lw-logistic-chest-active-provider-trans"
    elseif( name == "lw-cargo-wagon-requester" )then
        return "lw-logistic-chest-requester-trans"
    elseif( name == "lw-cargo-wagon-storage" )then
        return "lw-logistic-chest-storage-provider-trans"
    elseif( name == "lw-cargo-wagon-buffer" )then
        return "lw-logistic-chest-buffer-provider-trans"
    end
    return nil
end


function find_wagon_index( entity )
    if( entity == nil )then
        return nil
    end
    global.logisticWagons = global.logisticWagons or {}
    for i = 1, #global.logisticWagons do
        local wagon = global.logisticWagons[ i ]
        if( entity.unit_number ~= nil )then
            if( wagon.entity.unit_number == entity.unit_number )then
                return i
            end
        end
    end
    return nil
end


function find_wagon( entity )
    local i = find_wagon_index( entity )
    if( i ~= nil )then
        return global.logisticWagons[ i ]
    end
    return nil
end


function dumpWagons()
    global.logisticWagons = global.logisticWagons or {}
    for i = 1, #global.logisticWagons do
        local wagon = global.logisticWagons[ i ]
        debugLog( 0, "index = " .. i .. " :: wagon.entity.unit_number = " .. wagon.entity.unit_number, serpent.dump( wagon ) )
    end
end

-- Initialization
script.on_init( on_init )
script.on_load( on_load )

-- Entity was placed on map
script.on_event( {
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built },
    function( event )
    on_built_entity( event )
end )

-- Entity item was removed from the map
script.on_event( {
    defines.events.on_entity_died,
    defines.events.on_pre_player_mined_item,
    defines.events.on_robot_pre_mined,
    defines.events.script_raised_destroy },
    function( event )
    on_entity_removed( event )
end )

-- GUI was opened
script.on_event( {
    defines.events.on_gui_opened },
    function( event )
    on_gui_opened( event )
end )

-- Main loop
script.on_event(
    defines.events.on_tick,
    function( event )
    on_tick( event )
end )

