------------------------------------------------------------------------------------------------
-- BEASTMASTER NPC
------------------------------------------------------------------------------------------------

local EnableModule = true
local AnnounceModule = true   -- Announce module on player login ?

local Beastmaster = {
    entry = 601026, -- Beastmaster entry.
    maxObj = 13, -- 13 = Max amt. of menu objects.
    reqMastery = 1 -- Require Beast Mastery talent for exotic pets
}

------------------------------------------------------------------------------------------------
-- END CONFIG
------------------------------------------------------------------------------------------------

if (not EnableModule) then return end

require("GossipTextExtension")

local CACHE_NORMAL = 1
local CACHE_RARE = 2
local CACHE_EXOTIC = 3
local CACHE_EXOTIC_RARE = 4

local T = {
    [CACHE_NORMAL] = "Beasts",
    [CACHE_RARE] = "Rare Beasts",
    [CACHE_EXOTIC] = "Exotic Beasts",
    [CACHE_EXOTIC_RARE] = "Rare Exotic Beasts",
}

function Beastmaster.OnHello(event, player, unit)
    -- Check whether the player is actually a hunter or not.
    if(player:GetClass() == 3) then
        player:GossipSetText("Greetings, "..player:GetName()..". If you are looking for a trustful companion on your travels you have come to the right place. I can offer you a variety of tamed pets for you to choose from. If necessary I can also teach you the ways of the hunter so that you can take good care of your pet.")
        player:GossipMenuAddItem(3, "Tame Beasts", 1, 2)
        player:GossipMenuAddItem(3, "Tame Rare Beasts", 1, 3)
        player:GossipMenuAddItem(3, "Tame Exotic Beasts", 1, 4)
        player:GossipMenuAddItem(3, "Tame Rare Exotic Beasts", 1, 5)
        player:GossipMenuAddItem(3, "Hunter Training", 1, 6)
        player:GossipMenuAddItem(0, "I wish to stable my pet.", 1, 7)
        player:GossipMenuAddItem(1, "Buy Pet Food", 1, 8)
        player:GossipSendMenu(0x7FFFFFFF, unit)
    else
        local roll = math.random(1, 3)
        if (roll == 1) then
           player:GossipSetText("Scram "..player:GetClassAsString()..", I do not teach your kind.")
        elseif (roll == 2) then
            player:GossipSetText("I provide my services only to Hunters.")
        else
            player:GossipSetText("Sorry mate, Hunters only!")
        end
        player:GossipSendMenu(0x7FFFFFFF, unit)
    end
end

function Beastmaster.OnSelect(event, player, unit, sender, intid, code)
    if(player:GetClass() == 3) then
        -- Intid 0 is used solely for menu pages and 1 for pet selection.
        if(intid == 0) then
            Beastmaster.GenerateMenu(sender, player, unit)
        elseif(intid == 1) then
             local selection = player:GetData("_bm_menu_sel")
             if (not selection) then
                 player:SendBroadcastMessage("[|cff4CFF00BeastMasterNPC|r]|cffff2020 Something went wrong.")
                 player:GossipComplete()
            elseif (not player:HasSpell(1515)) then
                --unit:SendUnitWhisper("You need to learn how to Tame Beasts first.", 0, player)
                player:GossipSetText("You need to learn how to Tame Beasts first.")
                player:GossipMenuAddItem(3, "Hunter Training", sender, 6)
                player:GossipMenuAddItem(7, "Back", sender, 9)
                player:GossipSendMenu(0x7FFFFFFF, unit)
            elseif ((selection == CACHE_EXOTIC or selection == CACHE_EXOTIC_RARE) and Beastmaster.reqMastery==1 and not player:HasSpell(53270)) then
                --unit:SendUnitWhisper("You need to learn Beast Mastery to tame Exotic beasts.", 0, player)
                player:GossipSetText("You need to learn Beast Mastery to tame Exotic beasts.")
                player:GossipSendMenu(0x7FFFFFFF, unit)
            else
                if (player:GetPetGUID() < 1) then
                    player:CastSpell(player, 883, true)
                end
                if (player:GetPetGUID() > 0) then
                    --unit:SendUnitWhisper("First you must abandon or stable your current pet!", 0, player)
                    player:GossipSetText("First you must abandon or stable your current pet!")
                    player:GossipMenuAddItem(0, "I wish to stable my pet.", sender, 7)
                    player:GossipMenuAddItem(7, "Back", sender, 9)
                    player:GossipSendMenu(0x7FFFFFFF, unit)
                else
                    -- Spawn a temporary, friendly version of the selected creature and force tame it.
                    local pet = PerformIngameSpawn(1, sender, unit:GetMapId(), unit:GetInstanceId(), unit:GetX(), unit:GetY(), unit:GetZ(), unit:GetO(), false, 5000)
                    pet:SetFaction(35)
                    player:CastSpell(pet, 2650, true)
                    unit:SendUnitWhisper("A fine choice "..player:GetName().."! Take good care of your "..pet:GetName().." and you will never face your enemies alone.", 0, player)
                    player:GossipComplete()
                end
            end
        elseif(intid == 2 or intid == 3 or intid == 4 or intid == 5) then
            if (intid == 3) then
                player:SetData("_bm_menu_sel", CACHE_RARE)
            elseif (intid == 4) then
                player:SetData("_bm_menu_sel", CACHE_EXOTIC)
            elseif (intid == 5) then
                player:SetData("_bm_menu_sel", CACHE_EXOTIC_RARE)
            else
                player:SetData("_bm_menu_sel", CACHE_NORMAL)
            end
            Beastmaster.GenerateMenu(sender, player, unit)
        elseif(intid == 6) then
            player:SendTrainerList(unit)
        elseif(intid == 7) then
            player:GossipComplete()
            player:CastSpell(player, 63264, true)
            local aura = player:GetAura(63264)
            aura:SetMaxDuration(-1)
            aura:SetDuration(-1)
        elseif(intid == 8) then
            player:SendListInventory(unit)
        elseif(intid == 9) then -- back button
            Beastmaster.OnHello(1, player, unit)
        end
    else
        player:GossipComplete()
    end
    return true
