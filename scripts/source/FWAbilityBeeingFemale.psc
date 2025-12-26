Scriptname FWAbilityBeeingFemale extends FWAbilityBeeingBase

FWTextContents property Contents auto

;--------------------------------------------------------------------------------
; Variables & Properties
;--------------------------------------------------------------------------------
; State Variables
int property currentState = 0 auto hidden
float property stateEnterTime auto hidden
float _onUpdateGameTimeDelay = 1.0
float property stateDamageScale = 1.0 auto hidden
float CurrentStatePercent=0.0
float StateDaysRemaining=0.0
int property nextState = 1 auto hidden

bool property canBecomePregnantThisCycle = false auto hidden
bool property canBecomePMSThisCycle = false auto hidden
bool bHasPMS = false
float property LH = 0.0 auto hidden

; Baby Variables
float property UnbornHealth=0.0 auto hidden
int property NumChilds=0 auto hidden

float oldUpdateDelay=0.0
float property UpdateDelay=0.0 auto hidden
float property PauseStartTime=0.0 auto hidden

; Contraception
float ContraceptionPill=0.0
float ContraceptionTime=0.0

; Measurements
Float[] property BaseBellySize auto hidden
Float[] property BaseBreastSize auto hidden
Float property BaseWeight auto hidden
Float AddedBellySize = 0.0
Float AddedBreastSize = 0.0
Float AddedWeight = 0.0
int lastTypeOfScaling = -1

int property abortus = 0 auto hidden
float property AbortusTime = 0.0 auto hidden
bool Abortus_Fiber = false ; Player only
bool Abortus_Infection = false ; Player only
float LastBabyHealing


; Labor Pains step
; 0 - None
; 1 - Vorwehen
; 2 - Eröffnungswehen
; 3 - Presswehen
; 4 - Nachwehen
int property LaborPainsStep = 0 auto
Form[] dropedItems

MagicEffect BeeingFemaleEffect
Keyword KwArmorCuirass 
Keyword KwClothingBody

;--------------------------------------------------------------------------------
; Events
;--------------------------------------------------------------------------------

Event OnEffectStart(Actor target, Actor caster)
	if System.ModEnabled.GetValueInt() ;Tkc (Loverslab): optimization
	else;if System.ModEnabled.GetValueInt()!=1
		Self.Dispel()
		Return
	endif	
	float startTime = Utility.GetCurrentGameTime()
	ActorRef = target
	ActorRefBase = target.GetLeveledActorBase()
	BeeingFemaleEffect = System.BeeingFemaleSpell.GetNthEffectMagicEffect(0)
	IsPlayer = (target==PlayerRef) ;Tkc (Loverslab): optimization. PlayerRef added in FWAbilityBeeingBase
	parent.OnEffectStart(target, caster)
	;/reworked
	IsFollower = target.IsInFaction(System.FollowerFaction)
	;if (! System.NpcMentruation()) && (! isPlayer)
	if System.NpcMentruation() ;Tkc (Loverslab): optimization
	else;if (! System.NpcMentruation())
	 if isPlayer
	 else; (! isPlayer)
		System.Message( FWUtility.StringReplace( Contents.BeeingFemaleMissedOn2,"{0}",ActorRefBase.GetName()), System.MSG_Debug)
		Self.Dispel()
		return
	 endIf
	endIf
	if IsPlayer==true
		System.PlayerMale = none
		System.Player = self
	endIf
	
	IsFollower = target.IsInFaction(System.FollowerFaction) && IsPlayer == false
	/;;;\/
	;;;Tkc (Loverslab): reworked code of player\npc\follower detection
	if IsPlayer
		System.PlayerMale = none
		System.Player = self
		IsFollower = false;added to set IsFollower to false if it is player
		Self.RegisterForSingleUpdate(5);was added here from code below. suppose 5 sec. will be still enough to execute other code to the end of the event before OnUpdate will be executed
	else
		if System.NpcMentruation() ;Tkc (Loverslab): optimization
		else ;like in the condition in original code above: if (! System.NpcMentruation()) && (! isPlayer)
			System.Message( FWUtility.StringReplace( Contents.BeeingFemaleMissedOn2,"{0}",ActorRefBase.GetName()), System.MSG_Debug)
			Self.Dispel()
			return
		endIf	
		IsFollower = target.IsInFaction(System.FollowerFaction) ; in original code it is set two times ; like in original above here:IsFollower = target.IsInFaction(System.FollowerFaction) && IsPlayer == false
	endIf
	;;;;;;;
	GetBaseMeasurements(True)
	bInitSpell=true
	System.RegisterFWCache(self)
	;If IsPlayer ;Tkc (Loverslab): optimization. added in reworked player\npc\follower detection code above because it will reduce code by one check and it is only for player
	;	Self.RegisterForSingleUpdate(5) ;Bane -> Only uaed by Player now
	;EndIf
	If ActorRef.HasMagicEffect(BeeingFemaleEffect)	
		RegisterForAnimationEvent(ActorRef, "SoundPlay")
		Self.RegisterForModEvent("BeeingFemale", "BeeingFemale") 
		Self.RegisterForSleep()
		if oldUpdateDelay>0
			Self.RegisterForSingleUpdateGameTime(oldUpdateDelay)
		else
			InitState()
		endif
	endif
	
	KwArmorCuirass  = Keyword.GetKeyword("ArmorCuirass") 
	KwClothingBody = Keyword.GetKeyword("ClothingBody")

	equipChild()
	
	CheckRandomSexPartner()
	InitValues()
	if Contents;/!=none/;
		System.Message( FWUtility.StringReplace( Contents.BeeingFemaleCastedOn ,"{0}", ActorRef.GetLeveledActorBase().GetName() ), System.MSG_All)
	endif
	getLastSeenNPCs()
	System.Message("FWAbilityBeeingFemale::OnEffectStart("+ActorRef.GetLeveledActorBase().GetName()+") " + (Utility.GetCurrentRealTime() - startTime) + " sec", System.MSG_All, System.MSG_Trace)
endEvent

Event OnPlayerLoadGame()
	float startTime = Utility.GetCurrentGameTime()
	;if bInit;/==true/; && bInitSpell;/==true/;; && ActorRef.HasMagicEffect(System.BeeingFemaleSpell.GetNthEffectMagicEffect(0))
	if bInit ;Tkc (Loverslab): optimization
	 if bInitSpell
		;Utility.WaitMenuMode(2)
		SetBelly()
		Self.RegisterForSingleUpdate(5)
		Self.UnregisterForModEvent("BeeingFemale")
		Self.RegisterForModEvent("BeeingFemale", "BeeingFemale")
		Self.RegisterForSleep()
		if oldUpdateDelay>0
			Self.RegisterForSingleUpdateGameTime(oldUpdateDelay)
		else
			InitState()
		endif
		getLastSeenNPCs()
	 endif
	endif
	equipChild()
	System.Message("FWAbilityBeeingFemale::OnPlayerLoadGame() " + (Utility.GetCurrentRealTime() - startTime) + " sec", System.MSG_All, System.MSG_Trace)
endEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	if bInitSpell;/==true/;
		ResetBelly()
		onExitState()
	endif
	If ActorRef && ActorRef.HasSpell(System.BeeingFemaleSpell)
		ActorRef.RemoveSpell(System.BeeingFemaleSpell)
	EndIf
endEvent

; Bane --> On Update is now only needed by the player for triggering any Baby events via the parent.Onupdate() function
event OnUpdate()
	if IsPlayer ;Tkc (Loverslab): offered by dldrzz000. Error with registerforsingleupdate still occuring in 1839 line aven with IsPlayer check and disappearing when same check here.
	;if ActorRef.HasMagicEffect(System.BeeingFemaleSpell.GetNthEffectMagicEffect(0))
		parent.OnUpdate()
		Self.RegisterForSingleUpdate(5)
	;endif
	endif
endEvent

Event OnAnimationEvent(ObjectReference akSource, string asEventName) ;Bane -> Treading water will trigger washout every few seconds
	;If asEventName == "SoundPlay" && ActorRef.IsSwimming() && !( ActorRef.WornHasKeyword(KwArmorCuirass) || ActorRef.WornHasKeyword(KwClothingBody) )
	If asEventName == "SoundPlay" ;Tkc (Loverslab): optimization
	 If ActorRef.IsSwimming()
	  If ( ActorRef.WornHasKeyword(KwArmorCuirass) || ActorRef.WornHasKeyword(KwClothingBody) )
	  else;If !( ActorRef.WornHasKeyword(KwArmorCuirass) || ActorRef.WornHasKeyword(KwClothingBody) )
		System.Controller.WashOutSperm(ActorRef, 1, 0.8)
		System.Message("Washout Sperm - "+ ActorRef.GetLeveledActorBase().GetName(),System.MSG_Debug)
	  EndIf
	 EndIf
	EndIf
EndEvent

event BeeingFemale(string eventName, string strArg, float numArg, Form sender)
	if eventName=="BeeingFemale"
		if strArg=="TestScale" && (sender==ActorRef || sender as actor==none)
			Debug.Notification("Test Scaling for "+ActorRef.GetLeveledActorBase().GetName())
			TestScale(numArg)
		elseif (numArg== ActorRef.GetFormID() || sender==ActorRef)
			if strArg=="CheckAbortus"
				checkAbortus()
			elseif strArg=="Update"
				InitValues()
			elseif strArg=="Belly"
				SetBelly(true)
			elseif strArg=="Birth"
				SetBelly(true)
			elseif strArg=="ConceptionChance"
				if (numArg==1 && IsPlayer;/==true/;) || (numArg==2 && IsFollower;/==true/;) || (numArg==3 && IsFollower==false)
					System.Controller.setAutoFlag(ActorRef)
				endif
			elseif strArg=="Dispel"
				Dispel()
			endIf
		endIf
	endif
endEvent

