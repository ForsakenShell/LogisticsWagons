require( "debugLog" )


-- Update inventory sizes and fluid capacities to be more inline with the wagons representative size.
USE_CHESTS = settings.startup[ "lw-use-chests-in-recipes" ].value
ADJUST_VANILLA = settings.startup[ "lw-adjust-vanilla-wagons" ].value
USE_MULTIPLIERS = settings.startup[ "lw-use-multipliers" ].value
BASE_PLATES = settings.startup[ "lw-wagon-steel-plate-base" ].value
CHEST_MULTIPLIER = 1
FLUID_MULTIPLIER = 1

if( USE_MULTIPLIERS )then
    CHEST_MULTIPLIER = settings.startup[ "lw-cargo-wagon-multiplier" ].value
    FLUID_MULTIPLIER = settings.startup[ "lw-fluid-wagon-multiplier" ].value
end


function ingredient_name( ingredient )
    return ingredient.name or ingredient[ 1 ]
end

function ingredient_amount( ingredient )
    return ingredient.amount or ingredient[ 2 ]
end


function ingredient_in_recipe( recipe, name )
    for i = 1, #recipe.ingredients do
        if( ingredient_name( recipe.ingredients[ i ] ) == name )then
            return recipe.ingredients[ i ]
        end
    end
    return nil
end


function ingredient_amount_in_recipe( recipe, name )
    for i = 1, #recipe.ingredients do
        if( ingredient_name( recipe.ingredients[ i ] ) == name )then
            return ingredient_amount( recipe.ingredients[ i ] )
        end
    end
    return nil
end


function change_ingredient_in_recipe( recipe, name, newAmount, newName )
    local ingredient = ingredient_in_recipe( recipe, name )
    if( ingredient == nil )then
        local rn = newName or name
        table.insert( recipe.ingredients, { rn, newAmount } )
        return
    end
    if( newName ~= nil )then
        if( ingredient.name ~= nil )then
            ingredient.name = newName
        else
            ingredient[ 1 ] = newName
        end
    end
    if( ingredient.amount ~= nil )then
        ingredient.amount = newAmount
    else
        ingredient[ 2 ] = newAmount
    end
end


function is_excluded( name, excludes )
    if( excludes == nil )then
        return false
    end
    for i = 1, #excludes do
        if( name == excludes[ i ] )then
            return true
        end
    end
    return false
end


function copy_ingredients_in_recipe( target, source, multiplier, excludes )
    if( multiplier == nil )then
        multiplier = 1
    end
    for i = 1, #source.ingredients do
        local rn = ingredient_name( recipe.ingredients[ i ] )
        if( not is_excluded( rn, excludes ) )then
            local ra = ingredient_amount( source.ingredients[ i ] ) * multiplier
            change_ingredient_in_recipe( target, rn, ra )
        end
    end
end


function adjust_vanilla_wagon_recipes()
    if( not ADJUST_VANILLA )then
        return
    end
    
    local cargo_wagon = data.raw[ "recipe" ][ "cargo-wagon" ]
    if( USE_CHESTS )then
        local sci_sp = ingredient_in_recipe( cargo_wagon, "steel-plate" )
        change_ingredient_in_recipe( cargo_wagon, "steel-plate", BASE_PLATES )
        change_ingredient_in_recipe( cargo_wagon, "steel-chest", CHEST_MULTIPLIER )
    else
        local steel_chest = data.raw[ "recipe" ][ "steel-chest" ]
        change_ingredient_in_recipe( cargo_wagon, "steel-plate", BASE_PLATES + ingredient_amount_in_recipe( steel_chest, "steel-plate" ) * CHEST_MULTIPLIER )
    end
    
    local fluid_wagon = data.raw[ "recipe" ][ "fluid-wagon" ]
    change_ingredient_in_recipe( fluid_wagon, "steel-plate", BASE_PLATES )
    change_ingredient_in_recipe( fluid_wagon, "storage-tank", FLUID_MULTIPLIER )
end


function make_logistics_wagon_recipes( wName, lName )
    local recipe = util.table.deepcopy( data.raw[ "recipe" ][ "cargo-wagon" ] )
    
    recipe.name = wName
    recipe.result = wName
    
    if( USE_CHESTS )then
        change_ingredient_in_recipe( recipe, "steel-plate", BASE_PLATES )
        change_ingredient_in_recipe( recipe, lName, CHEST_MULTIPLIER )
    else
        local steel_chest = data.raw[ "recipe" ][ "steel-chest" ]
        local logistics_chest = data.raw[ "recipe" ][ lName ]
        change_ingredient_in_recipe( recipe, "steel-plate", BASE_PLATES + ingredient_amount_in_recipe( steel_chest, "steel-plate" ) * CHEST_MULTIPLIER )
        copy_ingredients_in_recipe( recipe, logistics_chest, CHEST_MULTIPLIER, { "steel-plate" } )
    end
    
    data:extend( { recipe } )
end

make_logistics_wagon_recipes( "lw-cargo-wagon-passive"  , "logistic-chest-passive-provider" )
make_logistics_wagon_recipes( "lw-cargo-wagon-active"   , "logistic-chest-active-provider"  )
make_logistics_wagon_recipes( "lw-cargo-wagon-storage"  , "logistic-chest-storage"          )
make_logistics_wagon_recipes( "lw-cargo-wagon-requester", "logistic-chest-requester"        )
adjust_vanilla_wagon_recipes()
