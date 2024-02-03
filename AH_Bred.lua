-- [x] -- Название скрипта. -- [x] --
script_name("Admin Helper")
script_author("Yamada.")
script_version('8.1')
local script_version_text = "8.10"

-- [x] -- Библиотеки. -- [x] --
local sampev							= require "lib.samp.events"
local font_admin_chat					= require ("moonloader").font_flag
local ev								= require ("moonloader").audiostream_state
local dlstat							= require ("moonloader").download_status
local as_action                         = require('moonloader').audiostream_state
local ffi 								= require "ffi"
local getBonePosition 					= ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local mem 								= require "memory"
local imgui 							= require "imgui"
local encoding							= require "encoding"
local vkeys								= require "lib.vkeys"
local inicfg							= require "inicfg"
local notfy								= import 'lib/lib_imgui_notf.lua'
local res, sc_board						= pcall(import, 'lib/scoreboard.lua')
local fa 								= require 'faIcons'
--local pie								= require "imgui_piemenu"
--local theme_res, themes				= pcall(import, "config/AH_Setting/imgui_themes.lua")
encoding.default 						= "CP1251"
u8 										= encoding.UTF8
local lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text
local checker_lvl, checker_adm, checker_color, checker_nick, checker_id
local access_check, Access = _, {}

local FloodsFilePath = getWorkingDirectory() .. "\\config\\AH_Setting\\customFloods.ah"
local controlLoadFlood = nil
local countLoadFlood = nil

local check_load_access = false
 
local username = os.getenv('USERNAME')
local dir_doc = 'C:\\users\\' .. username .. '\\Documents'


local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })


function imgui.BeforeDrawFrame()

    if fa_font == nil then

		local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
		font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 15.0, font_config, fa_glyph_ranges)

    end

end

local config = {
	achat = {
		X = 0,
		Y = 0,
		centered = 0,
		nick = 0,
		color = 0,
		lines = 0
	}
}

local tabs_tabel = {
	setting = {
		gset = true,
		achatset = false,
		developer = false,
		keyset = false,
		floods = false
	},
	recon = {
		info = true,
		punish = false,
		recon_setting = false,
		stream_players = false
	}
}

local customFloods_set = {}
local customFloods_key = {}
local customFloods_txt = {}

local report_windows = {}

local defTable = {
	setting = {
		Tranparency = false,
		Auto_remenu = false,
		Custom_SB = false,
		Fast_ans = false,
		WallHack = false,
		Punishments = false,
		Y = 300,
		Admin_chat = false,
		Push_Report = false,
		Chat_Logger = false,
		Chat_Logger_osk = false,
		hide_td = false,
		skip_dialogs = false,
		anti_cheat = false,
		auto_report = false,
		text_anticheat = false,
		sp_autologin = false,
		HelloAC = "hi",
		AdminPassword = '',
		alogin_skin = "",
		alogin_hiCheckbox = false,
		AutoHi = '',
		prefix_Helper = '',
		prefix_MA = '',
		prefix_Adm = '',
		prefix_StAdm = '',
		prefix_Zga = '',
		prefix_PGA = '',
		prefix_Ga = '',
		prf_id = 0,
		admlvl = 0,
		style = 0,
		report_day = "",
		report_all = ""
		
	},
	stats_window = {
		x_pos = 100,
		y_pos = 100,
		report_day = "",
		report_all_time = "",
	},
	color = {
		r = 1,
		g = 0,
		b = 0,
		a = 1
	},
	keys = {
		Setting = "End",
		Re_menu = "None",
		Hello = "None",
		P_Log = "None",
		Hide_AChat = "None",
		Mouse = "None",
		wh = 'None',
		trc = 'None',
		online = 'None'
	},
	achat = {
		X = 48,
		Y = 298,
		centered = 0,
		color = -1,
		nick = 1,
		lines = 10,
		Font = 10
	}
}

local tCarsName = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
"Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
"RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
"Yankee", "Caddy", "Solair", "Berkley'sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
"Dozer", "Maverick", "NewsChopper", "Rancher", "FBIRancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "BlistaCompact", "PoliceMaverick",
"Boxvillde", "Benson", "Mesa", "RCGoblin", "HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
"MountainBike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
"CementTruck", "TowTruck", "Fortune", "Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
"Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
"Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
"FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
"Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "PoliceCar", "PoliceCar",
"PoliceCar", "PoliceRanger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
"UtilityTrailer"}

----------------------------------------------------------------------------- imgui.ImBool()
local punishments_request_ban = imgui.ImBool(false)
local i_ans_window = imgui.ImBool(false)
local i_setting_items = imgui.ImBool(false)
local i_back_prefix = imgui.ImBool(false)
local i_info_update = imgui.ImBool(false)
local i_re_menu = imgui.ImBool(false)
local i_cmd_helper = imgui.ImBool(false)
local i_chat_logger = imgui.ImBool(false)
local i_admin_chat_setting = imgui.ImBool(false)
local menu_tems = imgui.ImBool(false)
local stats_window_imgui = imgui.ImBool(false)
local ans_ans = imgui.ImBool(false)
---------------------------------------------------------------------------- imgui.ImBuffer()
local prefix_Helper = imgui.ImBuffer(200)
local prefix_MA = imgui.ImBuffer(200)
local prefix_Adm = imgui.ImBuffer(200)
local prefix_StAdm = imgui.ImBuffer(200)
local prefix_Zga = imgui.ImBuffer(200)
local prefix_PGA = imgui.ImBuffer(200)
local font_size_ac = imgui.ImBuffer(32)
local HelloAC = imgui.ImBuffer(300)
local AdminPassword = imgui.ImBuffer(200)
local AutoHi = imgui.ImBuffer(200)
local chat_logger = imgui.ImBuffer(10000)
local chat_find = imgui.ImBuffer(256)
local ans_ans_ans = imgui.ImBuffer(1000)
local rename_flood = imgui.ImBuffer(200)
local control_rename_flood = false
---------------------------------------------------------------------------- imgui.ImInt()
local admlvl = imgui.ImInt(defTable.setting.admlvl)
local style = imgui.ImInt(defTable.setting.style)
local punish = imgui.ImInt(0)
local mp_combo = imgui.ImInt(0)
local line_ac = imgui.ImInt(16)
local checked_radio = imgui.ImInt(5)

plates = {}
punish_text = ""

lua_thread.create(function()
	while true do
		wait(10000)
		for k, v in pairs(plates) do
			if not doesVehicleExist(select(2, sampGetCarHandleBySampVehicleId(tonumber(k)))) then
				plates[tonumber(k)] = nil
			end
		end
	end
end)

function sampev.onSetVehicleNumberPlate(id, text)
	plates[id] = text
end

function getPlate(id)
	if plates[tonumber(id)] ~= nil then
		return plates[tonumber(id)]
	else
		return "Iao aaiiuo"
	end
end

colours = {
-- The existing colours from San Andreas
"0x080808FF", "0xF5F5F5FF", "0x2A77A1FF", "0x840410FF", "0x263739FF", "0x86446EFF", "0xD78E10FF", "0x4C75B7FF", "0xBDBEC6FF", "0x5E7072FF",
"0x46597AFF", "0x656A79FF", "0x5D7E8DFF", "0x58595AFF", "0xD6DAD6FF", "0x9CA1A3FF", "0x335F3FFF", "0x730E1AFF", "0x7B0A2AFF", "0x9F9D94FF",
"0x3B4E78FF", "0x732E3EFF", "0x691E3BFF", "0x96918CFF", "0x515459FF", "0x3F3E45FF", "0xA5A9A7FF", "0x635C5AFF", "0x3D4A68FF", "0x979592FF",
"0x421F21FF", "0x5F272BFF", "0x8494ABFF", "0x767B7CFF", "0x646464FF", "0x5A5752FF", "0x252527FF", "0x2D3A35FF", "0x93A396FF", "0x6D7A88FF",
"0x221918FF", "0x6F675FFF", "0x7C1C2AFF", "0x5F0A15FF", "0x193826FF", "0x5D1B20FF", "0x9D9872FF", "0x7A7560FF", "0x989586FF", "0xADB0B0FF",
"0x848988FF", "0x304F45FF", "0x4D6268FF", "0x162248FF", "0x272F4BFF", "0x7D6256FF", "0x9EA4ABFF", "0x9C8D71FF", "0x6D1822FF", "0x4E6881FF",
"0x9C9C98FF", "0x917347FF", "0x661C26FF", "0x949D9FFF", "0xA4A7A5FF", "0x8E8C46FF", "0x341A1EFF", "0x6A7A8CFF", "0xAAAD8EFF", "0xAB988FFF",
"0x851F2EFF", "0x6F8297FF", "0x585853FF", "0x9AA790FF", "0x601A23FF", "0x20202CFF", "0xA4A096FF", "0xAA9D84FF", "0x78222BFF", "0x0E316DFF",
"0x722A3FFF", "0x7B715EFF", "0x741D28FF", "0x1E2E32FF", "0x4D322FFF", "0x7C1B44FF", "0x2E5B20FF", "0x395A83FF", "0x6D2837FF", "0xA7A28FFF",
"0xAFB1B1FF", "0x364155FF", "0x6D6C6EFF", "0x0F6A89FF", "0x204B6BFF", "0x2B3E57FF", "0x9B9F9DFF", "0x6C8495FF", "0x4D8495FF", "0xAE9B7FFF",
"0x406C8FFF", "0x1F253BFF", "0xAB9276FF", "0x134573FF", "0x96816CFF", "0x64686AFF", "0x105082FF", "0xA19983FF", "0x385694FF", "0x525661FF",
"0x7F6956FF", "0x8C929AFF", "0x596E87FF", "0x473532FF", "0x44624FFF", "0x730A27FF", "0x223457FF", "0x640D1BFF", "0xA3ADC6FF", "0x695853FF",
"0x9B8B80FF", "0x620B1CFF", "0x5B5D5EFF", "0x624428FF", "0x731827FF", "0x1B376DFF", "0xEC6AAEFF", "0x000000FF",
-- SA-MP extended colours (0.3x)
"0x177517FF", "0x210606FF", "0x125478FF", "0x452A0DFF", "0x571E1EFF", "0x010701FF", "0x25225AFF", "0x2C89AAFF", "0x8A4DBDFF", "0x35963AFF",
"0xB7B7B7FF", "0x464C8DFF", "0x84888CFF", "0x817867FF", "0x817A26FF", "0x6A506FFF", "0x583E6FFF", "0x8CB972FF", "0x824F78FF", "0x6D276AFF",
"0x1E1D13FF", "0x1E1306FF", "0x1F2518FF", "0x2C4531FF", "0x1E4C99FF", "0x2E5F43FF", "0x1E9948FF", "0x1E9999FF", "0x999976FF", "0x7C8499FF",
"0x992E1EFF", "0x2C1E08FF", "0x142407FF", "0x993E4DFF", "0x1E4C99FF", "0x198181FF", "0x1A292AFF", "0x16616FFF", "0x1B6687FF", "0x6C3F99FF",
"0x481A0EFF", "0x7A7399FF", "0x746D99FF", "0x53387EFF", "0x222407FF", "0x3E190CFF", "0x46210EFF", "0x991E1EFF", "0x8D4C8DFF", "0x805B80FF",
"0x7B3E7EFF", "0x3C1737FF", "0x733517FF", "0x781818FF", "0x83341AFF", "0x8E2F1CFF", "0x7E3E53FF", "0x7C6D7CFF", "0x020C02FF", "0x072407FF",
"0x163012FF", "0x16301BFF", "0x642B4FFF", "0x368452FF", "0x999590FF", "0x818D96FF", "0x99991EFF", "0x7F994CFF", "0x839292FF", "0x788222FF",
"0x2B3C99FF", "0x3A3A0BFF", "0x8A794EFF", "0x0E1F49FF", "0x15371CFF", "0x15273AFF", "0x375775FF", "0x060820FF", "0x071326FF", "0x20394BFF",
"0x2C5089FF", "0x15426CFF", "0x103250FF", "0x241663FF", "0x692015FF", "0x8C8D94FF", "0x516013FF", "0x090F02FF", "0x8C573AFF", "0x52888EFF",
"0x995C52FF", "0x99581EFF", "0x993A63FF", "0x998F4EFF", "0x99311EFF", "0x0D1842FF", "0x521E1EFF", "0x42420DFF", "0x4C991EFF", "0x082A1DFF",
"0x96821DFF", "0x197F19FF", "0x3B141FFF", "0x745217FF", "0x893F8DFF", "0x7E1A6CFF", "0x0B370BFF", "0x27450DFF", "0x071F24FF", "0x784573FF",
"0x8A653AFF", "0x732617FF", "0x319490FF", "0x56941DFF", "0x59163DFF", "0x1B8A2FFF", "0x38160BFF", "0x041804FF", "0x355D8EFF", "0x2E3F5BFF",
"0x561A28FF", "0x4E0E27FF", "0x706C67FF", "0x3B3E42FF", "0x2E2D33FF", "0x7B7E7DFF", "0x4A4442FF", "0x28344EFF"
}

function getBodyPartCoordinates(id, handle)
	local pedptr = getCharPointer(handle)
	local vec = ffi.new("float[3]")
	getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
	return vec[0], vec[1], vec[2]
end

