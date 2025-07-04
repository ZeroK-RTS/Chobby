--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	--local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	local image = LUA_DIRNAME .. "images/planets/terran03_damaged.png"
	
	local planetData = {
		name = "Asjulohi",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.37,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.96,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Oceanic",
			radius = "6190 km",
			primary = "Royal",
			primaryType = "F9IV",
			milRating = 1,
			feedbackLink = "https://zero-k.info/Forum/Thread/24469",
			text = "There is an Ancient Fabricator on this world, capable of generating metal from nothing. It is hidden behind thick layers of defense, but their jamming systems have long stopped working. If I can jump right on top of it, I should be able to fight my way out."
			,
			extendedText = "The first part of the plan went pretty well, but now I am boxed in there. Time to use Djinn teleporters and Lobsters to launch an attack from behind the inner ring and break the siege."
		},
		tips = {
			{
				image = "unitpics/amphtele.png",
				text = [[The Djinn is a one-way teleporter capable of teleporting friendly units from around its paired Lamp. To use a Djinn tell it to place a Lamp and have units use the Lamp. A Djinn must be stationary to deploy and activate the teleportation bridge.]]
			},
			{
				image = "unitpics/tele_beacon.png",
				text = [[Djinni can place Lamps anywhere on the map, at global range. Besides using the Djinn for defense, you can also use it to recover units deep inside enemy territory, or to launch a sneak attack.]]
			},
			{
				image = "unitpics/amphlaunch.png",
				text = [[Lobsters propel nearby units through the air towards a nearby target. You can use this ability to deploy your own army or relocate enemies - experiment for best results. The units do not fly especially fast so they may be vulnerable while in transit.]]
			},
			{
				image = "unitpics/turretaafar.png",
				text = [[Chainsaws are long-range anti-air missile launchers, excellent for destroying bombers before they get too close.]]
			},
		},
		gameConfig = {
			mapName = "Onyx Cauldron 1.9",
			playerConfig = {
				startX = 2400,
				startZ = 6800,
				allyTeam = 0,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factoryamph",
					"amphcon",
					"amphaa",
					"amphtele",
					"amphlaunch",
					"turretaafar",
				},
				startUnits = {
					{
						name = "amphlaunch",
						x = 1950,
						z = 7090,
						facing = 2,
						commands = {
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {1950, 6980}},
							{cmdID = planetUtilities.COMMAND.ATTACK, pos = {1950, 6650}, options = {"shift"}},
						},
					},
					{
						name = "amphlaunch",
						x = 1950,
						z = 6140,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {1950, 6540}},
							{cmdID = planetUtilities.COMMAND.ATTACK, pos = {1950, 6870}, options = {"shift"}},
						},
					},
					{
						name = "amphriot",
						x = 1950,
						z = 6960,
						facing = 0,
					},
					{
						name = "amphtele",
						x = 2225,
						z = 6775,
						facing = 1,
					},
					{
						name = "amphtele",
						x = 7767,
						z = 4914,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.PLACE_BEACON, pos = {2800, 7300}},
						},
					},
					{
						name = "amphtele",
						x = 4157,
						z = 1288,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.PLACE_BEACON, pos = {1950, 6200}},
						},
					},
					{
						name = "amphfloater",
						x = 2350,
						z = 5120,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {3290, 5290}},
						},
					},
					{
						name = "amphfloater",
						x = 3290,
						z = 5290,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {2350, 5120}},
						},
					},
					{
						name = "amphfloater",
						x = 3650,
						z = 6660,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {3690, 5880}},
						},
					},
					{
						name = "amphfloater",
						x = 3690,
						z = 5880,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {3650, 6660}},
						},
					},
					{
						name = "amphcon",
						x = 2400,
						z = 6900,
						facing = 1,
					},
					{
						name = "amphfloater",
						x = 2080,
						z = 6750,
						facing = 1,
					},
					{
						name = "amphfloater",
						x = 2080,
						z = 6800,
						facing = 1,
					},
					{
						name = "amphriot",
						x = 2150,
						z = 6750,
						facing = 1,
					},
					{
						name = "amphriot",
						x = 2150,
						z = 6800,
						facing = 1,
					},
					{
						name = "amphimpulse",
						x = 2150,
						z = 6700,
						facing = 1,
					},
					{
						name = "amphimpulse",
						x = 2150,
						z = 6850,
						facing = 1,
					},
					{
						name = "pw_metal",
						x = 3104,
						z = 6240,
						facing = 0,
					},
 					{
						name = "pw_metal",
						x = 2736,
						z = 5840,
						facing = 0,
					},
 					{
						name = "turretriot",
						x = 3592,
						z = 6376,
						facing = 1,
					},
 					{
						name = "staticmex",
						x = 2728,
						z = 6232,
						facing = 1,
					},
 					{
						name = "staticcon",
						x = 2232,
						z = 7176,
						facing = 2,
						commands = {
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {2232, 7176}},
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {2257, 7151}, options = {"shift"}},
						},
					},
 					{
						name = "staticmex",
						x = 2616,
						z = 7032,
						facing = 1,
					},
 					{
						name = "staticmex",
						x = 2184,
						z = 6552,
						facing = 1,
					},
 					{
						name = "staticcon",
						x = 2200,
						z = 7096,
						facing = 2,
						commands = {
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {2200, 7096}},
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {2225, 7071}, options = {"shift"}},
						},
					},
 					{
						name = "energysolar",
						x = 2248,
						z = 6568,
						facing = 0,
					},
 					{
						name = "energysolar",
						x = 2680,
						z = 7048,
						facing = 0,
					},
 					{
						name = "energysolar",
						x = 2168,
						z = 6616,
						facing = 3,
					},
 					{
						name = "energysolar",
						x = 2600,
						z = 7096,
						facing = 3,
					},
 					{
						name = "energysolar",
						x = 2120,
						z = 6536,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 2200,
						z = 6488,
						facing = 1,
					},
 					{
						name = "energysolar",
						x = 2552,
						z = 7016,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 2632,
						z = 6968,
						facing = 1,
					},
 					{
						name = "staticcon",
						x = 2280,
						z = 7096,
						facing = 2,
						commands = {
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {2280, 7096}},
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {2305, 7071}, options = {"shift"}},
						},
					},
 					
 					{
						name = "energysolar",
						x = 2664,
						z = 6216,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 2712,
						z = 6296,
						facing = 3,
					},
 					{
						name = "energysolar",
						x = 2792,
						z = 6248,
						facing = 0,
					},
 					{
						name = "energysolar",
						x = 2744,
						z = 6168,
						facing = 1,
					},
 					{
						name = "pw_mine2",
						x = 3360,
						z = 6048,
						facing = 0,
					},
 					{
						name = "pw_mine2",
						x = 2960,
						z = 5648,
						facing = 0,
					},
 					{
						name = "pw_mine2",
						x = 2864,
						z = 6096,
						facing = 0,
					},
 					{
						name = "factoryamph",
						x = 2216,
						z = 6968,
						facing = 2,
					},
 					{
						name = "staticmex",
						x = 3064,
						z = 5960,
						facing = 1,
					},
 					{
						name = "energysolar",
						x = 3128,
						z = 5976,
						facing = 0,
					},
 					{
						name = "energysolar",
						x = 3048,
						z = 6024,
						facing = 3,
					},
 					{
						name = "energysolar",
						x = 3000,
						z = 5944,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 3080,
						z = 5896,
						facing = 1,
					},
 					{
						name = "turretaafar",
						x = 3008,
						z = 6688,
						facing = 1,
					},
 					{
						name = "turretaafar",
						x = 2320,
						z = 6224,
						facing = 1,
					},
 					{
						name = "staticheavyradar",
						x = 2752,
						z = 6736,
						facing = 2,
						terraformHeight = 233,
					},
 					{
						name = "turretriot",
						x = 2728,
						z = 5240,
						facing = 2,
					},
 					{
						name = "turretheavylaser",
						x = 3432,
						z = 5624,
						facing = 2,
					},
 					{
						name = "turretemp",
						x = 3616,
						z = 6016,
						facing = 1,
					},
 					{
						name = "turretemp",
						x = 3136,
						z = 5296,
						facing = 2,
					},
 					{
						name = "turretlaser",
						x = 2384,
						z = 5200,
						facing = 2,
					},
 					{
						name = "turretlaser",
						x = 3568,
						z = 6640,
						facing = 1,
					},
 					{
						name = "turretlaser",
						x = 3008,
						z = 5280,
						facing = 2,
					},
 					{
						name = "turretlaser",
						x = 3616,
						z = 6144,
						facing = 1,
					},
 					{
						name = "turretlaser",
						x = 3584,
						z = 5904,
						facing = 1,
					},
 					{
						name = "turretlaser",
						x = 3248,
						z = 5360,
						facing = 2,
					},
 					{
						name = "turretmissile",
						x = 1920,
						z = 5808,
						facing = 2,
					},
 					{
						name = "turretmissile",
						x = 2240,
						z = 5648,
						facing = 2,
					},
 					{
						name = "turretmissile",
						x = 3328,
						z = 7200,
						facing = 1,
					},
 					{
						name = "turretmissile",
						x = 3568,
						z = 7360,
						facing = 1,
					},
				}
			},
			aiConfig = {
				{
					startX = 5000,
					startZ = 3800,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					--aiLib = "Null AI",
					--bitDependant = false,
					humanName = "16:Stqix",
					commanderParameters = {
						facplop = false,
					},
					allyTeam = 1,
					unlocks = {
						--"staticmex",
						"staticradar",
						"energysolar",
						"energywind",
						"staticstorage",
						"staticcon",
						"turretmissile",
						"turretaalaser",
						"cloakraid",
						"cloakriot",
						"cloakskirm",
						"cloakassault",
						"cloakarty",
						"cloakbomb",
						"shieldraid",
						"shieldriot",
						--"shieldassault",
						"shieldskirm",
						"tankcon",
						"tankraid",
						"tankheavyraid",
						"tankriot",
						"tankassault",
						"planecon",
						"planescout",
						"planefighter",
						"bomberprec",
						"bomberriot",
					},
					difficultyDependantUnlocks = {
						[2] = {"shieldarty"},
						[3] = {"shieldarty","bomberheavy"},
						[4] = {"shieldarty","bomberheavy","cloaksnipe","shieldassault"},
					},
					commanderLevel = 2,
					commander = {
						name = "Kovedos",
						chassis = "engineer",
						decorations = {
						},
						modules = { }
					},
					startUnits = {
						{
							name = "shieldskirm",
							x = 3550,
							z = 3600,
							facing = 2,
							difficultyAtLeast = 2,
						},
						{
							name = "shieldskirm",
							x = 3650,
							z = 3600,
							facing = 2,
							difficultyAtLeast = 2,
						},
						{
							name = "shieldskirm",
							x = 3750,
							z = 3600,
							facing = 2,
							difficultyAtLeast = 2,
						},
						{
							name = "cloakassault",
							x = 3550,
							z = 3700,
							facing = 2,
							difficultyAtLeast = 2,
						},
						{
							name = "tankriot",
							x = 6670,
							z = 4550,
							facing = 2,
							difficultyAtLeast = 3,
						},
						{
							name = "tankassault",
							x = 6770,
							z = 4550,
							facing = 2,
							difficultyAtLeast = 3,
						},
						{
							name = "bomberheavy",
							x = 8840,
							z = 200,
							facing = 2,
							difficultyAtLeast = 4,
						},
						{
							name = "turretaafar",
							x = 5452,
							z = 8130,
							facing = 3,
						},
						{
							name = "turretaafar",
							x = 5068,
							z = 6850,
							facing = 3,
						},
						{
							name = "turretaafar",
							x = 2500,
							z = 4000 ,
							facing = 0,
						},
						{
							name = "turretaafar",
							x = 1300,
							z = 4000 ,
							facing = 0,
						},
						{
							name = "turretheavylaser",
							x = 4910,
							z = 6646 ,
							facing = 3,
						},
						{
							name = "turretheavylaser",
							x = 2350,
							z = 4228 ,
							facing = 0,
						},
						{
							name = "turretheavylaser",
							x = 4060,
							z = 4950 ,
							facing = 0,
						},
						{
							name = "turretmissile",
							x = 5424,
							z = 2560,
							facing = 2,
						},
 						{
							name = "staticmex",
							x = 2648,
							z = 2184,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 2280,
							z = 2152,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 5512,
							z = 2104,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 7192,
							z = 5464,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 2296,
							z = 2536,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 6920,
							z = 5272,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 6408,
							z = 1816,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 2376,
							z = 3240,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 1992,
							z = 3352,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 7192,
							z = 2008,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 5480,
							z = 5400,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 7608,
							z = 2280,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 5848,
							z = 6728,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 7464,
							z = 3112,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 5736,
							z = 7112,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 7176,
							z = 4248,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 4008,
							z = 3656,
							facing = 2,
						},
 						{
							name = "staticmex",
							x = 6712,
							z = 7160,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 6696,
							z = 6824,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 3944,
							z = 2024,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 7080,
							z = 6856,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 4152,
							z = 2216,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 6056,
							z = 3368,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 6792,
							z = 7080,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 6776,
							z = 6920,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 6952,
							z = 6872,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 6040,
							z = 3432,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 5992,
							z = 3352,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 5832,
							z = 6824,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 5784,
							z = 7000,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7496,
							z = 3048,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7512,
							z = 2968,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7512,
							z = 2888,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7528,
							z = 2808,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7544,
							z = 2728,
							facing = 1,
						},
 						{
							name = "factoryplane",
							x = 4976,
							z = 4136,
							facing = 0,
						},
 						{
							name = "energywind",
							x = 2296,
							z = 2472,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7544,
							z = 2648,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 2296,
							z = 2392,
							facing = 1,
						},
 						{
							name = "turrettorp",
							x = 4840,
							z = 4008,
							facing = 0,
						},
 						{
							name = "energywind",
							x = 7560,
							z = 2568,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 2296,
							z = 2312,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7576,
							z = 2488,
							facing = 1,
						},
 						{
							name = "turrettorp",
							x = 5112,
							z = 4008,
							facing = 0,
						},
 						{
							name = "energywind",
							x = 2296,
							z = 2232,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7576,
							z = 2408,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 2344,
							z = 2152,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7592,
							z = 2328,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 2424,
							z = 2152,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7528,
							z = 2280,
							facing = 1,
						},
 						{
							name = "turrettorp",
							x = 4968,
							z = 4312,
							facing = 0,
						},
 						{
							name = "energywind",
							x = 2504,
							z = 2168,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7448,
							z = 2232,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 2584,
							z = 2168,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7368,
							z = 2184,
							facing = 1,
						},
 						{
							name = "turretmissile",
							x = 4800,
							z = 4192,
							facing = 0,
						},
 						{
							name = "energywind",
							x = 7288,
							z = 2120,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7208,
							z = 2072,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7128,
							z = 2008,
							facing = 1,
						},
 						{
							name = "turretmissile",
							x = 5168,
							z = 4208,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 2264,
							z = 3240,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 7048,
							z = 1992,
							facing = 1,
						},
 						{
							name = "staticcon",
							x = 4984,
							z = 4040,
							facing = 0,
							commands = {
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {4984, 4040}},
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {4959, 4065}, options = {"shift"}},
							},
						},
 						{
							name = "energysolar",
							x = 2104,
							z = 3320,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6968,
							z = 1976,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6888,
							z = 1960,
							facing = 1,
						},
 						{
							name = "staticrearm",
							x = 4984,
							z = 3896,
							facing = 0,
						},
 						{
							name = "energywind",
							x = 6808,
							z = 1944,
							facing = 1,
						},
 						{
							name = "turretmissile",
							x = 4864,
							z = 3792,
							facing = 2,
						},
 						{
							name = "energywind",
							x = 6728,
							z = 1928,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6648,
							z = 1912,
							facing = 1,
						},
 						{
							name = "turretmissile",
							x = 5104,
							z = 3792,
							facing = 2,
						},
 						{
							name = "energywind",
							x = 6568,
							z = 1896,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6488,
							z = 1880,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6408,
							z = 1864,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 3976,
							z = 2088,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 4056,
							z = 2120,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 4136,
							z = 2152,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 5496,
							z = 5336,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 5416,
							z = 5384,
							facing = 1,
						},
 						{
							name = "factorycloak",
							x = 6440,
							z = 6960,
							facing = 2,
						},
 						{
							name = "staticcon",
							x = 6440,
							z = 7096,
							facing = 2,
							commands = {
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {6440, 7096}},
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {6415, 7071}, options = {"shift"}},
							},
						},
 						{
							name = "factoryshield",
							x = 2768,
							z = 2408,
							facing = 0,
						},
 						{
							name = "staticcon",
							x = 2776,
							z = 2280,
							facing = 0,
							commands = {
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {2776, 2280}},
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {2801, 2305}, options = {"shift"}},
							},
						},
 						{
							name = "energysolar",
							x = 5576,
							z = 2120,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 5496,
							z = 2168,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 5448,
							z = 2088,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 5528,
							z = 2040,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 6984,
							z = 5288,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 6904,
							z = 5336,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 6856,
							z = 5256,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 6936,
							z = 5208,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 4072,
							z = 3672,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 7256,
							z = 5480,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 7176,
							z = 5528,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 3992,
							z = 3720,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 7128,
							z = 5448,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 3944,
							z = 3640,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 7208,
							z = 5400,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 4024,
							z = 3592,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 5544,
							z = 5416,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 5464,
							z = 5464,
							facing = 2,
						},
 						{
							name = "factorytank",
							x = 6992,
							z = 2656,
							facing = 0,
						},
 						{
							name = "staticcon",
							x = 7000,
							z = 2520,
							facing = 0,
							commands = {
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {7000, 2520}},
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {6975, 2545}, options = {"shift"}},
							},
						},
 						{
							name = "turretaaflak",
							x = 2520,
							z = 2504,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 2464,
							z = 2848,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 2016,
							z = 2896,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 2128,
							z = 2256,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 2864,
							z = 2016,
							facing = 1,
						},
 						{
							name = "turretlaser",
							x = 6272,
							z = 7200,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 6560,
							z = 6608,
							facing = 2,
						},
 						{
							name = "turretlaser",
							x = 7088,
							z = 6544,
							facing = 2,
						},
 						{
							name = "turretheavylaser",
							x = 4952,
							z = 6184,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 7008,
							z = 7168,
							facing = 1,
						},
 						{
							name = "turretriot",
							x = 4920,
							z = 6376,
							facing = 3,
						},
 						{
							name = "turretriot",
							x = 4904,
							z = 6936,
							facing = 3,
						},
 						{
							name = "turretheavylaser",
							x = 4952,
							z = 7128,
							facing = 3,
						},
 						{
							name = "turretaalaser",
							x = 5032,
							z = 6696,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 4432,
							z = 5360,
							facing = 3,
						},
 						{
							name = "turretheavylaser",
							x = 1896,
							z = 4008,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 3968,
							z = 4640,
							facing = 3,
						},
 						{
							name = "turretaalaser",
							x = 4056,
							z = 4840,
							facing = 3,
						},
 						{
							name = "turretheavylaser",
							x = 2792,
							z = 3976,
							facing = 0,
						},
 						{
							name = "turretaalaser",
							x = 4264,
							z = 5144,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 4160,
							z = 5008,
							facing = 3,
						},
 						{
							name = "turretriot",
							x = 2040,
							z = 4232,
							facing = 0,
						},
 						{
							name = "turretriot",
							x = 2648,
							z = 4184,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 7120,
							z = 3152,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 7488,
							z = 3296,
							facing = 0,
						},
 						{
							name = "turretaaclose",
							x = 6824,
							z = 6744,
							facing = 3,
						},
 						{
							name = "turretaaclose",
							x = 6584,
							z = 7240,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 6576,
							z = 2432,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 6448,
							z = 2128,
							facing = 3,
						},
 						{
							name = "turretemp",
							x = 3408,
							z = 3904,
							facing = 0,
						},
 						{
							name = "turretemp",
							x = 3632,
							z = 4032,
							facing = 0,
						},
 						{
							name = "turretaafar",
							x = 7216,
							z = 2560,
							facing = 3,
						},
 						{
							name = "turretemp",
							x = 3824,
							z = 4208,
							facing = 0,
						},
 						{
							name = "turretgauss",
							x = 3544,
							z = 3928,
							facing = 0,
						},
 						{
							name = "turretgauss",
							x = 3768,
							z = 4104,
							facing = 0,
						},
 						{
							name = "turretaalaser",
							x = 2344,
							z = 4072,
							facing = 3,
						},
 						{
							name = "turretemp",
							x = 4768,
							z = 5536,
							facing = 3,
						},
 						{
							name = "turretemp",
							x = 4880,
							z = 5696,
							facing = 3,
						},
 						{
							name = "turretemp",
							x = 4928,
							z = 5888,
							facing = 3,
						},
 						{
							name = "turretmissile",
							x = 3040,
							z = 4032,
							facing = 0,
						},
 						{
							name = "turretgauss",
							x = 4856,
							z = 5592,
							facing = 3,
						},
 						{
							name = "turretmissile",
							x = 3120,
							z = 3984,
							facing = 0,
						},
 						{
							name = "turretgauss",
							x = 4952,
							z = 5784,
							facing = 3,
						},
 						{
							name = "turretmissile",
							x = 4960,
							z = 6096,
							facing = 3,
						},
 						{
							name = "turretmissile",
							x = 4880,
							z = 6192,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 4880,
							z = 7760,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 1664,
							z = 4176,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 4928,
							z = 7472,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 1520,
							z = 4272,
							facing = 0,
						},
 						{
							name = "turretmissile",
							x = 6880,
							z = 5456,
							facing = 0,
						},
 						{
							name = "turretmissile",
							x = 7168,
							z = 5184,
							facing = 1,
						},
 						{
							name = "turretmissile",
							x = 7216,
							z = 5664,
							facing = 1,
						},
 						{
							name = "turretmissile",
							x = 5120,
							z = 2896,
							facing = 2,
						},
 						{
							name = "staticheavyradar",
							x = 5264,
							z = 2720,
							facing = 2,
						},
 						{
							name = "staticheavyradar",
							x = 6432,
							z = 4192,
							facing = 2,
						},
 						{
							name = "turretmissile",
							x = 4128,
							z = 2384,
							facing = 2,
						},
 						{
							name = "turretmissile",
							x = 3824,
							z = 2176,
							facing = 2,
						},
 						{
							name = "turretmissile",
							x = 4160,
							z = 1952,
							facing = 2,
						},
					}
				},
			
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = {
				},
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalCommanders = false,
					vitalUnitTypes = {
						"factoryshield",
						"factoryplane",
						"factorycloak",
						"factorytank",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy all enemy factories",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				[1] = { -- Protect all Djinns
					satisfyForever = true,
					failOnUnitLoss = true, -- Fails the objective if any units being used to satisfy the objective are lost.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 0,
					unitTypes = {
						"amphtele",
					},
					image = planetUtilities.ICON_DIR .. "amphtele.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.GUARD,
					description = "Don't lose any Djinns",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Have 20 Metal Extractors
					satisfyByTime = 1200,
					capturedUnitsSatisfy = true,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 20,
					unitTypes = {
						"staticmex",
					},
					image = planetUtilities.ICON_DIR .. "staticmex.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Have 20 Metal Extractors before 20:00",
					experience = planetUtilities.BONUS_EXP,
				},
			},
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"amphaa",
				"amphtele",
				"amphlaunch",
				"turretaafar",
			},
			modules = {
				"module_autorepair_LIMIT_B_2",
			},
			abilities = {
			},
			codexEntries = {
				"faction_empire",
				"anomaly_asjulohi",
			},
		},
	}
	
	return planetData
end

return GetPlanet
