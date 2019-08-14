#===============================================================================
# Day and night system
#===============================================================================

# Set false to disable this system (returns Time.now)
NTN_ENABLED=true 

# Make this true to time only pass at field (Scene_Map) 
# A note to scripters: To make time pass on other scenes, put line
# '$PokemonGlobal.addNewFrameCount' near to line 'Graphics.update'
NTN_TIMESTOPS=true 

# Make this true to time pass in battle, during turns and command selection.
# This won't affect the Jermon and Bag submenus.
# Only works if NTN_TIMESTOPS=true.
NTN_BATTLEPASS=true

# Make this true to time pass when the Dialog box or the main menu are open.
# This won't affect the submenus like Jermon and Bag.
# Only works if NTN_TIMESTOPS=true.
NTN_TALKPASS=true

# Time proportion here. 
# So if it is 100, one second in real time will be 100 seconds in game.
# If it is 60, one second in real time will be one minute in game.
NTS_TIMEPROPORTION=6

# Choose switch number that when true the time won't pass (or -1 to cancel). 
# Only works if NTN_TIMESTOPS=true.
NTN_SWITCHSTOPS=60

# Choose variable(s) number(s) that can hold time passage (or -1 to cancel).
# The time in this variable isn't affected by NTS_TIMEPROPORTION.
# Example: When the player sleeps you wish to the time in game advance
# 8 hours, so put in NTN_EXTRASECONDS a game variable number and sum 
# 28800 (60*60*8) in this variable every time that the players sleeps.
NTN_EXTRASECONDS=26
NTN_EXTRADAYS=27

# Initial values
NTN_INITIALYEAR=2019 # Can ONLY holds around range 1970-2038
NTN_INITIALMONTH=6
NTN_INITIALDAY=7
NTN_INITIALHOUR=12
NTN_INITIALMINUTE=0

def pbGetTimeNow(bewwie=false)
  return Time.now if !NTN_ENABLED
  
  if(NTN_TIMESTOPS)
    # Sum the extra values to newFrameCount
    if(NTN_EXTRASECONDS>0)
      $PokemonGlobal.newFrameCount+=(
        pbGet(NTN_EXTRASECONDS)*Graphics.frame_rate)/NTS_TIMEPROPORTION
      $game_variables[NTN_EXTRASECONDS]=0
    end  
    if(NTN_EXTRADAYS>0)
      $PokemonGlobal.newFrameCount+=((60*60*24)*
        pbGet(NTN_EXTRADAYS)*Graphics.frame_rate)/NTS_TIMEPROPORTION
      $game_variables[NTN_EXTRADAYS]=0
    end
  elsif(NTN_EXTRASECONDS>0 && NTN_EXTRADAYS>0)
    # Checks to regulate the max/min values at NTN_EXTRASECONDS
    while (pbGet(NTN_EXTRASECONDS)>=(60*60*24))
      $game_variables[NTN_EXTRASECONDS]-=(60*60*24)
      $game_variables[NTN_EXTRADAYS]+=1
    end
    while (pbGet(NTN_EXTRASECONDS)<=-(60*60*24))
      $game_variables[NTN_EXTRASECONDS]+=(60*60*24)
      $game_variables[NTN_EXTRADAYS]-=1
    end  
  end  
  start_time=Time.local(NTN_INITIALYEAR,NTN_INITIALMONTH,NTN_INITIALDAY,
    NTN_INITIALHOUR,NTN_INITIALMINUTE)
  time_played=(NTN_TIMESTOPS && $PokemonGlobal) ? 
    $PokemonGlobal.newFrameCount : Graphics.frame_count
  time_played=(time_played*NTS_TIMEPROPORTION)/Graphics.frame_rate
  time_jumped=0
  time_jumped+=pbGet(NTN_EXTRASECONDS) if NTN_EXTRASECONDS>-1 
  time_jumped+=pbGet(NTN_EXTRADAYS)*(60*60*24) if NTN_EXTRADAYS>-1 
  time_ret = nil
  # To prevent crashes due to year limit, every time that you reach in year 
  # 2036 the system will subtract 6 years (to works with leap year) from
  # your date and sum in $PokemonGlobal.extraYears. You can sum your actual
  # year with this extraYears when displaying years.
  loop do
    extraYears=($PokemonGlobal) ? $PokemonGlobal.extraYears : 0
    time_fix=extraYears*60*60*24*(365*6+1)/6
    time_ret=start_time+(time_played+time_jumped-time_fix)
    break if time_ret.year<2036
    $PokemonGlobal.extraYears+=6
  end
  if bewwie
    $game_variables[28] = time_ret
  end
  return time_ret
