--
-- Manure Mod
--
-- By: baron <mve.karlsson@gmail.com>
--

ManureMod = {}

function ManureMod.fertilizeManureArea(x, z, x1, z1, x2, z2, limitToField)
    local detailId = g_currentMission.terrainDetailId
    local sprayFirstChannel = g_currentMission.sprayFirstChannel
    local sprayNumChannels = g_currentMission.sprayNumChannels
    local sprayLevelFirstChannel = g_currentMission.sprayLevelFirstChannel
    local sprayLevelNumChannels = g_currentMission.sprayLevelNumChannels
    local x0, z0, widthX, widthZ, heightX, heightZ = Utils.getXZWidthAndHeight(detailId, x, z, x1, z1, x2, z2)

    -- Increment fertilization levels by 1 where solid manure (spray bit 2)
    setDensityMaskParams(detailId, "equals", 2)
    setDensityCompareParams(detailId, "greater", 0)
    addDensityMaskedParallelogram(
        detailId,
        x0, z0, widthX, widthZ, heightX, heightZ,
        g_currentMission.sprayLevelFirstChannel, sprayLevelNumChannels,
        detailId, 
        g_currentMission.sprayFirstChannel, sprayNumChannels,
        1
    )
    setDensityMaskParams(detailId, "greater", 0)

    -- Remove visible fertilizer layer
    setDensityParallelogram(
        detailId,
        x0, z0, widthX, widthZ, heightX, heightZ,
        sprayFirstChannel, sprayNumChannels,
        0
    )
    setDensityCompareParams(detailId, "greater", -1)
end

-- Install manure mod. 
-- When relying on alphabetical loading order and doing this after loadMission00Finished 
-- we hope to overwrite after choppedStraw does to make sure manure was not already deleted
Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, function(...)

    local oldUpdateCultivatorArea = Utils.updateCultivatorArea
    Utils.updateCultivatorArea = function(x, z, x1, z1, x2, z2, limitToField, limitGrassDestructionToField, angle)
        ManureMod.fertilizeManureArea(x, z, x1, z1, x2, z2, limitToField)
        return oldUpdateCultivatorArea(x, z, x1, z1, x2, z2, limitToField, limitGrassDestructionToField, angle)
    end

    local oldUpdatePloughArea = Utils.updatePloughArea
    Utils.updatePloughArea = function(x, z, x1, z1, x2, z2, limitToField, limitGrassDestructionToField, angle)
        ManureMod.fertilizeManureArea(x, z, x1, z1, x2, z2, limitToField)
        return oldUpdatePloughArea(x, z, x1, z1, x2, z2, limitToField, limitGrassDestructionToField, angle)
    end
end)

Sprayer.processSprayerAreas = Utils.overwrittenFunction(Sprayer.processSprayerAreas, function(self, superFunc, workAreas, fillType)
    if fillType == FillUtil.FILLTYPE_LIQUIDMANURE or fillType == FillUtil.FILLTYPE_DIGESTATE then
        fillType = FillUtil.FILLTYPE_MANURE
    end
    
    return superFunc(self, workAreas, fillType)
end)
