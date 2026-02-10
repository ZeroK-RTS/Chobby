local invertZoomMult = -1

local TRUE = "true"
local FALSE = "false"

local lupsFileTarget = "lups.cfg"
local cmdcolorsFileTarget = "cmdcolors.txt"

local function UpdateLups(_, conf)
	conf = conf or (WG.Chobby and WG.Chobby.Configuration)
	local settings = conf and conf.settingsMenuValues
	if not settings then
		return
	end

	local lupsFileName = settings.ShaderDetail_file or "LuaMenu/configs/gameConfig/zk/lups/lups3.cfg"
	local lupsAirJetDisabled = ((settings.LupsAirJet == "On") and FALSE) or TRUE
	local lupsRibbonDisabled = ((settings.LupsRibbon == "On") and FALSE) or TRUE
	local lupsNanoParticlesDisabled = ((settings.LupsNanoParticles == "Cloud") and FALSE) or TRUE
	local LupsShieldShaderDisabled = ((settings.LupsShieldShader == "Off") and TRUE) or FALSE
	local LupsShieldHighQualityDisabled = ((settings.LupsShieldShader == "Default") and FALSE) or TRUE
	local lupsWaterRefractEnabled = ((settings.LupsWaterSettings == "Refraction" or settings.LupsWaterSettings == "Refract and Reflect") and 1) or 0
	local lupsWaterReflectEnabled = ((settings.LupsWaterSettings == "Reflection" or settings.LupsWaterSettings == "Refract and Reflect") and 1) or 0

	local sourceFile = VFS.LoadFile(lupsFileName)

	sourceFile = sourceFile:gsub("__AIR_JET__", lupsAirJetDisabled)
	sourceFile = sourceFile:gsub("__RIBBON__", lupsRibbonDisabled)
	sourceFile = sourceFile:gsub("__NANO_PARTICLES__", lupsNanoParticlesDisabled)
	sourceFile = sourceFile:gsub("__SHIELD_SPHERE_COLOR__", LupsShieldShaderDisabled)
	sourceFile = sourceFile:gsub("__SHIELD_SPHERE_HIGH_QUALITY__", LupsShieldHighQualityDisabled)
	sourceFile = sourceFile:gsub("__ENABLE_REFRACT__", lupsWaterRefractEnabled)
	sourceFile = sourceFile:gsub("__ENABLE_REFLECT__", lupsWaterReflectEnabled)

	local settingsFile = io.open(lupsFileTarget, "w")
	settingsFile:write(sourceFile)
	settingsFile:close()
end

local function UpdateCmdcolors(_, conf)
	conf = conf or (WG.Chobby and WG.Chobby.Configuration)
	local settings = conf and conf.settingsMenuValues
	if not settings then
		return
	end

	local cmdAlpha = (settings.CommandAlpha or 70)/100
	local cmdAlphaDark
	if cmdAlpha >= 0.7 then
		cmdAlphaDark = cmdAlpha + 0.1
	elseif cmdAlpha >= 0.6 then
		cmdAlphaDark = cmdAlpha + 0.05
	else
		cmdAlphaDark = cmdAlpha + 0.02
	end
	
	local queueIconAlpha = (settings.QueueIconAlpha or 50)/100

	local cmdcolorsFileName = "LuaMenu/configs/gameConfig/zk/cmdcolors/cmdcolors_source.txt"
	local sourceFile = VFS.LoadFile(cmdcolorsFileName)

	sourceFile = sourceFile:gsub("__CMD_ALPHA__", cmdAlpha)
	sourceFile = sourceFile:gsub("__CMD_ALPHA_DARK__", cmdAlphaDark)
	sourceFile = sourceFile:gsub("__QUEUE_ICON_ALPHA__", queueIconAlpha)

	local settingsFile = io.open(cmdcolorsFileTarget, "w")
	settingsFile:write(sourceFile)
	settingsFile:close()
	
	return {
		CmdAlpha = cmdAlpha,
		CmdAlphaDark = cmdAlphaDark,
		CmdIconAlpha = queueIconAlpha,
	}
end

local function GetUiScaleParameters()
	local realWidth, realHeight = Spring.Orig.GetViewSizes()
	local defaultUiScale = 100
	if realHeight > 1900 then
		defaultUiScale = 200
	elseif realHeight > 1220 or realWidth > 2500 then
		defaultUiScale = 125
	end
	local maxUiScale = math.max(2, realWidth/1000)*100
	local minUiScale = math.min(0.5, realWidth/4000)*100
	return defaultUiScale, maxUiScale, minUiScale
