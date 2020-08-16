#==============================================================================#
#                                    HM Items                                  #
#                             by Marin. Edited by Izzy                         #
#==============================================================================#
#                       No coding knowledge required at all.                   #
#                                                                              #
#  Because the items override the actual moves' functionality, the items have  #
#      switches to toggle them, as you see below (USING_SURF_ITEM, etc.)       #
#   If they're set to true, the items will be active and will override some    #
#                 in-field functionality of the moves themselves.              #
#==============================================================================#
#      Rock Smash, Strength and Cut all use the default Essentials events.     #
#==============================================================================#

# Future updates may contain: Headbutt, Rock Climb.


# The internal name of the item that will trigger Surf
SURF_ITEM = :POOLTUBE

# The internal name of the item that will trigger Rock Smash
ROCK_SMASH_ITEM = :DYNAMITE

# The internal name of the item that will trigger Fly
FLY_ITEM = :WORMHOLE

# The internal name of the item that will trigger Strength
STRENGTH_ITEM = :STRENGTHITEM

# The internal name of the item that will trigger Cut
CUT_ITEM = :SAPPER

# The internal name of the item that will trigger Dive
DIVE_ITEM = :DIVEITEM

# The internal name of the item that will trigger Flash
FLASH_ITEM = :FLASHLIGHT



# When true, this overrides the old surfing mechanics.
USING_SURF_ITEM = true

# When true, this overrides the old rock smash mechanics.
USING_ROCK_SMASH_ITEM = true

# When true, this overrides the old fly mechanics.
USING_FLY_ITEM = true

# When true, this overrides the old strength mechanics.
USING_STRENGTH_ITEM = true

# When true, this overrides the old cut mechanics.
USING_CUT_ITEM = true

# When true, this overrides the old dive mechanics.
USING_DIVE_ITEM = true

# When true, this overrides the old flash mechanics.
USING_FLASH_ITEM = true


#==============================================================================#
# This section of code contains minor utility methods.                         #
#==============================================================================#

class Game_Map
  attr_reader :map
end

class Game_Player
  attr_writer :x
  attr_writer :y
end

class HandlerHash
  def delete(sym)
    id = fromSymbol(sym)
    @hash.delete(id) if id && @hash[id]
    symbol = toSymbol(sym)
    @hash.delete(symbol) if symbol && @hash[symbol]
  end
end

def pbSmashEvent(event)
  return unless event
  if event.name == "Tree"
    pbSEPlay("Cut", 80)
  elsif event.name == "Rock"
    pbSEPlay("Rock Smash", 80)
  end
  pbMoveRoute(event,[
     PBMoveRoute::TurnDown,
     PBMoveRoute::Wait, 2,
     PBMoveRoute::TurnLeft,
     PBMoveRoute::Wait, 2,
     PBMoveRoute::TurnRight,
     PBMoveRoute::Wait, 2,
     PBMoveRoute::TurnUp,
     PBMoveRoute::Wait, 2
  ])
  pbWait(16)
  event.erase
  $PokemonMap.addErasedEvent(event.id) if $PokemonMap
end


#==============================================================================#
# This section of the code handles the item that calls Surf.                   #
#==============================================================================#

if USING_SURF_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:SURF)
  HiddenMoveHandlers::UseMove.delete(:SURF)
  
  def Kernel.pbSurf
    return false if $game_player.pbHasDependentEvents?
    if !pbCheckHiddenMoveBadge(BADGEFORSURF,false) && !$DEBUG
      return false
    end
    if Kernel.pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
      Kernel.pbMessage(_INTL("{1} used the {2}!", $Trainer.name, PBItems.getName(getConst(PBItems,SURF_ITEM))))
      Kernel.pbCancelVehicles
      surfbgm = pbGetMetadata(0,MetadataSurfBGM)
      pbCueBGM(surfbgm,0.5) if surfbgm
      pbStartSurfing
      return true
    end
    return false
  end
  
  ItemHandlers::UseInField.add(SURF_ITEM, proc do |item|
    $game_temp.in_menu = false
    Kernel.pbSurf
    return true
  end)
  
  ItemHandlers::UseFromBag.add(SURF_ITEM, proc do |item|
    return false if $PokemonGlobal.surfing ||
                    pbGetMetadata($game_map.map_id,MetadataBicycleAlways) ||
                    !PBTerrain.isSurfable?(Kernel.pbFacingTerrainTag) ||
                    !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
    return 2
  end)
end


#==============================================================================#
# This section of the code handles the item that calls Fly.                    #
#==============================================================================#

