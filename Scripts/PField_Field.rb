#===============================================================================
# This module stores encounter-modifying events that can happen during the game.
# A procedure can subscribe to an event by adding itself to the event. It will
# then be called whenever the event occurs.
#===============================================================================
module EncounterModifier
  @@procs    = []
  @@procsEnd = []

  def self.register(p)
    @@procs.push(p)
  end

  def self.registerEncounterEnd(p)
    @@procsEnd.push(p)
  end

  def self.trigger(encounter)
    for prc in @@procs
      encounter = prc.call(encounter)
    end
    return encounter
  end

  def self.triggerEncounterEnd()
    for prc in @@procsEnd
      prc.call()
    end
  end
end



#===============================================================================
# This module stores events that can happen during the game. A procedure can
# subscribe to an event by adding itself to the event. It will then be called
# whenever the event occurs.
#===============================================================================
module Events
  @@OnMapCreate                 = Event.new
  @@OnMapUpdate                 = Event.new
  @@OnMapChange                 = Event.new
  @@OnMapChanging               = Event.new
  @@OnMapSceneChange            = Event.new
  @@OnSpritesetCreate           = Event.new
  @@OnAction                    = Event.new
  @@OnStepTaken                 = Event.new
  @@OnLeaveTile                 = Event.new
  @@OnStepTakenFieldMovement    = Event.new
  @@OnStepTakenTransferPossible = Event.new
  @@OnStartBattle               = Event.new
  @@OnEndBattle                 = Event.new
  @@OnWildPokemonCreate         = Event.new
  @@OnWildBattleOverride        = Event.new
  @@OnWildBattleEnd             = Event.new
  @@OnTrainerPartyLoad          = Event.new

  # Fires whenever a map is created. Event handler receives two parameters: the
  # map (RPG::Map) and the tileset (RPG::Tileset)
  def self.onMapCreate; @@OnMapCreate; end
  def self.onMapCreate=(v); @@OnMapCreate = v; end

  # Fires each frame during a map update.
  def self.onMapUpdate; @@OnMapUpdate; end
  def self.onMapUpdate=(v); @@OnMapUpdate = v; end

  # Fires whenever one map is about to change to a different one. Event handler
  # receives the new map ID and the Game_Map object representing the new map.
  # When the event handler is called, $game_map still refers to the old map.
  def self.onMapChanging; @@OnMapChanging; end
  def self.onMapChanging=(v); @@OnMapChanging = v; end

  # Fires whenever the player moves to a new map. Event handler receives the old
  # map ID or 0 if none. Also fires when the first map of the game is loaded
  def self.onMapChange; @@OnMapChange; end
  def self.onMapChange=(v); @@OnMapChange = v; end

  # Fires whenever the map scene is regenerated and soon after the player moves
  # to a new map.
  # Parameters:
  # e[0] - Scene_Map object.
  # e[1] - Whether the player just moved to a new map (either true or false). If
  #        false, some other code had called $scene.createSpritesets to
  #        regenerate the map scene without transferring the player elsewhere
  def self.onMapSceneChange; @@OnMapSceneChange; end
  def self.onMapSceneChange=(v); @@OnMapSceneChange = v; end

  # Fires whenever a spriteset is created.
  # Parameters:
  # e[0] - Spriteset being created. e[0].map is the map associated with the
  #        spriteset (not necessarily the current map).
  # e[1] - Viewport used for tilemap and characters
  def self.onSpritesetCreate; @@OnSpritesetCreate; end
  def self.onSpritesetCreate=(v); @@OnSpritesetCreate = v; end

  # Triggers when the player presses the Action button on the map.
  def self.onAction; @@OnAction; end
  def self.onAction=(v); @@OnAction = v; end

  # Fires whenever the player takes a step.
  def self.onStepTaken; @@OnStepTaken; end
  def self.onStepTaken=(v); @@OnStepTaken = v; end

  # Fires whenever the player or another event leaves a tile.
  # Parameters:
  # e[0] - Event that just left the tile.
  # e[1] - Map ID where the tile is located (not necessarily
  #        the current map). Use "$MapFactory.getMap(e[1])" to
  #        get the Game_Map object corresponding to that map.
  # e[2] - X-coordinate of the tile
  # e[3] - Y-coordinate of the tile
  def self.onLeaveTile; @@OnLeaveTile; end
  def self.onLeaveTile=(v); @@OnLeaveTile = v; end

  # Fires whenever the player or another event enters a tile.
  # Parameters:
  # e[0] - Event that just entered a tile.
  def self.onStepTakenFieldMovement; @@OnStepTakenFieldMovement; end
  def self.onStepTakenFieldMovement=(v); @@OnStepTakenFieldMovement = v; end

  # Fires whenever the player takes a step. The event handler may possibly move
  # the player elsewhere.
  # Parameters:
  # e[0] - Array that contains a single boolean value. If an event handler moves
  #        the player to a new map, it should set this value to true. Other
  #        event handlers should check this parameter's value.
  def self.onStepTakenTransferPossible; @@OnStepTakenTransferPossible; end
  def self.onStepTakenTransferPossible=(v); @@OnStepTakenTransferPossible = v; end

  def self.onStartBattle; @@OnStartBattle; end
  def self.onStartBattle=(v); @@OnStartBattle = v; end

  def self.onEndBattle; @@OnEndBattle; end
  def self.onEndBattle=(v); @@OnEndBattle = v; end

  # Triggers whenever a wild Pokémon is created
  # Parameters: 
  # e[0] - Pokémon being created
  def self.onWildPokemonCreate; @@OnWildPokemonCreate; end
  def self.onWildPokemonCreate=(v); @@OnWildPokemonCreate = v; end

  # Triggers at the start of a wild battle.  Event handlers can provide their
  # own wild battle routines to override the default behavior.
  def self.onWildBattleOverride; @@OnWildBattleOverride; end
  def self.onWildBattleOverride=(v); @@OnWildBattleOverride = v; end

  # Triggers whenever a wild Pokémon battle ends
  # Parameters: 
  # e[0] - Pokémon species
  # e[1] - Pokémon level
  # e[2] - Battle result (1-win, 2-loss, 3-escaped, 4-caught, 5-draw)
  def self.onWildBattleEnd; @@OnWildBattleEnd; end
  def self.onWildBattleEnd=(v); @@OnWildBattleEnd = v; end

  # Triggers whenever an NPC trainer's Pokémon party is loaded
  # Parameters: 
  # e[0] - Trainer
  # e[1] - Items possessed by the trainer
  # e[2] - Party
  def self.onTrainerPartyLoad; @@OnTrainerPartyLoad; end
  def self.onTrainerPartyLoad=(v); @@OnTrainerPartyLoad = v; end