end

local defaultUiScale, maxUiScale, minUiScale = GetUiScaleParameters()

local settingsConfig = {
	{
		name = "Graphics",
		presets = {
			{
				name = "Compat.",
				settings = {
					WaterType_2 = "Basic",
					WaterQuality = "Low",
					Shadows = "None",
					ShadowMapSize = "1024",
					ShadowDetail = "Low",
					ParticleLimit = "2000",
					TerrainDetail = "Minimal",
					SoftParticles = "Compatibility",
					VegetationDetail = "Minimal",
					FeatureFade = "On",
					CompatibilityMode = "On",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "Off",
					VSync = "Off",
					ShaderDetail = "Minimal",
					LupsAirJet = "Off",
					LupsRibbon = "Off",
					LupsNanoParticles = "Beam",
					LupsShieldShader = "Off",
					LupsWaterSettings = "Off",
					FancySky = "Off",
					UseNewChili = "Off",
				}
			},
			{
				name = "Lowest",
				settings = {
					WaterType_2 = "Bumpmapped",
					WaterQuality = "Low",
					Shadows = "None",
					ShadowMapSize = "1024",
					ShadowDetail = "Low",
					ParticleLimit = "6000",
					TerrainDetail = "Low",
					SoftParticles = "Enabled",
					VegetationDetail = "Low",
					FeatureFade = "On",
					CompatibilityMode = "Off",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "Low",
					VSync = "Off",
					ShaderDetail = "Minimal",
					LupsAirJet = "Off",
					LupsRibbon = "Off",
					LupsNanoParticles = "Beam",
					LupsShieldShader = "Off",
					LupsWaterSettings = "Off",
					FancySky = "Off",
					UseNewChili = "Off",
				}
			},
			{
				name = "Low",
				settings = {
					WaterType_2 = "Bumpmapped",
					WaterQuality = "Low",
					Shadows = "Units Only",
					ShadowMapSize = "2048",
					ShadowDetail = "Low",
					ParticleLimit = "12000",
					TerrainDetail = "Low",
					SoftParticles = "Enabled",
					VegetationDetail = "Low",
					FeatureFade = "On",
					CompatibilityMode = "Off",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "Low",
					VSync = "Off",
					ShaderDetail = "Low",
					LupsAirJet = "Off",
					LupsRibbon = "On",
					LupsNanoParticles = "Beam",
					LupsShieldShader = "Default",
					LupsWaterSettings = "Off",
					FancySky = "Off",
					UseNewChili = "Off",
				}
			},
			{
				name = "Medium",
				settings = {
					WaterType_2 = "Bumpmapped",
					WaterQuality = "Medium",
					Shadows = "Units and Terrain",
					ShadowMapSize = "2048",
					ShadowDetail = "Medium",
					ParticleLimit = "15000",
					TerrainDetail = "Medium",
					SoftParticles = "Enabled",
					VegetationDetail = "Medium",
					FeatureFade = "On",
					CompatibilityMode = "Off",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "Low",
					VSync = "Off",
					ShaderDetail = "Medium",
					LupsAirJet = "On",
					LupsRibbon = "On",
					LupsNanoParticles = "Cloud",
					LupsShieldShader = "Default",
					LupsWaterSettings = "Off",
					FancySky = "Off",
					UseNewChili = "Off",
				}
			},
			{
				name = "High",
				settings = {
					WaterType_2 = "Bumpmapped",
					WaterQuality = "High",
					Shadows = "Units and Terrain",
					ShadowMapSize = "8192",
					ShadowDetail = "High",
					ParticleLimit = "25000",
					TerrainDetail = "High",
					SoftParticles = "Enabled",
					VegetationDetail = "High",
					FeatureFade = "On",
					CompatibilityMode = "Off",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "High",
					VSync = "Off",
					ShaderDetail = "High",
					LupsAirJet = "On",
					LupsRibbon = "On",
					LupsNanoParticles = "Cloud",
					LupsShieldShader = "Default",
					LupsWaterSettings = "Off",
					FancySky = "Off",
					UseNewChili = "Off",
				}
			}
		},

		-- FIXME: this list is in dire need of resorting
		settings = {
			{
				name = "DisplayMode",
				humanName = "Ingame Display Mode",
				displayModeToggle = true,
			},
			{
				name = "LobbyDisplayMode",
				humanName = "Menu Display Mode",
				lobbyDisplayModeToggle = true,
			},
			{
				name = "ActiveGraphicsLabel",
				humanName = "Graphics Driver Selected: ",
				isLabelSetting = true,
				desc = Platform.gpuVendor,
				size = 6,
			},
			{
				name = "AntiAliasing",
				humanName = "Anti Aliasing",
				options = {
					{
						name = "Off",
						apply = {
							MSAALevel = 1, -- Required, see https://springrts.com/mantis/view.php?id=5625
							FSAA = 0,
							SmoothLines = 0,
							SmoothPoints = 0,
						}
					},
					{
						name = "Low",
						apply = {
							MSAALevel = 4,
							FSAA = 1,
							SmoothLines = 1,
							SmoothPoints = 1,
						}
					},
					{
						name = "High",
						apply = {
							MSAALevel = 8,
							FSAA = 1,
							SmoothLines = 3,
							SmoothPoints = 3,
						}
					},
				},
			},
			{
				name = "LupsAirJet",
				humanName = "Aircraft Jets",
				options = {
					{
						name = "On",
						applyFunction = UpdateLups,
					},
					{
						name = "Off",
						applyFunction = UpdateLups,
					},
				},
			},
			{
				name = "LupsRibbon",
				humanName = "Aircraft Wing Trails",
				options = {
					{
						name = "On",
						applyFunction = UpdateLups,
					},
					{
						name = "Off",
						applyFunction = UpdateLups,
					},
				},
			},
			{
				name = "CompatibilityMode",
				humanName = "Compatibility Mode",
				options = {
					{
						name = "Off",
						apply = {
							AllowDeferredModelRendering = 1,
							AllowDeferredMapRendering = 1,
							LoadingMT = 0, -- See https://github.com/spring/spring/commit/bdd6b641960759ccadf3e7201e37f2192d873791
							AdvUnitShading = 1,
							AdvMapShading = 1,
							LuaShaders = 1,
							CubeTexSizeReflection = 1024,
							ForceDisableShaders = 0,
							UsePBO = 1,
							["3DTrees"] = 1,
							MaxDynamicMapLights = 1,
							MaxDynamicModelLights = 1,
							ROAM = 1, --Maybe ROAM = 0 when the new renderer is fully developed
						}
					},
					{
						name = "On",
						apply = {
							AllowDeferredModelRendering = 1,
							AllowDeferredMapRendering = 1,
							LoadingMT = 0,
							AdvUnitShading = 0,
							AdvMapShading = 0,
							LuaShaders = 0,
							CubeTexSizeReflection = 1024,
							ForceDisableShaders = 0,
							UsePBO = 0,
							["3DTrees"] = 0,
							MaxDynamicMapLights = 0,
							MaxDynamicModelLights = 0,
							ROAM = 1,
						}
					},
					{
						name = "Extreme",
						apply = {
							AllowDeferredModelRendering = 0,
							AllowDeferredMapRendering = 0,
							LoadingMT = 0,
							AdvUnitShading = 0,
							AdvMapShading = 0,
							LuaShaders = 0,
							CubeTexSizeReflection = 1,
							ForceDisableShaders = 1,
							UsePBO = 0,
							["3DTrees"] = 0,
							MaxDynamicMapLights = 0,
							MaxDynamicModelLights = 0,
							ROAM = 1,
						}
					},
				},
			},
			{
				name = "LupsNanoParticles",
				humanName = "Construction Effect",
				options = {
					{
						name = "Cloud",
						applyFunction = UpdateLups,
					},
					{
						name = "Beam",
						applyFunction = UpdateLups,
					},
				},
			},
			{
				name = "UseNewChili",
				humanName = "Experimental Interface Renderer",
				options = {
					{
						name = "Off",
						apply = {
							ZKUseNewChiliRTT = 0,
						}
					},
					{
						name = "On",
						apply = {
							ZKUseNewChiliRTT = 1,
						}
					},
				},
			},
			{
				name = "FancySky",
				humanName = "Fancy Sky",
				options = {
					{
						name = "On",
						apply = {
							DynamicSky = 1,
							AdvSky = 1,
						}
					},
					{
						name = "Off",
						apply = {
							DynamicSky = 0,
							AdvSky = 0,
						}
					},
				},
			},
			{
				name = "VSync",
				humanName = "Frame Rate Limit (vsync)",
				options = {
					{
						name = "Standard",
						apply = {
							VSync = 1,
						}
					},
					{
						name = "Adaptive",
						apply = {
							VSync = -1,
						}
					},
					{
						name = "Off",
						apply = {
							VSync = 0,
						}
					},
				},
			},
			{
				name = "ParticleLimit",
				humanName = "Particle Limit",
				options = {
					{
						name = "2000",
						apply = {
							MaxParticles = 2000
						}
					},
					{
						name = "4000",
						apply = {
							MaxParticles = 4000
						}
					},
					{
						name = "6000",
						apply = {
							MaxParticles = 6000
						}
					},
					{
						name = "9000",
						apply = {
							MaxParticles = 9000
						}
					},
					{
						name = "12000",
						apply = {
							MaxParticles = 12000
						}
					},
					{
						name = "15000",
						apply = {
							MaxParticles = 15000
						}
					},
					{
						name = "20000",
						apply = {
							MaxParticles = 15000
						}
					},
					{
						name = "25000",
						apply = {
							MaxParticles = 25000
						}
					},
					{
						name = "35000",
						apply = {
							MaxParticles = 25000
						}
					},
					{
						name = "50000",
						apply = {
							MaxParticles = 50000
						}
					},
				},
			},
			{
				name = "FeatureFade",
				humanName = "Rock and Wreck Fade",
				options = {
					{
						name = "On",
						apply = {
							FeatureDrawDistance = 6000,
							FeatureFadeDistance = 4500,
						}
					},
					{
						name = "Off",
						apply = {
							FeatureDrawDistance = 600000,
							FeatureFadeDistance = 600000,
						}
					},
				},
			},
			{
				name = "ShaderDetail",
				humanName = "Shader Detail",
				fileTarget = lupsFileTarget,
				applyFunction = UpdateLups,
				options = {
					{
						name = "Minimal",
						file = "LuaMenu/configs/gameConfig/zk/lups/lups0.cfg"
					},
					{
						name = "Low",
						file = "LuaMenu/configs/gameConfig/zk/lups/lups1.cfg"
					},
					{
						name = "Medium",
						file = "LuaMenu/configs/gameConfig/zk/lups/lups2.cfg"
					},
					{
						name = "High",
						file = "LuaMenu/configs/gameConfig/zk/lups/lups3.cfg"
					},
					{
						name = "Ultra",
						file = "LuaMenu/configs/gameConfig/zk/lups/lups4.cfg"
					},
				},
			},
			{
				name = "LupsWaterSettings",
				humanName = "Shaders Affected by Water",
				options = {
					{
						name = "Off",
						applyFunction = UpdateLups,
					},
					{
						name = "Refraction",
						applyFunction = UpdateLups,
					},
					{
						name = "Reflection",
						applyFunction = UpdateLups,
					},
					{
						name = "Refract and Reflect",
						applyFunction = UpdateLups,
					},
				},
			},
			{
				name = "LupsShieldShader",
				humanName = "Shield Effect Shader",
				options = {
					{
						name = "Default",
						applyFunction = UpdateLups,
					},
					{
						name = "Simple",
						applyFunction = UpdateLups,
					},
					{
						name = "Off",
						applyFunction = UpdateLups,
					},
				},
			},
			{
				name = "Shadows",
				humanName = "Shadows",
				options = {
					{
						name = "None",
						apply = {
							Shadows = 0
						}
					},
					{
						name = "Units Only",
						apply = {
							Shadows = 2
						}
					},
					{
						name = "Units and Terrain",
						apply = {
							Shadows = 1
						}
					},
				},
			},
			{
				name = "ShadowMapSize",
				humanName = "Shadow Map Size",
				options = {
					{
						name = "1024",
						apply = {
							ShadowMapSize = 1024
						}
					},
					{
						name = "2048",
						apply = {
							ShadowMapSize = 2048
						}
					},
					{
						name = "4096",
						apply = {
							ShadowMapSize = 4096
						}
					},
					{
						name = "8192",
						apply = {
							ShadowMapSize = 8192
						}
					},
					{
						name = "16384",
						apply = {
							ShadowMapSize = 16384
						}
					},
				},
			},
			{
				name = "SoftParticles",
				humanName = "Soft Particles",
				options = {
					{
						name = "Disabled",
						apply = {
							SoftParticles = 0
						}
					},
					{
						name = "Compatibility",
						apply = {
							SoftParticles = 1
						}
					},
					{
						name = "Enabled",
						apply = {
							SoftParticles = 2
						}
					},
				},
			},
			{
				name = "TerrainDetail",
				humanName = "Terrain Detail",
				options = {
					{
						name = "Minimal",
						apply = {
							GroundScarAlphaFade = 1,
							GroundDecals = 0,
							GroundDetail = 50,
						}
					},
					{
						name = "Low",
						apply = {
							GroundScarAlphaFade = 0,
							GroundDecals = 1,
							GroundDetail = 70,
						}
					},
					{
						name = "Medium",
						apply = {
							GroundScarAlphaFade = 1,
							GroundDecals = 2,
							GroundDetail = 90,
						}
					},
					{
						name = "High",
						apply = {
							GroundScarAlphaFade = 1,
							GroundDecals = 5,
							GroundDetail = 120,
						}
					},
					{
						name = "Ultra",
						apply = {
							GroundScarAlphaFade = 1,
							GroundDecals = 10,
							GroundDetail = 180,
						}
					},
				},
			},
			{
				name = "UnitReflections",
				humanName = "Unit Reflection Quality",
				options = {
					{
						name="Off",
						apply = {
							CubeTexSizeSpecular = 1,
						}
					},
					{
						name="Low",
						apply = {
							CubeTexSizeSpecular = 64,
						}
					},
					{
						name="Medium",
						apply = {
							CubeTexSizeSpecular = 128,
						}
					},
					{
						name="High",
						apply = {
							CubeTexSizeSpecular = 256,
						}
					},
					{
						name="Ultra",
						apply = {
							CubeTexSizeSpecular = 1024,
						}
					},
				},
			},
			{
				name = "VegetationDetail",
				humanName = "Vegetation Detail",
				options = {
					{
						name = "Minimal",
						apply = {
							TreeRadius = 1000,
							GrassDetail = 0,
						}
					},
					{
						name = "Low",
						apply = {
							TreeRadius = 1000,
							GrassDetail = 0,
						}
					},
					{
						name = "Medium",
						apply = {
							TreeRadius = 1200,
							GrassDetail = 0,
						}
					},
					{
						name = "High",
						apply = {
							TreeRadius = 1500,
							GrassDetail = 0,
						}
					},
					{
						name = "Ultra",
						apply = {
							TreeRadius = 2500,
							GrassDetail = 0,
						}
					},
					{
						name = "Ridiculous",
						apply = {
							TreeRadius = 2500,
							GrassDetail = 0,
						}
					},
				},
			},

			{
				name = "WaterType_2",
				humanName = "Water Type",
				options = {
					{
						name = "Basic",
						apply = {
							Water = 0,
						}
					},
					{
						name = "Reflective",
						apply = {
							Water = 1,
						}
					},
					{
						name = "Refractive",
						apply = {
							Water = 2,
						}
					},
					--{
					--	name = "Dynamic",
					--	apply = {
					--		Water = 3,
					--	}
					--},
					{
						name = "Bumpmapped",
						apply = {
							Water = 4,
						}
					},
				},
			},
			{
				name = "WaterQuality",
				humanName = "Water Quality",
				options = {
					{
						name = "Low",
						apply = {
							BumpWaterAnisotropy = 0,
							BumpWaterBlurReflection = 0,
							BumpWaterReflection = 0,
							BumpWaterRefraction = 0,
							BumpWaterDepthBits = 16,
							BumpWaterShoreWaves = 0,
							BumpWaterTexSizeReflection = 64,
						}
					},
					{
						name = "Medium",
						apply = {
							BumpWaterAnisotropy = 0,
							BumpWaterBlurReflection = 1,
							BumpWaterReflection = 1,
							BumpWaterRefraction = 1,
							BumpWaterDepthBits = 24,
							BumpWaterShoreWaves = 1,
							BumpWaterTexSizeReflection = 128,
						}
					},
					{
						name = "High",
						apply = {
							BumpWaterAnisotropy = 2,
							BumpWaterBlurReflection = 1,
							BumpWaterReflection = 2,
							BumpWaterRefraction = 1,
							BumpWaterDepthBits = 32,
							BumpWaterShoreWaves = 1,
							BumpWaterTexSizeReflection = 256,
						}
					},
					{
						name = "Ultra",
						apply = {
							BumpWaterAnisotropy = 2,
							BumpWaterBlurReflection = 1,
							BumpWaterReflection = 2,
							BumpWaterRefraction = 2,
							BumpWaterDepthBits = 32,
							BumpWaterShoreWaves = 1,
							BumpWaterTexSizeReflection = 1024,
						}
					},
				},
			},
		},
	},
	{
		name = "Game",
		presets = {
			{
				name = "Default",
				settings = {
					--IconDistance = 151,
					InterfaceScale = defaultUiScale,
					MouseZoomSpeed = 25,
					InvertZoom = "Off",
					HardwareCursor = "On",
					TextToSpeech = "On",
					EdgeScroll = "On",
					CommandAlpha = 60,
					QueueIconAlpha = 45,
					MiddlePanSpeed = 15,
					CameraPanSpeed = 50,
					NetworkSettings = "Balanced",
					SmoothBuffer = "Off",
				}
			},
		},
		settings = {
			--{
			--	name = "IconDistance",
			--	humanName = "Icon Distance",
			--	isNumberSetting = true,
			--	applyName = "UnitIconDist",
			--	minValue = 0,
			--	maxValue = 10000,
			--	springConversion = function(value)
			--		return value
			--	end,
			--},
			{
				name = "InterfaceScale",
				humanName = "Game Interface Scale",
				isNumberSetting = true,
				minValue = minUiScale,
				maxValue = maxUiScale,
				isPercent = true,
				applyFunction = function(value)
					if Spring.GetGameName() ~= "" then
						Spring.SendLuaUIMsg("SetInterfaceScale " .. value)
					end
					return {
						interfaceScale = value,
					}
				end,
			},
			{
				name = "MouseZoomSpeed",
				humanName = "Mouse Zoom Speed",
				isNumberSetting = true,
				applyName = "ScrollWheelSpeed",
				minValue = 1,
				maxValue = 500,
				springConversion = function(value)
					return value*invertZoomMult
				end,
			},
			{
				name = "InvertZoom",
				humanName = "Invert Zoom",
				options = {
					{
						name = "On",
						applyFunction = function(_, conf)
							conf = conf or (WG.Chobby and WG.Chobby.Configuration)
							if not conf then
								return {}
							end
							invertZoomMult = 1
							local currentZoom = conf.settingsMenuValues["MouseZoomSpeed"] or 25
							return {
								ScrollWheelSpeed = currentZoom,
							}
						end
					},
					{
						name = "Off",
						applyFunction = function(_, conf)
							conf = conf or (WG.Chobby and WG.Chobby.Configuration)
							if not conf then
								return {}
							end
							invertZoomMult = -1
							local currentZoom = conf.settingsMenuValues["MouseZoomSpeed"] or 25
							return {
								ScrollWheelSpeed = currentZoom * -1,
							}
						end
					},
				},
			},
			{
				name = "HardwareCursor",
				humanName = "Hardware Cursor",
				options = {
					{
						name = "On",
						apply = {
							HardwareCursor = 1,
						}
					},
					{
						name = "Off",
						apply = {
							HardwareCursor = 0,
						}
					},
				},
			},
			{
				name = "TextToSpeech",
				humanName = "Text To Speech",
				options = {
					{
						name = "On",
						applyFunction = function(_, conf)
							conf = conf or (WG.Chobby and WG.Chobby.Configuration)
							if not conf then
								return {}
							end
							conf:SetConfigValue("enableTextToSpeech", true)
							return false
						end
					},
					{
						name = "Off",
						applyFunction = function(_, conf)
							conf = conf or (WG.Chobby and WG.Chobby.Configuration)
							if not conf then
								return false
							end
							conf:SetConfigValue("enableTextToSpeech", false)
							return false
						end
					},
				},
			},
			{
				name = "EdgeScroll",
				humanName = "Screen Edge Scroll",
				options = {
					{
						name = "On",
						apply = {
							FullscreenEdgeMove = 1,
							WindowedEdgeMove = 1,
						}
					},
					{
						name = "Off",
						apply = {
							FullscreenEdgeMove = 0,
							WindowedEdgeMove = 0,
						}
					},
				},
			},
			{
				name = "CommandAlpha",
				humanName = "Command Line Alpha (%)",
				isNumberSetting = true,
				minValue = 10,
				maxValue = 100,
				applyFunction = UpdateCmdcolors
			},
			{
				name = "QueueIconAlpha",
				humanName = "Command Icon Alpha (%)",
				isNumberSetting = true,
				minValue = 10,
				maxValue = 100,
				applyFunction = UpdateCmdcolors
			},
			{
				name = "MiddlePanSpeed",
				humanName = "Middle Click Pan Speed",
				isNumberSetting = true,
				minValue = 0,
				maxValue = 1000,
				applyFunction = function(value, conf)
					conf = conf or (WG.Chobby and WG.Chobby.Configuration)
					local camPan = 50
					if conf and conf.game_settings then
						camPan = conf.game_settings.OverheadScrollSpeed or camPan
					end
					value = value*(-1/200)
					return {
						MiddleClickScrollSpeed = value/camPan,
					}
				end,
			},
			{
				name = "CameraPanSpeed",
				humanName = "Camera Pan Speed",
				isNumberSetting = true,
				minValue = 0,
				maxValue = 1000,
				applyFunction = function(value, conf)
					conf = conf or (WG.Chobby and WG.Chobby.Configuration)
					local middleScroll = 10
					if conf and conf.settingsMenuValues then
						middleScroll = conf.settingsMenuValues.MiddlePanSpeed or middleScroll
					end
					middleScroll = middleScroll*(-1/200)
					return {
						MiddleClickScrollSpeed = middleScroll/value,
						OverheadScrollSpeed = value,
						RotOverheadScrollSpeed = value,
						CamFreeScrollSpeed = value,
						FPSScrollSpeed = value,
					}
				end,
			},
			{
				name = "NetworkSettings",
				humanName = "Network Connection",
				options = {
					{
						name = "Reliable",
						apply = {
							NetworkLossFactor = 0,
							LinkOutgoingBandwidth = 65536,
							LinkIncomingSustainedBandwidth = 2048,
							LinkIncomingPeakBandwidth = 32768,
							LinkIncomingMaxPacketRate = 64,
						}
					},
					{
						name = "Balanced",
						apply = {
							NetworkLossFactor = 1,
							LinkOutgoingBandwidth = 131072,
							LinkIncomingSustainedBandwidth = 65536,
							LinkIncomingPeakBandwidth = 65536,
							LinkIncomingMaxPacketRate = 512,
						}
					},
					{
						name = "Fast",
						apply = {
							NetworkLossFactor = 2,
							LinkOutgoingBandwidth = 262144,
							LinkIncomingSustainedBandwidth = 262144,
							LinkIncomingPeakBandwidth = 262144,
							LinkIncomingMaxPacketRate = 2048,
						}
					},
				},
			},
			{
				name = "SmoothBuffer",
				humanName = "Smooth Buffer",
				options = {
					{
						name = "On",
						apply = {
							UseNetMessageSmoothingBuffer = 1,
						}
					},
					{
						name = "Off",
						apply = {
							UseNetMessageSmoothingBuffer = 0,
						}
					},
				},
			},
			{
				name = "GcRate",
				humanName = "GC Rate",
				options = {
					{
						name = "Highest performance",
						apply = {
							LuaGarbageCollectionMemLoadMult = 1.7,
						}
					},
					{
						name = "Higher performance",
						apply = {
							LuaGarbageCollectionMemLoadMult = 2.4,
						}
					},
					{
						name = "More performance",
						apply = {
							LuaGarbageCollectionMemLoadMult = 3.2,
						}
					},
					{
						name = "Recommended",
						apply = {
							LuaGarbageCollectionMemLoadMult = 4.5,
						}
					},
					{
						name = "More Stability",
						apply = {
							LuaGarbageCollectionMemLoadMult = 6,
						}
					},
					{
						name = "Higher Stability",
						apply = {
							LuaGarbageCollectionMemLoadMult = 8,
						}
					},
					{
						name = "Highest Stability",
						apply = {
							LuaGarbageCollectionMemLoadMult = 10,
						}
					},
				},
			},
			{
				name = "GcTimeMult",
				humanName = "GC Time Mult",
				options = {
					{
						name = "Highest performance",
						apply = {
							LuaGarbageCollectionRunTimeMult = 1.4,
						}
					},
					{
						name = "Higher Performance",
						apply = {
							LuaGarbageCollectionRunTimeMult = 1.7,
						}
					},
					{
						name = "More Performance",
						apply = {
							LuaGarbageCollectionRunTimeMult = 2,
						}
					},
					{
						name = "Recommended",
						apply = {
							LuaGarbageCollectionRunTimeMult = 3,
						}
					},
					{
						name = "More Stability",
						apply = {
							LuaGarbageCollectionRunTimeMult = 4,
						}
					},
					{
						name = "Higher Stability",
						apply = {
							LuaGarbageCollectionRunTimeMult = 5,
						}
					},
					{
						name = "Highest Stability",
						apply = {
							LuaGarbageCollectionRunTimeMult = 6,
						}
					},
				},
			},
			{
				name = "AtiIntelCompatibility_2",
				humanName = "ATI/Intel Compatibility",
				options = {
					{
						name = "On",
						applyFunction = function(_, conf)
							conf:UpdateFixedSettings(conf.AtiIntelSettingsOverride)
							Spring.Echo("Set ATI/intel/other non-nvidia compatibility state: Enabled")
							return
						end
					},
					{
						name = "Automatic",
						applyFunction = function(_, conf)
							if conf:GetIsNotRunningNvidia() then
								conf:UpdateFixedSettings(conf.AtiIntelSettingsOverride)
								Spring.Echo("Set ATI/intel/other non-nvidia compatibility state: Enabled (Automatic)")
								return
							end
							conf:UpdateFixedSettings()
							Spring.Echo("Set ATI/intel/other non-nvidia compatibility state: Disabled (Automatic)")
							return
						end
					},
					{
						name = "Off",
						applyFunction = function(_, conf)
							conf:UpdateFixedSettings()
							Spring.Echo("Set ATI/intel/other non-nvidia compatibility state: Disabled")
							return
						end
					},
				},
			},
		},
	},
}