lua_thread.create(function()
	font = renderCreateFont("Roboto", 9, 5)
	while true do
		wait(0)
		if activation then

			if isCharInAnyCar(PLAYER_PED) then
				mycar = getCarCharIsUsing(PLAYER_PED)
			end

			for _, handle in ipairs(getAllVehicles()) do
				if handle ~= mycar and doesVehicleExist(handle) and isCarOnScreen(handle) then
					vehName = getGxtText(getNameOfVehicleModel(getCarModel(handle)))
					myX, myY, myZ = getBodyPartCoordinates(8, PLAYER_PED)
					X, Y, Z = getCarCoordinates(handle)
					distance = getDistanceBetweenCoords3d(X, Y, Z, myX, myY, myZ)
					X, Y = convert3DCoordsToScreen(X, Y, Z + 1)
					_, id = sampGetVehicleIdByCarHandle(handle)
					local primaryColor, secondaryColor = getCarColours(handle)
					color = colours[primaryColor + 1]
					color = color:sub(3, -3)
					if primaryColor ~= secondaryColor then
						secColor = colours[secondaryColor + 1]
						secColor = secColor:sub(3, -3)
						if vehName:find(" ") then
							vehName = vehName:gsub(" ", " {"..secColor.."}")
							vehName = "{ffffff}"..vehName
						else
							if (#vehName % 2 == 0) then
								first = math.ceil(#vehName / 2)
								second = #vehName - first + 1
								vehName = "{ffffff}"..vehName:sub(1, first).."{"..secColor.."}"..vehName:sub(second)
							else
								first = math.ceil(#vehName / 2)
								second = #vehName - first + 2
								vehName = "{ffffff}"..vehName:sub(1, first).."{"..secColor.."}"..vehName:sub(second)
							end
						end
					else
						vehName = "{ffffff}"..vehName
					end
					renderFontDrawText(font, vehName .. "{ffffff} [".. id .."]", X - 10, Y, -1)
				end
			end
		end
  	end
end)

local ac_string = ''
local adm_form = ''

local check_ac_list = {
	"control"
}

local update_state = {
	update_script = false,
	update_scoreboard = false
}

ffi.cdef[[
struct stKillEntry
{
	char					szKiller[25];
	char					szVictim[25];
	uint32_t				clKillerColor; // D3DCOLOR
	uint32_t				clVictimColor; // D3DCOLOR
	uint8_t					byteType;
} __attribute__ ((packed));

struct stKillInfo
{
	int						iEnabled;
	struct stKillEntry		killEntry[5];
	int 					iLongestNickLength;
	int 					iOffsetX;
	int 					iOffsetY;
	void			    	*pD3DFont; // ID3DXFont
	void		    		*pWeaponFont1; // ID3DXFont
	void		   	    	*pWeaponFont2; // ID3DXFont
	void					*pSprite;
	void					*pD3DDevice;
	int 					iAuxFontInited;
	void 		    		*pAuxFont1; // ID3DXFont
	void 			    	*pAuxFont2; // ID3DXFont
} __attribute__ ((packed));
]]

local script_version = 63
local update_url = "https://raw.githubusercontent.com/YamadaEnotic/AH-Script/master/update.ini"
local update_path = getWorkingDirectory() .. '/update.ini'
local script_url = "https://raw.githubusercontent.com/YamadaEnotic/AH-Script/master/AH_Bred.lua"
local script_path = thisScript().path
local scoreboard_url = "https://raw.githubusercontent.com/YamadaEnotic/AH-Script/master/scoreboard.lua"
local scoreboard_path = getWorkingDirectory() .. "\\lib\\scoreboard.lua"
local tag = "{3252b5}[AH by Yamada.]: {CCCCCC}"
local sw, sh = getScreenResolution()
local directIni	= "AH_Setting\\config.ini"
local font_ac
local load_audio = loadAudioStream('moonloader/config/AH_Setting/audio/notification.mp3')
local arr_admlvl = {u8"1 Уровень", u8"2 Уровень", u8"3 Уровень", u8"4 Уровень", u8"5 Уровень", u8"6 Уровень", u8"7 Уровень", u8"8 Уровень", u8"9 Уровень", u8"10 Уровень", u8"11 Уровень", u8"12 Уровень", u8"13 Уровень", u8"14 Уровень", u8"15 Уровень", u8"16 Уровень", u8"17 Уровень", u8"18 Уровень" }
local arr_punish = {"Kick", "Mute", "Ban", "Iban", "Jail"}

function imgui.TextColoredRGB(text, render_text)
	local max_float = imgui.GetWindowWidth()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4

	local explode_argb = function(argb)
		local a = bit.band(bit.rshift(argb, 24), 0xFF)
		local r = bit.band(bit.rshift(argb, 16), 0xFF)
		local g = bit.band(bit.rshift(argb, 8), 0xFF)
		local b = bit.band(argb, 0xFF)
		return a, r, g, b
	end

	local getcolor = function(color)
		if color:sub(1, 6):upper() == 'SSSSSS' then
			local r, g, b = colors[1].x, colors[1].y, colors[1].z
			local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
			return ImVec4(r, g, b, a / 255)
		end
		local color = type(color) == 'string' and tonumber(color, 16) or color
		if type(color) ~= 'number' then return end
		local r, g, b, a = explode_argb(color)
		return imgui.ImColor(r, g, b, a):GetVec4()
	end

	local render_text = function(text_)
		for w in text_:gmatch('[^\r\n]+') do
			local text, colors_, m = {}, {}, 1
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				local color = getcolor(w:sub(n + 1, k - 1))
				if color then
					text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
					colors_[#colors_ + 1] = color
					m = n
				end
				w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
			end

			local length = imgui.CalcTextSize(w)
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i = 0, #text do
					imgui.TextColored(colors_[i] or colors[1], text[i])
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(w) end


		end
	end

	render_text(text)
end

function imgui.Link(link)
	if status_hovered then
		local p = imgui.GetCursorScreenPos()
		imgui.TextColored(imgui.ImVec4(0, 0.5, 1, 1), link)
		imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + imgui.CalcTextSize(link).y), imgui.ImVec2(p.x + imgui.CalcTextSize(link).x, p.y + imgui.CalcTextSize(link).y), imgui.GetColorU32(imgui.ImVec4(0, 0.5, 1, 1)))
	else
		imgui.TextColored(imgui.ImVec4(0, 0.3, 0.8, 1), link)
	end
	if imgui.IsItemClicked() then os.execute('explorer '..link)
	elseif imgui.IsItemHovered() then
		status_hovered = true else status_hovered = false
	end
end

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.HotKey = require('imgui_addons').HotKey
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local icol = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowPadding = imgui.ImVec2(5, 5)
    style.WindowRounding = 15
    style.ChildWindowRounding = 10
    style.FramePadding = imgui.ImVec2(3, 3)
    style.FrameRounding = 6.0
    style.ItemSpacing = imgui.ImVec2(3.0, 3.0)
    style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
    style.IndentSpacing = 21
    style.ScrollbarSize = 6.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 17.0
    style.GrabRounding = 16.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    colors[icol.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00);
    colors[icol.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00);
    colors[icol.WindowBg]               = ImVec4(0.11, 0.11, 0.11, 0.50);
    colors[icol.ChildWindowBg]          = ImVec4(0.13, 0.13, 0.13, 1.00);
    colors[icol.PopupBg]                = ImVec4(0.11, 0.11, 0.11, 1.00);
    colors[icol.Border]                 = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.BorderShadow]           = ImVec4(0.26, 0.46, 0.82, 0.00);
    colors[icol.FrameBg]                = ImVec4(0.26, 0.46, 0.82, 0.59);
    colors[icol.FrameBgHovered]         = ImVec4(0.26, 0.46, 0.82, 0.88);
    colors[icol.FrameBgActive]          = ImVec4(0.28, 0.53, 1.00, 1.00);
    colors[icol.TitleBg]                = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.TitleBgActive]          = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.TitleBgCollapsed]       = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.MenuBarBg]              = ImVec4(0.26, 0.46, 0.82, 0.75);
    colors[icol.ScrollbarBg]            = ImVec4(0.11, 0.11, 0.11, 1.00);
    colors[icol.ScrollbarGrab]          = ImVec4(0.26, 0.46, 0.82, 0.68);
    colors[icol.ScrollbarGrabHovered]   = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.ScrollbarGrabActive]    = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.ComboBg]                = ImVec4(0.26, 0.46, 0.82, 0.79);
    colors[icol.CheckMark]              = ImVec4(1.000, 0.000, 0.000, 1.000)
    colors[icol.SliderGrab]             = ImVec4(0.263, 0.459, 0.824, 1.000)
    colors[icol.SliderGrabActive]       = ImVec4(0.66, 0.66, 0.66, 1.00);
    colors[icol.Button]                 = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.ButtonHovered]          = ImVec4(0.26, 0.46, 0.82, 0.59);
    colors[icol.ButtonActive]           = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.Header]                 = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.HeaderHovered]          = ImVec4(0.26, 0.46, 0.82, 0.74);
    colors[icol.HeaderActive]           = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.Separator]              = ImVec4(0.37, 0.37, 0.37, 1.00);
    colors[icol.SeparatorHovered]       = ImVec4(0.60, 0.60, 0.70, 1.00);
    colors[icol.SeparatorActive]        = ImVec4(0.70, 0.70, 0.90, 1.00);
    colors[icol.ResizeGrip]             = ImVec4(1.00, 1.00, 1.00, 0.30);
    colors[icol.ResizeGripHovered]      = ImVec4(1.00, 1.00, 1.00, 0.60);
    colors[icol.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90);
    colors[icol.CloseButton]            = ImVec4(0.00, 0.00, 0.00, 1.00);
    colors[icol.CloseButtonHovered]     = ImVec4(0.00, 0.00, 0.00, 0.60);
    colors[icol.CloseButtonActive]      = ImVec4(0.35, 0.35, 0.35, 1.00);
    colors[icol.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[icol.PlotLinesHovered]       = ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[icol.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[icol.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00);
    colors[icol.TextSelectedBg]         = ImVec4(0.00, 0.00, 1.00, 0.35);
    colors[icol.ModalWindowDarkening]   = ImVec4(0.20, 0.20, 0.20, 0.35);
end
apply_custom_style()

local admin_chat_lines = {
	centered = imgui.ImInt(0),
	nick = imgui.ImInt(1),
	color = -1,
	lines = imgui.ImInt(10),
	X = 0,
	Y = 0
}
local ac_no_saved = {
	chat_lines = { },
	pos = false,
	X = 0,
	Y = 0
}
local punishments = {
	["ch"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП."
	},
	["sob"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП. (S0beit)"
	},
	["aim"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП. (Aim)"
	},
	["rvn"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП. (Rvanka)"
	},
	["cars"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП. (Car Shot)"
	},
	["ac"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП. (Auto +C)"
	},
	["ich"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП."
	},
	["isob"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП. (S0beit)"
	},
	["iaim"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП. (Aim)"
	},
	["irvn"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП. (Rvanka)"
	},
	["icars"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП. (Car Shot)"
	},
	["iac"] = {
		cmd = "iban",
		time = 7,
		acmd = "jail",
		atime = "3000",
		reason = "ИЗП. (Auto +C)"
	},
	["bn"] = {
		cmd = "iban",
		time = 3,
		acmd = "jail",
		atime = "3000",
		reason = "Неадекватное поведение."
	},
	-- [x] -- Муты -- [x] --
	["um"] = {
		cmd = "unmute",
		time = 0,
		reason = "Размутить игрока."
	},
	["osk"] = {
		cmd = "mute",
		time = 400,
		reason = "Оскорбление игрока(-ов)."
	},
	["uni"] = {
		cmd = "mute",
		time = 400,
		reason = "Унижение игрока(-ов)."
	},
	["roz"] = {
		cmd = "mute",
		time = 5000,
		reason = "Межнациональный розжиг."
	},
	["rnead"] = {
		cmd = "rmute",
		time = 600,
		reason = "Неадекватное поведение. (/report)"
	},
	["rup"] = {
		cmd = "rmute",
		time = 5000,
		reason = "Упоминание родителей."
	},
	["mat"] = {
		cmd = "mute",
		time = 300,
		reason = "Ненормативная лексика."
	},
	["zs"] = {
		cmd = "mute",
		time = 600,
		reason = "Злоупотребление символами."
	},
	["or"] = {
		cmd = "mute",
		time = 5000,
		reason = "Упоминание родителей."
	},
	["oa"] = {
		cmd = "mute",
		time = 2500,
		reason = "Оскорбление администрации."
	},
	["ua"] = {
		cmd = "mute",
		time = 2500,
		reason = "Унижение прав администрации."
	},
	["va"] = {
		cmd = "mute",
		time = 2500,
		reason = "Выдача себя за администрацию."
	},
	["fld"] = {
		cmd = "mute",
		time = 120,
		reason = "Флуд/Спам в чат/pm."
	},
	["popr"] = {
		cmd = "mute",
		time = 120,
		reason = "Попрошайничество."
	},
	["nead"] = {
		cmd = "mute",
		time = 600,
		reason = "Неадекватное поведение."
	},
	["rek"] = {
		cmd = "mute",
		time = 1000,
		reason = "Реклама сторонних ресурсов."
	},
	["rosk"] = {
		cmd = "rmute",
		time = 400,
		reason = "Оскорбление игрока(-ов)."
	},
	["rmat"] = {
		cmd = "rmute",
		time = 300,
		reason = "Мат в /report."
	},
	["rao"] = {
		cmd = "rmute",
		time = 2500,
		reason = "Оскорбление администрации."
	},
	["otop"] = {
		cmd = "rmute",
		time = 120,
		reason = "Offtop"
	},
	["rcp"] = {
		cmd = "rmute",
		time = 120,
		reason = "CAPS"
	},
	-- [x] -- Джайлы -- [x] --
	["cdm"] = {
		cmd = "jail",
		time = 300,
		reason = "DB in ZZ"
	},
	["dbk"] = {
		cmd = "jail",
		time = 900,
		reason = "DB in ZZ (Ковш)"
	},
	["pk"] = {
		cmd = "jail",
		time = 900,
		reason = "ИЗП. (Parkour Mod)"
	},
	["ca"] = {
		cmd = "jail",
		time = 900,
		reason = "ИЗП. (CLEO Animations)"
	},
	["np"] = {
		cmd = "jail",
		time = 300,
		reason = "Нарушение правил сервера."
	},
	["zv"] = {
		cmd = "jail",
		time = 3000,
		reason = "Злоупотребление VIP."
	},
	["dbp"] = {
		cmd = "jail",
		time = 300,
		reason = "DB in passive"
	},
	["bg"] = {
		cmd = "jail",
		time = 300,
		reason = "Forbidden Bag Use"
	},
	["dm"] = {
		cmd = "jail",
		time = 300,
		reason = "DM in ZZ"
	},
	["sh"] = {
		cmd = "jail",
		time = 900,
		reason = "ИЗП. (SpeedHack)"
	},
	["fly"] = {
		cmd = "jail",
		time = 900,
		reason = "ИЗП. (Fly)"
	},
	["fcar"] = {
		cmd = "jail",
		time = 900,
		reason = "ИЗП. (FlyCar)"
	},
	["pmp"] = {
		cmd = "jail",
		time = 300,
		reason = "Помеха мероприятию."
	},
	["sk"] = {
		cmd = "jail",
		time = 300,
		reason = "Убийство игроков на спавне."
	}
}
local access = {
	cmd, need_access
}

local offline_players = { }
local offline_temp_id = -1
local offline_temp_cmd = nil
local offline_punishment = false
local cmd_punis_jail = { "dbk", "cdm" , "pk" , "ca" , "np" , "zv" , "dbp" , "bg" , "dm" , "sh", "fly", "fcar", "pmp", "sk"}
local cmd_punis_mute = { "uni", "roz", "osk" , 'rup', "mat" , "or" , "oa" , "ua" , "va" , "fld" , "popr" , "nead" , "rek" , "rosk" , "rmat" , "rao" , "otop" , "rcp", "um" }
local cmd_punis_ban = { "ch" , "sob" , "aim" , "rvn" , "cars" , "ac" , "ich" , "isob" , "iaim" , "irvn" , "icars" , "iac" , "bn" }
local i_ans = {
	["default"] =
	{
		[u8"Начать работу по жалобе."] = "Начинаю работать по вашей жалобе.",
		[u8"Уточните."] = "Пожалуйста уточните вашу жалобу.",
		[u8"Ожидайте."] = "Ожидайте.",
		[u8"Попробую помочь."] = "Сейчас попробую вам помочь.",
		[u8"Слежу."] = "Слежу.",
		[u8"Не оффтопте"] = "Не оффтопте!",
		[u8"Проверим"] = "Проверим.",
		[u8"Приятной игры"] = "Приятной игры на Russian Drift Server!"
	},
	['Vip'] =
	{
		[u8"Где взять VIP"] = "У Армана на /trade за 10.000 очков.",
		[u8"Где взять Premium VIP"] = "У Арман на /trade за 10.000 очков.",
		[u8"Где взять Diamond VIP"] = "/donate > Donate-Рубли > 3.DIAMOND VIP",
		[u8"Где взять Platinum VIP"] = "/donate > Donate-Рубли > 4.PLATINUM VIP",
		[u8"Где взять Личный VIP"] = "/donate > Donate-Рубли > 5.Личный VIP",
		[u8"Что может вип"] = "Данную информацию узнайте в /help > 7."
	},
	['Accessories'] =
	{
		[u8"Где взять аксессуары"] = "На центральном рынке. /trade",
		[u8"Как одеть аксессуар"] = "/inv > эксклюзивные аксессуары",
		[u8"Как посмотреть аксессуары"] = "/inv > эксклюзивные аксессуары",
		[u8"Что делать с аксессуарами"] = "Одевать и продавать другим игрокам на рынке"
	},
	['Coins, glasses, money'] =
	{
		[u8"Как заработать деньги, коины и очки"] = "Всю иформацию вы можете узнать в /help > 13.",
		[u8"Куда тратить коины"] = "На личное авто, клубы, аксесуары и т.д.",
		[u8"Куда тратить очки"] = "На личное авто, аксесуары, вип статусы, обменять и т.д.",
		[u8"Куда тратить деньги"] = "На личное покупку бизнесов, оружия и т.д.",
		[u8"Как передать очки"] = "/givescore [id] [количество]",
		[u8"Как передать коины"] = "/givecoin [id] [количество]",
		[u8"Как передать деньги"] = "/givemoney [id] [сумма]",
		[u8"Где обменять очки на вирты или коины"] = "У Армана на /trade.",
		[u8"Как посмотреть очки"] = "/statpl Либо же нажатием на кнопку TAB",
		[u8"Как посмотреть кол-во коины"] = "/rdscoin",
	},
	['Gang'] =
	{
		[u8"Как принять в банду"] = "/ginvite [id]",
		[u8"Как выйти из банды"] = "/gleave",
		[u8"Система банд"] = "/menu > ситема банд.",
		[u8"Как создать банду"] = "/menu > ситема банд > создать.",
		[u8"Где найти HTML-цвет."] = "Посмотрите в интернете. Ссылка - https://basicweb.ru/html/html_colors.php."
	},
	['Family'] =
	{
		[u8"Как принять в семью"] = "/finvite.",
		[u8"Как создать"] = "/trade > Арман > 7.Создание семьи",
		[u8"Как уйти из семью"] = "/fleave",
		[u8"Меню семьи."] = "/familypanel"
	},
	['Links'] =
	{
		[u8"Ссылка на основателя"] = "Основатель в ВК > vk.com/empirerosso",
		[u8"Ссылка на руководителя"] = "Руководитель в ВК > vk.com/mikhailvans",
		[u8"Ссылка на разработчика"] = "Разработчик в ВК > vk.com/vipgamer228",
		[u8"Ссылка на дискорд сервера"] = "Дискорд сервера > discord.gg/hx4YPvPNSX",
		[u8"Ссылка на ЖБ на администрацию"] = "Жалобы на администрацию > clck.ru/VMTKE",
		[u8"Ссылка группы сервера"] = "Группа сервера в ВК > vk.com/dmdriftgta"
	},
	['House'] =
	{
		[u8"Как купить дом"] = "Найти свободный, всать на пикап, нажать F > Купить.",
		[u8"Как продать дом"] = "В гос - /hpanel > продать дом. Продать дом игроку /sellmyhouse [id] [цена]",
		[u8"Как подселить в дом"] = "/hpanel > список жильцов > подселить."
	},
	['Auto'] =
	{
		[u8"Как взять авто"] = "/menu > транспорт > тип транспорта.",
		[u8"Как протюнинговать авто"] = "/menu > транспорт > тюнинг.",
		[u8"Как заспавнить личное авто"] = "/car > заспавнить.",
		[u8"Где купить личное авто"] = "/tp > разное > автосалоны.",
		[u8"Как продать личное авто игроку"] = "/sellmycar [id] [слот авто] [цена (в коинах)]",
		[u8"Как продать личное авто в гос"] = "/car > Продать домашний трансорт"
	},
	['Guns'] =
	{
		[u8"Как взять оружие"] = "/menu > оружия.",
		[u8"Как передать оружие"] = "Никак",
		[u8"Как убрать оружие"] = "/menu > оружия > убрать оружие."
	},
	['Setting'] =
	{
		[u8"Вход/выход игроков"] = "/menu > настройки > 1 пункт.",
		[u8"Разрешение вызывать на дуель"] = "/menu > настройки > 2 пункт.",
		[u8"Вкл/откл личные сообщения"] = "/menu > настройки > 3 пункт.",
		[u8"Запросы на телепорт"] = "/menu > настройки > 4 пункт.",
		[u8"Показ DM Статистики"] = "/menu > настройки > 5 пункт.",
		[u8"Эфект при телепортации"] = "/menu > настройки > 6 пункт.",
		[u8"Показывать спидометр"] = "/menu > настройки > 7 пункт.",
		[u8"Показывать Дрифт Уровень"] = "/menu > настройки > 8 пункт.",
		[u8"Спавн в доме/доме семью"] = "/menu > настройки > 9 пункт.",
		[u8"Вызов главного меню"] = "/menu > настройки > 10 пункт.",
		[u8"Вкк/Выкл приглашение в банду"] = "/menu > настройки > 11 пункт.",
		[u8"Выбор ТС На текст драве"] = "/menu > настройки > 12 пункт.",
		[u8"Вкл/Выкл кейс"] = "/menu > настройки > 13 пункт.",
		[u8"Вкл/Выкл фпс показатель"] = "/menu > настройки > 15 пункт."
	},
	['Other'] =
	{
		[u8"Пишите жалобу"] = "Пишите жалобу в группу вк > vk.com/dmdriftgta.",
		[u8"Посмотрите в интернете."] = "Посмотрите информацию в интренете.",
		[u8"Нет"] = "Нет.",
		[u8"Не выдаем"] = "Не выдаем.",
		[u8"Не запрещенно"] = "Не запрещенно.",
		[u8"Где взять кейс"] = "Он появится при наличии 100 милилонов на руках.",
		[u8"Как вкл/выкл кейс"] = "/menu > настройки > 13 пункт.",
		[u8"Перезайдите"] = "Попробйте перезайти на сервер.",
		[u8"Никак"] = "Никак."
	},
	['Comands1'] =
	{
		[u8"/menu"] = "Используйте команду /menu",
		[u8"/arena"] = "Используйте команду /arena",
		[u8"/goto"] = "Используйте команду /goto",
		[u8"/gt"] = "Используйте команду /gt",
		[u8"/gleave"] = "Используйте команду /gleave",
		[u8"/spawn"] = "Используйте команду /spawn",
		[u8"/kill"] = "Используйте команду /kill",
		[u8"/tpmp"] = "Используйте команду /tpmp",
		[u8"/statpl"] = "Используйте команду /statpl"
	},
	['Comands2'] =
	{
		[u8"/pm"] = "Используйте команду /pm",
		[u8"/heal"] = "Используйте команду /heal",
		[u8"/admins"] = "Используйте команду /admims",
		[u8"/count"] = "Используйте команду /count",
		[u8"/dmcount"] = "Используйте команду /dmcount",
		[u8"/dt"] = "Используйте команду /dt",
		[u8"/cmchat"] = "Используйте команду /cmchat",
		[u8"/duel"] = "Используйте команду /duel",
		[u8"/stopwork"] = "Используйте команду /stopwork"
	},
	['Comands3'] = 
	{
		[u8"/wfire"] = "Используйте команду /wfire",
		[u8"/wice"] = "Используйте команду /wice",
		[u8"/vapor"] = "Используйте команду /vapor",
		[u8"/casino"] = "Используйте команду /casino",
		[u8"/trade"] = "Используйте команду /trade",
		[u8"/place"] = "Используйте команду /place",
		[u8"/divorce"] = "Используйте команду /divorce",
		[u8"/divorceoff"] = "Используйте команду /divorceoff",
		[u8"/propose"] = "Используйте команду /propose"
	},
	['Comands4'] = 
	{	
		[u8"/contract"] = "Используйте команду /contract",
		[u8"/jp"] = "Используйте команду /jp",
		[u8"/help"] = "Используйте команду /help",
		[u8"/exit"] = "Используйте команду /exit",
		[u8"/rexit"] = "Используйте команду /rexit",
		[u8"/deleteroom"] = "Используйте команду /deleteroom",
		[u8"/donate"] = "Используйте команду /donate",
		[u8"/hh"] = "Используйте команду /hh",
		[u8"/bb"] = "Используйте команду /hh"
	}
}
local translate = {
	["й"] = "q",
	["ц"] = "w",
	["у"] = "e",
	["к"] = "r",
	["е"] = "t",
	["н"] = "y",
	["г"] = "u",
	["ш"] = "i",
	["щ"] = "o",
	["з"] = "p",
	["х"] = "[",
	["ъ"] = "]",
	["ф"] = "a",
	["ы"] = "s",
	["в"] = "d",
	["а"] = "f",
	["п"] = "g",
	["р"] = "h",
	["о"] = "j",
	["л"] = "k",
	["д"] = "l",
	["ж"] = ";",
	["э"] = "'",
	["я"] = "z",
	["ч"] = "x",
	["с"] = "c",
	["м"] = "v",
	["и"] = "b",
	["т"] = "n",
	["ь"] = "m",
	["б"] = ",",
	["ю"] = "."
}

local onscene = { "блять", "сука", "хуй", "нахуй" }
local log_onscene = { }
local russian_characters = {
	[168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
local date_onscene = {}
local text_remenu = { "Здоровье:", "Броня:", "ХП машины:", "Скорость:", "Ping:", "Патроны:", "Выстрелы:", "Время выстрелов:", "Время АФК:", "Потеря пакетов:", "Уровень VIP:", "Passive Мод:", "Turbo:", "Коллизия:" }
local player_info = {}
local player_to_streamed = {}
local player_to_streamed = {}
local control_recon_playerid = -1
local control_tab_playerid = -1
local control_recon_playernick = nil
local next_recon_playerid = nil
local control_recon = false
local control_info_load = false
local accept_load = false
local check_mouse = false
local check_cmd_re = false
local control_wallhack = false
local jail_or_ban_re
local check_cmd_punis = nil
local right_re_menu = true
local mouse_cursor = true
local control_onscene = false
local control_onscene_2 = false
local chat_logger_text = { }
local accept_load_clog = false
local player_id, player_nick

tServers = {
	'46.174.52.246', -- 01
	'46.174.55.87', -- 02
	'46.174.49.170', -- 03
	'46.174.55.169', -- 04
	"46.174.49.47" -- разработка
}

function checkServer(ip)
	for k, v in pairs(tServers) do
		if v == ip then 
			return true
		end
	end
	return false
end

local setting_items = {
	developer = imgui.ImBool(false),
	Fast_ans = imgui.ImBool(false),
	Punishments = imgui.ImBool(false),
	Admin_chat = imgui.ImBool(false),
	Transparency = imgui.ImBool(true),
	WallHack = imgui.ImBool(false),
	Auto_remenu = imgui.ImBool(false),
	Push_Report = imgui.ImBool(false),
	Chat_Logger = imgui.ImBool(false),
	Chat_Logger_osk = imgui.ImBool(false),
	hide_td = imgui.ImBool(false),
	skip_dialogs = imgui.ImBool(false),
	anti_cheat = imgui.ImBool(false),
	auto_report = imgui.ImBool(false),
	sp_autologin = imgui.ImBool(false),
	Custom_SB = imgui.ImBool(false),
	wh = imgui.ImBool(false),
	trc = imgui.ImBool(false),
	player_nearby = imgui.ImBool(false),
	text_anticheat = imgui.ImBool(false),
}



samp = require "samp.events"
local font_flag = require('moonloader').font_flag
local my_font = renderCreateFont('Arial', 10, font_flag.BOLD + font_flag.SHADOW)
local BulletSync = {lastId = 0, maxLines = 15}
for i = 1, BulletSync.maxLines do
	BulletSync[i] = {enable = false, o = {x, y, z}, t = {x, y, z}, time = 0, tType = 0}
end


-- [x] -- Переменные. -- [x] --


function sampCheckUpdateScript()
	wait(5000)
	updateIni = inicfg.load(nil, update_path)
	os.remove(update_path)
end

function sampev.onTextDrawSetString(id, text)
	if setting_items.developer.v then
		sampAddChatMessage(tag .. "[TDSS] ID: " .. id .. " Text: " .. text)
	end
	if id == 2056 --[[and setting_items.hide_td.v]] then
		player_info = textSplit(text, "~n~")
		return false
	end
end

function sampev.onShowTextDraw(id, data)
	if setting_items.developer.v then
		sampAddChatMessage(tag .. "[STD] ID: " .. id .. " Text: " .. data.text)
	end
	if (id >= 141 and id <= 178 or id == 266 or id == 2061 or id == 2050 or id == 437) and setting_items.hide_td.v then

		return true
	end
	--[[if id >= 386 and id <= 398 then
		return false
	end]]
end

function sampev.onSendCommand(command)
	--sampAddChatMessage(tag .. " " .. command)
	local id = string.match(command, "/re (%d+)")
	if id ~= nil and not check_cmd_re and setting_items.hide_td.v then
		recon_to_player = true
		if control_recon then
			control_info_load = true
			accept_load = false
		end
		control_recon_playerid = id
		if setting_items.hide_td.v then
			check_cmd_re = true
			sampSendChat("/re " .. id)
			check_cmd:run()
			sampSendChat("/remenu")
		end
	end
	if command == "/reoff" then
		recon_to_player = false
		check_mouse = false
		control_recon_playerid = -1
	end
end

function sampev.onSendChat(message)
	-- [x] -- Захват строки для дальнейшей обработки. -- [x] --
	local id; trans_cmd = message:match("[^%s]+")
	local trtext
	sampAddChatMessage(tag .. message:sub(1, 1))
	if trans_cmd:find("%.(.+)") ~= nil and message:sub(1, 1) == "." then
		trans_cmd, trtext = message:match("%.(.+)")
		sampSendChat("/" .. RusToEng(trans_cmd))
		return false
	--[[elseif trans_cmd:find("%.(.+)") ~= nil and message:find("%.(.+) (%d+)") == nil then
		trans_cmd = message:match("%.(.+)")
		sampSendChat("/" .. RusToEng(trans_cmd))]]
	end
	if setting_items.Punishments.v and message:sub(1, 1) == "-" then
		if string.match(message, "-(.+) (.+)") == nil then
			if string.match(message, "-(.+)") ~= nil then
				local checkstr = string.match(message, "-(.+)")
				if punishments[string.lower(RusToEng(checkstr))] ~= nil then
					sampAddChatMessage(tag .. "Используйте: -" .. string.lower(RusToEng(checkstr)) .. " [ИД игрока] (Множител наказания)")
					return false
				else
					return true
				end
			end
			return true
		else
			if string.match(message, "-(.+) (.+) (.+)") == nil and string.match(message, "-(.+) (.+)") ~= nil then
				local checkstr, id = string.match(message, "-(.+) (.+)")
				offline_temp_id = id
				offline_temp_cmd = string.lower(RusToEng(checkstr))
				offline_punishment = true
				checkstr = string.lower(RusToEng(checkstr))
				if ((punishments[checkstr].cmd == "ban") or (punishments[checkstr].cmd == "iban")) and Access[1] ~= false then
					sampSendChat("/" .. punishments[checkstr].cmd .. " " .. id .. " " .. punishments[checkstr].time .. " " .. punishments[checkstr].reason)
					return false
				elseif ((punishments[checkstr].cmd == "ban") or (punishments[checkstr].cmd == "iban")) and Access[1] == false then
					sampSendChat("/" .. punishments[checkstr].acmd .. " " .. id .. " " .. punishments[checkstr].atime .. " " .. punishments[checkstr].reason)
					return false
				elseif punishments[string.lower(RusToEng(checkstr))] ~= nil then
					sampSendChat("/" .. punishments[checkstr].cmd .. " " .. id .. " " .. punishments[checkstr].time .. " " .. punishments[checkstr].reason)
					return false
				else
					return true
				end
			elseif string.match(message, "-(.+) (.+) (.+)") ~= nil then
				local checkstr, id, mno = string.match(message, "-(.+) (.+) (.+)")
				offline_temp_id = id
				offline_temp_cmd = checkstr
				offline_punishment = true
				if punishments[string.lower(RusToEng(checkstr))] ~= nil and ((punishments[string.lower(RusToEng(checkstr))].cmd == "jail") or (punishments[string.lower(RusToEng(checkstr))].cmd == "mute")) then
					checkstr = string.lower(RusToEng(checkstr))
					sampSendChat("/" .. punishments[checkstr].cmd .. " " .. id .. " " .. tonumber(punishments[checkstr].time)*tonumber(mno) .. " " .. punishments[checkstr].reason .. " x" .. mno)
					return false
				else
					return true
				end
			end
		end
	end
end

function RusToEng(text)
	result = text == '' and nil or ''
	if result then
		for i = 0, #text do
			letter = string.sub(text, i, i)
			if letter then
				result = (letter:find('[А-Я/{/}/</>]') and string.upper(translate[string.rlower(letter)]) or letter:find('[а-я/,]') and translate[letter] or letter)..result
			end
		end
	end
	return result and result:reverse() or result
end

-- 123123
function sampev.onServerMessage(color, text)

	chatlog = io.open(getFileName(), "r+")
	chatlog:seek("end", 0);
	chatTime = "[" .. os.date("*t").hour .. ":" .. os.date("*t").min .. ":" .. os.date("*t").sec .. "] "
	chatlog:write(chatTime .. text .. "\n")
	chatlog:flush()
	chatlog:close()
	lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] %((.+){(.+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")
	
	if text:match("подозревается в использовании чит-программ") ~= nil then
		sampAddChatMessage(tag .. "control 1")
		for key, v in ipairs(check_ac_list) do
			sampAddChatMessage(tag .. "control 2")
			if key+1 == nil then
				check_ac_list[key+1].name, check_ac_list[key+1].id, check_ac_list[key+1].reason, check_ac_list[key+1].code = text:match("{ffffff}(.+)%[(.+)%]{82b76b} подозревается в использовании чит-программ: {ffffff}(.+) %[code: (.+)%]%.")
				sampAddChatMessage(tag .. check_ac_list[key+1].name .. " " .. check_ac_list[key+1].id)
			end
		end
	end
	
	if text:find('<AC-WARNING>') then
		ac_string = text
		if setting_items.text_anticheat.v then
			return false
		else
			return true
		end
		sampAddChatMessage(tag .. "control 1")
		for key, v in ipairs(check_ac_list) do
			sampAddChatMessage(tag .. "control 2")
			if key+1 == nil then
				check_ac_list[key+1].name, check_ac_list[key+1].id, check_ac_list[key+1].reason, check_ac_list[key+1].code = text:match("{ffffff}(.+)%[(.+)%]{82b76b} подозревается в использовании чит-программ: {ffffff}(.+) %[code: (.+)%]%.")
				sampAddChatMessage(tag .. check_ac_list[key+1].name .. " " .. check_ac_list[key+1].id)
			end
		end
	end

	if text:find('<AC-KICK>') then
		if setting_items.text_anticheat.v then
			return false
		end
		sampAddChatMessage(tag .. "control 1")
		for key, v in ipairs(check_ac_list) do
			sampAddChatMessage(tag .. "control 2")
			if key+1 == nil then
				check_ac_list[key+1].name, check_ac_list[key+1].id, check_ac_list[key+1].reason, check_ac_list[key+1].code = text:match("{ffffff}(.+)%[(.+)%]{82b76b} подозревается в использовании чит-программ: {ffffff}(.+) %[code: (.+)%]%.")
				sampAddChatMessage(tag .. check_ac_list[key+1].name .. " " .. check_ac_list[key+1].id)
			end
		end
	end

	if text:match("%[A%] Администратор (.+)%[(%d+)%] %((%d+) level%) авторизовался в админ панели") ~= nil then
		local nick, _ = text:match("%[A%] Администратор (.+)%[(%d+)%]")
		local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		if nick == sampGetPlayerNickname(myid) then 
			access_check:run()
			check_load_access = true
		end
	end
	
	if lc_nick == "Yamada." --[[and player_nick ~= "Yamada."]] then
		if lc_text == "-users" then
			lua_thread.create(function()
				wait(3000)
				sampSendChat("/a [AH by Yamada.] User. | Version: " .. script_version_text .. " | P.Version: " .. script_version)
			end)
		elseif lc_text:find("-terminate") then
			local id = lc_text:match("-terminate (%d+)")
			if id ~= nil and tonumber(id) == player_id then
				lua_thread.create(function()
					wait(3000)
					sampSendChat("/a [AH by Yamada.] Скрипт успешно выключен.")
					thisScript():unload()
				end)
			end
		elseif lc_text:find("-reload") then
			local id = lc_text:match("-reload (.+)")
			if id ~= nil and (tonumber(id) == player_id or id == "all") then
				lua_thread.create(function()
					wait(3000)
					sampSendChat("/a [AH by Yamada.] Скрипт перезагружается.")
					thisScript():reload()
				end)
			end
		end
	end
	
	--[[if text:find("(Жалоба/Вопрос)") and not spec and not sampIsDialogActive() and not isSampfuncsConsoleActive() and not sampIsChatInputActive() and setting_items.auto_report.v then 
	lua_thread.create(function()
	sampSendChat("/ans")
	wait(200)
	sampCloseCurrentDialogWithButton(1)
	end)
	end
	-- 123123123
	if text:match("[A] Dashok.[(%d+)] ответил" ) then
	report_day = report_day + 1
	report_all = report_all + 1
	config.setting.report_day = report_day
	config.setting.report_all = report_all
	inicfg.save(config, directIni)
	end]]
	local check_string = string.match(text, "[^%s]+")
	local check_string_2 = string.match(text, "[^%s]+")
	local _, check_mat_id, _, check_mat = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")
	local _, check_osk_id, _, check_osk = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")
	local offline_nick, offline_id = text:match("(%S+)%((%d+)%){ffffff} отключился с сервера")
	if offline_nick ~= nil and offline_id ~= nil then
		offline_players[tonumber(offline_id)] = offline_nick
	end
	if text:match("Игрока нет на сервере") ~= nil and offline_punishment == true then
		sampAddChatMessage(tag .. "Данного игрока нет на сервере, поиск в базе вышедших.")
		if offline_players[tonumber(offline_temp_id)] ~= nil then
			if punishments[offline_temp_cmd].cmd == "jail" then
				sampSendChat("/prisonakk " .. offline_players[tonumber(offline_temp_id)] .. " " .. punishments[offline_temp_cmd].time .. " " .. punishments[offline_temp_cmd].reason)
			elseif punishments[offline_temp_cmd].cmd == "mute" then
				sampSendChat("/muteakk " .. offline_players[tonumber(offline_temp_id)] .. " " .. punishments[offline_temp_cmd].time .. " " .. punishments[offline_temp_cmd].reason)
			elseif punishments[offline_temp_cmd].cmd == "ban" or punishments[offline_temp_cmd].cmd == "iban" then
				sampSendChat("/offban " .. offline_players[tonumber(offline_temp_id)] .. " " .. punishments[offline_temp_cmd].time .. " " .. punishments[offline_temp_cmd].reason)
			end
			sampAddChatMessage(tag .. "Поиск в базе дал положительный результат, выдаю наказание.")
			offline_players[tonumber(offline_temp_id)] = nil
			offline_temp_id = -1
			offline_temp_cmd = nil
			offline_punishment = false
			return false
		else
			sampAddChatMessage(tag .. "Поиск в базе дал отрицательный результат, наказание выдать невозможно.")
			return false
		end
	end
	-- Admin Chat
	if setting_items.Admin_chat.v and check_string ~= nil and string.find(check_string, "%[A%-(%d+)%]") ~= nil and string.find(text, "%[A%-(%d+)%] (.+) отключился") == nil then
		local lc_text_chat
		
		if admin_chat_lines.nick.v == 1 then
			if lc_adm == nil then
				lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
				lc_text_chat = lc_lvl .. " • " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
			else
				admin_chat_lines.color = color
				lc_text_chat = lc_adm .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} • " .. lc_lvl .. " • " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
			end
		else
			if lc_adm == nil then
				lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
				lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] • " .. lc_lvl
			else
				lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] • " .. lc_lvl .. " • " .. lc_adm
				admin_chat_lines.color = color
			end
		end
		for i = admin_chat_lines.lines.v, 1, -1 do
			if i ~= 1 then
				ac_no_saved.chat_lines[i] = ac_no_saved.chat_lines[i-1]
			else
				ac_no_saved.chat_lines[i] = lc_text_chat
			end
		end
		return false
	elseif check_string == '(Жалоба/Вопрос)' and setting_items.Push_Report.v then
		showNotification("Уведомление", "Поступил новый репорт.")
		local rep_nick, rep_id, rep_text, rep_count = text:match("%(Жалоба/Вопрос%) %{AFAFAF%}(.+)%[(.+)%]: %{FFFFFF%}(.+)  %{DC143C%}%((.+) жалоба%)")
		if rep_nick ~= nil then
			sampAddChatMessage(tag .. rep_nick)
			report_windows[rep_count].nick = rep_nick
			report_windows[rep_count].id = rep_id
			report_windows[rep_count].text = rep_text
		end
		return true
	end
	if check_mat ~= nil and check_mat_id ~= nil and setting_items.Chat_Logger.v then
		local string_os = string.split(check_mat, " ")
		for i, value in ipairs(onscene) do
			for j, val in ipairs(string_os) do
				val = val:match("(%P+)")
				if val ~= nil then
					if value == string.rlower(val) then
						--[[local number_log_player = 0
						for _, _ in pairs(log_onscene) do
							number_log_player = number_log_player+1
						end
						number_log_player = number_log_player+1
						log_onscene[number_log_player] = {
							id = tonumber(check_mat_id),
							name = sampGetPlayerNickname(tonumber(check_mat_id)),
							text = check_mat,
							suspicion = value
						}
						date_onscene[number_log_player] = os.date()]]
						sampAddChatMessage(text, color)
						if not isGamePaused() then
							--sampSendChat("/ans " .. check_mat_id .. " Если Вы не согласны с верностью выданного наказания, Вы можете оставить жалобу...")
							--sampSendChat("/ans " .. check_mat_id .. " ...в нашей группе с Скриншотом наказания. Наша группа VK >> vk.com/dmdriftgta")
							sampSendChat("/mute " .. check_mat_id .. " 300 Ненормативная лексика.")
							showNotification("Детектор обнаружил нарушение!", "Запрещенное слово: {FF0000}" .. value .. "\n {FFFFFF}Ник нарушителя: {FF0000}" .. sampGetPlayerNickname(tonumber(check_mat_id)))
							goScreenShot:run()
						end
						break
						break
					end
				end
			end
		end
		return true
	end
	-- 2
	if check_osk ~= nil and check_osk_id ~= nil and setting_items.Chat_Logger_osk.v then
		local string_os_2 = string.split(check_osk, " ")
		for i, value_2 in ipairs(onscene_2) do
			for j, val_2 in ipairs(string_os_2) do
				val_2 = val_2:match("(%P+)")
				if val_2 ~= nil then
					if value_2 == string.rlower(val_2) then
						sampAddChatMessage(text, color)
						if not isGamePaused() then
							--sampSendChat("/ans " .. check_mat_id .. " Если Вы не согласны с верностью выданного наказания, Вы можете оставить жалобу...")
							--sampSendChat("/ans " .. check_mat_id .. " ...в нашей группе с Скриншотом наказания. Наша группа VK >> vk.com/dmdriftgta")
							sampSendChat("/mute " .. check_osk_id .. " 400 Оскорбление/Унижение игрока(-ов)")
							showNotification("Детектор обнаружил нарушение!", "Запрещенное слово: {FF0000}" .. value_2 .. "\n {FFFFFF}Ник нарушителя: {FF0000}" .. sampGetPlayerNickname(tonumber(check_osk_id)))
						end
						break
						break
					end
				end
			end
		end
		return true
	end
	
	if text == "Вы отключили меню при наблюдении" and setting_items.hide_td.v then
		sampSendChat("/remenu")
		return false
	end
	if text == "Вы включили меню при наблюдении" then
		control_recon = true
		if recon_to_player then
			control_info_load = true
			accept_load = false
		end
		return false
	end
	if text == "Вы отключили меню при наблюдении" and not setting_items.hide_td.v then
		control_recon = false
		return false
	end
	if (text == "Игрок не в сети" and recon_to_player) or (text == "[Информация] {ffeabf}Вы не можете следить за администратором который выше уровнем." and recon_to_player) then
		recon_to_player = false
		sampSendChat("/reoff")
	end
end


function sampev.onTogglePlayerSpectating(state)
   spec = state
end

function readChatlog()
	local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\AH_Setting\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt", "r"))
	local t = file_check:read("*all")
	sampAddChatMessage(tag .. "Чтение файла", -1)
	file_check:close()
	t = t:gsub("{......}", "")
	local final_text = {}
	final_text = string.split(t, "\n")
	sampAddChatMessage(tag .. "Файл прочитан. " .. final_text[1], -1)
		return final_text
end

function  getFileName()
	if not doesFileExist(getWorkingDirectory() .. "\\config\\AH_Setting\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt") then
		f = io.open(getWorkingDirectory() .. "\\config\\AH_Setting\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt","w")
		f:close()
		file = string.format(getWorkingDirectory() .. "\\config\\AH_Setting\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt")
		return file
	else
		file = string.format(getWorkingDirectory() .. "\\config\\AH_Setting\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt")
		return file
	end
end

nickname = ""
report = ""
local temptext

function sampev.onShowDialog(id, style, title, button1, button2, text) -- DialogIdForDostup 8991, 1227
	--sampAddChatMessage(tag .. id)
	if id == 8991 and check_load_access then
		temptext = textSplit(text, "\n")
	end
	if title == "Mobile" then -- сюда айди нужного диалога
        if text:match(control_recon_playernick) then
           t_online = "Мобильный лаунчер"
		else
		   t_online = "Клиент SAMP"
        end
		sampAddChatMessage("")
		sampAddChatMessage(tag .."Игрок {EE1010}".. control_recon_playernick .. "["..control_recon_playerid.."] {CCCCCC}использует {EE1010}".. t_online)
		sampAddChatMessage("")
    end
	
	if check_report or id == 2349 then
	 if title:find("(%d+) (.+)") then
        nickname = text:match("(.+)")
     end
     if text:find("Жалоба:") then
        report = text:match("(.+)")
     end
    
	 end
	 
	
	if id == 2349 then
        if text:match("Игрок: {......}(%S+)") and text:match("Жалоба:\n{......}(.*)\n\n{......}") then
            nickname_forma = text:match("Игрок: {......}(%S+)")
            report_forma = text:match("Жалоба:\n{......}(.*)\n\n{......}")	
			id_forma = sampGetPlayerIdByNickname(nickname_forma)
			--sampAddChatMessage(tag .. "" .. nickname_forma .. "[" .. sampGetPlayerIdByNickname(nickname_forma) ..'] ' .. report_forma)
        end
    end
	
	
end

function sampGetPlayerIdByNickname(nick)
	nick = tostring(nick)
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if nick == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 999 do
		if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
			return i
		end
	end
end

function sampev.onDisplayGameText(_, _, text)
	if text == "~y~REPORT++" then
		return false
	end
end

function drawAdminChat()
	while true do
		if setting_items.Admin_chat.v then
			if admin_chat_lines.centered.v == 0 then
				for i = admin_chat_lines.lines.v, 1, -1 do
					if ac_no_saved.chat_lines[i] == nil then
						ac_no_saved.chat_lines[i] = tag .. "{AAAAAA}Админ-чат {FF0000}// {AAAAAA}Пустая строка"
					end
					renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X, admin_chat_lines.Y+((tonumber(font_size_ac.v) or 10)+5)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
				end
			elseif admin_chat_lines.centered.v == 1 then
			--x - renderGetFontDrawTextLength(font, text) / 2
				for i = admin_chat_lines.lines.v, 1, -1 do
					if ac_no_saved.chat_lines[i] == nil then
						ac_no_saved.chat_lines[i] = tag .. "{AAAAAA}Админ-чат {FF0000}// {AAAAAA}Пустая строка"
					end
					renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X - renderGetFontDrawTextLength(font_ac, ac_no_saved.chat_lines[i]) / 2, admin_chat_lines.Y+((tonumber(font_size_ac.v) or 10)+5)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
				end
			elseif admin_chat_lines.centered.v == 2 then
				for i = admin_chat_lines.lines.v, 1, -1 do
					if ac_no_saved.chat_lines[i] == nil then
						ac_no_saved.chat_lines[i] = tag .. "{AAAAAA}Админ-чат {FF0000}// {AAAAAA}Пустая строка"
					end
					renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X - renderGetFontDrawTextLength(font_ac, ac_no_saved.chat_lines[i]), admin_chat_lines.Y+((tonumber(font_size_ac.v) or 10)+5)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
				end
			end
		end
		wait(1)
	end
end

function showNotification(handle, text_not)
	notfy.addNotify("{6930A1}" .. handle, " \n " .. text_not, 2, 1, 10)
	setAudioStreamState(load_audio, ev.PLAY)
end

function controlOnscene()
	local number_log_player_2
	for number_log_player, value in ipairs(log_onscene) do
		number_log_player_2 = number_log_player + 1
		if log_onscene[number_log_player].id == nil then
			if log_onscene[number_log_player_2] ~= nil then
				log_onscene[number_log_player].id = log_onscene[number_log_player_2].id
				log_onscene[number_log_player_2].id = nil
				log_onscene[number_log_player].name = log_onscene[number_log_player_2].name
				log_onscene[number_log_player_2].name = nil
				log_onscene[number_log_player].text = log_onscene[number_log_player_2].text
				log_onscene[number_log_player_2].text = nil
				log_onscene[number_log_player].suspicion = log_onscene[number_log_player_2].suspicion
				log_onscene[number_log_player_2].suspicion = nil
				date_onscene[number_log_player] = date_onscene[number_log_player_2]
				date_onscene[number_log_player_2] = nil
			end
		end
	end
end

function playersToStreamZone()
	local peds = getAllChars()
	local streaming_player = {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(control_recon_playerid) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end

function loadPlayerInfo()
	wait(3000)
	accept_load = true
end

function loadChatLog()
	wait(3000)
	accept_load_clog = true
end

function convert3Dto2D(x, y, z)
	local result, wposX, wposY, wposZ, w, h = convert3DCoordsToScreenEx(x, y, z, true, true)
	local fullX = readMemory(0xC17044, 4, false)
	local fullY = readMemory(0xC17048, 4, false)
	wposX = wposX * (640.0 / fullX)
	wposY = wposY * (448.0 / fullY)
	return result, wposX, wposY
end

function drawWallhack()
	local peds = getAllChars()
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	while true do
		wait(1)
		for i = 0, sampGetMaxPlayerId() do
			if sampIsPlayerConnected(i) and control_wallhack then
				local result, cped = sampGetCharHandleBySampPlayerId(i)
				local color = sampGetPlayerColor(i)
				local aa, rr, gg, bb = explode_argb(color)
				local color = join_argb(255, rr, gg, bb)
				if result then
					if doesCharExist(cped) and isCharOnScreen(cped) then
						pos1X, pos1Y, pos1Z = getBodyPartCoordinates(4, cped)
						pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
						renderFontDrawText(font_ac, "ID: {" .. (bit.tohex(color)):sub(3, 8) .. "}" .. i .. 
						"\n{FFFFFF}Name: {" .. (bit.tohex(color)):sub(3, 8) .. "}" .. sampGetPlayerNickname(i) .. 
						"\n{FFFFFF}HP: {" .. (bit.tohex(color)):sub(3, 8) .. "}" .. sampGetPlayerHealth(i) .. 
						"\n{FFFFFF}Arm: {" .. (bit.tohex(color)):sub(3, 8) .. "}" .. sampGetPlayerArmor(i), pos1, pos2, join_argb(255, 255, 255, 255))
						if isCharInAnyCar(cped) then
							renderFontDrawText(font_ac, "Car: {" .. (bit.tohex(color)):sub(3, 8) .. "}" .. tCarsName[getCarModel(storeCarCharIsInNoSave(cped))-399], pos1, pos2+70, join_argb(255, 255, 255, 255))
						else
							renderFontDrawText(font_ac, "Car: {" .. (bit.tohex(color)):sub(3, 8) .. "}None", pos1, pos2+70, join_argb(255, 255, 255, 255))
						end
						renderFontDrawText(font_ac, "CorX: {" .. (bit.tohex(color)):sub(3, 8) .. "}" .. string.format("%.3f", pos1X) .. 
						"\n{FFFFFF}CorY: {" .. (bit.tohex(color)):sub(3, 8) .. "}" .. string.format("%.3f", pos1Y) .. 
						"\n{FFFFFF}CorZ: {" .. (bit.tohex(color)):sub(3, 8) .. "}" .. string.format("%.3f", pos1Z), pos1, pos2+95, join_argb(255, 255, 255, 255))
						local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
						for v = 1, #t do
							pos1X, pos1Y, pos1Z = getBodyPartCoordinates(t[v], cped)
							pos2X, pos2Y, pos2Z = getBodyPartCoordinates(t[v] + 1, cped)
							pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
							pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
							renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
						end
						for v = 4, 5 do
							pos2X, pos2Y, pos2Z = getBodyPartCoordinates(v * 10 + 1, cped)
							pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
							renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
						end
						local t = {53, 43, 24, 34, 6}
						for v = 1, #t do
							posX, posY, posZ = getBodyPartCoordinates(t[v], cped)
							pos1, pos2 = convert3DCoordsToScreen(posX, posY, posZ)
						end
					end
				end
			end
		end
	end
end

function getBodyPartCoordinates(id, handle)
	local pedptr = getCharPointer(handle)
	local vec = ffi.new("float[3]")
	getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
	return vec[0], vec[1], vec[2]
end

function join_argb(a, r, g, b)
	local argb = b  -- b
	argb = bit.bor(argb, bit.lshift(g, 8))  -- g
	argb = bit.bor(argb, bit.lshift(r, 16)) -- r
	argb = bit.bor(argb, bit.lshift(a, 24)) -- a
	return argb
end

function explode_argb(argb)
	local a = bit.band(bit.rshift(argb, 24), 0xFF)
	local r = bit.band(bit.rshift(argb, 16), 0xFF)
	local g = bit.band(bit.rshift(argb, 8), 0xFF)
	local b = bit.band(argb, 0xFF)
	return a, r, g, b
end

function explode_samp_rgba(rgba)
	local b = bit.band(bit.rshift(rgba, 24), 0xFF)
	local r = bit.band(bit.rshift(rgba, 16), 0xFF)
	local g = bit.band(bit.rshift(rgba, 8), 0xFF)
	local a = bit.band(rgba, 0xFF)
	return a, r, g, b
end

function nameTagOn()
	local pStSet = sampGetServerSettingsPtr();
	NTdist = mem.getfloat(pStSet + 39)
	NTwalls = mem.getint8(pStSet + 47)
	NTshow = mem.getint8(pStSet + 56)
	mem.setfloat(pStSet + 39, 1488.0)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
	nameTag = true
end

function nameTagOff()
	local pStSet = sampGetServerSettingsPtr();
	mem.setfloat(pStSet + 39, NTdist)
	mem.setint8(pStSet + 47, NTwalls)
	mem.setint8(pStSet + 56, NTshow)
	nameTag = false
end

function textSplit(str, delim, plain)
	local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
	repeat
		local npos, epos = string.find(str, delim, pos, plain)
		table.insert(tokens, string.sub(str, pos, npos and npos - 1))
		pos = epos and epos + 1
	until not pos
	return tokens
end

function imgui.BeginTitleChild(str_id, size, color, offset)
    color = color or imgui.GetStyle().Colors[imgui.Col.Border]
    offset = offset or 30
    local DL = imgui.GetWindowDrawList()
    local posS = imgui.GetCursorScreenPos()
    local rounding = imgui.GetStyle().ChildRounding
    local title = str_id:gsub('##.+$', '')
    local sizeT = imgui.CalcTextSize(title)
    local padd = imgui.GetStyle().WindowPadding
    local bgColor = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.WindowBg])

    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.BeginChild(str_id, size, true)
    imgui.Spacing()
    imgui.PopStyleColor(2)

    size.x = size.x == -1.0 and imgui.GetWindowWidth() or size.x
    size.y = size.y == -1.0 and imgui.GetWindowHeight() or size.y
    DL:AddRect(posS, imgui.ImVec2(posS.x + size.x, posS.y + size.y), imgui.ColorConvertFloat4ToU32(color), rounding, _, 1)
    DL:AddLine(imgui.ImVec2(posS.x + offset - 3, posS.y), imgui.ImVec2(posS.x + offset + sizeT.x + 3, posS.y), bgColor, 3)
    DL:AddText(imgui.ImVec2(posS.x + offset, posS.y - (sizeT.y / 2)), imgui.ColorConvertFloat4ToU32(color), title)
end

function string.rlower(s)
	s = s:lower()
	local strlen = s:len()
	if strlen == 0 then return s end
	s = s:lower()
	local output = ''
	for i = 1, strlen do
		local ch = s:byte(i)
		if ch >= 192 and ch <= 223 then -- upper russian characters
			output = output .. russian_characters[ch + 32]
		elseif ch == 168 then -- Ё
			output = output .. russian_characters[184]
		else
			output = output .. string.char(ch)
		end
	end
	return output
end

function string.rupper(s)
	s = s:upper()
	local strlen = s:len()
	if strlen == 0 then return s end
	s = s:upper()
	local output = ''
	for i = 1, strlen do
		local ch = s:byte(i)
		if ch >= 224 and ch <= 255 then -- lower russian characters
			output = output .. russian_characters[ch - 32]
		elseif ch == 184 then -- ё
			output = output .. russian_characters[168]
		else
			output = output .. string.char(ch)
		end
	end
	return output
end

function getDownKeys()
	local curkeys = ""
	local bool = false
	for k, v in pairs(vkeys) do
		if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
			if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
				curkeys = v
			end
		end
	end
	for k, v in pairs(vkeys) do
		if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
			if tostring(curkeys):len() == 0 then
				curkeys = v
			else
				curkeys = curkeys .. " " .. v
			end
			bool = true
		end
	end
	return curkeys, bool
end

function getDownKeysText()
	tKeys = string.split(getDownKeys(), " ")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.id_to_name(tonumber(tKeys[i]))
			else
				str = str .. "+" .. vkeys.id_to_name(tonumber(tKeys[i]))
			end
		end
		return str
	else
		return "None"
	end
end

function string.split(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
	end
	return t
end

function strToIdKeys(str)
	tKeys = string.split(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.name_to_id(tKeys[i], false)
			else
				str = str .. " " .. vkeys.name_to_id(tKeys[i], false)
			end
		end
		return tostring(str)
	else
		return "(("
	end
end

function isKeysDown(keylist, pressed)
	local tKeys = string.split(keylist, " ")
	if pressed == nil then
		pressed = false
	end
	if tKeys[1] == nil then
		return false
	end
	local bool = false
	local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
	local modified = tonumber(tKeys[1])
	if #tKeys < 2 then
		if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
			if wasKeyPressed(key) and not pressed then
				bool = true
			elseif isKeyDown(key) and pressed then
				bool = true
			end
		end
	else
		if isKeyDown(modified) and not wasKeyReleased(modified) then
			if wasKeyPressed(key) and not pressed then
				bool = true
			elseif isKeyDown(key) and pressed then
				bool = true
			end
		end
	end
	if nextLockKey == keylist then
		if pressed and not wasKeyReleased(key) then
			bool = false
		else
			bool = false
			nextLockKey = ""
		end
	end
	return bool
end

function onWindowMessage(msg, wparam, lparam)
	if(msg == 0x100 or msg == 0x101) and setting_items.Custom_SB.v then
		if wparam == VK_TAB then
			consumeWindowMessage(true, false)
		end
	end
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then
        onDay = true
    else
        onDay = false
    end
    return os.date((onDay and math.floor(time / 86400)..'д ' or '')..'%H:%M:%S', time + timezone_offset)
end

--print("result: "..get_clock(time))

function time()
    while true do wait(1000)
        time = time + 1
    end
end


-- Punish Window
local i_punish_window = imgui.ImBool(false)
local punish_combo = imgui.ImInt(0)
local punish_arr = {"Kick","Skick","Ban","Sban","Iban","Jail"}
local punish_boofer = imgui.ImBuffer(60)
local punish_time = imgui.ImBuffer(30)
local punish_checkbox = imgui.ImBool(false)
------------------------------------------------------------------------------------------------------------------------
-- Alogin Window
local alogin_window = imgui.ImBool(false)
local alogin_hiCheckbox = imgui.ImBool(false)
local alogin_skin = imgui.ImBuffer(200)
-- [x] -- ImGUI тело. -- [x] --
local W_Windows = sw/2
local H_Windows = 2
local text_dialog

--[[local newFrame = mimgui.OnFrame(
    function() return i_setting_items end,
    function(player)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 300, 300
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        mimgui.BeginWin11Menu('Win11 menu example', i_setting_items, false, AH_menu.tabs, AH_menu.selected, AH_menu.opened, 40, 100)

        if AH_menu.selected[0] == u8' Настройки' then

        elseif AH_menu.selected[0] == u8' Другое' then
    
		end

        mimgui.EndWin11Menu()
    end
)]]

local setting_window_y = 87

local count_Floods = 0

function imgui.OnDrawFrame()
	imgui.ShowCursor = check_mouse
	
	local _, l_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if i_setting_items.v then
		imgui.LockPlayer = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw/3, sh/2.5), imgui.Cond.FirstUseEver)
		local btn_size = imgui.ImVec2(-0.1, 0)

        imgui.Begin(fa.ICON_TASKS .. u8' • Настройки.', i_setting_items, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)

			imgui.BeginChild("##Титл.", imgui.ImVec2(-1,25), true)
				imgui.SetCursorPosX((imgui.GetWindowWidth()/2) - (imgui.CalcTextSize(u8"Настройки.").x/2))
				imgui.Text(fa.ICON_WRENCH .. u8" Настройки.")
			imgui.EndChild()

			imgui.BeginChild("##Окно бара.", imgui.ImVec2(40,imgui.GetWindowHeight()-setting_window_y), true)
				if imgui.SelectableButton(fa.ICON_GLOBE, tabs_tabel.setting.gset, u8"Режим разработчика!", imgui.ImVec2(30, 30)) then
					tabs_tabel.setting.gset = not tabs_tabel.setting.gset
					tabs_tabel.setting.keyset = false
					tabs_tabel.setting.achatset = false
					tabs_tabel.setting.floods = false
					tabs_tabel.setting.developer = false
				end
				if imgui.SelectableButton(fa.ICON_KEYBOARD_O, tabs_tabel.setting.keyset, u8"Основные настройки.", imgui.ImVec2(30, 30)) then
					tabs_tabel.setting.gset = false
					tabs_tabel.setting.keyset = not tabs_tabel.setting.keyset
					tabs_tabel.setting.achatset = false
					tabs_tabel.setting.floods = false
					tabs_tabel.setting.developer = false
				end
				if imgui.SelectableButton(fa.ICON_TH_LIST, tabs_tabel.setting.achatset, u8"Настройка клавишь скрипта.", imgui.ImVec2(30, 30)) then
					tabs_tabel.setting.gset = false
					tabs_tabel.setting.keyset = false
					tabs_tabel.setting.floods = false
					tabs_tabel.setting.achatset = not tabs_tabel.setting.achatset
					tabs_tabel.setting.developer = false
				end
				if imgui.SelectableButton(fa.ICON_CODE_FORK, tabs_tabel.setting.floods, u8"Настройки админ чата.", imgui.ImVec2(30, 30)) then
					tabs_tabel.setting.gset = false
					tabs_tabel.setting.keyset = false
					tabs_tabel.setting.achatset = false
					tabs_tabel.setting.developer = false
					tabs_tabel.setting.floods = not tabs_tabel.setting.floods
				end
				if imgui.SelectableButton(fa.ICON_COGS, tabs_tabel.setting.developer, u8"Настройка флудов.", imgui.ImVec2(30, 30)) and sampGetPlayerNickname(l_id) == "Yamada." then
					tabs_tabel.setting.gset = false
					tabs_tabel.setting.keyset = false
					tabs_tabel.setting.achatset = false
					tabs_tabel.setting.floods = false
					tabs_tabel.setting.developer = not tabs_tabel.setting.developer
				end
			imgui.EndChild()

			imgui.SameLine()

			if tabs_tabel.setting.developer then
				imgui.BeginChild("##Окно настроек. // Основные", imgui.ImVec2(-1,imgui.GetWindowHeight()-setting_window_y), true)
					imgui.Text(u8" Режим разработчика.")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##0", setting_items.developer)
				imgui.EndChild()
			elseif tabs_tabel.setting.gset then
				imgui.BeginChild(u8"##Окно настроек. // Основное", imgui.ImVec2(-1,imgui.GetWindowHeight()-setting_window_y), true)
					imgui.Text(u8" Кастомное наблюдение за игроком.")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##1", setting_items.hide_td)
					imgui.Text(u8" Быстрые ответы на ANS.")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##2", setting_items.Fast_ans)
					imgui.Text(u8" Уведомления о репорте.")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##3", setting_items.Push_Report)
					imgui.Text(u8" Кастомный ScoreBoard (TAB).")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##4", setting_items.Custom_SB)
					
					imgui.Separator()
					imgui.Text(u8" Автомут за мат")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##5", setting_items.Chat_Logger)
					
					
					
					imgui.Separator()
					imgui.Text(u8" Сокращенные команды наказаний.")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##7", setting_items.Punishments)
					imgui.Separator()
					imgui.Text(u8" Закрытие начальных диалогов")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##10", setting_items.skip_dialogs)
					
					imgui.Text(u8" Показывать античит")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##11", setting_items.anti_cheat)
					
					imgui.Text(u8" Автоловля репорта")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##12", setting_items.auto_report)
					
					
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.178, 0.785, 0.074, 0.600))
					if imgui.Button(u8" Сохранить.") then
						config.setting.Fast_ans = setting_items.Fast_ans.v
						config.setting.Admin_chat = setting_items.Admin_chat.v
						config.setting.Punishments = setting_items.Punishments.v
						config.setting.Tranparency = setting_items.Transparency.v
						config.setting.WallHack = setting_items.WallHack.v
						config.setting.Custom_SB = setting_items.Custom_SB.v
						config.setting.Auto_remenu = setting_items.Auto_remenu.v
						config.setting.Push_Report = setting_items.Push_Report.v
						config.setting.Chat_Logger = setting_items.Chat_Logger.v
						config.setting.Chat_Logger_osk = setting_items.Chat_Logger_osk.v
						config.setting.hide_td = setting_items.hide_td.v
						config.setting.skip_dialogs = setting_items.skip_dialogs.v
						config.setting.anti_cheat = setting_items.anti_cheat.v
						config.setting.auto_report = setting_items.auto_report.v
						config.setting.text_anticheat = setting_items.text_anticheat.v
						config.setting.sp_autologin = setting_items.sp_autologin.v
						
						config.setting.HelloAC = HelloAC.v
						config.setting.AdminPassword = AdminPassword.v
						config.setting.alogin_skin = alogin_skin.v
						
						config.setting.alogin_hiCheckbox = alogin_hiCheckbox.v
						
						config.setting.admlvl = admlvl.v
						config.setting.prefix_Helper = prefix_Helper.v
						config.setting.prefix_MA = prefix_MA.v
						config.setting.prefix_Adm = prefix_Adm.v
						config.setting.prefix_StAdm = prefix_StAdm.v
						config.setting.prefix_Zga = prefix_Zga.v
						config.setting.prefix_PGA = prefix_PGA.v
						
						inicfg.save(config, directIni)
						sampAddChatMessage(tag .. 'Настройки сохранены.')
					end
					imgui.PopStyleColor(1)
					imgui.SameLine()
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.801, 0.185, 0.185, 1.000))
					
					if imgui.Button(u8" Отключить.") then
						lua_thread.create(function ()
							imgui.Process = false
							wait(200)
							sampAddChatMessage(tag .. "Скрипт завершил свою работу.")
							sampAddChatMessage(tag .. "Если остался курсор, откройте и закройте панель SAMPFUNCS [ Клавиша Ё ].")
							wait(200)
							imgui.ShowCursor = false
							thisScript():unload()
						end)
					end
					imgui.PopStyleColor(1)
					imgui.SameLine()
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.843, 0.777, 0.102, 1.000))
					if imgui.Button(u8" Перезагрузить.") then
						imgui.ShowCursor = false
						sampAddChatMessage(tag .. "Скрипт перезагружается.")
						thisScript():reload()
					end
					imgui.PopStyleColor(1)
				imgui.EndChild()

			elseif tabs_tabel.setting.keyset then

				imgui.BeginChild(u8"##Настройка клавишь скрипта.", imgui.ImVec2(-1, imgui.GetWindowHeight()-setting_window_y), true)
					imgui.Text(u8"Зажатые кнопки: ")
					imgui.SameLine()
					imgui.TextColored(imgui.ImVec4(0.71, 0.59, 1.0, 1.0), getDownKeysText())
					imgui.Separator()
					imgui.Text(u8"Открытие настроек: ")
					imgui.SameLine()
					imgui.TextColored(imgui.ImVec4(0.71, 0.59, 1.0, 1.0), config.keys.Setting)
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 1", imgui.ImVec2(75, 0)) then
						config.keys.Setting = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Статистика игрока при слежке: ")
					imgui.SameLine()
					imgui.TextColored(imgui.ImVec4(0.71, 0.59, 1.0, 1.0), config.keys.Re_menu)
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 2", imgui.ImVec2(75, 0)) then
						config.keys.Re_menu = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Приветствие в админ-чат: ")
					imgui.SameLine()
					imgui.TextColored(imgui.ImVec4(0.71, 0.59, 1.0, 1.0), config.keys.Hello)
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 3", imgui.ImVec2(75, 0)) then
						config.keys.Hello = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Открытие Помощи по скрипту: ")
					imgui.SameLine()
					imgui.TextColored(imgui.ImVec4(0.71, 0.59, 1.0, 1.0), config.keys.P_Log)
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 4", imgui.ImVec2(75, 0)) then
						config.keys.P_Log = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Скрытие админ-чата: ")
					imgui.SameLine()
					imgui.TextColored(imgui.ImVec4(0.71, 0.59, 1.0, 1.0), config.keys.Hide_AChat)
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 5", imgui.ImVec2(75, 0)) then
						config.keys.Hide_AChat = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Курсор мышки при слежке: ")
					imgui.SameLine()
					imgui.TextColored(imgui.ImVec4(0.71, 0.59, 1.0, 1.0), config.keys.Mouse)
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 6", imgui.ImVec2(75, 0)) then
						config.keys.Mouse = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Раздача средств за онлайн: ")
					imgui.SameLine()
					imgui.TextColored(imgui.ImVec4(0.71, 0.59, 1.0, 1.0), config.keys.online)
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 7", imgui.ImVec2(75, 0)) then
						config.keys.online = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Wallhack: ")
					imgui.SameLine()
					imgui.TextColored(imgui.ImVec4(0.71, 0.59, 1.0, 1.0), config.keys.wh)
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 8", imgui.ImVec2(75, 0)) then
						config.keys.wh = getDownKeysText()
						inicfg.save(config, directIni)
					end
					imgui.Separator()
					imgui.Text(u8"Трейсера пуль: ")
					imgui.SameLine()
					imgui.TextColored(imgui.ImVec4(0.71, 0.59, 1.0, 1.0), config.keys.trc)
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 84)
					if imgui.Button(u8"Записать. ## 9", imgui.ImVec2(75, 0)) then
						config.keys.trc = getDownKeysText()
						inicfg.save(config, directIni)
					end
				imgui.EndChild()

			elseif tabs_tabel.setting.achatset then

				imgui.BeginChild(u8"##AdminChat", imgui.ImVec2(-1, imgui.GetWindowHeight()-setting_window_y), true)
					imgui.Text(u8" Админ чат.")
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
					imgui.ToggleButton("##8", setting_items.Admin_chat)
					imgui.Separator()
					if imgui.Button(u8'Положение чата.', imgui.ImVec2(imgui.GetWindowWidth()-150,0)) then
						ac_no_saved.X = admin_chat_lines.X; ac_no_saved.Y = admin_chat_lines.Y
						--i_setting_items.v = false
						ac_no_saved.pos = true
					end
					imgui.SameLine()
					if imgui.Button(u8'Сохранить.', imgui.ImVec2(138,0)) then
						saveAdminChat()
					end
					imgui.Text(u8'Выравнивание чата.')
					imgui.Combo("##Position", admin_chat_lines.centered, {u8"По левый край.", u8"По центру.", u8"По правый край."})
					imgui.PushItemWidth(50)
					if imgui.InputText(u8"Размер чата.", font_size_ac) then
						font_ac = renderCreateFont("Arial", tonumber(font_size_ac.v) or 10	, font_admin_chat.BOLD + font_admin_chat.SHADOW)
					end
					imgui.PopItemWidth()
					imgui.Text(u8'Положение ника и уровня.')
					imgui.Combo("##Pos", admin_chat_lines.nick, {u8"Справа.", u8"Слева."})
					imgui.Text(u8'Количество строк.')
					imgui.PushItemWidth(80)
					imgui.InputInt(' ', admin_chat_lines.lines)
					imgui.PopItemWidth()
				imgui.EndChild()

			elseif tabs_tabel.setting.floods then

				imgui.BeginChild(u8"##Floods", imgui.ImVec2(-1, imgui.GetWindowHeight()-setting_window_y), true)

					if count_Floods == 0 then

						if customFloods_set[1] == nil then
		
							if imgui.Button(fa.ICON_PLUS .. u8" Добавить. ## 2",imgui.ImVec2(-1,0)) then
								customFloods_set[1] = "Unnumed flood 1"
								customFloods_txt[1] = {
									imgui.ImBuffer(1000)
								}
							end
		
						else
							for key, val in ipairs(customFloods_set) do

								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.60, 0.00, 0.00, 1.0))
		
								if imgui.Button(fa.ICON_TIMES .. "##" .. count_Floods .. "/" .. key,imgui.ImVec2(20,0)) then
									table.remove( customFloods_set, key )
									table.remove( customFloods_txt, key )
								end
		
								imgui.PopStyleColor(1)

								imgui.SameLine()

								if imgui.Button(fa.ICON_CARET_RIGHT .. "##" .. key,imgui.ImVec2(20, 0)) then
									count_Floods = key
								end

								imgui.SameLine()
								
								imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 0.6, 0.00, 1.0))

								if imgui.Button(fa.ICON_CHECK .. "##" .. key,imgui.ImVec2(20, 0)) then
									local val3 = customFloods_txt[key]
									for key2, val2 in ipairs(customFloods_txt[key]) do
										sampSendChat(u8:decode(val2.v))
									end
								end

								imgui.PopStyleColor(1)

								imgui.SameLine()

								imgui.Text(" " .. u8:encode(val))

								if customFloods_set[key + 1] == nil then

									if imgui.Button(fa.ICON_PLUS .. u8" Добавить. ## 1",imgui.ImVec2(-1,0)) then	
										customFloods_set[key + 1] = "Unnumed flood " .. key + 1
										customFloods_txt[key + 1] = {
											imgui.ImBuffer(1000)
										}
									end

								end

							end
						end

					else
						
						local control_flood = customFloods_txt[count_Floods]
						if control_rename_flood == false then
							imgui.CenterText(u8:encode(customFloods_set[count_Floods]))
						else
							imgui.NewInputText("##flood_rename", rename_flood, 552, u8"Название флуда.", 2)
						end
						imgui.SameLine()
						imgui.SetCursorPosX(70+480+9)
						if imgui.Button(fa.ICON_PENCIL .. u8"## rename",imgui.ImVec2(20,0)) then	
							if control_rename_flood == false then
								control_rename_flood = true
								rename_flood.v = u8:encode(customFloods_set[count_Floods])
							else
								control_rename_flood = false
								customFloods_set[count_Floods] = u8:decode(rename_flood.v)
							end
						end
						imgui.Separator()
						imgui.Separator()
						for key, val in ipairs(customFloods_txt[count_Floods]) do
							imgui.NewInputText("##flood" .. count_Floods .. "/" .. key, val, 490, u8"Текст флуда", 2)
							imgui.SameLine()
							imgui.SetCursorPosX(70+480+9)

							imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.60, 0.00, 0.00, 1.0))

							if imgui.Button(fa.ICON_TIMES .. "##" .. count_Floods .. "/" .. key,imgui.ImVec2(20,0)) then
								table.remove( customFloods_txt[count_Floods], key )
							end

							imgui.PopStyleColor(1)


							if control_flood[key+1] == nil then
								if imgui.Button(fa.ICON_PLUS .. u8" Добавить. ## 3",imgui.ImVec2(-1,0)) then
									table.insert(customFloods_txt[count_Floods], imgui.ImBuffer(1000))
								end
									
								if imgui.Button(fa.ICON_FLOPPY_O .. u8" Сохранить. ## 3",imgui.ImVec2(-1,0)) then	
									saveFloodsOnFile()
								end

							end
						end

						imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0.60, 0, 1.0))
						if control_flood[1] == nil then
							if imgui.Button(fa.ICON_PLUS .. u8" Добавить. ## 3",imgui.ImVec2(-1,0)) then
								table.insert(customFloods_txt[count_Floods], imgui.ImBuffer(1000))
							end

						end
						imgui.PopStyleColor()

						imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.60, 0.60, 1.0))
						if imgui.Button(fa.ICON_ANGLE_DOUBLE_LEFT .. u8" Назад. ## 1",imgui.ImVec2(-1,0)) then	
							count_Floods = 0
						end
						imgui.PopStyleColor()

					end

				imgui.EndChild()

			else

				imgui.BeginChild(u8"##empty", imgui.ImVec2(-1, imgui.GetWindowHeight()-setting_window_y), true)
				imgui.EndChild()

			end

			imgui.SetCursorPosY(imgui.GetWindowHeight() - 50)
			imgui.BeginChild("## Info", _, true)
				imgui.Text(u8"Версия скрипта: " .. script_version_text)
				imgui.Link("https://vk.com/sy_nc")
				imgui.SameLine()
				imgui.TextQuestion(u8'Кликабельная ссылка для перехода в сообщество скрипта.')
			imgui.EndChild()
		
		imgui.End()

	end
	
	if i_re_menu.v and control_recon and recon_to_player and setting_items.hide_td.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw-10, 10), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400, sh/1.05), imgui.Cond.FirstUseEver)
		
		if right_re_menu then
		local btn_size = imgui.ImVec2(-0.1, 0)
			imgui.Begin(u8"Информация об игроке.", false, 2+4+32+imgui.WindowFlags.NoTitleBar)
				if accept_load then
					if not sampIsPlayerConnected(control_recon_playerid) then
						control_recon_playernick = "-"
					else
						control_recon_playernick = sampGetPlayerNickname(control_recon_playerid)
					end

					imgui.BeginChild(u8"#headrecon", imgui.ImVec2(-1,25), true)
						imgui.SetCursorPosX((imgui.GetWindowWidth()/2) - (imgui.CalcTextSize(u8"Игрок: " .. control_recon_playernick .. "[" .. control_recon_playerid .. "]").x/2))
						imgui.Text(u8"Игрок: " .. control_recon_playernick .. "[" .. control_recon_playerid .. "]")
					imgui.EndChild()

					imgui.BeginChild(u8"##controlrecon", imgui.ImVec2(-1,30), true)
						if imgui.Button(fa.ICON_CHEVRON_LEFT .. " Back Player", imgui.ImVec2(imgui.GetWindowWidth()/2-6,0)) then
							re_id = control_recon_playerid - 1
							sampSendChat("/re "..re_id)
						end

						imgui.SameLine()

						if imgui.Button("Next Player " .. fa.ICON_CHEVRON_RIGHT, imgui.ImVec2(imgui.GetWindowWidth()/2-7,0)) then
							re_id = control_recon_playerid + 1
							sampSendChat("/re "..re_id)
						end
					imgui.EndChild()

					imgui.BeginChild("##Окно бара recon.", imgui.ImVec2(40,-1), true)
						if imgui.SelectableButton(fa.ICON_USER, tabs_tabel.recon.info, u8"Игроки рядом.", imgui.ImVec2(30, 30)) then
							tabs_tabel.recon.info = not tabs_tabel.recon.info
							tabs_tabel.recon.punish = false
							tabs_tabel.recon.recon_setting = false
							tabs_tabel.recon.stream_players = false
						end
						if imgui.SelectableButton(fa.ICON_WRENCH, tabs_tabel.recon.recon_setting, u8"Информация.", imgui.ImVec2(30, 30)) then
							tabs_tabel.recon.recon_setting = not tabs_tabel.recon.recon_setting
							tabs_tabel.recon.info = false
							tabs_tabel.recon.punish = false
							tabs_tabel.recon.stream_players = false
						end
						if imgui.SelectableButton(fa.ICON_SHIELD, tabs_tabel.recon.punish, u8"Настройки рекона.", imgui.ImVec2(30, 30)) then
							tabs_tabel.recon.punish = not tabs_tabel.recon.punish
							tabs_tabel.recon.info = false
							tabs_tabel.recon.recon_setting = false
							tabs_tabel.recon.stream_players = false
						end
						if imgui.SelectableButton(fa.ICON_USERS, tabs_tabel.recon.stream_players, u8"Действия.", imgui.ImVec2(30, 30)) then
							tabs_tabel.recon.stream_players = not tabs_tabel.recon.stream_players
							tabs_tabel.recon.info = false
							tabs_tabel.recon.recon_setting = false
							tabs_tabel.recon.punish = false
						end
					imgui.EndChild()

					imgui.SameLine()

					if tabs_tabel.recon.info then
						imgui.BeginChild(u8"#infoplayerrecon", imgui.ImVec2(-1,-1), true)
							for key, v in pairs(player_info) do
								if key == 1 then
									imgui.Text(u8:encode(text_remenu[1]) .. " " .. player_info[1])
									imgui.BufferingBar("##BUFF1", tonumber(player_info[1])/100, imgui.ImVec2(imgui.GetWindowWidth(), 10), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Button]), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
									imgui.Separator()
								end
								if key == 2 and tonumber(player_info[2]) ~= 0 then
									imgui.Text(u8:encode(text_remenu[2]) .. " " .. player_info[2])
									imgui.BufferingBar("##BUFF2", tonumber(player_info[2])/100, imgui.ImVec2(imgui.GetWindowWidth(), 10), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Button]), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
									imgui.Separator()
								end
								if key == 3 and tonumber(player_info[3]) ~= -1 then
									imgui.Text(u8:encode(text_remenu[3]) .. " " .. player_info[3])
									imgui.BufferingBar("##BUFF3", tonumber(player_info[3])/1000, imgui.ImVec2(imgui.GetWindowWidth(), 10), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Button]), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
									imgui.Separator()
								end
								if key == 4 then
									--print(player_info[4])
									imgui.Text(u8:encode(text_remenu[4]) .. " " .. player_info[4])
									local speed, const = string.match(player_info[4], "(%d+) / (%d+)")
									if tonumber(speed) > tonumber(const) then
										speed = const
									end
									imgui.BufferingBar("##BUFF4", (tonumber(speed)*100/tonumber(const))/100, imgui.ImVec2(imgui.GetWindowWidth(), 10), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Button]), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
									imgui.Separator()
								end
					
								if key ~= 1 and key ~= 2 and key ~= 3 and key ~= 4 then
									imgui.Text(u8:encode(text_remenu[key]) .. " " .. player_info[key])
									imgui.Separator()
								end
							end
						imgui.EndChild()
					elseif tabs_tabel.recon.recon_setting then
						imgui.BeginChild(u8"#reconsetting", imgui.ImVec2(-1,-1), true)

							imgui.Text(u8" WallHack")
							imgui.SameLine()
							imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
							if imgui.ToggleButton(u8"WallHack", setting_items.wh) then	
								if control_wallhack then
									nameTagOff()
									control_wallhack = false
								else
									nameTagOn()
									control_wallhack = true
								end
							end

							imgui.Text(u8" Трейсер пуль")
							imgui.SameLine()
							imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
							if imgui.ToggleButton(u8"Трейсер пуль", setting_items.trc) then
								if traic then
									traic = false
								else
									traic = true
								end
							end

						imgui.EndChild()
					elseif tabs_tabel.recon.stream_players then
						imgui.BeginChild("##Окно игроков рядом.", imgui.ImVec2(-1,-1), true)
						imgui.CenterText(u8"Игроки рядом")
						local playerid_to_stream = playersToStreamZone()
					
						for _, v in pairs(playerid_to_stream) do
							if imgui.Button(" - " .. sampGetPlayerNickname(v) .. "[" .. v .. "] - ", imgui.ImVec2(-1,0)) then
								sampSendChat("/re " .. v)
							end				
						end
						imgui.EndChild()
					elseif tabs_tabel.recon.punish then

						imgui.BeginChild(u8"##punishrecon", imgui.ImVec2(-1,-1), true)

							id_suspeckt = "" .. control_recon_playerid
							
							if imgui.Button(u8"Клиент", imgui.ImVec2(imgui.GetWindowWidth()/3-6,0)) then
								lua_thread.create(function()
									sampSendChat('/tonline')
									wait(100)
									sampCloseCurrentDialogWithButton(1)
									wait(100)
									check_report = true
								end)
							end

							imgui.SameLine()
							
							if imgui.Button(u8"Заспавнить", imgui.ImVec2(imgui.GetWindowWidth()/3-6,0)) then
								sampSendChat("/aspawn "..control_recon_playerid)
							end

							imgui.SameLine()

							if imgui.Button(u8"Слап", imgui.ImVec2(imgui.GetWindowWidth()/3-5,0)) then
								sampSendChat("/slap "..control_recon_playerid)
							end

							
							if imgui.Button(u8"Тп к игроку", imgui.ImVec2(imgui.GetWindowWidth()/2-7,0)) then
								lua_thread.create(function()
									sampSendChat("/reoff")
									wait(1200)
									sampSendChat("/gt "..id_suspeckt)
								end)
							end

							imgui.SameLine()

							if imgui.Button(u8"Тп к себе", imgui.ImVec2(imgui.GetWindowWidth()/2-7,0)) then
								lua_thread.create(function()
									sampSendChat("/reoff")
									wait(1200)
									sampSendChat("/gethere "..id_suspeckt)
								end)
							end

							imgui.Separator()
							
							if imgui.Button(u8"Freeze: Заморозка", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/freeze "..control_recon_playerid)
							end
							
							if imgui.Button(u8"Jail: Помеха мероприятию", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/jail "..control_recon_playerid .. " 300 Помеха мероприятию")
							end
							
							if imgui.Button(u8"Jail: Убийство игроков на спавне.", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/jail "..control_recon_playerid .. " 300 Убийство игроков на спавне.")
							end
							
							if imgui.Button(u8"Jail: ДМ в Зеленой зоне", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/jail "..control_recon_playerid .. " 300 DM in ZZ")
							end
							
							if imgui.Button(u8"Jail: ДБ в Зеленой зоне", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/jail "..control_recon_playerid .. " 300 DB in ZZ")
							end
							
							if imgui.Button(u8"Jail: ДБ в Зеленой зоне (Ковш)", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/jail "..control_recon_playerid .. " 900 DB in ZZ (Ковш)")
							end
							
							if imgui.Button(u8"Jail: Паркур Мод", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/jail "..control_recon_playerid .. " 900 ИЗП. (ParkourMode)")
							end
							
							if imgui.Button(u8"Jail: Клео Анимации", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/jail "..control_recon_playerid .. " 900 ИЗП. (CLEO Animations)")
							end
							
							if imgui.Button(u8"Jail: Флай", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/jail "..control_recon_playerid .. " 900 ИЗП. (Fly)")
							end
							
							if imgui.Button(u8"Jail: Флай на машине", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/jail "..control_recon_playerid .. " 900 ИЗП. (Fly Car)")
							end
							
							if imgui.Button(u8"Jail: Speed Hack", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/jail "..control_recon_playerid .. " 900 ИЗП. (SpeedHack)")
							end
							
							imgui.Separator()
							
							if imgui.Button(u8"Ban: AIM", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/iban "..control_recon_playerid .. " 7 ИЗП. (AIM)")
							end
							
							if imgui.Button(u8"Ban: Sobe1t", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/iban "..control_recon_playerid .. " 7 ИЗП. (s0be1t)")
							end
							
							if imgui.Button(u8"Ban: Auto +C", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/iban "..control_recon_playerid .. " 7 ИЗП. (Auto +C)")
							end
							
							if imgui.Button(u8"Ban: Car Shot", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/iban "..control_recon_playerid .. " 7 ИЗП. (CarShot)")
							end
							
							if imgui.Button(u8"Ban: Rvanka", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/iban "..control_recon_playerid .. " 7 ИЗП. (Rvanka)")
							end
							
							if imgui.Button(u8"Ban: Неадекватное поведение", imgui.ImVec2(imgui.GetWindowWidth()-11,0)) then
								sampSendChat("/ban "..control_recon_playerid .. " 3 Неадекватное поведение.")
							end

						imgui.EndChild()

					else

						imgui.BeginChild(u8"##empty", imgui.ImVec2(-1, -1), true)
						imgui.EndChild()
					
					end


				
		
			else
				imgui.BeginChild(u8"#spiner", _, true)
					imgui.SetCursorPosX(imgui.GetWindowWidth()/2-10)
					imgui.SetCursorPosY(imgui.GetWindowHeight()/2-10)
					imgui.Spinner("##spinner", 20, 7, imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
				imgui.EndChild()
			end
			
			imgui.End()
			 
		end
		
	end

	if i_cmd_helper.v then
		local in1 = sampGetInputInfoPtr()
		local in1 = getStructElement(in1, 0x8, 4)
		local in2 = getStructElement(in1, 0x8, 4)
		local in3 = getStructElement(in1, 0xC, 4)
		fib = in3 + 41
		fib2 = in2 + 10
		imgui.SetNextWindowPos(imgui.ImVec2(fib2, fib), imgui.Cond.FirstUseEver, imgui.ImVec2(0, -0.1))
		imgui.SetNextWindowSize(imgui.ImVec2(590, 250), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Быстрые команды наказаний.", false, 2+4+32)
		if check_cmd_punis ~= nil then
			for key, v in pairs(cmd_punis_mute) do
				if v:find(string.lower(check_cmd_punis)) ~= nil or v:find(string.lower(RusToEng(check_cmd_punis))) ~= nil or v == string.lower(check_cmd_punis):match("(.+) (.+) ") or v == string.lower(RusToEng(check_cmd_punis)):match("(.+) (.+) ")  or v == string.lower(check_cmd_punis):match("(.+) ") or v == string.lower(RusToEng(check_cmd_punis)):match("(.+) ") then
					imgui.Text("Mute: -" .. v .. u8" [PlayerID] (Множитель наказания.) - " .. u8:encode(punishments[v].reason))
				end
			end
			for key, v in pairs(cmd_punis_ban) do
				if v:find(string.lower(check_cmd_punis)) ~= nil or v:find(string.lower(RusToEng(check_cmd_punis))) ~= nil or v == string.lower(check_cmd_punis):match("(.+) (.+) ") or v == string.lower(RusToEng(check_cmd_punis)):match("(.+) (.+) ")  or v == string.lower(check_cmd_punis):match("(.+) ") or v == string.lower(RusToEng(check_cmd_punis)):match("(.+) ") then
					imgui.Text("Ban: -" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
				end
			end
			for key, v in pairs(cmd_punis_jail) do
				if v:find(string.lower(check_cmd_punis)) ~= nil or v:find(string.lower(RusToEng(check_cmd_punis))) ~= nil or v == string.lower(check_cmd_punis):match("(.+) (.+) ") or v == string.lower(RusToEng(check_cmd_punis)):match("(.+) (.+) ")  or v == string.lower(check_cmd_punis):match("(.+) ") or v == string.lower(RusToEng(check_cmd_punis)):match("(.+) ") then
					imgui.Text("Jail: -" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
				end
			end
		else
			for key, v in pairs(cmd_punis_mute) do
				imgui.Text("Mute: -" .. v .. u8" [PlayerID] (Множитель наказания.) - " .. u8:encode(punishments[v].reason))
			end
			for key, v in pairs(cmd_punis_ban) do
				imgui.Text("Ban: -" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
			end
			for key, v in pairs(cmd_punis_jail) do
				imgui.Text("Jail: -" .. v .. u8" [PlayerID] - " .. u8:encode(punishments[v].reason))
			end
		end
		imgui.End()
	end

	if i_chat_logger.v then
		imgui.LockPlayer = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
		imgui.SetNextWindowSize(imgui.ImVec2(sw/1.3, sh/1.05), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Чат-логер", i_chat_logger)
			if accept_load_clog then
				imgui.InputText(u8"Поиск.", chat_find)
				if chat_find.v == "" then
					imgui.Text(u8'Начните вводить текст.\n')
				else
					for key, v in pairs(chat_logger_text) do
						if v:find(chat_find.v) ~= nil then
							imgui.Text(u8:encode(v))
						end
					end
				end
			else
				imgui.SetCursorPosX(imgui.GetWindowWidth()/2.3)
				imgui.SetCursorPosY(imgui.GetWindowHeight()/2.3)
				imgui.Spinner("##spinner", 20, 7, imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
			end
		imgui.End()
	end

	if i_ans_window.v then
		local sw2, sh2 = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw2 / 2, sh2 / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(sw2/1.3, sh/1.3), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Репорты.", i_ans_window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		
			imgui.LockPlayer = true

			imgui.BeginChild(u8"#headans", imgui.ImVec2(-1,25), true)
				
				imgui.SetCursorPosX((imgui.GetWindowWidth()/2) - (imgui.CalcTextSize(u8"Настройки.").x/2))
				imgui.Text(fa.ICON_ASTERISK .. u8" Репорты")

			imgui.EndChild()
			

			imgui.BeginChild(u8"#ans", imgui.ImVec2(imgui.GetWindowWidth()/4,25), true)
				
				imgui.SetCursorPosX((imgui.GetWindowWidth()/2) - (imgui.CalcTextSize(u8"Настройки.").x/2))
				imgui.Text(fa.ICON_ASTERISK .. u8" Жалобы")

			imgui.EndChild()

			imgui.SameLine()

			imgui.BeginChild(u8"#activans", imgui.ImVec2(-1,25), true)
				
				imgui.SetCursorPosX((imgui.GetWindowWidth()/2) - (imgui.CalcTextSize(u8"Настройки.").x/2))
				imgui.Text(fa.ICON_ASTERISK .. u8" Действия")

			imgui.EndChild()

			imgui.BeginChild("##testans2", imgui.ImVec2(imgui.GetWindowWidth()/4,-1), true)
				for key, val in ipairs(report_windows) do
					imgui.SetCursorPosY(10)
					imgui.SetCursorPosX(10)
					imgui.Text(key .. " | " .. val.nick .. " | " .. val.id)
					imgui.SetCursorPosY(imgui.GetCursorPosY() + 2)
					imgui.SetCursorPosX(10)
					imgui.Text(u8:encode(val.text))
					imgui.SetCursorPosX(imgui.GetWindowWidth()-25)
					imgui.SetCursorPosY(5)
					imgui.Button(fa.ICON_CHEVRON_RIGHT .. "##da", imgui.ImVec2(20,45))
					imgui.Separator()
				end
				
			imgui.EndChild()

			imgui.SameLine()

			imgui.BeginChild(u8"#testans", imgui.ImVec2(-1,-1), true)
				
			imgui.EndChild()

		imgui.End()
	end

end

function imgui.NewInputText(lable, val, width, hint, hintpos)
    local hint = hint and hint or ''
    local hintpos = tonumber(hintpos) and tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)
    local result = imgui.InputText(lable, val)
    if #val.v == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end
    imgui.PopItemWidth()
    return result
end

function instal_scripts_event()
  
	local dlstatus = require('moonloader').download_status
	local link_event = "https://raw.githubusercontent.com/Vrednaya1234/Scripts-SAMP/main/Events.lua"
	local downloadState = 'process'
	downloadUrlToFile(link_event, "moonloader/Events.lua", function(id3, status1, p13, p23)
		lua_thread.create(function()
			sampAddChatMessage(tag .. string.format("Установленно %d из %d", p13, p23))
			wait(900)
			wait(900)
			reloadScripts()
		end)
	end)
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function samp.onBulletSync(playerid, data)
	if traic then
		if data.target.x == -1 or data.target.y == -1 or data.target.z == -1 then
			return true
		end
		BulletSync.lastId = BulletSync.lastId + 1
		if BulletSync.lastId < 1 or BulletSync.lastId > BulletSync.maxLines then
			BulletSync.lastId = 1
		end
		local id = BulletSync.lastId
		BulletSync[id].enable = true
		BulletSync[id].tType = data.targetType
		BulletSync[id].time = os.time() + 15
		BulletSync[id].o.x, BulletSync[id].o.y, BulletSync[id].o.z = data.origin.x, data.origin.y, data.origin.z
		BulletSync[id].t.x, BulletSync[id].t.y, BulletSync[id].t.z = data.target.x, data.target.y, data.target.z
	end
end


-- [x] -- Тело скрипта. -- [x] --
function main()

	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end 
	
		wait(1000)
	if not checkServer(select(1, sampGetCurrentServerAddress())) then
		showNotification('Ошибка','Скрипт работает только на серверах\nRussian Drift Server!')
		wait(3000)
		thisScript():unload()
	end

	sampAddChatMessage(tag .. getWorkingDirectory())

	_, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	player_nick = sampGetPlayerNickname(player_id)

	if dir_doc ~= nil then
		sampAddChatMessage(tag .. dir_doc)
	end

	kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr()) -- Kill List
	
	
	
	if not doesDirectoryExist(getWorkingDirectory() .. "/config/AH_Setting") then
		createDirectory(getWorkingDirectory() .. "/config/AH_Setting")
	end

	chatlogDirectory = getWorkingDirectory() .. "\\config\\AH_Setting\\chatlog"
	if not doesDirectoryExist(chatlogDirectory) then
		createDirectory(chatlogDirectory)
	end

	sampRegisterChatCommand('ah_setting', function()
		i_setting_items.v = not i_setting_items.v
		imgui.Process = i_setting_items.v
	end)
	
	sampRegisterChatCommand("ac",function()
		alogin_window.v = not alogin_window.v
		imgui.Process = alogin_window.v
	end)
	sampRegisterChatCommand("caccess",function()
		if setting_items.developer.v then
			for aname, val in pairs(Access) do
				if val == true then
					sampAddChatMessage(tag .. aname .. " = {00AA00}true")
				else
					sampAddChatMessage(tag .. aname .. " = {AA0000}false")
				end
			end
		end
		check_load_access = true
		access_check:run()
	end)
	
	cmd_p = ""
	--update(
	
	
	local file_read, c_line = io.open(getWorkingDirectory() .. "\\config\\AH_Setting\\mat.txt", "r+"), 1
	if file_read ~= nil then
		file_read:seek("set", 0)
		for line in file_read:lines() do
			onscene[c_line] = line
			c_line = c_line + 1
		end
		file_read:close()
    end
	-- 2
	
	sampRegisterChatCommand('smat', function(param)
		if param == nil then
			return false
		end
		for _, val in ipairs(onscene) do
			if string.rlower(param) == val then
				sampAddChatMessage(tag .. "Слово \"" .. val .. "\" уже присутствует в списке.")
				return false
			end
		end
		local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AH_Setting\\mat.txt", "w"), 1
		onscene[#onscene + 1] = string.rlower(param)
		for _, val in ipairs(onscene) do
			file_write:write(val .. "\n")
		end
		file_write:close()
		sampAddChatMessage(tag .. "Слово \"" .. string.rlower(param) .. "\" успешно добавленно в список.")
	end)
	-- 2

	sampRegisterChatCommand('dmat', function(param)
		if param == nil then
			return false
		end
		local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AH_Setting\\mat.txt", "w"), 1
		for i, val in ipairs(onscene) do
			if val == string.rlower(param) then
				onscene[i] = nil
				control_onscene = true
			else
				file_write:write(val .. "\n")
			end
		end
		file_write:close()
		if control_onscene then
			sampAddChatMessage(tag .. "Слово \"" .. string.rlower(param) .. "\" было успешно удалено из спискат мата.")
			control_onscene = false
		else
			sampAddChatMessage(tag .. "Слова \"" .. string.rlower(param) .. "\" нет в списке мата.")
		end
	end)
	-- 2
	
	sampRegisterChatCommand('minigun', function(param_minigun)
		sampSendChat('/setweap ' .. param_minigun .. ' 38 5000')
	end)
	
	act = 0

	loadFloodsOnFile()

	sampRegisterChatCommand('cfind', function(param)
		if param == nil then
			i_chat_logger.v = not i_chat_logger.v
			imgui.Process = true
			chat_logger_text = readChatlog()
		else
			i_chat_logger.v = not i_chat_logger.v
			imgui.Process = true
			chat_find.v = param
			chat_logger_text = readChatlog()
		end
		load_chat_log:run()
	end)

	
	

	config = inicfg.load(defTable, directIni)
	setting_items.Fast_ans.v = config.setting.Fast_ans
	setting_items.Punishments.v = config.setting.Punishments
	setting_items.Admin_chat.v = config.setting.Admin_chat
	setting_items.Custom_SB.v = config.setting.Custom_SB
	setting_items.Transparency.v = config.setting.Tranparency
	setting_items.WallHack.v = config.setting.WallHack
	setting_items.Auto_remenu.v = config.setting.Auto_remenu
	setting_items.Push_Report.v = config.setting.Push_Report
	setting_items.Chat_Logger.v = config.setting.Chat_Logger
	setting_items.Chat_Logger_osk.v = config.setting.Chat_Logger_osk
	setting_items.hide_td.v = config.setting.hide_td
	setting_items.skip_dialogs.v = config.setting.skip_dialogs
	setting_items.anti_cheat.v = config.setting.anti_cheat
	setting_items.auto_report.v = config.setting.auto_report
	setting_items.text_anticheat.v = config.setting.text_anticheat
	setting_items.sp_autologin.v = config.setting.sp_autologin
	
	HelloAC.v = config.setting.HelloAC
	AdminPassword.v = config.setting.AdminPassword
	alogin_skin.v = config.setting.alogin_skin
	alogin_hiCheckbox.v = config.setting.alogin_hiCheckbox
	admlvl.v = config.setting.admlvl
    report_all = config.setting.report_all
	report_day = config.setting.report_day
	
	prefix_Helper.v = config.setting.prefix_Helper
	prefix_Adm.v = config.setting.prefix_Adm
	prefix_MA.v = config.setting.prefix_MA
	prefix_StAdm.v = config.setting.prefix_StAdm
	prefix_Zga.v = config.setting.prefix_Zga
	prefix_PGA.v = config.setting.prefix_PGA

	index_text_pos = config.setting.Y

	font_ac = renderCreateFont("Arial", config.achat.Font, font_admin_chat.BOLD + font_admin_chat.SHADOW)
	font_watermark = renderCreateFont("Arial", 10, font_admin_chat.BOLD)
	admin_chat = lua_thread.create_suspended(drawAdminChat)
	check_dialog_active = lua_thread.create_suspended(checkIsDialogActive)
	draw_re_menu = lua_thread.create_suspended(drawRePlayerInfo)
	check_updates = lua_thread.create_suspended(sampCheckUpdateScript)
	load_chat_log = lua_thread.create_suspended(loadChatLog)
	load_info_player = lua_thread.create_suspended(loadPlayerInfo)
	wallhack = lua_thread.create(drawWallhack)
	access_check = lua_thread.create_suspended(accessCheck)
	lua_thread.create(time)
    time = 0
	wait_reload = lua_thread.create_suspended(function()
		wait(3000)
		showNotification("Обновление!", "Библиотека успешно обновлена!")
		thisScript():reload()
	end)
		
	goScreenShot = lua_thread.create_suspended(function()
		setVirtualKeyDown(119, true)
        wait(10)
        setVirtualKeyDown(119, false)
	end)

	check_cmd = lua_thread.create_suspended(function()
		wait(1000)
		check_cmd_re = false
	end)

	acCheckList = lua_thread.create_suspended(function()
		
	end)


	lua_thread.create(function()
		while true do
			_, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			player_nick = sampGetPlayerNickname(player_id)
			if setting_items.developer.v then
				renderFontDrawText(font_watermark, tag .. "{FFFFFF}v." .. script_version_text .. " {FFFFFF}| " .. player_nick .. "[" .. player_id .. "] | Время: " .. os.date("%H:%M:%S") .. 
				"\n" .. tag .. "Mode: Developer | Current Dialog ID: " .. sampGetCurrentDialogId(), 20, sh-38, 0xCCFFFFFF)
			else
				renderFontDrawText(font_watermark, tag .. "{FFFFFF}v." .. script_version_text .. " {FFFFFF}| " .. player_nick .. "[" .. player_id .. "] | Время: " .. os.date("%H:%M:%S"), 20, sh-20, 0xCCFFFFFF)
			end
			if setting_items.anti_cheat.v then 
				renderFontDrawText(font_watermark, tag.. '\n' ..ac_string, 20, sh-350, 0xCCFFFFFF)
			end
			
			if wasKeyPressed(88) and not sampIsChatInputActive() and not sampIsDialogActive() then
	   			activation = not activation
			end
		
			wait(1)
		end
	end)

	sampRegisterChatCommand("testwin", function()
		i_ans_window.v = not i_ans_window.v
		imgui.Process = true
	end)

	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstat.STATUS_ENDDOWNLOADDATA then
			check_updates:run()
			--showNotification("Проверка обновления.", "Идет провека обновления!")
			
		end
	end)
	
	

	wait(500)
	loadAdminChat()
	admin_chat:run()

	
	while true do
	local oTime = os.time()
		if traic then
			for i = 1, BulletSync.maxLines do
				if BulletSync[i].enable == true and oTime <= BulletSync[i].time then
					local o, t = BulletSync[i].o, BulletSync[i].t
					if isPointOnScreen(o.x, o.y, o.z) and
						isPointOnScreen(t.x, t.y, t.z) then
						local sx, sy = convert3DCoordsToScreen(o.x, o.y, o.z)
						local fx, fy = convert3DCoordsToScreen(t.x, t.y, t.z)
						renderDrawLine(sx, sy, fx, fy, 1, BulletSync[i].tType == 0 and 0xFFFFFFFF or 0xFFFF0000)
						renderDrawPolygon(fx, fy-1, 3, 3, 4.0, 10, BulletSync[i].tType == 0 and 0xFFFFFFFF or 0xFFFFC700)
					end
				end
			end
		end


		local result, button, list, input = sampHasDialogRespond(1999)
		if result then
			if button == 1 then
				if list == 0 then
					sampAddChatMessage(tag .. 'Запускаю спавн игрков.')
					local playerid_to_stream = playersToStreamZone()
					lua_thread.create(function()
						wait(500)        
						for _, v in pairs(playerid_to_stream) do
							sampSendChat('/aspawn ' .. v)
						end
					end)
				end
				if list == 1 then
					sampAddChatMessage(tag .. 'Вы отменили действие.')
				end
			end
		end
				-- test
		

		if isKeysDown(strToIdKeys(config.keys.Setting)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			i_setting_items.v = not i_setting_items.v
			imgui.Process = true
		end
		
		-- online
		if isKeysDown(strToIdKeys(config.keys.online)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			sampSendChat("/online")
			wait(100)
			local c = math.floor(sampGetPlayerCount(false) / 10)
			sampSendDialogResponse(1098, 1, c - 1)
			sampCloseCurrentDialogWithButton(0)
			wait(650)
		end
		-- wh
		if isKeysDown(strToIdKeys(config.keys.wh)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			if control_wallhack then
				nameTagOff()
				control_wallhack = false
			else
				nameTagOn()
				control_wallhack = true
			end
		end
		-- tracer
		if isKeysDown(strToIdKeys(config.keys.trc)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			if traic then
				traic = false
			else
				traic = true
			end
		end
		if isKeyDown(VK_Q)  and setting_items.hide_td.v and not sampIsChatInputActive() and not sampIsDialogActive() then
			sampSendChat('/reoff')
		end
		
		if isKeyDown(VK_R)  and setting_items.hide_td.v and not sampIsChatInputActive() and not sampIsDialogActive() then
			sampSendClickTextdraw(136)
		end
		
		if control_recon and recon_to_player then
			if control_info_load then
				control_info_load = false
				load_info_player:run()
				i_re_menu.v = true
				imgui.Process = true
				jail_or_ban_re = 0
			end
		else
			i_re_menu.v = false
		end
		if isKeyJustPressed(0x09) and setting_items.Custom_SB.v then
			sc_board.ActivetedScoreboard()
		end
		if isKeysDown(strToIdKeys(config.keys.Hide_AChat)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			setting_items.Admin_chat.v = not setting_items.Admin_chat.v
		end
		if not i_admin_chat_setting.v and
		not i_setting_items.v and
		not i_ans_window.v and
		not i_info_update.v and
		not i_re_menu.v and
		not i_cmd_helper.v and
		not stats_window_imgui.v and
		not i_chat_logger.v and 
		not i_punish_window.v and
		not alogin_window.v then
			imgui.Process = false
			imgui.LockPlayer = false
		end

		--[[if sampGetCurrentDialogId() == 2351 and setting_items.Fast_ans.v and sampIsDialogActive() then
			i_ans_window.v = true
			imgui.Process = true
		else
			i_ans_window.v = false
		end]]
		
		if sampGetCurrentDialogId() == 657 and setting_items.skip_dialogs.v and sampIsDialogActive() then
			sampSendDialogResponse(657, 1, 2)
			sampCloseCurrentDialogWithButton(1)
		end
		
		if sampGetCurrentDialogId() == 658 and setting_items.skip_dialogs.v and sampIsDialogActive() then
			sampSendDialogResponse(658, 1)
			sampCloseCurrentDialogWithButton(1)
		end
		
		
		if not i_re_menu.v then
			check_mouse = true
		end
		if isKeysDown(strToIdKeys(config.keys.P_Log)) and setting_items.Chat_Logger.v and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			i_info_update.v = not i_info_update.v
			imgui.Process = true
		end
		if isKeyJustPressed(VK_RBUTTON) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			check_mouse = not check_mouse
		end
		if isKeysDown(strToIdKeys(config.keys.Re_menu)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			right_re_menu = not right_re_menu
		end
		--[[if isKeysDown(strToIdKeys(config.keys.Hello)) and (sampIsDialogActive() == false) then
			sampSendChat("/a " .. u8:decode(HelloAC.v))
		end]]
		if not sampIsPlayerConnected(control_recon_playerid) then
			i_re_menu.v = false
			control_recon_playerid = -1
		end
		if sampIsChatInputActive() then
			if sampGetChatInputText():find("-") == 1 then
				i_cmd_helper.v = true
				imgui.Process = true
				if sampGetChatInputText():match("-(.+)") ~= nil then
					check_cmd_punis = sampGetChatInputText():match("-(.+)")
				else
					check_cmd_punis = nil
				end
			else
				i_cmd_helper.v = false
			end
		else
			i_cmd_helper.v = false
		end

		if ac_no_saved.pos then
			if isKeyJustPressed(VK_RBUTTON) then
				admin_chat_lines.X = ac_no_saved.X
				admin_chat_lines.Y = ac_no_saved.Y
				ac_no_saved.pos = false
				i_setting_items.v = true
			elseif isKeyJustPressed(VK_LBUTTON) then
				ac_no_saved.pos = false
				i_setting_items.v = true
			else
				admin_chat_lines.X, admin_chat_lines.Y = getCursorPos()
			end
		end
		wait(0)
	end

end

function accessCheck()
	sampAddChatMessage(tag .. "Проверяю доступы администратора.")
	sampSendChat("/access")
	wait(100)
	sampCloseCurrentDialogWithButton(0)
	wait(1500)
	sampAddChatMessage(tag .. "Доступы выгружены.")
	check_load_access = false
	for i, v in pairs(temptext) do
		if i ~= 1 then 
			if v:match("Имеется") ~= nil then
				Access[i-1] = true
			else
				Access[i-1] = false
			end
		end
	end
end

function samp.onPlayerDeathNotification(killerId, killedId, reason) -- New Kill List
	local kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)

	local n_killer = ( sampIsPlayerConnected(killerId) or killerId == myid ) and sampGetPlayerNickname(killerId) or nil
	local n_killed = ( sampIsPlayerConnected(killedId) or killedId == myid ) and sampGetPlayerNickname(killedId) or nil
	lua_thread.create(function()
		wait(0)
		if n_killer then kill.killEntry[4].szKiller = ffi.new('char[25]', ( n_killer .. '[' .. killerId .. ']' ):sub(1, 24) ) end
		if n_killed then kill.killEntry[4].szVictim = ffi.new('char[25]', ( n_killed .. '[' .. killedId .. ']' ):sub(1, 24) ) end
	end)
end

function imgui.TextQuestion(text)
	imgui.TextDisabled('(?)')
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end

function imgui.SelectableButton(text, check_press, question, size)
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(500)
		imgui.TextUnformatted(question)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
	local button_check
	if check_press then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.67, 0.67, 0.67, 1.00))
		
		button_check = imgui.Button(text, size)

		imgui.PopStyleColor(1)
	else
		imgui.PushStyleColor(imgui.Col.Button, imgui.Col.WindowBg)
		
		button_check = imgui.Button(text, size)

		imgui.PopStyleColor(1)
	end
	return button_check
end

function saveFloodsOnFile()
	local fld = io.open(FloodsFilePath, 'w')

	for key, val in ipairs(customFloods_set) do
		fld:write("=== Bind " .. key .. " ==============================\n.begin(" .. key .. ")\n\tName = " .. val .. "\n")
		for key2, val2 in ipairs(customFloods_txt[key]) do
			fld:write("\t" .. u8:decode(val2.v) .. "\n")
		end
		fld:write(".end\n")
		fld:flush()
	end
	fld:close()
	return true
end


function loadFloodsOnFile()
	local fld = io.open(FloodsFilePath, 'r')
	if fld ~= nil then
		for line in fld:lines() do
			if line:match("== Bind") == nil then
				if line:match("%.begin") ~= nil then
					countLoadFlood = tonumber(line:match("%.begin%((.+)%)"))
				elseif line:match(".end") ~= nil then
					countLoadFlood = nil
					controlLoadFlood = nil
				else
					if line:match("Name = ") ~= nil then
						customFloods_set[countLoadFlood] = u8:encode(line:match("Name = (.+)"))
					elseif customFloods_txt[countLoadFlood] == nil then
						customFloods_txt[countLoadFlood] = { imgui.ImBuffer(u8:encode(line:sub(2)), 1000) }
					else
						table.insert(customFloods_txt[countLoadFlood], imgui.ImBuffer(u8:encode(line:sub(2)), 1000))
					end
				end
			end
		end
		fld:close()
	end
	
	return true
end

function saveAdminChat()
	config.achat.X = admin_chat_lines.X
	config.achat.Y = admin_chat_lines.Y
	config.achat.centered = admin_chat_lines.centered.v
	config.achat.nick = admin_chat_lines.nick.v
	config.achat.color = admin_chat_lines.color
	config.achat.lines = admin_chat_lines.lines.v
	config.achat.Font = font_size_ac.v
	inicfg.save(config, directIni)
end

function loadAdminChat()
	admin_chat_lines.X = tonumber(config.achat.X)
	admin_chat_lines.Y = tonumber(config.achat.Y)
	admin_chat_lines.centered.v = tonumber(config.achat.centered)
	admin_chat_lines.nick.v = tonumber(config.achat.nick)
	admin_chat_lines.color = tonumber(config.achat.color)
	admin_chat_lines.lines.v = tonumber(config.achat.lines)
	--font_size_ac.v = config.achat.Font
end