event OnUpdateGameTime()
	float startTime = Utility.GetCurrentGameTime()
	float currentTime = Utility.GetCurrentGameTime()
	;if System.IsActorPregnantByChaurus(ActorRef) && (Self.GetState() != "PregnantChaurus_State")
	if System.IsActorPregnantByChaurus(ActorRef) ;Tkc (Loverslab): optimization
	 if (Self.GetState() == "PregnantChaurus_State")
	 else;if (Self.GetState() != "PregnantChaurus_State")
		System.Controller.Pause(ActorRef,true)
		;System.setObjective(21)	
		GoToState("PregnantChaurus_State")
	 endIf
	endIf
	
	GetStorageVariable()
	
	float stateDuration = System.getStateDuration(CurrentState, ActorRef)

	If Self.GetState() == "PregnantChaurus_State" && (CurrentState == 2 || CurrentState == 8)
		stateEnterTime = Utility.GetCurrentGameTime() ;Hold Luteal or Replenish State at 0% complete whilst Chaurus Pregnant
	EndIf
	if stateDuration > 0
		CurrentStatePercent = ((currentTime - stateEnterTime) * 100) / stateDuration
		StateDaysRemaining = stateDuration - (currentTime - stateEnterTime)
		if currentTime >= stateEnterTime + stateDuration
			changeState(NextState)
		endIf
		System.Manager.onUpdateFunction(ActorRef,CurrentState,CurrentStatePercent)
	else
		CurrentStatePercent=0.0
		System.Manager.onUpdateFunction(ActorRef,CurrentState,0)
	endIf
	if IsPlayer
		System.Message("OnUpdateGameTime "+ActorRef.GetLeveledActorBase().GetName()+": "+CurrentState+" at "+CurrentStatePercent+"% (Dur: "+stateDuration+")",System.MSG_Debug)
	else
		System.Message("OnUpdateGameTime "+ActorRef.GetLeveledActorBase().GetName()+": "+CurrentState+" at "+CurrentStatePercent+"% (Dur: "+stateDuration+")",System.MSG_All)
	endIf
	if currentState>=4 && currentState <20
		SetBelly();
		AbortusPains()
	endif
	if IsPlayer
		if System.Player ;Tkc (Loverslab): optimization
		else;if System.Player==none
			System.Player=self
			System.PlayerMale=none
		endif
		System.GlobalPlayerState.SetValue(currentState)
		System.GlobalPlayerStatePercent.SetValue(CurrentStatePercent)
	endif
	;if !IsPlayer && currentState<4 && ActorRef.Is3DLoaded()
	if IsPlayer ;Tkc (Loverslab): optimization
	else;if !IsPlayer
	 if currentState<4
	  if ActorRef.Is3DLoaded()
		if numChilds>0
			System.InstantBornChilds(ActorRef)
			numChilds=0
		endif
	  endif
	 endif
	endif
	OnUpdateFunction()
	System.Message("FWAbilityBeeingFemale::OnUpdateGameTime("+ActorRef.GetLeveledActorBase().GetName()+") " + (Utility.GetCurrentRealTime() - startTime) + " sec", System.MSG_All, System.MSG_Trace)
	Utility.WaitMenuMode(1)
	If ActorRef.HasMagicEffect(BeeingFemaleEffect)
		Self.RegisterForSingleUpdateGameTime(oldUpdateDelay)
	EndIf
endEvent

bool OnHitIsBusy
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
if OnHitIsBusy;spamguard
else
	OnHitIsBusy = true
	
	onHitFunction(akAggressor,akSource,akProjectile,abPowerAttack,abSneakAttack,abBashAttack,abHitBlocked)
	parent.onHit(akAggressor, akSource, akProjectile, abPowerAttack, abSneakAttack, abBashAttack, abHitBlocked)
	
	OnHitIsBusy = false
endif
endEvent

Event OnSpellCast(Form akSpell)
	if (akSpell as Spell);/!=none/;
		onCastSpellFunction(akSpell as Spell)
	elseif (akSpell as potion);/!=none/;
		potion p = akSpell as potion
		onPotionFunction(p)
	endif
	If System.BadSpellList && System.BadSpellList.Find(akSpell)>0 && currentState>=4 && currentState<20
		If IsPlayer
			System.Message( FWUtility.StringReplace( Contents.AlcoholNotGoodForYourBaby,"{0}",ActorRefBase.GetName()), System.MSG_Low)
		Else
			System.Message( FWUtility.StringReplace( Contents.AlcoholNotGoodForNPCBaby,"{0}",ActorRefBase.GetName()), System.MSG_High)
		EndIf
		System.Controller.DamageBaby(ActorRef, 8.0)
	EndIf
	parent.OnSpellCast(akSpell)
EndEvent

;--------------------------------------------------------------------------------
; General Functions
;--------------------------------------------------------------------------------

function CheckRandomSexPartner()
	
endFunction

function InitValues()
	System.Data.Update(ActorRef)
	GetStorageVariable()
	InitState()
endFunction

function GetStorageVariable()
	stateEnterTime= StorageUtil.GetFloatValue(ActorRef, "FW.StateEnterTime", Utility.GetCurrentGameTime())
	currentState= StorageUtil.GetIntValue(ActorRef, "FW.CurrentState",0)
	UnbornHealth = StorageUtil.GetFloatValue(ActorRef,"FW.UnbornHealth",100.0)
	NumChilds = StorageUtil.GetIntValue(ActorRef,"FW.NumChilds",0)
	AbortusTime = StorageUtil.GetFloatValue(ActorRef,"FW.AbortusTime",0.0)
	abortus = StorageUtil.GetIntValue(ActorRef, "FW.Abortus",0)
endFunction

function InitState()
	string StateName
	int ObjectiveID
	bool bStateFound=true
	if currentState==0
		UpdateDelay=4.0 ; Less activity - lower update rate
		StateName="Follicular_State"
		ObjectiveID=0
		nextState = 1
	elseif currentState==1
		UpdateDelay=1.0
		StateName="Ovulation_State"
		ObjectiveID=1
		nextState = 2
	elseif currentState==2
		UpdateDelay=1.0
		StateName="Luteal_State"
		ObjectiveID=2
		nextState = 3
	elseif currentState==3
		UpdateDelay=1.0
		StateName="Menstruation_State"
		ObjectiveID=3
		nextState = 0
	elseif currentState==4
		UpdateDelay=3.0
		StateName="PregnancyFirst_State"
		ObjectiveID=4
		nextState = 5
	elseif currentState==5
		UpdateDelay=3.0
		StateName="PregnancySecond_State"
		ObjectiveID=5
		nextState = 6
	elseif currentState==6
		UpdateDelay=1.0
		StateName="PregnancyThird_State"
		ObjectiveID=6
		nextState = 7
	elseif currentState==7
		UpdateDelay=0.2
		StateName="LaborPains_State"
		ObjectiveID=7
		nextState = 8
	elseif currentState==8
		UpdateDelay=1.0
		StateName="Replanish_State"
		ObjectiveID=8
		nextState = 0
	else
		bStateFound=false
	endIf
	
	if IsPlayer
		System.GlobalPlayerState.SetValue(currentState)
	endif
	
	if self as string != "[FWAbilityBeeingFemale <None>]" ; Reverted by Bane - This is a reliable method for avoiding the error RegisterForSingleUpdateGameTime - no native object bound to the script object, or object is of incorrect type
		;if oldUpdateDelay!=UpdateDelay && bInit;/==true/; && bInitSpell;/==true/;
		if oldUpdateDelay==UpdateDelay ;Tkc (Loverslab): optimization
		else;if oldUpdateDelay!=UpdateDelay
		 if bInit;/==true/;
		  if bInitSpell;/==true/; 
			;Self.UnregisterForUpdateGameTime() 
			;if UpdateDelay > 0 && System.cfg.PlayerTimer
			if UpdateDelay > 0
				if System.cfg.PlayerTimer
					;if IsPlayer ;Tkc (Loverslab): Fix for error reported by dldrzz000:  Reverted by Bane ***This is also for npcs and stopped npc cyrcles*******
						Self.RegisterForSingleUpdateGameTime(UpdateDelay) 
					;endIf
				endIf
			endIf
			oldUpdateDelay = UpdateDelay
		  endIf
		 endIf
		endIf
		if bStateFound
			onExitState()
			stateEnterTime = Utility.GetCurrentGameTime()
			CurrentStatePercent=0.0
			StateDaysRemaining = System.getStateDuration(currentState, ActorRef)
			GoToState(StateName)
			castStateSpell()
			onEnterState()
			System.raiseModEvent("stateChanged",self)
		Else
			System.Message( FWUtility.StringReplace( Contents.StateNotFound,"{0}",StateName), System.MSG_Error)
		endIf
	endif
endFunction

function changeState(int NewState)
	if (abortus > 1 && (NewState==4 || NewState==5 || NewState==6)) || (abortus > 2 && NewState==7)
		return
	endif
	currentState=NewState
	StorageUtil.SetIntValue(ActorRef,"FW.CurrentState",currentState)
	StorageUtil.SetFloatValue(ActorRef,"FW.StateEnterTime", Utility.GetCurrentGameTime())
	StorageUtil.SetFloatValue(ActorRef,"FW.LastUpdate",Utility.GetCurrentGameTime())
	InitState()
endFunction

function castStateSpell()
	if ActorRef ;Tkc (Loverslab): optimization
	else;if !ActorRef
		return
	endif
	int i=0
	while i<=8
		if currentState == i
			if ActorRef.HasSpell(System.StatCycleID_List[i]) ;Tkc (Loverslab): optimization
			else;if ActorRef.HasSpell(System.StatCycleID_List[i]) == false
				ActorRef.AddSpell(System.StatCycleID_List[i],false)
			endif
		else
			if ActorRef.HasSpell(System.StatCycleID_List[i])
				ActorRef.RemoveSpell(System.StatCycleID_List[i])
			endif
		endif
		i+=1
	endWhile
	if currentState>=0 && currentState<4
		; Cycle
		if ActorRef.HasSpell(System.StatMenstruationCycle) ;Tkc (Loverslab): optimization
		else;if ActorRef.HasSpell(System.StatMenstruationCycle)==false
			ActorRef.AddSpell(System.StatMenstruationCycle,false)
		endIf
		if ActorRef.HasSpell(System.StatPregnancyCycle)
			ActorRef.RemoveSpell(System.StatPregnancyCycle)
		endIf
	elseif currentState>=4 && currentState<20
		; Pregnant
		if ActorRef.HasSpell(System.StatMenstruationCycle)
			ActorRef.RemoveSpell(System.StatMenstruationCycle)
		endIf
		if ActorRef.HasSpell(System.StatPregnancyCycle) ;Tkc (Loverslab): optimization
		else;if ActorRef.HasSpell(System.StatPregnancyCycle)==false
			ActorRef.AddSpell(System.StatPregnancyCycle,false)
		endIf
	else
		; Pregnant by other mod?
		if ActorRef.HasSpell(System.StatMenstruationCycle)
			ActorRef.RemoveSpell(System.StatMenstruationCycle)
		endIf
		if ActorRef.HasSpell(System.StatPregnancyCycle)
			ActorRef.RemoveSpell(System.StatPregnancyCycle)
		endIf
	endif
