-- --------------------------------------------------------------------------------------
--    BEASTMASTER NPC - 601026
-- --------------------------------------------------------------------------------------
SET
@Entry        := 601026,
@TrainerEntry := 998,
@Model        := 26314, -- Northrend Worgen White
@Name         := "White Fang",
@Title        := "BeastMaster",
@Icon         := "Trainer",
@GossipMenu   := 0,
@MinLevel     := 80,
@MaxLevel     := 80,
@Faction      := 35,
@NPCFlag      := 4194481,
@Scale        := 1.0,
@Rank         := 2,
@Type         := 7,
@TypeFlags    := 134217728,
@FlagsExtra   := 2,
@AIName       := "PassiveAI",
@HealthMod    := 6,
@Script       := "";

-- NPC
DELETE FROM world.creature_template WHERE entry = @Entry;
INSERT INTO world.creature_template (entry, modelid1, name, subname, IconName, gossip_menu_id, minlevel, maxlevel, faction, npcflag, scale, rank, unit_class, unit_flags, unit_flags2, type, type_flags, flags_extra, AiName, MovementType, HealthModifier, ScriptName) VALUES
(@Entry, @Model, @Name, @Title, @Icon, @GossipMenu, @MinLevel, @MaxLevel, @Faction, @NPCFlag, @Scale, @Rank, 1, 768, 2048, @Type, @TypeFlags, @FlagsExtra, @AIName, 0, @HealthMod, @Script);

-- NPC EQUIPPED
DELETE FROM world.creature_equip_template WHERE CreatureID=@Entry AND ID=1;
INSERT INTO world.creature_equip_template (CreatureID, ID, ItemID1, ItemID2, ItemID3) VALUES (@Entry, 1, 2196, 1906, 0); -- Haunch of Meat (2196), Torch (1906)

-- NPC TEXT
-- DELETE FROM `npc_text` WHERE `ID`=@Entry;
-- INSERT INTO `npc_text` (`ID`, `text0_0`) VALUES (@Entry, 'Greetings, $N. If you are looking for a trustful companion on your travels you have come to the right place. I can offer you a variety of tamed pets for you to choose from. If necessary I can also teach you the ways of the hunter so that you can take good care of your pet.');

-- HUNTER TRAINER

DELETE FROM world.trainer_spell WHERE TrainerId=@TrainerEntry;
INSERT INTO world.trainer_spell (TrainerId, SpellId, MoneyCost, ReqSkillLine, ReqSkillRank, ReqAbility1, ReqAbility2, ReqAbility3, ReqLevel) 
SELECT @TrainerEntry, SpellId, MoneyCost, ReqSkillLine, ReqSkillRank, ReqAbility1, ReqAbility2, ReqAbility3, ReqLevel FROM world.trainer_spell WHERE TrainerId = 7;
INSERT INTO world.trainer_spell (TrainerId, SpellId, MoneyCost, ReqSkillLine, ReqSkillRank, ReqAbility1, ReqAbility2, ReqAbility3, ReqLevel) VALUES 
(@TrainerEntry, 1515, 0, 0, 0, 0, 0, 0, 10), -- Tame Beast
(@TrainerEntry, 883, 0, 0, 0, 0, 0, 0, 10),  -- Call Pet
(@TrainerEntry, 2641, 0, 0, 0, 0, 0, 0, 10), -- Dismiss Pet
(@TrainerEntry, 982, 0, 0, 0, 0, 0, 0, 10),  -- Revive Pet
(@TrainerEntry, 6991, 0, 0, 0, 0, 0, 0, 10); -- Feed Pet
DELETE FROM world.trainer WHERE Id=@TrainerEntry;
INSERT INTO world.trainer (Id, Type, Requirement, Greeting) 
SELECT @TrainerEntry, Type, Requirement, Greeting FROM world.trainer WHERE Id = 7;
DELETE FROM world.trainer_locale WHERE Id=@TrainerEntry;
INSERT INTO world.trainer_locale (Id, locale, Greeting_lang) 
SELECT @TrainerEntry, locale, Greeting_lang FROM world.trainer_locale WHERE Id = 7;
DELETE FROM world.creature_default_trainer WHERE CreatureId = @Entry;
INSERT INTO world.creature_default_trainer (CreatureId, TrainerId) VALUES (@Entry, @TrainerEntry);