end



def Kernel.pbOnSpritesetCreate(spriteset,viewport)
  Events.onSpritesetCreate.trigger(nil,spriteset,viewport)
end



#===============================================================================
# Constant checks
#===============================================================================
# Pokérus check
Events.onMapUpdate+=proc {|sender,e|
  last = $PokemonGlobal.pokerusTime
  now = pbGetTimeNow
  if !last || last.year!=now.year || last.month!=now.month || last.day!=now.day
    if $Trainer
      for i in $Trainer.pokemonParty
        i.lowerPokerusCount
      end
      $PokemonGlobal.pokerusTime = now
    end
  end
}

# Returns whether the Poké Center should explain Pokérus to the player, if a
# healed Pokémon has it.
def Kernel.pbPokerus?
  return false if $game_switches[SEEN_POKERUS_SWITCH]
  for i in $Trainer.party
    return true if i.pokerusStage==1
  end
  return false
end



class PokemonTemp
  attr_accessor :batterywarning
  attr_accessor :cueBGM
  attr_accessor :cueFrames
end



def pbBatteryLow?
  power="\0"*12
  begin
    sps=Win32API.new('kernel32.dll','GetSystemPowerStatus','p','l')
  rescue
    return false
  end
  if sps.call(power)==1
    status=power.unpack("CCCCVV")
    # AC line presence
    return false if status[0]!=0 # Not plugged in or unknown
    # Battery Flag
    return true if status[1]==4 # Critical (<5%)
    # Battery Life Percent
    return true if status[2]<3 # Less than 3 percent
    # Battery Life Time
    return true if status[4]>0 && status[4]<300 # Less than 5 minutes and unplugged
  end
  return false
end

Events.onMapUpdate+=proc {|sender,e|
  if !$PokemonTemp.batterywarning && pbBatteryLow?
    if $Trainer && $PokemonGlobal && $game_player && $game_map &&
       !$game_temp.in_menu && !$game_temp.in_battle &&
       !$game_player.move_route_forcing && !$game_temp.message_window_showing &&
       !pbMapInterpreterRunning?
      if pbGetTimeNow.sec==0
        Kernel.pbMessage(_INTL("The game has detected that the battery is low. You should save soon to avoid losing your progress."))
        $PokemonTemp.batterywarning = true
      end
    end
  end
  if $PokemonTemp.cueFrames
    $PokemonTemp.cueFrames -= 1
    if $PokemonTemp.cueFrames<=0
      $PokemonTemp.cueFrames = nil
      if $game_system.getPlayingBGM==nil
        pbBGMPlay($PokemonTemp.cueBGM)
      end
    end
  end
}



#===============================================================================
# Checks per step
#===============================================================================
# Party Pokémon gain happiness from walking
Events.onStepTaken+=proc {
  $PokemonGlobal.happinessSteps = 0 if !$PokemonGlobal.happinessSteps
  $PokemonGlobal.happinessSteps += 1
  if $PokemonGlobal.happinessSteps>=128
    for pkmn in $Trainer.ablePokemonParty
      pkmn.changeHappiness("walking") if rand(2)==0
    end
    $PokemonGlobal.happinessSteps = 0
  end
}

# Poison party Pokémon
Events.onStepTakenTransferPossible+=proc {|sender,e|
  handled = e[0]
  next if handled[0]
  if $PokemonGlobal.stepcount%4==0 && POISONINFIELD
    flashed = false
    for i in $Trainer.ablePokemonParty
      if i.status==PBStatuses::POISON && !isConst?(i.ability,PBAbilities,:IMMUNITY)
        if !flashed
          $game_screen.start_flash(Color.new(255,0,0,128), 4)
          flashed = true
        end
        i.hp -= 1 if i.hp>1 || POISONFAINTINFIELD
        if i.hp==1 && !POISONFAINTINFIELD
          i.status = 0
          Kernel.pbMessage(_INTL("{1} survived the poisoning.\\nThe poison faded away!\1",i.name))
          next
        elsif i.hp==0
          i.changeHappiness("faint")
          i.status = 0
          Kernel.pbMessage(_INTL("{1} fainted...",i.name))
        end
        if pbAllFainted
          handled[0] = true
          pbCheckAllFainted
        end
      end
    end
  end
}

def pbCheckAllFainted
  if pbAllFainted
    Kernel.pbMessage(_INTL("You have no more Pokémon that can fight!\1"))
    Kernel.pbMessage(_INTL("You blacked out!"))
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    pbFadeOutIn(99999){ Kernel.pbStartOver }
  end
end

# Gather soot from soot grass
Events.onStepTakenFieldMovement+=proc {|sender,e|
  event = e[0] # Get the event affected by field movement
  thistile = $MapFactory.getRealTilePos(event.map.map_id,event.x,event.y)
  map = $MapFactory.getMap(thistile[0])
  sootlevel = -1
  for i in [2, 1, 0]
    tile_id = map.data[thistile[1],thistile[2],i]
    next if tile_id==nil
    if map.terrain_tags[tile_id] && map.terrain_tags[tile_id]==PBTerrain::SootGrass
      sootlevel = i
      break
    end
  end
  if sootlevel>=0 && hasConst?(PBItems,:SOOTSACK)
    $PokemonGlobal.sootsack = 0 if !$PokemonGlobal.sootsack
#    map.data[thistile[1],thistile[2],sootlevel]=0
    if event==$game_player && $PokemonBag.pbHasItem?(:SOOTSACK)
      $PokemonGlobal.sootsack += 1
    end
#    $scene.createSingleSpriteset(map.map_id)
  end
}