endFunction

float function timeRemaining()
	if System.getStateDuration(currentState, ActorRef) > 0
		return System.getStateDuration(currentState, ActorRef) - (Utility.getCurrentGameTime() - stateEnterTime)
	else
		return Utility.getCurrentGameTime() - stateEnterTime
	endIf
endFunction

function getLastSeenNPCs()
	int Searches = 5
	;actor p = Game.GetPlayer()
	actor a = Game.FindClosestActorFromRef(ActorRef, 2500)
	if a==PlayerRef ;Tkc (Loverslab): optimization
	else;if a!=PlayerRef
		addLastSeenNPC(a)
	endif
	while Searches>0
		Searches -=1
		a = Game.FindRandomActorFromRef(ActorRef, 2500)
		if a==PlayerRef ;Tkc (Loverslab): optimization
		else;if a!=PlayerRef
			addLastSeenNPC(a)
		endif
	endWhile
	; Clear old values
	int c = StorageUtil.FormListCount(ActorRef,"FW.LastSeenNPCs")
	float t = Utility.GetCurrentGameTime()
	while c>0
		c-=1
		; Remove all actors that are older then 2 Days and not in the same location
		float tt = StorageUtil.FloatListGet(ActorRef,"FW.LastSeenNPCsTime",c)
		actor ta = StorageUtil.FormListGet(ActorRef,"FW.LastSeenNPCs",c) as actor
		if ta==none || ta.IsDead()
			StorageUtil.FormListRemoveAt(ActorRef, "FW.LastSeenNPCsTime", c)
			StorageUtil.FormListRemoveAt(ActorRef, "FW.LastSeenNPCs", c)
		elseif tt < t - 2
			Location Loc = ta.GetCurrentLocation()
			;if Loc && !ActorRef.IsInLocation(Loc)
			if Loc ;Tkc (Loverslab): optimization
				if ActorRef.IsInLocation(Loc)
				else;if !ActorRef.IsInLocation(Loc)
					StorageUtil.FloatListRemoveAt(ActorRef, "FW.LastSeenNPCsTime", c)
					StorageUtil.FormListRemoveAt(ActorRef, "FW.LastSeenNPCs", c)
				endif
			endif
		endif
	endWhile
endFunction
function addLastSeenNPC(actor a)
	;if System.IsValidateMaleActor(a)>0 && !a.GetRace().HasKeywordString("ActorTypeCreature")
	if System.IsValidateMaleActor(a)>0 ;Tkc (Loverslab): optimization
	 if a.GetRace().HasKeywordString("ActorTypeCreature")
	 else;if !a.GetRace().HasKeywordString("ActorTypeCreature")
		int pos=StorageUtil.FormListFind(ActorRef,"FW.LastSeenNPCs", a)
		if pos==-1
			StorageUtil.FormListAdd(ActorRef,"FW.LastSeenNPCs",a)
			StorageUtil.FloatListAdd(ActorRef,"FW.LastSeenNPCsTime", Utility.GetCurrentGameTime())
		else
			StorageUtil.FloatListSet(ActorRef,"FW.LastSeenNPCsTime", pos, Utility.GetCurrentGameTime())
		endif
	 endif
	endif
endFunction




;--------------------------------------------------------------------------------
; Abortus Functions
;--------------------------------------------------------------------------------
;   0	None
;   1	Abortus_imminens // drohender abortus
;   2	Abortus_incipiens // beginnender Abortus
;   3	Abortus_incompletus // unvollständiger Abort
;   4	Abortus_completus // vollständiger Abortus
;   5	Missed_Abortion // verhaltener Abort
;   6	Miscarriage // Totgeburt
bool function checkAbortus() ; SensebilityPercent - 20 = up to 20% Chances to losing child, 50 = up to 50% chance to lossingchild
	if System.cfg.abortus ;Tkc (Loverslab): optimization
	else;if System.cfg.abortus==false
		return false
	endif
	if currentState<4 && currentState==8
		; Not pregnant or in replenish
		return false
	endif
	float hp = StorageUtil.GetFloatValue(ActorRef, "FW.UnbornHealth",100.0)
	numChilds = StorageUtil.GetIntValue(ActorRef, "FW.NumChilds",0)
	AbortusTime = StorageUtil.GetFloatValue(ActorRef,"FW.AbortusTime",0.0)
	abortus = StorageUtil.GetIntValue(ActorRef, "FW.Abortus",0)
	
	float trimesterTimeDay=System.GetStateDuration(currentState,ActorRef) / 89
	
	if hp < 8 && numChilds>0 && abortus<=2 ; Init abortus
		if abortus == 0 && hp>0
			; Abortus_imminens // drohender abortus
			StorageUtil.SetIntValue(ActorRef, "FW.Abortus",1)
			StorageUtil.SetFloatValue(ActorRef, "FW.AbortusTime",Utility.GetCurrentGameTime())
		elseif abortus==0 && hp<=0
			StorageUtil.SetIntValue(ActorRef, "FW.Abortus",2)
			StorageUtil.SetFloatValue(ActorRef, "FW.AbortusTime",Utility.GetCurrentGameTime())
			StorageUtil.SetFloatValue(ActorRef, "FW.UnbornHealth",0.0)
		elseif (abortus == 1 && ( Utility.GetCurrentGameTime() - AbortusTime)>trimesterTimeDay*2 && AbortusTime>0) && hp<=4
			; Abortus_incipiens // beginnender Abortus
			StorageUtil.SetIntValue(ActorRef, "FW.Abortus",2)
			StorageUtil.SetFloatValue(ActorRef, "FW.AbortusTime",Utility.GetCurrentGameTime())
			StorageUtil.SetFloatValue(ActorRef, "FW.UnbornHealth",0.0)
		elseif abortus == 2 && ( Utility.GetCurrentGameTime() - AbortusTime)>trimesterTimeDay*3 && AbortusTime>0
			; Abortus variance
			int randomAbortus=Utility.RandomInt(0,50)
			float infectChance=0
			float fiberChance=0
			
			if randomAbortus < 13 && CurrentStatePercent<14 && CurrentState==4
				; Abortus_completus // vollständiger Abortus
				StorageUtil.SetIntValue(ActorRef, "FW.Abortus",4)
				StorageUtil.SetFloatValue(ActorRef, "FW.AbortusTime",Utility.GetCurrentGameTime())
				fiberChance = 0.2
				infectChance = 0.1
			elseif randomAbortus<41 && CurrentState==4
				; Abortus_incompletus // unvollständiger Abort
				StorageUtil.SetIntValue(ActorRef, "FW.Abortus",3)
				StorageUtil.SetFloatValue(ActorRef, "FW.AbortusTime",Utility.GetCurrentGameTime())
				fiberChance = 8.1
				infectChance = 0.62
			elseif CurrentState==4
				; Missed_Abortion // verhaltener Abort
				StorageUtil.SetIntValue(ActorRef, "FW.Abortus",5)
				StorageUtil.SetFloatValue(ActorRef, "FW.AbortusTime",Utility.GetCurrentGameTime())
				fiberChance = 0.35
				infectChance = 0.21
			elseif CurrentState>4 && CurrentState<20
				; Miscarriage // Totgeburt
				StorageUtil.SetIntValue(ActorRef, "FW.Abortus",6)
				StorageUtil.SetFloatValue(ActorRef, "FW.AbortusTime",Utility.GetCurrentGameTime())
				fiberChance = 0.71
				infectChance = 0.43
			endif
			Abortus_Fiber = fiberChance> Utility.RandomFloat(0.0,1.0)
			Abortus_Infection = infectChance> Utility.RandomFloat(0.0,1.0)
		endif
		return true
	
	; Abortus_incompletus
	elseif abortus==3 &&  ( Utility.GetCurrentGameTime() - AbortusTime)>trimesterTimeDay*12 && AbortusTime>0
		castAbortus(5,true)
		return true
		
	; Abortus_completus
	elseif abortus==4 &&  ( Utility.GetCurrentGameTime() - AbortusTime)>trimesterTimeDay*11 && AbortusTime>0
		castAbortus(3,true)
		return true
	
	; Missed_Abortion
	elseif abortus==5 &&  ( Utility.GetCurrentGameTime() - AbortusTime)>trimesterTimeDay*13 && AbortusTime>0
		castAbortus(4,true)
		return true
	
	; still birth
	elseif abortus==6 &&  ( Utility.GetCurrentGameTime() - AbortusTime)>trimesterTimeDay*16 && AbortusTime>0
		castAbortus(4,true)
		return true
	
	; Baby got some life again
	elseif hp>=10 && abortus<2
		StorageUtil.UnsetIntValue(ActorRef,"FW.Abortus")
		StorageUtil.UnsetFloatValue(ActorRef,"FW.AbortusTime")
	endIf
	return false
endFunction

