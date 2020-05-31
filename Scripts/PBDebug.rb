module PBDebug
  def PBDebug.logonerr
    begin
      yield
    rescue
      PBDebug.log("")
      PBDebug.log("**Exception: #{$!.message}")
      PBDebug.log("#{$!.backtrace.inspect}")
      PBDebug.log("")
#      if $INTERNAL
        pbPrintException($!)
#      end
      PBDebug.flush
    end
  end

  @@log=[]

  def PBDebug.flush
    if $DEBUG && $INTERNAL && @@log.length>0
      File.open("Data/debuglog.txt", "a+b") {|f| f.write("#{@@log}") }
    end
    @@log.clear 
  end

  def PBDebug.log(msg)
    if $DEBUG && $INTERNAL
      @@log.push("#{msg}\r\n")
#      if @@log.length>1024
        PBDebug.flush
#      end
    end
  end

  def PBDebug.dump(msg)
    if $DEBUG && $INTERNAL
      File.open("Data/dumplog.txt", "a+b") { |f| f.write("#{msg}\r\n") }
    end
  end
end

def pbDebugSetVariable(id,diff)
  pbPlayCursorSE()
  $game_variables[id]=0 if $game_variables[id]==nil
  if $game_variables[id].is_a?(Numeric)
    $game_variables[id]=[$game_variables[id]+diff,999999999].min
    $game_variables[id]=[$game_variables[id],-999999999].max
  end
end

def pbDebugVariableScreen(id)
  value=0
  if $game_variables[id].is_a?(Numeric)
    value=$game_variables[id]
  end
  params=ChooseNumberParams.new
  params.setDefaultValue(value)
  params.setMaxDigits(9)
  params.setNegativesAllowed(true)
  value=Kernel.pbMessageChooseNumber(_INTL("Set variable {1}.",id),params)
  $game_variables[id]=[value,999999999].min
  $game_variables[id]=[$game_variables[id],-999999999].max
end