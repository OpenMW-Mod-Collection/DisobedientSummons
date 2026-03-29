local I = require("openmw.interfaces")
local storage = require("openmw.storage")
local nearby = require("openmw.nearby")
local types = require("openmw.types")
local self = require("openmw.self")
local core = require("openmw.core")

local settings = storage.globalSection("SettingsDisobedientSummons")
local l10n = core.l10n("DisobedientSummons")
local toScan = { nearby.actors, nearby.players }

local summoner
local deltaTime = 0
local cooldown = 1
local pendingActors = {}
local message

I.AI.forEachPackage(function(pkg)
    if (pkg.type == "Follow" or pkg.type == "Escort") and pkg.target and pkg.target:isValid() then
        summoner = pkg.target
    end
end)

-- just in case
if not summoner then
    return
end

local luck = summoner.type.stats.attributes.luck(summoner)
local disobedientChance = settings:get("baseChance")
    + luck.modified * settings:get("luckMod")

-- obedience check
if math.random() * 100 > disobedientChance then
    return
end

local function onUpdate(dt)
    deltaTime = deltaTime + dt
    if #pendingActors == 0 then
        if message then
            for _, player in ipairs(nearby.players) do
                player:sendEvent(
                    "ShowMessage",
                    { message = message }
                )
            end
            message = nil
        end

        if deltaTime < cooldown then
            return
        end

        deltaTime = 0

        for _, objects in ipairs(toScan) do
            for _, obj in ipairs(objects) do
                pendingActors[#pendingActors + 1] = obj
            end
        end
    end

    local currActor = table.remove(pendingActors)
    if currActor.type ~= types.NPC
        or currActor == summoner
        or (self.position - currActor.position):length() > settings:get("maxDistance")
    then
        return
    end

    local conjuration = types.NPC.stats.skills.conjuration
    local actorConj = types.NPC.objectIsInstance(currActor)
        and conjuration(currActor).modified
        or settings:get("creatureConjurationSkill")
    local summonerConj = types.NPC.objectIsInstance(summoner)
        and conjuration(summoner).modified
        or settings:get("creatureConjurationSkill")
    if actorConj - summonerConj < settings:get("conjurationDifference") then
        return
    end

    I.AI.startPackage({
        type = "Follow",
        target = currActor,
        cancelOther = true,
    })
    summoner = currActor

    if settings:get("enableMessages") then
        local selfName = self.type.records[self.recordId].name
        local summonerName = summoner.type == types.Player
            and "you"
            or summoner.type.records[summoner.recordId].name
        message = l10n(
            "msg_disobeyed",
            { summon = selfName, master = summonerName }
        )
    end
end

return {
    engineHandlers = {
        onUpdate = onUpdate,
    }
}