-- NPC ITEMS
DELETE FROM world.npc_vendor WHERE entry = @Entry;
INSERT INTO world.npc_vendor (entry, item) VALUES 
-- MEAT
(@Entry,35953), -- (75) -- Mead Blasted Caribou 
(@Entry,33454), -- (65) -- Salted Venison 
(@Entry,27854), -- (55) -- Smoked Talbuk Venison
(@Entry,8952),  -- (45) -- Roasted Quail 
(@Entry,4599),  -- (35) -- Cured Ham Steak  
(@Entry,3771),  -- (25) -- Wild Hog Shank 
(@Entry,3770),  -- (15) -- Mutton Chop
(@Entry,2287),  -- (5)  -- Haunch of Meat
(@Entry,117),   -- (1)  -- Tough Jerky
-- FUNGUS
(@Entry,35947), -- (75) -- Sparkling Frostcap
(@Entry,33452), -- (65) -- Honey-Spiced Lichen 
(@Entry,27859), -- (55) -- Zangar Caps
(@Entry,8948),  -- (45) -- Dried King Bolete
(@Entry,4608),  -- (35) -- Raw Black Truffle 
(@Entry,4607),  -- (25) -- Delicious Cave Mold
(@Entry,4606),  -- (15) -- Spongy Morel
(@Entry,4605),  -- (5)  -- Red-Speckled Mushroom 
(@Entry,4604),  -- (1)  -- Forest Mushroom Cap
-- BREAD
(@Entry,35950), -- (75) -- Sweet Potato Bread
(@Entry,33449), -- (65) -- Crusty Flatbread
(@Entry,27855), -- (55) -- Mag'har Grainbread
(@Entry,8950),  -- (45) -- Homemade Cherry Pie
(@Entry,4601),  -- (35) -- Soft Banana Bread
(@Entry,4544),  -- (25) -- Mulgore Spice Bread
(@Entry,4542),  -- (15) -- Moist Cornbread
(@Entry,4541),  -- (5)  -- Freshly Baked Bread
(@Entry,4540),  -- (1)  -- Tough Hunk of Bread
-- FRUIT
(@Entry,35948), -- (75) -- Savory Snowplum
(@Entry,35949), -- (65) -- Tundra Berries
(@Entry,27856), -- (55) -- Sklethyl Berries
(@Entry,8953),  -- (45) -- Deep Fried Plantains
(@Entry,4602),  -- (35) -- Moon Harvest Pumpkin
(@Entry,4539),  -- (25) -- Goldenbark Apple
(@Entry,4538),  -- (15) -- Snapvine Watermelon
(@Entry,4537),  -- (5)  -- Tel'Abim Banana
(@Entry,4536),  -- (1)  -- Shiny Red Apple
-- FISH
(@Entry,35951), -- (75) -- Poached Emperor Salmon
(@Entry,33451), -- (65) -- Filet of Icefin
(@Entry,27858), -- (55) -- Sunspring Carp
(@Entry,8957),  -- (45) -- Spinefin Halibut
(@Entry,21552), -- (35) -- Striped Yellowtail
(@Entry,4594),  -- (25) -- Rockscale Cod
(@Entry,4593),  -- (15) -- Bristle Whisker Catfish
(@Entry,4592),  -- (5)  -- Longjaw Mud Snapper
(@Entry,787),   -- (1)  -- Slitherskin Mackeral
-- CHEESE
(@Entry,35952), -- (75) -- Briny Hardcheese
(@Entry,33443), -- (65) -- Sour Goat Cheese
(@Entry,27857), -- (55) -- Gradar Sharp
(@Entry,8932),  -- (45) -- Alterac Swiss
(@Entry,3927),  -- (35) -- Fine Aged Chedder
(@Entry,1707),  -- (25) -- Stormwind Brie
(@Entry,422),   -- (15) -- Dwarven Mild
(@Entry,414),   -- (5)  -- Dalaran Sharp
(@Entry,2070),  -- (1)  -- Darnassian Bleu
-- BUFF
(@Entry,33875), -- Kibler's Bits
-- RARE
(@Entry,21024); -- Chimaerok Tenderloin