# Show grass rustle animation, and auto-move the player over waterfalls and ice
Events.onStepTakenFieldMovement+=proc {|sender,e|
  event = e[0] # Get the event affected by field movement
  if $scene.is_a?(Scene_Map)
    currentTag = pbGetTerrainTag(event)
    if PBTerrain.isJustGrass?(pbGetTerrainTag(event,true))  # Won't show if under bridge
      $scene.spriteset.addUserAnimation(GRASS_ANIMATION_ID,event.x,event.y,true,1)
    elsif event==$game_player
      if currentTag==PBTerrain::WaterfallCrest
        # Descend waterfall, but only if this event is the player
        Kernel.pbDescendWaterfall(event)
      elsif PBTerrain.isIce?(currentTag) && !$PokemonGlobal.sliding
        Kernel.pbSlideOnIce(event)
      end
    end
  end
}

def Kernel.pbOnStepTaken(eventTriggered)
  if $game_player.move_route_forcing || pbMapInterpreterRunning? || !$Trainer
    Events.onStepTakenFieldMovement.trigger(nil,$game_player)
    return
  end
  $PokemonGlobal.stepcount = 0 if !$PokemonGlobal.stepcount
  $PokemonGlobal.stepcount += 1
  $PokemonGlobal.stepcount &= 0x7FFFFFFF
  repel = ($PokemonGlobal.repel>0)
  Events.onStepTaken.trigger(nil)
#  Events.onStepTakenFieldMovement.trigger(nil,$game_player)
  handled = [nil]
  Events.onStepTakenTransferPossible.trigger(nil,handled)
  return if handled[0]
  if !eventTriggered
    pbBattleOnStepTaken(repel)
  end
end

def pbBattleOnStepTaken(repel=false)
  return if $Trainer.ablePokemonCount==0
  encounterType = $PokemonEncounters.pbEncounterType
  return if encounterType<0
  return if !$PokemonEncounters.isEncounterPossibleHere?
  encounter = $PokemonEncounters.pbGenerateEncounter(encounterType)
  encounter = EncounterModifier.trigger(encounter)
  if $PokemonEncounters.pbCanEncounter?(encounter,repel)
    $PokemonTemp.encounterType = encounterType
    if !$PokemonTemp.forceSingleBattle && ($PokemonGlobal.partner ||
       ($Trainer.ablePokemonCount>1 && PBTerrain.isDoubleWildBattle?(pbGetTerrainTag) && rand(100)<30))
      encounter2 = $PokemonEncounters.pbEncounteredPokemon(encounterType)
      encounter2 = EncounterModifier.trigger(encounter2)
      pbDoubleWildBattle(encounter[0],encounter[1],encounter2[0],encounter2[1])
    else
      pbWildBattle(encounter[0],encounter[1])
    end
    $PokemonTemp.encounterType = -1
  end
  $PokemonTemp.forceSingleBattle = false
  EncounterModifier.triggerEncounterEnd()
end



#===============================================================================
# Checks when moving between maps
#===============================================================================
# Clears the weather of the old map, if the old and new maps have different
# names or defined weather
Events.onMapChanging+=proc {|sender,e|
  newmapID = e[0]
  newmap   = e[1]
  if newmapID>0
    mapinfos = ($RPGVX) ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
    oldweather = pbGetMetadata($game_map.map_id,MetadataWeather)
    if $game_map.name!=mapinfos[newmapID].name
      $game_screen.weather(0,0,0) if oldweather
    else
      newweather = pbGetMetadata(newmapID,MetadataWeather)
      $game_screen.weather(0,0,0) if oldweather && !newweather
    end
  end
}

# Set up various data related to the new map
Events.onMapChange+=proc {|sender,e|
  oldid = e[0] # previous map ID, 0 if no map ID
  healing = pbGetMetadata($game_map.map_id,MetadataHealingSpot)
  $PokemonGlobal.healingSpot = healing if healing
  $PokemonMap.clear if $PokemonMap
  $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
  $PokemonGlobal.visitedMaps[$game_map.map_id] = true
  if oldid!=0 && oldid!=$game_map.map_id
    mapinfos = ($RPGVX) ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
    weather = pbGetMetadata($game_map.map_id,MetadataWeather)
    if $game_map.name!=mapinfos[oldid].name
      $game_screen.weather(weather[0],8,20) if weather && rand(100)<weather[1]
    else
      oldweather = pbGetMetadata(oldid,MetadataWeather)
      $game_screen.weather(weather[0],8,20) if weather && !oldweather && rand(100)<weather[1]
    end
  end
}