local settingsDefault = {
	WaterType_2 = "Bumpmapped",
	WaterQuality = "Medium",
	Shadows = "Units and Terrain",
	ShadowMapSize = "2048",
	ShadowDetail = "Medium",
	ParticleLimit = "15000",
	TerrainDetail = "Medium",
	SoftParticles = "Enabled",
	VegetationDetail = "Medium",
	FeatureFade = "Off",
	CompatibilityMode = "Off",
	AtiIntelCompatibility_2 = "Automatic",
	AntiAliasing = "Low",
	VSync = "Off",
	ShaderDetail = "Medium",
	LupsAirJet = "On",
	LupsRibbon = "On",
	LupsNanoParticles = "Cloud",
	LupsShieldShader = "Default",
	LupsWaterSettings = "Off",
	FancySky = "Off",
	UseNewChili = "Off",
	--IconDistance = 151,
	InterfaceScale = defaultUiScale,
	MouseZoomSpeed = 25,
	InvertZoom = "Off",
	HardwareCursor = "On",
	TextToSpeech = "On",
	EdgeScroll = "On",
	CommandAlpha = 60,
	QueueIconAlpha = 45,
	MiddlePanSpeed = 15,
	CameraPanSpeed = 50,
	NetworkSettings = "Balanced",
	SmoothBuffer = "Off",
	GcRate = "Recommended",
	GcTimeMult = "Recommended",
}

