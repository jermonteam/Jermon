#===============================================================================
# Register contacts
#===============================================================================
def pbPhoneRegisterNPC(ident,name,mapid,showmessage=true)
  $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
  exists = pbFindPhoneTrainer(ident,name)
  if exists
    return if exists[0] # Already visible
    exists[0] = true # Make visible
  else
    phonenum = [true,ident,name,mapid]
    $PokemonGlobal.phoneNumbers.push(phonenum)
  end
  Kernel.pbMessage(_INTL("Registered {1} in the Jermogear.",name)) if showmessage
end

def pbPhoneRegister(event,trainertype,trainername)
  $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
  return if pbFindPhoneTrainer(trainertype,trainername)
  phonenum = []
  phonenum.push(true)
  phonenum.push(trainertype)
  phonenum.push(trainername)
  phonenum.push(0) # time to next battle
  phonenum.push(0) # can battle
  phonenum.push(0) # battle count
  if event
    phonenum.push(event.map.map_id)
    phonenum.push(event.id)
  end
  $PokemonGlobal.phoneNumbers.push(phonenum)
end

def pbPhoneDeleteContact(index)
  $PokemonGlobal.phoneNumbers[index][0] = false       # Remove from contact list
  if $PokemonGlobal.phoneNumbers[index].length==8
    $PokemonGlobal.phoneNumbers[index][3] = 0                  # Reset countdown
    $PokemonGlobal.phoneNumbers[index][4] = 0                  # Reset countdown
  end
end

def pbPhoneRegisterBattle(message,event,trainertype,trainername,maxbattles)
  return if !$Trainer.pokegear               # Can't register without a Jermogear
  if trainertype.is_a?(String) || trainertype.is_a?(Symbol)
    return false if !hasConst?(PBTrainers,trainertype)
    trainertype = PBTrainers.const_get(trainertype)
  end
  contact = pbFindPhoneTrainer(trainertype,trainername)
  return if contact && contact[0]              # Existing contact and is visible
  message = _INTL("Let me register you.") if !message
  if Kernel.pbConfirmMessage(message)
    displayname = _INTL("{1} {2}",PBTrainers.getName(trainertype),
       pbGetMessageFromHash(MessageTypes::TrainerNames,trainername)
    )
    if contact                        # Previously registered, just make visible
      contact[0] = true
    else                                                       # Add new contact
      pbPhoneRegister(event,trainertype,trainername)
      pbPhoneIncrement(trainertype,trainername,maxbattles)
    end
    Kernel.pbMessage(_INTL("Registered {1} in the Jermogear.",displayname))
  end
end

#===============================================================================
# Contact information
#===============================================================================
def pbRandomPhoneTrainer
  $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
  temparray = []
  currentregion = pbGetMetadata($game_map.map_id,MetadataMapPosition)
  for num in $PokemonGlobal.phoneNumbers
    if num[0] && num.length==8 # if visible and a trainer
      next if $game_player && $game_map.map_id==num[6] # Can't call if on same map
      callerregion  = pbGetMetadata(num[6],MetadataMapPosition)
      if callerregion && currentregion && callerregion[0]!=currentregion[0]
        next   # Can't call if in different region
      end
      temparray.push(num)
    end
  end
  return nil if temparray.length==0
  return temparray[rand(temparray.length)]
end

def pbFindPhoneTrainer(trtype,trname)           # Ignores whether visible or not
  return nil if !$PokemonGlobal.phoneNumbers
  if trtype.is_a?(String) || trtype.is_a?(Symbol)
    return nil if !hasConst?(PBTrainers,trtype)
    trtype = PBTrainers.const_get(trtype)
  end
  for num in $PokemonGlobal.phoneNumbers
    return num if num[1]==trtype && num[2]==trname # If a match
  end
  return nil
end

def pbHasPhoneTrainer?(trtype,trname)
  return pbFindPhoneTrainer!=nil
end

def pbPhoneBattleCount(trtype,trname)
  trainer = pbFindPhoneTrainer(trtype,trname)
  return trainer[5] if trainer
  return 0
end

