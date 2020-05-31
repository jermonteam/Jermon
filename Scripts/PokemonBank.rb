#This script is for storing the players money in a bank.

def pbDepositBank
  params=ChooseNumberParams.new
  params.setMaxDigits(9)
  params.setRange(MINDEPOSIT,$Trainer.money) #sets min/max deposit from MINDEPOSIT to what the player has on hand
  params.setInitialValue($Trainer.money) #sets the value to what the player has on hand
  params.setCancelValue(0)
  if $Trainer.money<MINDEPOSIT #checks if the player has less money than MINDEPOSIT
    Kernel.pbMessage(
      _INTL("\\G\\XVSorry you must have at least ${1} to deposit.",MINDEPOSIT)) #not enough to deposit
  elsif pbGet(14)==MAXBANK#checks if the bank amount is full
    Kernel.pbMessage(
      _INTL("\\G\\XVYour Bank Account is full, you can not deposit any more money.")) #\\XV shows the bankwindow when picking amount
  elsif $Trainer.money>=MINDEPOSIT#checks if player has more money than MINDEPOSIT
    qty=Kernel.pbMessageChooseNumber(
      _INTL("\\G\\XVHow much would you like to deposit?"),params) #choose deposit amount
    maxqty=MAXBANK-pbGet(14)
      if qty>maxqty
        newqty=MAXBANK-pbGet(14)
        Kernel.pbMessage(
          _INTL("\\G\\XVYou are only allowed to deposit ${1}.",newqty))
        pbAdd(14,newqty)
        $Trainer.money=$Trainer.money-newqty
      else
        pbAdd(14,qty) #adds money to bank
        $Trainer.money=$Trainer.money-qty #subtracts money from player
      end
  end
end

def pbWithdrawBank
  params=ChooseNumberParams.new
  params.setMaxDigits(9)
  params.setRange(1,pbGet(14)) #sets range from 1 to how much the player has in the bank
  params.setInitialValue(pbGet(14)) #sets value to how much the player has in the bank
  params.setCancelValue(0)
  maxqty=MAXMONEY-$Trainer.money
  if pbGet(14)==0 #checks if you have no money in the bank
      Kernel.pbMessage(
        _INTL("\\G\\XVYou do not have any money to withdraw.")) #no money in bank
  elsif pbGet(14)>0#checks if you have money in the bank
    qty=Kernel.pbMessageChooseNumber(
      _INTL("\\G\\XVHow much would you like to withdraw?"),params) #\\XV shows the bankwindow when picking amount
      if qty>maxqty
        newqty=MAXMONEY-$Trainer.money
        Kernel.pbMessage(
          _INTL("\\G\\XVWe were only allowed to give you ${1}",newqty))
        pbSub(14,newqty)
        $Trainer.money=$Trainer.money+newqty
      else
        pbSub(14,qty) #subtracts money from bank
        $Trainer.money=$Trainer.money+qty #adds money to player
      end
  end
end