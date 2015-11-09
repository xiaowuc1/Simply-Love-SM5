local args = ...
local NumRows = args.NumRows
local player = args.Player
local Row = args.Row

-- the metatable for an optionrow choice
local optionrow_choice_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			local af = Def.ActorFrame{
				Name=self.name,
				InitCommand=function(subself)
					self.container = subself
				end,
				OffCommand=function(subself)
					subself:linear(0.2):diffusealpha(0)
				end,

			}

			if Row == "JudgmentGraphic" then
				af[#af+1] = Def.Sprite{
					InitCommand=function(subself)
						self.actor = subself
						subself:zoom(0.4):y(46)
					end
				}
			end

			if Row == "NoteSkin" then
				af[#af+1] = Def.ActorProxy{
					InitCommand=function(subself)
						self.actorproxy = subself
						subself:zoom(0.35):y(46):visible(true)
					end,
					BeginCommand=function(subself)
						subself:SetTarget( SCREENMAN:GetTopScreen():GetChild("Overlay"):GetChild("NoteSkin_"..self.choice) )
					end
				}
			end


			af[#af+1] = Def.BitmapText{
				Font="Common normal",
				InitCommand=function(subself)
					self.bmt = subself

					subself:diffuse(Color.White)
					if Row == "JudgmentGraphic" or Row == "NoteSkin" then
						subself:y(60):zoom(0.6)
					else
						subself:y(50):zoom(0.75)
					end
				end,
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)
			self.container:finishtweening()
			self.container:linear(0.2)
			self.index=item_index

			local OffsetFromCenter = (item_index - math.floor(num_items/2))-1
			local x_padding = 80
			local x = x_padding * OffsetFromCenter
			-- local z = -1.25 * math.abs(OffsetFromCenter)
			-- local zoom = (z + math.floor(num_items/2) + 1) * 1.75


			if item_index <= 1 or item_index >= num_items then
				self.container:diffusealpha(0)
			else
				if has_focus then
					self.container:diffuse( Color.White ):diffusealpha(1)

					if Row == "NoteSkin" and self.actorproxy:GetTarget() then
						self.actorproxy:GetTarget():playcommand("GainFocus")
					end
				else
					self.container:diffuse( color("#888888") ):diffusealpha(0.33)

					if Row == "NoteSkin" and self.actorproxy:GetTarget() then
						self.actorproxy:GetTarget():playcommand("LoseFocus")
					end
				end
			end


			self.container:x(x)
			self.bmt:settext( self.choice )

		end,

		set = function(self, choice)
			if not choice then return end
			self.choice = choice

			if Row == "JudgmentGraphic" then

				if choice == "3.9" then choice = "_judgments/3_9"
				elseif choice == "None" then choice = "_blank.png"
				else choice = "_judgments/" .. choice
				end

				self.actor:Load( THEME:GetPathG("", choice ) )
				self.actor:setstate(0)
				self.actor:animate(false)
			end

			if Row == "NoteSkin" then
				self.actorproxy:playcommand("Begin")
			end
		end
	}
}

return optionrow_choice_mt