Events.onMapSceneChange+=proc{|sender,e|
  scene      = e[0]
  mapChanged = e[1]
  return if !scene || !scene.spriteset
  # Update map trail
  if $game_map
    lastmapdetails = $PokemonGlobal.mapTrail[0] ?
       pbGetMetadata($PokemonGlobal.mapTrail[0],MetadataMapPosition) : [-1,0,0]
    lastmapdetails = [-1,0,0] if !lastmapdetails
    newmapdetails = $game_map.map_id ?
       pbGetMetadata($game_map.map_id,MetadataMapPosition) : [-1,0,0]
    newmapdetails = [-1,0,0] if !newmapdetails
    $PokemonGlobal.mapTrail = [] if !$PokemonGlobal.mapTrail
    if $PokemonGlobal.mapTrail[0]!=$game_map.map_id
      $PokemonGlobal.mapTrail[3] = $PokemonGlobal.mapTrail[2] if $PokemonGlobal.mapTrail[2]
      $PokemonGlobal.mapTrail[2] = $PokemonGlobal.mapTrail[1] if $PokemonGlobal.mapTrail[1]
      $PokemonGlobal.mapTrail[1] = $PokemonGlobal.mapTrail[0] if $PokemonGlobal.mapTrail[0]
    end
    $PokemonGlobal.mapTrail[0] = $game_map.map_id
  end
  # Display darkness circle on dark maps
  darkmap = pbGetMetadata($game_map.map_id,MetadataDarkMap)
  if darkmap
    if $PokemonGlobal.flashUsed
      $PokemonTemp.darknessSprite = DarknessSprite.new
      scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
      darkness = $PokemonTemp.darknessSprite
      darkness.radius = 176
    else
      $PokemonTemp.darknessSprite = DarknessSprite.new
      scene.spriteset.addUserSprite($PokemonTemp.darknessSprite)
    end
  elsif !darkmap
    $PokemonGlobal.flashUsed = false
    if $PokemonTemp.darknessSprite
      $PokemonTemp.darknessSprite.dispose
      $PokemonTemp.darknessSprite = nil
    end
  end
  # Show location signpost
  if mapChanged
    if pbGetMetadata($game_map.map_id,MetadataShowArea)
      nosignpost = false
      if $PokemonGlobal.mapTrail[1]
        for i in 0...NOSIGNPOSTS.length/2
          nosignpost = true if NOSIGNPOSTS[2*i]==$PokemonGlobal.mapTrail[1] && NOSIGNPOSTS[2*i+1]==$game_map.map_id
          nosignpost = true if NOSIGNPOSTS[2*i+1]==$PokemonGlobal.mapTrail[1] && NOSIGNPOSTS[2*i]==$game_map.map_id
          break if nosignpost
        end
        mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
        oldmapname = mapinfos[$PokemonGlobal.mapTrail[1]].name
        nosignpost = true if $game_map.name==oldmapname
      end
      scene.spriteset.addUserSprite(LocationWindow.new($game_map.name)) if !nosignpost
    end
  end
  # Force cycling/walking
  if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
    Kernel.pbMountBike
  else
    Kernel.pbDismountBike if !pbCanUseBike?($game_map.map_id)
  end
}



#===============================================================================
# Event movement
#===============================================================================
module PBMoveRoute
  Down               = 1
  Left               = 2
  Right              = 3
  Up                 = 4
  LowerLeft          = 5
  LowerRight         = 6
  UpperLeft          = 7
  UpperRight         = 8
  Random             = 9
  TowardPlayer       = 10
  AwayFromPlayer     = 11
  Forward            = 12
  Backward           = 13
  Jump               = 14 # xoffset, yoffset
  Wait               = 15 # frames
  TurnDown           = 16
  TurnLeft           = 17
  TurnRight          = 18
  TurnUp             = 19
  TurnRight90        = 20
  TurnLeft90         = 21
  Turn180            = 22
  TurnRightOrLeft90  = 23
  TurnRandom         = 24
  TurnTowardPlayer   = 25
  TurnAwayFromPlayer = 26
  SwitchOn           = 27 # 1 param
  SwitchOff          = 28 # 1 param
  ChangeSpeed        = 29 # 1 param
  ChangeFreq         = 30 # 1 param
  WalkAnimeOn        = 31
  WalkAnimeOff       = 32
  StepAnimeOn        = 33
  StepAnimeOff       = 34
  DirectionFixOn     = 35
  DirectionFixOff    = 36
  ThroughOn          = 37
  ThroughOff         = 38
  AlwaysOnTopOn      = 39
  AlwaysOnTopOff     = 40
  Graphic            = 41 # Name, hue, direction, pattern
  Opacity            = 42 # 1 param
  Blending           = 43 # 1 param
  PlaySE             = 44 # 1 param
  Script             = 45 # 1 param
  ScriptAsync        = 101 # 1 param
end



def pbMoveRoute(event,commands,waitComplete=false)
  route = RPG::MoveRoute.new
  route.repeat    = false
  route.skippable = true
  route.list.clear
  route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOn))
  i=0; while i<commands.length
    case commands[i]
    when PBMoveRoute::Wait, PBMoveRoute::SwitchOn, PBMoveRoute::SwitchOff,
       PBMoveRoute::ChangeSpeed, PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
       PBMoveRoute::Blending, PBMoveRoute::PlaySE, PBMoveRoute::Script
      route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1]]))
      i += 1
    when PBMoveRoute::ScriptAsync
      route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,[commands[i+1]]))
      route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[0]))
      i += 1
    when PBMoveRoute::Jump
      route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1],commands[i+2]]))
      i += 2
    when PBMoveRoute::Graphic
      route.list.push(RPG::MoveCommand.new(commands[i],
         [commands[i+1],commands[i+2],commands[i+3],commands[i+4]]))
      i += 4
    else
      route.list.push(RPG::MoveCommand.new(commands[i]))
    end
    i += 1
  end
  route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOff))
  route.list.push(RPG::MoveCommand.new(0))
  if event
    event.force_move_route(route)
  end
  return route
end

def pbWait(numframes)
  numframes.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end



#===============================================================================
# Player/event movement in the field
#===============================================================================
def pbLedge(xOffset,yOffset)
  if PBTerrain.isLedge?(Kernel.pbFacingTerrainTag)
    if Kernel.pbJumpToward(2,true)
      $scene.spriteset.addUserAnimation(DUST_ANIMATION_ID,$game_player.x,$game_player.y,true,1)
      $game_player.increase_steps
      $game_player.check_event_trigger_here([1,2])
    end
    return true
  end
  return false
end

def Kernel.pbSlideOnIce(event=nil)
  event = $game_player if !event
  return if !event
  return if !PBTerrain.isIce?(pbGetTerrainTag(event))
  $PokemonGlobal.sliding = true
  direction    = event.direction
  oldwalkanime = event.walk_anime
  event.straighten
  event.walk_anime = false
  loop do
    break if !event.passable?(event.x,event.y,direction)
    break if !PBTerrain.isIce?(pbGetTerrainTag(event))
    event.move_forward
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  event.center(event.x,event.y)
  event.straighten
  event.walk_anime = oldwalkanime
  $PokemonGlobal.sliding = false
