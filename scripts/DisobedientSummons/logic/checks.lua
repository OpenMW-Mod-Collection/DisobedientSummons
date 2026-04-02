local types = require("openmw.types")
local core = require("openmw.core")

require("scripts.DisobedientSummons.utils.consts")

local function isSummoner(currActor)
    local spells = currActor.type.spells(currActor)
    for _, spell in ipairs(spells) do
        local effects = core.magic.spells.records[spell.id].effects
        for _, effect in ipairs(effects) do
            if SummonSpells[effect.id] then
                return true
            end
        end
    end
    return false
end

function ValidSummoner(currActor, summoner, selfPos, maxDistance)
    if currActor == summoner
        or (selfPos - currActor.position):length() > maxDistance
    then
        return false
    end

    if currActor.type == types.NPC then
        return true
    else
        return isSummoner(currActor)
    end
end

function SkillCheck(settings, currActor, summoner)
    local conjuration = types.NPC.stats.skills.conjuration
    local actorConj = types.NPC.objectIsInstance(currActor)
        and conjuration(currActor).modified
        or settings:get("creatureConjurationSkill")
    local summonerConj = types.NPC.objectIsInstance(summoner)
        and conjuration(summoner).modified
        or settings:get("creatureConjurationSkill")
    return actorConj - summonerConj > settings:get("conjurationDifference")
end
