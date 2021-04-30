local hasGearId = "ashfallGearAdded_v"
local gearVersion = 1
local function hasGearAdded(reference)
    return reference.data[hasGearId .. gearVersion] == true
end
local function setGearAdedd(reference)
    reference.data[hasGearId .. gearVersion] = true
end

local common = require("mer.ashfall.common.common")
local config = require("mer.ashfall.config.config").config
--Place an invisible, appCulled container at the feet of a merchant and assign ownership
--This is how we add stock to merchants without editing the cell in the CS
local function placeContainer(merchant, containerId)
    common.log:debug("Adding container %s to %s", containerId, merchant.object.name)
    local container = tes3.createReference{
        object = containerId,
        position = merchant.position:copy(),
        orientation = merchant.orientation:copy(),
        cell = merchant.cell
    }
    tes3.setOwner{ reference = container, owner = merchant}
end


local function onMobileActivated(e)
    local config = config
    local obj = e.reference.baseObject or e.reference.object

    --Publicans get food
    if common.isInnkeeper(e.reference) then
        local hasFoodAlready = e.reference.data.ashfallFoodAdded == true
        if not hasFoodAlready then
            e.reference.data.ashfallFoodAdded = true
            placeContainer(e.reference, common.staticConfigs.crateIds.food)
        end
    end

    --Selected outfitters and traders get camping gear
    local isMerchant = config.campingMerchants[ obj.id:lower() ] == true
    if isMerchant then
        if not hasGearAdded(e.reference) then
            setGearAdedd(e.reference)
            placeContainer(e.reference, 'ashfall_crate_rnd')
        end
    end
end
event.register("mobileActivated", onMobileActivated )


