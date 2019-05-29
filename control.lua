local debug = false

local function log(str)
  if debug then
    game.print("[Enhanced Pipette] " .. str)
  end
end

script.on_event(defines.events.on_player_pipette, function(ev)
  local player = game.players[ev.player_index]

  log("Player " .. ev.player_index .. " used pipette")

  if player.selected then
    if not player.selected.valid then
      log("Player has invalid entity selected")
    end

    if not global.pipette then global.pipette = {} end
    global.pipette[ev.player_index] = {}
    global.pipette[ev.player_index].entity = player.selected
    global.pipette[ev.player_index].item = ev.item
    log("Stored valid entity " .. player.selected.unit_number .. " on player")
  end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(ev)
  local player = game.players[ev.player_index]

  if not global.pipette or not global.pipette[ev.player_index] then return end
  local item = global.pipette[ev.player_index].item

  if player.cursor_stack then 
    if not player.cursor_stack.valid_for_read then
      log("Cleared stored pipette for player " .. ev.player_index)
      log("Player cursor is now empty")
      global.pipette[ev.player_index] = nil
      return
    end
    if player.cursor_stack.prototype ~= item then
      log("Cleared stored pipette for player " .. ev.player_index)
      log("Stored prototype was for " .. item.name .. " but player cursor now contains " .. player.cursor_stack.name)
      global.pipette[ev.player_index] = nil
      return
    end
  end

  if player.cursor_ghost and player.cursor_ghost ~= item then
    log("Cleared stored pipette for player " .. ev.player_index)
    log("Stored prototype was for " .. item.name .. " but player cursor now contains ghost of " .. player.cursor_ghost.name)
    global.pipette[ev.player_index] = nil
  end
end)

script.on_event(defines.events.on_put_item, function(ev)
  if not global.over_ghost then global.over_ghost = {} end
  if game.players[ev.player_index].selected then
    log("Player " .. ev.player_index .. " about to build over something")
    global.over_ghost[ev.player_index] = true
  else
    log("Player " .. ev.player_index .. " about to build over nothing")
    global.over_ghost[ev.player_index] = nil
  end
end)

script.on_event(defines.events.on_built_entity, function(ev)
  if global.over_ghost and global.over_ghost[ev.player_index] then
    log("Player " .. ev.player_index .. " built, but replaced something, so ignoring")
    return
  end
  
  if not global.pipette or not global.pipette[ev.player_index] or not global.pipette[ev.player_index].entity then
    log("Player " .. ev.player_index .. " built, but nothing stored on player")
    return
  end

  if not global.pipette[ev.player_index].entity.valid then
    log("Player " .. ev.player_index .. " built, but entity stored on player is not valid")
    return
  end

  local entity = global.pipette[ev.player_index].entity

  ev.created_entity.copy_settings(entity)
  log("Copied settings for entity built by player" .. ev.player_index)
end)

