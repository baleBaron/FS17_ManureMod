--
-- Manure Mod
--
-- By: baron <mve.karlsson@gmail.com>
--

local Overwritten = {updateCultivatorArea   = Utils.updateCultivatorArea,
                     updatePloughArea       = Utils.updatePloughArea}

ManureMod = {}

Utils.updateCultivatorArea = function(x, z, x1, z1, x2, z2, limitToField, limitGrassDestructionToField, angle)
    ManureMod.fertilizeManureArea(x, z, x1, z1, x2, z2, limitToField)
    return Overwritten.updateCultivatorArea(x, z, x1, z1, x2, z2, limitToField, limitGrassDestructionToField, angle)
end

Utils.updatePloughArea = function(x, z, x1, z1, x2, z2, limitToField, limitGrassDestructionToField, angle)
    ManureMod.fertilizeManureArea(x, z, x1, z1, x2, z2, limitToField)
    return Overwritten.updatePloughArea(x, z, x1, z1, x2, z2, limitToField, limitGrassDestructionToField, angle)
end

function ManureMod.fertilizeManureArea(x, z, x1, z1, x2, z2, limitToField)
    -- Increment fertilization levels by 1 where solid manure (spray bit 2)
    local x0, z0, widthX, widthZ, heightX, heightZ = Utils.getXZWidthAndHeight(g_currentMission.terrainDetailId, x, z, x1, z1, x2, z2)
    setDensityMaskParams(g_currentMission.terrainDetailId, "equals", 2)
    addDensityMaskedParallelogram(
        g_currentMission.terrainDetailId,
        x0, z0, widthX, widthZ, heightX, heightZ,
        g_currentMission.sprayLevelFirstChannel, g_currentMission.sprayLevelNumChannels,
        g_currentMission.terrainDetailId, g_currentMission.sprayFirstChannel, g_currentMission.sprayNumChannels,
        1
    )
    -- Reset spray layer to 0
    setDensityMaskParams(g_currentMission.terrainDetailId, "greater", -1)
    setDensityParallelogram(
        g_currentMission.terrainDetailId,
        x0, z0, widthX, widthZ, heightX, heightZ,
        g_currentMission.sprayFirstChannel, g_currentMission.sprayNumChannels,
        0
    )
end