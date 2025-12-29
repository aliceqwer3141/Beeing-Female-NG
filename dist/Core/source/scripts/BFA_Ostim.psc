Scriptname BFA_Ostim extends FWAddOn_Misc
import FWUtility

OSexIntegrationMain OStim
bool bOstim = false
FWSystem property System auto

int TryRegisterCount = 0

FWSystemConfig property cfg auto
Spell Property BeeingFemaleSpell Auto
FWController property Controller auto
FWAddOnManager property Manager auto
FWTextContents property Content auto
Actor Property PlayerRef Auto

function OnGameLoad()
	if !System
		System=GetSystem()
	endif
	bOstim = false
	UnregisterForAllModEvents()
	TryRegisterCount = 0
	RegisterForSingleUpdate(5)
endFunction

event OnUpdate()
	If Game.GetModByName("Ostim.esp")!= 255
		registerOstimEventHandlers()
		bOstim = true
	elseif (TryRegisterCount < 10)
		;UnregisterForUpdate()
		RegisterForSingleUpdate(5)
		TryRegisterCount+=1
	endif
endEvent

int function registerOstimEventHandlers()
    OStim = OUtils.GetOStim()
    if (OStim == none || OStim.GetAPIVersion() < 23)
        return 0
    endif

    if (OStim.GetAPIVersion() >= 29)
        RegisterForModEvent("ostim_actor_orgasm", "OStimOrgasmThread")
    else
        RegisterForModEvent("ostim_orgasm", "OStimOrgasm")
    endif
    return 2
endFunction

Event OStimOrgasmThread(String EventName, String Args, Float ThreadID, Form Sender)
    if sender as Actor
		HandleActorOrgasm(ThreadID as int, sender as Actor)
	endif
EndEvent

Event OStimOrgasm(String EventName, String Args, Float Nothing, Form Sender)
	OStim = OUtils.GetOStim()
	; If this is OStim NG, bail out (Since Below code is processed in OStimOrgasmThread)
	if (OStim.GetAPIVersion() >= 29)
		return
	endif

	if sender as Actor
		HandleActorOrgasm(0, sender as Actor)
		return
	else ;Backup check for most recent orgasmer
		actor orgasmer = OStim.GetMostRecentOrgasmedActor() ; Was never all that reliable but it is the only failsafe if Sender isnt sent
		if orgasmer
			HandleActorOrgasm(0, orgasmer)
		endif
	endif
EndEvent

Function HandleActorOrgasm(int threadId, Actor targetActor)
	OStim = OUtils.GetOStim()
	Actor partner = ostim.GetSexPartner(targetActor)

	if partner && !OStim.IsFemale(targetActor) && OStim.IsFemale(partner) && Ostim.IsVaginal()
		processPair(partner, targetActor)
	endIf
EndFunction

function Refresh(string strArg, FWAddOnManager sender)
	;parent.Refresh(strArg, sender)
	OnGameLoad()
endFunction

bool function IsSSLActive() ;Edit by BAne
	return bOstim
endFunction

bool function IsActive()
	return bOstim
endFunction


function Trace(string s)
	Debug.Trace(s)
endFunction

Function log(String msg, int lvl = 0)
		Debug.Trace("[Beeing Female NG]: " + msg)
EndFunction



