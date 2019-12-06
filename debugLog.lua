-- Debug functions needs to be in global scope to be able to be called from the other scripts

 -- set for debug
DEBUG_LOG_VERBOSITY = -1
DEBUG_CONSOLE = false

function debugLog( verbosity, message, toLogOnly )
    if( forceLog == nil )then
        forceLog = false
    end
    if( verbosity <= DEBUG_LOG_VERBOSITY )then
        if( ( DEBUG_CONSOLE )and( game ~= nil ) )then
            for i, player in pairs( game.players ) do
                player.print( message )
            end
        end
        if( toLogOnly ~= nil )then
            log( message .. " :: " .. toLogOnly )
        else
            log( message )
        end
    end
end