end

if NTN_ENABLED
  class PokemonGlobalMetadata
    attr_accessor :newFrameCount
    attr_accessor :extraYears 
    
    def addNewFrameCount
      self.newFrameCount+=1 if !(
        NTN_SWITCHSTOPS>0 && $game_switches[NTN_SWITCHSTOPS])
    end
    
    def newFrameCount
      @newFrameCount=0 if !@newFrameCount
      return @newFrameCount
    end
    
    def extraYears
      @extraYears=0 if !@extraYears
      return @extraYears
    end
  end  

  if NTN_TIMESTOPS  
    class Scene_Map
      alias :updateold :update
    
      def update
        $PokemonGlobal.addNewFrameCount
        updateold
      end
    
      if NTN_TALKPASS  
        alias :miniupdateold :miniupdate
        
        def miniupdate
          $PokemonGlobal.addNewFrameCount 
          miniupdateold
        end
      end
    end  
  
    if NTN_BATTLEPASS
      class PokeBattle_Scene
        alias :pbGraphicsUpdateold :pbGraphicsUpdate
        
        def pbGraphicsUpdate
          $PokemonGlobal.addNewFrameCount 
          pbGraphicsUpdateold
        end
      end
    end
  end
end


module PBDayNight
  HourlyTones = [
    Tone.new(-70, -90,  15, 55),   # Night           # Midnight
    Tone.new(-70, -90,  15, 55),   # Night
    Tone.new(-70, -90,  15, 55),   # Night
    Tone.new(-70, -90,  15, 55),   # Night
    Tone.new(-60, -70,  -5, 50),   # Night
    Tone.new(-40, -50, -35, 50),   # Day/morning
    Tone.new(-40, -50, -35, 50),   # Day/morning     # 6AM
    Tone.new(-40, -50, -35, 50),   # Day/morning
    Tone.new(-40, -50, -35, 50),   # Day/morning
    Tone.new(-20, -25, -15, 20),   # Day/morning
    Tone.new(  0,   0,   0,  0),   # Day
    Tone.new(  0,   0,   0,  0),   # Day
    Tone.new(  0,   0,   0,  0),   # Day             # Noon
    Tone.new(  0,   0,   0,  0),   # Day
    Tone.new(  0,   0,   0,  0),   # Day/afternoon
    Tone.new(  0,   0,   0,  0),   # Day/afternoon
    Tone.new(  0,   0,   0,  0),   # Day/afternoon
    Tone.new(  0,   0,   0,  0),   # Day/afternoon
    Tone.new( -5, -30, -20,  0),   # Day/evening     # 6PM 
    Tone.new(-15, -60, -10, 20),   # Day/evening
    Tone.new(-15, -60, -10, 20),   # Day/evening
    Tone.new(-40, -75,   5, 40),   # Night
    Tone.new(-70, -90,  15, 55),   # Night
    Tone.new(-70, -90,  15, 55)    # Night
  ]
  @cachedTone = nil
  @dayNightToneLastUpdate = nil
  @oneOverSixty = 1/60.0

# Returns true if it's day.
  def self.isDay?(time=nil)
    time = pbGetTimeNow if !time
    return (time.hour>=5 && time.hour<20)
  end

# Returns true if it's night.
  def self.isNight?(time=nil)
    time = pbGetTimeNow if !time
    return (time.hour>=20 || time.hour<5)
  end