Function processPair(Actor female, Actor Male)
	bool bCondom = System.CheckForCondome(Female, Male)
	float amount = 1.0
	;If Female && Male && bCondom==false
	If Female ;Tkc (Loverslab): optimization
	If Male
	If bCondom
	else;if bCondom==false
		;Trace("6. Male and Female are relevant for now")

		if Male.getLeveledActorBase().GetSex() == 0
			if System.IsValidateMaleActor(Male)<0
				;Trace("   Male is not a validate Male Actor: "+System.IsValidateMaleActor(Male))
				;Trace("[/SexLabOrgasmEvent]")
				return
			endif
		else
			if System.IsValidateFemaleActor(Male) < 0
				;Trace("   Male is not a validate Female Actor: "+System.IsValidateFemaleActor(Male))
				;Trace("[/SexLabOrgasmEvent]")
				return
			endif
		endif
		if Female.getLeveledActorBase().GetSex() == 0
			if System.IsValidateMaleActor(Female) < 0
				;Trace("   Female is not a validate Male Actor: "+System.IsValidateMaleActor(Female))
				;Trace("[/SexLabOrgasmEvent]")
				return
			endif
		else
			if System.IsValidateFemaleActor(Female) < 0
				;Trace("   Female is not a validate Female Actor: "+System.IsValidateFemaleActor(Female))
				;Trace("[/SexLabOrgasmEvent]")
				return
			endif
		endif

		;Trace("8. Add sperm")

		;Trace("   Raise AddOn Event 'OnCameInside'")
		;Manager.OnCameInside(Female,Male)

		;If Female.HasSpell(BeeingFemaleSpell)==false && System.IsValidateFemaleActor(Female)>0
		If Female.HasSpell(BeeingFemaleSpell) ;Tkc (Loverslab): optimization
		else;If Female.HasSpell(BeeingFemaleSpell)==false
		 if System.IsValidateFemaleActor(Female)>0
			;Trace("   Female doesn't had BF Spell - apply spell")
			System.ActorAddSpellOpt(Female,BeeingFemaleSpell)
		 endif
		endif

		float virility = Controller.GetVirility(Male)
		amount = Utility.RandomFloat(virility * 0.75, virility*1.1)
		if amount > 1.0
			amount = 1.0
		endif
		;If cfg.MaleVirilityRecovery > 0.0
		;	float virility = FWUtility.ClampFloat(Controller.GetDaysSinceLastSex(Male) / cfg.MaleVirilityRecovery, 0.02, 1.0)
		;	amount = Utility.RandomFloat(virility * 0.75, virility*1.1)
		;	if amount>1.0
		;		amount=1.0
		;	endif
		;	System.Trace("   Base Sperm-Amount is " + amount)
		;EndIf

		amount = Manager.getSpermAmount(Female,Male,amount)
		;Trace("   Calculated Sperm-Amount is " + amount)

		if Female.HasSpell(BeeingFemaleSpell) ;Tkc (Loverslab): optimization
		else;if Female.HasSpell(BeeingFemaleSpell)==false
			;Trace("   Female still don't got the BF Spell - ignore and continue")
			System.Message( FWUtility.StringReplace( Content.NoBeeingFemaleSpell , "{0}",Female.GetLeveledActorBase().GetName()), System.MSG_Immersive)
		endif
		actor p = PlayerRef
		If Male == p
			;self.Message("You came inside " + Female.GetLeveledActorBase().GetName() + ".", self.MSG_Immersive)
			System.Message( FWUtility.StringReplace( Content.YouCameInsideNPC , "{0}",Female.GetLeveledActorBase().GetName()), System.MSG_Immersive)
		ElseIf Female == p
			;self.Message(Male.GetLeveledActorBase().GetName() + " came inside you.", self.MSG_Immersive)
			System.Message( FWUtility.StringReplace( Content.NPCCameInsideYou , "{0}",Male.GetLeveledActorBase().GetName()), System.MSG_Immersive)
		Else
			;self.Message(Male.GetLeveledActorBase().GetName() + " came inside " + Female.GetLeveledActorBase().GetName() + ".", self.Msg_High)
			string[] astring = new string[2]
			astring[0] = Male.GetLeveledActorBase().GetName()
			astring[1] = Female.GetLeveledActorBase().GetName()
			System.Message( FWUtility.ArrayReplace(Content.NPCCameInsideNPC,astring), System.Msg_High)
		EndIf

		if amount>0.0
			;Trace("   Finaly add " + amount + " sperm from "+Male.GetLeveledActorBase().GetName() + " to " +Female.GetLeveledActorBase().GetName())
			Controller.AddSperm(Female, Male, amount)				
		endif
	EndIf
	EndIf
	EndIf
endfunction
; 02.06.2019 Tkc (Loverslab) optimizations: Changes marked with "Tkc (Loverslab)" comment. Added Sexlab pain sound when Sexlab is active(for example for giving birth)