end

def pbTurnTowardEvent(event,otherEvent)
  sx = 0; sy = 0
  if $MapFactory
    relativePos=$MapFactory.getThisAndOtherEventRelativePos(otherEvent,event)
    sx = relativePos[0]
    sy = relativePos[1]
  else
    sx = event.x - otherEvent.x
    sy = event.y - otherEvent.y
  end
  return if sx == 0 and sy == 0
  if sx.abs > sy.abs
    (sx > 0) ? event.turn_left : event.turn_right
  else
    (sy > 0) ? event.turn_up : event.turn_down
  end
end

def Kernel.pbMoveTowardPlayer(event)
  maxsize = [$game_map.width,$game_map.height].max
  return if !pbEventCanReachPlayer?(event,$game_player,maxsize)
  loop do
    x = event.x
    y = event.y
    event.move_toward_player
    break if event.x==x && event.y==y
    while event.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  $PokemonMap.addMovedEvent(event.id) if $PokemonMap
end

def Kernel.pbJumpToward(dist=1,playSound=false,cancelSurf=false)
  x = $game_player.x
  y = $game_player.y
  case $game_player.direction
  when 2; $game_player.jump(0,dist)  # down
  when 4; $game_player.jump(-dist,0) # left
  when 6; $game_player.jump(dist,0)  # right
  when 8; $game_player.jump(0,-dist) # up
  end
  if $game_player.x!=x || $game_player.y!=y
    pbSEPlay("Player jump") if playSound
    $PokemonEncounters.clearStepCount if cancelSurf
    $PokemonTemp.endSurf = true if cancelSurf
    while $game_player.jumping?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    return true
  end
  return false
end



#===============================================================================
# Fishing
#===============================================================================
def pbFishingBegin
  $PokemonGlobal.fishing = true
  if !pbCommonEvent(FISHINGBEGINCOMMONEVENT)
    patternb = 2*$game_player.direction - 1
    meta = pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
    num = 6
    if meta && meta[num] && meta[num]!=""
      charset = pbGetPlayerCharset(meta,num)
      4.times do |pattern|
        $game_player.setDefaultCharName(charset,patternb-pattern,true)
        2.times do
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
    end
  end
end

def pbFishingEnd
  if !pbCommonEvent(FISHINGENDCOMMONEVENT)
    patternb = 2*($game_player.direction - 2)
    meta = pbGetMetadata(0,MetadataPlayerA+$PokemonGlobal.playerID)
    num = 6
    if meta && meta[num] && meta[num]!=""
      charset = pbGetPlayerCharset(meta,num)
      4.times do |pattern|
        $game_player.setDefaultCharName(charset,patternb+pattern,true)
        2.times do
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
    end
  end
  $PokemonGlobal.fishing = false
end

def pbFishing(hasencounter,rodtype=1)
  speedup = ($Trainer.firstPokemon &&
            (isConst?($Trainer.firstPokemon.ability,PBAbilities,:STICKYHOLD) ||
            isConst?($Trainer.firstPokemon.ability,PBAbilities,:SUCTIONCUPS)))
  bitechance = 20+(25*rodtype)   # 45, 70, 95
  bitechance *= 1.5 if speedup
  hookchance = 100
  oldpattern = $game_player.fullPattern
  pbFishingBegin
  msgwindow = Kernel.pbCreateMessageWindow
  ret = false
  loop do
    time = 5+rand(6)
    time = [time,5+rand(6)].min if speedup
    message = ""
    time.times do 
      message += ".   "
    end
    if pbWaitMessage(msgwindow,time)
      pbFishingEnd
      $game_player.setDefaultCharName(nil,oldpattern)
      Kernel.pbMessageDisplay(msgwindow,_INTL("Not even a nibble..."))
      break
    end
    if hasencounter && rand(100)<bitechance
      $scene.spriteset.addUserAnimation(EXCLAMATION_ANIMATION_ID,$game_player.x,$game_player.y,true,3)
      frames = 20+rand(21)
      if !pbWaitForInput(msgwindow,message+_INTL("\r\nOh! A bite!"),frames)
        pbFishingEnd
        $game_player.setDefaultCharName(nil,oldpattern)
        Kernel.pbMessageDisplay(msgwindow,_INTL("The Pokémon got away..."))
        break
      end
      if FISHINGAUTOHOOK || rand(100)<hookchance
        pbFishingEnd
        Kernel.pbMessageDisplay(msgwindow,_INTL("Landed a Pokémon!")) if !FISHINGAUTOHOOK
        $game_player.setDefaultCharName(nil,oldpattern)
        ret = true
        break
      end
#      bitechance+=15
#      hookchance+=15
    else
      pbFishingEnd
      $game_player.setDefaultCharName(nil,oldpattern)
      Kernel.pbMessageDisplay(msgwindow,_INTL("Not even a nibble..."))
      break
    end
  end
  Kernel.pbDisposeMessageWindow(msgwindow)
  return ret
end

def pbWaitForInput(msgwindow,message,frames)
  Kernel.pbMessageDisplay(msgwindow,message,false)
  twitchframe = 0
  if FISHINGAUTOHOOK
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      twitchframe = (twitchframe+1)%32
      if twitchframe<16 && (twitchframe&4)==0
        $game_player.pattern = 1
      else
        $game_player.pattern = 0
      end
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        $game_player.pattern = 0
        return true
      end
    end
  else
    frames.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      twitchframe = (twitchframe+1)%32
      if twitchframe<16 && (twitchframe&4)==0
        $game_player.pattern = 1
      else
        $game_player.pattern = 0
      end
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        $game_player.pattern = 0
        return true
      end
    end
  end
  return false
end

