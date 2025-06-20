--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	--local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	local image = LUA_DIRNAME .. "images/planets/inferno03.png"
	
	local planetData = {
		name = "Skokukur",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.24,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.33,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Volcanic",
			radius = "1775 km",
			primary = "Jayadu A/B",
			primaryType = "F9V/F9V",
			milRating = 1,
			feedbackLink = "https://zero-k.info/Forum/Thread/24457",
			text = "This world appears to have been prosperous, once. But a series of violent uprisings and punitive expeditions have reduced it to a barely inhabitable, glassy ashball."
			.. "\n "
			.. "\nIt is so covered with wrecks that most of its industry, or what was left of it, appears to have been recycling them."
			,
			extendedText = "This planet has been the focus of so many battles, it is now littered with scrap. The self-replicating Puppy walking bombs can quickly turn these wrecks into a new army for me."
		},
		tips = {
			{
				image = "unitpics/jumpraid.png",
				text = [[The Constable and Pyro have jumpjets to get over obstacles and move around more quickly. The default jump hotkey is J.]]
			},
			{
				image = "unitpics/jumpscout.png",
				text = [[Puppies are suicidal missiles on legs. If a Puppy stands next to a unit wreck, it will convert the wreck into more Puppies. Use the Economy view (default hotkey F4) to highlight wrecks.]]
			},
			{
				image = "unitpics/jumpblackhole.png",
				text = [[Placeholders create gravitational anomalies which pull nearby units into the centre until the anomaly dissipates. Use them to keep enemies away from your longer-range units and turrets, and to make enemies more vulnerable to area-of-effect attacks.]]
			},
		},
		gameConfig = {
			mapName = "TartarusV7",
			playerConfig = {
				startX = 550,
				startZ = 1850,
				allyTeam = 0,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factoryjump",
					"jumpcon",
					"jumpraid",
					"jumpscout",
					"jumpblackhole",
				},
				startUnits = {
					{
						name = "jumpscout",
						x = 700,
						z = 1950,
						facing = 1,
						commands = {
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {1350, 1900}},
						},
					},
					{
						name = "jumpscout",
						x = 700,
						z = 2000,
						facing = 1,
						commands = {
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {1350, 1900}},
						},
					},
					{
						name = "jumpscout",
						x = 700,
						z = 2050,
						facing = 1,
						commands = {
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {1350, 1900}},
						},
					},
					{
						name = "jumpscout",
						x = 700,
						z = 2100,
						facing = 1,
						commands = {
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {1350, 1900}},
						},
					},
					{
						name = "jumpscout",
						x = 700,
						z = 2150,
						facing = 1,
						commands = {
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {1350, 1900}},
						},
					},
					{
						name = "jumpblackhole",
						x = 800,
						z = 3500,
						facing = 1,
					},
					{
						name = "jumpraid",
						x = 800,
						z = 3600,
						facing = 1,
					},
					{
						name = "jumpblackhole",
						x = 1250,
						z = 1150,
						facing = 1,
					},
					{
						name = "jumpraid",
						x = 1230,
						z = 1250,
						facing = 1,
					},
					{
						name = "jumpblackhole",
						x = 1260,
						z = 1340,
						facing = 1,
					},
					{
						name = "jumpcon",
						x = 250,
						z = 2250,
						facing = 1,
					},
					{
						name = "jumpcon",
						x = 350,
						z = 2250,
						facing = 1,
					},
					{
						name = "factoryjump",
						x = 392,
						z = 2104,
						facing = 1,
					},
 					{
						name = "staticmex",
						x = 136,
						z = 1864,
						facing = 1,
					},
 					-- {
						-- name = "staticmex",
						-- x = 920,
						-- z = 840,
						-- facing = 0,
					-- },
 					{
						name = "staticmex",
						x = 312,
						z = 3640,
						facing = 0,
					},
 					{
						name = "staticmex",
						x = 616,
						z = 3944,
						facing = 0,
					},
 					{
						name = "staticradar",
						x = 544,
						z = 2672,
						facing = 0,
					},
 					{
						name = "energysolar",
						x = 344,
						z = 3768,
						facing = 1,
					},
 					{
						name = "turretlaser",
						x = 1120,
						z = 864,
						facing = 1,
					},
 					{
						name = "staticradar",
						x = 912,
						z = 1104,
						facing = 1,
					},
 					{
						name = "staticcon",
						x = 296,
						z = 2104,
						facing = 1,
						commands = {
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {296, 2104}},
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {321, 2079}, options = {"shift"}},
						},
					},
 					{
						name = "turretlaser",
						x = 928,
						z = 1856,
						facing = 1,
					},
 					{
						name = "turretlaser",
						x = 1056,
						z = 2144,
						facing = 1,
					},
 					{
						name = "energysolar",
						x = 200,
						z = 1880,
						facing = 0,
					},
 					{
						name = "energysolar",
						x = 120,
						z = 1928,
						facing = 3,
					},
 					{
						name = "turretlaser",
						x = 656,
						z = 2704,
						facing = 1,
					},
 					{
						name = "energysolar",
						x = 72,
						z = 1848,
						facing = 2,
					},
 					{
						name = "turretlaser",
						x = 704,
						z = 3344,
						facing = 1,
					},
 					{
						name = "turretlaser",
						x = 752,
						z = 3680,
						facing = 1,
					},
 					{
						name = "energysolar",
						x = 152,
						z = 1800,
						facing = 1,
					},
 					{
						name = "energysolar",
						x = 488,
						z = 3896,
						facing = 1,
					},
				}
			},
			aiConfig = {
				{
					startX = 4000,
					startZ = 3400,
					humanName = "Jasmine",
					--aiLib = "Null AI",
					--bitDependant = false,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					commanderParameters = {
						facplop = false,
						bonusObjectiveID = 3,
					},
					allyTeam = 1,
					unlocks = {
						"staticmex",
						"staticcon",
						"energysolar",
						"energywind",
						"vehcon",
						"vehscout",
						"vehraid",
						"vehsupport",
						"vehaa",
						"spiderassault",
						"spiderskirm",
					},
					commanderLevel = 3,
					commander = {
						name = "Barasogus",
						chassis = "guardian",
						modules = {
							"commweapon_flamethrower",
							"module_autorepair",
							"module_ablative_armor",
							"module_ablative_armor",
							"module_high_power_servos",
							"module_high_power_servos",
						}
					},
					startUnits = {
						{
							name = "turretlaser",
							x = 3400,
							z = 2000,
							facing = 3,
						},
						{
							name = "turretlaser",
							x = 3400,
							z = 2200,
							facing = 3,
						},
						{
							name = "turretmissile",
							x = 3584,
							z = 1200,
							facing = 3,
						},
 						{
							name = "staticmex",
							x = 3688,
							z = 3960,
							facing = 2,
						},
 						{
							name = "staticmex",
							x = 3912,
							z = 3768,
							facing = 2,
							difficultyAtLeast = 2,
						},
 						{
							name = "energywind",
							x = 3784,
							z = 3912,
							facing = 2,
						},
 						{
							name = "energywind",
							x = 3864,
							z = 3848,
							facing = 2,
						},
 						{
							name = "factoryspider",
							x = 3600,
							z = 3000,
							facing = 3,
						},
 						{
							name = "energywind",
							x = 3880,
							z = 3944,
							facing = 3,
						},
 						{
							name = "staticmex",
							x = 3496,
							z = 264,
							facing = 1,
						},
 						{
							name = "staticmex",
							x = 3784,
							z = 504,
							facing = 1,
							difficultyAtLeast = 3,
						},
 						{
							name = "energysolar",
							x = 3608,
							z = 312,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 3720,
							z = 408,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 3512,
							z = 408,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 3640,
							z = 504,
							facing = 1,
						},
 						{
							name = "vehcon",
							x = 3581,
							z = 1058,
							facing = 0,
						},
						{
							name = "vehraid",
							x = 3000,
							z = 1000,
							facing = 0,
						},
						{
							name = "vehraid",
							x = 3000,
							z = 1100,
							facing = 0,
							difficultyAtLeast = 2,
						},
						{
							name = "vehraid",
							x = 3000,
							z = 1200,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "vehraid",
							x = 3000,
							z = 1300,
							facing = 0,
							difficultyAtLeast = 4,
						},
 						{
							name = "energywind",
							x = 3944,
							z = 3880,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 3800,
							z = 4008,
							facing = 1,
						},
 						{
							name = "factoryveh",
							x = 3400,
							z = 696,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 3264,
							z = 400,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 3440,
							z = 960,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 3760,
							z = 3728,
							facing = 3,
						},
 						{
							name = "turretmissile",
							x = 3232,
							z = 128,
							facing = 3,
						},
 						{
							name = "turretmissile",
							x = 3824,
							z = 640,
							facing = 3,
						},
 						{
							name = "turretmissile",
							x = 3248,
							z = 3952,
							facing = 3,
						},
 						{
							name = "turretmissile",
							x = 3312,
							z = 2800,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 4008,
							z = 3992,
							facing = 3,
						},
 						{
							name = "turretheavylaser",
							x = 2952,
							z = 3112,
							facing = 3,
						},
 						{
							name = "turretheavylaser",
							x = 3208,
							z = 1416,
							facing = 3,
						},
 						{
							name = "turretaaclose",
							x = 3832,
							z = 3416,
							facing = 3,
						},
 						{
							name = "turretaalaser",
							x = 3736,
							z = 888,
							facing = 3,
						},
 						{
							name = "spiderassault",
							x = 4071,
							z = 3696,
							facing = 1,
							difficultyAtLeast = 2,
						},
 						{
							name = "spiderassault",
							x = 3971,
							z = 3752,
							facing = 1,
							difficultyAtLeast = 3,
						},
 						{
							name = "spiderassault",
							x = 4078,
							z = 3776,
							facing = 0,
							difficultyAtLeast = 4,
						},
 						{
							name = "spiderskirm",
							x = 4023,
							z = 3682,
							facing = 3,
							difficultyAtLeast = 3,
						},
 						{
							name = "spiderskirm",
							x = 4036,
							z = 3768,
							facing = 1,
							difficultyAtLeast = 4,
						},
 						{
							name = "vehsupport",
							x = 2953,
							z = 733,
							facing = 3,
						},
 						{
							name = "vehsupport",
							x = 3017,
							z = 850,
							facing = 3,
							difficultyAtLeast = 2,
						},
 						{
							name = "vehsupport",
							x = 3041,
							z = 936,
							facing = 3,
							difficultyAtLeast = 3,
						},
 						{
							name = "vehcon",
							x = 3624,
							z = 1034,
							facing = 0,
							difficultyAtLeast = 3,
						},
					}
				},
			},
			initialWrecks = {
				{
					name = "factoryplane_dead",
					x = 240,
					z = 208,
					facing = 0,
				},
				{
					name = "staticmex_dead",
					x = 216,
					z = 440,
					facing = 0,
				},
				{
					name = "staticmex_dead",
					x = 1976,
					z = 1544,
					facing = 0,
				},
				{
					name = "staticmex_dead",
					x = 1736,
					z = 2488,
					facing = 0,
				},
				{
					name = "staticmex_dead",
					x = 2264,
					z = 2568,
					facing = 0,
				},
				{
					name = "staticmex_dead",
					x = 2216,
					z = 3400,
					facing = 0,
				},
				{
					name = "staticmex_dead",
					x = 504,
					z = 184,
					facing = 0,
				},
				{
					name = "turretlaser_dead",
					x = 896,
					z = 176,
					facing = 0,
				},
				{
					name = "turretlaser_dead",
					x = 128,
					z = 640,
					facing = 0,
				},
				{
					name = "tankassault_dead",
					x = 1341,
					z = 2720,
					facing = 0,
				},
				{
					name = "tankassault_dead",
					x = 2700,
					z = 1400,
					facing = 1,
				},
				{
					name = "tankraid_dead",
					x = 2800,
					z = 2600,
					facing = 3,
				},
				{
					name = "tankraid_dead",
					x = 3730,
					z = 1900,
					facing = 3,
				},
				{
					name = "tankheavyraid_dead",
					x = 3900,
					z = 2120,
					facing = 3,
				},
				{
					name = "amphtele_dead",
					x = 1400,
					z = 1900,
					facing = 0,
				},
				{
					name = "tankassault_dead",
					x = 1375,
					z = 3113,
					facing = 3,
				},
				{
					name = "striderdante_dead",
					x = 3455,
					z = 2113,
					facing = 1,
				},
				{
					name = "staticmex_dead",
					x = 2088,
					z = 760,
					facing = 0,
				},
				{
					name = "factorytank_dead",
					x = 2192,
					z = 1232,
					facing = 0,
				},
				{
					name = "athena_dead",
					x = 2035,
					z = 3720,
					facing = 2,
				},
				{
					name = "tankheavyraid_dead",
					x = 2363,
					z = 3705,
					facing = 1,
				},
				{
					name = "tankheavyraid_dead",
					x = 2671,
					z = 2276,
					facing = 3,
				},
				{
					name = "tankheavyraid_dead",
					x = 2064,
					z = 400,
					facing = 2,
				},
				{
					name = "tankarty_dead",
					x = 2436,
					z = 1442,
					facing = 0,
				},
				{
					name = "cloakheavyraid_dead",
					x = 242,
					z = 3691,
					facing = 1,
				},
				{
					name = "cloakheavyraid_dead",
					x = 213,
					z = 3573,
					facing = 1,
				},
				{
					name = "cloakheavyraid_dead",
					x = 289,
					z = 3464,
					facing = 0,
				},
				{
					name = "cloakheavyraid_dead",
					x = 200,
					z = 3800,
					facing = 1,
				},
				{
					name = "cloakheavyraid_dead",
					x = 180,
					z = 3900,
					facing = 1,
				},
				{
					name = "cloakheavyraid_dead",
					x = 90,
					z = 4000,
					facing = 2,
				},
				{
					name = "cloakassault_dead",
					x = 1000,
					z = 3800,
					facing = 3,
				},
				{
					name = "cloakassault_dead",
					x = 1074,
					z = 3720,
					facing = 3,
				},
				{
					name = "vehheavyarty_dead",
					x = 1600,
					z = 3480,
					facing = 3,
				},
				{
					name = "cloakassault_dead",
					x = 1224,
					z = 3411,
					facing = 3,
				},
				{
					name = "spiderskirm_dead",
					x = 3000,
					z = 2700,
					facing = 3,
				},
				{
					name = "spiderskirm_dead",
					x = 3340,
					z = 2760,
					facing = 3,
				},
				{
					name = "spiderskirm_dead",
					x = 3450,
					z = 2500,
					facing = 3,
				},
				{
					name = "spiderskirm_dead",
					x = 3800,
					z = 2720,
					facing = 3,
				},
				{
					name = "cloakassault_dead",
					x = 2224,
					z = 2976,
					facing = 3,
				},
				{
					name = "cloakassault_dead",
					x = 2357,
					z = 877,
					facing = 2,
				},
				{
					name = "shieldraid_dead",
					x = 1764,
					z = 2803,
					facing = 1,
				},
				{
					name = "shieldraid_dead",
					x = 1769,
					z = 1491,
					facing = 2,
				},
				{
					name = "shieldraid_dead",
					x = 1823,
					z = 1358,
					facing = 1,
				},
				{
					name = "shieldraid_dead",
					x = 1765,
					z = 1238,
					facing = 3,
				},
				{
					name = "shieldraid_dead",
					x = 1771,
					z = 1157,
					facing = 2,
				},
				{
					name = "shieldraid_dead",
					x = 1633,
					z = 1076,
					facing = 1,
				},
				{
					name = "shieldraid_dead",
					x = 2010,
					z = 2907,
					facing = 0,
				},
				{
					name = "striderantiheavy_dead",
					x = 1308,
					z = 78,
					facing = 1,
				},
				{
					name = "jumpskirm_dead",
					x = 2310,
					z = 1242,
					facing = 3,
				},
				{
					name = "jumpskirm_dead",
					x = 2266,
					z = 3665,
					facing = 0,
				},
				{
					name = "jumpskirm_dead",
					x = 2385,
					z = 3892,
					facing = 3,
				},
				{
					name = "hoverassault_dead",
					x = 2489,
					z = 215,
					facing = 3,
				},
				{
					name = "hoverassault_dead",
					x = 2589,
					z = 172,
					facing = 3,
				},
				{
					name = "hoverassault_dead",
					x = 2545,
					z = 419,
					facing = 3,
				},
				{
					name = "tankheavyarty_dead",
					x = 2500,
					z = 1660,
					facing = 2,
				},
			},
			defeatConditionConfig = {
				[0] = { },
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalCommanders = false,
					vitalUnitTypes = {
						"factoryspider",
						"factoryveh",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				[1] = {
					description = "Destroy the enemy Factories",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				[1] = { -- Have 100 Puppies by 3:00
					satisfyByTime = 4*60,
					countRemovedUnits = true,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 105,
					unitTypes = {
						"jumpscout",
					},
					image = planetUtilities.ICON_DIR .. "jumpscout.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build or spawn 100 Puppies before 4:00",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Make the enemy lose one factory by 6:00
					onlyCountRemovedUnits = true,
					satisfyByTime = 360,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 1,
					enemyUnitTypes = {
						"factoryspider",
						"factoryveh"
					},
					image = planetUtilities.ICON_DIR .. "factoryveh.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Destroy an enemy Factory before 6:00",
					experience = planetUtilities.BONUS_EXP,
				},
				[3] = { -- Kill enemy commander
					satisfyOnce = true,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 0,
					-- See bonusObjectiveID in units table
					image = planetUtilities.ICON_DIR .. "skin_recon_red.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Destroy the enemy Commander",
					experience = planetUtilities.BONUS_EXP,
				},
			},
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"jumpscout",
				"jumpblackhole",
			},
			modules = {
				"commweapon_flamethrower",
			},
			codexEntries = {
				"location_skokukur"
			}
		},
	}
	
	return planetData
end

return GetPlanet
