--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	--local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	local image = LUA_DIRNAME .. "images/planets/terran04.png"
	
	local planetData = {
		name = "New Falsell",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.06,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.26,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "5288 km",
			primary = "Omis",
			primaryType = "G7V",
			milRating = 1,
			feedbackLink = "https://zero-k.info/Forum/Thread/24429",
			text = "There is something very strange on this world. Some kind of artefact, I have never seen anything like it. Could it hold answers about what happened to everyone? I need to get closer."
			.. "\n "
			.. "\nIt is heavily defended, direct assault would be a bad idea. Maybe I can find some weakness in those defenses..."
			,
			extendedText = "Frontal attack would be suicidal, but most of it is static defenses. If I can infiltrate Phantom sniper bots and destroy their Singularity Plants, it will deactivate the heavier defenses."
			.. "\n "
			.. "\nI should not let my guard down, some mobile forces are still active. And there is something very strange with their data flux..."
		},
		tips = {
			{
				image = "unitpics/cloaksnipe.png",
				text = [[Unlike all other cloaked units, the Phantom can fire its weapon without becoming visible. Use this to sneak into the defense network, destroying what you need to without blowing your cover.]]
			},
			{
				image = "unitpics/turretheavy.png",
				text = [[Heavier turrets cannot fire unless they are connected to energy-producing buildings. Deactivate them by destroying the connecting Energy Pylons or the energy producers themselves.]]
			},
			{
				image = "unitpics/shieldfelon.png",
				text = [[You will need to defend your southern flank against Interloper Shieldbot attacks. The Felon is a dangerous opponent but a Sniper can easily pierce its shields.]]
			},
		},
		gameConfig = {
			mapName = "The river Nix 20",
			playerConfig = {
				startX = 1000,
				startZ = 7000,
				allyTeam = 0,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
					victoryAtLocation = {
						x = 6025,
						z = 2625,
						radius = 120,
						objectiveID = 1,
					},
				},
				extraUnlocks = {
					"cloaksnipe",
				},
				startUnits = {
					{
						name = "staticmex",
						x = 888,
						z = 6824,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 600,
						z = 6776,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 648,
						z = 7064,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 712,
						z = 7080,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 632,
						z = 7128,
						facing = 3,
					},
					{
						name = "energysolar",
						x = 584,
						z = 7048,
						facing = 2,
					},
					{
						name = "energysolar",
						x = 664,
						z = 7000,
						facing = 1,
					},
					{
						name = "energysolar",
						x = 952,
						z = 6840,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 872,
						z = 6888,
						facing = 3,
					},
					{
						name = "energysolar",
						x = 824,
						z = 6808,
						facing = 2,
					},
					{
						name = "energysolar",
						x = 904,
						z = 6760,
						facing = 1,
					},
					{
						name = "turretlaser",
						x = 2064,
						z = 8992,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 2448,
						z = 8880,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 664,
						z = 6792,
						facing = 0,
					},
					{
						name = "staticradar",
						x = 2240,
						z = 8848,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 584,
						z = 6840,
						facing = 3,
					},
					{
						name = "energysolar",
						x = 536,
						z = 6760,
						facing = 2,
					},
					{
						name = "energysolar",
						x = 616,
						z = 6712,
						facing = 1,
					},
					{
						name = "factorycloak",
						x = 1128,
						z = 6696,
						facing = 1,
					},
					{
						name = "cloakcon",
						x = 1205,
						z = 6937,
						facing = 0,
					},
					{
						name = "cloakcon",
						x = 1124,
						z = 6918,
						facing = 0,
					},
					{
						name = "cloaksnipe",
						x = 3060,
						z = 5780,
						facing = 1,
					},
					{
						name = "cloaksnipe",
						x = 3060,
						z = 6040,
						facing = 1,
					},
					{
						name = "cloaksnipe",
						x = 2200,
						z = 8960,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 3312,
						z = 6624,
						facing = 1,
					},
					{
						name = "staticradar",
						x = 2928,
						z = 6224,
						facing = 0,
					},
					{
						name = "staticradar",
						x = 672,
						z = 6432,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 3312,
						z = 6240,
						facing = 1,
					},
					{
						name = "turretlaser",
						x = 3296,
						z = 5584,
						facing = 1,
					},
					{
						name = "turretlaser",
						x = 3296,
						z = 5184,
						facing = 1,
					},
				}
			},
			aiConfig = {
				{
					--aiLib = "Null AI",
					--bitDependant = false,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					humanName = "Interlopers",
					allyTeam = 1,
					unlocks = {
						"shieldfelon",
						"shieldassault",
					},
					difficultyDependantUnlocks = {
						[4] = {"shieldarty"},
					},
					commander = false,
					startUnits = {
						{
							name = "staticmex",
							x = 5050,
							z = 8960,
							facing = 1,
						},
						{
							name = "energywind",
							x = 5090,
							z = 8960,
							facing = 1,
						},
						{
							name = "energywind",
							x = 5010,
							z = 8960,
							facing = 1,
						},
						{
							name = "staticmex",
							x = 5662,
							z = 9380,
							facing = 0,
						},
						{
							name = "energywind",
							x = 5662,
							z = 9330,
							facing = 0,
						},
						{
							name = "energywind",
							x = 5662,
							z = 9430,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6756,
							z = 9400,
							facing = 0,
						},
						{
							name = "energywind",
							x = 6756,
							z = 9350,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 7511,
							z = 8902,
							facing = 0,
						},
						{
							name = "energywind",
							x = 7561,
							z = 8902,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6168,
							z = 12008,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6408,
							z = 11784,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6408,
							z = 12008,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 6280,
							z = 11784,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 6168,
							z = 11896,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 6280,
							z = 12008,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 6392,
							z = 11896,
							facing = 0,
						},
						{
							name = "factoryshield",
							x = 5070,
							z = 11080,
							facing = 2,
							bonusObjectiveID = 3,
						},
						{
							name = "staticcon",
							x = 5200,
							z = 11080,
							facing = 2,
						},
						{
							name = "shieldfelon",
							x = 5200,
							z = 10950,
							facing = 2,
						},
						{
							name = "shieldassault",
							x = 5150,
							z = 10950,
							facing = 2,
						},
						{
							name = "shieldassault",
							x = 5100,
							z = 10950,
							facing = 2,
							difficultyAtLeast = 2.
						},
						{
							name = "shieldassault",
							x = 5050,
							z = 10950,
							facing = 2,
							difficultyAtLeast = 2.
						},
						{
							name = "shieldskirm",
							x = 5050,
							z = 11500,
							facing = 2,
							difficultyAtLeast = 3,
						},
						{
							name = "shieldskirm",
							x = 5100,
							z = 11500,
							facing = 2,
							difficultyAtLeast = 3,
						},
						{
							name = "shieldfelon",
							x = 5150,
							z = 11500,
							facing = 2,
							difficultyAtLeast = 4,
						},
						{
							name = "shieldarty",
							x = 5200,
							z = 11500,
							facing = 2,
							difficultyAtLeast = 4,
						},
						{
							name = "staticstorage",
							x = 5936,
							z = 12072,
							facing = 2,
						},
						{
							name = "staticheavyradar",
							x = 3808,
							z = 11472,
							facing = 0,
						},
						{
							name = "staticheavyradar",
							x = 1216,
							z = 9712,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 6576,
							z = 11632,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 5664,
							z = 12096,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 4816,
							z = 11376,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 5600,
							z = 11024,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 7424,
							z = 11168,
							facing = 2,
						},
						{
							name = "turrettorp",
							x = 5032,
							z = 9672,
							facing = 2,
						},
						{
							name = "turrettorp",
							x = 4696,
							z = 9384,
							facing = 2,
						},
						{
							name = "staticmex",
							x = 9530,
							z = 10770,
							facing = 2,
						},
						{
							name = "staticmex",
							x = 9791,
							z = 10914,
							facing = 2,
						},
						{
							name = "staticmex",
							x = 9824,
							z = 10612,
							facing = 2,
						},
						{
							name = "energywind",
							x = 9600,
							z = 10770,
							facing = 2,
						},
						{
							name = "energywind",
							x = 9773,
							z = 10844,
							facing = 2,
						},
						{
							name = "energywind",
							x = 9773,
							z = 10671,
							facing = 2,
						},
						{
							name = "energywind",
							x = 9870,
							z = 10940,
							facing = 2,
						},
					}
				},
				{
					aiLib = "Null AI",
					bitDependant = false,
					humanName = "Automaton",
					commanderParameters = {
						facplop = false,
					},
					allyTeam = 2,
					unlocks = {
						"staticradar",
						"staticheavyradar",
						"turretaaclose",
						"turretaafar",
						"turretaaflak",
						"turretaaheavy",
						"turretaalaser",
						"turretantiheavy",
						"turretemp",
						"turretgauss",
						"turretheavy",
						"turretheavylaser",
						"turretimpulse",
						"turretlaser",
						"turretmissile",
						"turretriot",
						"turretsunlance",
						"turrettorp",
					},
					commanderLevel = 2,
					commander = false,
					startUnits = {
						{
							name = "energysingu",
							x = 5800,
							z = 184,
							facing = 0,
							bonusObjectiveID = 1,
						},
						{
							name = "energysingu",
							x = 5992,
							z = 184,
							facing = 0,
							bonusObjectiveID = 1,
						},
						{
							name = "energysingu",
							x = 6184,
							z = 184,
							facing = 0,
							bonusObjectiveID = 1,
						},
						{
							name = "energysingu",
							x = 6184,
							z = 344,
							facing = 0,
							bonusObjectiveID = 1,
						},
						{
							name = "energysingu",
							x = 5992,
							z = 344,
							facing = 0,
							bonusObjectiveID = 1,
							mapMarker = {
								text = "Singularity Reactors",
								color = "red"
							},
						},
						{
							name = "energysingu",
							x = 5800,
							z = 344,
							facing = 0,
							bonusObjectiveID = 1,
						},
						{
							name = "turretheavylaser",
							x = 6024,
							z = 2472,
							facing = 2,
							difficultyAtLeast = 2,
						},
						{
							name = "turretheavylaser",
							x = 6024,
							z = 2760,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "staticmex",
							x = 5256,
							z = 264,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 5544,
							z = 216,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 5496,
							z = 504,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6344,
							z = 264,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6648,
							z = 216,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6584,
							z = 504,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 5608,
							z = 1976,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6424,
							z = 2008,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6024,
							z = 3480,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 5144,
							z = 4728,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6008,
							z = 4568,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 5992,
							z = 5720,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6984,
							z = 6008,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 632,
							z = 1592,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 11624,
							z = 1528,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 5432,
							z = 376,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6504,
							z = 392,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6552,
							z = 1320,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6536,
							z = 2248,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 5400,
							z = 1304,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 5384,
							z = 2232,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 4536,
							z = 1368,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6664,
							z = 3160,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 7432,
							z = 1448,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 3688,
							z = 1416,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 7944,
							z = 1032,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 5304,
							z = 3176,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6008,
							z = 3768,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 5992,
							z = 4744,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 5976,
							z = 5608,
							facing = 0,
						},
						{
							name = "turretmissile",
							x = 4032,
							z = 3024,
							facing = 3,
						},
						{
							name = "turretaaflak",
							x = 5144,
							z = 4008,
							facing = 0,
						},
						{
							name = "turretmissile",
							x = 3824,
							z = 2528,
							facing = 3,
						},
						{
							name = "turretlaser",
							x = 5232,
							z = 4096,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 5040,
							z = 4096,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 5608,
							z = 5304,
							facing = 3,
						},
						{
							name = "turretriot",
							x = 5752,
							z = 2632,
							facing = 3,
						},
						{
							name = "turretmissile",
							x = 3056,
							z = 496,
							facing = 3,
						},
						{
							name = "turretriot",
							x = 6280,
							z = 2648,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 6928,
							z = 4080,
							facing = 0,
						},
						{
							name = "turretheavy",
							x = 5240,
							z = 5320,
							facing = 3,
						},
						{
							name = "turretheavy",
							x = 5240,
							z = 5944,
							facing = 3,
						},
						{
							name = "turretmissile",
							x = 6880,
							z = 5040,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 6880,
							z = 4896,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 5216,
							z = 5536,
							facing = 3,
						},
						{
							name = "turretmissile",
							x = 5216,
							z = 5424,
							facing = 3,
						},
						{
							name = "staticstorage",
							x = 5688,
							z = 5160,
							facing = 0,
						},
						{
							name = "staticstorage",
							x = 5752,
							z = 5160,
							facing = 0,
						},
						{
							name = "staticstorage",
							x = 5736,
							z = 5224,
							facing = 0,
						},
						{
							name = "staticstorage",
							x = 5688,
							z = 5224,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 5304,
							z = 5608,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 6776,
							z = 5128,
							facing = 0,
						},
						{
							name = "turretheavylaser",
							x = 4920,
							z = 6184,
							facing = 3,
						},
						{
							name = "turretriot",
							x = 5608,
							z = 4216,
							facing = 3,
						},
						{
							name = "turretgauss",
							x = 5992,
							z = 4952,
							facing = 3,
						},
						{
							name = "turretriot",
							x = 5608,
							z = 4968,
							facing = 3,
						},
						{
							name = "turretheavy",
							x = 6856,
							z = 5464,
							facing = 1,
						},
						{
							name = "turretriot",
							x = 5608,
							z = 4600,
							facing = 3,
						},
						{
							name = "turretaaheavy",
							x = 6016,
							z = 4400,
							facing = 1,
						},
						{
							name = "turretheavy",
							x = 6856,
							z = 4776,
							facing = 1,
						},
						{
							name = "turretheavylaser",
							x = 7144,
							z = 5640,
							facing = 1,
						},
						{
							name = "turretheavylaser",
							x = 7144,
							z = 4600,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 7024,
							z = 4592,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 5072,
							z = 5120,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 6832,
							z = 4592,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 5248,
							z = 5120,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 5248,
							z = 6192,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 7056,
							z = 5680,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 6832,
							z = 5680,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 5072,
							z = 6192,
							facing = 0,
						},
						{
							name = "turretmissile",
							x = 6880,
							z = 5312,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 5216,
							z = 5808,
							facing = 3,
						},
						{
							name = "turretmissile",
							x = 6880,
							z = 5168,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 5216,
							z = 5664,
							facing = 3,
						},
						{
							name = "turretriot",
							x = 6408,
							z = 6104,
							facing = 1,
						},
						{
							name = "turretriot",
							x = 6408,
							z = 5704,
							facing = 1,
						},
						{
							name = "turretriot",
							x = 6408,
							z = 5320,
							facing = 1,
						},
						{
							name = "turretriot",
							x = 5608,
							z = 6104,
							facing = 3,
						},
						{
							name = "turretriot",
							x = 6408,
							z = 4968,
							facing = 1,
						},
						{
							name = "turretriot",
							x = 5608,
							z = 5672,
							facing = 3,
						},
						{
							name = "turretriot",
							x = 6408,
							z = 4584,
							facing = 1,
						},
						{
							name = "turretriot",
							x = 6408,
							z = 4248,
							facing = 1,
						},
						{
							name = "turretriot",
							x = 5784,
							z = 1352,
							facing = 0,
						},
						{
							name = "turretriot",
							x = 6232,
							z = 1352,
							facing = 0,
						},
						{
							name = "turretgauss",
							x = 5992,
							z = 5432,
							facing = 0,
						},
						{
							name = "turretimpulse",
							x = 6384,
							z = 400,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 6288,
							z = 2192,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 5696,
							z = 1696,
							facing = 1,
						},
						{
							name = "turretaafar",
							x = 6256,
							z = 5200,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 7520,
							z = 3568,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 6320,
							z = 1168,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 7680,
							z = 3056,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 7776,
							z = 2448,
							facing = 1,
						},
						{
							name = "turretaaflak",
							x = 6856,
							z = 4024,
							facing = 0,
						},
						{
							name = "turretmissile",
							x = 7936,
							z = 2080,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 4208,
							z = 3568,
							facing = 3,
						},
						{
							name = "turretlaser",
							x = 6784,
							z = 4080,
							facing = 0,
						},
						{
							name = "turretaalaser",
							x = 6200,
							z = 3992,
							facing = 2,
						},
						{
							name = "turretaafar",
							x = 6288,
							z = 880,
							facing = 1,
						},
						{
							name = "turretheavy",
							x = 6008,
							z = 4184,
							facing = 2,
						},
						{
							name = "turretaaheavy",
							x = 5984,
							z = 1664,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 5872,
							z = 1664,
							facing = 3,
						},
						{
							name = "turretlaser",
							x = 5984,
							z = 1760,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 6096,
							z = 1664,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 5984,
							z = 1552,
							facing = 2,
						},
						{
							name = "turretheavylaser",
							x = 3576,
							z = 1544,
							facing = 3,
						},
						{
							name = "turretheavylaser",
							x = 3464,
							z = 1160,
							facing = 3,
						},
						{
							name = "turretheavylaser",
							x = 8152,
							z = 1512,
							facing = 1,
						},
						{
							name = "turretheavylaser",
							x = 3544,
							z = 1848,
							facing = 3,
						},
						{
							name = "turretlaser",
							x = 3392,
							z = 1664,
							facing = 3,
						},
						{
							name = "turretheavylaser",
							x = 8360,
							z = 1080,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 3344,
							z = 1360,
							facing = 3,
						},
						{
							name = "turretlaser",
							x = 3232,
							z = 992,
							facing = 3,
						},
						{
							name = "turretlaser",
							x = 8304,
							z = 1632,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 8320,
							z = 1312,
							facing = 1,
						},
						{
							name = "turretaaflak",
							x = 3576,
							z = 1048,
							facing = 3,
						},
						{
							name = "turretlaser",
							x = 8496,
							z = 1024,
							facing = 1,
						},
						{
							name = "turretaaflak",
							x = 3368,
							z = 536,
							facing = 3,
						},
						{
							name = "turretaaflak",
							x = 8264,
							z = 584,
							facing = 1,
						},
						{
							name = "turretaaflak",
							x = 4216,
							z = 1864,
							facing = 3,
						},
						{
							name = "turretaaflak",
							x = 7848,
							z = 1464,
							facing = 1,
						},
						{
							name = "turretimpulse",
							x = 6480,
							z = 128,
							facing = 1,
						},
						{
							name = "turretaaflak",
							x = 7560,
							z = 2744,
							facing = 1,
						},
						{
							name = "turretimpulse",
							x = 6224,
							z = 544,
							facing = 1,
						},
						{
							name = "turretemp",
							x = 6176,
							z = 1008,
							facing = 1,
						},
						{
							name = "turretemp",
							x = 6416,
							z = 784,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 5392,
							z = 272,
							facing = 3,
						},
						{
							name = "turretimpulse",
							x = 5392,
							z = 160,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 5856,
							z = 720,
							facing = 0,
						},
						{
							name = "turretimpulse",
							x = 5552,
							z = 400,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 6080,
							z = 720,
							facing = 0,
						},
						{
							name = "turretimpulse",
							x = 5744,
							z = 592,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 6512,
							z = 256,
							facing = 1,
						},
						{
							name = "turretimpulse",
							x = 6000,
							z = 608,
							facing = 1,
						},
						{
							name = "turretantiheavy",
							x = 6016,
							z = 3296,
							facing = 2,
						},
						{
							name = "turretaalaser",
							x = 5832,
							z = 1832,
							facing = 2,
						},
						{
							name = "turretaalaser",
							x = 6184,
							z = 1864,
							facing = 2,
						},
						{
							name = "turretaaclose",
							x = 5880,
							z = 3288,
							facing = 2,
						},
						{
							name = "turretaaclose",
							x = 6168,
							z = 3288,
							facing = 2,
						},
						{
							name = "turretmissile",
							x = 5584,
							z = 2656,
							facing = 1,
						},
						{
							name = "turretaalaser",
							x = 5816,
							z = 4008,
							facing = 2,
						},
						{
							name = "turretmissile",
							x = 6336,
							z = 2880,
							facing = 1,
						},
						{
							name = "turretheavylaser",
							x = 4930,
							z = 5132,
							facing = 3,
						},
						{
							name = "turrettorp",
							x = 3135,
							z = 2500,
							facing = 3,
						},
						{
							name = "turrettorp",
							x = 3195,
							z = 2920,
							facing = 3,
						},
						{
							name = "turrettorp",
							x = 3735,
							z = 3800,
							facing = 3,
						},
						{
							name = "turrettorp",
							x = 3795,
							z = 4220,
							facing = 3,
						},
						-- consider these
						-- },
							-- name = "turretantiheavy",
							-- x = 6000,
							-- z = 1950,
							-- facing = 0,
						-- },
						-- {
							-- name = "turretgauss",
							-- x = 5800,
							-- z = 1950,
							-- facing = 3,
						-- },
						-- {
							-- name = "turretgauss",
							-- x = 6200,
							-- z = 1950,
							-- facing = 1,
						-- },
						-- {
							-- name = "energypylon",
							-- x = 7410,
							-- z = 2200,
							-- facing = 0,
						-- },
						-- {
							-- name = "energypylon",
							-- x = 7410,
							-- z = 2900,
							-- facing = 0,
						-- },
						-- {
							-- name = "energypylon",
							-- x = 6100,
							-- z = 1760,
							-- facing = 0,
						-- },
					}
				},
			},
			neutralUnits = {
				{
					name = "pw_relay",
					x = 6025,
					z = 2625,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
					mapMarker = {
						text = "Relay Node",
						color = "green"
					},
				},
				{
					name = "pw_inhibitor",
					x = 6232,
					z = 4360,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_inhibitor",
					x = 6232,
					z = 4488,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_gaspowerstation",
					x = 5856,
					z = 2624,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_gaspowerstation",
					x = 6160,
					z = 2624,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_interception",
					x = 4400,
					z = 3472,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_interception",
					x = 7440,
					z = 1824,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_interception",
					x = 4288,
					z = 1408,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_warpgate",
					x = 6256,
					z = 5896,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_warpjammer",
					x = 5760,
					z = 5888,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_mstorage2",
					x = 5752,
					z = 4312,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_mstorage2",
					x = 5752,
					z = 4488,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "staticmex",
					x = 10472,
					z = 5800,
					facing = 0,
					ignoredByAI = true,
				},
				{
					name = "staticmex",
					x = 10760,
					z = 5640,
					facing = 0,
					ignoredByAI = true,
				},
				{
					name = "staticmex",
					x = 10728,
					z = 5928,
					facing = 0,
					ignoredByAI = true,
				},
				{
					name = "staticmex",
					x = 11400,
					z = 5032,
					facing = 0,
					ignoredByAI = true,
				},
				{
					name = "staticmex",
					x = 11640,
					z = 4792,
					facing = 0,
					ignoredByAI = true,
				},
				{
					name = "staticmex",
					x = 11704,
					z = 5080,
					facing = 0,
					ignoredByAI = true,
				},
				{
					name = "staticmex",
					x = 11384,
					z = 6648,
					facing = 0,
					ignoredByAI = true,
				},
				{
					name = "staticmex",
					x = 11688,
					z = 6600,
					facing = 0,
					ignoredByAI = true,
				},
				{
					name = "staticmex",
					x = 11624,
					z = 6888,
					facing = 0,
					ignoredByAI = true,
				},
				{
					name = "pw_mine",
					x = 11528,
					z = 6728,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_mine",
					x = 11560,
					z = 4968,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
				{
					name = "pw_metal",
					x = 10656,
					z = 5760,
					facing = 0,
					invincible = true,
					ignoredByAI = true,
				},
			},
			terraform = {
				{
					terraformShape = planetUtilities.TERRAFORM_SHAPE.RECTANGLE,
					terraformType = planetUtilities.TERRAFORM_TYPE.LEVEL,
					position = {3416, 5700, 4740, 5990},
					height = 6,
				},
				{
					terraformShape = planetUtilities.TERRAFORM_SHAPE.RECTANGLE,
					terraformType = planetUtilities.TERRAFORM_TYPE.LEVEL,
					position = {7700, 9780, 9400, 9820},
					height = -40,
				},
				{
					terraformShape = planetUtilities.TERRAFORM_SHAPE.RECTANGLE,
					terraformType = planetUtilities.TERRAFORM_TYPE.LEVEL,
					position = {9360, 9800, 9420, 11340},
					height = -40,
				},
				{
					terraformShape = planetUtilities.TERRAFORM_SHAPE.RAMP,
					position = {4040, 6, 10470, 3604, 6, 9857},
					width = 500
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = { },
				[1] = {
					ignoreUnitLossDefeat = true,
					loseAfterSeconds = false,
				},
				[2] = {
					ignoreUnitLossDefeat = true,
					loseAfterSeconds = false,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Bring your Commander to the defense Relay Node",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				[1] = { -- Kill the Singus
					satisfyOnce = true,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 0,
					-- See bonusObjectiveID in units table
					image = planetUtilities.ICON_DIR .. "energysingu.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Destroy the Automaton Singularity Reactors",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Win by 10:00
					victoryByTime = 600,
					image = planetUtilities.ICON_OVERLAY.CLOCK,
					description = "Win by 10:00",
					experience = planetUtilities.BONUS_EXP,
				},
				[3] = { -- Kill enemy fac
					satisfyOnce = true,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 0,
					-- See bonusObjectiveID in units table
					image = planetUtilities.ICON_DIR .. "factoryshield.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Destroy the Interlopers' Shieldbot Factory",
					experience = planetUtilities.BONUS_EXP,
				},
			},
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"cloaksnipe",
			},
			modules = {
				"module_personal_cloak",
			},
			abilities = {
			},
			codexEntries = {
				"anomaly_new_falsell"
			},
		},
	}
	
	return planetData
end

return GetPlanet