# Returns true if it's morning.
  def self.isMorning?(time=nil)
    time = pbGetTimeNow if !time
    return (time.hour>=5 && time.hour<10)
  end

# Returns true if it's the afternoon.
  def self.isAfternoon?(time=nil)
    time = pbGetTimeNow if !time
    return (time.hour>=14 && time.hour<17)
  end

# Returns true if it's the evening.
  def self.isEvening?(time=nil)
    time = pbGetTimeNow if !time
    return (time.hour>=17 && time.hour<20)
  end

# Gets a number representing the amount of daylight (0=full night, 255=full day).
  def self.getShade
    time = pbGetDayNightMinutes
    time = (24*60)-time if time>(12*60)
    shade=255*time/(12*60)
  end

# Gets a Tone object representing a suggested shading
# tone for the current time of day.
  def self.getTone
    @cachedTone = Tone.new(0,0,0) if !@cachedTone
    return @cachedTone if !ENABLESHADING
    if !@dayNightToneLastUpdate ||
       Graphics.frame_count-@dayNightToneLastUpdate>=Graphics.frame_rate*30
      getToneInternal
      @dayNightToneLastUpdate = Graphics.frame_count
    end
    return @cachedTone
  end

  def self.pbGetDayNightMinutes
    now = pbGetTimeNow   # Get the current in-game time
    return (now.hour*60)+now.min
  end

  private

# Internal function

  def self.getToneInternal
    # Calculates the tone for the current frame, used for day/night effects
    realMinutes = pbGetDayNightMinutes
    hour   = realMinutes/60
    minute = realMinutes%60
    tone         = PBDayNight::HourlyTones[hour]
    nexthourtone = PBDayNight::HourlyTones[(hour+1)%24]
    # Calculate current tint according to current and next hour's tint and
    # depending on current minute
    @cachedTone.red   = ((nexthourtone.red-tone.red)*minute*@oneOverSixty)+tone.red
    @cachedTone.green = ((nexthourtone.green-tone.green)*minute*@oneOverSixty)+tone.green
    @cachedTone.blue  = ((nexthourtone.blue-tone.blue)*minute*@oneOverSixty)+tone.blue
    @cachedTone.gray  = ((nexthourtone.gray-tone.gray)*minute*@oneOverSixty)+tone.gray
  end
end



def pbDayNightTint(object)
  return if !$scene.is_a?(Scene_Map)
  if ENABLESHADING && $game_map && pbGetMetadata($game_map.map_id,MetadataOutdoor)
    tone = PBDayNight.getTone
    object.tone.set(tone.red,tone.green,tone.blue,tone.gray)
  else
    object.tone.set(0,0,0,0)  
  end  
end



#===============================================================================
# Moon phases and Zodiac
#===============================================================================
# Calculates the phase of the moon.
# 0 - New Moon
# 1 - Waxing Crescent
# 2 - First Quarter
# 3 - Waxing Gibbous
# 4 - Full Moon
# 5 - Waning Gibbous
# 6 - Last Quarter
# 7 - Waning Crescent
def moonphase(time=nil) # in UTC
  time = pbGetTimeNow if !time
  transitions = [
     1.8456618033125,
     5.5369854099375,
     9.2283090165625,
     12.9196326231875,
     16.6109562298125,
     20.3022798364375,
     23.9936034430625,
     27.6849270496875]
  yy = time.year-((12-time.mon)/10.0).floor
  j = (365.25*(4712+yy)).floor + (((time.mon+9)%12)*30.6+0.5).floor + time.day+59
  j -= (((yy/100.0)+49).floor*0.75).floor-38 if j>2299160
  j += (((time.hour*60)+time.min*60)+time.sec)/86400.0
  v = (j-2451550.1)/29.530588853
  v = ((v-v.floor)+(v<0 ? 1 : 0))
  ag = v*29.53
  for i in 0...transitions.length
    return i if ag<=transitions[i]
  end
  return 0
end