end

function Beastmaster.GenerateMenu(id, player, unit)
    local selection = player:GetData("_bm_menu_sel")
    if (not selection) then
        player:SendBroadcastMessage("[|cff4CFF00BeastMasterNPC|r]|cffff2020 Something went wrong.")
        return
    end

    local low = ((Beastmaster.maxObj*id)-Beastmaster.maxObj+1)
    local high = Beastmaster.maxObj*id
    
    player:GossipSetText(T[selection])
    
    -- Retrieve the current page sets' gossip option information.
    for i = low, high do
        local t = Beastmaster["Cache"][selection][i]
        
        if t then -- show "i" if only exists in the table
            -- Do not list gossip options with creatures above the players level.
            if(player:GetLevel() >= t["level"]) then
                player:GossipMenuAddItem(9, "Level: "..t["level"].." - "..t["name"], t["entry"], 1)
            end
        end
    end
    
    -- If the next menu has available objects and object is within player level, show Next button.
    if(Beastmaster["Cache"][selection][high+1]) and (player:GetLevel() >= Beastmaster["Cache"][selection][high+1]["level"]) then
        player:GossipMenuAddItem(4, "Next -->", id+1, 0)
    end
    
    -- If the menu is not the first menu, show Previous button.
    if(id == 1) then
        player:GossipMenuAddItem(7, "<-- Back", id, 9)
    else
        player:GossipMenuAddItem(4, "<-- Previous", id-1, 0)
    end
    
    player:GossipSendMenu(0x7FFFFFFF, unit)
end

function Beastmaster.LoadCache()
    Beastmaster["Cache"] = {
        [CACHE_NORMAL] = {},
        [CACHE_RARE] = {},
        [CACHE_EXOTIC] = {},
        [CACHE_EXOTIC_RARE] = {}
    }
    local Query
    
    if(GetCoreName() == "MaNGOS") then
        Query = WorldDBQuery("SELECT Entry, Name, MaxLevel CreatureTypeFlags, rank FROM creature_template WHERE CreatureType=1 AND CreatureTypeFlags&1 <> 0 AND Family!=0 ORDER BY MaxLevel ASC;")
    elseif(GetCoreName() == "TrinityCore" or GetCoreName() == "AzerothCore") then
        Query = WorldDBQuery("SELECT Entry, Name, MaxLevel, Type_Flags, rank FROM creature_template WHERE Type=1 AND Type_Flags&1 <> 0 AND Family!=0 ORDER BY MaxLevel ASC;")
    end
    
    if(Query) then
        repeat
            local npc = {
                entry = Query:GetUInt32(0),
                name = Query:GetString(1),
                level = Query:GetUInt32(2)
            };
            local flags = Query:GetUInt32(3)
            local rank = Query:GetUInt32(4)
            if (bit_and(flags,65536) ~= 0) then
                if (rank > 1 and rank < 5) then
                    table.insert(Beastmaster["Cache"][CACHE_EXOTIC_RARE], npc)
                else
                    table.insert(Beastmaster["Cache"][CACHE_EXOTIC], npc)
                end
            else
                if (rank > 1 and rank < 5) then
                    table.insert(Beastmaster["Cache"][CACHE_RARE], npc)
                else
                    table.insert(Beastmaster["Cache"][CACHE_NORMAL], npc)
                end
            end
        until not Query:NextRow()
        print("[Eluna Beastmaster]: Cache initialized. Loaded "..Query:GetRowCount().." total tameable beasts (ExoticRare:"..#Beastmaster["Cache"][CACHE_EXOTIC_RARE]..
        " Exotic:"..#Beastmaster["Cache"][CACHE_EXOTIC_RARE].." Rare:"..#Beastmaster["Cache"][CACHE_RARE].." Normal:"..#Beastmaster["Cache"][CACHE_NORMAL]..")")
    else
        print("[Eluna Beastmaster]: Cache initialized. No results found.")
    end
end

local function moduleAnnounce(event, player)
    player:SendBroadcastMessage("This server is running the |cff4CFF00BeastMasterNPC|r module.")
end

Beastmaster.LoadCache()
RegisterCreatureGossipEvent(Beastmaster.entry, 1, Beastmaster.OnHello)
RegisterCreatureGossipEvent(Beastmaster.entry, 2, Beastmaster.OnSelect)
if (AnnounceModule) then
    RegisterPlayerEvent(3, moduleAnnounce)   -- PLAYER_EVENT_ON_LOGIN
end
