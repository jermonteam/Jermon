class MoveSelectionSprite < SpriteWrapper
  attr_reader :preselected
  attr_reader :index

  def initialize(viewport=nil,fifthmove=false)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/Pictures/Summary/cursor_move")
    @frame = 0
    @index = 0
    @fifthmove = fifthmove
    @preselected = false
    @updating = false
    refresh
  end

  def dispose
    @movesel.dispose
    super
  end

  def index=(value)
    @index = value
    refresh
  end

  def preselected=(value)
    @preselected = value
    refresh
  end

  def refresh
    w = @movesel.width
    h = @movesel.height/2
    self.x = 240
    self.y = 92+(self.index*64)
    self.y -= 76 if @fifthmove
    self.y += 20 if @fifthmove && self.index==4
    self.bitmap = @movesel.bitmap
    if self.preselected
      self.src_rect.set(0,h,w,h)
    else
      self.src_rect.set(0,0,w,h)
    end
  end

  def update
    @updating = true
    super
    @movesel.update
    @updating = false
    refresh
  end
end



class RibbonSelectionSprite < MoveSelectionSprite
  def initialize(viewport=nil)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/Pictures/Summary/cursor_ribbon")
    @frame = 0
    @index = 0
    @preselected = false
    @updating = false
    @spriteVisible = true
    refresh
  end

  def visible=(value)
    super
    @spriteVisible = value if !@updating
  end

  def refresh
    w = @movesel.width
    h = @movesel.height/2
    self.x = 228+(self.index%4)*68
    self.y = 76+((self.index/4).floor*68)
    self.bitmap = @movesel.bitmap
    if self.preselected
      self.src_rect.set(0,h,w,h)
    else
      self.src_rect.set(0,0,w,h)
    end
  end

  def update
    @updating = true
    super
    self.visible = @spriteVisible && @index>=0 && @index<12
    @movesel.update
    @updating = false
    refresh
  end
end



