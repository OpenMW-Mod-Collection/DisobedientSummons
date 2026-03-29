local I = require("openmw.interfaces")

I.Settings.registerGroup {
    key = 'SettingsDisobedientSummons',
    page = 'DisobedientSummons',
    l10n = 'DisobedientSummons',
    name = 'settings_groupName',
    description = 'settings_groupDesc',
    permanentStorage = true,
    order  = 1,
    settings = {
        {
            key = 'baseChance',
            name = 'baseChance_name',
            renderer = 'number',
            default = 20,
        },
        {
            key = 'luckMod',
            name = 'luckMod_name',
            renderer = 'number',
            default = -.10,
        },
        {
            key = 'conjurationDifference',
            name = 'conjurationDifference_name',
            description = 'conjurationDifference_desc',
            renderer = 'number',
            default = 20,
        },
        {
            key = 'creatureConjurationSkill',
            name = 'creatureConjurationSkill_name',
            description = 'creatureConjurationSkill_desc',
            renderer = 'number',
            default = 85,
        },
        {
            key = 'maxDistance',
            name = 'maxDistance_name',
            description = 'maxDistance_desc',
            renderer = 'number',
            default = 1000,
        },
        {
            key = 'enableMessages',
            name = 'enableMessages_name',
            renderer = 'checkbox',
            default = true,
        },
    }
}
