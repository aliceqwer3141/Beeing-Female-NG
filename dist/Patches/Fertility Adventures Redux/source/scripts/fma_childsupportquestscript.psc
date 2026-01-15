Scriptname FMA_ChildSupportQuestScript extends Quest  

GlobalVariable Property FMA_ChildSupportEnabled  Auto                                                                    
GlobalVariable Property FMA_ChildCost  Auto  
GlobalVariable Property PlayerFund Auto

;Container Property chest  Auto  


Int Property LastCharge = 0 auto
Int Property OrphanCount = 0 auto
Int Property PayeeCount = 0 auto
Int Property PaymentMultiplier = 0 auto
Int Property TotalCost = 0 auto

;MiscObject Property Gold001  Auto  

FormList Property FMA_ChildSupportPayeeList  Auto  

Faction Property FMA_PlayerPregFaction  Auto  

ReferenceAlias Property PlayerSpouse  Auto  


;Event OnInit()
;	StartPolling()
;EndEvent

Function StartPolling()
	RegisterForSingleUpdateGameTime(24)
	Debug.Notification("Started polling")
	RegisterForModEvent("FertilityModeLabor", "OnFertilityModeLabor")
EndFunction

Event OnUpdateGameTime()
	If FMA_ChildSupportEnabled.GetValue() == 1
		Debug.Notification("Updating FMA child support")

		;Check payee list
		Int Index = 0
		While Index < FMA_ChildSupportPayeeList.GetSize()

			If (FMA_ChildSupportPayeeList.GetAt(Index) as Actor).IsDead()
				FMA_ChildSupportPayeeList.RemoveAddedForm(FMA_ChildSupportPayeeList.GetAt(Index))
				Debug.Notification("A payee was removed from the child support list")
			EndIf

			Index += 1
		EndWhile
		PayeeCount = FMA_ChildSupportPayeeList.GetSize()

		;Check orphan count
		;For when I figure out how to count the player orphans

		;Retotal the payment multiplier based on payee count
		PaymentMultiplier = PayeeCount + OrphanCount

		;Set new monthly fee
		TotalCost = (FMA_ChildCost.GetValue() as int)*PaymentMultiplier

		LastCharge += 1
		If LastCharge > 2
			ChargeMoney(Totalcost)
		EndIf

		RegisterForSingleUpdateGameTime(24)

	Else
		RegisterForSingleUpdateGameTime(24)
		Debug.Notification("FMA child support is disabled")
	EndIf
EndEvent


Function PayMoney(Int akPayment)
	PlayerFund.SetValue((PlayerFund.GetValue() as int) + akPayment)
	Debug.Notification("New player fund is <PlayerFund.GetValue()> gold.")
EndFunction

Function ChargeMoney(Int akMoney)
	PlayerFund.SetValue((PlayerFund.GetValue() as int) - akMoney)
	LastCharge = 0
	Debug.Notification("Player was charged child support")
EndFunction

Function AddPayee(Actor akActor)
	FMA_ChildSupportPayeeList.AddForm(akActor)
	Debug.Notification("Payee added to list")
EndFunction




event OnFertilityModeLabor(string eventName, Form sender, int actorIndex)

	AddPayee(Sender as actor)

	;If ((Sender as Actor).IsInFaction(FMA_PlayerParentFaction) || (Sender as Actor).IsInFaction(FMA_PlayerPregFaction)) && (Sender as Actor).IsInFaction(PlayerMarriedFaction) == 0
	;	AddPayee(Sender as actor)
	;Endif
endEvent


Faction Property PlayerMarriedFaction  Auto  

Faction Property FMA_PlayerParentFaction  Auto  