def pbWaitMessage(msgwindow,time)
  message = ""
  (time+1).times do |i|
    message += ".   " if i>0
    Kernel.pbMessageDisplay(msgwindow,message,false)
    16.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::C) || Input.trigger?(Input::B)
        return true
      end
    end
  end
  return false
end



#===============================================================================
# Bridges, cave escape points, and setting the heal point
#===============================================================================
def pbBridgeOn(height=2)
  $PokemonGlobal.bridge = height
end

def pbBridgeOff
  $PokemonGlobal.bridge = 0
end

def pbSetEscapePoint
  $PokemonGlobal.escapePoint = [] if !$PokemonGlobal.escapePoint
  xco = $game_player.x
  yco = $game_player.y
  case $game_player.direction
  when 2; yco -= 1; dir = 8   # Down
  when 4; xco += 1; dir = 6   # Left
  when 6; xco -= 1; dir = 4   # Right
  when 8; yco += 1; dir = 2   # Up
  end
  $PokemonGlobal.escapePoint = [$game_map.map_id,xco,yco,dir]
end

def pbEraseEscapePoint
  $PokemonGlobal.escapePoint = []
end

def Kernel.pbSetPokemonCenter
  $PokemonGlobal.pokecenterMapId     = $game_map.map_id
  $PokemonGlobal.pokecenterX         = $game_player.x
  $PokemonGlobal.pokecenterY         = $game_player.y
  $PokemonGlobal.pokecenterDirection = $game_player.direction
end



#===============================================================================
# Partner trainer
#===============================================================================
def pbRegisterPartner(trainerid,trainername,partyid=0)
  if trainerid.is_a?(String) || trainerid.is_a?(Symbol)
    trainerid = getID(PBTrainers,trainerid)
  end
  Kernel.pbCancelVehicles
  trainer = pbLoadTrainer(trainerid,trainername,partyid)
  Events.onTrainerPartyLoad.trigger(nil,trainer)
  trainerobject = PokeBattle_Trainer.new(_INTL(trainer[0].name),trainerid)
  trainerobject.setForeignID($Trainer)
  for i in trainer[2]
    i.trainerID = trainerobject.id
    i.ot        = trainerobject.name
    i.calcStats
  end
  $PokemonGlobal.partner = [trainerid,trainerobject.name,trainerobject.id,trainer[2]]
end

def pbDeregisterPartner
  $PokemonGlobal.partner = nil
end



#===============================================================================
# Event locations, terrain tags
#===============================================================================
def pbEventFacesPlayer?(event,player,distance)
  return false if distance<=0
  # Event can't reach player if no coordinates coincide
  return false if event.x!=player.x && event.y!=player.y
  deltaX = (event.direction==6) ? 1 : (event.direction==4) ? -1 : 0
  deltaY = (event.direction==2) ? 1 : (event.direction==8) ? -1 : 0
  # Check for existence of player
  curx = event.x
  cury = event.y
  found = false
  for i in 0...distance
    curx += deltaX
    cury += deltaY
    if player.x==curx && player.y==cury
      found = true
      break
    end
  end
  return found
end

def pbEventCanReachPlayer?(event,player,distance)
  return false if distance<=0
  # Event can't reach player if no coordinates coincide
  return false if event.x!=player.x && event.y!=player.y
  deltaX = (event.direction==6) ? 1 : (event.direction==4) ? -1 : 0
  deltaY = (event.direction==2) ? 1 : (event.direction==8) ? -1 : 0
  # Check for existence of player
  curx = event.x
  cury = event.y
  found = false
  realdist = 0
  for i in 0...distance
    curx += deltaX
    cury += deltaY
    if player.x==curx && player.y==cury
      found = true
      break
    end
    realdist += 1
  end
  return false if !found
  # Check passibility
  curx = event.x
  cury = event.y
  for i in 0...realdist
    if !event.passable?(curx,cury,event.direction)
      return false
    end
    curx += deltaX
    cury += deltaY
  end
  return true
end

def pbFacingTileRegular(direction=nil,event=nil)
  event = $game_player if !event
  return [0,0,0] if !event
  x = event.x
  y = event.y
  direction = event.direction if !direction
  case direction
  when 1; y+=1; x-=1
  when 2; y+=1
  when 3; y+=1; x+=1
  when 4; x-=1
  when 6; x+=1
  when 7; y-=1; x-=1
  when 8; y-=1
  when 9; y-=1; x+=1
  end
  return [$game_map ? $game_map.map_id : 0,x,y]
end

def pbFacingTile(direction=nil,event=nil)
  if $MapFactory
    return $MapFactory.getFacingTile(direction,event)
  else
    return pbFacingTileRegular(direction,event)
  end
end

def pbFacingEachOther(event1,event2)
  return false if !event1 || !event2
  if $MapFactory
    tile1 = $MapFactory.getFacingTile(nil,event1)
    tile2 = $MapFactory.getFacingTile(nil,event2)
    return false if !tile1 || !tile2
    return tile1[0]==event2.map.map_id &&
           tile1[1]==event2.x && tile1[2]==event2.y &&
           tile2[0]==event1.map.map_id &&
           tile2[1]==event1.x && tile2[2]==event1.y
  else
    tile1 = Kernel.pbFacingTile(nil,event1)
    tile2 = Kernel.pbFacingTile(nil,event2)
    return false if !tile1 || !tile2
    return tile1[1]==event2.x && tile1[2]==event2.y &&
           tile2[1]==event1.x && tile2[2]==event1.y
  end
end

def pbGetTerrainTag(event=nil,countBridge=false)
  event = $game_player if !event
  return 0 if !event
  if $MapFactory
    return $MapFactory.getTerrainTag(event.map.map_id,event.x,event.y,countBridge)
  else
    $game_map.terrain_tag(event.x,event.y,countBridge)
  end
end

def Kernel.pbFacingTerrainTag(event=nil,dir=nil)
  if $MapFactory
    return $MapFactory.getFacingTerrainTag(dir,event)
  else
    event = $game_player if !event
    return 0 if !event
    facing = pbFacingTile(dir,event)
    return $game_map.terrain_tag(facing[1],facing[2])
  end
