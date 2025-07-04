--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/ocean03.png"
	
	local planetData = {
		name = "Baosezu",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.165,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.14,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Barren",
			radius = "5510 km",
			primary = "EL-5591",
			primaryType = "G8V",
			milRating = 1,
			feedbackLink = "https://zero-k.info/Forum/Thread/24457",
			text = "This world seems to have rebelled against their Empire, while it was too busy fighting on other fronts. They built formidable defenses, most of them still intact as the Empire cut them off instead of landing a punitive force."
			.. "\n "
			.. "\nSomehow, it has been enough to cripple them, and most of their mobile ground forces have disappeared."
			,
			extendedText = "Ground forces or not, they are sending Gunships out from behind a formidable defensive array - the blasted automata are taking me for an Imperial landing force. I have Crasher anti-air rovers to shoot down the gunships, then I can tear down their base with Impaler artillery."
		},
		tips = {
			{
				image = "unitpics/vehheavyarty.png",
				text = [[Impalers fire long-range cruise missiles which are very effective against turrets. They are practically useless against mobile targets so make sure they are well escorted against land and air threats.]]
			},
			{
				image = "unitpics/vehscout.png",
				text = [[Darts are equipped with a disruptor beam to harass and slow enemies. Their main use is as disposable scouts, discovering enemy locations and identifying radar dots.]]
			},
			{
				image = "unitpics/turretheavy.png",
				text = [[It would be sheer folly to directly attack the defensive positions your opponent has laid out here. Wear them down from long range instead.]]
			},
		},
		gameConfig = {
			mapName = "BlueBend-v01",
			playerConfig = {
				startX = 3550,
				startZ = 2250,
				allyTeam = 0,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factoryveh",
					"vehcon",
					"vehheavyarty",
					"vehaa",
					"vehscout",
					"turrettorp",
					"vehraid",
					"vehriot",
					"vehassault",
				},
				startUnits = {
					{
						name = "factoryveh",
						x = 3144,
						z = 2408,
						facing = 0,
					},
					{
						name = "staticradar",
						x = 900,
						z = 2050,
						facing = 0,
					},
					{
						name = "staticradar",
						x = 3200,
						z = 2000,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 2824,
						z = 2472,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 3080,
						z = 2040,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 2296,
						z = 1896,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 2408,
						z = 1416,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 3144,
						z = 728,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 3400,
						z = 808,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 2360,
						z = 376,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 1816,
						z = 632,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 1144,
						z = 1256,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 1176,
						z = 1656,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 968,
						z = 392,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1128,
						z = 1544,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1112,
						z = 1400,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1080,
						z = 1256,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1064,
						z = 1096,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1064,
						z = 920,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1032,
						z = 744,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1016,
						z = 600,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1032,
						z = 440,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1208,
						z = 728,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1368,
						z = 696,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1512,
						z = 664,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1672,
						z = 600,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1832,
						z = 536,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1960,
						z = 488,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 2072,
						z = 472,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 2216,
						z = 440,
						facing = 0,
					},
					{
						name = "turretaalaser",
						x = 1368,
						z = 1096,
						facing = 0,
					},
					{
						name = "turretaalaser",
						x = 2808,
						z = 440,
						facing = 0,
					},
					{
						name = "turretaalaser",
						x = 2888,
						z = 2216,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 2048,
						z = 2048,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 3168,
						z = 1104,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 3760,
						z = 368,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 3296,
						z = 2224,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 2992,
						z = 2592,
						facing = 0,
					},
					{
						name = "vehcon",
						x = 3500,
						z = 2150,
						facing = 0,
					},
					{
						name = "vehcon",
						x = 3600,
						z = 2150,
						facing = 0,
					},
					{
						name = "vehscout",
						x = 3450,
						z = 2030,
						facing = 0,
					},
					{
						name = "vehscout",
						x = 3550,
						z = 2030,
						facing = 0,
					},
					{
						name = "vehscout",
						x = 3650,
						z = 2030,
						facing = 0,
					},
					{
						name = "vehaa",
						x = 3450,
						z = 1900,
						facing = 0,
					},
					{
						name = "vehaa",
						x = 3550,
						z = 1900,
						facing = 0,
					},
					{
						name = "vehaa",
						x = 3650,
						z = 1900,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 2424,
						z = 456,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 2552,
						z = 520,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 2664,
						z = 552,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 2776,
						z = 584,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 2936,
						z = 648,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 3032,
						z = 728,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 3176,
						z = 824,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 3304,
						z = 872,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 2312,
						z = 1784,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 2344,
						z = 1656,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 2376,
						z = 1528,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 248,
						z = 744,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 168,
						z = 1336,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 120,
						z = 2312,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 256,
						z = 2656,
						facing = 0,
					},
					{
						name = "turretaalaser",
						x = 200,
						z = 1816,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 152,
						z = 808,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 120,
						z = 968,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 88,
						z = 1160,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 56,
						z = 1352,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 56,
						z = 1544,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 56,
						z = 1912,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 88,
						z = 2200,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 56,
						z = 2056,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 56,
						z = 1720,
						facing = 0,
					},
					{
						name = "staticcon",
						x = 2952,
						z = 2424,
						facing = 0,
						selfPatrol = true,
					},
					{
						name = "staticcon",
						x = 2952,
						z = 2328,
						facing = 0,
						selfPatrol = true,
					},
					{
						name = "staticcon",
						x = 3016,
						z = 2248,
						facing = 0,
						selfPatrol = true,
					},
					{
						name = "staticstorage",
						x = 2700,
						z = 2400,
						facing = 0,
					},
				}
			},
			aiConfig = {
				{
					startX = 6800,
					startZ = 6800,
					humanName = "Enemy",
					--aiLib = "Null AI",
					--bitDependant = false,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					commanderParameters = {
						facplop = false,
					},
					allyTeam = 1,
					unlocks = {
						"staticmex",
						"energywind",
						"staticradar",
						"staticstorage",
						--"staticcon",
						"gunshipcon",
						"gunshipbomb",
						"gunshipemp",
						"gunshipraid",
						"gunshipskirm",
						"gunshipheavyskirm",
						"gunshipaa",
						"factoryamph",
						"amphraid",
						"turretlaser",
						"turretmissile"
					},
					difficultyDependantUnlocks = {
						[1] = {"staticcon"},
						[2] = {"staticcon","amphimpulse","amphriot","gunshipassault"},
						[3] = {"staticcon","amphimpulse","amphriot","gunshipassault","turretriot","turretheavylaser"},
						[4] = {"amphimpulse","amphriot","gunshipassault","turretriot","amphfloater","turretheavylaser"}, --leaving out caretaker makes the mission *harder* - go figure
					},
					commanderLevel = 2,
					commander = {
						name = "Most Loyal Opposition",
						chassis = "recon",
						decorations = {
						},
						modules = { "commweapon_lparticlebeam",
									"module_ablative_armor",
									"module_autorepair" }
					},
					startUnits = {
						{
							name = "factorygunship",
							x = 5096,
							z = 5336,
							facing = 0,
							difficultyAtMost = 2,
							mapMarker = {
								text = "Gunship Plant",
								color = "red"
							},
						},
						{
							name = "factorygunship",
							x = 6312,
							z = 6168,
							facing = 0,
							difficultyAtLeast = 3,
							mapMarker = {
								text = "Gunship Plant",
								color = "red"
							},
						},
						{
							name = "staticcon",
							x = 5096,
							z = 5464,
							facing = 0,
							difficultyAtMost = 2,
						},
						{
							name = "staticcon",
							x = 5224,
							z = 5320,
							facing = 0,
							difficultyAtLeast = 2,
							difficultyAtMost = 2,
						},
						{
							name = "staticcon",
							x = 6312,
							z = 6280,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "staticcon",
							x = 6440,
							z = 6168,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "gunshipcon",
							x = 6000,
							z = 6000,
							facing = 0,
						},
						{
							name = "gunshipcon",
							x = 5900,
							z = 6000,
							facing = 0,
							difficultyAtLeast = 2,
						},
						{
							name = "gunshipcon",
							x = 5800,
							z = 6000,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "gunshipcon",
							x = 5700,
							z = 6000,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "staticmex",
							x = 4520,
							z = 5830,
							facing = 0,
							difficultyAtLeast = 2,
						},
						{
							name = "staticmex",
							x = 5990,
							z = 4390,
							facing = 0,
							difficultyAtLeast = 2,
						},
						{
							name = "staticmex",
							x = 3190,
							z = 6530,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "staticmex",
							x = 6300,
							z = 3020,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "staticmex",
							x = 6935,
							z = 233,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "staticmex",
							x = 6900,
							z = 500,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "turretlaser",
							x = 6800,
							z = 400,
							facing = 3,
							difficultyAtLeast = 4,
						},
						{
							name = "staticmex",
							x = 1800,
							z = 6855,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "staticmex",
							x = 6936,
							z = 6872,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6664,
							z = 6312,
							facing = 0,
						},
						{
							name = "energyfusion",
							x = 7128,
							z = 6928,
							facing = 0,
						},
						{
							name = "energyfusion",
							x = 6952,
							z = 7104,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6632,
							z = 6584,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6168,
							z = 6072,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6152,
							z = 5176,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 5256,
							z = 6312,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6392,
							z = 4280,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6504,
							z = 3576,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 4392,
							z = 6472,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 3736,
							z = 6616,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 5368,
							z = 5464,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 4984,
							z = 5128,
							facing = 0,
						},
						{
							name = "turretheavy",
							x = 4760,
							z = 4792,
							facing = 0,
						},
						{
							name = "turretheavy",
							x = 3688,
							z = 6472,
							facing = 0,
						},
						{
							name = "turretheavy",
							x = 6344,
							z = 3480,
							facing = 0,
						},
						{
							name = "turretheavylaser",
							x = 4232,
							z = 5752,
							facing = 0,
						},
						{
							name = "turretheavylaser",
							x = 5688,
							z = 4136,
							facing = 0,
						},
						{
							name = "turretheavylaser",
							x = 5864,
							z = 2488,
							facing = 0,
						},
						{
							name = "turretheavylaser",
							x = 3048,
							z = 5832,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 2872,
							z = 5592,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 2920,
							z = 5992,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 3256,
							z = 5800,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 5768,
							z = 2600,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 5992,
							z = 2424,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 4840,
							z = 5576,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 5352,
							z = 5000,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 2360,
							z = 6840,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 5096,
							z = 3768,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 3832,
							z = 5096,
							facing = 0,
						},
						{
							name = "turretaafar",
							x = 6480,
							z = 6384,
							facing = 0,
						},
						{
							name = "turretaalaser",
							x = 4200,
							z = 6200,
							facing = 0,
						},
						{
							name = "turretaalaser",
							x = 4696,
							z = 5096,
							facing = 0,
						},
						{
							name = "turretaalaser",
							x = 6184,
							z = 4072,
							facing = 0,
						},
						{
							name = "turretaaclose",
							x = 5192,
							z = 5128,
							facing = 0,
						},
						{
							name = "turretaaclose",
							x = 6552,
							z = 6136,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 7128,
							z = 6696,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 6696,
							z = 7112,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 7080,
							z = 6472,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 6568,
							z = 6936,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 6416,
							z = 6736,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 6256,
							z = 6368,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 6816,
							z = 6224,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 4600,
							z = 7016,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 4840,
							z = 5256,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 5448,
							z = 4728,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6888,
							z = 4536,
							facing = 0,
						},
					}
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = { },
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalCommanders = false,
					vitalUnitTypes = {
						"factorygunship",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy the enemy Gunship Plant",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				[1] = {
					satisfyOnce = true,
					countRemovedUnits = true, -- count units that previously died.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 6,
					unitTypes = {
						"vehheavyarty",
					},
					image = planetUtilities.ICON_DIR .. "vehheavyarty.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build 6 Impalers",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Have 30 Metal Extractors by 9:00
					satisfyByTime = 540,
					capturedUnitsSatisfy = true,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 30,
					unitTypes = {
						"staticmex",
					},
					image = planetUtilities.ICON_DIR .. "staticmex.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Have 30 Metal Extractors by 9:00",
					experience = planetUtilities.BONUS_EXP,
				},
				[3] = { -- Destroy all three DDMs
					satisfyOnce = true,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 0,
					enemyUnitTypes = {
						"turretheavy",
					},
					image = planetUtilities.ICON_DIR .. "turretheavy.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Destroy all enemy Desolator turrets",
					experience = planetUtilities.BONUS_EXP,
				},
				-- [3] = { -- Win by 15:00
					-- victoryByTime = 900,
					-- image = planetUtilities.ICON_OVERLAY.CLOCK,
					-- description = "Win by 15:00",
					-- experience = planetUtilities.BONUS_EXP,
				-- },
			},
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"vehheavyarty",
				"vehaa",
				"vehscout",
			},
			modules = {
				"module_adv_targeting_LIMIT_A_2",
			},
			abilities = {
			},
			codexEntries = {
				"location_baosezu",
				"quadrant_celestial_arm",
			},
		},
	}
	
	return planetData
end

return GetPlanet