local settingsNames = {}
for i = 1, #settingsConfig do
	local subSettings = settingsConfig[i].settings
	for j = 1, #subSettings do
		local data = subSettings[j]
		settingsNames[data.name] = data
		if data.options then
			data.optionNames = {}
			for k = 1, #data.options do
				data.optionNames[data.options[k].name] = data.options[k]
			end
		end
	end
end

local function DefaultPresetFunc()
	local gameDefault = settingsConfig[2].presets[1].settings

	if Platform then
		local gpuMemorySize = Platform.gpuMemorySize or 0
		if gpuMemorySize == 0 then
			-- Apparently gpuMemorySize only exists on nvidia
			if Platform.glVersionShort and string.sub(Platform.glVersionShort or "3", 1, 1) ~= "3" then
				-- Medium
				Spring.Echo("Medium settings preset", Platform.glVersionShort)
				return Spring.Utilities.MergeTable(gameDefault, settingsConfig[1].presets[4].settings, true)
			else
				-- Default to Low
				Spring.Echo("Low settings preset", Platform.glVersionShort)
				return Spring.Utilities.MergeTable(gameDefault, settingsConfig[1].presets[3].settings, true)
			end
		else
			-- gpuMemorySize is in KB even though wiki claims MB.
			if gpuMemorySize < 1024*1024 then
				-- Minimal
				Spring.Echo("Minimal settings preset", gpuMemorySize)
				return Spring.Utilities.MergeTable(gameDefault, settingsConfig[1].presets[2].settings, true)
			elseif gpuMemorySize < 2048*1024 then
				-- Low
				Spring.Echo("Low settings preset", gpuMemorySize)
				return Spring.Utilities.MergeTable(gameDefault, settingsConfig[1].presets[3].settings, true)
			elseif gpuMemorySize == 2048*1024 then
				-- Medium
				Spring.Echo("Medium settings preset", gpuMemorySize)
				return Spring.Utilities.MergeTable(gameDefault, settingsConfig[1].presets[4].settings, true)
			else
				-- High
				Spring.Echo("High settings preset", gpuMemorySize)
				return Spring.Utilities.MergeTable(gameDefault, settingsConfig[1].presets[5].settings, true)
			end
		end
	end

	-- Default to Medium
	Spring.Echo("Medium settings preset", Platform, (Platform or {}).gpuMemorySize, (Platform or {}).glVersionShort)
	return Spring.Utilities.MergeTable(gameDefault, settingsConfig[1].presets[4].settings, true)
end

return settingsConfig, settingsNames, settingsDefault, DefaultPresetFunc