end



#===============================================================================
# Events
#===============================================================================
class Game_Event
  def cooledDown?(seconds)
    if !(expired?(seconds) && tsOff?("A"))
      self.need_refresh = true
      return false
    else
      return true
    end
  end

  def cooledDownDays?(days)
    if !(expiredDays?(days) && tsOff?("A"))
      self.need_refresh = true
      return false
    else
      return true
    end
  end
end



module InterpreterFieldMixin
  # Used in boulder events. Allows an event to be pushed. To be used in
  # a script event command.
  def pbPushThisEvent
    event = get_character(0)
    oldx  = event.x
    oldy  = event.y
    # Apply strict version of passable, which makes impassable
    # tiles that are passable only from certain directions
    return if !event.passableStrict?(event.x,event.y,$game_player.direction)
    case $game_player.direction
    when 2; event.move_down  # down
    when 4; event.move_left  # left
    when 6; event.move_right # right
    when 8; event.move_up    # up
    end
    $PokemonMap.addMovedEvent(@event_id) if $PokemonMap
    if oldx!=event.x || oldy!=event.y
      $game_player.lock
      begin
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end until !event.moving?
      $game_player.unlock
    end
  end

  def pbPushThisBoulder
    pbPushThisEvent if $PokemonMap.strengthUsed
    return true
  end

  def pbSmashThisEvent
    event = get_character(0)
    if event
      pbSmashEvent(event)
    end
    @index += 1
    return true
  end

  def pbHeadbutt
    Kernel.pbHeadbutt(get_character(0))
    return true
  end

  def pbTrainerIntro(symbol)
    return if $DEBUG && !Kernel.pbTrainerTypeCheck(symbol)
    trtype = PBTrainers.const_get(symbol)
    pbGlobalLock
    Kernel.pbPlayTrainerIntroME(trtype)
    return true
  end

  def pbTrainerEnd
    pbGlobalUnlock
    e = get_character(0)
    e.erase_route if e
  end

  def pbParams
    (@parameters) ? @parameters : @params
  end

  def pbGetPokemon(id)
    return $Trainer.party[pbGet(id)]
  end

  def pbSetEventTime(*arg)
    $PokemonGlobal.eventvars = {} if !$PokemonGlobal.eventvars
    time = pbGetTimeNow
    time = time.to_i
    pbSetSelfSwitch(@event_id,"A",true)
    $PokemonGlobal.eventvars[[@map_id,@event_id]]=time
    for otherevt in arg
      pbSetSelfSwitch(otherevt,"A",true)
      $PokemonGlobal.eventvars[[@map_id,otherevt]]=time
    end
  end

  def getVariable(*arg)
    if arg.length==0
      return nil if !$PokemonGlobal.eventvars
      return $PokemonGlobal.eventvars[[@map_id,@event_id]]
    else
      return $game_variables[arg[0]]
    end
  end

  def setVariable(*arg)
    if arg.length==1
      $PokemonGlobal.eventvars = {} if !$PokemonGlobal.eventvars
      $PokemonGlobal.eventvars[[@map_id,@event_id]]=arg[0]
    else
      $game_variables[arg[0]] = arg[1]
      $game_map.need_refresh = true
    end
  end

  def tsOff?(c)
    get_character(0).tsOff?(c)
  end

  def tsOn?(c)
    get_character(0).tsOn?(c)
  end

  alias isTempSwitchOn? tsOn?
  alias isTempSwitchOff? tsOff?

  def setTempSwitchOn(c)
    get_character(0).setTempSwitchOn(c)
  end

  def setTempSwitchOff(c)
    get_character(0).setTempSwitchOff(c)
  end

  # Must use this approach to share the methods because the methods already
  # defined in a class override those defined in an included module
  CustomEventCommands=<<_END_

  def command_352
    scene = PokemonSave_Scene.new
    screen = PokemonSaveScreen.new(scene)
    screen.pbSaveScreen
    return true
  end

  def command_125
    value = operate_value(pbParams[0], pbParams[1], pbParams[2])
    $Trainer.money += value
    return true
  end

  def command_132
    ($PokemonGlobal.nextBattleBGM=pbParams[0]) ? pbParams[0].clone : nil
    return true
  end

  def command_133
    ($PokemonGlobal.nextBattleME=pbParams[0]) ? pbParams[0].clone : nil
    return true
  end

  def command_353
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    pbFadeOutIn(99999){ Kernel.pbStartOver(true) }
  end

  def command_314
    pbHealAll if pbParams[0]==0
    return true
  end

_END_
end



class Interpreter
  include InterpreterFieldMixin
  eval(InterpreterFieldMixin::CustomEventCommands)
end



class Game_Interpreter
  include InterpreterFieldMixin
  eval(InterpreterFieldMixin::CustomEventCommands)
end



#===============================================================================
# Audio playing
#===============================================================================
def pbCueBGM(bgm,seconds,volume=nil,pitch=nil)
  return if !bgm
  bgm        = pbResolveAudioFile(bgm,volume,pitch)
  playingBGM = $game_system.playing_bgm
  if !playingBGM || playingBGM.name!=bgm.name || playingBGM.pitch!=bgm.pitch
    pbBGMFade(seconds)
    if !$PokemonTemp.cueFrames
      $PokemonTemp.cueFrames = (seconds*Graphics.frame_rate)*3/5
    end
    $PokemonTemp.cueBGM=bgm
  elsif playingBGM
    pbBGMPlay(bgm)
  end
end

def pbAutoplayOnTransition
  surfbgm = pbGetMetadata(0,MetadataSurfBGM)
  if $PokemonGlobal.surfing && surfbgm
    pbBGMPlay(surfbgm)
  else
    $game_map.autoplayAsCue
  end
end

