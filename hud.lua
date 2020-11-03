local client_latency, math_floor, renderer_measure_text, renderer_rectangle, renderer_text, string_format = client.latency, math.floor, renderer.measure_text, renderer.rectangle, renderer.text, string.format
local localPlayer = entity.get_local_player();
local playerResource = entity.get_player_resource();
local scrW, scrH = client.screen_size();
local csgo_weapons = require "gamesense/csgo_weapons"
local images = require "gamesense/images"
local js = panorama.open()
local GameStateAPI = js.GameStateAPI
local chatMSG = {};
local avatars = {};

ui.new_label("LUA", "B", "-+-+-+-+ [ Onion's HUD LUA ] +-+-+-+-")
local onion_enabled = ui.new_checkbox("LUA", "B", "Enabled")
local color = ui.new_color_picker("LUA", "B", "Healthbar Color", 3, 136, 252, 100);
local chatboxOffset = ui.new_slider("LUA", "B", "Side Offset", 20, 200, 20)
local chatboxTopOffset = ui.new_slider("LUA", "B", "Top Offset", 0, 1080, 900)

client.set_event_callback("paint", function()
    if (ui.get(onion_enabled)) then
        cvar.cl_draw_only_deathnotices:set_int(1)
        cvar.cl_drawhud_force_radar:set_int(1)
        -- Textbox
        local offset = ui.get(chatboxOffset);
        local offsetY = ui.get(chatboxTopOffset);
        renderer_rectangle(offset, offsetY, 300, 2, ui.get(color));
        renderer_rectangle(offset, 2 + offsetY, 300, 16, 20, 20, 20, 100);
        renderer_text(155 + offset, 10 + offsetY, 255, 255, 255, 255, "c", 0, "Chatbox")

        if (#chatMSG ~= nil) then
            if (#chatMSG > 0) then
                for i = 1, #chatMSG do
                    renderer_rectangle(offset, 22 + (20 * (i - 1)) + offsetY, 2, 16, ui.get(color))
                    renderer_rectangle(2 + offset, 22 + (20 * (i - 1)) + offsetY, 84, 16, 20, 20, 20, 100)
                    renderer_rectangle(90 + offset, 22 + (20 * (i - 1)) + offsetY, 210, 16, 20, 20, 20, 100)
                    renderer_text(195 + offset, (22 + (20 * (i - 1))) + 8 + offsetY, 255, 255, 255, 255, "c", 202, chatMSG[i][2])
                    local index;

                    for f = 1, #avatars do
                        if (avatars[f][1] == chatMSG[i][3]) then
                            index = f;
                        end
                    end

                    if (index == nil) then
                        table.insert(avatars, {chatMSG[i][3], images.get_steam_avatar(chatMSG[i][3])});
                        index = #chatMSG;
                    end

                    if (chatMSG[i][4] == 2) then -- T Side
                        renderer_text(44 + offset, (22 + (20 * (i - 1))) + 8 + offsetY, 255, 114, 43, 255, "c", 71, chatMSG[i][1])
                    elseif (chatMSG[i][4] == 3) then -- CT Side
                        renderer_text(44 + offset, (22 + (20 * (i - 1))) + 8 + offsetY, 43, 223, 255, 255, "c", 71, chatMSG[i][1])
                    else -- Spectators
                        renderer_text(44 + offset, (22 + (20 * (i - 1))) + 8 + offsetY, 200, 200, 200, 255, "c", 71, chatMSG[i][1])
                    end

                    if ( avatars[index][2] ~= nil) then
                        avatars[index][2]:draw(offset - 20, 22 + (20 * (i - 1)) + offsetY, 16, 16, 255, 255, 255, 255, false, 'f')
                    end
                end
            end
        end

        localPlayer = entity.get_local_player();
        if localPlayer == nil then return end

        local plyHealth = entity.get_prop(localPlayer, "m_iHealth");
        if plyHealth ~= nil then
            -- Health Bar
            local tW, tH = renderer_measure_text("c", "100 hp")
            if (plyHealth > 100) then plyHealth = 100 end
            renderer_rectangle(20, scrH - 44, 150 + 20 + tW, 2, ui.get(color));
            renderer_rectangle(20, scrH - 42, 150 + 20 + tW, 16, 20, 20, 20, 100);
            renderer_rectangle(27, scrH - 35, 150, 2, 20, 20, 20, 255);
            renderer_rectangle(27, scrH - 35, 150 * (plyHealth / 100), 2, ui.get(color));
            renderer_text(184 + (tW / 2), scrH - 35, 255, 255, 255, 255, "c", 0, plyHealth .. " hp")
        end

        local weaponEnt = entity.get_player_weapon(localPlayer)
        if weaponEnt == nil then return end
        
        local weaponIDx = entity.get_prop(weaponEnt, "m_iItemDefinitionIndex")
        if weaponIDx == nil then return end
        
        local curAmmo = entity.get_prop(weaponEnt, "m_iClip1")
        if curAmmo == nil then curAmmo = 0; end

        local weapon = csgo_weapons[weaponIDx]
        if weapon ~= nil then
            -- Weapon List
            local tW, tH = renderer_measure_text("c", weapon.name .. ", " .. curAmmo .. "/" .. weapon.primary_clip_size)
            if (curAmmo > weapon.primary_clip_size) then curAmmo = weapon.primary_clip_size end
            renderer_rectangle(scrW - ((150 + 20 + tW) + (20)), scrH - 44, 150 + 20 + tW, 2, ui.get(color));
            renderer_rectangle(scrW - ((150 + 20 + tW) + (20)), scrH - 42, 150 + 20 + tW, 16, 20, 20, 20, 100);
            renderer_rectangle(scrW - ((150 + 20 + tW) + (13)), scrH - 35, 150, 2, 20, 20, 20, 255);
            renderer_rectangle(scrW - ((150 + 20 + tW) + (13)), scrH - 35, 150 * (curAmmo / weapon.primary_clip_size), 2, ui.get(color));
            renderer_text(scrW - (27 + (tW / 2)), scrH - 35, 255, 255, 255, 255, "c", 0, weapon.name .. ", " .. curAmmo .. "/" .. weapon.primary_clip_size)
        end
    else
        cvar.cl_draw_only_deathnotices:set_int(0)
        cvar.cl_drawhud_force_radar:set_int(0)
    end
end)

client.set_event_callback("player_chat", function(e)
    if e.entity == nil then return end
    local steamid = entity.get_steam64(e.entity);
    local teamNum = entity.get_prop(playerResource, "m_iTeam", e.entity);
    if (e.name == nil or e.text == nil or e.name == "" or e.text == "" or steamid == "" or steamid == nil or teamNum == nil) then return end

    if (#chatMSG < 6) then
        table.insert(chatMSG, {e.name, e.text, steamid, teamNum})
    else
        table.remove(chatMSG, 1);
        table.insert(chatMSG, {e.name, e.text, steamid, teamNum})
    end
end)
