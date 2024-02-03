local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'

local directIni = 'AcsRempverByChapo.ini'
local ini = inicfg.load(inicfg.load({
    main = {
    	me = false,
    	other = true,
    },
}, directIni))
inicfg.save(ini, directIni)

local hide_me = ini.main.me
local hide_other = ini.main.other

function main()
	while not isSampAvailable() do wait(0) end
	sampRegisterChatCommand('acsrem', function()
		callDialog()
	end)
	while true do
		wait(0)
		result, button, list, input = sampHasDialogRespond(888)
		if result then
			if button == 1 then
				if list == 0 then 
					hide_me = not hide_me
					sampAddChatMessage('[ACS Remover by chapo]: {ffffff}зайди в любой интерьер', 0xFFff004d)
				elseif list == 1 then
					hide_other = not hide_other
					sampAddChatMessage('[ACS Remover by chapo]: {ffffff}обнови зону стрима', 0xFFff004d)
				end
				ini.main.me = hide_me
				ini.main.other = hide_other
				inicfg.save(ini, directIni)
				callDialog()
			end
		end
	end
end

function callDialog()
	sampShowDialog(888, 'ACS Remover by {ff004d}chapo', 'Скрывать мои аксессуары'..(hide_me and '{ff004d} - Выбрано' or '')..'\n'..'Скрывать чужие аксессуары'..(hide_other and '{ff004d} - Выбрано' or ''), 'Выбрать', 'Закрыть', 4 )
end

function sampev.onSetPlayerAttachedObject(playerId, index, create, object)
    if hide_me and playerId == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then return false end
    if hide_other and playerId ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then return false end
end