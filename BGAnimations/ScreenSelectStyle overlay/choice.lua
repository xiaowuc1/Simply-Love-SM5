local args = ...
local choiceName = args[1].name
local pads = args[1].pads
local index = args[2]


local yshift = WideScale(54,78)
local zoomFactor = WideScale(0.435,0.525)
local gameName = GAMESTATE:GetCurrentGame():GetName()

local drawNinePanelPad = function(color, xoffset)

	return Def.ActorFrame {

		InitCommand=cmd(x, xoffset; y, -yshift),

		-- first row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth())
				self:y(zoomFactor * self:GetHeight())

				if gameName == "pump" or gameName == "techno" or gameName == "dance" and choiceName == "solo" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 2)
				self:y(zoomFactor * self:GetHeight())

				if gameName == "dance" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 3)
				self:y(zoomFactor * self:GetHeight())

				if gameName == "pump" or gameName == "techno" or gameName == "dance" and choiceName == "solo" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},


		-- second row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth())
				self:y(zoomFactor * self:GetHeight() * 2)

				if gameName == "dance" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 2)
				self:y(zoomFactor * self:GetHeight() * 2)

				if gameName == "pump" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 3)
				self:y(zoomFactor * self:GetHeight() * 2)

				if gameName == "dance" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},



		-- third row
		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth())
				self:y(zoomFactor * self:GetHeight() * 3)

				if gameName == "pump" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 2)
				self:y(zoomFactor * self:GetHeight() * 3)

				if gameName == "dance" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		},

		LoadActor("rounded-square.png")..{
			InitCommand=function(self)
				self:zoom(zoomFactor)
				self:x(zoomFactor * self:GetWidth() * 3)
				self:y(zoomFactor * self:GetHeight() * 3)

				if gameName == "pump" or gameName == "techno" then
					self:diffuse(DifficultyIndexColor(color))
				else
					self:diffuse(0.2,0.2,0.2,1)
				end
			end
		}
	}
end



local af = Def.ActorFrame{
	Enabled = false,
	InitCommand=function(self)
		-- self.container = self
		self:zoom(0.5):xy( args[1].x, _screen.cy )

		if ThemePrefs.Get("VisualTheme")=="Gay" then
			self:bob():effectmagnitude(0,0,0):effectclock('bgm'):effectperiod(0.666)
		end
	end,
	OnCommand=function(self)
		-- self:finishtweening()
		-- if self.index == wheel:get_actor_item_at_focus_pos().index then
		-- 	self:zoom(1)
		-- end
		-- self.bmt:settext(self.index)
	end,
	OffCommand=function(self)
		self:sleep(0.04 * index)
		self:linear(0.2)
		self:diffusealpha(0)
	end,
	GainFocusCommand=function(self)
		self:linear(0.125):zoom(1)
		if ThemePrefs.Get("VisualTheme")=="Gay" then
			self:effectmagnitude(0,4,0)
		end
	end,
	LoseFocusCommand=function(self)
		self:linear(0.125):zoom(0.5):effectmagnitude(0,0,0)
	end,
	EnableCommand=function(self)
		if self.Enabled then
			self:diffusealpha(1)
		else
			self:diffusealpha(0.25)
		end
	 end,

	LoadFont("_wendy small")..{
		Text=THEME:GetString("ScreenSelectStyle", choiceName:gsub("^%l", string.upper)),
		InitCommand=function(self)
			self:shadowlength(1):y(60):zoom(0.5)
		end,
	}
}


if choiceName == "single" then -- 1 Player
	af[#af+1] = drawNinePanelPad(pads[1][1], pads[1][2])..{
		OffCommand=cmd(linear,0.2; diffusealpha,0)
	}

elseif choiceName == "versus" then -- 2 Players
	af[#af+1] = drawNinePanelPad(pads[1][1],pads[1][2])..{
		OffCommand=cmd(sleep,0.12; linear,0.2; diffusealpha,0)
	}
	af[#af+1] = drawNinePanelPad(pads[2][1], pads[2][2])..{
		OffCommand=cmd(sleep,0.24; linear,0.2; diffusealpha,0)
	}

elseif choiceName == "double" then -- Double
	af[#af+1] = drawNinePanelPad(pads[1][1],pads[1][2])..{
		OffCommand=cmd(sleep,0.36; linear,0.2; diffusealpha,0)
	}
	af[#af+1] = drawNinePanelPad(pads[2][1], pads[2][2])..{
		OffCommand=cmd(sleep,0.48; linear,0.2; diffusealpha,0)
	}

elseif choiceName == "solo" then -- Solo
	af[#af+1] = drawNinePanelPad(pads[1][1], pads[1][2])..{
		OffCommand=cmd(linear,0.2; diffusealpha,0)
	}

end

return af