if USING_FLY_ITEM
  ItemHandlers::UseFromBag.add(FLY_ITEM, proc do |item|
    return false unless pbGetMetadata($game_map.map_id,MetadataOutdoor)
    if defined?(BetterRegionMap)
      ret = pbBetterRegionMap(nil, true, true)
    else
      ret = pbFadeOutIn(99999) do
        scene = PokemonRegionMap_Scene.new(-1, false)
        screen = PokemonRegionMapScreen.new(scene)
        next screen.pbStartFlyScreen
      end
    end
    if ret
      $PokemonTemp.flydata = ret
      return 2
    end
    return 0
  end)
  
  ItemHandlers::UseInField.add(FLY_ITEM, proc do |item|
    $game_temp.in_menu = false
    return false if !$PokemonTemp.flydata
    Kernel.pbMessage(_INTL("{1} used the {2}!", $Trainer.name,PBItems.getName(getConst(PBItems,FLY_ITEM))))
    pbFadeOutIn(99999) do
       $game_temp.player_new_map_id    = $PokemonTemp.flydata[0]
       $game_temp.player_new_x         = $PokemonTemp.flydata[1]
       $game_temp.player_new_y         = $PokemonTemp.flydata[2]
       $game_temp.player_new_direction = 2
       Kernel.pbCancelVehicles
       $PokemonTemp.flydata = nil
       $scene.transfer_player
       $game_map.autoplay
       $game_map.refresh
    end
    pbEraseEscapePoint
    return true
  end)
end


#==============================================================================#
# This section of the code handles the item that calls Rock Smash.             #
#==============================================================================#

if USING_ROCK_SMASH_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:ROCKSMASH)
  HiddenMoveHandlers::UseMove.delete(:ROCKSMASH)
  
  ItemHandlers::UseFromBag.add(ROCK_SMASH_ITEM, proc do |item|
    if $game_player.pbFacingEvent && $game_player.pbFacingEvent.name == "Rock"
      return 2
    end
    return false
  end)
  
  ItemHandlers::UseInField.add(ROCK_SMASH_ITEM, proc do |item|
    $game_player.pbFacingEvent.start
    return true
  end)
  
  def Kernel.pbRockSmash
    if !pbCheckHiddenMoveBadge(BADGEFORROCKSMASH,false)
      Kernel.pbMessage(_INTL("It's a rugged rock, but an item may be able to smash it."))
      return false
    end
    item = PBItems.getName(getConst(PBItems,ROCK_SMASH_ITEM))
    if Kernel.pbConfirmMessage(_INTL("This rock appears to be breakable. Would you like to use the {1}?", item))
      Kernel.pbMessage(_INTL("{1} used the {2}!",$Trainer.name, item))
      return true
    end
    return false
  end
end


#==============================================================================#
# This section of code handles the item that calls Strength.                   #
#==============================================================================#

if USING_STRENGTH_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:STRENGTH)
  HiddenMoveHandlers::UseMove.delete(:STRENGTH)
  
  def Kernel.pbStrength
    if $PokemonMap.strengthUsed
      Kernel.pbMessage(_INTL("Strength made it possible to move boulders around."))
      return false
    end
    if !pbCheckHiddenMoveBadge(BADGEFORSTRENGTH,false) && !$DEBUG
      Kernel.pbMessage(_INTL("It's a big boulder, but an item may be able to push it aside."))
      return false
    end
    itemname = PBItems.getName(getConst(PBItems,STRENGTH_ITEM))
    Kernel.pbMessage(_INTL("It's a big boulder, but an item may be able to push it aside.\1"))
    if Kernel.pbConfirmMessage(_INTL("Would you like to use the {1}?", itemname))
      Kernel.pbMessage(_INTL("{1} used the {2}!",
          $Trainer.name, itemname))
      Kernel.pbMessage(_INTL("The {1} made it possible to move boulders around!",itemname))
      $PokemonMap.strengthUsed = true
      return true
    end
    return false
  end
  
  ItemHandlers::UseFromBag.add(STRENGTH_ITEM, proc do
    if $game_player.pbFacingEvent && $game_player.pbFacingEvent.name == "Boulder"
      return 2
    end
    return false
  end)
  
  ItemHandlers::UseInField.add(STRENGTH_ITEM, proc { Kernel.pbStrength })
end


#==============================================================================#
# This section of code handles the item that calls Cut.                        #
#==============================================================================#

if USING_CUT_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:CUT)
  HiddenMoveHandlers::UseMove.delete(:CUT)
  
  def Kernel.pbCut
    if !pbCheckHiddenMoveBadge(BADGEFORCUT,false) && !$DEBUG
      Kernel.pbMessage(_INTL("This dispenser could probably be destroyed somehow."))
      return false
    end
    Kernel.pbMessage(_INTL("This dispenser looks like it could be sapped!\1"))
    if Kernel.pbConfirmMessage(_INTL("Would you like to sap it?"))
      itemname = PBItems.getName(getConst(PBItems,CUT_ITEM))
      Kernel.pbMessage(_INTL("{1} used the {2}!",$Trainer.name,itemname))
      pbSmashEvent($game_player.pbFacingEvent)
      return true
    end
    return false
  end
  
  ItemHandlers::UseFromBag.add(CUT_ITEM, proc do
    if $game_player.pbFacingEvent && $game_player.pbFacingEvent.name == "Dispenser"
      return 2
    end
    return false
  end)
  
  ItemHandlers::UseInField.add(CUT_ITEM, proc { $game_player.pbFacingEvent.start })
end

#=======================================================================================================#
# This section of the code handles the item that calls Dive. Made by her Empress, the Magnificent, Izzy #
#=======================================================================================================#

