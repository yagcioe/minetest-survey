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


local function tut1(name)
    local player_info = minetest.get_player_information(name)

    local news_formspec = "formspec_version[5]" ..
        "size[25, 15]" ..
        "noprepend[]" ..
        "bgcolor[" .. colors.background_color .. "]" ..
        "button_exit[21.8, 13.8; 3, 1;exit; OK]" 

    local news_filename = minetest.get_worldpath() .. "/news/tut1.md"
    local news_file = io.open(news_filename, "r")
    local news_markdown = news_file:read("*a")
    news_file:close()

    news_formspec = news_formspec .. md2f.md2f(0.2, 0.2, 24.8, 13.4, news_markdown, "server_news", colors)

    -- Gotta log 'em all!
    minetest.show_formspec(name, "server_news", news_formspec)
    
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

local function tut2(name)
    local player_info = minetest.get_player_information(name)

    local news_formspec = "formspec_version[5]" ..
        "size[25, 15]" ..
        "noprepend[]" ..
        "bgcolor[" .. colors.background_color .. "]" ..
        "button_exit[21.8, 13.8; 3, 1;exit; OK]" 
        
    local news_filename = minetest.get_worldpath() .. "/news/tut2.md"
    local news_file = io.open(news_filename, "r")
    local news_markdown = news_file:read("*a")
    news_file:close()

    news_formspec = news_formspec .. md2f.md2f(0.2, 0.2, 24.8, 13.4, news_markdown, "server_news", colors)

    -- Gotta log 'em all!
    minetest.show_formspec(name, "server_news", news_formspec)
    
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

local function tut3(name)
    local player_info = minetest.get_player_information(name)

    local news_formspec = "formspec_version[5]" ..
        "size[25, 15]" ..
        "noprepend[]" ..
        "bgcolor[" .. colors.background_color .. "]" ..
        "button_exit[21.8, 13.8; 3, 1;exit; OK]" 

    local news_filename = minetest.get_worldpath() .. "/news/tut3.md"
    local news_file = io.open(news_filename, "r")
    local news_markdown = news_file:read("*a")
    news_file:close()

    news_formspec = news_formspec .. md2f.md2f(0.2, 0.2, 24.8, 13.4, news_markdown, "server_news", colors)

    -- Gotta log 'em all!
    minetest.show_formspec(name, "server_news", news_formspec)
    
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


minetest.register_chatcommand("tut1", {
    params = S("[<name>]"),
    description = "Shows the servers tut1",
    func = tut1
})

minetest.register_chatcommand("tut2", {
    params = S("[<name>]"),
    description = "Shows the servers tut2",
    func = tut2
})

minetest.register_chatcommand("tut3", {
    params = S("[<name>]"),
    description = "Shows the servers tut3",
    func = tut3
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
