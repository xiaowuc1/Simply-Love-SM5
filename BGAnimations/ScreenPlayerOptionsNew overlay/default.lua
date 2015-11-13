---------------------------------------------------------------------
-- OptionRow Wheel(s)
---------------------------------------------------------------------
local Rows = {
	"SpeedModType",
	"SpeedMod",
	"Mini",
	"Perspective",
	"NoteSkin",
	"JudgmentGraphic",
	"BackgroundFilter",
	"MusicRate",
	"Steps",
	"ScreenAfterPlayerOptions",
	"Done"
}
-- the number of rows that can be vertically stacked on-screen simultaneously
local NumRowsToDraw = 10
local header_height = 32
local footer_height = 32
local RowHeight = (_screen.h - (header_height + footer_height))/(NumRowsToDraw+2)


local OptionRowWheels = {}

for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
	local pn = ToEnumShortString(player)

	-- Add one OptionWheel per human player
	OptionRowWheels[pn] = setmetatable({}, sick_wheel_mt)

	for optionrow in ivalues(Rows) do
		-- Add one OptionRowWheel per OptionRow
		OptionRowWheels[pn][optionrow] = setmetatable({} , sick_wheel_mt)
	end
end




---------------------------------------------------------------------
-- Initialize Generalized Event Handling function(s)
---------------------------------------------------------------------

local InputHandler = function(event)

	----------------------------------------------------------------------------

	-- if any of these, don't attempt to handle input
	if not event.PlayerNumber or not event.button then
		return false
	end

	if event.type == "InputEventType_FirstPress" and event.button == "Back" then
		SCREENMAN:GetTopScreen():GetChild("Overlay"):playcommand("Off")
								:sleep(0.85):queuecommand("TransitionBack")
	end


	-- truncate "PlayerNumber_P1" into "P1" and "PlayerNumber_P2" into "P2"
	local pn = ToEnumShortString(event.PlayerNumber)

	if event.type ~= "InputEventType_Release" then

		if event.button == "Start" then

			-- if we've reached the end of the list, don't wrap around
			if OptionRowWheels[pn]:get_info_at_focus_pos() == Rows[#Rows] then
				return false
			end

			OptionRowWheels[pn]:scroll_by_amount(1)

		elseif event.button == "Select" then
			OptionRowWheels[pn]:scroll_by_amount(-1)

		elseif event.button == "MenuLeft" or event.button == "MenuRight" then

			local row = OptionRowWheels[pn]:get_info_at_focus_pos()

			if event.button == "MenuLeft" then
				OptionRowWheels[pn][row]:scroll_by_amount(-1)
			elseif event.button == "MenuRight" then
				OptionRowWheels[pn][row]:scroll_by_amount(1)
			end

			if CustomOptionRow(row).ExportOnChange then
				CustomOptionRow(row):SaveSelections(CustomOptionRow(row):Choices() , event.PlayerNumber )
			end
		end
	end

	return false
end

---------------------------------------------------------------------
-- Primary ActorFrame and children
---------------------------------------------------------------------
local t = Def.ActorFrame{
	InitCommand=function(self)

		for player in ivalues( GAMESTATE:GetHumanPlayers() ) do
			local pn = ToEnumShortString(player)

			-- set_info_set() takes two arguments:
			--		a table of meaningful data to divvy up to wheel items
			--		the index of which item we want to initially give focus to
			OptionRowWheels[pn]:set_info_set(Rows, 1)

			for k2, Row in ipairs(Rows) do

				if Row ~= "Done" then
					local opt_row = CustomOptionRow( Row )
					local Choices =  opt_row:Choices()

					local focus = 1
					if SL[pn].ActiveModifiers[Row] then
						focus = FindInTable(SL[pn].ActiveModifiers[Row], Choices) or 1
					end
					OptionRowWheels[pn][Row]:set_info_set(Choices, focus)
				end
			end
		end

		-- queue the next command so that we can actually GetTopScreen()
		self:queuecommand("Capture")
	end,
	CaptureCommand=function(self)
		-- attach our InputHandler to the TopScreen and pass it this ActorFrame
		-- so we can manipulate stuff more easily from there
		SCREENMAN:GetTopScreen():AddInputCallback( InputHandler )
	end,
	OnCommand=function(self) self:sleep(0.15):queuecommand("StartMusic") end,
	StartMusicCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		local path = song:GetMusicPath()
		local preview_length = song:GetSampleLength()
		local preview_start = song:GetSampleStart()

		SOUND:PlayMusicPart(path, preview_start, preview_length, 0, 1, true, true, true)
	end,
	MusicRateChangedMessageCommand=function(self) SM("YO") end,
	TransitionBackCommand=function(self)
		SCREENMAN:GetTopScreen():PostScreenMessage("SM_GoToPrevScreen",0)
	end,

	Def.Quad{
		InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0) end,
		OffCommand=function(self) self:sleep(0.3):linear(0.55):diffusealpha(1) end
	}
}



-- Add noteskin actors to the primary AF and hide them immediately.
-- We'll refer to these later via ActorProxy in the NoteSkin row
for k,noteskin in ipairs( CustomOptionRow("NoteSkin").Choices() ) do
	t[#t+1] = NOTESKIN:LoadActorForNoteSkin("Up", "Tap Note", noteskin)..{
		Name="NoteSkin_"..noteskin,
		InitCommand=function(self) self:visible(false) end,
		GainFocusCommand=function(self) self:diffusealpha(1) end,
		LoseFocusCommand=function(self) self:diffusealpha(0.15) end
	}
end




-- add an OptionWheel for each available player
for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	local pn = ToEnumShortString(player)
	local x_pos = player == PLAYER_1 and _screen.cx-(_screen.w*160/640) or _screen.cx+(_screen.w*160/640)

	local OptionRow_mt = LoadActor("./OptionRowMT.lua", {NumRows=NumRowsToDraw, Player=player, Items=Rows, RowHeight=RowHeight})
	t[#t+1] = OptionRowWheels[pn]:create_actors( "OptionRowWheel"..pn, #Rows, OptionRow_mt, x_pos, 50)


	-- add an OptionRowWheel for each Option for each available player
	for k2, Row in ipairs(Rows) do
		local OptionRowChoice_mt = LoadActor("./OptionRowChoiceMT.lua", {NumRows=7, Player=player, Row=Row})

		x_pos = player == PLAYER_1 and _screen.cx-(_screen.w*160/640)+50 or _screen.cx+(_screen.w*160/640)-50

		local num_choices = 5
		if Row ~= "Done" then

			if CustomOptionRow( Row ).LayoutType == "ShowOneInRow" or #CustomOptionRow(Row).Choices() < num_choices-2 then
				num_choices = #CustomOptionRow(Row).Choices()
			end
		end

		t[#t+1] = OptionRowWheels[pn][Row]:create_actors( "OptionRowChoiceWheel"..ToEnumShortString(player), num_choices, OptionRowChoice_mt, x_pos, k2*35)
	end
end



---------------------------------------------------------------------
return t