local storage = minetest.get_mod_storage()
local prefix = "newsOnJoinExceptions_"
local S = core.get_translator("__builtin")
local colors = {
    background_color = "#FFF0",
    font_color = "#FFF",
    heading_1_color = "#FFFFFF",
    heading_2_color = "#FAA",
    heading_3_color = "#AAF",
    heading_4_color = "#FFA",
    heading_5_color = "#AFF",
    heading_6_color = "#FAF",
    heading_1_size = "80",
    heading_2_size = "24",
    heading_3_size = "22",
    heading_4_size = "20",
    heading_5_size = "18",
    heading_6_size = "16",
    code_block_mono_color = "#6F6",
    code_block_font_size = 14,
    mono_color = "#6F6",
    block_quote_color = "#FFA",
}

    


minetest.register_chatcommand("show", {
    params = "<playername> <filename>",
    description = S("Shows the servers <filename> to <name>"),
    func = function(name, param)
        local found, _, target, filename = param:find("^([^%s]+)%s+(.*)$")
        if found == nil then
			minetest.chat_send_player(name, "Invalid usage: " .. param)
			return
		end
		if not minetest.get_player_by_name(target) then
			minetest.chat_send_player(name, "Invalid target: " .. target)
		end
        local news_formspec = "formspec_version[5]" ..
            "size[25, 15]" ..
            "noprepend[]" ..
            "bgcolor[" .. colors.background_color .. "]" ..
            "button_exit[21.8, 13.8; 3, 1;exit; OK]"

        local news_filename = minetest.get_worldpath() .. "/news/" .. filename .. ".md"
        local news_file = io.open(news_filename, "r")
        if news_file == nil then
			minetest.chat_send_player(name, "File doesn´t exist. ")
			return
		end
        local news_markdown = news_file:read("*a")
        news_file:close()

        news_formspec = news_formspec .. md2f.md2f(0.2, 0.2, 24.8, 13.4, news_markdown, "server_news", colors)

        minetest.show_formspec(target, "server_news", news_formspec)
    
        minetest.register_on_player_receive_fields(function(player, formname, fields)
            name = player:get_player_name()

            -- Don't do anything when the exit button is clicked, because no checkbox data is sent then
            if not fields.exit then
                if (fields.dont_show_again == "true") then
                storage:set_int(prefix .. name, 1)
              else
                    storage:set_int(prefix .. name, 0)
             end

                minetest.log("action", "Toggled newsOnJoinExceptions_" .. name .. " to " .. tostring(storage:get_int(prefix .. name)))
         end
     end)
    end
})
minetest.register_chatcommand("toggle_news", {
    description = "Toggles showing the news to you when you log in",
    func = function(name)
        local current_state = storage:get_int(prefix .. name)

        if (current_state == 0) then
            storage:set_int(prefix .. name, 1)
            minetest.chat_send_player(name, minetest.colorize("green", "You will no longer see automatic news"))

            minetest.log("action", name .. " disabled automatic news")
        else
            storage:set_int(prefix .. name, 0)
            minetest.chat_send_player(name, minetest.colorize("green", "You will now see automatic news"))

            minetest.log("action", name .. " enabled automatic news")
        end
    end
})
