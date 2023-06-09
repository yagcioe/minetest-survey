-- gamemode/init.lua

gamemode = {}

local gamemodes = {}
local aliases   = {}
local creative  = minetest.settings:get_bool("creative_mode")
local modpath   = minetest.get_modpath("gamemode")

---
--- Callbacks
---


-- [event] Override sfinv pages is_in_nav after all pages have been registered
minetest.after(0, function()
	for name, def in pairs(sfinv.pages) do
		local name_data = name:split(":")
		local old_is_in_nav = def.is_in_nav
		def.is_in_nav = function(self, player, context)
			local gm  = gamemode.get(player)
			local def = gamemode.def(gm)
			if gm and def then
				if def.pages then
					for _, p in pairs(def.pages) do
						if name == p then
							return true
						end
					end
				end

				if def.page_mods and name_data then
					local mod = name_data[1]
					for _, m in pairs(def.page_mods) do
						if mod == m then
							return true
						end
					end
				end
			else
				if old_is_in_nav then
					return old_is_in_nav(self, player, context)
				end
			end
		end
	end
end)

---
--- Redefinitions
---

local rotate_node = minetest.rotate_node
function minetest.rotate_node(itemstack, placer, pointed_thing)
	itemstack = rotate_node(itemstack, placer, pointed_thing)

	local mode = gamemode.def(gamemode.get(placer))
	if not mode.stack_unlimited then
		itemstack:take_item(1)
	end

	return itemstack
end

---
--- API
---

-- [function] Register gamemode
function gamemode.register(name, def)
	-- Register hand
	if def.hand then
		minetest.register_item("gamemode:"..name, {
			type = "none",
			wield_image = def.hand.wield_image or "wieldhand.png",
			wield_scale = {x = 1, y = 1, z = 2.5},
			range = def.hand.range,
			tool_capabilities = def.hand,
			on_use = def.hand.on_use,
		})

		def.hand = "gamemode:"..name
	end

	-- Save aliases
	if def.aliases then
		for _, a in pairs(def.aliases) do
			aliases[a] = name
		end
	end

	def.name = name
	gamemodes[name] = def
end

-- [function] Get gamemode definition
function gamemode.def(name)
	if gamemodes[name] then
		return gamemodes[name]
	else
		if aliases[name] then
			return gamemodes[aliases[name]]
		end
	end
end

-- [function] Set player gamemode
function gamemode.set(player, gm_name)
	local gm = gamemode.def(gm_name)
	if gm then
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)

		local old_gm = gamemode.def(gamemode.get(player))
		-- Revert HUD flags
		if old_gm.hud_flags then
			local flags = table.copy(old_gm.hud_flags)
			for _, f in pairs(flags) do
				flags[_] = not f
			end
			player:hud_set_flags(flags)
		end
		-- Revert privileges
		if old_gm.privileges then
			for _, i in pairs(old_gm.privileges) do
				privs[_] = not old_gm.privileges[_] or nil
			end
		end
		-- Check for on disable
		if old_gm.on_disable then
			old_gm.on_disable(player)
		end

		-- Update cache
		player:set_attribute("gamemode", gm_name)
		-- Update HUD flags
		if gm.hud_flags then
			player:hud_set_flags(gm.hud_flags)
		end
		-- Check for on enable
		if gm.on_enable then
			gm.on_enable(player)
		end
		-- Update privileges
		if gm.privileges then
			for _, i in pairs(gm.privileges) do
				privs[_] = gm.privileges[_] or nil
			end
		end
		-- Update hand
		if gm.hand then
			player:get_inventory():set_stack("hand", 1, gm.hand)
		else -- else, Reset hand
			player:get_inventory():set_stack("hand", 1, "")
		end
		-- Show/hide healthbar and breathbar
		player:hud_set_flags({
			healthbar = gm.damage ~= false,
			breathbar = gm.breath ~= false,
		})

		minetest.set_player_privs(name, privs) -- Update privileges

		-- Update sfinv
		sfinv.set_player_inventory_formspec(player)

		if sfinv.pages_unordered then
			sfinv.set_page(player, sfinv.pages_unordered[1].name)
		end

		return true
	end
end

-- [function] Get player gamemode
function gamemode.get(player)
	if type(player) == "string" then
		player = minetest.get_player_by_name(player)
	end

	local gm = player:get_attribute("gamemode")
	if not gm or gm == "" then
		if creative then gm = "creative"
		else gm = "survival" end
	end

	if not gamemode.def(gm) then
		return "survival"
	end

	return gm
end

-- [function] Can interact
function gamemode.can_interact(player)
	local mode = gamemode.def(gamemode.get(player))
	if mode.privileges and mode.privileges.interact == false then
		return false
	end

	return true
end

---
--- Chatcommand
---

-- [privelege] Gamemode
minetest.register_privilege("gamemode", "Ability to use /gamemode")

-- [command] Gamemode
minetest.register_chatcommand("gamemode", {
	description = "Change gamemode (providing no gamemode parameter returns "..
			"the player's gamemode)",
	params = "(<player name>) [<gamemode> | list]",
	privs = {gamemode=true},
	func = function(name, param)
		local params = param:split(" ")
		local player = minetest.get_player_by_name(name)
		local newgm

		if params and #params == 1 then
			if params[1] == "list" then
				local list = ""
				for name, gm in pairs(gamemodes) do
					list = list..name..": "..gm.caption

					if gm.aliases then
						list = list.." (aliases: "..table.concat(gm.aliases, ", ")..")"
					end

					list = list.."\n"
				end

				list = list:sub(1, -3) -- Remove final "\n"

				return true, list
			else
				if gamemode.def(params[1]) then
					newgm = params[1]
				else
					if minetest.get_player_by_name(params[1]) then
						local gm = gamemode.get(params[1])
						if gm then
							return true, params[1].."'s gamemode is set to "..
									gamemode.def(gm).caption:lower()
						end
					else
						return false, "Invalid player or gamemode "..dump(params[1])
					end
				end
			end
		elseif params and #params == 2 then
			player = minetest.get_player_by_name(params[1])
			newgm  = params[2]
		else
			local gm = gamemode.get(name)
			if gm then
				return true, "Your gamemode is set to "..gamemode.def(gm).caption:lower()
			else
				return false, "Invalid usage (see /help gamemode)"
			end
		end

		if not player then
			return false, "Invalid player "..dump(params[1])
		end

		-- Set gamemode
		if newgm and gamemode.set(player, newgm) then
			return true, "Set "..player:get_player_name().."'s gamemode to "..
					gamemode.def(newgm).caption:lower()
		else -- else, Return invalid gamemode
			return false, "Invalid gamemode "..dump(newgm)
		end
	end,
})

---
--- Load Gamemodes
---

dofile(modpath.."/modes.lua")
