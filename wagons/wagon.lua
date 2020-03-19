--[[
    wagon = {
        proxy_name = name of proxy entity
        wagon_count = wagon inventory count
        proxy_count = proxy inventory count
        is_moving = is the wagon moving?
        entity = wagon entity
        proxy = logistics chest entity or nil (when rolling),
        request_slots = nil or {} is a requester
    }
]]

require( "debugLog" )

function wagon_create( entity, proxy_name )
    debugLog( 2, "wagon_create()", "entity = " .. entity.name .. " :: proxy_name = " .. proxy_name )
    
    local wagon =
    {
        proxy_name = proxy_name,
        wagon_count = -1,
        proxy_count = -1,
        is_moving = false,
        entity = entity,
        proxy = nil,
        request_slots = nil
    }
    
    return wagon
end

function wagon_on_tick( wagon )
    if( wagon == nil )or( wagon.entity == nil )or( not wagon.entity.valid )then
        return
    end
    
    wagon.is_moving = wagon_is_moving( wagon )
    debugLog( 4, "wagon_on_tick()", "wagon = " .. serpent.dump( wagon ) )
    
    if( wagon.is_moving )and( wagon.proxy ~= nil )then
        wagon_remove_proxy( wagon )
        
    elseif( not wagon.is_moving )then
        if( wagon.proxy == nil )then
            wagon_create_proxy( wagon )
        end
        wagon_sync_filters( wagon )
        wagon_sync_inventory( wagon )
    end
end

function wagon_on_gui_opened( wagon, event )
    if( event.gui_type ~= defines.gui_type.entity )or( wagon.proxy == nil )then
        return
    end
    if( wagon.proxy.prototype.logistic_mode ~= "requester" )and( wagon.proxy.prototype.logistic_mode ~= "buffer" )then
        return
    end
    debugLog( 2, "wagon_on_gui_opened() :: event = " .. serpent.dump( event ) .. " :: wagon = " .. serpent.dump( wagon ) )
    -- Redirect the GUI to the proxy for requesters
    local player = game.players[ event.player_index ]
    player.opened = wagon.proxy
end

function wagon_is_moving( wagon )
    if( wagon == nil )or( wagon.entity == nil )or( not wagon.entity.valid )or( wagon.entity.train == nil )or( wagon.entity.train.speed == nil )then
        return false
    end
    return math.abs( wagon.entity.train.speed ) > 0
end

function wagon_create_proxy( wagon )
    if( wagon == nil )or( wagon.entity == nil )or( not wagon.entity.valid )or( wagon.proxy ~= nil )then
        return
    end
    debugLog( 2, "wagon_create_proxy()", "wagon = " .. serpent.dump( wagon ) )
    local proxyPosition = wagon.entity.position
    proxyPosition.y = proxyPosition.y - 1
    wagon.proxy = wagon.entity.surface.create_entity{ name = wagon.proxy_name, position = proxyPosition, force = wagon.entity.force, raise_built = false }
    wagon.wagon_count = -1
    wagon.proxy_count = -1
    if( wagon.proxy.prototype.logistic_mode == "requester" )or( wagon.proxy.prototype.logistic_mode == "buffer" )then
        local slotCount = wagon.proxy.request_slot_count or 0
        if( slotCount > 0 )and( wagon.request_slots ~= nil )then
            for i = 1, slotCount do
                if( wagon.request_slots[ i ] ~= nil )then
                    wagon.proxy.set_request_slot( wagon.request_slots[ i ], i )
                end
            end
        end
    end
end

function wagon_remove_proxy( wagon )
    if( wagon == nil )or( wagon.entity == nil )or( wagon.proxy == nil )then
        return
    end
    debugLog( 2, "wagon_remove_proxy()", "wagon = " .. serpent.dump( wagon ) )
    wagon_sync_inventory( wagon )
    wagon.proxy.destroy()
    wagon.proxy = nil
    wagon.wagon_count = -1
    wagon.proxy_count = -1
end

function wagon_sync_filters( wagon )
    if( wagon == nil )or( wagon.entity == nil )or( wagon.proxy == nil )then
        return
    end
    debugLog( 4, "wagon_sync_filters()", "wagon = " .. serpent.block( wagon ) )
    
    local wagonInventory = wagon.entity.get_inventory( 1 )
    local proxyInventory = wagon.proxy.get_inventory( 1 )
    
    -- Sync the barred inventory slots
    local wagonBar = wagonInventory.getbar()
    local proxyBar = proxyInventory.getbar()
    if( wagonBar ~= proxyBar )then
        if( wagon.proxy.prototype.logistic_mode == "requester" )or( wagon.proxy.prototype.logistic_mode == "buffer" )then
            wagonInventory.setbar( proxyBar )
        else
            proxyInventory.setbar( wagonBar )
        end
    end
    
    -- Sync the request slots
    if( wagon.proxy.prototype.logistic_mode == "requester" )or( wagon.proxy.prototype.logistic_mode == "buffer" )then
        local slotCount = wagon.proxy.request_slot_count or 0
        if( slotCount > 0 )then
            local wagonSlots = {}
            for i = 1, slotCount do
                wagonSlots[ i ] = wagon.proxy.get_request_slot( i )
            end
            wagon.request_slots = wagonSlots
        end
    end
    
end

function wagon_sync_inventory( wagon )
    if( wagon == nil )or( wagon.entity == nil )or( wagon.proxy == nil )then
        return
    end
    debugLog( 4, "wagon_sync_inventory()", "wagon = " .. serpent.dump( wagon ) )
    
    local wagonInventory = wagon.entity.get_inventory( 1 )
    local proxyInventory = wagon.proxy.get_inventory( 1 )
    
    if( wagonInventory.get_item_count() ~= wagon.wagon_count )then
        copy_inventory( wagonInventory, proxyInventory )
        
        wagon.wagon_count = wagonInventory.get_item_count()
        wagon.proxy_count = proxyInventory.get_item_count()

        return true
        
    elseif( proxyInventory.get_item_count() ~= wagon.proxy_count )then
        copy_inventory( proxyInventory, wagonInventory )
        
        wagon.wagon_count = wagonInventory.get_item_count()
        wagon.proxy_count = proxyInventory.get_item_count()
        
        return true
    end
    
    return false
end

function copy_inventory( copyFrom, copyTo )
    if( ( copyFrom == nil )or( copyTo == nil ) )then
        return
    end
    
    --debugLog( "ProxyWagon:copy_inventory()" )
    
    local action = {}
    local fromContents = copyFrom.get_contents()
    local toContents = copyTo.get_contents()
    
    for name, count in pairs( fromContents ) do
        local diff = get_item_difference( name, fromContents[ name ], toContents[ name ] )
        if( diff ~= 0 )then
            action[ name ] = diff
        end 
    end
            
    for name, count in pairs( toContents ) do
        if( fromContents[ name ] == nil )then
            action[ name ] = get_item_difference( name, fromContents[ name ], toContents[ name ] )
        end
    end
    
    for name, diff in pairs( action ) do
        if( diff > 0 )then
            copyTo.insert( { name = name, count =  diff } )
        elseif( diff < 0 )then
            copyTo.remove( { name = name, count = -diff } )
        end
    end
    
end

function get_item_difference( item, syncFromItemCount, syncToItemCount )
    if( syncFromItemCount == nil )then
        if( syncToItemCount ~= nil )then
            return -syncToItemCount
        end
    elseif( syncToItemCount == nil )then 
        return syncFromItemCount
    else
        return syncFromItemCount - syncToItemCount
    end
    return 0
end