function AbortusPains()
	if System.cfg.abortus ;Tkc (Loverslab): optimization
	else;if System.cfg.abortus==false
		return
	endif
	if abortus >0
		float Abortus_DamageScale = System.getDamageScale(5, ActorRef)
		if abortus==2 && Utility.RandomInt(0,10)>6
			System.Blur(Utility.RandomFloat(0.3,1.0), System.iModPainLow)
		elseif abortus==3 && Utility.RandomInt(0,10)>3
			System.Blur(Utility.RandomFloat(0.4,1.0), System.iModPainMiddle)
			System.PlayPainSound(ActorRef)
			System.DoDamage(ActorRef,3*Abortus_DamageScale,14)
		elseif abortus==4 && Utility.RandomInt(0,10)>7
			System.Blur(Utility.RandomFloat(0.4,0.8), System.iModPainMiddle)
			System.PlayPainSound(ActorRef)
			System.DoDamage(ActorRef,2*Abortus_DamageScale,14)
		elseif abortus==5 && Utility.RandomInt(0,10)>5
			System.Blur(Utility.RandomFloat(0.4,0.8), System.iModPainMiddle)
			System.PlayPainSound(ActorRef)
			System.DoDamage(ActorRef,4*Abortus_DamageScale,14)
		elseif abortus==6 && Utility.RandomInt(0,10)>4
			if Utility.RandomInt(0,10)>7
				System.Blur(Utility.RandomFloat(0.4,0.6), System.iModPainHigh)
			else
				System.Blur(Utility.RandomFloat(0.4,0.8), System.iModPainMiddle)
			endif
			System.PlayPainSound(ActorRef)
			System.DoDamage(ActorRef,2*Abortus_DamageScale,14)
			Utility.Wait(5)
		endif
		if Abortus_Fiber;/==true/;
			FWUtility.ActorAddSpell(ActorRef, System.FeverSpell, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		endIf
		if Abortus_Infection;/==true/;
			FWUtility.ActorAddSpell(ActorRef, System.InfectionSpell, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		endIf
		
		if System.GlobalMenstruating.GetValueInt(); == 1
			if Utility.RandomInt(1, 100) < 34
				ActorRef.DispelSpell(System.Effect_VaginalBloodLow)
				FWUtility.ActorAddSpell(ActorRef,System.Effect_VaginalBloodHigh, false, true, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			else
				ActorRef.DispelSpell(System.Effect_VaginalBloodHigh)	
				FWUtility.ActorAddSpell(ActorRef,System.Effect_VaginalBloodLow, false, true, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			endif
		endif
		
		Utility.Wait(1)
		checkAbortus()
	endif
endfunction


function castAbortus(float Strength, bool AllowBleedOut = false)
	if System.cfg.abortus ;Tkc (Loverslab): optimization
	else;if System.cfg.abortus==false
		return
	endif
	if IsPlayer
		FWUtility.LockPlayer()
	endif
	
	bool bIsVaginalBleedingEmitter=false
	System.Blur(1,System.AbortusImod)
	Utility.Wait(1)
	if AllowBleedOut
		Debug.SendAnimationEvent(ActorRef, "IdleForceDefaultState")
		Debug.SendAnimationEvent(ActorRef, "BleedOutStart")
		Utility.Wait(2)
		if ( ActorRef.WornHasKeyword(KwArmorCuirass) || ActorRef.WornHasKeyword(KwClothingBody) ) ;Tkc (Loverslab): optimization
		else;if !( ActorRef.WornHasKeyword(KwArmorCuirass) || ActorRef.WornHasKeyword(KwClothingBody) )
			; Actor is naked - start bleeding effect
			FWUtility.EquipItem(ActorRef,System.VaginalBleeding)
			bIsVaginalBleedingEmitter=true
		endif
	endif
	
	ActorRef.DispelSpell(System.Effect_VaginalBloodLow)
	ActorRef.DispelSpell(System.Effect_VaginalBloodHigh)	
	System.Effect_VaginalBloodBig.cast(ActorRef,ActorRef)
	
	int i = Utility.RandomInt(6,9)
	float Abortus_DamageScale = System.getDamageScale(5, ActorRef)
	while i > 0
		i-=1
		System.PlayPainSound(ActorRef)
		System.DoDamage(ActorRef,Strength*Abortus_DamageScale,14)
		Utility.Wait(1.5)
	endWhile
	
	if bIsVaginalBleedingEmitter;/==true/;
		FWUtility.UnEquipItem(ActorRef, System.VaginalBleeding)
		Utility.Wait(2)
	endif
	
	if ActorRef == PlayerRef
		System.Message( FWUtility.StringReplace( Contents.YouHaveLostYourChild,"{0}",ActorRef.GetLeveledActorBase().GetName()), System.MSG_Immersive)
		Utility.Wait(1)
	else
		System.Message( FWUtility.StringReplace( Contents.NPCHasLostItsChild,"{0}",ActorRef.GetLeveledActorBase().GetName()), System.MSG_Immersive)
	endif
	
	if AllowBleedOut
		Debug.SendAnimationEvent(ActorRef, "BleedOutStop");
	endif
	
	StorageUtil.SetIntValue(ActorRef,"FW.NumChilds",0)
	StorageUtil.UnsetFloatValue(ActorRef,"FW.UnbornHealth")
	StorageUtil.FormListClear(ActorRef,"FW.ChildFather")
	StorageUtil.UnsetFloatValue(ActorRef,"FW.AbortusTime")
	StorageUtil.UnsetIntValue(ActorRef,"FW.Abortus")
	
	Utility.Wait(1)
	if IsPlayer
		FWUtility.UnlockPlayer()
	endif
	changeState(8)
endFunction


;--------------------------------------------------------------------------------
; Belly and Brust Size functions
;--------------------------------------------------------------------------------
Function GetBaseMeasurements(Bool bInitMeasurements = False)
	If bInitMeasurements || (BaseBellySize.Length != 2)
		BaseBellySize = New Float[2]
		BaseBellySize[0] = 1.0
		BaseBellySize[1] = 1.0
	EndIf
	If bInitMeasurements || (BaseBreastSize.Length != 8)
		BaseBreastSize = New Float[8]
		BaseBreastSize[0] = 1.0
		BaseBreastSize[1] = 1.0
		BaseBreastSize[2] = 1.0
		BaseBreastSize[3] = 1.0
		BaseBreastSize[4] = 1.0
		BaseBreastSize[5] = 1.0
		BaseBreastSize[6] = 1.0
		BaseBreastSize[7] = 1.0
	EndIf
	
	If NetImmerse.HasNode(ActorRef, "NPC Belly", True)
		BaseBellySize[0] = NetImmerse.GetNodeScale(ActorRef, "NPC Belly", True)
	EndIf
	If NetImmerse.HasNode(ActorRef, "NPC Belly", False)
		BaseBellySize[1] = NetImmerse.GetNodeScale(ActorRef, "NPC Belly", False)
	EndIf
	
	If NetImmerse.HasNode(ActorRef, "NPC L Breast", True)
		BaseBreastSize[0] = NetImmerse.GetNodeScale(ActorRef, "NPC L Breast", True)
	EndIf
	If NetImmerse.HasNode(ActorRef, "NPC L Breast", False)
		BaseBreastSize[1] = NetImmerse.GetNodeScale(ActorRef, "NPC L Breast", False)
	EndIf
	
	If NetImmerse.HasNode(ActorRef, "NPC R Breast", True)
		BaseBreastSize[2] = NetImmerse.GetNodeScale(ActorRef, "NPC R Breast", True)
	EndIf
	If NetImmerse.HasNode(ActorRef, "NPC R Breast", False)
		BaseBreastSize[3] = NetImmerse.GetNodeScale(ActorRef, "NPC R Breast", False)
	EndIf
	
	If NetImmerse.HasNode(ActorRef, "NPC L Breast01", True)
		BaseBreastSize[4] = NetImmerse.GetNodeScale(ActorRef, "NPC L Breast01", True)
	EndIf
	If NetImmerse.HasNode(ActorRef, "NPC L Breast01", False)
		BaseBreastSize[5] = NetImmerse.GetNodeScale(ActorRef, "NPC L Breast01", False)
	EndIf
	
	If NetImmerse.HasNode(ActorRef, "NPC R Breast01", True)
		BaseBreastSize[6] = NetImmerse.GetNodeScale(ActorRef, "NPC R Breast01", True)
	EndIf
	If NetImmerse.HasNode(ActorRef, "NPC R Breast01", False)
		BaseBreastSize[7] = NetImmerse.GetNodeScale(ActorRef, "NPC R Breast01", False)
	EndIf
	
	BaseWeight = ActorRefBase.GetWeight()
	
	If ( bInitMeasurements) ;Tkc (Loverslab): optimization
	else;If (! bInitMeasurements)
		BaseBellySize[0] = BaseBellySize[0] - AddedBellySize
		BaseBellySize[1] = BaseBellySize[1] - AddedBellySize
		
		BaseBreastSize[0] = BaseBreastSize[0] - AddedBreastSize
		BaseBreastSize[1] = BaseBreastSize[1] - AddedBreastSize
		BaseBreastSize[2] = BaseBreastSize[2] - AddedBreastSize
		BaseBreastSize[3] = BaseBreastSize[3] - AddedBreastSize
		
		BaseBreastSize[4] = BaseBreastSize[4] - AddedBreastSize
		BaseBreastSize[5] = BaseBreastSize[5] - AddedBreastSize
		BaseBreastSize[6] = BaseBreastSize[6] - AddedBreastSize
		BaseBreastSize[7] = BaseBreastSize[7] - AddedBreastSize
		
		BaseWeight -= AddedWeight
	EndIf
EndFunction

Function SLIF_inflate(Actor kActor, String sKey, float value)
	int SLIF_event = ModEvent.Create("SLIF_inflate")
	If (SLIF_event)
		ModEvent.PushForm(SLIF_event, kActor)
		ModEvent.PushString(SLIF_event, "Beeing Female")
		ModEvent.PushString(SLIF_event, sKey)
		ModEvent.PushFloat(SLIF_event, value)
		ModEvent.PushString(SLIF_event, "BeeingFemale")
		ModEvent.Send(SLIF_event)
	EndIf
EndFunction

Function SLIF_unregisterNode(Actor kActor, String sKey)
	int SLIF_event = ModEvent.Create("SLIF_unregisterNode")
	If (SLIF_event)
		ModEvent.PushForm(SLIF_event, kActor)
		ModEvent.PushString(SLIF_event, "Beeing Female")
		ModEvent.PushString(SLIF_event, sKey)
		ModEvent.Send(SLIF_event)
	EndIf
EndFunction

Function UpdateNodesSLIF(Float afAddedBellySize, Float afAddedBreastSize)
	If System.cfg.BellyScale;/==true/;
		SLIF_inflate(ActorRef, "slif_belly", afAddedBellySize + 1)
	Else
		SLIF_unregisterNode(ActorRef, "slif_belly")
	EndIf
	If System.cfg.BreastScale;/==true/;
		SLIF_inflate(ActorRef, "slif_breast", afAddedBreastSize + 1)
	Else
		SLIF_unregisterNode(ActorRef, "slif_breast")
	EndIf
EndFunction

Function UpdateNodes2(Float afAddedBellySize, Float afAddedBreastSize)
	If ActorRef;/!=none/;
		If System.cfg.BellyScale;/==true/;
			if(afAddedBellySize>0)  ;Patched by qotsafan was ->  if(afAddedBreastSize>0)
				NiOverride.AddNodeTransformScale(ActorRef, true, true, "NPC Belly", "BeeingFemale", afAddedBellySize +1)
				NiOverride.AddNodeTransformScale(ActorRef, false, true, "NPC Belly", "BeeingFemale", afAddedBellySize +1)
			else
				NiOverride.RemoveNodeTransformScale(ActorRef, true, true, "NPC Belly", "BeeingFemale")
				NiOverride.RemoveNodeTransformScale(ActorRef, false, true, "NPC Belly", "BeeingFemale")
			endif
			
			NiOverride.UpdateNodeTransform(ActorRef, true, true, "NPC Belly")
			NiOverride.UpdateNodeTransform(ActorRef, false, true, "NPC Belly")
		EndIf
		
		If System.cfg.BreastScale;/==true/;
			if(afAddedBreastSize>0)
				NiOverride.AddNodeTransformScale(ActorRef, true, true, "NPC L Breast", "BeeingFemale", afAddedBreastSize +1)
				NiOverride.AddNodeTransformScale(ActorRef, false, true, "NPC L Breast", "BeeingFemale", afAddedBreastSize +1)
				
				NiOverride.AddNodeTransformScale(ActorRef, true, true, "NPC R Breast", "BeeingFemale", afAddedBreastSize +1)
				NiOverride.AddNodeTransformScale(ActorRef, false, true, "NPC R Breast", "BeeingFemale", afAddedBreastSize +1)
				
				NiOverride.UpdateNodeTransform(ActorRef, true, true, "NPC L Breast")
				NiOverride.UpdateNodeTransform(ActorRef, false, true, "NPC R Breast")
			else
				NiOverride.RemoveNodeTransformScale(ActorRef, true, true, "NPC L Breast", "BeeingFemale")
				NiOverride.RemoveNodeTransformScale(ActorRef, false, true, "NPC L Breast", "BeeingFemale")
				
				NiOverride.RemoveNodeTransformScale(ActorRef, true, true, "NPC R Breast", "BeeingFemale")
				NiOverride.RemoveNodeTransformScale(ActorRef, false, true, "NPC R Breast", "BeeingFemale")
			endif
			
			NiOverride.UpdateNodeTransform(ActorRef, true, true, "NPC L Breast")
			NiOverride.UpdateNodeTransform(ActorRef, false, true, "NPC L Breast")
			NiOverride.UpdateNodeTransform(ActorRef, true, true, "NPC R Breast")
			NiOverride.UpdateNodeTransform(ActorRef, false, true, "NPC R Breast")
		EndIf
		
	EndIf
EndFunction

Function UpdateNodes(Float afAddedBellySize, Float afAddedBreastSize)
	If ActorRef;/!=none/;
		; b3lisario Body Scaling
		If BaseBellySize.Length == 2 && System.cfg.BellyScale;/==true/;
			If NetImmerse.HasNode(ActorRef, "NPC Belly", True)
				NetImmerse.SetNodeScale(ActorRef, "NPC Belly", afAddedBellySize + BaseBellySize[0], True)
			EndIf
			If NetImmerse.HasNode(ActorRef, "NPC Belly", False)
				NetImmerse.SetNodeScale(ActorRef, "NPC Belly", afAddedBellySize + BaseBellySize[1], False)
			EndIf
			AddedBellySize = afAddedBellySize
		EndIf
		
		If BaseBreastSize.Length == 8 && System.cfg.BreastScale;/==true/;
			
			If NetImmerse.HasNode(ActorRef, "NPC L Breast", True)
				NetImmerse.SetNodeScale(ActorRef, "NPC L Breast", afAddedBreastSize + BaseBreastSize[0], True)
			EndIf
			If NetImmerse.HasNode(ActorRef, "NPC L Breast", False)
				NetImmerse.SetNodeScale(ActorRef, "NPC L Breast", afAddedBreastSize + BaseBreastSize[1], False)
			EndIf
			
			If NetImmerse.HasNode(ActorRef, "NPC R Breast", True)
				NetImmerse.SetNodeScale(ActorRef, "NPC R Breast", afAddedBreastSize + BaseBreastSize[2], True)
			EndIf
			If NetImmerse.HasNode(ActorRef, "NPC R Breast", False)
				NetImmerse.SetNodeScale(ActorRef, "NPC R Breast", afAddedBreastSize + BaseBreastSize[3], False)
			EndIf
			
			; For Torpedo-Fix
			If NetImmerse.HasNode(ActorRef, "NPC L Breast01", True)
				NetImmerse.SetNodeScale(ActorRef, "NPC L Breast01", afAddedBreastSize + BaseBreastSize[4], True)
			EndIf
			If NetImmerse.HasNode(ActorRef, "NPC L Breast01", False)
				NetImmerse.SetNodeScale(ActorRef, "NPC L Breast01", afAddedBreastSize + BaseBreastSize[5], False)
			EndIf
			
			If NetImmerse.HasNode(ActorRef, "NPC R Breast01", True)
				NetImmerse.SetNodeScale(ActorRef, "NPC R Breast01", afAddedBreastSize + BaseBreastSize[6], True)
			EndIf
			If NetImmerse.HasNode(ActorRef, "NPC R Breast01", False)
				NetImmerse.SetNodeScale(ActorRef, "NPC R Breast01", afAddedBreastSize + BaseBreastSize[7], False)
			EndIf
			AddedBreastSize = afAddedBreastSize
		EndIf
		
		If ( ActorRef.IsOnMount()) ;Tkc (Loverslab): optimization
		else;If (! ActorRef.IsOnMount())
			ActorRef.QueueNiNodeUpdate()
		EndIf
	EndIf
EndFunction

Function UpdateWeight(Float afAddedWeight)
	Float NewWeight = FWUtility.ClampFloat(BaseWeight + afAddedWeight, 0.0, 100.0)
	Float NeckDelta = (ActorRefBase.GetWeight() - NewWeight) / 100
	
	;If NeckDelta && (! ActorRef.IsOnMount())
	If NeckDelta ;Tkc (Loverslab): optimization
	 if ( ActorRef.IsOnMount())
	 else;if (! ActorRef.IsOnMount())
		ActorRefBase.SetWeight(NewWeight)
		ActorRef.UpdateWeight(NeckDelta)
		ActorRef.QueueNiNodeUpdate()
		
		AddedWeight = NewWeight - BaseWeight
	 EndIf
	EndIf
EndFunction

Function ResetBelly()
	if Game.GetModbyName("SexLab Inflation Framework.esp") != 255
		UpdateNodesSLIF(0, 0)
	elseif lastTypeOfScaling == 1
		UpdateNodes(0, 0)
	elseif lastTypeOfScaling == 2
		UpdateNodes2(0, 0)
	elseif lastTypeOfScaling == 3
		UpdateWeight(0)
	endif
EndFunction

function TestScale(float Scale=1.0)
	If Game.GetModbyName("SexLab Inflation Framework.esp") != 255
		UpdateNodesSLIF(Scale * System.cfg.BellyMaxScale, Scale * System.cfg.BreastsMaxScale)
	ElseIf System.cfg.VisualScaling == 1
		if lastTypeOfScaling == 2
			UpdateNodes2(0, 0)
		elseif lastTypeOfScaling == 3
			UpdateWeight(0.0)
		endif
		UpdateNodes(Scale * System.cfg.BellyMaxScale, Scale * System.cfg.BreastsMaxScale)
	ElseIf System.cfg.VisualScaling == 2
		if lastTypeOfScaling == 1
			UpdateNodes(0, 0)
		elseif lastTypeOfScaling == 3
			UpdateWeight(0.0)
		endif
		UpdateNodes2(Scale * System.cfg.BellyMaxScale, Scale * System.cfg.BreastsMaxScale)
	ElseIf System.cfg.VisualScaling == 3
		if lastTypeOfScaling == 1
			UpdateNodes(0, 0)
		elseif lastTypeOfScaling == 2
			UpdateNodes2(0, 0)
		endif
		Float MaxAdditionalWeight = FWUtility.MinFloat(System.cfg.WeightGainMax, 100 - BaseWeight)
		Float addWeight = (Scale * MaxAdditionalWeight)
		UpdateWeight(addWeight)
	EndIf
	Utility.Wait(10)
	Debug.Notification("Reset Belly for "+ActorRef.GetLeveledActorBase().GetName())
	SetBelly(true)
endFunction

Function SetBelly(bool bForce=false)
	float startTime = Utility.GetCurrentGameTime()
	;if (currentState<4 || currentState>=20 || System.IsActorPregnantByChaurus(ActorRef)) && bForce==false  ;-->Bane SetBellyTest
	if bForce ;Tkc (Loverslab): optimization
	else;if bForce==false
		if (currentState<4 || currentState>=20 || System.IsActorPregnantByChaurus(ActorRef))
			return
		endif
	endif
	If (System.cfg.VisualScaling > 0)
		Int stateID = currentState
		
		float ScaleBelly = 0.0
		float ScaleBreast = 0.0
		
		; Scale up belly and breasts depending on how far along actor is in her
		; pregnancy
		If stateID == 4
			; Add scale value of current trimester
			ScaleBelly = System.GetPhaseScale(0, 0) * (CurrentStatePercent / 100)
			ScaleBreast = System.GetPhaseScale(1, 0) * (CurrentStatePercent / 100)
		ElseIf stateID == 5
			ScaleBelly = System.GetPhaseScale(0, 0) + (System.GetPhaseScale(0, 1) * (CurrentStatePercent / 100))
			ScaleBreast = System.GetPhaseScale(1, 0) + (System.GetPhaseScale(1, 1) * (CurrentStatePercent / 100))
		ElseIf stateID == 6
			ScaleBelly = System.GetPhaseScale(0, 0) + System.GetPhaseScale(0, 1) + (System.GetPhaseScale(0, 2) * (CurrentStatePercent / 100))
			ScaleBreast = System.GetPhaseScale(0, 0) + System.GetPhaseScale(1, 1) + (System.GetPhaseScale(1, 2) * (CurrentStatePercent / 100))
			
		; Set to maximum scale in labor pains phase and later
		ElseIf stateID == 7
			ScaleBelly = 1.0
			ScaleBreast = 1.0
		
		; Scale back belly and breasts over the course of recovery  phase
		ElseIf stateID == 8
			ScaleBelly = FWUtility.MaxFloat(0.0, (33 - CurrentStatePercent) / 100)
			ScaleBreast = FWUtility.MaxFloat(0.0, (100 - CurrentStatePercent) / 100)
		EndIf
		
		; Scale with number of children
		If NumChilds > 1 && stateID<8
			ScaleBelly *= Math.Pow(1.15, NumChilds - 1)
			ScaleBreast *= Math.Pow(1.08, NumChilds - 1)
		EndIf
		
		; Race specific scaling
		
		If Game.GetModbyName("SexLab Inflation Framework.esp") != 255
			UpdateNodesSLIF(ScaleBelly * System.cfg.BellyMaxScale, ScaleBreast * System.cfg.BreastsMaxScale)
		ElseIf System.cfg.VisualScaling == 1
			if lastTypeOfScaling == 2
				UpdateNodes2(0, 0)
			elseif lastTypeOfScaling == 3
				UpdateWeight(0.0)
			endif
			UpdateNodes(ScaleBelly * System.cfg.BellyMaxScale, ScaleBreast * System.cfg.BreastsMaxScale)
		ElseIf System.cfg.VisualScaling == 2
			if lastTypeOfScaling == 1
				UpdateNodes(0, 0)
			elseif lastTypeOfScaling == 3
				UpdateWeight(0.0)
			endif
			UpdateNodes2(ScaleBelly * System.cfg.BellyMaxScale, ScaleBreast * System.cfg.BreastsMaxScale)
		ElseIf System.cfg.VisualScaling == 3
			if lastTypeOfScaling == 1
				UpdateNodes(0, 0)
			elseif lastTypeOfScaling == 2
				UpdateNodes2(0, 0)
			endif
			Float MaxAdditionalWeight = FWUtility.MinFloat(System.cfg.WeightGainMax, 100 - BaseWeight)
			Float addWeight = (ScaleBelly * MaxAdditionalWeight)
			UpdateWeight(addWeight)
		EndIf
		
		lastTypeOfScaling = System.cfg.VisualScaling
	Else;if lastTypeOfScaling != System.cfg.VisualScaling
		if lastTypeOfScaling == System.cfg.VisualScaling ;Tkc (Loverslab): optimization
		else;if lastTypeOfScaling != System.cfg.VisualScaling
			ResetBelly()
			lastTypeOfScaling = System.cfg.VisualScaling
		EndIf
	EndIf
	System.Message("FWAbilityBeeingFemale::SetBelly("+ActorRef.GetLeveledActorBase().GetName()+") " + (Utility.GetCurrentRealTime() - startTime) + " sec", System.MSG_All, System.MSG_Trace)
EndFunction



function castMentrualBlood()
	;if !ActorRef || System.GlobalMenstruating.GetValueInt() != 1
	if ActorRef ;Tkc (Loverslab): optimization
	else;if !ActorRef
		return
	endif
	if System.GlobalMenstruating.GetValueInt() ;Tkc (Loverslab): optimization
	else;if System.GlobalMenstruating.GetValueInt() != 1
		return
	endif
	if ActorRef.IsEquipped(System.Sanitary_Napkin_Normal) || ActorRef.IsEquipped(System.Tampon_Normal)
		; Panty or Tampon is equipped		
		if ActorRef.IsEquipped(System.Sanitary_Napkin_Normal)
			if IsPlayer;/==true/;
				System.Message( System.Content.YourPantys, System.MSG_Low)
				ActorRef.UnequipItem(System.Sanitary_Napkin_Normal, false, true)
				ActorRef.RemoveItem(System.Sanitary_Napkin_Normal, 1, true)
				ActorRef.addItem(System.Sanitary_Napkin_Bloody, 1, true)
				ActorRef.EquipItem(System.Sanitary_Napkin_Bloody, false, true)
			else
				System.Message( FWUtility.StringReplace( System.Content.NPCPantys , "{0}", ActorRef.GetLeveledActorBase().GetName()), System.MSG_Debug)
				ActorRef.UnequipItem(System.Sanitary_Napkin_Normal, false, true)
				ActorRef.RemoveItem(System.Sanitary_Napkin_Normal, 1, true)
				ActorRef.addItem(System.Sanitary_Napkin_Bloody, 1, true)
				ActorRef.EquipItem(System.Sanitary_Napkin_Bloody, false, true)
				Utility.WaitGameTime(0.5) ; Wait some time till redress another sani napkin
				EquipNapkin()
			endif
		else
			if IsPlayer;/==true/;
				System.Message( System.Content.YourTampon, System.MSG_Low)
				ActorRef.UnequipItem(System.Tampon_Normal, false, true)
				ActorRef.RemoveItem(System.Tampon_Normal, 1, true)
				ActorRef.addItem(System.Tampon_Bloody, 1, true)
				ActorRef.EquipItem(System.Tampon_Bloody, false, true)
			else
				System.Message( FWUtility.StringReplace( System.Content.NPCTampon , "{0}", ActorRef.GetLeveledActorBase().GetName()), System.MSG_Debug)
				ActorRef.UnequipItem(System.Tampon_Normal, false, true)
				ActorRef.RemoveItem(System.Tampon_Normal, 1, true)
				ActorRef.addItem(System.Tampon_Bloody, 1, true)
				ActorRef.EquipItem(System.Tampon_Bloody, false, true)
				Utility.WaitGameTime(0.5) ; Wait some time till redress another sani napkin
				EquipTampon()
			endif
		endif
	else
		; Cast blood
		if (CurrentStatePercent > 40.0 && CurrentStatePercent < 60.0)
			ActorRef.DispelSpell(System.Effect_VaginalBloodLow)			
			FWUtility.ActorAddSpell(ActorRef,System.Effect_VaginalBloodHigh, false, true, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		else
			ActorRef.DispelSpell(System.Effect_VaginalBloodHigh)	
			FWUtility.ActorAddSpell(ActorRef,System.Effect_VaginalBloodLow, false, true, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		endif
	endif
endFunction

function EquipNapkin()
	if System.GlobalMenstruating.GetValueInt(); == 1 ;Tkc (Loverslab): optimization
		;if ActorRef.GetItemCount(System.Sanitary_Napkin_Normal)>1 && ActorRef.IsEquipped(System.Sanitary_Napkin_Normal)==false
		if ActorRef.GetItemCount(System.Sanitary_Napkin_Normal)>1 ;Tkc (Loverslab): optimization
		 if ActorRef.IsEquipped(System.Sanitary_Napkin_Normal)
		 else;if ActorRef.IsEquipped(System.Sanitary_Napkin_Normal)==false
			form ax = ActorRef.GetWornForm(System.Sanitary_Napkin_Normal.GetSlotMask())
			if ax;/!=none/;
				ActorRef.UnequipItem(ax)
			endif
			ActorRef.EquipItem(System.Sanitary_Napkin_Bloody, false, true)
		 endif
		endif
	endif
endfunction

function EquipTampon()
	if System.GlobalMenstruating.GetValueInt(); == 1 ;Tkc (Loverslab): optimization
		;if ActorRef.GetItemCount(System.Tampon_Normal)>1 && ActorRef.IsEquipped(System.Tampon_Normal)==false
		if ActorRef.GetItemCount(System.Tampon_Normal)>1 ;Tkc (Loverslab): optimization
		 if ActorRef.IsEquipped(System.Tampon_Normal);
		 else;if ActorRef.IsEquipped(System.Tampon_Normal)==false
			form ax = ActorRef.GetWornForm(System.Tampon_Normal.GetSlotMask())
			if ax;/!=none/;
				ActorRef.UnequipItem(ax)
			endif
			ActorRef.EquipItem(System.Tampon_Bloody, false, true)
		 endif
		endif
	endif
endfunction

float SleepingStart
Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
	SleepingStart=Utility.GetCurrentGameTime()
	parent.OnSleepStart(afSleepStartTime, afDesiredSleepEndTime)
endEvent
Event OnSleepStop(bool abInterrupted)
	float SleepDur
	if SleepingStart>0.0
		SleepDur = Utility.GetCurrentGameTime() - SleepingStart
		System.Controller.HealBaby(ActorRef,SleepDur*1.3)
	endif
	SleepingStart=0.0
	parent.OnSleepStop(abInterrupted)
endEvent
float SitStart
Event OnSit(ObjectReference akFurniture)
	SitStart=Utility.GetCurrentGameTime()
endEvent
Event OnGetUp(ObjectReference akFurniture)
	float SitDur
	if SitStart>0.0
		SitDur = Utility.GetCurrentGameTime() - SitStart
		System.Controller.HealBaby(ActorRef,SitDur*0.5)
	endif
	SitStart=0.0
endEvent

Event OnDeath(Actor akKiller)
	parent.OnDeath(akKiller)
	;if ActorRef==PlayerRef
	if IsPlayer ;Tkc (Loverslab): optimization. IsPlayer is true if ActorRef==PlayerRef
		System.Controller.DamageBaby(ActorRef,92)
	else
		FWSaveLoad.Delete(ActorRef)
	endif	
endEvent





;--------------------------------------------------------------------------------
; StateFunctions
;--------------------------------------------------------------------------------
function onEnterState()
endFunction
function onExitState()
endFunction
function onUpdateFunction()
endFunction
function onHitFunction(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
endFunction
function onPotionFunction(potion Item)
endFunction
function onCastSpellFunction(spell SpellID)
endFunction

;--------------------------------------------------------------------------------
; State - Follicular
;--------------------------------------------------------------------------------
state Follicular_State
	function onEnterState()
		System.Manager.removeCME(ActorRef) ; Remove All effects
		;if ActorRef==PlayerRef
		if IsPlayer ;Tkc (Loverslab): optimization. IsPlayer is true if ActorRef==PlayerRef
			System.Controller.setAutoFlag(ActorRef)
		endIf
		System.Manager.CastCME(ActorRef,0,System.cfg.PMSEffects)
		bHasPMS==false
		if IsPlayer ;Tkc (Loverslab): show widged when state was changed
			System.StateWidget.showTimed(ActorRef)
		endif
	endFunction
		
	function onExitState()
		ActorRef.removeSpell(System.Effect_Vorwehen)
		System.Manager.RemoveCME(ActorRef,0) ; Remove Follicular Effects
		bHasPMS==false
	endfunction
endState

;--------------------------------------------------------------------------------
; State - Ovulation
;--------------------------------------------------------------------------------
state Ovulation_State

	function onEnterState()
		System.Manager.removeCME(ActorRef,0) ; Remove Follicular Effects
		FWUtility.ActorAddSpell(ActorRef,System.Effect_Mittelschmerz, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		System.Manager.CastCME(ActorRef,1,System.cfg.PMSEffects)
		bHasPMS==false
		if IsPlayer ;Tkc (Loverslab): show widged when state was changed
			System.StateWidget.showTimed(ActorRef)
		endif
	endfunction
	
	function onUpdateFunction()
		if CurrentStatePercent > 40
			FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Mittelschmerz)
		else
			FWUtility.ActorAddSpell(ActorRef,System.Effect_Mittelschmerz, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		endif
		if CurrentStatePercent >= 50
			; Check for Pregnancy
			int rnd = Utility.RandomInt(0,15)
			if rnd<7
				; Actor is pregnant!
				if System.Controller.ActiveSpermImpregnation(ActorRef);/==true/;
					FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Mittelschmerz)
					changeState(4)
				endif
			endIf
		endif
	endfunction
	
	function onExitState()
		; Make sure Mittelschmerz was removed
		FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Mittelschmerz)
		System.Manager.removeCME(ActorRef,1)
		bHasPMS==false
	endfunction
endState

;--------------------------------------------------------------------------------
; State - Luteal
;--------------------------------------------------------------------------------
state Luteal_State
	function onUpdateFunction()
		if CurrentStatePercent < 65
			; Check for Pregnancy
			; Simulate FH Hormones
			Float rnd = Utility.RandomFloat(0,100)
			float chance = System.LutealImpregnationTime(CurrentStatePercent)
			if chance > rnd
				if System.Controller.ActiveSpermImpregnation(ActorRef);/==true/;
					; Actor is pregnant!
					System.Manager.removeCME(ActorRef,3) ; PMS Effects
					changeState(4)
					return
				endif
			endIf
		endIf
		if CurrentStatePercent > 75
			; Check for PMS
			;if bHasPMS==false && System.Controller.canBecomePMS(ActorRef);/==true/;
			if bHasPMS ;Tkc (Loverslab): optimization
			else;if bHasPMS==false
				if System.Controller.canBecomePMS(ActorRef)
					System.Message("Cast PMS for "+ActorRef.GetLeveledActorBase().GetName(), System.MSG_Debug )
					System.Manager.castCME(ActorRef,3,System.cfg.PMSEffects)
					bHasPMS=true
				endIf
			endIf
			
			; Check for Tampons
			;if !isPlayer && ActorRef.GetItemCount(System.Tampon_Normal)<=2  ;***Edit by Bane
			if isPlayer ;Tkc (Loverslab): optimization
			else;if !isPlayer
				if ActorRef.GetItemCount(System.Tampon_Normal)<=2
					ActorRef.AddItem(System.Tampon_Normal,6)
				endif
			endif
		endif
	endFunction
	
	function onEnterState()
		System.Manager.removeCME(ActorRef,1)
		System.Manager.CastCME(ActorRef,2,System.cfg.PMSEffects)
		bHasPMS=false
		if CurrentStatePercent > 75
			; Check for PMS
			;if bHasPMS==false && System.Controller.canBecomePMS(ActorRef);/==true/;
			if bHasPMS ;Tkc (Loverslab): optimization
			else;if bHasPMS==false
				if System.Controller.canBecomePMS(ActorRef)
					bHasPMS=true
					System.Message("Cast PMS for "+ActorRef.GetLeveledActorBase().GetName(), System.MSG_Debug )
					System.Manager.castCME(ActorRef,3,System.cfg.PMSEffects)
					System.Message("Casted", System.MSG_Debug )
				endIf
			endIf
		endif
		if IsPlayer ;Tkc (Loverslab): show widged when state was changed
			System.StateWidget.showTimed(ActorRef)
		endif
	endFunction
	
	function onExitState()
		; Remove PMS
		System.Manager.RemoveCME(ActorRef,2) ; Lutheal Effects
		System.Manager.removeCME(ActorRef,3) ; PMS Effects
		bHasPMS=false
	endFunction
endState

;--------------------------------------------------------------------------------
; State - Menstruation
;--------------------------------------------------------------------------------
state Menstruation_State
	function onEnterState()
		EquipNapkin()
		FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Nachwehen)
		FWUtility.ActorAddSpell(ActorRef,System.Effect_MenstruationCramps, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		System.Manager.removeCME(ActorRef,3)
		System.Manager.removeCME(ActorRef,2)
		System.Manager.CastCME(ActorRef,4,System.cfg.PMSEffects)
		bHasPMS=false
		if IsPlayer ;Tkc (Loverslab): show widged when state was changed
			System.StateWidget.showTimed(ActorRef)
		endif
	endfunction
	
	function onUpdateFunction()
		EquipNapkin()
		Float fStateFlowRisk = CurrentStatePercent
		If fStateFlowRisk > 50.0
			fStateFlowRisk = 50.0 - (fStateFlowRisk - 50.0)
		EndIf
		if Utility.RandomFloat(1,100) < fStateFlowRisk
			castMentrualBlood()
		endif
		;if !isPlayer && ActorRef.GetItemCount(System.Tampon_Normal)<=2 ;***Edit by Bane
		if isPlayer ;Tkc (Loverslab): optimization
		else;if !isPlayer
			if ActorRef.GetItemCount(System.Tampon_Normal)<=2
				ActorRef.AddItem(System.Tampon_Normal,6)
			endif
		endif
		EquipNapkin()
	endfunction
	
	function onExitState()
		FWUtility.ActorRemoveSpell(ActorRef,System.Effect_MenstruationCramps)
		ActorRef.DispelSpell(System.Effect_VaginalBloodLow)					
		ActorRef.DispelSpell(System.Effect_VaginalBloodHigh)	
		System.Controller.setAutoFlag(ActorRef)
		System.Manager.RemoveCME(ActorRef)
	endfunction

endState

;--------------------------------------------------------------------------------
; State 1. Trimester
;--------------------------------------------------------------------------------
state PregnancyFirst_State
	function onHitFunction(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		;if (abPowerAttack || abSneakAttack || abBashAttack) && !abHitBlocked
		if abHitBlocked ;Tkc (Loverslab): optimization
		else;if !abHitBlocked ;Tkc (Loverslab): optimization
			if (abPowerAttack || abSneakAttack || abBashAttack)
				System.Controller.DamageBaby(ActorRef, Utility.RandomFloat(2,7))
			endIf
		endIf
	endfunction
	
	function onEnterState()
		System.Manager.RemoveCME(ActorRef,4)
		System.Manager.CastCME(ActorRef,5,System.cfg.PMSEffects)
		if IsPlayer ;Tkc (Loverslab): show widged when state was changed
			System.StateWidget.showTimed(ActorRef)
		endif
	endFunction
	
	function onExitState()
		System.Manager.RemoveCME(ActorRef,5)
	endFunction
	
	function onPotionFunction(potion p)
		int c = p.GetNumEffects()
		while c>0
			c-=1
			if p.GetNthEffectMagicEffect(c).HasKeywordString("MagicAlchRestoreHealth")
				System.Controller.HealBaby(ActorRef, p.GetNthEffectMagnitude(c) / 5)
			endif
			if p.GetNthEffectMagicEffect(c).HasKeywordString("MagicAlchHarmful")
				System.Controller.DamageBaby(ActorRef, p.GetNthEffectMagnitude(c) / 10)
			endif
		endwhile
	endFunction
	
	function onUpdateFunction()
		checkAbortus()
		float GT = Utility.GetCurrentGameTime()
		int HealAmount = Math.Floor( GT - LastBabyHealing)
		if HealAmount >0
			System.Controller.HealBaby(ActorRef, HealAmount )
			LastBabyHealing=GT
		endif
	endFunction
endState

;--------------------------------------------------------------------------------
; State 2. Trimester
;--------------------------------------------------------------------------------
state PregnancySecond_State
	function onHitFunction(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		;if (abPowerAttack || abSneakAttack || abBashAttack) && !abHitBlocked
		if abHitBlocked ;Tkc (Loverslab): optimization
		else;if !abHitBlocked
			if (abPowerAttack || abSneakAttack || abBashAttack)
				System.Controller.DamageBaby(ActorRef, Utility.RandomFloat(0,3))
			endIf
		endIf
	endfunction
	
	function onEnterState()
		System.Manager.RemoveCME(ActorRef,5)
		System.Manager.CastCME(ActorRef,6,System.cfg.PMSEffects)
		if IsPlayer ;Tkc (Loverslab): show widged when state was changed
			System.StateWidget.showTimed(ActorRef)
		endif
	endFunction
	
	function onExitState()
		System.Manager.RemoveCME(ActorRef,6)
	endFunction
	
	function onPotionFunction(potion p)
		int c = p.GetNumEffects()
		while c>0
			c-=1
			if p.GetNthEffectMagicEffect(c).HasKeywordString("MagicAlchRestoreHealth")
				System.Controller.HealBaby(ActorRef, p.GetNthEffectMagnitude(c) / 10)
			endif
			if p.GetNthEffectMagicEffect(c).HasKeywordString("MagicAlchHarmful")
				System.Controller.DamageBaby(ActorRef, p.GetNthEffectMagnitude(c) / 10)
			endif
		endwhile
	endFunction
	
	function onUpdateFunction()
		checkAbortus()
		float GT = Utility.GetCurrentGameTime()
		int HealAmount = Math.Floor( GT - LastBabyHealing) * 3
		if HealAmount >0
			System.Controller.HealBaby(ActorRef, HealAmount )
			LastBabyHealing=GT
		endif
	endFunction
endState

;--------------------------------------------------------------------------------
; State 3. Trimester
;--------------------------------------------------------------------------------
state PregnancyThird_State
	function onUpdateFunction()
		if CurrentStatePercent > 90
			; Vorwehen
			FWUtility.ActorAddSpell(ActorRef,System.Effect_Vorwehen, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		endIf
		if CurrentStatePercent > 75 && Utility.RandomInt(0,10)>4
			; Breast milk
			int rnd= Utility.RandomInt(0,10)
			if rnd<6
				System.Message("Breast Milk1 ("+ActorRef.GetLeveledActorBase().GetName()+")",System.MSG_All)
				FWUtility.ActorAddSpell(ActorRef,System.Effect_BreastMilk1,false,true, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			elseif rnd<10
				System.Message("Breast Milk2 ("+ActorRef.GetLeveledActorBase().GetName()+")",System.MSG_All)
				FWUtility.ActorAddSpell(ActorRef,System.Effect_BreastMilk2,false,true, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			else
				System.Message("Breast Milk3 ("+ActorRef.GetLeveledActorBase().GetName()+")",System.MSG_All)
				FWUtility.ActorAddSpell(ActorRef,System.Effect_BreastMilk3,false,true, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			endif
		endIf
		checkAbortus()
		
		; Baby hits - let the controler vibrate
		if Utility.RandomInt(0, 100) > 60
			float intensity = Utility.RandomFloat(0.5, 1.0)
			game.shakeController(intensity, intensity, Utility.RandomFloat(0.2, 1.0))
		endif
		
		float GT = Utility.GetCurrentGameTime()
		int HealAmount = Math.Floor( GT - LastBabyHealing) * 5
		if HealAmount >0
			System.Controller.HealBaby(ActorRef, HealAmount )
			LastBabyHealing=GT
		endif
	endFunction
	
	function onEnterState()
		System.Manager.RemoveCME(ActorRef,6)
		System.Manager.CastCME(ActorRef,7,System.cfg.PMSEffects)
		if IsPlayer ;Tkc (Loverslab): show widged when state was changed
			System.StateWidget.showTimed(ActorRef)
		endif
	endFunction
	
	function onHitFunction(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		;if (abPowerAttack || abSneakAttack || abBashAttack) && !abHitBlocked
		if abHitBlocked ;Tkc (Loverslab): optimization
		else;if !abHitBlocked
			if (abPowerAttack || abSneakAttack || abBashAttack)
				System.Controller.DamageBaby(ActorRef, Utility.RandomFloat(0,2))
			endIf
		endIf
	endfunction
	
	function onPotionFunction(potion p)
		int c = p.GetNumEffects()
		while c>0
			c-=1
			if p.GetNthEffectMagicEffect(c).HasKeywordString("MagicAlchRestoreHealth")
				System.Controller.HealBaby(ActorRef, p.GetNthEffectMagnitude(c) / 10)
			endif
			if p.GetNthEffectMagicEffect(c).HasKeywordString("MagicAlchHarmful")
				System.Controller.DamageBaby(ActorRef, p.GetNthEffectMagnitude(c) / 10)
			endif
		endwhile
	endFunction
	
	function onExitState()
		; Remove Vorwehen
		FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Vorwehen)
		System.Manager.RemoveCME(ActorRef,7)
	endFunction
endState

;--------------------------------------------------------------------------------
; State Labor Pains
;--------------------------------------------------------------------------------

Bool bWatersBroken

state LaborPains_State

	function onEnterState()
		bWatersBroken = false
		System.Manager.RemoveCME(ActorRef,7)
		System.Manager.CastCME(ActorRef,8,System.cfg.PMSEffects)
		if CurrentStatePercent >=50 && CurrentStatePercent<95 && ActorRef.HasSpell(System.Effect_Presswehen)==false
			FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Eroeffnungswehen)
			FWUtility.ActorAddSpell(ActorRef,System.Effect_Presswehen, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			System.Controller.GiveBirth(ActorRef)
			return
		elseif CurrentStatePercent>=95
			System.InstantBornChilds(ActorRef)
			changeState(8)
			return
		else;if CurrentStatePercent < 50 && !bWatersBroken
		  if CurrentStatePercent < 50 ;Tkc (Loverslab): optimization
		  if bWatersBroken
		  else;if !bWatersBroken
			bWatersBroken = true
			FWUtility.ActorAddSpell(ActorRef,System.Effect_Eroeffnungswehen, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			;if ActorRef==PlayerRef
			if IsPlayer ;Tkc (Loverslab): optimization. IsPlayer is true if ActorRef==PlayerRef
				FWUtility.LockPlayer()
				System.Message(Contents.YourPregnantWaterBreaks,System.MSG_Immersive)
			else
				System.Message( FWUtility.StringReplace(Contents.NPCPregnantWaterBreaks,"{0}",ActorRef.GetLeveledActorBase().GetName()) ,System.MSG_Low)
			endif
			FWUtility.EquipItem(ActorRef,System.AmnioticFluid)
			Utility.Wait(8)
			FWUtility.UnequipItem(ActorRef,System.AmnioticFluid)
			;if ActorRef==PlayerRef
			if IsPlayer ;Tkc (Loverslab): optimization. IsPlayer is true if ActorRef==PlayerRef
				FWUtility.UnlockPlayer()
			endif
		  endif
		  endif
		endif
		if IsPlayer ;Tkc (Loverslab): show widged when state was changed
			System.StateWidget.showTimed(ActorRef)
		endif
	endFunction
	
	function onUpdateFunction()
		;Debug.Trace(CurrentStatePercent+"% at Labor Pains for "+ActorRef.GetLeveledActorBase().GetName())
		if CurrentStatePercent >=50 && CurrentStatePercent<95 && ActorRef.HasSpell(System.Effect_Presswehen)==false
			FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Eroeffnungswehen)
			FWUtility.ActorAddSpell(ActorRef,System.Effect_Presswehen, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			System.Controller.GiveBirth(ActorRef)
			return
		elseif CurrentStatePercent>=95
			System.InstantBornChilds(ActorRef)
			changeState(8)
			return
		else;if CurrentStatePercent<50 && ActorRef.HasSpell(System.Effect_Eroeffnungswehen)==false
			if CurrentStatePercent<50 ;Tkc (Loverslab): optimization
				if ActorRef.HasSpell(System.Effect_Eroeffnungswehen)
				else;if ActorRef.HasSpell(System.Effect_Eroeffnungswehen)==false
					FWUtility.ActorAddSpell(ActorRef,System.Effect_Eroeffnungswehen, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
				endif
			endif
		endif
	endFunction
	
	function onExitState()
		FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Eroeffnungswehen)
		FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Presswehen)
		System.Manager.RemoveCME(ActorRef,8)
		;System.InstantBornChilds(ActorRef)
	endFunction
endState

;--------------------------------------------------------------------------------
; State - Replanish
;--------------------------------------------------------------------------------
state Replanish_State
	function onEnterState()
		System.Manager.RemoveCME(ActorRef) ; Remove all Effects
		System.Manager.CastCME(ActorRef,9,System.cfg.PMSEffects)
		SetBelly()
		
		equipChild()
		
		;if ActorRef.GetItemCount(System.ContraceptionLow)<=1 && IsPlayer==false
		if IsPlayer ;Tkc (Loverslab): optimization
		else;if IsPlayer==false
			if ActorRef.GetItemCount(System.ContraceptionLow)<=1
				ActorRef.AddItem(System.ContraceptionLow, 10, false)
			endif
		endif
		if CurrentStatePercent < 4
			FWUtility.ActorAddSpell(ActorRef,System.Effect_Nachwehen, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		endif
		if IsPlayer ;Tkc (Loverslab): show widged when state was changed
			System.StateWidget.showTimed(ActorRef)
		endif
	endFunction
	
	function onUpdateFunction()
		if CurrentStatePercent >=4
			FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Nachwehen)
		else
			FWUtility.ActorAddSpell(ActorRef,System.Effect_Nachwehen, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		endif
		if CurrentStatePercent >= 2 && ActorRef.HasSpell(System.FeverSpell)
			FWUtility.ActorRemoveSpell(ActorRef, System.FeverSpell)
		endif
		if CurrentStatePercent < 20 && Utility.RandomInt(0,10)>4
			; Breast milk
			int rnd= Utility.RandomInt(0,10)
			if rnd<6
				System.Message("Breast Milk1 ("+ActorRef.GetLeveledActorBase().GetName()+")",System.MSG_All)
				FWUtility.ActorAddSpell(ActorRef,System.Effect_BreastMilk1,false,true, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			elseif rnd<10
				System.Message("Breast Milk2 ("+ActorRef.GetLeveledActorBase().GetName()+")",System.MSG_All)
				FWUtility.ActorAddSpell(ActorRef,System.Effect_BreastMilk2,false,true, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			else
				System.Message("Breast Milk3 ("+ActorRef.GetLeveledActorBase().GetName()+")",System.MSG_All)
				FWUtility.ActorAddSpell(ActorRef,System.Effect_BreastMilk3,false,true, ShowMsg=System.cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			endif
		endIf
	endFunction
	
	function onExitState()
		; System.Manager.removeCME(ActorRef) ; CME Effects will always be removed when Follicel Phase beginns
		FWUtility.ActorRemoveSpell(ActorRef,System.Effect_Nachwehen)
		FWUtility.ActorRemoveSpell(ActorRef,System.FeverSpell)
		FWUtility.ActorRemoveSpell(ActorRef,System.InfectionSpell)
		ResetBelly()
		System.Controller.setAutoFlag(ActorRef)
	endFunction

endState

;--------------------------------------------------------------------------------
; State - Pregnant by unknown Mod
;--------------------------------------------------------------------------------
state PregnantUnknown_State
	function SetBelly(bool bForce=false)
	endFunction
endState

;--------------------------------------------------------------------------------
; State - Pregnant by Chaurus
;--------------------------------------------------------------------------------
state PregnantChaurus_State

	; THANK YOU CORUM FOR THE FIX!
	; A lot of respect to figure out how FWController and FWSystem works without having a guide!
	
	Event OnBeginState()
		if (currentState == 4)
			castAbortus(3,true)
		elseif (currentState == 5)
			castAbortus(4,true)
		elseif (currentState == 6 || currentState == 7)
			castAbortus(5,true)
		Else;if currentState != 2 && currentState != 8
			if currentState == 2 ;Tkc (Loverslab): optimization
			Else;if currentState != 2
				if currentState == 8
				Else;if currentState != 8
					changeState(2)
				EndIf
			EndIf
		EndIf
	EndEvent

	function OnUpdateFunction()
		;No action if still Pregnant by Chaurus, otherwise resume BFStates
		If System.IsActorPregnantByChaurus(ActorRef) ;Tkc (Loverslab): optimization
		else;If !System.IsActorPregnantByChaurus(ActorRef)
			ResetBelly()
			System.Controller.Pause(ActorRef,false)
			changeState(3)
			System.Controller.ChangeState(ActorRef,3) ;Ensure Controller and FWAbilityBeeingFemale are in a consistent state
		EndIf
	EndFunction

	; Bane --> On Update is now only needed by the player for triggering any Baby events via the parent.Onupdate() function
	event OnUpdate()
		if IsPlayer ;Tkc (Loverslab): added check because still was error here from female npc
			parent.OnUpdate()
			Self.RegisterForSingleUpdate(5)
		endif
	endEvent

endState


;OnMagicEffectApply Event moved to seperate script FWAbilityBFOnMagicEffectApply by Bane Master 03/07/2019

;bool ProcessingMagicEffect

; Event received when a magic affect is being applied to this object
;Event OnMagicEffectApply(ObjectReference akCaster, MagicEffect akEffect)
;	If ProcessingMagicEffect;spamguard ;Tkc (Loverslab): optimization
;	else;If !ProcessingMagicEffect
;		ProcessingMagicEffect = true
;		
;		System.Manager.OnMagicEffectApply(ActorRef,akCaster, akEffect)
;		
;		ProcessingMagicEffect = false
;	Endif
;endEvent

; 07 jule 2019 Tkc (Loverslab) optimizations:  Game.GetPlayer() replaced by PlayerRef. Other changes marked with "Tkc (Loverslab)" comment