local args = ...
local NumRows = args.NumRows
local player = args.Player
local AllItems = args.Items
local RowHeight = args.RowHeight

-- the metatable for a single option in any given OptionRow
local OptionRow_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=self.name,
				InitCommand=function(subself)
					self.container = subself
					subself:diffusealpha(0)
				end,
				OnCommand=function(subself)
					subself:y(RowHeight * self.index + 2)
						:sleep(0.04 * self.index)
						:linear(0.2):diffusealpha(1)
				end,
				OffCommand=function(subself)
					subself:sleep(0.04 * self.index)
						:linear(0.2):diffusealpha(0)
				end,
			}

			af[#af+1] = Def.Quad{
				InitCommand=function(subself)
					self.BGQuad = subself
					subself:zoomto(_screen.w/2 - 40, RowHeight-2)
				end,

			}

			af[#af+1] = Def.Quad{
				InitCommand=function(subself)
					self.TitleQuad = subself
					subself:diffuse(0,0,0,1)
					local x_pos = player == PLAYER_1 and -142 or 142
					subself:zoomto(_screen.w/6 - 40, RowHeight-2):x(x_pos)
				end,

			}


			af[#af+1] = Def.BitmapText{
				Font="Common normal",
				InitCommand=function(subself)
					self.bmt = subself
					local align = player == PLAYER_1 and right or left
					local x_pos = player == PLAYER_1 and -100 or 100
					subself:zoom(0.9):horizalign(align):x(x_pos)
				end,
			}

			return af
		end,


		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()
			self.container:linear(0.2)

			if has_focus then
				self.BGQuad:diffuse(color("#4b545a")):diffusealpha(0.66)
				self.TitleQuad:diffusealpha(0.5)
				self.bmt:diffuse( PlayerColor(player) ):diffusealpha(1)
			else
				self.BGQuad:diffuse(color("#071016")):diffusealpha(0.6)
				self.TitleQuad:diffusealpha(0.1)
				self.bmt:diffuse(Color.White):diffusealpha(0.5)
			end
		end,


		set = function(self, optionrow)
			if not optionrow then return end
			self.optionrow = optionrow
			self.index = FindInTable( optionrow, AllItems ) or 1
			local text = THEME:GetString( "OptionTitles", optionrow )
			self.bmt:settext(text)
		end
	}
}

return OptionRow_mt