class PokemonSummary_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(party,partyindex)
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @party      = party
    @partyindex = partyindex
    @pokemon    = @party[@partyindex]
    @page = 1
    @typebitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Summary/markings")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::Center)
    @sprites["pokemon"].x = 104
    @sprites["pokemon"].y = 206
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon,@viewport)
    @sprites["pokeicon"].x       = 14
    @sprites["pokeicon"].y       = 52
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"] = ItemIconSprite.new(30,320,@pokemon.item,@viewport)
    @sprites["itemicon"].blankzero = true
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible     = false
    @sprites["movepresel"].preselected = true
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible = false
    @sprites["ribbonpresel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonpresel"].visible     = false
    @sprites["ribbonpresel"].preselected = true
    @sprites["ribbonsel"] = RibbonSelectionSprite.new(@viewport)
    @sprites["ribbonsel"].visible = false
    @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
    @sprites["uparrow"].x = 350
    @sprites["uparrow"].y = 56
    @sprites["uparrow"].play
    @sprites["uparrow"].visible = false
    @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
    @sprites["downarrow"].x = 350
    @sprites["downarrow"].y = 260
    @sprites["downarrow"].play
    @sprites["downarrow"].visible = false
    @sprites["markingbg"] = IconSprite.new(260,88,@viewport)
    @sprites["markingbg"].setBitmap("Graphics/Pictures/Summary/overlay_marking")
    @sprites["markingbg"].visible = false
    @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["markingoverlay"].visible = false
    pbSetSystemFont(@sprites["markingoverlay"].bitmap)
    @sprites["markingsel"] = IconSprite.new(0,0,@viewport)
    @sprites["markingsel"].setBitmap("Graphics/Pictures/Summary/cursor_marking")
    @sprites["markingsel"].src_rect.height = @sprites["markingsel"].bitmap.height/2
    @sprites["markingsel"].visible = false
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"],2)
    drawPage(@page)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartForgetScene(party,partyindex,moveToLearn)
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @party      = party
    @partyindex = partyindex
    @pokemon    = @party[@partyindex]
    @page = 4
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon,@viewport)
    @sprites["pokeicon"].x      = 14
    @sprites["pokeicon"].y      = 52
    @sprites["movesel"] = MoveSelectionSprite.new(@viewport,moveToLearn>0)
    @sprites["movesel"].visible = false
    @sprites["movesel"].visible = true
    @sprites["movesel"].index   = 0
    drawSelectedMove(moveToLearn,@pokemon.moves[0].id)
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @markingbitmap.dispose if @markingbitmap
    @viewport.dispose
  end

  def pbDisplay(text)
    @sprites["messagebox"].text = text
    @sprites["messagebox"].visible = true
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["messagebox"].busy?
        if Input.trigger?(Input::C)
          pbPlayDecisionSE() if @sprites["messagebox"].pausing?
          @sprites["messagebox"].resume
        end
      elsif Input.trigger?(Input::C) || Input.trigger?(Input::B)
        break
      end
    end
    @sprites["messagebox"].visible = false
  end

  def pbConfirm(text)
    ret = -1
    @sprites["messagebox"].text    = text
    @sprites["messagebox"].visible = true
    using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"),_INTL("No")])){
      cmdwindow.z       = @viewport.z+1
      cmdwindow.visible = false
      pbBottomRight(cmdwindow)
      cmdwindow.y -= @sprites["messagebox"].height
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible = true if !@sprites["messagebox"].busy?
        cmdwindow.update
        pbUpdate
        if !@sprites["messagebox"].busy?
          if Input.trigger?(Input::B)
            ret = false
            break
          elsif Input.trigger?(Input::C) && @sprites["messagebox"].resume
            ret = (cmdwindow.index==0)
            break
          end
        end
      end
    }
    @sprites["messagebox"].visible = false
    return ret
  end

  def pbShowCommands(commands,index=0)
    ret = -1
    using(cmdwindow = Window_CommandPokemon.new(commands)) {
       cmdwindow.z = @viewport.z+1
       cmdwindow.index = index
       pbBottomRight(cmdwindow)
       loop do
         Graphics.update
         Input.update
         cmdwindow.update
         pbUpdate
         if Input.trigger?(Input::B)
           pbPlayCancelSE
           ret = -1
           break
         elsif Input.trigger?(Input::C)
           pbPlayDecisionSE
           ret = cmdwindow.index
           break
         end
       end
    }
    return ret
  end

  def drawMarkings(bitmap,x,y)
    markings = @pokemon.markings
    markrect = Rect.new(0,0,16,16)
    for i in 0...6
      markrect.x = i*16
      markrect.y = (markings&(1<<i)!=0) ? 16 : 0
      bitmap.blt(x+i*16,y,@markingbitmap.bitmap,markrect)
    end
  end

  def drawPage(page)
    if @pokemon.egg?
      drawPageOneEgg; return
    end
    @sprites["itemicon"].item = @pokemon.item
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_#{page}")
    imagepos=[]
    # Show the Jermo Ball containing the Jermon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    # Show status/fainted/Jermorus infected icon
    status = -1
    status = 6 if @pokemon.pokerusStage==1
    status = @pokemon.status-1 if @pokemon.status>0
    status = 5 if @pokemon.hp==0
    if status>=0
      imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    # Show Jermorus cured icon
    if @pokemon.pokerusStage==2
      imagepos.push([sprintf("Graphics/Pictures/Summary/icon_pokerus"),176,100,0,0,-1,-1])
    end
    # Show shininess star
    if @pokemon.isShiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134,0,0,-1,-1])
    end
    # Draw all images
    pbDrawImagePositions(overlay,imagepos)
    textpos = []
    # Write various bits of text
    pagename = [_INTL("INFO"),
                _INTL("TRAINER MEMO"),
                _INTL("SKILLS"),
                _INTL("MOVES"),
                _INTL("RIBBONS")][page-1]
    textpos = [
       [pagename,26,16,0,base,shadow],
       [@pokemon.name,46,62,0,base,shadow],
       [@pokemon.level.to_s,46,92,0,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Item"),66,318,0,base,shadow]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([PBItems.getName(@pokemon.item),16,352,0,Color.new(64,64,64),Color.new(176,176,176)])
    else
      textpos.push([_INTL("None"),16,352,0,Color.new(192,200,208),Color.new(208,216,224)])
    end
    # Write the gender symbol
    if @pokemon.isMale?
      textpos.push([_INTL("♂"),178,62,0,Color.new(24,112,216),Color.new(136,168,208)])
    elsif @pokemon.isFemale?
      textpos.push([_INTL("♀"),178,62,0,Color.new(248,56,32),Color.new(224,152,144)])
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Draw the Jermon's markings
    drawMarkings(overlay,84,292)
    # Draw page-specific information
    case page
    when 1; drawPageOne
    when 2; drawPageTwo
    when 3; drawPageThree
    when 4; drawPageFour
    when 5; drawPageFive
    end
  end

  def drawPageOne
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    dexNumBase   = (@pokemon.isShiny?) ? Color.new(248,56,32) : Color.new(64,64,64)
    dexNumShadow = (@pokemon.isShiny?) ? Color.new(224,152,144) : Color.new(176,176,176)
    # If a Shadow Jermon, draw the heart gauge area and bar
    if (@pokemon.isShadow? rescue false)
      shadowfract = @pokemon.heartgauge*1.0/PokeBattle_Pokemon::HEARTGAUGESIZE
      imagepos = [
         ["Graphics/Pictures/Summary/overlay_shadow",224,240,0,0,-1,-1],
         ["Graphics/Pictures/Summary/overlay_shadowbar",242,280,0,0,(shadowfract*248).floor,-1]
      ]
      pbDrawImagePositions(overlay,imagepos)
    end
    # Write various bits of text
    textpos = [
       [_INTL("Dex No."),238,80,0,base,shadow],
       [_INTL("Species"),238,112,0,base,shadow],
       [PBSpecies.getName(@pokemon.species),435,112,2,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Type"),238,144,0,base,shadow],
       [_INTL("OT"),238,176,0,base,shadow],
       [_INTL("ID No."),238,208,0,base,shadow],
    ]
    # Write the Regional/National Dex number
    dexnum = @pokemon.species
    dexnumshift = false
    if $PokemonGlobal.pokedexUnlocked[$PokemonGlobal.pokedexUnlocked.length-1]
      dexnumshift = true if DEXINDEXOFFSETS.include?(-1)
    else
      dexnum = 0
      for i in 0...$PokemonGlobal.pokedexUnlocked.length-1
        if $PokemonGlobal.pokedexUnlocked[i]
          num = pbGetRegionalNumber(i,@pokemon.species)
          if num>0
            dexnum = num
            dexnumshift = true if DEXINDEXOFFSETS.include?(i)
            break
          end
        end
      end
    end
    if dexnum<=0
      textpos.push(["???",435,80,2,dexNumBase,dexNumShadow])
    else
      dexnum -= 1 if dexnumshift
      textpos.push([sprintf("%03d",dexnum),435,80,2,dexNumBase,dexNumShadow])
    end
    # Write Original Trainer's name and ID number
    if @pokemon.ot==""
      textpos.push([_INTL("RENTAL"),435,176,2,Color.new(64,64,64),Color.new(176,176,176)])
      textpos.push(["?????",435,208,2,Color.new(64,64,64),Color.new(176,176,176)])
    else
      ownerbase   = Color.new(64,64,64)
      ownershadow = Color.new(176,176,176)
      case @pokemon.otgender
      when 0; ownerbase = Color.new(24,112,216); ownershadow = Color.new(136,168,208)
      when 1; ownerbase = Color.new(248,56,32);  ownershadow = Color.new(224,152,144)
      end
      textpos.push([@pokemon.ot,435,176,2,ownerbase,ownershadow])
      textpos.push([sprintf("%05d",@pokemon.publicID),435,208,2,Color.new(64,64,64),Color.new(176,176,176)])
    end
    # Write Exp text OR heart gauge message (if a Shadow Jermon)
    growthrate = @pokemon.growthrate
    startexp = PBExperience.pbGetStartExperience(@pokemon.level,growthrate)
    endexp   = PBExperience.pbGetStartExperience(@pokemon.level+1,growthrate)
    if (@pokemon.isShadow? rescue false)
      textpos.push([_INTL("Heart Gauge"),238,240,0,base,shadow])
      heartmessage = [_INTL("The door to its heart is open! Undo the final lock!"),
                      _INTL("The door to its heart is almost fully open."),
                      _INTL("The door to its heart is nearly open."),
                      _INTL("The door to its heart is opening wider."),
                      _INTL("The door to its heart is opening up."),
                      _INTL("The door to its heart is tightly shut.")][@pokemon.heartStage]
      memo = sprintf("<c3=404040,B0B0B0>%s\n",heartmessage)
      drawFormattedTextEx(overlay,234,304,264,memo)
    else
      textpos.push([_INTL("Exp. Points"),238,240,0,base,shadow])
      textpos.push([pbCommaNumber(@pokemon.exp),488,272,1,Color.new(64,64,64),Color.new(176,176,176)])
      textpos.push([_INTL("To Next Lv."),238,304,0,base,shadow])
      textpos.push([pbCommaNumber(endexp-@pokemon.exp),488,336,1,Color.new(64,64,64),Color.new(176,176,176)])
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Draw Jermon type(s)
    type1rect = Rect.new(0,@pokemon.type1*28,64,28)
    type2rect = Rect.new(0,@pokemon.type2*28,64,28)
    if @pokemon.type1==@pokemon.type2
      overlay.blt(402,146,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(370,146,@typebitmap.bitmap,type1rect)
      overlay.blt(436,146,@typebitmap.bitmap,type2rect)
    end
    # Draw Exp bar
    if @pokemon.level<PBExperience::MAXLEVEL
      pbDrawImagePositions(overlay,[
         ["Graphics/Pictures/Summary/overlay_exp",362,372,0,0,(@pokemon.exp-startexp)*128/(endexp-startexp),6]
      ])
    end
  end

  def drawPageOneEgg
    @sprites["itemicon"].item = @pokemon.item
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    pbSetSystemFont(overlay)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_egg")
    imagepos = []
    # Show the Jermo Ball containing the Jermon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%02d",@pokemon.ballused)
    imagepos.push([ballimage,14,60,0,0,-1,-1])
    # Draw all images
    pbDrawImagePositions(overlay,imagepos)
    # Write various bits of text
    textpos=[
       [_INTL("TRAINER MEMO"),26,16,0,base,shadow],
       [@pokemon.name,46,62,0,base,shadow],
       [_INTL("Item"),62,318,0,base,shadow]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([PBItems.getName(@pokemon.item),16,352,0,Color.new(64,64,64),Color.new(176,176,176)])
    else
      textpos.push([_INTL("None"),16,352,0,Color.new(184,184,160),Color.new(208,208,200)])
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    memo = ""
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n",date,month,year)
    end
    # Write map name egg was received on
    mapname = pbGetMapNameFromId(@pokemon.obtainMap)
    if (@pokemon.obtainText rescue false) && @pokemon.obtainText!=""
      mapname=@pokemon.obtainText
    end
    if mapname && mapname!=""
      memo+=_INTL("<c3=404040,B0B0B0>A mysterious Jermon Egg received from <c3=F83820,E09890>{1}<c3=404040,B0B0B0>.\n",mapname)
    else
      memo+=_INTL("<c3=404040,B0B0B0>A mysterious Jermon Egg.\n",mapname)
    end
    memo+="\n" # Empty line
    # Write Egg Watch blurb
    memo += _INTL("<c3=404040,B0B0B0>\"The Egg Watch\"\n")
    eggstate = _INTL("It looks like this Egg will take a long time to hatch.")
    eggstate = _INTL("What will hatch from this? It doesn't seem close to hatching.") if @pokemon.eggsteps<10200
    eggstate = _INTL("It appears to move occasionally. It may be close to hatching.") if @pokemon.eggsteps<2550
    eggstate = _INTL("Sounds can be heard coming from inside! It will hatch soon!") if @pokemon.eggsteps<1275
    memo += sprintf("<c3=404040,B0B0B0>%s\n",eggstate)
    # Draw all text
    drawFormattedTextEx(overlay,232,78,268,memo)
    # Draw the Jermon's markings
    drawMarkings(overlay,82,292)
  end

  def drawPageTwo
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    memo = ""
    # Write nature
    shownature = !(@pokemon.isShadow? && @pokemon.heartStage<=3 rescue false)
    if shownature
      naturename = PBNatures.getName(@pokemon.nature)
      memo += _INTL("<c3=F83820,E09890>{1}<c3=404040,B0B0B0> nature.\n",naturename)
    end
    # Write date received
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n",date,month,year)
    end
    # Write map name Jermon was received on
    mapname = pbGetMapNameFromId(@pokemon.obtainMap)
    if (@pokemon.obtainText rescue false) && @pokemon.obtainText!=""
      mapname = @pokemon.obtainText
    end
    mapname = INTL("Faraway place") if !mapname || mapname==""
    memo += sprintf("<c3=F83820,E09890>%s\n",mapname)
    # Write how Jermon was obtained
    mettext = [_INTL("Met at Lv. {1}.",@pokemon.obtainLevel),
               _INTL("Egg received."),
               _INTL("Traded at Lv. {1}.",@pokemon.obtainLevel),
               "",
               _INTL("Had a fateful encounter at Lv. {1}.",@pokemon.obtainLevel)
              ][@pokemon.obtainMode]
    memo += sprintf("<c3=404040,B0B0B0>%s\n",mettext) if mettext && mettext!=""
    # If Jermon was hatched, write when and where it hatched
    if @pokemon.obtainMode==1
      if @pokemon.timeEggHatched
        date  = @pokemon.timeEggHatched.day
        month = pbGetMonthName(@pokemon.timeEggHatched.mon)
        year  = @pokemon.timeEggHatched.year
        memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n",date,month,year)
      end
      mapname = pbGetMapNameFromId(@pokemon.hatchedMap)
      mapname = INTL("Faraway place") if !mapname || mapname==""
      memo += sprintf("<c3=F83820,E09890>%s\n",mapname)
      memo += _INTL("<c3=404040,B0B0B0>Egg hatched.\n")
    else
      memo += "\n" # Empty line
    end
    # Write characteristic
    if shownature
      bestiv     = 0
      tiebreaker = @pokemon.personalID%6
      for i in 0...6
        if @pokemon.iv[i]==@pokemon.iv[bestiv]
          bestiv = i if i>=tiebreaker && bestiv<tiebreaker
        elsif @pokemon.iv[i]>@pokemon.iv[bestiv]
          bestiv = i
        end
      end
      characteristic = [_INTL("Loves to eat."),
                        _INTL("Often dozes off."),
                        _INTL("Often scatters things."),
                        _INTL("Scatters things often."),
                        _INTL("Likes to relax."),
                        _INTL("Proud of its power."),
                        _INTL("Likes to thrash about."),
                        _INTL("A little quick tempered."),
                        _INTL("Likes to fight."),
                        _INTL("Quick tempered."),
                        _INTL("Sturdy body."),
                        _INTL("Capable of taking hits."),
                        _INTL("Highly persistent."),
                        _INTL("Good endurance."),
                        _INTL("Good perseverance."),
                        _INTL("Likes to run."),
                        _INTL("Alert to sounds."),
                        _INTL("Impetuous and silly."),
                        _INTL("Somewhat of a clown."),
                        _INTL("Quick to flee."),
                        _INTL("Highly curious."),
                        _INTL("Mischievous."),
                        _INTL("Thoroughly cunning."),
                        _INTL("Often lost in thought."),
                        _INTL("Very finicky."),
                        _INTL("Strong willed."),
                        _INTL("Somewhat vain."),
                        _INTL("Strongly defiant."),
                        _INTL("Hates to lose."),
                        _INTL("Somewhat stubborn.")
                       ][bestiv*5+@pokemon.iv[bestiv]%5]
      memo += sprintf("<c3=404040,B0B0B0>%s\n",characteristic)
    end
    # Write all text
    drawFormattedTextEx(overlay,232,78,268,memo)
  end

  def drawPageThree
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    # Determine which stats are boosted and lowered by the Jermon's nature
    statshadows = []
    for i in 0...5; statshadows[i] = shadow; end
    if !(@pokemon.isShadow? && @pokemon.heartStage<=3 rescue false)
      natup = (@pokemon.nature/5).floor
      natdn = (@pokemon.nature%5).floor
      statshadows[natup] = Color.new(136,96,72) if natup!=natdn
      statshadows[natdn] = Color.new(64,120,152) if natup!=natdn
    end
    # Write various bits of text
    textpos = [
       [_INTL("HP"),292,76,2,base,shadow],
       [sprintf("%d/%d",@pokemon.hp,@pokemon.totalhp),462,76,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Attack"),248,120,0,base,statshadows[0]],
       [sprintf("%d",@pokemon.attack),456,120,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Defense"),248,152,0,base,statshadows[1]],
       [sprintf("%d",@pokemon.defense),456,152,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Atk"),248,184,0,base,statshadows[3]],
       [sprintf("%d",@pokemon.spatk),456,184,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Def"),248,216,0,base,statshadows[4]],
       [sprintf("%d",@pokemon.spdef),456,216,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Speed"),248,248,0,base,statshadows[2]],
       [sprintf("%d",@pokemon.speed),456,248,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Ability"),224,284,0,base,shadow],
       [PBAbilities.getName(@pokemon.ability),362,284,0,Color.new(64,64,64),Color.new(176,176,176)],
    ]
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Draw ability description
    abilitydesc = pbGetMessage(MessageTypes::AbilityDescs,@pokemon.ability)
    drawTextEx(overlay,224,316,282,2,abilitydesc,Color.new(64,64,64),Color.new(176,176,176))
    # Draw HP bar
    if @pokemon.hp>0
      hpzone = 0
      hpzone = 1 if @pokemon.hp<=(@pokemon.totalhp/2).floor
      hpzone = 2 if @pokemon.hp<=(@pokemon.totalhp/4).floor
      imagepos = [
         ["Graphics/Pictures/Summary/overlay_hp",360,110,0,hpzone*6,@pokemon.hp*96/@pokemon.totalhp,6]
      ]
      pbDrawImagePositions(overlay,imagepos)
    end
  end

  def drawPageFour
    overlay = @sprites["overlay"].bitmap
    moveBase   = Color.new(64,64,64)
    moveShadow = Color.new(176,176,176)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248,192,0),    # 1/2 of total PP or less
                Color.new(248,136,32),   # 1/4 of total PP or less
                Color.new(248,72,72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144,104,0),   # 1/2 of total PP or less
                Color.new(144,72,24),   # 1/4 of total PP or less
                Color.new(136,48,48)]   # Zero PP
    @sprites["pokemon"].visible  = true
    @sprites["pokeicon"].visible = false
    @sprites["itemicon"].visible = true
    textpos  = []
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 98
    for i in 0...@pokemon.moves.length
      move=@pokemon.moves[i]
      if move.id>0
        imagepos.push(["Graphics/Pictures/types",248,yPos+2,0,move.type*28,64,28])
        textpos.push([PBMoves.getName(move.id),316,yPos,0,moveBase,moveShadow])
        if move.totalpp>0
          textpos.push([_INTL("PP"),342,yPos+32,0,moveBase,moveShadow])
          ppfraction = 0
          if move.pp==0;                 ppfraction = 3
          elsif move.pp*4<=move.totalpp; ppfraction = 2
          elsif move.pp*2<=move.totalpp; ppfraction = 1
          end
          textpos.push([sprintf("%d/%d",move.pp,move.totalpp),460,yPos+32,1,ppBase[ppfraction],ppShadow[ppfraction]])
        end
      else
        textpos.push(["-",316,yPos,0,moveBase,moveShadow])
        textpos.push(["--",442,yPos+32,1,moveBase,moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay,textpos)
    pbDrawImagePositions(overlay,imagepos)
  end

  def drawSelectedMove(moveToLearn,moveid)
    # Draw all of page four, except selected move's details
    drawMoveSelection(moveToLearn)
    # Set various values
    overlay = @sprites["overlay"].bitmap
    pbSetSystemFont(overlay)
    base   = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
    @sprites["pokemon"].visible = false if @sprites["pokemon"]
    @sprites["pokeicon"].pokemon  = @pokemon
    @sprites["pokeicon"].visible  = true
    @sprites["itemicon"].visible  = false if @sprites["itemicon"]
    # Get data for selected move
    movedata = PBMoveData.new(moveid)
    basedamage = movedata.basedamage
    type       = movedata.type
    category   = movedata.category
    accuracy   = movedata.accuracy
    move = moveid
    textpos = []
    # Write power and accuracy values for selected move
    if basedamage==0 # Status move
      textpos.push(["---",216,154,1,base,shadow])
    elsif basedamage==1 # Variable power move
      textpos.push(["???",216,154,1,base,shadow])
    else
      textpos.push([sprintf("%d",basedamage),216,154,1,base,shadow])
    end
    if accuracy==0
      textpos.push(["---",216,186,1,base,shadow])
    else
      textpos.push([sprintf("%d%",accuracy),216+overlay.text_size("%").width,186,1,base,shadow])
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Draw selected move's damage category icon
    imagepos = [["Graphics/Pictures/category",166,124,0,category*28,64,28]]
    pbDrawImagePositions(overlay,imagepos)
    # Draw selected move's description
    drawTextEx(overlay,4,218,230,5,
       pbGetMessage(MessageTypes::MoveDescriptions,moveid),base,shadow)
  end

  def drawMoveSelection(moveToLearn)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    moveBase   = Color.new(64,64,64)
    moveShadow = Color.new(176,176,176)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248,192,0),    # 1/2 of total PP or less
                Color.new(248,136,32),   # 1/4 of total PP or less
                Color.new(248,72,72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144,104,0),   # 1/2 of total PP or less
                Color.new(144,72,24),   # 1/4 of total PP or less
                Color.new(136,48,48)]   # Zero PP
    pbSetSystemFont(overlay)
    # Set background image
    if moveToLearn!=0
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_learnmove")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_movedetail")
    end
    # Write various bits of text
    textpos = [
       [_INTL("MOVES"),26,16,0,base,shadow],
       [_INTL("CATEGORY"),20,122,0,base,shadow],
       [_INTL("POWER"),20,154,0,base,shadow],
       [_INTL("ACCURACY"),20,186,0,base,shadow]
    ]
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 98
    yPos -= 76 if moveToLearn!=0
    for i in 0...5
      move = @pokemon.moves[i]
      if i==4
        move = PBMove.new(moveToLearn) if moveToLearn!=0
        yPos += 20
      end
      if move && move.id>0
        imagepos.push(["Graphics/Pictures/types",248,yPos+2,0,move.type*28,64,28])
        textpos.push([PBMoves.getName(move.id),316,yPos,0,moveBase,moveShadow])
        if move.totalpp>0
          textpos.push([_INTL("PP"),342,yPos+32,0,moveBase,moveShadow])
          ppfraction = 0
          if move.pp==0;                 ppfraction = 3
          elsif move.pp*4<=move.totalpp; ppfraction = 2
          elsif move.pp*2<=move.totalpp; ppfraction = 1
          end
          textpos.push([sprintf("%d/%d",move.pp,move.totalpp),460,yPos+32,1,ppBase[ppfraction],ppShadow[ppfraction]])
        end
      else
        textpos.push(["-",316,yPos,0,moveBase,moveShadow])
        textpos.push(["--",442,yPos+32,1,moveBase,moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay,textpos)
    pbDrawImagePositions(overlay,imagepos)
    # Draw Jermon's type icon(s)
    type1rect = Rect.new(0,@pokemon.type1*28,64,28)
    type2rect = Rect.new(0,@pokemon.type2*28,64,28)
    if @pokemon.type1==@pokemon.type2
      overlay.blt(130,78,@typebitmap.bitmap,type1rect)
    else
      overlay.blt(96,78,@typebitmap.bitmap,type1rect)
      overlay.blt(166,78,@typebitmap.bitmap,type2rect)
    end
  end

  def drawPageFive
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
    # Write various bits of text
    textpos = [
       [_INTL("No. of Ribbons:"),234,332,0,Color.new(64,64,64),Color.new(176,176,176)],
       [@pokemon.ribbonCount.to_s,450,332,1,Color.new(64,64,64),Color.new(176,176,176)],
    ]
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Show all ribbons
    imagepos = []
    coord = 0
    if @pokemon.ribbons
      for i in @ribbonOffset*4...@ribbonOffset*4+12
        break if !@pokemon.ribbons[i]
        ribn = @pokemon.ribbons[i]-1
        imagepos.push(["Graphics/Pictures/ribbons",230+68*(coord%4),78+68*(coord/4).floor,
                                                   64*(ribn%8),64*(ribn/8).floor,64,64])
        coord += 1
        break if coord>=12
      end
    end
    # Draw all images
    pbDrawImagePositions(overlay,imagepos)
  end

  def drawSelectedRibbon(ribbonid)
    # Draw all of page five
    drawPage(5)
    # Set various values
    overlay = @sprites["overlay"].bitmap
    pbSetSystemFont(overlay)
    base   = Color.new(64,64,64)
    shadow = Color.new(176,176,176)
    nameBase   = Color.new(248,248,248)
    nameShadow = Color.new(104,104,104)
    # Get data for selected ribbon
    name = ribbonid ? PBRibbons.getName(ribbonid) : ""
    desc = ribbonid ? PBRibbons.getDescription(ribbonid) : ""
    # Draw the description box
    imagepos = [
       ["Graphics/Pictures/Summary/overlay_ribbon",8,280,0,0,-1,-1]
    ]
    pbDrawImagePositions(overlay,imagepos)
    # Draw name of selected ribbon
    textpos = [
       [name,18,286,0,nameBase,nameShadow]
    ]
    pbDrawTextPositions(overlay,textpos)
    # Draw selected ribbon's description
    drawTextEx(overlay,18,318,480,2,desc,base,shadow)
  end

  def pbGoToPrevious
    newindex = @partyindex
    while newindex>0
      newindex -= 1
      if @party[newindex] && (@page==1 || !@party[newindex].egg?)
        @partyindex = newindex
        break
      end
    end
  end

  def pbGoToNext
    newindex = @partyindex
    while newindex<@party.length-1
      newindex += 1
      if @party[newindex] && (@page==1 || !@party[newindex].egg?)
        @partyindex = newindex
        break
      end
    end
  end

  def pbMoveSelection
    @sprites["movesel"].visible = true
    @sprites["movesel"].index   = 0
    selmove    = 0
    oldselmove = 0
    switching = false
    drawSelectedMove(0,@pokemon.moves[selmove].id)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["movepresel"].index==@sprites["movesel"].index
        @sprites["movepresel"].z = @sprites["movesel"].z+1
      else
        @sprites["movepresel"].z = @sprites["movesel"].z
      end
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        break if !switching
        @sprites["movepresel"].visible = false
        switching = false
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        if selmove==4
          break if !switching
          @sprites["movepresel"].visible = false
          switching = false
        else
          if !(@pokemon.isShadow? rescue false)
            if !switching
              @sprites["movepresel"].index   = selmove
              @sprites["movepresel"].visible = true
              oldselmove = selmove
              switching = true
            else
              tmpmove                    = @pokemon.moves[oldselmove]
              @pokemon.moves[oldselmove] = @pokemon.moves[selmove]
              @pokemon.moves[selmove]    = tmpmove
              @sprites["movepresel"].visible = false
              switching = false
              drawSelectedMove(0,@pokemon.moves[selmove].id)
            end
          end
        end
      elsif Input.trigger?(Input::UP)
        selmove -= 1
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove = @pokemon.numMoves-1
        end
        selmove = 0 if selmove>=4
        selmove = @pokemon.numMoves-1 if selmove<0
        @sprites["movesel"].index = selmove
        newmove = @pokemon.moves[selmove].id
        pbPlayCursorSE
        drawSelectedMove(0,newmove)
      elsif Input.trigger?(Input::DOWN)
        selmove += 1
        selmove = 0 if selmove<4 && selmove>=@pokemon.numMoves
        selmove = 0 if selmove>=4
        selmove = 4 if selmove<0
        @sprites["movesel"].index = selmove
        newmove = @pokemon.moves[selmove].id
        pbPlayCursorSE
        drawSelectedMove(0,newmove)
      end
    end
    @sprites["movesel"].visible=false
  end

  def pbRibbonSelection
    @sprites["ribbonsel"].visible = true
    @sprites["ribbonsel"].index   = 0
    selribbon    = @ribbonOffset*4
    oldselribbon = selribbon
    switching = false
    numRibbons = @pokemon.ribbons.length
    numRows    = [((numRibbons+3)/4).floor,3].max
    drawSelectedRibbon(@pokemon.ribbons[selribbon])
    loop do
      @sprites["uparrow"].visible   = (@ribbonOffset>0)
      @sprites["downarrow"].visible = (@ribbonOffset<numRows-3)
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["ribbonpresel"].index==@sprites["ribbonsel"].index
        @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z+1
      else
        @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z
      end
      hasMovedCursor = false
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        break if !switching
        @sprites["ribbonpresel"].visible = false
        switching = false
      elsif Input.trigger?(Input::C)
        if !switching
          if @pokemon.ribbons[selribbon]
            pbPlayDecisionSE
            @sprites["ribbonpresel"].index = selribbon-@ribbonOffset*4
            oldselribbon = selribbon
            @sprites["ribbonpresel"].visible = true
            switching = true
          end
        else
          pbPlayDecisionSE
          tmpribbon                      = @pokemon.ribbons[oldselribbon]
          @pokemon.ribbons[oldselribbon] = @pokemon.ribbons[selribbon]
          @pokemon.ribbons[selribbon]    = tmpribbon
          if @pokemon.ribbons[oldselribbon] || @pokemon.ribbons[selribbon]
            @pokemon.ribbons.compact!
            if selribbon>=numRibbons
              selribbon = numRibbons-1
              hasMovedCursor = true
            end
          end
          @sprites["ribbonpresel"].visible = false
          switching = false
          drawSelectedRibbon(@pokemon.ribbons[selribbon])
        end
      elsif Input.trigger?(Input::UP)
        selribbon -= 4
        selribbon += numRows*4 if selribbon<0
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        selribbon += 4
        selribbon -= numRows*4 if selribbon>=numRows*4
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::LEFT)
        selribbon -= 1
        selribbon += 4 if selribbon%4==3
        hasMovedCursor = true
        pbPlayCursorSE
      elsif Input.trigger?(Input::RIGHT)
        selribbon += 1
        selribbon -= 4 if selribbon%4==0
        hasMovedCursor = true
        pbPlayCursorSE
      end
      if hasMovedCursor
        @ribbonOffset = (selribbon/4).floor if selribbon<@ribbonOffset*4
        @ribbonOffset = (selribbon/4).floor-2 if selribbon>=(@ribbonOffset+3)*4
        @ribbonOffset = 0 if @ribbonOffset<0
        @ribbonOffset = numRows-3 if @ribbonOffset>numRows-3
        @sprites["ribbonsel"].index    = selribbon-@ribbonOffset*4
        @sprites["ribbonpresel"].index = oldselribbon-@ribbonOffset*4
        drawSelectedRibbon(@pokemon.ribbons[selribbon])
      end
    end
    @sprites["ribbonsel"].visible = false
  end

  def pbMarking(pokemon)
    @sprites["markingbg"].visible      = true
    @sprites["markingoverlay"].visible = true
    @sprites["markingsel"].visible     = true
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    ret = pokemon.markings
    markings = pokemon.markings
    index = 0
    redraw = true
    markrect = Rect.new(0,0,16,16)
    loop do
      # Redraw the markings and text
      if redraw
        @sprites["markingoverlay"].bitmap.clear
        for i in 0...6
          markrect.x = i*16
          markrect.y = (markings&(1<<i)!=0) ? 16 : 0
          @sprites["markingoverlay"].bitmap.blt(300+58*(i%3),154+50*(i/3),@markingbitmap.bitmap,markrect)
        end
        textpos = [
           [_INTL("Mark {1}",pokemon.name),366,96,2,base,shadow],
           [_INTL("OK"),366,248,2,base,shadow],
           [_INTL("Cancel"),366,298,2,base,shadow]
        ]
        pbDrawTextPositions(@sprites["markingoverlay"].bitmap,textpos)
        redraw = false
      end
      # Reposition the cursor
      @sprites["markingsel"].x = 284+58*(index%3)
      @sprites["markingsel"].y = 144+50*(index/3)
      if index==6 # OK
        @sprites["markingsel"].x = 284
        @sprites["markingsel"].y = 244
        @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height/2
      elsif index==7 # Cancel
        @sprites["markingsel"].x = 284
        @sprites["markingsel"].y = 294
        @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height/2
      else
        @sprites["markingsel"].src_rect.y = 0
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        if index==6 # OK
          ret = markings
          break
        elsif index==7 # Cancel
          break
        else
          mask = (1<<index)
          if (markings&mask)==0
            markings |= mask
          else
            markings &= ~mask
          end
          redraw = true
        end
      elsif Input.trigger?(Input::UP)
        if index==7; index = 6
        elsif index==6; index = 4
        elsif index<3; index = 7
        else; index -= 3
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        if index==7; index = 1
        elsif index==6; index = 7
        elsif index>=3; index = 6
        else; index += 3
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::LEFT)
        if index<6
          index -= 1
          index += 3 if index%3==2
          pbPlayCursorSE
        end
      elsif Input.trigger?(Input::RIGHT)
        if index<6
          index += 1
          index -= 3 if index%3==0
          pbPlayCursorSE
        end
      end
    end
    @sprites["markingbg"].visible      = false
    @sprites["markingoverlay"].visible = false
    @sprites["markingsel"].visible     = false
    if pokemon.markings!=ret
      pokemon.markings = ret
      return true
    end
    return false
  end

  def pbOptions
    dorefresh = false
    commands   = []
    cmdGiveItem = -1
    cmdTakeItem = -1
    cmdPokedex  = -1
    cmdMark     = -1
    commands[cmdGiveItem = commands.length] = _INTL("Give item")
    commands[cmdTakeItem = commands.length] = _INTL("Take item") if @pokemon.hasItem?
    commands[cmdPokedex = commands.length]  = _INTL("View Jermodex")
    commands[cmdMark = commands.length]     = _INTL("Mark")
    commands[commands.length]               = _INTL("Cancel")
    command = pbShowCommands(commands)
    if cmdGiveItem>=0 && command==cmdGiveItem
      item = 0
      pbFadeOutIn(99999){
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene,$PokemonBag)
        item = screen.pbChooseItemScreen(Proc.new{|item| pbCanHoldItem?(item) })
      }
      if item>0
        dorefresh = pbGiveItemToPokemon(item,@pokemon,self,@partyindex)
      end
    elsif cmdTakeItem>=0 && command==cmdTakeItem
      dorefresh = pbTakeItemFromPokemon(@pokemon,self)
    elsif cmdPokedex>=0 && command==cmdPokedex
      pbUpdateLastSeenForm(@pokemon)
      pbFadeOutIn(99999){
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbStartSceneSingle(@pokemon.species)
      }
      dorefresh = true
    elsif cmdMark>=0 && command==cmdMark
      dorefresh = pbMarking(@pokemon)
    end
    return dorefresh
  end

  def pbChooseMoveToForget(moveToLearn)
    selmove = 0
    maxmove = (moveToLearn>0) ? 4 : 3
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        selmove = 4
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::UP)
        selmove -= 1
        selmove = maxmove if selmove<0
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove = @pokemon.numMoves-1
        end
        @sprites["movesel"].index = selmove
        newmove = (selmove==4) ? moveToLearn : @pokemon.moves[selmove].id
        drawSelectedMove(moveToLearn,newmove)
      elsif Input.trigger?(Input::DOWN)
        selmove += 1
        selmove = 0 if selmove>maxmove
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove = (moveToLearn>0) ? maxmove : 0
        end
        @sprites["movesel"].index = selmove
        newmove = (selmove==4) ? moveToLearn : @pokemon.moves[selmove].id
        drawSelectedMove(moveToLearn,newmove)
      end
    end
    return (selmove==4) ? -1 : selmove
  end

  def pbScene
    pbPlayCry(@pokemon)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::A)
        pbSEStop; pbPlayCry(@pokemon)
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        if @page==4
          pbMoveSelection
          dorefresh = true
        elsif @page==5
          pbRibbonSelection
          dorefresh = true
        else
          dorefresh = pbOptions
        end
      elsif Input.trigger?(Input::UP) && @partyindex>0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          @pokemon = @party[@partyindex]
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["itemicon"].item = @pokemon.item
          pbSEStop; pbPlayCry(@pokemon)
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && @partyindex<@party.length-1
        oldindex = @partyindex
        pbGoToNext
        if @partyindex!=oldindex
          @pokemon = @party[@partyindex]
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["itemicon"].item = @pokemon.item
          pbSEStop; pbPlayCry(@pokemon)
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage = @page
        @page -= 1
        @page = 1 if @page<1
        @page = 5 if @page>5
        if @page!=oldpage # Move to next page
          pbPlayCursorSE
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage = @page
        @page += 1
        @page = 1 if @page<1
        @page = 5 if @page>5
        if @page!=oldpage # Move to next page
          pbPlayCursorSE
          @ribbonOffset = 0
          dorefresh = true
        end
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end
end



class PokemonSummaryScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(party,partyindex)
    @scene.pbStartScene(party,partyindex)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbStartForgetScreen(party,partyindex,moveToLearn)
    ret = -1
    @scene.pbStartForgetScene(party,partyindex,moveToLearn)
    loop do
      ret = @scene.pbChooseMoveToForget(moveToLearn)
      if ret>=0 && moveToLearn!=0 && pbIsHiddenMove?(party[partyindex].moves[ret].id) && !$DEBUG
        Kernel.pbMessage(_INTL("HM moves can't be forgotten now.")){ @scene.pbUpdate }
      else
        break
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbStartChooseMoveScreen(party,partyindex,message)
    ret = -1
    @scene.pbStartForgetScene(party,partyindex,0)
    Kernel.pbMessage(message){ @scene.pbUpdate }
    loop do
      ret = @scene.pbChooseMoveToForget(0)
      if ret<0
        Kernel.pbMessage(_INTL("You must choose a move!")){ @scene.pbUpdate }
      else
        break
      end
    end
    @scene.pbEndScene
    return ret
  end
end