def pbPhoneReadyToBattle?(trtype,trname)
  trainer = pbFindPhoneTrainer(trtype,trname)
  return (trainer && trainer[4]>=2)
end

#===============================================================================
# Contact rematch data modifications
#===============================================================================
def pbPhoneIncrement(trtype,trname,maxbattles)
  trainer = pbFindPhoneTrainer(trtype,trname)
  if trainer
    if trainer[5]<maxbattles
      trainer[5] += 1 # Increment battle count
    end
    trainer[3] = 0 # reset time to can-battle
    trainer[4] = 0 # reset can-battle flag
  end
end

def pbPhoneReset(trtype,trname)
  trainer = pbFindPhoneTrainer(trtype,trname)
  if trainer
    trainer[3] = 0 # reset time to can-battle
    trainer[4] = 0 # reset can-battle flag
    return true
  end
  return false
end

def pbSetReadyToBattle(num)
  if num[6] && num[7]
    $game_self_switches[[num[6],num[7],"A"]] = false
    $game_self_switches[[num[6],num[7],"B"]] = true
    $game_map.need_refresh = true
  end
end

#===============================================================================
# Phone-related counters
#===============================================================================
Events.onMapUpdate+=proc {|sender,e|
  if !$PokemonGlobal || !$game_player || !$game_map ||
     !$Trainer || !$Trainer.pokegear
    # do nothing
    next
  elsif !$PokemonGlobal.phoneTime || $PokemonGlobal.phoneTime<=0
    $PokemonGlobal.phoneTime = 20*60*Graphics.frame_rate
    $PokemonGlobal.phoneTime += rand(20*60*Graphics.frame_rate)
  end
  $PokemonGlobal.phoneNumbers = [] if !$PokemonGlobal.phoneNumbers
  if !$game_temp.in_menu && !$game_temp.in_battle &&
     !$game_player.move_route_forcing && !$game_temp.message_window_showing &&
     !pbMapInterpreterRunning?
    $PokemonGlobal.phoneTime -= 1
    if $PokemonGlobal.phoneTime%10==0
      for num in $PokemonGlobal.phoneNumbers
        if num[0] && num.length==8 # if visible and a trainer
          if num[4]==0 # needs resetting
            num[3] = 2000+rand(2000) # set time to can-battle
            num[4] = 1
          end
          num[3] -= 1
          if num[3]<=0 && num[4]==1
            num[4] = 2 # set ready-to-battle flag
            pbSetReadyToBattle(num)
          end
        end
      end
    end
    if $PokemonGlobal.phoneTime<=0
      # find all trainer phone numbers
      phonenum = pbRandomPhoneTrainer
      if phonenum
        call = pbPhoneGenerateCall(phonenum)
        pbPhoneCall(call,phonenum)
      end
    end
  end
}

#===============================================================================
# Player calls a contact
#===============================================================================
def pbCallTrainer(trtype,trname)
  trainer = pbFindPhoneTrainer(trtype,trname)
  if trainer
    if trainer.length==8
      if $game_player && $game_map.map_id==trainer[6]
        Kernel.pbMessage(_INTL("The Trainer is close by.\nTalk to the Trainer in person!"))
        return
      end
      callerregion  = pbGetMetadata(trainer[6],MetadataMapPosition)
      currentregion = pbGetMetadata($game_map.map_id,MetadataMapPosition)
      if callerregion && currentregion && callerregion[0]!=currentregion[0]
        Kernel.pbMessage(_INTL("The Trainer is out of range."))
        return   # Can't call if in different region
      end
      call = pbPhoneGenerateCall(trainer)
      pbPhoneCall(call,trainer)
    else
      if !pbCommonEvent(trtype)
        Kernel.pbMessage(_INTL("{1}'s messages not defined.\nCouldn't call common event {2}.",trainer[2],trtype))
      end
    end
  end
end