def pbAutoplayOnSave
  surfbgm = pbGetMetadata(0,MetadataSurfBGM)
  if $PokemonGlobal.surfing && surfbgm
    pbBGMPlay(surfbgm)
  else
    $game_map.autoplay
  end
end



#===============================================================================
# Voice recorder
#===============================================================================
def pbRecord(text,maxtime=30.0)
  text = "" if !text
  textwindow = Window_UnformattedTextPokemon.newWithSize(text,0,0,Graphics.width,Graphics.height-96)
  textwindow.z=99999
  if text==""
    textwindow.visible = false
  end
  wave = nil
  msgwindow = Kernel.pbCreateMessageWindow
  oldvolume = Kernel.Audio_bgm_get_volume()
  Kernel.Audio_bgm_set_volume(0)
  delay = 2
  delay.times do |i|
    Kernel.pbMessageDisplay(msgwindow,_INTL("Recording in {1} second(s)...\nPress ESC to cancel.",delay-i),false)
    Graphics.frame_rate.times do
      Graphics.update
      Input.update
      textwindow.update
      msgwindow.update
      if Input.trigger?(Input::B)
        Kernel.Audio_bgm_set_volume(oldvolume)
        Kernel.pbDisposeMessageWindow(msgwindow)
        textwindow.dispose
        return nil
      end
    end
  end
  Kernel.pbMessageDisplay(msgwindow,_INTL("NOW RECORDING\nPress ESC to stop recording."),false)
  if beginRecordUI
    frames = (maxtime*Graphics.frame_rate).to_i
    frames.times do
      Graphics.update
      Input.update
      textwindow.update
      msgwindow.update
      if Input.trigger?(Input::B)
        break
      end
    end
    tmpFile = ENV["TEMP"]+"\\record.wav"
    endRecord(tmpFile)
    wave = getWaveDataUI(tmpFile,true)
    if wave
      Kernel.pbMessageDisplay(msgwindow,_INTL("PLAYING BACK..."),false)
      textwindow.update
      msgwindow.update
      Graphics.update
      Input.update
      wave.play
      (Graphics.frame_rate*wave.time).to_i.times do
        Graphics.update
        Input.update
        textwindow.update
        msgwindow.update
      end
    end
  end
  Kernel.Audio_bgm_set_volume(oldvolume)
  Kernel.pbDisposeMessageWindow(msgwindow)
  textwindow.dispose
  return wave
end



#===============================================================================
# Picking up an item found on the ground
#===============================================================================
def Kernel.pbItemBall(item,quantity=1)
  if item.is_a?(String) || item.is_a?(Symbol)
    item = getID(PBItems,item)
  end
  return false if !item || item<=0 || quantity<1
  itemname = (quantity>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
  pocket = pbGetPocket(item)
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be picked up
    if isConst?(item,PBItems,:LEFTOVERS)
      Kernel.pbMessage(_INTL("\\me[Item get]You found some \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
    elsif pbIsMachine?(item)   # TM or HM
      Kernel.pbMessage(_INTL("\\me[Item get]You found \\c[1]{1} {2}\\c[0]!\\wtnp[30]",itemname,PBMoves.getName(pbGetMachine(item))))
    elsif quantity>1
      Kernel.pbMessage(_INTL("\\me[Item get]You found {1} \\c[1]{2}\\c[0]!\\wtnp[30]",quantity,itemname))
    elsif ['a','e','i','o','u'].include?(itemname[0,1].downcase)
      Kernel.pbMessage(_INTL("\\me[Item get]You found an \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
    else
      Kernel.pbMessage(_INTL("\\me[Item get]You found a \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
    end
    Kernel.pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
       itemname,pocket,PokemonBag.pocketNames()[pocket]))
    return true
  else   # Can't add the item
    if isConst?(item,PBItems,:LEFTOVERS)
      Kernel.pbMessage(_INTL("You found some \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
    elsif pbIsMachine?(item)   # TM or HM
      Kernel.pbMessage(_INTL("You found \\c[1]{1} {2}\\c[0]!\\wtnp[30]",itemname,PBMoves.getName(pbGetMachine(item))))
    elsif quantity>1
      Kernel.pbMessage(_INTL("You found {1} \\c[1]{2}\\c[0]!\\wtnp[30]",quantity,itemname))
    elsif ['a','e','i','o','u'].include?(itemname[0,1].downcase)
      Kernel.pbMessage(_INTL("You found an \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
    else
      Kernel.pbMessage(_INTL("You found a \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
    end
    Kernel.pbMessage(_INTL("But your Bag is full..."))
    return false
  end
end



#===============================================================================
# Being given an item
#===============================================================================
def Kernel.pbReceiveItem(item,quantity=1)
  if item.is_a?(String) || item.is_a?(Symbol)
    item = getID(PBItems,item)
  end
  return false if !item || item<=0 || quantity<1
  itemname = (quantity>1) ? PBItems.getNamePlural(item) : PBItems.getName(item)
  pocket = pbGetPocket(item)
  if isConst?(item,PBItems,:LEFTOVERS)
    Kernel.pbMessage(_INTL("\\me[Item get]You obtained some \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  elsif pbIsMachine?(item)   # TM or HM
    Kernel.pbMessage(_INTL("\\me[Item get]You obtained \\c[1]{1} {2}\\c[0]!\\wtnp[30]",itemname,PBMoves.getName(pbGetMachine(item))))
  elsif quantity>1
    Kernel.pbMessage(_INTL("\\me[Item get]You obtained {1} \\c[1]{2}\\c[0]!\\wtnp[30]",quantity,itemname))
  elsif ['a','e','i','o','u'].include?(itemname[0,1].downcase)
    Kernel.pbMessage(_INTL("\\me[Item get]You obtained an \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  else
    Kernel.pbMessage(_INTL("\\me[Item get]You obtained a \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
  end
  if $PokemonBag.pbStoreItem(item,quantity)   # If item can be added
    Kernel.pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
       itemname,pocket,PokemonBag.pocketNames()[pocket]))
    return true
  end
  return false   # Can't add the item
end