if USING_DIVE_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:DIVE)
  HiddenMoveHandlers::UseMove.delete(:DIVE)
  
  def Kernel.pbDive
    divemap = pbGetMetadata($game_map.map_id,MetadataDiveMap)
    return false if !divemap
    if !pbCheckHiddenMoveBadge(BADGEFORDIVE,false) || !$DEBUG 
      Kernel.pbMessage(_INTL("The sea is deep here. A Jermon may be able to go underwater."))
      return false
    end
    if Kernel.pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
      Kernel.pbMessage(_INTL("{1} used {2}!",$Trainer.name, PBItems.getName(getConst(PBItems,DIVE_ITEM))))
      pbFadeOutIn(99999){
         $game_temp.player_new_map_id    = divemap
         $game_temp.player_new_x         = $game_player.x
         $game_temp.player_new_y         = $game_player.y
         $game_temp.player_new_direction = $game_player.direction
         Kernel.pbCancelVehicles
         $PokemonGlobal.diving = true
         Kernel.pbUpdateVehicle
         $scene.transfer_player(false)
         $game_map.autoplay
         $game_map.refresh
      }
      return true
    end
    return false
  end

  def Kernel.pbSurfacing
    return if !$PokemonGlobal.diving
    divemap = nil
    meta = pbLoadMetadata
    for i in 0...meta.length
      if meta[i] && meta[i][MetadataDiveMap] && meta[i][MetadataDiveMap]==$game_map.map_id
        divemap = i; break
      end
    end
    return if !divemap
    if !pbCheckHiddenMoveBadge(BADGEFORDIVE,false) || !$DEBUG
      Kernel.pbMessage(_INTL("Light is filtering down from above. A Jermon may be able to surface here."))
      return false
    end
    if Kernel.pbConfirmMessage(_INTL("Light is filtering down from above. Would you like to use Dive?"))
      Kernel.pbMessage(_INTL("{1} used {2}!",$Trainer.name, PBItems.getName(getConst(PBItems,DIVE_ITEM))))
      pbFadeOutIn(99999){
         $game_temp.player_new_map_id    = divemap
         $game_temp.player_new_x         = $game_player.x
         $game_temp.player_new_y         = $game_player.y
         $game_temp.player_new_direction = $game_player.direction
         Kernel.pbCancelVehicles
         $PokemonGlobal.surfing = true
         Kernel.pbUpdateVehicle
         $scene.transfer_player(false)
         surfbgm = pbGetMetadata(0,MetadataSurfBGM)
         (surfbgm) ?  pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
         $game_map.refresh
      }
      return true
    end
    return false
  end
  
  ItemHandlers::UseInField.add(DIVE_ITEM, proc do |item|
    $game_temp.in_menu = false
    if $PokemonGlobal.diving
     if DIVINGSURFACEANYWHERE
       Kernel.pbSurfacing
       return
     end
     divemap = nil
     meta = pbLoadMetadata
     for i in 0...meta.length
       if meta[i] && meta[i][MetadataDiveMap] && meta[i][MetadataDiveMap]==$game_map.map_id
         divemap = i; break
       end
     end
     if PBTerrain.isDeepWater?($MapFactory.getTerrainTag(divemap,$game_player.x,$game_player.y))
       Kernel.pbSurfacing
       return
     end
   else
     if PBTerrain.isDeepWater?($game_player.terrain_tag)
       Kernel.pbDive
       return
     end
   end
    return true
  end)
  
  ItemHandlers::UseFromBag.add(DIVE_ITEM, proc do |item|
    return false if !pbGetMetadata($game_map.map_id,MetadataDiveMap) ||
                    !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
    return 2
  end)
end

#===========================================================================================================#
# This section of the code handles the item that calls Flash. Made by Poofy the magnificent, edited by Izzy #
#===========================================================================================================#

if USING_FLASH_ITEM
  HiddenMoveHandlers::CanUseMove.delete(:FLASH)
  HiddenMoveHandlers::UseMove.delete(:FLASH)

  def canUseMoveFlash?
     showmsg = true
     return false if !pbCheckHiddenMoveBadge(BADGEFORFLASH,showmsg)
     if !pbGetMetadata($game_map.map_id,MetadataDarkMap)
       Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
       return false
     end
     if $PokemonGlobal.flashUsed
       Kernel.pbMessage(_INTL("The flashlight is already being used.")) if showmsg
       return false
     end
     return true
  end

  def useMoveFlash
     darkness = $PokemonTemp.darknessSprite
     return false if !darkness || darkness.disposed?
     if !pbHiddenMoveAnimation(nil)
       Kernel.pbMessage(_INTL("{1} used the flashlight!",$Trainer.name))
     end
     $PokemonGlobal.flashUsed = true
     while darkness.radius<176
       Graphics.update
       Input.update
       pbUpdateSceneMap
       darkness.radius += 4
     end
     return true
  end

  ItemHandlers::UseFromBag.add(FLASH_ITEM, proc do |item|
     next canUseMoveFlash? ? 2 : 0
  end)


  ItemHandlers::UseInField.add(FLASH_ITEM,proc do |item|
    if canUseMoveFlash?
      useMoveFlash
    end
  end)

end
