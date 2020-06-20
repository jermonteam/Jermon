DEFAULTDARKCIRCLERAD = 64
$DarknessSprite = nil

class PokeBattle_Trainer
  attr_writer :beginDarkCircle
  def beginDarkCircle
    @beginDarkCircle = false if !@beginDarkCircle
    return @beginDarkCircle
  end
  
  attr_writer :darkCircleRadius
  def darkCircleRadius
    if !@darkCircleRadius
      @darkCircleRadius = DEFAULTDARKCIRCLERAD
    end
    return @darkCircleRadius
  end  
end

def beginDarkCircle
  $DarknessSprite = DarknessSprite.new
  $DarknessSprite.radius = $Trainer.darkCircleRadius
  $Trainer.beginDarkCircle = true
end

def endDarkCircle
  return if !$Trainer.beginDarkCircle
  $DarknessSprite.dispose
  $DarknessSprite = nil
  $Trainer.beginDarkCircle = false
  $Trainer.darkCircleRadius = DEFAULTDARKCIRCLERAD
end

def changeDarkCircleRadius(newRadius)
  return if $DarknessSprite == nil
  $Trainer.darkCircleRadius = newRadius
  $DarknessSprite.radius = $Trainer.darkCircleRadius
end

def changeDarkCircleRadiusSlowly(newRadius)
  return if $DarknessSprite == nil
  $Trainer.darkCircleRadius = newRadius
  changeRate = (newRadius - $DarknessSprite.radius)/12
  return if changeRate == 0
  for i in 0...12
    $DarknessSprite.radius += changeRate
    pbWait(1)
  end
  $DarknessSprite.radius = $Trainer.darkCircleRadius
end


Events.onMapSceneChange+=proc{|sender,e|
  scene=e[0]
  mapChanged=e[1]
  return if !$Trainer
  beginDarkCircle if $Trainer.beginDarkCircle && $DarknessSprite == nil
  if $Trainer.beginDarkCircle && $PokemonTemp.darknessSprite
    $PokemonTemp.darknessSprite.dispose
    $PokemonTemp.darknessSprite = nil
  end
}