# Calculates the zodiac sign based on the given month and day:
# 0 is Aries, 11 is Pisces. Month is 1 if January, and so on.
def zodiac(month,day)
  time = [
     3,21,4,19,   # Aries
     4,20,5,20,   # Taurus
     5,21,6,20,   # Gemini
     6,21,7,20,   # Cancer
     7,23,8,22,   # Leo
     8,23,9,22,   # Virgo 
     9,23,10,22,  # Libra
     10,23,11,21, # Scorpio
     11,22,12,21, # Sagittarius
     12,22,1,19,  # Capricorn
     1,20,2,18,   # Aquarius
     2,19,3,20    # Pisces
  ]
  for i in 0...12
    return i if month==time[i*4] && day>=time[i*4+1]
    return i if month==time[i*4+2] && day<=time[i*4+3]
  end
  return 0
end
 
# Returns the opposite of the given zodiac sign.
# 0 is Aries, 11 is Pisces.
def zodiacOpposite(sign)
  return (sign+6)%12
end

# 0 is Aries, 11 is Pisces.
def zodiacPartners(sign)
  return [(sign+4)%12,(sign+8)%12]
end

# 0 is Aries, 11 is Pisces.
def zodiacComplements(sign)
  return [(sign+1)%12,(sign+11)%12]
end

#===============================================================================
# Days of the week
#===============================================================================
def pbIsWeekday(wdayVariable,*arg)
  timenow = pbGetTimeNow
  wday = timenow.wday
  ret = false
  for wd in arg
    ret = true if wd==wday
  end
  if wdayVariable>0
    $game_variables[wdayVariable] = [ 
       _INTL("Sunday"),
       _INTL("Monday"),
       _INTL("Tuesday"),
       _INTL("Wednesday"),
       _INTL("Thursday"),
       _INTL("Friday"),
       _INTL("Saturday")][wday] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

#===============================================================================
# Months
#===============================================================================
def pbIsMonth(monVariable,*arg)
  timenow = pbGetTimeNow
  thismon = timenow.mon
  ret = false
  for wd in arg
    ret = true if wd==thismon
  end
  if monVariable>0
    $game_variables[monVariable] = pbGetMonthName(thismon)
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbGetMonthName(month)
  return [_INTL("January"),
          _INTL("February"),
          _INTL("March"),
          _INTL("April"),
          _INTL("May"),
          _INTL("June"),
          _INTL("July"),
          _INTL("August"),
          _INTL("September"),
          _INTL("October"),
          _INTL("November"),
          _INTL("December")][month-1]
end

def pbGetAbbrevMonthName(month)
  return ["",
          _INTL("Jan."),
          _INTL("Feb."),
          _INTL("Mar."),
          _INTL("Apr."),
          _INTL("May"),
          _INTL("Jun."),
          _INTL("Jul."),
          _INTL("Aug."),
          _INTL("Sep."),
          _INTL("Oct."),
          _INTL("Nov."),
          _INTL("Dec.")][month]
end

#===============================================================================
# Seasons
#===============================================================================
def pbGetSeason
  return (pbGetTimeNow.mon-1)%4
end

def pbIsSeason(seasonVariable,*arg)
  thisseason = pbGetSeason
  ret = false
  for wd in arg
    ret = true if wd==thisseason
  end
  if seasonVariable>0
    $game_variables[seasonVariable] = [ 
       _INTL("Spring"),
       _INTL("Summer"),
       _INTL("Autumn"),
       _INTL("Winter")][thisseason] 
    $game_map.need_refresh = true if $game_map
  end
  return ret
end

def pbIsSpring; return pbIsSeason(0,0); end # Jan, May, Sep
def pbIsSummer; return pbIsSeason(0,1); end # Feb, Jun, Oct
def pbIsAutumn; return pbIsSeason(0,2); end # Mar, Jul, Nov
def pbIsFall; return pbIsAutumn; end
def pbIsWinter; return pbIsSeason(0,3); end # Apr, Aug, Dec

def pbGetSeasonName(season)
  return [_INTL("Spring"),
          _INTL("Summer"),
          _INTL("Autumn"),
          _INTL("Winter")][season]
end