#===============================================================================
# Generate phone message
#===============================================================================
def pbPhoneGenerateCall(phonenum)
  call = ""
  phoneData = pbLoadPhoneData
  # Choose random greeting depending on time of day
  call = pbRandomPhoneItem(phoneData.greetings)
  time = pbGetTimeNow
  if PBDayNight.isMorning?(time)
    modcall = pbRandomPhoneItem(phoneData.greetingsMorning)
    call = modcall if modcall && modcall!=""
  elsif PBDayNight.isEvening?(time)
    modcall = pbRandomPhoneItem(phoneData.greetingsEvening)
    call = modcall if modcall && modcall!=""
  end
  call += "\\m"
  if phonenum[4]==2 || (rand(2)==0 && phonenum[4]==3)
    # If "can battle" is set, make ready to battle
    call += pbRandomPhoneItem(phoneData.battleRequests)
    pbSetReadyToBattle(phonenum)
    phonenum[4] = 3
  elsif rand(4)<3
    # Choose random body
    call += pbRandomPhoneItem(phoneData.bodies1)
    call += "\\m"
    call += pbRandomPhoneItem(phoneData.bodies2)
  else
    # Choose random generic
    call += pbRandomPhoneItem(phoneData.generics)
  end
  return call
end

def pbRandomPhoneItem(array)
  ret = array[rand(array.length)]
  ret = "" if !ret
  return pbGetMessageFromHash(MessageTypes::PhoneMessages,ret)
end

def pbRandomEncounterSpecies(enctype)
  return 0 if !enctype
  len = [enctype.length,4].min
  return enctype[rand(len)][0]
end

def pbEncounterSpecies(phonenum)
  return "" if !phonenum[6] || phonenum[6]==0
  begin
    data = load_data("Data/encounters.dat")
    return "" if !data
    enctypes = data[phonenum[6]][1]
  rescue
    return ""
  end
  species = pbRandomEncounterSpecies(enctypes[EncounterTypes::Land])
  species = pbRandomEncounterSpecies(enctypes[EncounterTypes::Cave]) if species==0
  species = pbRandomEncounterSpecies(enctypes[EncounterTypes::LandDay]) if species==0
  species = pbRandomEncounterSpecies(enctypes[EncounterTypes::LandMorning]) if species==0
  species = pbRandomEncounterSpecies(enctypes[EncounterTypes::LandNight]) if species==0
  species = pbRandomEncounterSpecies(enctypes[EncounterTypes::Water]) if species==0
  return "" if species==0
  return PBSpecies.getName(species)
end

def pbLoadTrainerData(trainerid,trainername,partyid=0)
  ret = nil
  trainers = load_data("Data/trainers.dat")
  for trainer in trainers
    name = trainer[1]
    thistrainerid = trainer[0]
    thispartyid   = trainer[4]
    if trainerid==thistrainerid && name==trainername && partyid==thispartyid
      ret = trainer
      break
    end
  end
  return ret
end

def pbTrainerSpecies(phonenum)
  return "" if !phonenum[0]
  partyid = [0,(phonenum[5]-1)].max
  trainer = pbLoadTrainerData(phonenum[1],phonenum[2],partyid)
  return "" if !trainer || trainer[3].length==0
  rndpoke = trainer[3][rand(trainer[3].length)]
  return PBSpecies.getName(rndpoke[0])
end

def pbTrainerMapName(phonenum)
  return "" if !phonenum[6] || phonenum[6]==0
  return pbGetMessage(MessageTypes::MapNames,phonenum[6])
end

#===============================================================================
# The phone call itself
#===============================================================================
def pbPhoneCall(call,phonenum)
  Kernel.pbMessage(_INTL("......\\wt[5] ......\\1"))
  encspecies     = pbEncounterSpecies(phonenum)
  trainerspecies = pbTrainerSpecies(phonenum)
  trainermap     = pbTrainerMapName(phonenum)
  messages = call.split("\\m")
  for i in 0...messages.length
    messages[i].gsub!(/\\TN/,phonenum[2])
    messages[i].gsub!(/\\TP/,trainerspecies)
    messages[i].gsub!(/\\TE/,encspecies)
    messages[i].gsub!(/\\TM/,trainermap)
    messages[i] += "\\1" if i<messages.length-1
    Kernel.pbMessage(messages[i])
  end
  Kernel.pbMessage(_INTL("Click!\\wt[10]\n......\\wt[5] ......\\1"))
end