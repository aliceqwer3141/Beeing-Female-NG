Scriptname FWAddOnManager extends Quest
import FWUtility

FWTextContents property Contents auto


FWAddOn_Race[] property Races Auto Hidden ; Overdue - But left for downgrade compatiblity
bool[] property bRaces Auto Hidden ; Overdue - But left for downgrade compatiblity
string[] property sRaces Auto Hidden ; Overdue - But left for downgrade compatiblity
int property iRaces=0 Auto Hidden ; Overdue - But left for downgrade compatiblity

FWAddOn_CycleMagicEffect[] property CME Auto Hidden ; Overdue - But left for downgrade compatiblity
bool[] property bCME Auto Hidden ; Overdue - But left for downgrade compatiblity
string[] property sCME Auto Hidden ; Overdue - But left for downgrade compatiblity
int property iCME=0 Auto Hidden ; Overdue - But left for downgrade compatiblity

FWAddOn_Misc[] property Misc Auto Hidden
bool[] property bMisc Auto Hidden ; Overdue - But left for downgrade compatiblity
string[] property sMisc Auto Hidden
int property iMisc=0 Auto Hidden

int _LoadingState
int property LoadingState hidden
	int function get()
		return _LoadingState
	endFunction
endProperty
int _LoadingStateRace
int property LoadingStateRace hidden
	int function get()
		return _LoadingStateRace
	endFunction
endProperty
int _LoadingStateCME
int property LoadingStateCME hidden
	int function get()
		return _LoadingStateCME
	endFunction
endProperty
int _LoadingStateMisc
int property LoadingStateMisc hidden
	int function get()
		return _LoadingStateMisc
	endFunction
endProperty
string _SLoadingRace
string property SLoadingRace hidden
	string function get()
		return _SLoadingRace
	endFunction
endProperty
string _SLoadingCME
string property SLoadingCME hidden
	string function get()
		return _SLoadingCME
	endFunction
endProperty
string _SLoadingMisc
string property SLoadingMisc hidden
	string function get()
		return _SLoadingMisc
	endFunction
endProperty


string AddOnFolderHash=""



int property ADDON_TYPE_ALL = 127 AutoReadOnly
int property ADDON_TYPE_MISC = 1 AutoReadOnly
int property ADDON_TYPE_RACE = 2 AutoReadOnly
int property ADDON_TYPE_CME = 4 AutoReadOnly


Actor Property PlayerRef Auto
FWSystem property System auto
FWSystemConfig property cfg auto
GlobalVariable Property myBFA_ProbChildRaceDeterminedByFather Auto
GlobalVariable Property myBFA_ProbChildSexDetermMale Auto
GlobalVariable Property BFOpt_MatureTimeInDays Auto
int DefaultMatureStep = 3
float DefaultInitialScale = 0.7		; // If it is less than this value, baby actor may not be visible!
float DefaultFinalScale = 1.0
float DefaultMatureScaleStep = 0.1	; // ((DefaultFinalScale - DefaultInitialScale) / DefaultMatureStep) = (0.3 / 3) = 0.1. At the final mature stage, baby actor will be automatically scaled to be "DefaultFinalScale" (if "finalScale" is not defined in the addon) or "finalScale" (if it is defined in the addon).

Faction Property BF_ForbiddenFaction Auto

function Upgrade(int oldVersion, int newVersion)
	if oldVersion<20900
		; Use the "Export"
		
	endif
endFunction

event onInit()
	Misc=new FWAddOn_Misc[128]
	sMisc=new string[128]
	OnGameLoad()
endEvent

function OnGameLoad()
	_LoadingState=1
	string H = FWUtility.GetDirectoryHash("AddOn")
	bool bAddOnMiscOK=true
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc ;Tkc (Loverslab): optimization
		else;if Misc[i] as FWAddOn_Misc==none
			bAddOnMiscOK=false
		endif
		i+=1
	endWhile
	if H==AddOnFolderHash && bAddOnMiscOK ;Tkc (Loverslab): optimization
	else;if H!=AddOnFolderHash||bAddOnMiscOK==false
		RefreshAddOnH()
	endif
	bAddOnMiscOK=true
	i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc ;Tkc (Loverslab): optimization
		else;if Misc[i] as FWAddOn_Misc==none
			bAddOnMiscOK=false
		endif
		i+=1
	endWhile
	
	; Raise 'OnGameLoad' on each Misc AddOn
	_LoadingState=0x80
	if bAddOnMiscOK
		i=0
		while i<iMisc
			_LoadingState=0x81
			Misc[i].OnGameLoad()
			_LoadingState=0x82
			i+=1
		endWhile
	endif
	
	; Recast CME Effects on player
	_LoadingState=0x90
	i = 0
	actor p = PlayerRef
	_LoadingState=0x91
	RecastSpell2(p, "FollicularPhase")
	_LoadingState=0x92
	RecastSpell2(p, "Ovulation")
	_LoadingState=0x93
	RecastSpell2(p, "LuthealPhase")
	_LoadingState=0x94
	RecastSpell2(p, "PMS")
	_LoadingState=0x95
	RecastSpell2(p, "Menstruation")
	_LoadingState=0x96
	RecastSpell2(p, "Trimester1")
	_LoadingState=0x97
	RecastSpell2(p, "Trimester2")
	_LoadingState=0x98
	RecastSpell2(p, "Trimester3")
	_LoadingState=0x99
	RecastSpell2(p, "Recovery")
	
	_LoadingState=0
endFunction


function RefreshAddOn(int type=127)
	RefreshAddOnH(type)
	_LoadingState=0
endFunction

function RefreshAddOnH(int type=127)
	_LoadingState=0x20
;	if Math.LogicalAnd(type,2)==2
;		ResetAllRaceAddOns()
;	endif
	Clear(type)
	
	ClearActorAddOns()
	
	ClearGlobalSettings()
	
	int c = FWUtility.GetFileCount("AddOn","ini")
	
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - Number of AddOn is " + c)
	
	_LoadingState=0x21
	AddOnFolderHash=FWUtility.GetDirectoryHash("AddOn")
	_LoadingState=0x22
	while c>0
		_LoadingState=0x30
		c-=1
		string n = FWUtility.GetFileName("AddOn","ini",c)
		
		if(n)
			Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn file name is " + n)
		
			if FWUtility.getIniCBool("AddOn",n,"AddOn","enabled") || FWUtility.getIniCBool("AddOn",n,"AddOn","locked")
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn is enabled or locked")
			
				_LoadingState=0x31
				string required = FWUtility.getIniCString("AddOn",n,"AddOn","required")
				bool bUse=true
				if required;/!=""/; ;Tkc (Loverslab): optimization
					Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn has requirements")

					string[] requiredA = StringUtil.Split(required,",")
					
					int NumOfRequired = requiredA.Length
					int myIndex = 0
					while(myIndex < NumOfRequired)
						Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : " + (myIndex + 1) + "th requirement is " + requiredA[myIndex])				
						myIndex += 1
					endWhile				
					
					if FWUtility.AreModsInstalled(requiredA) ;Tkc (Loverslab): optimization
						Debug.Trace("[Beeing Female NG] - FWAddOnManager - Requirements of " + c + "th AddOn are already installed!")
					else;if FWUtility.AreModsInstalled(requiredA)==false
						Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn is failed to work due to the lack of requirements...")
						bUse=false
					endif
				else
					Debug.Trace("[Beeing Female NG] - FWAddOnManager - Failed to load requirements of " + c + "th AddOn. Maybe it does not need requirements...")
				endif
				_LoadingState=0x32
				if bUse
					_LoadingState=0x33
					string t = FWUtility.toLower(FWUtility.getIniCString("AddOn",n,"AddOn","type"))					
					_LoadingState=0x34
					
					if(t)
						Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn type is " + t)

						if t=="misc" && Math.LogicalAnd(type,1)==1
							Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn type is misc")
							
							_LoadingState=0x40
							string modName=FWUtility.getIniCString("AddOn",n,"AddOn","modFile")							
							_LoadingState=0x41
							int formID=FWUtility.getIniCInt("AddOn",n,"AddOn","form")							
							_LoadingState=0x42
							;if modName!="" && FWUtility.IsModInstalled(modName) && formID>0
							if modName;/!=""/; ;Tkc (Loverslab): optimization
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn has modName")
							
								if FWUtility.IsModInstalled(modName)
									Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : modName = " + modName + " is installed")
									
									if formID>0
										_LoadingState=0x43
										FWAddOn_Misc tmp=Game.GetFormFromFile(formID,modName) as FWAddOn_Misc
										if tmp as FWAddOn_Misc;/!=none/;
											Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : tmp = " + tmp)
											
											sMisc[iMisc]=n
											Misc[iMisc]=tmp
											iMisc+=1
										else
											Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : Failed to load tmp with FormID = " + formID)
										endif
										_LoadingState=0x44
									else
										Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : FormID is not positive and hence it is invalid...")
									endif
								else
									Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : modName = " + modName + " is not installed...")
								endif
							else
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn does not have modName")
							endif
							_LoadingState=0x45
						elseif t=="race" && Math.LogicalAnd(type,2)==2
							Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn type is race")
							
							string sRaceCount=FWUtility.getIniString("AddOn",n,"races","")							
							int RaceCount=0
							if sRaceCount;/!=""/; ;Tkc (Loverslab): optimization
								RaceCount=sRaceCount as int
								
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : RaceCount = " + RaceCount)
							else
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : sRaceCount is zero")
							endif
							if RaceCount==0
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : RaceCount is zero. Running AddRaceAddOnCat...")
								
								AddRaceAddOnCat(n,"AddOn")
							else
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : RaceCount is not zero")
								
								while RaceCount>0
									Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : Running " + RaceCount + "th AddRaceAddOnCat...")
									
									AddRaceAddOnCat(n,"Race"+RaceCount)
									RaceCount-=1
								endwhile
							endif
							
						elseif t=="cme" && Math.LogicalAnd(type,4)==4
							Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn type is cme")
							
							_LoadingState=0x70
							AddCME(n,"Always_FollicularPhase")
							AddCME(n,"Always_LaborPains")
							AddCME(n,"Always_LutealPhase")
							AddCME(n,"Always_Menstruation")
							_LoadingState=0x71
							AddCME(n,"Always_Ovulation")
							AddCME(n,"Always_PMS")
							AddCME(n,"Always_Recovery")
							_LoadingState=0x72
							AddCME(n,"Always_Trimester1")
							AddCME(n,"Always_Trimester2")
							AddCME(n,"Always_Trimester3")
							_LoadingState=0x73
							AddCME(n,"Sometimes_FollicularPhase")
							AddCME(n,"Sometimes_LaborPains")
							AddCME(n,"Sometimes_LutealPhase")
							_LoadingState=0x74
							AddCME(n,"Sometimes_Menstruation")
							AddCME(n,"Sometimes_Ovulation")
							AddCME(n,"Sometimes_PMS")
							_LoadingState=0x75
							AddCME(n,"Sometimes_Recovery")
							AddCME(n,"Sometimes_Trimester1")
							AddCME(n,"Sometimes_Trimester2")
							_LoadingState=0x76
							AddCME(n,"Sometimes_Trimester3")
						elseif(t == "global")
							Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn type is global")
							
							if(FWUtility.getIniCBool("AddOn", n, "AddOn", "Global_RemoveSPIDitems", false))
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - Global_RemoveSPIDitems is true")
								StorageUtil.SetIntValue(none, "FW.AddOn.Global_RemoveSPIDitems", 1)
							endIf
							LoadGlobalAddOnValue(n, "Global_WidgetFadeOutTime")
							LoadGlobalAddOnValue(n, "Global_WidgetFlashShowTime")
							LoadGlobalAddOnValue(n, "Global_WidgetNoFlashShowTime")

							if(FWUtility.getIniCBool("AddOn", n, "AddOn", "Global_DisablePregnancy", false))
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - Activating Global_DisablePregnancy")	
								StorageUtil.SetIntValue(none, "FW.AddOn.Global_DisablePregnancy", 1)
							endIf
							
							LoadGlobalAddOnValue(n, "Global_ChanceToBecomePregnantScale")
							LoadGlobalAddOnValue(n, "Global_ContraceptionDuration")
							LoadGlobalAddOnValue(n, "Global_Duration_01_Follicular")
							LoadGlobalAddOnValue(n, "Global_Duration_02_Ovulation")
							LoadGlobalAddOnValue(n, "Global_Duration_03_Luteal")
							LoadGlobalAddOnValue(n, "Global_Duration_04_Menstruation")
							LoadGlobalAddOnValue(n, "Global_Duration_05_Trimester1")
							LoadGlobalAddOnValue(n, "Global_Duration_06_Trimester2")
							LoadGlobalAddOnValue(n, "Global_Duration_07_Trimester3")
							LoadGlobalAddOnValue(n, "Global_Duration_08_Recovery")
							LoadGlobalAddOnValue(n, "Global_Duration_09_LaborPains")
							LoadGlobalAddOnValue(n, "Global_Duration_10_SecondsBetweenLaborPains")
							LoadGlobalAddOnValue(n, "Global_Duration_11_SecondsBetweenBabySpawn")
							LoadGlobalAddOnValue(n, "Global_Irregulation_Chance_Scale")
							LoadGlobalAddOnValue(n, "Global_Irregulation_Value_Scale")
							LoadGlobalAddOnValue(n, "Global_Multiple_Threshold_Chance")
							LoadGlobalAddOnValue(n, "Global_Multiple_Threshold_Max_Babys")
							LoadGlobalAddOnValue(n, "Global_Pain_Abortus")
							LoadGlobalAddOnValue(n, "Global_Pain_GivingBirth")
							LoadGlobalAddOnValue(n, "Global_Pain_LaborPains")
							LoadGlobalAddOnValue(n, "Global_Pain_Mittelschmerz")
							LoadGlobalAddOnValue(n, "Global_Pain_Phase_CyclePains")
							LoadGlobalAddOnValue(n, "Global_Pain_Phase_PregnantPains")
							LoadGlobalAddOnValue(n, "Global_Pain_PMS")
							LoadGlobalAddOnValue(n, "Global_PMS_ChanceScale")
							LoadGlobalAddOnValue(n, "Global_Sizes_Belly_Max")
							LoadGlobalAddOnValue(n, "Global_Sizes_Belly_Max_Multiple")
							LoadGlobalAddOnValue(n, "Global_Sizes_Breasts_Max")
							LoadGlobalAddOnValue(n, "Global_Sizes_Breasts_Max_Multiple")
							LoadGlobalAddOnValue(n, "Global_Preg1stBellyScale")
							LoadGlobalAddOnValue(n, "Global_Preg2ndBellyScale")
							LoadGlobalAddOnValue(n, "Global_Preg3rdBellyScale")
							LoadGlobalAddOnValue(n, "Global_Preg1stBreastsScale")
							LoadGlobalAddOnValue(n, "Global_Preg2ndBreastsScale")
							LoadGlobalAddOnValue(n, "Global_Preg3rdBreastsScale")
							LoadGlobalAddOnValue(n, "Global_MultipleBabySperm")
							LoadGlobalAddOnValue(n, "Global_MultipleBabyChancePerSperm")
							LoadGlobalAddOnValue(n, "Global_Baby_Healing_Scale")
							LoadGlobalAddOnValue(n, "Global_Baby_Damage_Scale")


							LoadGlobalAddOnValue(n, "Global_Duration_MaleSperm")
							LoadGlobalAddOnValue(n, "Global_Sperm_Amount_Scale")
							LoadGlobalAddOnValue(n, "Global_Male_Recovery_Scale")
							LoadGlobalAddOnValue(n, "Global_Ignore_Contraception_Prob")
							if FWUtility.getIniCBool("AddOn", n, "AddOn", "Global_Allow_Impregnation_For_Any_Period", false)
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - RefreshAddOnH : AddOn file name = " + n + ", loading data. Activating FW.AddOn.Global_Allow_Impregnation_For_Any_Period")
								
								LoadGlobalAddOnValue(n, "Global_Sperm_Impregnation_Prob_For_Any_Period")
								if(StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Sperm_Impregnation_Prob_For_Any_Period", 0) > 0)
									StorageUtil.SetIntValue(none, "FW.AddOn.Global_Allow_Impregnation_For_Any_Period", 1)
								else
									StorageUtil.SetIntValue(none, "FW.AddOn.Global_Allow_Impregnation_For_Any_Period", 0)
								endif
							endif
							LoadGlobalAddOnValueAnything(n, "Global_Sperm_Impregnation_Boost")
							LoadGlobalAddOnValueAnything(n, "Global_Modify_Baby_Healing_Scale_by_FatherRace")
							LoadGlobalAddOnValueAnything(n, "Global_Modify_Baby_Damage_Scale_by_FatherRace")


							if FWUtility.getIniCBool("AddOn", n, "AddOn", "Global_Female_Force_This_Baby", false)
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - RefreshAddOnH : AddOn file name = " + n + ", loading data. Activating FW.AddOn.Global_Female_Force_This_Baby")
								
								StorageUtil.SetIntValue(none, "FW.AddOn.Global_Female_Force_This_Baby", 1)
							endif
							AddGlobalAddOnArrayToList(n, "Global_BabyActor_Female")
							AddGlobalAddOnArrayToList(n, "Global_BabyActor_FemalePlayer")
							AddGlobalAddOnArrayToList(n, "Global_BabyActor_Male")
							AddGlobalAddOnArrayToList(n, "Global_BabyActor_MalePlayer")
							if(FWUtility.getIniCBool("AddOn", n, "AddOn", "Global_MixWithCopyActorBase", false))
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - RefreshAddOnH : AddOn file name = " + n + ", loading data. Activating FW.AddOn.Global_MixWithCopyActorBase and reading Global_ProbChildActorBorn...")
								
								StorageUtil.SetIntValue(none, "FW.AddOn.Global_MixWithCopyActorBase", 1)
								LoadGlobalAddOnValueInt(n, "Global_ProbChildActorBorn")
							endif
							if FWUtility.getIniCBool("AddOn", n, "AddOn", "Global_AllowPCDialogue", false)
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - Global_AllowPCDialogue is true")
								StorageUtil.SetIntValue(none, "FW.AddOn.Global_AllowPCDialogue", 1)
							endif
							LoadGlobalAddOnValue(n, "Global_initialScale")
							LoadGlobalAddOnValue(n, "Global_finalScale")
							if FWUtility.getIniCBool("AddOn", n, "AddOn", "Global_DisableMatureTime", false)
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - Global_DisableMatureTime is true")
								StorageUtil.SetIntValue(none, "FW.AddOn.Global_DisableMatureTime", 1)
							else
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - Global_DisableMatureTime is false. Reading Global_MatureTimeScale...")
								LoadGlobalAddOnValue(n, "Global_MatureTimeScale")	
							endif
							LoadGlobalAddOnValueInt(n, "Global_MatureStep")
							if FWUtility.getIniCBool("AddOn", n, "AddOn", "Global_AllowUnrestrictedS", false)
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - Global_AllowUnrestrictedS is true")
								StorageUtil.SetIntValue(none, "FW.AddOn.Global_AllowUnrestrictedS", 1)
							endif
							if FWUtility.getIniCBool("AddOn", n, "AddOn", "Global_ProtectedChildActor", false)
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - Global_ProtectedChildActor is true")
								StorageUtil.SetIntValue(none, "FW.AddOn.Global_ProtectedChildActor", 1)
							endif
						elseif(t == "actor")
							Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn type is actor")
							
							string sActorCount = FWUtility.getIniString("AddOn", n, "actors", "")							
							int ActorCount = 0
							if sActorCount;/!=""/; ;Tkc (Loverslab): optimization
								ActorCount = sActorCount as int
								
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : ActorCount = " + ActorCount)
							else
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : sActorCount is zero")
							endif
							if(ActorCount == 0)
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : ActorCount is zero. Running AddActorAddOnCat...")
								
								AddActorAddOnCat(n, "AddOn")
							else
								Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : ActorCount is not zero")
								
								while(ActorCount > 0)
									Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn : Running " + ActorCount + "th AddActorAddOnCat...")
									
									AddActorAddOnCat(n, "Actor" + ActorCount)
									ActorCount -= 1
								endwhile
							endif
						else
							Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn type cannot be recognized in BeeingFemale...")
						endif
					else
						Debug.Trace("[Beeing Female NG] - FWAddOnManager - Failed to load " + c + "th AddOn type...")
					endIf
				else
					Debug.Trace("[Beeing Female NG] - FWAddOnManager - " + c + "th AddOn will not be used...")
				endif
			endif
		else
			Debug.Trace("[Beeing Female NG] - FWAddOnManager - Failed to load " + c + "th AddOn file name...")
		endIf
	endWhile
endFunction


bool function Export(FWAddOnBase q, string Prefix="", int type=127) global
	bool bRes=false
	; Check for each type - there could be 
	if q as FWAddOn_Misc;/!=none/; && Math.LogicalAnd(type,1)==1
		if Export_Misc(q as FWAddOn_Misc,Prefix)
			bRes=true
		endif
	endif
	if q as FWAddOn_Race;/!=none/; && Math.LogicalAnd(type,2)==2
		if Export_Race(q as FWAddOn_Race,Prefix)
			bRes=true
		endif
	endif
	if q as FWAddOn_CycleMagicEffect;/!=none/; && Math.LogicalAnd(type,4)==4
		if Export_CME(q as FWAddOn_CycleMagicEffect,Prefix)
			bRes=true
		endif
	endif
	return bRes
endFunction

bool function Export_Misc(FWAddOn_Misc q, string Prefix="") global
	; Basic Ini Variables
	if q as FWAddOn_Misc ;Tkc (Loverslab): optimization
	else;if q as FWAddOn_Misc == none
		return false
	endif
	string fName=Prefix+q.GetName()+".ini"
	FWUtility.setIniString("AddOn",fName,"name",q.GetName())
	FWUtility.setIniString("AddOn",fName,"description",q.AddOnDescription)
	FWUtility.setIniString("AddOn",fName,"author",q.AddOnAuthor)
	FWUtility.setIniString("AddOn",fName,"type","misc")
	FWUtility.setIniString("AddOn",fName,"required",FWUtility.GetModFromForm(q,true))
	
	FWUtility.setIniBool("AddOn",fName,"enabled",true)
	FWUtility.setIniBool("AddOn",fName,"locked",q.AddOnLocked)
	FWUtility.setIniBool("AddOn",fName,"hidden",!q.AddOnVisible)
	
	FWUtility.setIniString("AddOn",fName,"modFile",FWUtility.GetModFromForm(q,true))
	FWUtility.setIniString("AddOn",fName,"form","0x" + FWUtility.Hex(q.GetFormID() % 0x1000000,6))
	return true
endFunction

bool function Export_Race(FWAddOn_Race q, string Prefix="") global
	; Basic Ini Variables
	if q as FWAddOn_Race ;Tkc (Loverslab): optimization
	else;if q as FWAddOn_Race == none
		return false
	endif
	string fName=Prefix+FWUtility.GetModFromForm(q,false)+".ini"
	FWUtility.setIniString("AddOn",fName,"name",FWUtility.GetModFromForm(q,false))
	FWUtility.setIniString("AddOn",fName,"description",q.AddOnDescription)
	FWUtility.setIniString("AddOn",fName,"author",q.AddOnAuthor)
	FWUtility.setIniString("AddOn",fName,"type","race")
	FWUtility.setIniString("AddOn",fName,"required",FWUtility.GetModFromForm(q,true))
	
	FWUtility.setIniBool("AddOn",fName,"enabled",true)
	FWUtility.setIniBool("AddOn",fName,"locked",q.AddOnLocked)
	FWUtility.setIniBool("AddOn",fName,"hidden",!q.AddOnVisible)
	
	int xRaces=FWUtility.getIniInt("AddOn",fName,"races",0)
	xRaces+=1
	FWUtility.setIniString("AddOn",fName,"races",xRaces)
	_Export_RaceHandler(q,fName,"Race"+xRaces)
	Utility.WaitMenuMode(0.1) ; Wait a short time
	return true
endFunction

function _Export_RaceHandler(FWAddOn_Race q, string fName, string cat) global
	
	FWUtility.setIniCString("AddOn",fName,cat,"id", FWUtility.GetStringFromRaces(q.RaceID))
	
	; Export Baby ActorSizeScaler/Items/Armors
	if q.BabyMesh_Female;/!=none/;
		FWUtility.setIniCString("AddOn",fName,cat,"BabyMesh_Female", FWUtility.GetStringFromForm(q.BabyMesh_Female))
	endif
	if q.BabyArmor_Female;/!=none/;
		FWUtility.setIniCString("AddOn",fName,cat,"BabyArmor_Female", FWUtility.GetStringFromForm(q.BabyArmor_Female))
	endif
	if q.BabyActor_Female;/!=none/;
		FWUtility.setIniCString("AddOn",fName,cat,"BabyActor_Female", FWUtility.GetStringFromForm(q.BabyActor_Female))
	endif
	if q.BabyActor_FemalePlayer;/!=none/;
		FWUtility.setIniCString("AddOn",fName,cat,"BabyActor_FemalePlayer", FWUtility.GetStringFromForm(q.BabyActor_FemalePlayer))
	endif
	if q.BabyMesh_Male;/!=none/;
		FWUtility.setIniCString("AddOn",fName,cat,"BabyMesh_Male", FWUtility.GetStringFromForm(q.BabyMesh_Male))
	endif
	if q.BabyArmor_Male;/!=none/;
		FWUtility.setIniCString("AddOn",fName,cat,"BabyArmor_Male", FWUtility.GetStringFromForm(q.BabyArmor_Male))
	endif
	if q.BabyActor_Male;/!=none/;
		FWUtility.setIniCString("AddOn",fName,cat,"BabyActor_Male", FWUtility.GetStringFromForm(q.BabyActor_Male))
	endif
	if q.BabyActor_MalePlayer;/!=none/;
		FWUtility.setIniCString("AddOn",fName,cat,"BabyActor_MalePlayer", FWUtility.GetStringFromForm(q.BabyActor_MalePlayer))
	endif
	
	; Export boolen variables
	if q.Female_Force_This_Baby
		FWUtility.setIniCBool("AddOn",fName,cat,"Female_Force_This_Baby", q.Female_Force_This_Baby)
	endif
	if q.DisablePregnancy
		FWUtility.setIniCBool("AddOn",fName,cat,"DisablePregnancy", q.DisablePregnancy)
	endif
	
	;if q.Duration_01_Follicular>0.0 && q.Duration_01_Follicular!=1.0
	if q.Duration_01_Follicular>0.0 ;Tkc (Loverslab): optimization
		if q.Duration_01_Follicular==1.0
		else;if q.Duration_01_Follicular!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_01_Follicular", q.Duration_01_Follicular)
		endif
	endif
	;if q.Duration_02_Ovulation>0.0 && q.Duration_02_Ovulation!=1.0
	if q.Duration_02_Ovulation>0.0
		if q.Duration_02_Ovulation==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_02_Ovulation!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_02_Ovulation", q.Duration_02_Ovulation)
		endif
	endif
	;if q.Duration_03_Luteal>0.0 && q.Duration_03_Luteal!=1.0
	if q.Duration_03_Luteal>0.0
		if q.Duration_03_Luteal==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_03_Luteal!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_03_Luteal", q.Duration_03_Luteal)
		endif
	endif
	;if q.Duration_04_Menstruation>0.0 && q.Duration_04_Menstruation!=1.0
	if q.Duration_04_Menstruation>0.0
		if q.Duration_04_Menstruation==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_04_Menstruation!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_04_Menstruation", q.Duration_04_Menstruation)
		endif
	endif
	;if q.Duration_05_Trimester1>0.0 && q.Duration_05_Trimester1!=1.0
	if q.Duration_05_Trimester1>0.0
		if q.Duration_05_Trimester1==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_05_Trimester1!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_05_Trimester1", q.Duration_05_Trimester1)
		endif
	endif
	;if q.Duration_06_Trimester2>0.0 && q.Duration_06_Trimester2!=1.0
	if q.Duration_06_Trimester2>0.0
		if q.Duration_06_Trimester2==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_06_Trimester2!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_06_Trimester2", q.Duration_06_Trimester2)
		endif
	endif
	;if q.Duration_07_Trimester3>0.0 && q.Duration_07_Trimester3!=1.0
	if q.Duration_07_Trimester3>0.0
		if q.Duration_07_Trimester3==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_07_Trimester3!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_07_Trimester3", q.Duration_07_Trimester3)
		endif
	endif
	;if q.Duration_08_Recovery>0.0 && q.Duration_08_Recovery!=1.0
	if q.Duration_08_Recovery>0.0
		if q.Duration_08_Recovery==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_08_Recovery!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_08_Recovery", q.Duration_08_Recovery)
		endif
	endif
	;if q.Duration_09_LaborPains>0.0 && q.Duration_09_LaborPains!=1.0
	if q.Duration_09_LaborPains>0.0
		if q.Duration_09_LaborPains==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_09_LaborPains!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_09_LaborPains", q.Duration_09_LaborPains)
		endif
	endif
	;if q.Duration_10_SecondsBetweenLaborPains>0.0 && q.Duration_10_SecondsBetweenLaborPains!=1.0
	if q.Duration_10_SecondsBetweenLaborPains>0.0
		if q.Duration_10_SecondsBetweenLaborPains==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_10_SecondsBetweenLaborPains!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_10_SecondsBetweenLaborPains", q.Duration_10_SecondsBetweenLaborPains)
		endif
	endif
	;if q.Duration_11_SecondsBetweenBabySpawn>0.0 && q.Duration_11_SecondsBetweenBabySpawn!=1.0
	if q.Duration_11_SecondsBetweenBabySpawn>0.0
		if q.Duration_11_SecondsBetweenBabySpawn==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_11_SecondsBetweenBabySpawn!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_11_SecondsBetweenBabySpawn", q.Duration_11_SecondsBetweenBabySpawn)
		endif
	endif
	;if q.Duration_MaleSperm>0.0 && q.Duration_MaleSperm!=1.0
	if q.Duration_MaleSperm>0.0
		if q.Duration_MaleSperm==1.0 ;Tkc (Loverslab): optimization
		else;if q.Duration_MaleSperm!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Duration_MaleSperm", q.Duration_MaleSperm)
		endif
	endif
	
	;if q.Pain_Mittelschmerz>0.0 && q.Pain_Mittelschmerz!=1.0
	if q.Pain_Mittelschmerz>0.0
		if q.Pain_Mittelschmerz==1.0 ;Tkc (Loverslab): optimization
		else;if q.Pain_Mittelschmerz!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Pain_Mittelschmerz", q.Pain_Mittelschmerz)
		endif
	endif
	;if q.Pain_Menstruation>0.0 && q.Pain_Menstruation!=1.0
	if q.Pain_Menstruation>0.0
		if q.Pain_Menstruation==1.0 ;Tkc (Loverslab): optimization
		else;if q.Pain_Menstruation!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Pain_Menstruation", q.Pain_Menstruation)
		endif
	endif
	;if q.Pain_PMS>0.0 && q.Pain_PMS!=1.0
	if q.Pain_PMS>0.0
		if q.Pain_PMS==1.0 ;Tkc (Loverslab): optimization
		else;if q.Pain_PMS!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Pain_PMS", q.Pain_PMS)
		endif
	endif
	;if q.Pain_LaborPains>0.0 && q.Pain_LaborPains!=1.0
	if q.Pain_LaborPains>0.0
		if q.Pain_LaborPains==1.0 ;Tkc (Loverslab): optimization
		else;if q.Pain_LaborPains!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Pain_LaborPains", q.Pain_LaborPains)
		endif
	endif
	;if q.Pain_GivingBirth>0.0 && q.Pain_GivingBirth!=1.0
	if q.Pain_GivingBirth>0.0
		if q.Pain_GivingBirth==1.0 ;Tkc (Loverslab): optimization
		else;if q.Pain_GivingBirth!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Pain_GivingBirth", q.Pain_GivingBirth)
		endif
	endif
	;if q.Pain_Abortus>0.0 && q.Pain_Abortus!=1.0
	if q.Pain_Abortus>0.0
		if q.Pain_Abortus==1.0 ;Tkc (Loverslab): optimization
		else;if q.Pain_Abortus!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Pain_Abortus", q.Pain_Abortus)
		endif
	endif
	;if q.Pain_Phase_CyclePains>0.0 && q.Pain_Phase_CyclePains!=1.0
	if q.Pain_Phase_CyclePains>0.0
		if q.Pain_Phase_CyclePains==1.0 ;Tkc (Loverslab): optimization
		else;if q.Pain_Phase_CyclePains!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Pain_Phase_CyclePains", q.Pain_Phase_CyclePains)
		endif
	endif
	;if q.Pain_Phase_PregnantPains>0.0 && q.Pain_Phase_PregnantPains!=1.0
	if q.Pain_Phase_PregnantPains>0.0
		if q.Pain_Phase_PregnantPains==1.0 ;Tkc (Loverslab): optimization
		else;if q.Pain_Phase_PregnantPains!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Pain_Phase_PregnantPains", q.Pain_Phase_PregnantPains)
		endif
	endif
	
	;if q.Max_CME_EffectsScale>0.0 && q.Max_CME_EffectsScale!=1.0
	if q.Max_CME_EffectsScale>0.0
		if q.Max_CME_EffectsScale==1.0 ;Tkc (Loverslab): optimization
		else;if q.Max_CME_EffectsScale!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Max_CME_EffectsScale", q.Max_CME_EffectsScale)
		endif
	endif
	;if q.ChanceToBecomePregnantScale>0.0 && q.ChanceToBecomePregnantScale!=1.0
	if q.ChanceToBecomePregnantScale>0.0
		if q.ChanceToBecomePregnantScale==1.0 ;Tkc (Loverslab): optimization
		else;if q.ChanceToBecomePregnantScale!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"ChanceToBecomePregnantScale", q.ChanceToBecomePregnantScale)
		endif
	endif
	;if q.Sizes_Belly_Max>0.0 && q.Sizes_Belly_Max!=1.0
	if q.Sizes_Belly_Max>0.0
		if q.Sizes_Belly_Max==1.0 ;Tkc (Loverslab): optimization
		else;if q.Sizes_Belly_Max!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Sizes_Belly_Max", q.Sizes_Belly_Max)
		endif
	endif
	;if q.Sizes_Breasts_Max>0.0 && q.Sizes_Breasts_Max!=1.0
	if q.Sizes_Breasts_Max>0.0
		if q.Sizes_Breasts_Max==1.0 ;Tkc (Loverslab): optimization
		else;if q.Sizes_Breasts_Max!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Sizes_Breasts_Max", q.Sizes_Breasts_Max)
		endif
	endif
	;if q.Sizes_Belly_Max_Multiple>0.0 && q.Sizes_Belly_Max_Multiple!=1.0
	if q.Sizes_Belly_Max_Multiple>0.0
		if q.Sizes_Belly_Max_Multiple==1.0 ;Tkc (Loverslab): optimization
		else;if q.Sizes_Belly_Max_Multiple!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Sizes_Belly_Max_Multiple", q.Sizes_Belly_Max_Multiple)
		endif
	endif
	;if q.Sizes_Breasts_Max_Multiple>0.0 && q.Sizes_Breasts_Max_Multiple!=1.0
	if q.Sizes_Breasts_Max_Multiple>0.0
		if q.Sizes_Breasts_Max_Multiple==1.0 ;Tkc (Loverslab): optimization
		else;if q.Sizes_Breasts_Max_Multiple!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Sizes_Breasts_Max_Multiple", q.Sizes_Breasts_Max_Multiple)
		endif
	endif
	;if q.Multiple_Threshold_Chance>0.0 && q.Multiple_Threshold_Chance!=1.0
	if q.Multiple_Threshold_Chance>0.0
		if q.Multiple_Threshold_Chance==1.0 ;Tkc (Loverslab): optimization
		else;if q.Multiple_Threshold_Chance!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Multiple_Threshold_Chance", q.Multiple_Threshold_Chance)
		endif
	endif
	;if q.Multiple_Threshold_Max_Babys>0.0 && q.Multiple_Threshold_Max_Babys!=1.0
	if q.Multiple_Threshold_Max_Babys>0.0
		if q.Multiple_Threshold_Max_Babys==1.0 ;Tkc (Loverslab): optimization
		else;if q.Multiple_Threshold_Max_Babys!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Multiple_Threshold_Max_Babys", q.Multiple_Threshold_Max_Babys)
		endif
	endif
	;if q.Irregulation_Chance_Scale>0.0 && q.Irregulation_Chance_Scale!=1.0
	if q.Irregulation_Chance_Scale>0.0
		if q.Irregulation_Chance_Scale==1.0 ;Tkc (Loverslab): optimization
		else;if q.Irregulation_Chance_Scale!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Irregulation_Chance_Scale", q.Irregulation_Chance_Scale)
		endif
	endif
	;if q.Irregulation_Value_Scale>0.0 && q.Irregulation_Value_Scale!=1.0
	if q.Irregulation_Value_Scale>0.0
		if q.Irregulation_Value_Scale==1.0 ;Tkc (Loverslab): optimization
		else;if q.Irregulation_Value_Scale!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"Irregulation_Value_Scale", q.Irregulation_Value_Scale)
		endif
	endif
	;if q.ContraceptionDuration>0.0 && q.ContraceptionDuration!=1.0
	if q.ContraceptionDuration>0.0
		if q.ContraceptionDuration==1.0 ;Tkc (Loverslab): optimization
		else;if q.ContraceptionDuration!=1.0
			FWUtility.setIniCFloat("AddOn",fName,cat,"ContraceptionDuration", q.ContraceptionDuration)
		endif
	endif
endFunction

bool function Export_CME(FWAddOn_CycleMagicEffect q, string Prefix="") global
	; Basic Ini Variables
	if q as FWAddOn_CycleMagicEffect ;Tkc (Loverslab): optimization
	else;if q as FWAddOn_CycleMagicEffect == none
		return false
	endif
	string fName=Prefix+q.GetName()+".ini"
	FWUtility.setIniString("AddOn",fName,"name",q.GetName())
	FWUtility.setIniString("AddOn",fName,"description",q.AddOnDescription)
	FWUtility.setIniString("AddOn",fName,"author",q.AddOnAuthor)
	FWUtility.setIniString("AddOn",fName,"type","cme")
	FWUtility.setIniString("AddOn",fName,"required",FWUtility.GetModFromForm(q,true))
	
	FWUtility.setIniBool("AddOn",fName,"enabled",true)
	FWUtility.setIniBool("AddOn",fName,"locked",q.AddOnLocked)
	FWUtility.setIniBool("AddOn",fName,"hidden",!q.AddOnVisible)
	
	if q.Always_FollicularPhase.length>0
		FWUtility.setIniString("AddOn",fName,"Always_FollicularPhase",FWUtility.GetStringFromSpells(q.Always_FollicularPhase))
	endif
	if q.Always_Ovulation.length>0
		FWUtility.setIniString("AddOn",fName,"Always_Ovulation",FWUtility.GetStringFromSpells(q.Always_Ovulation))
	endif
	if q.Always_LuthealPhase.length>0
		FWUtility.setIniString("AddOn",fName,"Always_LuthealPhase",FWUtility.GetStringFromSpells(q.Always_LuthealPhase))
	endif
	if q.Always_PMS.length>0
		FWUtility.setIniString("AddOn",fName,"Always_PMS",FWUtility.GetStringFromSpells(q.Always_PMS))
	endif
	if q.Always_Menstruation.length>0
		FWUtility.setIniString("AddOn",fName,"Always_Menstruation",FWUtility.GetStringFromSpells(q.Always_Menstruation))
	endif
	if q.Always_Trimester1.length>0
		FWUtility.setIniString("AddOn",fName,"Always_Trimester1",FWUtility.GetStringFromSpells(q.Always_Trimester1))
	endif
	if q.Always_Trimester2.length>0
		FWUtility.setIniString("AddOn",fName,"Always_Trimester2",FWUtility.GetStringFromSpells(q.Always_Trimester2))
	endif
	if q.Always_Trimester3.length>0
		FWUtility.setIniString("AddOn",fName,"Always_Trimester3",FWUtility.GetStringFromSpells(q.Always_Trimester3))
	endif
	if q.Always_LaborPains.length>0
		FWUtility.setIniString("AddOn",fName,"Always_LaborPains",FWUtility.GetStringFromSpells(q.Always_LaborPains))
	endif
	if q.Always_Recovery.length>0
		FWUtility.setIniString("AddOn",fName,"Always_Recovery",FWUtility.GetStringFromSpells(q.Always_Recovery))
	endif
	
	if q.Sometimes_FollicularPhase.length>0
		FWUtility.setIniString("AddOn",fName,"Sometimes_FollicularPhase",FWUtility.GetStringFromSpells(q.Sometimes_FollicularPhase))
	endif
	if q.Sometimes_Ovulation.length>0
		FWUtility.setIniString("AddOn",fName,"Sometimes_Ovulation",FWUtility.GetStringFromSpells(q.Sometimes_Ovulation))
	endif
	if q.Sometimes_LuthealPhase.length>0
		FWUtility.setIniString("AddOn",fName,"Sometimes_LuthealPhase",FWUtility.GetStringFromSpells(q.Sometimes_LuthealPhase))
	endif
	if q.Sometimes_PMS.length>0
		FWUtility.setIniString("AddOn",fName,"Sometimes_PMS",FWUtility.GetStringFromSpells(q.Sometimes_PMS))
	endif
	if q.Sometimes_Menstruation.length>0
		FWUtility.setIniString("AddOn",fName,"Sometimes_Menstruation",FWUtility.GetStringFromSpells(q.Sometimes_Menstruation))
	endif
	if q.Sometimes_Trimester1.length>0
		FWUtility.setIniString("AddOn",fName,"Sometimes_Trimester1",FWUtility.GetStringFromSpells(q.Sometimes_Trimester1))
	endif
	if q.Sometimes_Trimester2.length>0
		FWUtility.setIniString("AddOn",fName,"Sometimes_Trimester2",FWUtility.GetStringFromSpells(q.Sometimes_Trimester2))
	endif
	if q.Sometimes_Trimester3.length>0
		FWUtility.setIniString("AddOn",fName,"Sometimes_Trimester3",FWUtility.GetStringFromSpells(q.Sometimes_Trimester3))
	endif
	if q.Sometimes_LaborPains.length>0
		FWUtility.setIniString("AddOn",fName,"Sometimes_LaborPains",FWUtility.GetStringFromSpells(q.Sometimes_LaborPains))
	endif
	if q.Sometimes_Recovery.length>0
		FWUtility.setIniString("AddOn",fName,"Sometimes_Recovery",FWUtility.GetStringFromSpells(q.Sometimes_Recovery))
	endif
	return true
endFunction


function AddCME(string n, string valueName)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddCME : AddOn file name = " + n + ", with valueName = " + valueName)

	string s=FWUtility.getIniCString("AddOn",n,"AddOn",valueName)
	
	if s;/!=""/; ;Tkc (Loverslab): optimization
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddCME : " + n + " - Loaded valueName = " + s)
		
		string[] ss = StringUtil.Split(s,",")
		int c=ss.Length
		
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddCME : Number of valueName in " + n + " is " + c)
		while c>0
			c-=1
;			spell itm = FWUtility.GetFormFromString(ss[c]) as spell		// GetFormFromString is DEPRECATED in SE! Use FWUtility.GetFormFromStringSE() instead!
			spell itm = FWUtility.GetFormFromStringSE(ss[c]) as spell
							
			if itm;/!=none/;
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddCME : " + (c + 1) + "th spell in " + n + " is " + itm + ". It will be added to FW.AddOn." + valueName)
					
				StorageUtil.FormListAdd(none,"FW.AddOn."+valueName,itm)
;			else
;				Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddCME : Failed to get " + (c + 1) + "th spell in " + n + "...")
			endif
		endWhile
;	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddCME : " + n + " - Failed to load valueName...")
	endif
endFunction

function AddRaceAddOnValue(race r, string n, string cat,string valueName)
	float v=FWUtility.getIniCFloat("AddOn",n,cat,valueName,1.0)
	
	if v>0; && v<10
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnValue : Race = " + r + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnValue : Data = " + cat + " in " + n + ". Loaded valueName = " + v)
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnValue : Data = " + cat + " in " + n + ". valueName condition is satisfied!")
		
		float oldVal = StorageUtil.GetFloatValue(r,"FW.AddOn."+valueName,1.0)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnValue : Data = " + cat + " in " + n + ". oldVal = " + oldVal + " will be changed to " + (oldVal * v))
		
		StorageUtil.SetFloatValue(r, "FW.AddOn."+valueName, (oldVal * v))
;	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnValue : Data = " + cat + " in " + n + ". Loaded valueName is out of range. valueName > 0 is not satisfied..")
	endif
endFunction

function LoadRaceAddOnValue(race r, string n, string cat, string valueName)
	float v = FWUtility.getIniCFloat("AddOn", n, cat, valueName, -1)
	
	if v > 0
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Race = " + r + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = " + cat + " in " + n + ". Loaded valueName = " + v)
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = " + cat + " in " + n + ". valueName condition is satisfied!")
		StorageUtil.SetFloatValue(r, "FW.AddOn." + valueName, v)
;	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = " + cat + " in " + n + ". Loaded valueName is out of range. valueName >=0 is not satisfied..")
	endif
endFunction

function LoadRaceAddOnValueIncludingZero(race r, string n, string cat, string valueName)
	float v = FWUtility.getIniCFloat("AddOn", n, cat, valueName, -1)
	
	if v >= 0
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Race = " + r + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = " + cat + " in " + n + ". Loaded valueName = " + v)
		StorageUtil.SetFloatValue(r, "FW.AddOn." + valueName, v)
	endif
endFunction

function LoadRaceAddOnValueAnything(race r, string n, string cat, string valueName)
	float v = FWUtility.getIniCFloat("AddOn", n, cat, valueName, 0)
	
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Race = " + r + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = " + cat + " in " + n + ". Loaded valueName = " + v)
	StorageUtil.SetFloatValue(r, "FW.AddOn." + valueName, v)
endFunction

function LoadRaceAddOnValueInt(race r, string n, string cat, string valueName)
	int v = FWUtility.getIniCInt("AddOn", n, cat, valueName, -1)
	
	if v >= 0
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValueInt : Race = " + r + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValueInt : Data = " + cat + " in " + n + ". Loaded valueName = " + v)
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValueInt : Data = " + cat + " in " + n + ". valueName condition is satisfied!")
		StorageUtil.SetIntValue(r, "FW.AddOn." + valueName, v)
;	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValueInt : Data = " + cat + " in " + n + ". Loaded valueName is out of range. valueName >=0 is not satisfied..")
	endif
endFunction

function AddRaceAddOnArrayToList(race r, string n, string cat,string valueName)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)

	string s = FWUtility.getIniCString("AddOn",n,cat,valueName,"")
	if s;/!=""/; ;Tkc (Loverslab): optimization
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". Loaded valueName = " + s)

		string[] ss=StringUtil.Split(s,",")
		int c=ss.length
		
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". Number of valueName = " + c)
		
		if StorageUtil.GetIntValue(r,"FW.AddOn.Female_Force_This_Baby",0)==0
;			Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". For race " + r + ", FW.AddOn.Female_Force_This_Baby is zero")
			
			while c>0
				c-=1
				if ss[c];/!=""/; ;Tkc (Loverslab): optimization
;					Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". " + (c + 1) + "th valueName = " + ss[c])
;					form itm = FWUtility.GetFormFromString(ss[c])		// GetFormFromString is DEPRECATED in SE! Use FWUtility.GetFormFromStringSE() instead!
					form itm = FWUtility.GetFormFromStringSE(ss[c])				

					if itm;/!=none/;
;						Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". Loaded " + (c + 1) + "th valueName is " + itm)
						
						if StorageUtil.FormListHas(r,"FW.AddOn."+valueName,itm) ;Tkc (Loverslab): optimization
;							Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". " + (c + 1) + "th valueName is already added in FW.AddOn." + valueName + " for race " + r)
						else;if StorageUtil.FormListHas(r,"FW.AddOn."+valueName,itm)==false
							Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". " + (c + 1) + "th valueName will be added to FW.AddOn." + valueName + " in race " + r)
							StorageUtil.FormListAdd(r,"FW.AddOn."+valueName,itm)
						endif
;					else
;						Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". Failed to load " + (c + 1) + "th valueName...")
					endif
;				else
;					Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". Failed to load " + (c + 1) + "th valueName...")
				endif
			endWhile
		else
			Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". For race " + r + ", FW.AddOn.Female_Force_This_Baby is not zero")

			Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". Clearing FW.AddOn." + valueName + " in race " + r)
			StorageUtil.FormListClear(r, "FW.AddOn." + valueName)

			while c>0
				c-=1
				if ss[c];/!=""/; ;Tkc (Loverslab): optimization
;					Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". " + (c + 1) + "th valueName = " + ss[c])
;					form itm = FWUtility.GetFormFromString(ss[c])		// GetFormFromString is DEPRECATED in SE! Use FWUtility.GetFormFromStringSE() instead!
					form itm = FWUtility.GetFormFromStringSE(ss[c])

					if itm;/!=none/;
						Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". Loaded " + (c + 1) + "th valueName is " + itm)

						Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". " + (c + 1) + "th valueName will be added to FW.AddOn." + valueName + " in race " + r)
						if StorageUtil.FormListHas(r,"FW.AddOn."+valueName,itm) ;Tkc (Loverslab): optimization
;							Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". " + (c + 1) + "th valueName is already added in FW.AddOn." + valueName + " for race " + r)
						else;if StorageUtil.FormListHas(r,"FW.AddOn."+valueName,itm)==false
							StorageUtil.FormListAdd(r,"FW.AddOn."+valueName,itm)
						endIf
;					else
;						Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". Failed to load " + (c + 1) + "th valueName...")
					endif
;				else
;					Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Race = " + r + ", Data = " + cat + " in " + n + ". Failed to load " + (c + 1) + "th valueName...")
				endif
			endWhile
		endif
;	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Failed to load valueName...")
	endif
endFunction

function AddRaceAddOnCat(string n, string cat)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnCat : AddOn file name = " + n + ", loading data in = " + cat)

	string ids=FWUtility.getIniCString("AddOn",n,cat,"id","")
	if ids;/!=""/; ;Tkc (Loverslab): optimization
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnCat : AddOn file name = " + n + ", loading data in = " + cat + ". Loaded id = " + ids)

		string[] saRaces=StringUtil.Split(ids,",")
		int c2=saRaces.length
		while c2>0
			c2-=1
;			race r=FWUtility.GetFormFromString(saRaces[c2]) as Race		// GetFormFromString is DEPRECATED in SE! Use FWUtility.GetFormFromStringSE() instead!
			race r = FWUtility.GetFormFromStringSE(saRaces[c2]) as Race
			
			if r;/!=none/;
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnCat : AddOn file name = " + n + ", loading data in = " + cat + ". " + (c2 + 1) + "th race is " + r)
					
				AddRaceAddOn(r,n,cat)
;			else
;				Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnCat : AddOn file name = " + n + ", loading data in = " + cat + ". Failed to load " + (c2 + 1) + "th race...")
			endif
		endWhile
;	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnCat : AddOn file name = " + n + ", loading data in = " + cat + ". Failed to load id...")
	endif
endFunction
function AddRaceAddOn(race r, string n, string cat)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r)

	if StorageUtil.FormListHas(none,"FW.AddOn.Races",r) ;Tkc (Loverslab): optimization
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". This race is already in FW.AddOn.Races...")
	else;if !StorageUtil.FormListHas(none,"FW.AddOn.Races",r)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Adding this race to FW.AddOn.Races")

		StorageUtil.FormListAdd(none,"FW.AddOn.Races",r)
	endif
	
	if FWUtility.getIniCBool("AddOn",n,cat,"DisablePregnancy",false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Activating FW.AddOn.DisablePregnancy for this race")
	
		StorageUtil.SetIntValue(r,"FW.AddOn.DisablePregnancy",1)
;	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Does not activate FW.AddOn.DisablePregnancy for this race")
	endif
	AddRaceAddOnValue(r,n,cat,"ChanceToBecomePregnantScale")
	AddRaceAddOnValue(r,n,cat,"ContraceptionDuration")
	AddRaceAddOnValue(r,n,cat,"Duration_01_Follicular")
	AddRaceAddOnValue(r,n,cat,"Duration_02_Ovulation")
	AddRaceAddOnValue(r,n,cat,"Duration_03_Luteal")
	AddRaceAddOnValue(r,n,cat,"Duration_04_Menstruation")
	AddRaceAddOnValue(r,n,cat,"Duration_05_Trimester1")
	AddRaceAddOnValue(r,n,cat,"Duration_06_Trimester2")
	AddRaceAddOnValue(r,n,cat,"Duration_07_Trimester3")
	AddRaceAddOnValue(r,n,cat,"Duration_08_Recovery")
	AddRaceAddOnValue(r,n,cat,"Duration_09_LaborPains")
	AddRaceAddOnValue(r,n,cat,"Duration_10_SecondsBetweenLaborPains")
	AddRaceAddOnValue(r,n,cat,"Duration_11_SecondsBetweenBabySpawn")
	AddRaceAddOnValue(r,n,cat,"Irregulation_Chance_Scale")
	AddRaceAddOnValue(r,n,cat,"Irregulation_Value_Scale")
	AddRaceAddOnValue(r,n,cat,"Max_CME_EffectScale")
	AddRaceAddOnValue(r,n,cat,"Multiple_Threshold_Chance")
	AddRaceAddOnValue(r,n,cat,"Multiple_Threshold_Max_Babys")
	AddRaceAddOnValue(r,n,cat,"Pain_Abortus")
	AddRaceAddOnValue(r,n,cat,"Pain_GivingBirth")
	AddRaceAddOnValue(r,n,cat,"Pain_LaborPains")
	AddRaceAddOnValue(r,n,cat,"Pain_Menstruation")
	AddRaceAddOnValue(r,n,cat,"Pain_Mittelschmerz")
	AddRaceAddOnValue(r,n,cat,"Pain_Phase_CyclePains")
	AddRaceAddOnValue(r,n,cat,"Pain_Phase_PregnantPains")
	AddRaceAddOnValue(r,n,cat,"Pain_PMS")
	AddRaceAddOnValue(r,n,cat,"PMS_ChanceScale")
	AddRaceAddOnValue(r,n,cat,"Sizes_Belly_Max")
	AddRaceAddOnValue(r,n,cat,"Sizes_Belly_Max_Multiple")
	AddRaceAddOnValue(r,n,cat,"Sizes_Breasts_Max")
	AddRaceAddOnValue(r,n,cat,"Sizes_Breasts_Max_Multiple")
	LoadRaceAddOnValue(r, n, cat, "Preg1stBellyScale")
	LoadRaceAddOnValue(r, n, cat, "Preg2ndBellyScale")
	LoadRaceAddOnValue(r, n, cat, "Preg3rdBellyScale")
	LoadRaceAddOnValue(r, n, cat, "Preg1stBreastsScale")
	LoadRaceAddOnValue(r, n, cat, "Preg2ndBreastsScale")
	LoadRaceAddOnValue(r, n, cat, "Preg3rdBreastsScale")
	LoadRaceAddOnValue(r, n, cat, "MultipleBabySperm")
	LoadRaceAddOnValue(r, n, cat, "MultipleBabyChancePerSperm")	
	AddRaceAddOnValue(r,n,cat,"Baby_Healing_Scale")
	AddRaceAddOnValue(r,n,cat,"Baby_Damage_Scale")
	
	
	AddRaceAddOnValue(r,n,cat,"Duration_MaleSperm")
	AddRaceAddOnValue(r,n,cat,"Sperm_Amount_Scale")
	AddRaceAddOnValue(r,n,cat,"Male_Recovery_Scale")
	LoadRaceAddOnValueInt(r, n, cat, "ProbChildRaceDeterminedByFather")
	LoadRaceAddOnValueInt(r, n, cat, "ProbChildSexDetermMale")
	LoadRaceAddOnValue(r, n, cat, "Ignore_Contraception_Prob")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Trimester1_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Trimester2_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Trimester3_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_LaborPainsPeriod_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Recovery_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_SecondsBetweenLaborPains_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_SecondsBetweenBabySpawn_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Pain_Abortus_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Pain_GivingBirth_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Pain_LaborPains_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Preg1stBellyScale_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Preg2ndBellyScale_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Preg3rdBellyScale_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Preg1stBreastsScale_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Preg2ndBreastsScale_by_FatherRace")
	LoadRaceAddOnValueIncludingZero(r, n, cat, "Modify_Preg3rdBreastsScale_by_FatherRace")
	if FWUtility.getIniCBool("AddOn", n, cat, "Allow_Impregnation_For_Any_Period", false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Activating FW.AddOn.Allow_Impregnation_For_Any_Period for this race")
		
		LoadRaceAddOnValue(r, n, cat, "Sperm_Impregnation_Prob_For_Any_Period")
		if(StorageUtil.GetFloatValue(r, "FW.AddOn.Sperm_Impregnation_Prob_For_Any_Period", 0) > 0)
			StorageUtil.SetIntValue(r, "FW.AddOn.Allow_Impregnation_For_Any_Period", 1)
		else
			StorageUtil.SetIntValue(r, "FW.AddOn.Allow_Impregnation_For_Any_Period", 0)
		endif
	endif
	LoadRaceAddOnValueAnything(r, n, cat, "Sperm_Impregnation_Boost")
	if FWUtility.getIniCBool("AddOn", n, cat, "Allow_NTR_baby", false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Activating FW.AddOn.Allow_NTR_baby for this race")
		
		LoadRaceAddOnValue(r, n, cat, "Sperm_NTR_baby_Prob")
		if(StorageUtil.GetFloatValue(r, "FW.AddOn.Sperm_NTR_baby_Prob", 0) > 0)
			StorageUtil.SetIntValue(r, "FW.AddOn.Allow_NTR_baby", 1)
		else
			StorageUtil.SetIntValue(r, "FW.AddOn.Allow_NTR_baby", 0)
		endif
	endif
	LoadRaceAddOnValueAnything(r, n, cat, "Modify_Baby_Healing_Scale_by_FatherRace")
	LoadRaceAddOnValueAnything(r, n, cat, "Modify_Baby_Damage_Scale_by_FatherRace")


	if FWUtility.getIniCBool("AddOn",n,cat,"Female_Force_This_Baby",false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Activating FW.AddOn.Female_Force_This_Baby for this race")
		
		StorageUtil.SetIntValue(r,"FW.AddOn.Female_Force_This_Baby",1)
;	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Does not activate FW.AddOn.Female_Force_This_Baby for this race")
	endif
	AddRaceAddOnArrayToList(r,n,cat,"BabyArmor_Female")
	AddRaceAddOnArrayToList(r,n,cat,"BabyArmor_Male")
	AddRaceAddOnArrayToList(r,n,cat,"BabyActor_Female")
	AddRaceAddOnArrayToList(r,n,cat,"BabyActor_FemalePlayer")
	AddRaceAddOnArrayToList(r,n,cat,"BabyActor_Male")
	AddRaceAddOnArrayToList(r,n,cat,"BabyActor_MalePlayer")
	if(FWUtility.getIniCBool("AddOn", n, cat, "MixWithCopyActorBase", false))
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Activating FW.AddOn.MixWithCopyActorBase for this race and reading ProbChildActorBorn...")
		
		StorageUtil.SetIntValue(r, "FW.AddOn.MixWithCopyActorBase", 1)
		LoadRaceAddOnValueInt(r, n, cat, "ProbChildActorBorn")
	endif
	if(FWUtility.getIniCBool("AddOn", n, cat, "AllowPCDialogue", false))
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Activating FW.AddOn.AllowPCDialogue for this race")
		StorageUtil.SetIntValue(r, "FW.AddOn.AllowPCDialogue", 1)
	endIf
	LoadRaceAddOnValue(r, n, cat, "initialScale")
	LoadRaceAddOnValue(r, n, cat, "finalScale")
	if FWUtility.getIniCBool("AddOn", n, cat, "DisableMatureTime", false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Activating FW.AddOn.DisableMatureTime for this race")
		StorageUtil.SetIntValue(r, "FW.AddOn.DisableMatureTime", 1)
	else
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". FW.AddOn.DisableMatureTime is disabled for this race. Reading MatureTimeScale...")
		LoadRaceAddOnValue(r, n, cat, "MatureTimeScale")	
	endif
	LoadRaceAddOnValueInt(r, n, cat, "MatureStep")
	if FWUtility.getIniCBool("AddOn", n, cat, "AllowUnrestrictedS", false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Activating FW.AddOn.AllowUnrestrictedS for this race")
		StorageUtil.SetIntValue(r, "FW.AddOn.AllowUnrestrictedS", 1)
	endif
	if(FWUtility.getIniCBool("AddOn", n, cat, "ProtectedChildActor", false))
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for race " + r + ". Activating FW.AddOn.ProtectedChildActor for this race")
		StorageUtil.SetIntValue(r, "FW.AddOn.ProtectedChildActor", 1)
	endIf
endFunction


Function ClearGlobalSettings()
	; Reset variables
	StorageUtil.SetIntValue(none, "FW.AddOn.Global_RemoveSPIDitems", 0)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_WidgetFadeOutTime", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_WidgetFlashShowTime", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_WidgetNoFlashShowTime", -1)


	StorageUtil.SetIntValue(none, "FW.AddOn.Global_DisablePregnancy", 0)
	
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_ChanceToBecomePregnantScale", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_ContraceptionDuration", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_01_Follicular", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_02_Ovulation", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_03_Luteal", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_04_Menstruation", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_05_Trimester1", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_06_Trimester2", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_07_Trimester3", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_08_Recovery", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_09_LaborPains", 0.2)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_10_SecondsBetweenLaborPains", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_11_SecondsBetweenBabySpawn", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Irregulation_Chance_Scale", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Irregulation_Value_Scale", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Multiple_Threshold_Chance", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Multiple_Threshold_Max_Babys", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Pain_Abortus", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Pain_GivingBirth", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Pain_LaborPains", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Pain_Mittelschmerz", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Pain_Phase_CyclePains", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Pain_Phase_PregnantPains", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Pain_PMS", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_PMS_ChanceScale", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Sizes_Belly_Max", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Sizes_Belly_Max_Multiple", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Sizes_Breasts_Max", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Sizes_Breasts_Max_Multiple", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Preg1stBellyScale", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Preg2ndBellyScale", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Preg3rdBellyScale", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Preg1stBreastsScale", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Preg2ndBreastsScale", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Preg3rdBreastsScale", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_MultipleBabySperm", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_MultipleBabyChancePerSperm", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Baby_Healing_Scale", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Baby_Damage_Scale", 1)


	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Duration_MaleSperm", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Sperm_Amount_Scale", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Male_Recovery_Scale", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Ignore_Contraception_Prob", -1)
	StorageUtil.SetIntValue(none, "FW.AddOn.Global_Allow_Impregnation_For_Any_Period", 0)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Sperm_Impregnation_Prob_For_Any_Period", 0)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Sperm_Impregnation_Boost", 0)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Modify_Baby_Healing_Scale_by_FatherRace", 1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_Modify_Baby_Damage_Scale_by_FatherRace", 1)
	

	StorageUtil.SetIntValue(none, "FW.AddOn.Global_Female_Force_This_Baby", 0)
	StorageUtil.FormListClear(none, "FW.AddOn.Global_BabyActor_Female")
	StorageUtil.FormListClear(none, "FW.AddOn.Global_BabyActor_FemalePlayer")
	StorageUtil.FormListClear(none, "FW.AddOn.Global_BabyActor_Male")
	StorageUtil.FormListClear(none, "FW.AddOn.Global_BabyActor_MalePlayer")			
	StorageUtil.SetIntValue(none, "FW.AddOn.Global_MixWithCopyActorBase", 0)
	StorageUtil.SetIntValue(none, "FW.AddOn.Global_ProbChildActorBorn", -1)
	StorageUtil.SetIntValue(none, "FW.AddOn.Global_AllowPCDialogue", 0)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_initialScale", -1)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_finalScale", -1)
	StorageUtil.SetIntValue(none, "FW.AddOn.Global_DisableMatureTime", 0)
	StorageUtil.SetFloatValue(none, "FW.AddOn.Global_MatureTimeScale", -1)
	StorageUtil.SetIntValue(none, "FW.AddOn.Global_MatureStep", -1)
	StorageUtil.SetIntValue(none, "FW.AddOn.Global_AllowUnrestrictedS", 0)
	StorageUtil.SetIntValue(none, "FW.AddOn.Global_ProtectedChildActor", 0)


	; Unset variables
	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_RemoveSPIDitems")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_WidgetFadeOutTime")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_WidgetFlashShowTime")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_WidgetNoFlashShowTime")


	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_DisablePregnancy")
	
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_ChanceToBecomePregnantScale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_ContraceptionDuration")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_01_Follicular")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_02_Ovulation")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_03_Luteal")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_04_Menstruation")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_05_Trimester1")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_06_Trimester2")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_07_Trimester3")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_08_Recovery")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_09_LaborPains")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_10_SecondsBetweenLaborPains")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_11_SecondsBetweenBabySpawn")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Irregulation_Chance_Scale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Irregulation_Value_Scale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Multiple_Threshold_Chance")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Multiple_Threshold_Max_Babys")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Pain_Abortus")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Pain_GivingBirth")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Pain_LaborPains")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Pain_Mittelschmerz")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Pain_Phase_CyclePains")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Pain_Phase_PregnantPains")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Pain_PMS")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_PMS_ChanceScale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Sizes_Belly_Max")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Sizes_Belly_Max_Multiple")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Sizes_Breasts_Max")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Sizes_Breasts_Max_Multiple")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Preg1stBellyScale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Preg2ndBellyScale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Preg3rdBellyScale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Preg1stBreastsScale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Preg2ndBreastsScale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Preg3rdBreastsScale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_MultipleBabySperm")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_MultipleBabyChancePerSperm")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Baby_Healing_Scale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Baby_Damage_Scale")


	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Duration_MaleSperm")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Sperm_Amount_Scale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Male_Recovery_Scale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Ignore_Contraception_Prob")
	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_Allow_Impregnation_For_Any_Period")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Sperm_Impregnation_Prob_For_Any_Period")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Sperm_Impregnation_Boost")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Modify_Baby_Healing_Scale_by_FatherRace")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_Modify_Baby_Damage_Scale_by_FatherRace")


	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_Female_Force_This_Baby")
	StorageUtil.FormListClear(none, "FW.AddOn.Global_BabyActor_Female")
	StorageUtil.FormListClear(none, "FW.AddOn.Global_BabyActor_FemalePlayer")
	StorageUtil.FormListClear(none, "FW.AddOn.Global_BabyActor_Male")
	StorageUtil.FormListClear(none, "FW.AddOn.Global_BabyActor_MalePlayer")
	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_MixWithCopyActorBase")
	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_ProbChildActorBorn")
	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_AllowPCDialogue")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_initialScale")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_finalScale")
	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_DisableMatureTime")
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Global_MatureTimeScale")
	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_MatureStep")
	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_AllowUnrestrictedS")
	StorageUtil.UnsetIntValue(none, "FW.AddOn.Global_ProtectedChildActor")
endFunction
function LoadGlobalAddOnValue(string n, string valueName)
	float v = FWUtility.getIniCFloat("AddOn", n, "AddOn", valueName, -1)
	
	if v > 0
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : AddOn file name = " + n + ", loading data in = AddOn, and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = AddOn in " + n + ". Loaded valueName = " + v)
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = AddOn in " + n + ". valueName condition is satisfied!")
		StorageUtil.SetFloatValue(none, "FW.AddOn." + valueName, v)
;	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = AddOn in " + n + ". Loaded valueName is out of range. valueName >=0 is not satisfied..")
	endif
endFunction
function LoadGlobalAddOnValueIncludingZero(string n, string valueName)
	float v = FWUtility.getIniCFloat("AddOn", n, "AddOn", valueName, -1)
	
	if(v >= 0)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : AddOn file name = " + n + ", loading data in = AddOn, and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = AddOn in " + n + ". Loaded valueName = " + v)
		StorageUtil.SetFloatValue(none, "FW.AddOn." + valueName, v)
	endif
endFunction
function LoadGlobalAddOnValueAnything(string n, string valueName)
	float v = FWUtility.getIniCFloat("AddOn", n, "AddOn", valueName, 0)
	
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : AddOn file name = " + n + ", loading data in = AddOn, and valueName = " + valueName)
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = AddOn in " + n + ". Loaded valueName = " + v)
	StorageUtil.SetFloatValue(none, "FW.AddOn." + valueName, v)
endFunction
function LoadGlobalAddOnValueInt(string n, string valueName)
	int v = FWUtility.getIniCInt("AddOn", n, "AddOn", valueName, -1)
	
	if v >= 0
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValueInt : AddOn file name = " + n + ", loading data in AddOn, and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValueInt : Data = AddOn in " + n + ". Loaded valueName = " + v)
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValueInt : Data = AddOn in " + n + ". valueName condition is satisfied!")
		StorageUtil.SetIntValue(none, "FW.AddOn." + valueName, v)
;	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValueInt : Data = AddOn in " + n + ". Loaded valueName is out of range. valueName >=0 is not satisfied..")
	endif
endFunction
function AddGlobalAddOnArrayToList(string n, string valueName)
	string s = FWUtility.getIniCString("AddOn", n, "AddOn", valueName, "")
	if s;/!=""/; ;Tkc (Loverslab): optimization
		string[] ss = StringUtil.Split(s, ",")
		int c = ss.length
		
		if StorageUtil.GetIntValue(none, "FW.AddOn.Female_Force_This_Baby", 0) == 0
			while(c > 0)
				c -= 1
				if ss[c];/!=""/; ;Tkc (Loverslab): optimization
;					form itm = FWUtility.GetFormFromString(ss[c])		// GetFormFromString is DEPRECATED in SE! Use FWUtility.GetFormFromStringSE() instead!
					form itm = FWUtility.GetFormFromStringSE(ss[c])				

					if itm;/!=none/;
						if StorageUtil.FormListHas(none, "FW.AddOn." + valueName, itm) ;Tkc (Loverslab): optimization
						else;if StorageUtil.FormListHas(r,"FW.AddOn."+valueName,itm)==false
							Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddGlobalAddOnArrayToList : Data in " + n + ". " + (c + 1) + "th valueName will be added to FW.AddOn." + valueName + " in global settings")
							StorageUtil.FormListAdd(none, "FW.AddOn." + valueName, itm)
						endif
					endif
				endif
			endWhile
		else
			Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddGlobalAddOnArrayToList : Data in " + n + ". Global FW.AddOn.Female_Force_This_Baby is not zero")

			Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddGlobalAddOnArrayToList : Data in " + n + ". Clearing FW.AddOn." + valueName + " in global settings")
			StorageUtil.FormListClear(none, "FW.AddOn." + valueName)

			while(c > 0)
				c -= 1
				if ss[c];/!=""/; ;Tkc (Loverslab): optimization
					form itm = FWUtility.GetFormFromStringSE(ss[c])

					if itm;/!=none/;
						Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddGlobalAddOnArrayToList : Data in " + n + ". Loaded " + (c + 1) + "th valueName is " + itm)

						Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddGlobalAddOnArrayToList : Data in " + n + ". " + (c + 1) + "th valueName will be added to FW.AddOn." + valueName + " in global settings")
						if StorageUtil.FormListHas(none, "FW.AddOn." + valueName, itm) ;Tkc (Loverslab): optimization
						else;if StorageUtil.FormListHas(r,"FW.AddOn."+valueName,itm)==false
							StorageUtil.FormListAdd(none, "FW.AddOn." + valueName, itm)
						endIf
					endif
				endif
			endWhile
		endif
	endif
endFunction


function AddActorAddOnArrayToList(actor a, string n, string cat, string valueName)
	string s = FWUtility.getIniCString("AddOn", n, cat, valueName, "")
	if s;/!=""/; ;Tkc (Loverslab): optimization
		string[] ss = StringUtil.Split(s, ",")
		int c = ss.length
		
		if(StorageUtil.GetIntValue(a, "FW.AddOn.Female_Force_This_Baby", 0) == 0)
			while(c > 0)
				c -= 1
				if ss[c];/!=""/; ;Tkc (Loverslab): optimization
;					form itm = FWUtility.GetFormFromString(ss[c])		// GetFormFromString is DEPRECATED in SE! Use FWUtility.GetFormFromStringSE() instead!
					form itm = FWUtility.GetFormFromStringSE(ss[c])				

					if itm;/!=none/;
						if StorageUtil.FormListHas(a, "FW.AddOn." + valueName, itm) ;Tkc (Loverslab): optimization
						else;if StorageUtil.FormListHas(r,"FW.AddOn."+valueName,itm)==false
							Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddRaceAddOnArrayToList : Actor = " + a + ", Data = " + cat + " in " + n + ". " + (c + 1) + "th valueName will be added to FW.AddOn." + valueName + " in actor " + a)
							StorageUtil.FormListAdd(a, "FW.AddOn." + valueName, itm)
						endif
					endif
				endif
			endWhile
		else
			Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOnArrayToList : Actor = " + a + ", Data = " + cat + " in " + n + ". For actor " + a + ", FW.AddOn.Female_Force_This_Baby is not zero")

			Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOnArrayToList : Actor = " + a + ", Data = " + cat + " in " + n + ". Clearing FW.AddOn." + valueName + " in actor " + a)
			StorageUtil.FormListClear(a, "FW.AddOn." + valueName)

			while(c > 0)
				c -= 1
				if ss[c];/!=""/; ;Tkc (Loverslab): optimization
;					form itm = FWUtility.GetFormFromString(ss[c])		// GetFormFromString is DEPRECATED in SE! Use FWUtility.GetFormFromStringSE() instead!
					form itm = FWUtility.GetFormFromStringSE(ss[c])

					if itm;/!=none/;
						Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOnArrayToList : Actor = " + a + ", Data = " + cat + " in " + n + ". Loaded " + (c + 1) + "th valueName is " + itm)

						Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOnArrayToList : Actor = " + a + ", Data = " + cat + " in " + n + ". " + (c + 1) + "th valueName will be added to FW.AddOn." + valueName + " in actor " + a)
						if StorageUtil.FormListHas(a, "FW.AddOn." + valueName, itm) ;Tkc (Loverslab): optimization
						else;if StorageUtil.FormListHas(r,"FW.AddOn."+valueName,itm)==false
							StorageUtil.FormListAdd(a, "FW.AddOn." + valueName, itm)
						endIf
					endif
				endif
			endWhile
		endif
	endif
endFunction
function AddActorAddOnValue(actor a, string n, string cat, string valueName)
	float v = FWUtility.getIniCFloat("AddOn", n, cat, valueName, 1.0)
	
	if(v > 0)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOnValue : Actor = " + a + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOnValue : Data = " + cat + " in " + n + ". Loaded valueName = " + v)
		
		float oldVal = StorageUtil.GetFloatValue(a, "FW.AddOn." + valueName, 1.0)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOnValue : Data = " + cat + " in " + n + ". oldVal = " + oldVal + " will be changed to " + (oldVal * v))
		
		StorageUtil.SetFloatValue(a, "FW.AddOn." + valueName, (oldVal * v))
	endif
endFunction
function LoadActorAddOnValueInt(actor a, string n, string cat, string valueName)
	int v = FWUtility.getIniCInt("AddOn", n, cat, valueName, -1)
	
	if(v >= 0)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadActorAddOnValueInt : Actor = " + a + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadActorAddOnValueInt : Data = " + cat + " in " + n + ". Loaded valueName = " + v)
		StorageUtil.SetIntValue(a, "FW.AddOn." + valueName, v)
	endif
endFunction
function LoadActorAddOnValue(actor a, string n, string cat, string valueName)
	float v = FWUtility.getIniCFloat("AddOn", n, cat, valueName, -1)
	
	if(v > 0)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadActorAddOnValue : Actor = " + a + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadActorAddOnValue : Data = " + cat + " in " + n + ". Loaded valueName = " + v)
		StorageUtil.SetFloatValue(a, "FW.AddOn." + valueName, v)
	endif
endFunction
function LoadActorAddOnValueIncludingZero(actor a, string n, string cat, string valueName)
	float v = FWUtility.getIniCFloat("AddOn", n, cat, valueName, -1)
	
	if(v >= 0)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Actor = " + a + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = " + cat + " in " + n + ". Loaded valueName = " + v)
		StorageUtil.SetFloatValue(a, "FW.AddOn." + valueName, v)
	endif
endFunction
function LoadActorAddOnValueAnything(actor a, string n, string cat, string valueName)
	float v = FWUtility.getIniCFloat("AddOn", n, cat, valueName, 0)
	
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Actor = " + a + ". AddOn file name = " + n + ", loading data in = " + cat + ", and valueName = " + valueName)
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - LoadRaceAddOnValue : Data = " + cat + " in " + n + ". Loaded valueName = " + v)
	StorageUtil.SetFloatValue(a, "FW.AddOn." + valueName, v)
endFunction

function AddActorAddOnCat(string n, string cat)
	string ids = FWUtility.getIniCString("AddOn", n, cat, "id", "")
	if ids;/!=""/; ;Tkc (Loverslab): optimization
		string[] saActors = StringUtil.Split(ids, ",")
		int c2 = saActors.length
		while(c2 > 0)
			c2 -= 1
;			race r=FWUtility.GetFormFromString(saRaces[c2]) as Race		// GetFormFromString is DEPRECATED in SE! Use FWUtility.GetFormFromStringSE() instead!
			actor a = FWUtility.GetFormFromStringSE(saActors[c2]) as actor
			
			if a;/!=none/;
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOnCat : AddOn file name = " + n + ", loading data in = " + cat + ". " + (c2 + 1) + "th actor is " + a)
					
				AddActorAddOn(a, n, cat)
			endif
		endWhile
	endif
endFunction
function AddActorAddOn(actor a, string n, string cat)
	if StorageUtil.FormListHas(none, "FW.AddOn.Actors", a) ;Tkc (Loverslab): optimization
	else;if !StorageUtil.FormListHas(none,"FW.AddOn.Races",r)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". Adding this Actor to FW.AddOn.Actors")

		StorageUtil.FormListAdd(none, "FW.AddOn.Actors", a)
	endif
	
	if FWUtility.getIniCBool("AddOn", n, cat, "DisablePregnancy", false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". Activating FW.AddOn.DisablePregnancy for this actor")
	
		StorageUtil.SetIntValue(a, "FW.AddOn.DisablePregnancy", 1)
	endif
	AddActorAddOnValue(a, n, cat, "ChanceToBecomePregnantScale")
	AddActorAddOnValue(a, n, cat, "ContraceptionDuration")
	AddActorAddOnValue(a, n, cat, "Duration_01_Follicular")
	AddActorAddOnValue(a, n, cat, "Duration_02_Ovulation")
	AddActorAddOnValue(a, n, cat, "Duration_03_Luteal")
	AddActorAddOnValue(a, n, cat, "Duration_04_Menstruation")
	AddActorAddOnValue(a, n, cat, "Duration_05_Trimester1")
	AddActorAddOnValue(a, n, cat, "Duration_06_Trimester2")
	AddActorAddOnValue(a, n, cat, "Duration_07_Trimester3")
	AddActorAddOnValue(a, n, cat, "Duration_08_Recovery")
	AddActorAddOnValue(a, n, cat, "Duration_08_Recovery")
	AddActorAddOnValue(a, n, cat, "Duration_09_LaborPains")
	AddActorAddOnValue(a, n, cat, "Duration_11_SecondsBetweenBabySpawn")
	AddActorAddOnValue(a, n, cat, "Irregulation_Chance_Scale")
	AddActorAddOnValue(a, n, cat, "Irregulation_Value_Scale")
	AddActorAddOnValue(a, n, cat, "Multiple_Threshold_Chance")
	AddActorAddOnValue(a, n, cat, "Multiple_Threshold_Max_Babys")
	AddActorAddOnValue(a, n, cat, "Pain_Abortus")
	AddActorAddOnValue(a, n, cat, "Pain_GivingBirth")
	AddActorAddOnValue(a, n, cat, "Pain_LaborPains")
	AddActorAddOnValue(a, n, cat, "Pain_Mittelschmerz")
	AddActorAddOnValue(a, n, cat, "Pain_Phase_CyclePains")
	AddActorAddOnValue(a, n, cat, "Pain_Phase_PregnantPains")
	AddActorAddOnValue(a, n, cat, "Pain_PMS")
	AddActorAddOnValue(a, n, cat, "PMS_ChanceScale")
	AddActorAddOnValue(a, n, cat, "Sizes_Belly_Max")
	AddActorAddOnValue(a, n, cat, "Sizes_Belly_Max_Multiple")
	AddActorAddOnValue(a, n, cat, "Sizes_Breasts_Max")
	AddActorAddOnValue(a, n, cat, "Sizes_Breasts_Max_Multiple")
	LoadActorAddOnValue(a, n, cat, "Preg1stBellyScale")
	LoadActorAddOnValue(a, n, cat, "Preg2ndBellyScale")
	LoadActorAddOnValue(a, n, cat, "Preg3rdBellyScale")
	LoadActorAddOnValue(a, n, cat, "Preg1stBreastsScale")
	LoadActorAddOnValue(a, n, cat, "Preg2ndBreastsScale")
	LoadActorAddOnValue(a, n, cat, "Preg3rdBreastsScale")
	LoadActorAddOnValue(a, n, cat, "MultipleBabySperm")
	LoadActorAddOnValue(a, n, cat, "MultipleBabyChancePerSperm")	
	AddActorAddOnValue(a, n, cat, "Baby_Healing_Scale")
	AddActorAddOnValue(a, n, cat, "Baby_Damage_Scale")
	
	
	AddActorAddOnValue(a, n, cat, "Duration_MaleSperm")
	AddActorAddOnValue(a, n, cat, "Sperm_Amount_Scale")
	AddActorAddOnValue(a, n, cat, "Male_Recovery_Scale")
	LoadActorAddOnValueInt(a, n, cat, "ProbChildRaceDeterminedByFather")
	LoadActorAddOnValueInt(a, n, cat, "ProbChildSexDetermMale")
	LoadActorAddOnValue(a, n, cat, "Ignore_Contraception_Prob")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Trimester1_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Trimester2_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Trimester3_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_LaborPainsPeriod_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Recovery_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_SecondsBetweenLaborPains_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_SecondsBetweenBabySpawn_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Pain_Abortus_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Pain_GivingBirth_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Pain_LaborPains_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Preg1stBellyScale_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Preg2ndBellyScale_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Preg3rdBellyScale_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Preg1stBreastsScale_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Preg2ndBreastsScale_by_FatherRace")
	LoadActorAddOnValueIncludingZero(a, n, cat, "Modify_Preg3rdBreastsScale_by_FatherRace")
	if FWUtility.getIniCBool("AddOn", n, cat, "Allow_Impregnation_For_Any_Period", false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". Activating FW.AddOn.Allow_Impregnation_For_Any_Period for this actor")
		
		LoadActorAddOnValue(a, n, cat, "Sperm_Impregnation_Prob_For_Any_Period")
		if(StorageUtil.GetFloatValue(a, "FW.AddOn.Sperm_Impregnation_Prob_For_Any_Period", 0) > 0)
			StorageUtil.SetIntValue(a, "FW.AddOn.Allow_Impregnation_For_Any_Period", 1)
		else
			StorageUtil.SetIntValue(a, "FW.AddOn.Allow_Impregnation_For_Any_Period", 0)
		endif
	endif
	LoadActorAddOnValueAnything(a, n, cat, "Sperm_Impregnation_Boost")
	if FWUtility.getIniCBool("AddOn", n, cat, "Allow_NTR_baby", false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". Activating FW.AddOn.Allow_NTR_baby for this actor")
		
		LoadActorAddOnValue(a, n, cat, "Sperm_NTR_baby_Prob")
		if(StorageUtil.GetFloatValue(a, "FW.AddOn.Sperm_NTR_baby_Prob", 0) > 0)
			StorageUtil.SetIntValue(a, "FW.AddOn.Allow_NTR_baby", 1)
		else
			StorageUtil.SetIntValue(a, "FW.AddOn.Allow_NTR_baby", 0)
		endif
	endif
	LoadActorAddOnValueAnything(a, n, cat, "Modify_Baby_Healing_Scale_by_FatherRace")
	LoadActorAddOnValueAnything(a, n, cat, "Modify_Baby_Damage_Scale_by_FatherRace")


	if FWUtility.getIniCBool("AddOn", n, cat, "Female_Force_This_Baby", false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". Activating FW.AddOn.Female_Force_This_Baby for this actor")
		
		StorageUtil.SetIntValue(a, "FW.AddOn.Female_Force_This_Baby", 1)
	endif
	AddActorAddOnArrayToList(a, n, cat, "BabyActor_Female")
	AddActorAddOnArrayToList(a, n, cat, "BabyActor_FemalePlayer")
	AddActorAddOnArrayToList(a, n, cat, "BabyActor_Male")
	AddActorAddOnArrayToList(a, n, cat, "BabyActor_MalePlayer")
	if(FWUtility.getIniCBool("AddOn", n, cat, "MixWithCopyActorBase", false))
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". Activating FW.AddOn.MixWithCopyActorBase for this actor and reading ProbChildActorBorn...")
		
		StorageUtil.SetIntValue(a, "FW.AddOn.MixWithCopyActorBase", 1)
		LoadActorAddOnValueInt(a, n, cat, "ProbChildActorBorn")
	endif
	if(FWUtility.getIniCBool("AddOn", n, cat, "AllowPCDialogue", false))
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". Activating FW.AddOn.AllowPCDialogue for this actor")
		StorageUtil.SetIntValue(a, "FW.AddOn.AllowPCDialogue", 1)
	endIf
	LoadActorAddOnValue(a, n, cat, "initialScale")
	LoadActorAddOnValue(a, n, cat, "finalScale")
	if FWUtility.getIniCBool("AddOn", n, cat, "DisableMatureTime", false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". Activating FW.AddOn.DisableMatureTime for this actor")
		StorageUtil.SetIntValue(a, "FW.AddOn.DisableMatureTime", 1)
	else
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". FW.AddOn.DisableMatureTime is disabled for this actor. Reading MatureTimeScale...")
		LoadActorAddOnValue(a, n, cat, "MatureTimeScale")	
	endif
	LoadActorAddOnValueInt(a, n, cat, "MatureStep")
	if FWUtility.getIniCBool("AddOn", n, cat, "AllowUnrestrictedS", false)
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". Activating FW.AddOn.AllowUnrestrictedS for this actor")
		StorageUtil.SetIntValue(a, "FW.AddOn.AllowUnrestrictedS", 1)
	endif
	if(FWUtility.getIniCBool("AddOn", n, cat, "ProtectedChildActor", false))
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - AddActorAddOn : AddOn file name = " + n + ", loading data in = " + cat + " for actor " + a + ". Activating FW.AddOn.ProtectedChildActor for this actor")
		StorageUtil.SetIntValue(a, "FW.AddOn.ProtectedChildActor", 1)
	endIf
endFunction
function ClearActorAddOns()
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - ClearActorAddOns : Clearing...")

	int c = StorageUtil.FormListCount(none, "FW.AddOn.Actors")
	while(c > 0)
		c -= 1
		actor a = StorageUtil.FormListGet(none, "FW.AddOn.Actors", c) as actor
		if a ;Tkc (Loverslab): optimization
			StorageUtil.SetIntValue(a, "FW.AddOn.DisablePregnancy", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.ChanceToBecomePregnantScale", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.ContraceptionDuration", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_01_Follicular", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_02_Ovulation", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_03_Luteal", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_04_Menstruation", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_05_Trimester1", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_06_Trimester2", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_07_Trimester3", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_08_Recovery", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_09_LaborPains", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_10_SecondsBetweenLaborPains", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_11_SecondsBetweenBabySpawn", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Irregulation_Chance_Scale", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Irregulation_Value_Scale", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Multiple_Threshold_Chance", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Multiple_Threshold_Max_Babys", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Pain_Abortus", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Pain_GivingBirth", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Pain_LaborPains", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Pain_Mittelschmerz", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Pain_Phase_CyclePains", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Pain_Phase_PregnantPains", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Pain_PMS", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.PMS_ChanceScale", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Sizes_Belly_Max", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Sizes_Belly_Max_Multiple", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Sizes_Breasts_Max", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Sizes_Breasts_Max_Multiple", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Preg1stBellyScale", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Preg2ndBellyScale", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Preg3rdBellyScale", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Preg1stBreastsScale", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Preg2ndBreastsScale", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Preg3rdBreastsScale", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.MultipleBabySperm", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.MultipleBabyChancePerSperm", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Baby_Healing_Scale", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Baby_Damage_Scale", 1)
			
		
			StorageUtil.SetFloatValue(a, "FW.AddOn.Duration_MaleSperm", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Sperm_Amount_Scale", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Male_Recovery_Scale", 1)
			StorageUtil.SetIntValue(a, "FW.AddOn.ProbChildRaceDeterminedByFather", -1)
			StorageUtil.SetIntValue(a, "FW.AddOn.ProbChildSexDetermMale", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Ignore_Contraception_Prob", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Trimester1_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Trimester2_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Trimester3_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_LaborPainsPeriod_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Recovery_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_SecondsBetweenLaborPains_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_SecondsBetweenBabySpawn_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Pain_Abortus_by_FatherRace", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Pain_GivingBirth_by_FatherRace", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Pain_LaborPains_by_FatherRace", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Preg1stBellyScale_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Preg2ndBellyScale_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Preg3rdBellyScale_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Preg1stBreastsScale_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Preg2ndBreastsScale_by_FatherRace", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Preg3rdBreastsScale_by_FatherRace", 0)
			StorageUtil.SetIntValue(a, "FW.AddOn.Allow_Impregnation_For_Any_Period", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Sperm_Impregnation_Prob_For_Any_Period", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Sperm_Impregnation_Boost", 0)
			StorageUtil.SetIntValue(a, "FW.AddOn.Allow_NTR_baby", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Sperm_NTR_baby_Prob", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Baby_Healing_Scale_by_FatherRace", 1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.Modify_Baby_Damage_Scale_by_FatherRace", 1)


			StorageUtil.SetIntValue(a, "FW.AddOn.Female_Force_This_Baby", 0)
			StorageUtil.FormListClear(a, "FW.AddOn.BabyActor_Female")
			StorageUtil.FormListClear(a, "FW.AddOn.BabyActor_FemalePlayer")
			StorageUtil.FormListClear(a, "FW.AddOn.BabyActor_Male")
			StorageUtil.FormListClear(a, "FW.AddOn.BabyActor_MalePlayer")			
			StorageUtil.SetIntValue(a, "FW.AddOn.MixWithCopyActorBase", 0)
			StorageUtil.SetIntValue(a, "FW.AddOn.ProbChildActorBorn", -1)
			StorageUtil.SetIntValue(a, "FW.AddOn.AllowUnrestrictedS", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.initialScale", -1)
			StorageUtil.SetFloatValue(a, "FW.AddOn.finalScale", -1)
			StorageUtil.SetIntValue(a, "FW.AddOn.DisableMatureTime", 0)
			StorageUtil.SetFloatValue(a, "FW.AddOn.MatureTimeScale", -1)
			StorageUtil.SetIntValue(a, "FW.AddOn.MatureStep", -1)
			StorageUtil.SetIntValue(a, "FW.AddOn.AllowPCDialogue", 0)
			StorageUtil.SetIntValue(a, "FW.AddOn.ProtectedChildActor", 0)
		else;if r==none
			StorageUtil.UnsetIntValue(a, "FW.AddOn.DisablePregnancy")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.ChanceToBecomePregnantScale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.ContraceptionDuration")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_01_Follicular")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_02_Ovulation")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_03_Luteal")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_04_Menstruation")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_05_Trimester1")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_06_Trimester2")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_07_Trimester3")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_08_Recovery")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_09_LaborPains")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_10_SecondsBetweenLaborPains")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_11_SecondsBetweenBabySpawn")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Irregulation_Chance_Scale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Irregulation_Value_Scale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Multiple_Threshold_Chance")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Multiple_Threshold_Max_Babys")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Pain_Abortus")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Pain_GivingBirth")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Pain_LaborPains")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Pain_Mittelschmerz")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Pain_Phase_CyclePains")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Pain_Phase_PregnantPains")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Pain_PMS")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.PMS_ChanceScale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Sizes_Belly_Max")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Sizes_Belly_Max_Multiple")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Sizes_Breasts_Max")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Sizes_Breasts_Max_Multiple")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Preg1stBellyScale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Preg2ndBellyScale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Preg3rdBellyScale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Preg1stBreastsScale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Preg2ndBreastsScale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Preg3rdBreastsScale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.MultipleBabySperm")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.MultipleBabyChancePerSperm")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Baby_Healing_Scale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Baby_Damage_Scale")

		
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Duration_MaleSperm")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Sperm_Amount_Scale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Male_Recovery_Scale")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.ProbChildRaceDeterminedByFather")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.ProbChildSexDetermMale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Ignore_Contraception_Prob")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Trimester1_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Trimester2_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Trimester3_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_LaborPainsPeriod_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Recovery_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_SecondsBetweenLaborPains_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_SecondsBetweenBabySpawn_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Pain_Abortus_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Pain_GivingBirth_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Pain_LaborPains_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Preg1stBellyScale_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Preg2ndBellyScale_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Preg3rdBellyScale_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Preg1stBreastsScale_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Preg2ndBreastsScale_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Preg3rdBreastsScale_by_FatherRace")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.Allow_Impregnation_For_Any_Period")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Sperm_Impregnation_Prob_For_Any_Period")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Sperm_Impregnation_Boost")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.Allow_NTR_baby")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Sperm_NTR_baby_Prob")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Baby_Healing_Scale_by_FatherRace")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.Modify_Baby_Damage_Scale_by_FatherRace")


			StorageUtil.UnsetIntValue(a, "FW.AddOn.Female_Force_This_Baby")
			StorageUtil.FormListClear(a, "FW.AddOn.BabyActor_Female")
			StorageUtil.FormListClear(a, "FW.AddOn.BabyActor_FemalePlayer")
			StorageUtil.FormListClear(a, "FW.AddOn.BabyActor_Male")
			StorageUtil.FormListClear(a, "FW.AddOn.BabyActor_MalePlayer")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.MixWithCopyActorBase")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.ProbChildActorBorn")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.AllowPCDialogue")		
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.initialScale")
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.finalScale")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.DisableMatureTime")			
			StorageUtil.UnsetFloatValue(a, "FW.AddOn.MatureTimeScale")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.MatureStep")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.AllowUnrestrictedS")
			StorageUtil.UnsetIntValue(a, "FW.AddOn.ProtectedChildActor")
		endif
	endWhile
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Actors")
endFunction


function Clear(int type=7)
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - Clear : Clearing...")
	AddOnFolderHash=""
	if Math.LogicalAnd(type,1)==1
		ClearMiscAddOns()
	endif
	if Math.LogicalAnd(type,2)==2
		ClearRaceAddOns()
	endif
	if Math.LogicalAnd(type,4)==4
		ClearCMEAddOns()
	endif
endFunction

function ClearMiscAddOns()
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - ClearMiscAddOns : Clearing Misc AddOns...")

	Misc=new FWAddOn_Misc[128]
	sMisc=new string[128]
	bMisc=new bool[128]
	iMisc=0
endFunction

function ClearCMEAddOns()
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - ClearCMEAddOns : Clearing CME AddOns...")

	StorageUtil.FormListClear(none,"FW.AddOn.Always_FollicularPhase")
	StorageUtil.FormListClear(none,"FW.AddOn.Always_LaborPains")
	StorageUtil.FormListClear(none,"FW.AddOn.Always_LutealPhase")
	StorageUtil.FormListClear(none,"FW.AddOn.Always_Menstruation")
	StorageUtil.FormListClear(none,"FW.AddOn.Always_Ovulation")
	StorageUtil.FormListClear(none,"FW.AddOn.Always_PMS")
	StorageUtil.FormListClear(none,"FW.AddOn.Always_Recovery")
	StorageUtil.FormListClear(none,"FW.AddOn.Always_Trimester1")
	StorageUtil.FormListClear(none,"FW.AddOn.Always_Trimester2")
	StorageUtil.FormListClear(none,"FW.AddOn.Always_Trimester3")
	StorageUtil.FormListClear(none,"FW.AddOn.Sometimes_FollicularPhase")
	StorageUtil.FormListClear(none,"FW.AddOn.Sometimes_LaborPains")
	StorageUtil.FormListClear(none,"FW.AddOn.Sometimes_LutealPhase")
	StorageUtil.FormListClear(none,"FW.AddOn.Sometimes_Menstruation")
	StorageUtil.FormListClear(none,"FW.AddOn.Sometimes_Ovulation")
	StorageUtil.FormListClear(none,"FW.AddOn.Sometimes_PMS")
	StorageUtil.FormListClear(none,"FW.AddOn.Sometimes_Recovery")
	StorageUtil.FormListClear(none,"FW.AddOn.Sometimes_Trimester1")
	StorageUtil.FormListClear(none,"FW.AddOn.Sometimes_Trimester2")
	StorageUtil.FormListClear(none,"FW.AddOn.Sometimes_Trimester3")
endFunction

function ClearRaceAddOns()
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - ClearRaceAddOns : Clearing...")

	int c = StorageUtil.FormListCount(none, "FW.AddOn.Races")
	while c>0
		c-=1
		race r = StorageUtil.FormListGet(none, "FW.AddOn.Races",c) as race
		if r ;Tkc (Loverslab): optimization
			StorageUtil.SetIntValue(r,"FW.AddOn.DisablePregnancy",0)
			StorageUtil.SetFloatValue(r,"FW.AddOn.ChanceToBecomePregnantScale",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.ContraceptionDuration",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_01_Follicular",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_02_Ovulation",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_03_Luteal",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_04_Menstruation",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_05_Trimester1",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_06_Trimester2",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_07_Trimester3",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_08_Recovery",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_09_LaborPains",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_10_SecondsBetweenLaborPains",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_11_SecondsBetweenBabySpawn",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Irregulation_Chance_Scale",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Irregulation_Value_Scale",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Max_CME_EffectScale",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Multiple_Threshold_Chance",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Multiple_Threshold_Max_Babys",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Pain_Abortus",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Pain_GivingBirth",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Pain_LaborPains",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Pain_Menstruation",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Pain_Mittelschmerz",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Pain_Phase_CyclePains",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Pain_Phase_PregnantPains",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Pain_PMS",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.PMS_ChanceScale",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Sizes_Belly_Max",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Sizes_Belly_Max_Multiple",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Sizes_Breasts_Max",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Sizes_Breasts_Max_Multiple",1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Preg1stBellyScale", -1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Preg2ndBellyScale", -1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Preg3rdBellyScale", -1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Preg1stBreastsScale", -1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Preg2ndBreastsScale", -1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Preg3rdBreastsScale", -1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.MultipleBabySperm", -1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.MultipleBabyChancePerSperm", -1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Baby_Healing_Scale",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Baby_Damage_Scale",1)
			
		
			StorageUtil.SetFloatValue(r,"FW.AddOn.Duration_MaleSperm",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Sperm_Amount_Scale",1)
			StorageUtil.SetFloatValue(r,"FW.AddOn.Male_Recovery_Scale",1)
			StorageUtil.SetIntValue(r, "FW.AddOn.ProbChildRaceDeterminedByFather", -1)
			StorageUtil.SetIntValue(r, "FW.AddOn.ProbChildSexDetermMale", -1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Ignore_Contraception_Prob", -1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Trimester1_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Trimester2_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Trimester3_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_LaborPainsPeriod_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Recovery_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_SecondsBetweenLaborPains_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_SecondsBetweenBabySpawn_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Pain_Abortus_by_FatherRace", 1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Pain_GivingBirth_by_FatherRace", 1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Pain_LaborPains_by_FatherRace", 1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Preg1stBellyScale_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Preg2ndBellyScale_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Preg3rdBellyScale_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Preg1stBreastsScale_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Preg2ndBreastsScale_by_FatherRace", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Preg3rdBreastsScale_by_FatherRace", 0)
			StorageUtil.SetIntValue(r, "FW.AddOn.Allow_Impregnation_For_Any_Period", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Sperm_Impregnation_Prob_For_Any_Period", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Sperm_Impregnation_Boost", 0)
			StorageUtil.SetIntValue(r, "FW.AddOn.Allow_NTR_baby", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Sperm_NTR_baby_Prob", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Baby_Healing_Scale_by_FatherRace", 1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.Modify_Baby_Damage_Scale_by_FatherRace", 1)


			StorageUtil.SetIntValue(r,"FW.AddOn.Female_Force_This_Baby",0)
			StorageUtil.FormListClear(r,"FW.AddOn.BabyArmor_Female")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyArmor_Male")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyActor_Female")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyActor_FemalePlayer")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyActor_Male")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyActor_MalePlayer")
			StorageUtil.SetIntValue(r, "FW.AddOn.MixWithCopyActorBase", 0)
			StorageUtil.SetIntValue(r, "FW.AddOn.ProbChildActorBorn", -1)
			StorageUtil.SetIntValue(r, "FW.AddOn.AllowPCDialogue", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.initialScale", -1)
			StorageUtil.SetFloatValue(r, "FW.AddOn.finalScale", -1)
			StorageUtil.SetIntValue(r, "FW.AddOn.DisableMatureTime", 0)
			StorageUtil.SetFloatValue(r, "FW.AddOn.MatureTimeScale", -1)
			StorageUtil.SetIntValue(r, "FW.AddOn.MatureStep", -1)
			StorageUtil.SetIntValue(r, "FW.AddOn.AllowUnrestrictedS", 0)
			StorageUtil.SetIntValue(r, "FW.AddOn.ProtectedChildActor", 0)
		else;if r==none
			StorageUtil.UnsetIntValue(r,"FW.AddOn.DisablePregnancy")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.ChanceToBecomePregnantScale")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.ContraceptionDuration")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_01_Follicular")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_02_Ovulation")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_03_Luteal")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_04_Menstruation")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_05_Trimester1")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_06_Trimester2")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_07_Trimester3")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_08_Recovery")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_09_LaborPains")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_10_SecondsBetweenLaborPains")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_11_SecondsBetweenBabySpawn")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Irregulation_Chance_Scale")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Irregulation_Value_Scale")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Max_CME_EffectScale")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Multiple_Threshold_Chance")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Multiple_Threshold_Max_Babys")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Pain_Abortus")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Pain_GivingBirth")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Pain_LaborPains")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Pain_Menstruation")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Pain_Mittelschmerz")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Pain_Phase_CyclePains")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Pain_Phase_PregnantPains")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Pain_PMS")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.PMS_ChanceScale")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Sizes_Belly_Max")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Sizes_Belly_Max_Multiple")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Sizes_Breasts_Max")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Sizes_Breasts_Max_Multiple")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Preg1stBellyScale")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Preg2ndBellyScale")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Preg3rdBellyScale")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Preg1stBreastsScale")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Preg2ndBreastsScale")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Preg3rdBreastsScale")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.MultipleBabySperm")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.MultipleBabyChancePerSperm")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Baby_Healing_Scale")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Baby_Damage_Scale")


			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Duration_MaleSperm")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Sperm_Amount_Scale")
			StorageUtil.UnsetFloatValue(r,"FW.AddOn.Male_Recovery_Scale")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.ProbChildRaceDeterminedByFather")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.ProbChildSexDetermMale")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Ignore_Contraception_Prob")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Trimester1_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Trimester2_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Trimester3_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_LaborPainsPeriod_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Recovery_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_SecondsBetweenLaborPains_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_SecondsBetweenBabySpawn_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Pain_Abortus_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Pain_GivingBirth_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Pain_LaborPains_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Preg1stBellyScale_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Preg2ndBellyScale_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Preg3rdBellyScale_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Preg1stBreastsScale_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Preg2ndBreastsScale_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Preg3rdBreastsScale_by_FatherRace")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.Allow_Impregnation_For_Any_Period")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Sperm_Impregnation_Prob_For_Any_Period")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Sperm_Impregnation_Boost")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.Allow_NTR_baby")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Sperm_NTR_baby_Prob")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Baby_Healing_Scale_by_FatherRace")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.Modify_Baby_Damage_Scale_by_FatherRace")


			StorageUtil.UnsetIntValue(r,"FW.AddOn.Female_Force_This_Baby")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyArmor_Female")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyArmor_Male")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyActor_Female")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyActor_FemalePlayer")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyActor_Male")
			StorageUtil.FormListClear(r,"FW.AddOn.BabyActor_MalePlayer")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.MixWithCopyActorBase")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.ProbChildActorBorn")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.AllowPCDialogue")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.initialScale")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.finalScale")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.DisableMatureTime")
			StorageUtil.UnsetFloatValue(r, "FW.AddOn.MatureTimeScale")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.MatureStep")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.AllowUnrestrictedS")
			StorageUtil.UnsetIntValue(r, "FW.AddOn.ProtectedChildActor")
		endif
	endWhile
	StorageUtil.UnsetFloatValue(none, "FW.AddOn.Races")
endFunction


function RecastSpell2(actor a, string s)
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RecastSpell2 : Recasting...")

	if StringUtil.Substring(s,0,7)=="Always_" || StringUtil.Substring(s,0,10)=="Sometimes_"
		int i = StorageUtil.FormListCount(none,"FW.AddOn."+s)
		while i>0
			i-=1
			spell spl = StorageUtil.FormListGet(none,"FW.AddOn."+s,i ) as spell
			if a.HasSpell(spl)
				a.DispelSpell(spl)
				a.AddSpell(spl, false) ;Tkc (Loverslab): disabled spell adding notifications
			endif
		endwhile
	else
		int i = StorageUtil.FormListCount(none,"FW.AddOn.Always_"+s)
		while i>0
			i-=1
			spell spl = StorageUtil.FormListGet(none,"FW.AddOn.Always_"+s,i ) as spell
			if a.HasSpell(spl)
				a.DispelSpell(spl)
				a.AddSpell(spl, false) ;Tkc (Loverslab): disabled spell adding notifications
			endif
		endwhile
		i = StorageUtil.FormListCount(none,"FW.AddOn.Sometimes_"+s)
		while i>0
			i-=1
			spell spl = StorageUtil.FormListGet(none,"FW.AddOn.Sometimes_"+s,i ) as spell
			if a.HasSpell(spl)
				a.DispelSpell(spl)
				a.AddSpell(spl, false) ;Tkc (Loverslab): disabled spell adding notifications
			endif
		endwhile
	endif
endFunction


bool function IsAddOnActive(string AddOnName)
	bool bActive=FWUtility.getIniBool("AddOn",AddOnName+".ini","enabled",false)
	if bActive
;		string t=FWUtility.getIniString("AddOn",AddOnName+".ini","type")
		string t = FWUtility.toLower(FWUtility.getIniString("AddOn", AddOnName + ".ini", "type"))
;		if t=="Misc" || t=="misc" || t=="MISC"
		if(t == "misc")
			int c=iMisc
			while c>0
				c-=1
				if FWUtility.toLower(sMisc[c])==FWUtility.toLower(AddOnName)+".ini"
					if Misc[c] as FWAddOn_Misc;/!=none/;
						bool bAddOnActive=Misc[c].IsActive()
						return bAddOnActive
					endif
				endif
			endWhile
			return false
		endif
	endif
	return bActive
endFunction

FWAddOn_Misc function GetMiscAddOn(string AddOnName)
	int i=0
	while i<iMisc
		if Misc[i].GetName() == AddOnName
			return Misc[i]
		endif
		i+=1
	endWhile
endFunction



MiscObject function GetBabyItem(race ParentRace,int Gender)
	MiscObject m=none
	string sGender="BabyMesh_Male"
	if Gender==1
		sGender="BabyMesh_Female"
	endif
	int c=StorageUtil.FormListCount(ParentRace, "FW.AddOn."+sGender)
	if c>0
		int r=Utility.RandomInt(0,c - 1)
		m=StorageUtil.FormListGet(ParentRace, "FW.AddOn."+sGender,r) as MiscObject
		if m;/!=none/;
			return m
		endif
		while c>0
			c-=1
			m=StorageUtil.FormListGet(ParentRace, "FW.AddOn."+sGender,c) as MiscObject
			if m;/!=none/;
				return m
			endif
		endWhile
	endif
	return none
endFunction

Armor function GetBabyArmor(race ParentRace,int Gender)
	Armor m;=none ;Tkc (Loverslab): optimization
	string sGender="BabyMesh_Male"
	if Gender==1
		sGender="BabyArmor_Female"
	endif
	int c=StorageUtil.FormListCount(ParentRace, "FW.AddOn."+sGender)
	if c>0
		int r=Utility.RandomInt(0,c - 1)
		m=StorageUtil.FormListGet(ParentRace, "FW.AddOn."+sGender,r) as Armor
		if m;/!=none/;
			return m
		endif
		while c>0
			c-=1
			m=StorageUtil.FormListGet(ParentRace, "FW.AddOn."+sGender,c) as Armor
			if m;/!=none/;
				return m
			endif
		endWhile
	endif
	return none
endFunction





; state values:
; -1 = All
; 0 = Fullicular
; 1 = Ovulating
; 2 = Lutheal
; 3 = PMS
; 4 = Menstrual
; 5 = Pregnancy 1.
; 6 = Pregnancy 2.
; 7 = Pregnancy 3.
; 8 = Labor Pains
; 9 = Replanish
function removeCME(actor a, int EffectID = -1)
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - removeCME : Removing...")

	if EffectID==-1
		ActorRemoveSpellsS(a,"Always_FollicularPhase")
		ActorRemoveSpellsS(a,"Always_Ovulation")
		ActorRemoveSpellsS(a,"Always_LuthealPhase")
		ActorRemoveSpellsS(a,"Always_PMS")
		ActorRemoveSpellsS(a,"Always_Menstruation")
		ActorRemoveSpellsS(a,"Always_Trimester1")
		ActorRemoveSpellsS(a,"Always_Trimester2")
		ActorRemoveSpellsS(a,"Always_Trimester3")
		ActorRemoveSpellsS(a,"Always_LaborPains")
		ActorRemoveSpellsS(a,"Always_Recovery")
		
		ActorRemoveSpellsS(a,"Sometimes_FollicularPhase")
		ActorRemoveSpellsS(a,"Sometimes_Ovulation")
		ActorRemoveSpellsS(a,"Sometimes_LuthealPhase")
		ActorRemoveSpellsS(a,"Sometimes_PMS")
		ActorRemoveSpellsS(a,"Sometimes_Menstruation")
		ActorRemoveSpellsS(a,"Sometimes_Trimester1")
		ActorRemoveSpellsS(a,"Sometimes_Trimester2")
		ActorRemoveSpellsS(a,"Sometimes_Trimester3")
		ActorRemoveSpellsS(a,"Sometimes_LaborPains")
		ActorRemoveSpellsS(a,"Sometimes_Recovery")
	elseif EffectID==0
		ActorRemoveSpellsS(a,"Always_FollicularPhase")
		ActorRemoveSpellsS(a,"Sometimes_FollicularPhase")
	elseif EffectID==1
		ActorRemoveSpellsS(a,"Always_Ovulation")
		ActorRemoveSpellsS(a,"Sometimes_Ovulation")
	elseif EffectID==2
		ActorRemoveSpellsS(a,"Always_LuthealPhase")
		ActorRemoveSpellsS(a,"Sometimes_LuthealPhase")
	elseif EffectID==3
		ActorRemoveSpellsS(a,"Always_PMS")
		ActorRemoveSpellsS(a,"Sometimes_PMS")
	elseif EffectID==4
		ActorRemoveSpellsS(a,"Always_Menstruation")
		ActorRemoveSpellsS(a,"Sometimes_Menstruation")
	elseif EffectID==5
		ActorRemoveSpellsS(a,"Always_Trimester1")
		ActorRemoveSpellsS(a,"Sometimes_Trimester1")
	elseif EffectID==6
		ActorRemoveSpellsS(a,"Always_Trimester2")
		ActorRemoveSpellsS(a,"Sometimes_Trimester2")
	elseif EffectID==7
		ActorRemoveSpellsS(a,"Always_Trimester3")
		ActorRemoveSpellsS(a,"Sometimes_Trimester3")
	elseif EffectID==8
		ActorRemoveSpellsS(a,"Always_LaborPains")
		ActorRemoveSpellsS(a,"Sometimes_LaborPains")
	elseif EffectID==9
		ActorRemoveSpellsS(a,"Always_Recovery")
		ActorRemoveSpellsS(a,"Sometimes_Recovery")
	endif
endFunction

function castCME(actor a, int EffectID, int NumEffects)
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - castCME : Casting...")

	if EffectID==0
		FWUtility.ActorAddSpellsS(a,"Always_FollicularPhase");
	elseif EffectID==1
		FWUtility.ActorAddSpellsS(a,"Always_Ovulation");
	elseif EffectID==2
		FWUtility.ActorAddSpellsS(a,"Always_LuthealPhase");
	elseif EffectID==3
		FWUtility.ActorAddSpellsS(a,"Always_PMS");
	elseif EffectID==4
		FWUtility.ActorAddSpellsS(a,"Always_Menstruation");
	elseif EffectID==5
		FWUtility.ActorAddSpellsS(a,"Always_Trimester1");
	elseif EffectID==6
		FWUtility.ActorAddSpellsS(a,"Always_Trimester2");
	elseif EffectID==7
		FWUtility.ActorAddSpellsS(a,"Always_Trimester3");
	elseif EffectID==8
		FWUtility.ActorAddSpellsS(a,"Always_LaborPains");
	elseif EffectID==9
		FWUtility.ActorAddSpellsS(a,"Always_Recovery");
	endIf
	castCMEEffect(a, EffectID, NumEffects)
endFunction



; EffectID	State
;  0		FollicularPhase
;  1		Ovulation
;  2		LuthealPhase
;  3		PMS
;  4		Menstruation
;  5		Trimester1
;  6		Trimester2
;  7		Trimester3
;  8		LaborPains
;  9		Recovery
function castCMEEffect(Actor akActor,int EffectID, int MaxEffectNumber)
	Debug.Trace("[Beeing Female NG] - FWAddOnManager - castCMEEffect : Casting...")

	if akActor ;Tkc (Loverslab): optimization
	else;if akActor == none
		return
	endif
	float maxEffects=Utility.RandomInt(1, MaxEffectNumber)
	; Check racial maximum PMS Effects
	race RaceID = akActor.GetLeveledActorBase().GetRace()
	maxEffects*=StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Max_CME_EffectsScale",1.0)
	if maxEffects<=0
		maxEffects=1
	endIf
	
	string sName=""
	if EffectID==0
		sName="Follicular"
	elseif EffectID==1
		sName="Ovulation"
	elseif EffectID==2
		sName="LuthealPhase"
	elseif EffectID==3
		sName="PMS"
	elseif EffectID==4
		sName="Menstruation"
	elseif EffectID==5
		sName="Trimester1"
	elseif EffectID==6
		sName="Trimester2"
	elseif EffectID==7
		sName="Trimester3"
	elseif EffectID==8
		sName="LaborPains"
	elseif EffectID==9
		sName="Recovery"
	endif
	
	if sName;/!=""/; ;Tkc (Loverslab): optimization
		int cmeCount = StorageUtil.FormListCount(none,"FW.AddOn.Sometimes_"+sName)
		if cmeCount>0
			if maxEffects>=cmeCount
			; there are more effects available then needed. pick random one
				while maxEffects>0
					maxEffects-=1
					int sID=Utility.RandomInt(0,cmeCount - 1)
					spell spl = StorageUtil.FormListGet(none,"FW.AddOn.Sometimes_"+sName,sID) as spell
					if spl;/!=none/;
						System.ActorAddSpellOpt(akActor,spl, False, False, False) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
					endif
				endWhile
			else
			; There are less or equals effects available. cast all spells
				int iMaxEffects=Math.Ceiling(maxEffects)
				while iMaxEffects>0
					iMaxEffects-=1
					spell spl = StorageUtil.FormListGet(none,"FW.AddOn.Sometimes_"+sName,iMaxEffects) as spell
					if spl;/!=none/;
						System.ActorAddSpellOpt(akActor,spl, False, False, False) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
					endif
				endWhile
			endif
		endif
	endif
endFunction


; Get Is canBecomePregnant is Enabled
bool function ActorCanBecomePregnant(actor a)
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		bool myResult = (StorageUtil.GetIntValue(a, "FW.AddOn.DisablePregnancy", 0) == 0)
		if(myResult)
			race abr = a.GetRace()
			if abr
				myResult = RaceCanBecomePregnant(abr)
				Debug.Trace("[Beeing Female NG] - FWAddONManager - ActorCanBecomePregnant : the actor " + a + " can become pregnant? = " + myResult)
			endIf
		endIf
		return myResult
	endIf
	return false
endfunction
bool function RaceCanBecomePregnant(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceCanBecomePregnant : Race = " + RaceID + ". ChanceToBecomePregnantScale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.ChanceToBecomePregnantScale",1.0))

	;WaitRaces()
;	return StorageUtil.GetFloatValue(RaceID,"FW.AddOn.DisablePregnancy",0)==0
	bool myResult = (StorageUtil.GetIntValue(RaceID, "FW.AddOn.DisablePregnancy", 0) == 0)
	if(myResult)
		myResult = (StorageUtil.GetIntValue(none, "FW.AddOn.Global_DisablePregnancy", 0) == 0)
	endIf

	return myResult
endfunction


; Get the "BecomePregnant" Chance
float function PregnancyChanceActorScale(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.ChanceToBecomePregnantScale", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = PregnancyChanceRaceScale(abr)
			endIf
		endIf
	endIf
	if result < 0.1
		return 0.1
	else
		return result
	endif
endfunction
float function PregnancyChanceRaceScale(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - PregnancyChanceRaceScale : Race = " + RaceID + ". ChanceToBecomePregnantScale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.ChanceToBecomePregnantScale",1.0))

	float result = 1.0;
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.ChanceToBecomePregnantScale", 1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_ChanceToBecomePregnantScale", 1.0)
	endIf
	
	if result < 0.1
		return 0.1
	else
		return result
	endif
endfunction


; Get ContraceptionDuration
float function getActorContraceptionDuration(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.ContraceptionDuration", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = getRaceContraceptionDuration(abr)
			endIf
		endIf
	endIf
	if result < 1.0
		return 1.0 ; return at least 1 Day
	elseif result > 8.0
		return 8.0 ; return a maximum of 8 Days
	else
		return result
	endIf
endFunction
float function getRaceContraceptionDuration(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceContraceptionDuration : Race = " + RaceID + ". ContraceptionDuration = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.ContraceptionDuration",1.0))

	float result = 1.0
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.ContraceptionDuration", 1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_ContraceptionDuration", 1.0)
	endIf
	
	if result < 1.0
		return 1.0 ; return at least 1 Day
	elseif result > 8.0
		return 8.0 ; return a maximum of 8 Days
	else
		return result
	endIf
endFunction


; Alias for getRaceDurationScale - but with Actor-Argument
float function getActorDurationScale(int Step, Actor a)
	float result = 1.0
	race abr = none
	
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		if(Step >= 0)
			if(Step < 8)
				if(Step < 4)
					if(Step < 2)
						if(Step == 0)
							result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_01_Follicular", -1)
							if(result < 0)
								abr = a.GetRace()
								result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Duration_01_Follicular", -1)
								if(result < 0)
									result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_01_Follicular", 1.0)
								endIf
							endIf
						else;if Step==1
							result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_02_Ovulation", -1)
							if(result < 0)
								abr = a.GetRace()
								result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Duration_02_Ovulation", -1)
								if(result < 0)
									result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_02_Ovulation", 1.0)
								endIf
							endIf
						endIf
					else
						if(Step == 2)
							result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_03_Luteal", 1.0)
							if(result == 1.0)
								abr = a.GetRace()
								result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Duration_03_Luteal", 1.0)
								if(result == 1.0)
									result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_03_Luteal", 1.0)
								endIf
							endIf
						else;if Step==3
							result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_04_Menstruation", 1.0)
							if(result == 1.0)
								abr = a.GetRace()
								result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Duration_04_Menstruation", 1.0)
								if(result == 1.0)
									result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_04_Menstruation", 1.0)
								endIf
							endIf
						endIf
					endIf
				else
					if(Step < 6)
						if(Step == 4)
							result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_05_Trimester1", 1.0)
							if(result == 1.0)
								abr = a.GetRace()
								result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Duration_05_Trimester1", 1.0)
								if(result == 1.0)
									result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_05_Trimester1", 1.0)
								endIf
							endIf
						else;if Step==5
							result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_06_Trimester2", 1.0)	
							if(result == 1.0)
								abr = a.GetRace()
								result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Duration_06_Trimester2", 1.0)	
								if(result == 1.0)
									result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_06_Trimester2", 1.0)	
								endIf
							endIf
						endIf
					else
						if(Step == 6)
							result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_07_Trimester3", 1.0)
							if(result == 1.0)
								abr = a.GetRace()
								result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Duration_07_Trimester3", 1.0)
								if(result == 1.0)
									result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_07_Trimester3", 1.0)
								endIf
							endIf
						else
							result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_09_LaborPains", 1.0)
							if(result == 1.0)
								abr = a.GetRace()
								result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Duration_09_LaborPains", 1.0)
								if(result == 1.0)
									result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_09_LaborPains", 1.0)
								endIf
							endIf
						endIf
					endIf
				endIf
			else
				if(Step == 8)
					result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_08_Recovery", 1.0)
					if(result == 1.0)
						abr = a.GetRace()
						result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Duration_08_Recovery", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_08_Recovery", 1.0)
						endIf
					endIf
				else
					return result
				endIf
			endIf
		else
			return result
		endIf
	endIf
	if result < 0.2
		return 0.2 ; return at least 20%
	else
		return result
	endIf
endFunction
; Deprecated
float function getRaceDurationScale(int Step, race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDurationScale : Race = " + RaceID + ". Duration_01_Follicular = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_01_Follicular",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDurationScale : Race = " + RaceID + ". Duration_02_Ovulation = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_02_Ovulation",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDurationScale : Race = " + RaceID + ". Duration_03_Luteal = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_03_Luteal",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDurationScale : Race = " + RaceID + ". Duration_04_Menstruation = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_04_Menstruation",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDurationScale : Race = " + RaceID + ". Duration_05_Trimester1 = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_05_Trimester1",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDurationScale : Race = " + RaceID + ". Duration_06_Trimester2 = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_06_Trimester2",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDurationScale : Race = " + RaceID + ". Duration_07_Trimester3 = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_07_Trimester3",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDurationScale : Race = " + RaceID + ". Duration_08_Recovery = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_08_Recovery",1.0))

;	if Step==7 ; Labor Pain is fixed
;		return result
;	endif
	;WaitRaces()
	float result = 1.0
	
	if(Step >= 0)
		if(Step < 8)
			if(Step < 4)
				if(Step < 2)
					if(Step == 0)
						result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Duration_01_Follicular", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_01_Follicular", 1.0)
						endIf
					else;if Step==1
						result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Duration_02_Ovulation", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_02_Ovulation", 1.0)
						endIf
					endIf
				else
					if(Step == 2)
						result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Duration_03_Luteal", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_03_Luteal", 1.0)
						endIf
					else;if Step==3
						result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Duration_04_Menstruation", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_04_Menstruation", 1.0)
						endIf
					endIf
				endIf
			else
				if(Step < 6)
					if(Step == 4)
						result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Duration_05_Trimester1", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_05_Trimester1", 1.0)
						endIf
					else;if Step==5
						result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Duration_06_Trimester2", 1.0)	
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_06_Trimester2", 1.0)	
						endIf
					endIf
				else
					if(Step == 6)
						result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Duration_07_Trimester3", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_07_Trimester3", 1.0)
						endIf
					else;if(Step == 7)
						result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Duration_09_LaborPains", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_09_LaborPains", 1.0)
						endIf
					endIf
				endIf
			endIf
		else
			if(Step == 8)
				result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Duration_08_Recovery", 1.0)
				if(result == 1.0)
					result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_08_Recovery", 1.0)
				endIf
			else
				return result
			endIf
		endIf
	else
		return result
	endIf
	
;	if Step==0
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_01_Follicular",1.0)
;	elseif Step==1
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_02_Ovulation",1.0)
;	elseif Step==2
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_03_Luteal",1.0)
;	elseif Step==3
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_04_Menstruation",1.0)
;	elseif Step==4
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_05_Trimester1",1.0)
;	elseif Step==5
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_06_Trimester2",1.0)
;	elseif Step==6
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_07_Trimester3",1.0)
;	elseif Step==8
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_08_Recovery",1.0)
;	endIf
	if result < 0.2
		return 0.2 ; return at least 20%
	else
		return result
	endIf
endFunction


float function getActorDurationScaleLaborPains(actor a)
	float result = 1.0
	race abr = none
	
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_09_LaborPains", 1.0)
		if(result == 1.0)
			abr = a.GetRace()
			result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Duration_09_LaborPains", 1.0)
			if(result == 1.0)
				result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_09_LaborPains", 1.0)
			endIf
		endIf
	endIf
	if result < (2.0 / 24.0)
		return (2.0 / 24.0)
	elseif result > 1.0
		return 1.0
	else
		return result
	endIf
endFunction
; Deprecated
float function getRaceDurationScaleLaborPains(race RaceID)
	float result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Duration_09_LaborPains", 1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_09_LaborPains", 1.0)
	endIf
	return result
endFunction


; Get Duration_BetweenLaborPains
float function getActorDuration_BetweenLaborPains(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_10_SecondsBetweenLaborPains", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = getRaceDuration_BetweenLaborPains(abr)
			endIf
		endIf
	endIf
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endIf
endFunction
float function getRaceDuration_BetweenLaborPains(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDuration_BetweenLaborPains : Race = " + RaceID + ". Duration_10_SecondsBetweenLaborPains = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_10_SecondsBetweenLaborPains",1.0))

	float result = 1.0
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_10_SecondsBetweenLaborPains",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_10_SecondsBetweenLaborPains", 1.0)
	endIf
	
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endIf
endFunction


; Get Duration_BabySpawn
float function getActorDuration_BabySpawn(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_11_SecondsBetweenBabySpawn", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = getRaceDuration_BabySpawn(abr)
			endIf
		endIf
	endIf
	
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endIf
endFunction
float function getRaceDuration_BabySpawn(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDuration_BabySpawn : Race = " + RaceID + ". Duration_11_SecondsBetweenBabySpawn = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_11_SecondsBetweenBabySpawn",1.0))

	float result = 1.0
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_11_SecondsBetweenBabySpawn",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_11_SecondsBetweenBabySpawn", 1.0)
	endIf
	
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endIf
endFunction


; Get IrregulationChance
float function IrregulationChance(actor woman, int state_number)
;	int i=0
	float result = 1.0;
	if(woman)
		;actorbase ab = woman.GetLeveledActorBase()
		;if(ab)
		
		result = StorageUtil.GetFloatValue(woman, "FW.AddOn.Irregulation_Chance_Scale", 1.0)
		if(result == 1.0)
			;race RaceID = ab.GetRace()
			
			race RaceID = woman.GetRace()
			if(RaceID)
				result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Irregulation_Chance_Scale", 1.0)
				if(result == 1.0)
					result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Irregulation_Chance_Scale", 1.0)
				endIf
			endIf
		endIf
	endIf

;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - IrregulationChance : Race = " + RaceID + ". Irregulation_Chance_Scale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Irregulation_Chance_Scale",1.0))

	if result < 0.1
		return 0.1
	else
		return result
	endif
endFunction


; Get IrregulationValue
float function IrregulationValue(actor woman, int state_number)
;	int i=0
	float result = 1.0;
	if(woman)
		;actorbase ab = woman.GetLeveledActorBase()
		;if(ab)
		
		result = StorageUtil.GetFloatValue(woman, "FW.AddOn.Irregulation_Value_Scale", 1.0)
		if(result == 1.0)
			;race RaceID = ab.GetRace()
			
			race RaceID = woman.GetRace()
			if(RaceID)
				result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Irregulation_Value_Scale", 1.0)
				if(result == 1.0)
					result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Irregulation_Value_Scale", 1.0)
				endIf
			endIf
		endIf
	endIf

;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - IrregulationValue : Race = " + RaceID + ". Irregulation_Value_Scale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Irregulation_Value_Scale",1.0))

	if result < 0.1
		return 0.1
	else
		return result
	endif
endFunction


; Get the multiple threshold chance
float function ActorMaxChance(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Multiple_Threshold_Chance", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = RaceMaxChance(abr)
			endIf
		endIf
	endIf
	if result < 0.1
		return 0.1
	else
		return result
	endif
endfunction
float function RaceMaxChance(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceMaxChance : Race = " + RaceID + ". Multiple_Threshold_Chance = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Multiple_Threshold_Chance",1.0))

	float result = 1.0;
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Multiple_Threshold_Chance",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Multiple_Threshold_Chance", 1.0)
	endIf
	
	if result < 0.1
		return 0.1
	else
		return result
	endif
endfunction


; Get Max Baby count on multiple threshold
float function ActorMaxBabse(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Multiple_Threshold_Max_Babys", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = RaceMaxBabse(abr)
			endIf
		endIf
	endIf
	if result < 0.1
		return 0.1
	else
		return result
	endif
endfunction
float function RaceMaxBabse(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceMaxBabse : Race = " + RaceID + ". Multiple_Threshold_Max_Babys = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Multiple_Threshold_Max_Babys",1.0))

	float result = 1.0;
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Multiple_Threshold_Max_Babys",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Multiple_Threshold_Max_Babys", 1.0)
	endIf
	
	if result < 0.1
		return 0.1
	else
		return result
	endif
endfunction


; DamageType Argument:
; 	0 = Mittelschmerz
; 	1 = Menstruation
; 	2 = PMS pains
; 	3 = Labor Pains
; 	4 = Giving Birth
;	5 = Aborts
float function getActorDamageScale(int DamageType, actor a)
	float result = 1.0
	float myMulti = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		race abr = a.GetRace()

		if(DamageType >= 0)
			if(DamageType < 3)
				if(DamageType < 2)
					result = StorageUtil.GetFloatValue(a, "FW.AddOn.Pain_Mittelschmerz", 1.0)
					if(result == 1.0)
						result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Pain_Mittelschmerz", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_Mittelschmerz", 1.0)
						endIf
					endIf
				else;if(DamageType == 2)
					result = StorageUtil.GetFloatValue(a, "FW.AddOn.Pain_PMS", 1.0)
					if(result == 1.0)
						result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Pain_PMS", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_PMS", 1.0)
						endIf
					endIf
				endIf
				
				myMulti = StorageUtil.GetFloatValue(a, "FW.AddOn.Pain_Phase_CyclePains", 1.0)
				if(myMulti == 1.0)
					myMulti = StorageUtil.GetFloatValue(abr, "FW.AddOn.Pain_Phase_CyclePains", 1.0)
					if(myMulti == 1.0)
						myMulti = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_Phase_CyclePains", 1.0)
					endIf
				endIf
			elseif(DamageType < 6)
				if(DamageType < 5)
					if DamageType==3
						result = StorageUtil.GetFloatValue(a, "FW.AddOn.Pain_LaborPains", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Pain_LaborPains", 1.0)
							if(result == 1.0)
								result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_LaborPains", 1.0)
							endIf
						endIf
					else;if(DamageType == 4)
						result = StorageUtil.GetFloatValue(a, "FW.AddOn.Pain_GivingBirth", 1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Pain_GivingBirth", 1.0)
							if(result == 1.0)
								result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_GivingBirth", 1.0)
							endIf
						endIf
					endIf
				else;if DamageType==5
					result = StorageUtil.GetFloatValue(a, "FW.AddOn.Pain_Abortus", 1.0)
					if(result == 1.0)
						result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Pain_Abortus",1.0)
						if(result == 1.0)
							result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_Abortus",1.0)
						endIf
					endIf
				endIf
				
				myMulti = StorageUtil.GetFloatValue(a, "FW.AddOn.Pain_Phase_PregnantPains", 1.0)
				if(myMulti == 1.0)
					myMulti = StorageUtil.GetFloatValue(abr, "FW.AddOn.Pain_Phase_PregnantPains", 1.0)
					if(myMulti == 1.0)
						myMulti = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_Phase_PregnantPains", 1.0)
					endIf
				endIf
			endIf
		endIf
	endIf
	result *= myMulti
	
	if result < 0.05
		return 0.05
	else
		return result
	endif
endFunction
; Deprecated
float function getRaceDamageScale(int DamageType, race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDamageScale : Race = " + RaceID + ". Pain_Mittelschmerz = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Mittelschmerz",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDamageScale : Race = " + RaceID + ". Pain_Phase_CyclePains = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Phase_CyclePains",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDamageScale : Race = " + RaceID + ". Pain_PMS = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_PMS",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDamageScale : Race = " + RaceID + ". Pain_LaborPains = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_LaborPains",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDamageScale : Race = " + RaceID + ". Pain_Phase_PregnantPains = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Phase_PregnantPains",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDamageScale : Race = " + RaceID + ". Pain_GivingBirthPain_PMS = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_GivingBirthPain_PMS",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - getRaceDamageScale : Race = " + RaceID + ". Pain_Abortus = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Abortus",1.0))

	float result = 1.0
	float myMulti = 1.0
	if(DamageType >= 0)
		if(DamageType < 3)
			if(DamageType < 2)
				result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Pain_Mittelschmerz", 1.0)
				if(result == 1.0)
					result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_Mittelschmerz", 1.0)
				endIf
			else;if(DamageType == 2)
				result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Pain_PMS", 1.0)
				if(result == 1.0)
					result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_PMS", 1.0)
				endIf
			endIf
			
			myMulti = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Pain_Phase_CyclePains", 1.0)
			if(myMulti == 1.0)
				myMulti = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_Phase_CyclePains", 1.0)
			endIf
		elseif(DamageType < 6)
			if(DamageType < 5)
				if DamageType==3
					result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Pain_LaborPains", 1.0)
					if(result == 1.0)
						result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_LaborPains", 1.0)
					endIf
				else;if(DamageType == 4)
					result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Pain_GivingBirth", 1.0)
					if(result == 1.0)
						result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_GivingBirth", 1.0)
					endIf
				endIf
			else;if DamageType==5
				result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Pain_Abortus",1.0)
				if(result == 1.0)
					result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_Abortus",1.0)
				endIf
			endIf
			
			myMulti = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.Pain_Phase_PregnantPains", 1.0)
			if(myMulti == 1.0)
				myMulti = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Pain_Phase_PregnantPains", 1.0)
			endIf
		endIf
	endIf
	
;	if DamageType == 0
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Mittelschmerz",1.0)
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Phase_CyclePains",1.0)
;	elseif DamageType==1
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Mittelschmerz",1.0)
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Phase_CyclePains",1.0)
;	elseif DamageType==2
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_PMS",1.0)
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Phase_CyclePains",1.0)
;	elseif DamageType==3
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_LaborPains",1.0)
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Phase_PregnantPains",1.0)
;	elseif DamageType==4
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_GivingBirth",1.0)
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Phase_PregnantPains",1.0)
;	elseif DamageType==5
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Abortus",1.0)
;		result *= StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Pain_Phase_PregnantPains",1.0)
;	endIf
	result *= myMulti
	
	if result <0.05
		return 0.05 ; Return at least 5%
	else
		return result
	endif
endFunction


; Get the PMS Chance
float function PMSChanceActorScale(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.PMS_ChanceScale", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = PMSChanceRaceScale(abr)
			endIf
		endIf
	endIf
	
	if result < 0.1
		return 0.1
	else
		return result
	endif
endfunction
float function PMSChanceRaceScale(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - PMSChanceRaceScale : Race = " + RaceID + ". PMS_ChanceScale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.PMS_ChanceScale",1.0))

	float result = 1.0;
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.PMS_ChanceScale",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_PMS_ChanceScale", 1.0)
	endIf
	
	if result < 0.1
		return 0.1
	else
		return result
	endif
endfunction


; Get the Size Scaler
; Type Argument
; 0 = Belly Scaling
; 1 = Brest Scaling
; 2 = +Belly Scaling (on multiple threshold)
; 3 = +Brest Scaling (on multiple threshold)
float function ActorSizeScaler(int Type, actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		race abr = a.GetRace()

		if Type < 2
			if Type==0
				result = StorageUtil.GetFloatValue(a, "FW.AddOn.Sizes_Belly_Max", 1.0)
				if(result == 1.0)
					result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Sizes_Belly_Max", 1.0)
					if(result == 1.0)
						result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Sizes_Belly_Max", 1.0)
					endIf
				endIf
			else;if Type==1
				result = StorageUtil.GetFloatValue(a, "FW.AddOn.Sizes_Breasts_Max", 1.0)
				if(result == 1.0)
					result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Sizes_Breasts_Max", 1.0)
					if(result == 1.0)
						result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Sizes_Breasts_Max", 1.0)
					endIf
				endIf
			endIf
		else
			if Type==2
				result = StorageUtil.GetFloatValue(a, "FW.AddOn.Sizes_Belly_Max_Multiple", 1.0)
				if(result == 1.0)
					result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Sizes_Belly_Max_Multiple", 1.0)
					if(result == 1.0)
						result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Sizes_Belly_Max_Multiple", 1.0)
					endIf
				endIf
			else;if Type==3
				result = StorageUtil.GetFloatValue(a, "FW.AddOn.Sizes_Breasts_Max_Multiple", 1.0)
				if(result == 1.0)
					result = StorageUtil.GetFloatValue(abr, "FW.AddOn.Sizes_Breasts_Max_Multiple", 1.0)
					if(result == 1.0)
						result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Sizes_Breasts_Max_Multiple", 1.0)
					endIf
				endIf
			endIf
		endIf
	endIf
	if result < 0.1
		return 0.1
	else
		return result
	endif
endfunction
; Deprecated
float function RaceSizeScaler(int Type, race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceSizeScaler : Race = " + RaceID + ". Sizes_Belly_Max = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Sizes_Belly_Max",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceSizeScaler : Race = " + RaceID + ". Sizes_Breasts_Max = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Sizes_Breasts_Max",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceSizeScaler : Race = " + RaceID + ". Sizes_Belly_Max_Multiple = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Sizes_Belly_Max_Multiple",1.0))
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceSizeScaler : Race = " + RaceID + ". Sizes_Breasts_Max_Multiple = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Sizes_Breasts_Max_Multiple",1.0))

	float result = 1.0;
	if Type < 2
		if Type==0
			result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Sizes_Belly_Max",1.0)
			if(result == 1.0)
				result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Sizes_Belly_Max", 1.0)
			endIf
		else;if Type==1
			result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Sizes_Breasts_Max",1.0)
			if(result == 1.0)
				result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Sizes_Breasts_Max", 1.0)
			endIf
		endIf
	else
		if Type==2
			result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Sizes_Belly_Max_Multiple",1.0)
			if(result == 1.0)
				result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Sizes_Belly_Max_Multiple", 1.0)
			endIf
		else;if Type==3
			result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Sizes_Breasts_Max_Multiple",1.0)
			if(result == 1.0)
				result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Sizes_Breasts_Max_Multiple", 1.0)
			endIf
		endIf
	endIf
	if result < 0.1
		return 0.1
	else
		return result
	endif
endfunction


; Get Preg1stBellyScale
float Function ActorPreg1stBellyScale(actor a)
	float myPreg1stBellyScale = -1
	if a
		myPreg1stBellyScale = StorageUtil.GetFloatValue(a, "FW.AddOn.Preg1stBellyScale", -1)
		if(myPreg1stBellyScale <= 0)
			race abr = a.GetRace()
			if abr
				myPreg1stBellyScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.Preg1stBellyScale", -1)
				if(myPreg1stBellyScale <= 0)
					myPreg1stBellyScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Preg1stBellyScale", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myPreg1stBellyScale > 0
		Debug.Trace("FWAddOnManager - ActorPreg1stBellyScale = " + myPreg1stBellyScale + " for actor " + a)
		return myPreg1stBellyScale
	else	; must be positive
		Debug.Trace("FWAddOnManager - ActorPreg1stBellyScale will follow the MCM settings for actor " + a)
		return System.GetPhaseScale(0, 0)
	endIf
endFunction


; Get Preg2ndBellyScale
float Function ActorPreg2ndBellyScale(actor a)
	float myPreg2ndBellyScale = -1
	if a
		myPreg2ndBellyScale = StorageUtil.GetFloatValue(a, "FW.AddOn.Preg2ndBellyScale", -1)
		if(myPreg2ndBellyScale <= 0)
			race abr = a.GetRace()
			if abr
				myPreg2ndBellyScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.Preg2ndBellyScale", -1)
				if(myPreg2ndBellyScale <= 0)
					myPreg2ndBellyScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Preg2ndBellyScale", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myPreg2ndBellyScale > 0
		Debug.Trace("FWAddOnManager - ActorPreg2ndBellyScale = " + myPreg2ndBellyScale + " for actor " + a)
		return myPreg2ndBellyScale
	else	; must be positive
		Debug.Trace("FWAddOnManager - ActorPreg2ndBellyScale will follow the MCM settings for actor " + a)
		return System.GetPhaseScale(0, 1)
	endIf
endFunction


; Get Preg3rdBellyScale
float Function ActorPreg3rdBellyScale(actor a)
	float myPreg3rdBellyScale = -1
	if a
		myPreg3rdBellyScale = StorageUtil.GetFloatValue(a, "FW.AddOn.Preg3rdBellyScale", -1)
		if(myPreg3rdBellyScale <= 0)
			race abr = a.GetRace()
			if abr
				myPreg3rdBellyScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.Preg3rdBellyScale", -1)
				if(myPreg3rdBellyScale <= 0)
					myPreg3rdBellyScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Preg3rdBellyScale", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myPreg3rdBellyScale > 0
		Debug.Trace("FWAddOnManager - ActorPreg3rdBellyScale = " + myPreg3rdBellyScale + " for actor " + a)
		return myPreg3rdBellyScale
	else	; must be positive
		Debug.Trace("FWAddOnManager - ActorPreg3rdBellyScale will follow the MCM settings for actor " + a)
		return System.GetPhaseScale(0, 2)
	endIf
endFunction


; Get Preg1stBreastsScale
float Function ActorPreg1stBreastsScale(actor a)
	float myPreg1stBreastsScale = -1
	if a
		myPreg1stBreastsScale = StorageUtil.GetFloatValue(a, "FW.AddOn.Preg1stBreastsScale", -1)
		if(myPreg1stBreastsScale <= 0)
			race abr = a.GetRace()
			if abr
				myPreg1stBreastsScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.Preg1stBreastsScale", -1)
				if(myPreg1stBreastsScale <= 0)
					myPreg1stBreastsScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Preg1stBreastsScale", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myPreg1stBreastsScale > 0
		Debug.Trace("FWAddOnManager - ActorPreg1stBreastsScale = " + myPreg1stBreastsScale + " for actor " + a)
		return myPreg1stBreastsScale
	else	; must be positive
		Debug.Trace("FWAddOnManager - ActorPreg1stBreastsScale will follow the MCM settings for actor " + a)
		return System.GetPhaseScale(1, 0)
	endIf
endFunction


; Get Preg2ndBreastsScale
float Function ActorPreg2ndBreastsScale(actor a)
	float myPreg2ndBreastsScale = -1
	if a
		myPreg2ndBreastsScale = StorageUtil.GetFloatValue(a, "FW.AddOn.Preg2ndBreastsScale", -1)
		if(myPreg2ndBreastsScale <= 0)
			race abr = a.GetRace()
			if abr
				myPreg2ndBreastsScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.Preg2ndBreastsScale", -1)
				if(myPreg2ndBreastsScale <= 0)
					myPreg2ndBreastsScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Preg2ndBreastsScale", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myPreg2ndBreastsScale > 0
		Debug.Trace("FWAddOnManager - ActorPreg2ndBreastsScale = " + myPreg2ndBreastsScale + " for actor " + a)
		return myPreg2ndBreastsScale
	else	; must be positive
		Debug.Trace("FWAddOnManager - ActorPreg2ndBreastsScale will follow the MCM settings for actor " + a)
		return System.GetPhaseScale(1, 1)
	endIf
endFunction


; Get Preg3rdBreastsScale
float Function ActorPreg3rdBreastsScale(actor a)
	float myPreg3rdBreastsScale = -1
	if a
		myPreg3rdBreastsScale = StorageUtil.GetFloatValue(a, "FW.AddOn.Preg3rdBreastsScale", -1)
		if(myPreg3rdBreastsScale <= 0)
			race abr = a.GetRace()
			if abr
				myPreg3rdBreastsScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.Preg3rdBreastsScale", -1)
				if(myPreg3rdBreastsScale <= 0)
					myPreg3rdBreastsScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Preg3rdBreastsScale", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myPreg3rdBreastsScale > 0
		Debug.Trace("FWAddOnManager - ActorPreg3rdBreastsScale = " + myPreg3rdBreastsScale + " for actor " + a)
		return myPreg3rdBreastsScale
	else	; must be positive
		Debug.Trace("FWAddOnManager - ActorPreg3rdBreastsScale will follow the MCM settings for actor " + a)
		return System.GetPhaseScale(1, 2)
	endIf
endFunction


; Get MultipleBabySperm
float Function ActorMultipleBabySperm(actor a)
	float myMultipleBabySperm = -1
	if a
		myMultipleBabySperm = StorageUtil.GetFloatValue(a, "FW.AddOn.MultipleBabySperm", -1)
		if(myMultipleBabySperm <= 0)
			race abr = a.GetRace()
			if abr
				myMultipleBabySperm = StorageUtil.GetFloatValue(abr, "FW.AddOn.MultipleBabySperm", -1)
				if(myMultipleBabySperm <= 0)
					Debug.Trace("[Beeing Female NG] - FWAddOnManager - ActorMultipleBabySperm: Failed to get race specific MultipleBabySperm for actor " + a + ", thus loading Global_MultipleBabySperm...")
					myMultipleBabySperm = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_MultipleBabySperm", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myMultipleBabySperm > 0
		Debug.Trace("FWAddOnManager - ActorMultipleBabySperm = " + myMultipleBabySperm + " for actor " + a)
		return myMultipleBabySperm
	else	; must be positive
		Debug.Trace("FWAddOnManager - ActorMultipleBabySperm is not defined for actor " + a)
		return -1
	endIf
endFunction


; Get MultipleBabyChancePerSperm
float Function ActorMultipleBabyChancePerSperm(actor a)
	float myMultipleBabyChancePerSperm = -1
	if a
		myMultipleBabyChancePerSperm = StorageUtil.GetFloatValue(a, "FW.AddOn.MultipleBabyChancePerSperm", -1)
		if(myMultipleBabyChancePerSperm <= 0)
			race abr = a.GetRace()
			if abr
				myMultipleBabyChancePerSperm = StorageUtil.GetFloatValue(abr, "FW.AddOn.MultipleBabyChancePerSperm", -1)
				if(myMultipleBabyChancePerSperm <= 0)
					Debug.Trace("[Beeing Female NG] - FWAddOnManager - ActorMultipleBabyChancePerSperm: Failed to get race specific MultipleBabyChancePerSperm for actor " + a + ", thus loading Global_MultipleBabyChancePerSperm...")
					myMultipleBabyChancePerSperm = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_MultipleBabyChancePerSperm", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myMultipleBabyChancePerSperm > 0
		Debug.Trace("FWAddOnManager - ActorMultipleBabyChancePerSperm = " + myMultipleBabyChancePerSperm + " for actor " + a)
		return myMultipleBabyChancePerSperm
	else	; must be positive
		Debug.Trace("FWAddOnManager - ActorMultipleBabyChancePerSperm is not defined for actor " + a)
		return -1
	endIf
endFunction


; Get BabyHealingScale
float function ActorBabyHealingScale(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Baby_Healing_Scale", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = RaceBabyHealingScale(abr)
			endIf
		endIf
	endIf
	
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endif
endFunction
float function RaceBabyHealingScale(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceBabyHealingScale : Race = " + RaceID + ". Baby_Healing_Scale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Baby_Healing_Scale",1.0))

	float result = 1.0
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Baby_Healing_Scale",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Baby_Healing_Scale", 1.0)
	endIf
	
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endIf
endFunction


; Get BabyDamageScale
float function ActorBabyDamageScale(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Baby_Damage_Scale", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = RaceBabyDamageScale(abr)
			endIf
		endIf
	endIf
	
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endif
endFunction
float function RaceBabyDamageScale(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceBabyDamageScale : Race = " + RaceID + ". Baby_Damage_Scale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Baby_Damage_Scale",1.0))

	float result = 1.0
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Baby_Damage_Scale",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Baby_Damage_Scale", 1.0)
	endIf
	
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endIf
endFunction




; Get SpermDurationScale
float function ActorMaleSpermDurationScale(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Duration_MaleSperm", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = RaceMaleSpermDurationScale(abr)
			endIf
		endIf
	endIf
	
	if result < 0.1
		return 0.1
	else
		return result
	endif
endFunction
float function RaceMaleSpermDurationScale(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceMaleSpermDurationScale : Race = " + RaceID + ". Duration_MaleSperm = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_MaleSperm",1.0))

	float result = 1.0;
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Duration_MaleSperm",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Duration_MaleSperm", 1.0)
	endIf
	
	if result < 0.1
		return 0.1
	else
		return result
	endif
endFunction


; Get SpermAmountScale
float function ActorSpermAmountScale(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Sperm_Amount_Scale", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = RaceSpermAmountScale(abr)
			endIf
		endIf
	endIf
	
	if result < 0.1
		return 0.1
	else
		return result
	endif
endFunction
float function RaceSpermAmountScale(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceSpermAmountScale : Race = " + RaceID + ". Sperm_Amount_Scale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Sperm_Amount_Scale",1.0))

	float result = 1.0
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Sperm_Amount_Scale",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Sperm_Amount_Scale", 1.0)
	endIf
	
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endIf
endFunction


; Get MaleRecoveryScale
float function ActorMaleRecoveryScale(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Male_Recovery_Scale", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = RaceMaleRecoveryScale(abr)
			endIf
		endIf
	endIf
	
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endif
endFunction
float function RaceMaleRecoveryScale(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceMaleRecoveryScale : Race = " + RaceID + ". Male_Recovery_Scale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Male_Recovery_Scale",1.0))

	float result = 1.0
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Male_Recovery_Scale",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Male_Recovery_Scale", 1.0)
	endIf
	
	if result < 0.3
		return 0.3 ; return at least 30%
	else
		return result
	endIf
endFunction


; Get ChildRaceDeterminedByFather
int Function ActorChildRaceDeterminedByFather(actor a)
	int DefaultChildRaceDeterminedByFather = myBFA_ProbChildRaceDeterminedByFather.GetValue() as int
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - ActorChildRaceDeterminedByFather: DefaultChildRaceDeterminedByFather = " + DefaultChildRaceDeterminedByFather)

	int ChildRaceDeterminedByFather
	if a
		ChildRaceDeterminedByFather = StorageUtil.GetIntValue(a, "FW.AddOn.ProbChildRaceDeterminedByFather", DefaultChildRaceDeterminedByFather)
		if((ChildRaceDeterminedByFather == DefaultChildRaceDeterminedByFather) || (ChildRaceDeterminedByFather < 0))
			race abr = a.GetRace()
			if abr
				ChildRaceDeterminedByFather = StorageUtil.GetIntValue(abr, "FW.AddOn.ProbChildRaceDeterminedByFather", -1)
			endIf
		endIf
	endIf
	if ChildRaceDeterminedByFather < 0	; Must be nonnegative!
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - ActorChildRaceDeterminedByFather: Changing ChildRaceDeterminedByFather from " + ChildRaceDeterminedByFather + " to " + DefaultChildRaceDeterminedByFather)
		return DefaultChildRaceDeterminedByFather
	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - ActorChildRaceDeterminedByFather: ChildRaceDeterminedByFather = " + ChildRaceDeterminedByFather)
		return ChildRaceDeterminedByFather
	endif
endFunction


; Get ChildSexDetermMale
int Function ActorChildSexDetermMale(actor a)
	int DefaultChildSexDetermMale = myBFA_ProbChildSexDetermMale.GetValue() as int
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - ActorChildSexDetermMale: DefaultChildSexDetermMale = " + DefaultChildSexDetermMale)
	
	int ChildSexDetermMale
	if a
		ChildSexDetermMale = StorageUtil.GetIntValue(a, "FW.AddOn.ProbChildSexDetermMale", DefaultChildSexDetermMale)
		if((ChildSexDetermMale == DefaultChildSexDetermMale) || (ChildSexDetermMale < 0))
			race abr = a.GetRace()
			if abr
				ChildSexDetermMale = StorageUtil.GetIntValue(abr, "FW.AddOn.ProbChildSexDetermMale", -1)
			endIf
		endIf
	endIf
	if ChildSexDetermMale < 0	; Must be nonnegative!
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - ActorChildSexDetermMale: Changing ChildSexDetermMale from " + ChildSexDetermMale + " to " + DefaultChildSexDetermMale)
		return DefaultChildSexDetermMale
	else
;		Debug.Trace("[Beeing Female NG] - FWAddOnManager - ActorChildSexDetermMale: ChildSexDetermMale = " + ChildSexDetermMale)
		return ChildSexDetermMale
	endif
endFunction


; Get BabyHealingScale
float function ActorBabyHealingScaleByFather(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Modify_Baby_Healing_Scale_by_FatherRace", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = RaceBabyHealingScaleByFather(abr)
			endIf
		endIf
	endIf
	
	return result
endFunction
float function RaceBabyHealingScaleByFather(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceBabyHealingScale : Race = " + RaceID + ". Baby_Healing_Scale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Baby_Healing_Scale",1.0))

	float result = 1.0
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Modify_Baby_Healing_Scale_by_FatherRace",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Modify_Baby_Healing_Scale_by_FatherRace", 1.0)
	endIf
	
	return result
endFunction


; Get BabyDamageScale
float function ActorBabyDamageScaleByFather(actor a)
	float result = 1.0
	;if a && a.GetActorBase() && a.GetActorBase().GetRace()
	if a ;Tkc (Loverslab): optimization
		result = StorageUtil.GetFloatValue(a, "FW.AddOn.Modify_Baby_Damage_Scale_by_FatherRace", 1.0)
		if(result == 1.0)
			race abr = a.GetRace()
			if abr
				result = RaceBabyDamageScaleByFather(abr)
			endIf
		endIf
	endIf
	
	return result
endFunction
float function RaceBabyDamageScaleByFather(race RaceID)
;	Debug.Trace("[Beeing Female NG] - FWAddOnManager - RaceBabyDamageScale : Race = " + RaceID + ". Baby_Damage_Scale = " + StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Baby_Damage_Scale",1.0))

	float result = 1.0
	result = StorageUtil.GetFloatValue(RaceID,"FW.AddOn.Modify_Baby_Damage_Scale_by_FatherRace",1.0)
	if(result == 1.0)
		result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_Modify_Baby_Damage_Scale_by_FatherRace", 1.0)
	endIf
	
	return result
endFunction



ActorBase function validateBabyCustomRace(ActorBase b)
	if !b
		return none
	endif
	Race childRace = b.GetRace()
	if childRace
		string childRaceName = FWUtility.toLower(childRace.GetName() + MiscUtil.GetRaceEditorID(childRace))
		if StringUtil.Find(childRaceName, "child") == -1 && childRace.HasKeywordString("ActorTypeNPC")
			Debug.Trace("BeeingFemale - AddonManager - getBabyActor - Child race " + childRace + " is not labeled as child; falling back to default")
			if cfg.ShowDebugMessage
				Debug.Messagebox("Child race is not labeled as child; falling back to default.")
			endIf
			return none
		else
			return b
		endIf
	endIf
	return none
endFunction

; Get BabyActor
ActorBase function GetBabyActorNew(actor ParentActor, race ParentRace, int Gender)
	ActorBase m;=none ;Tkc (Loverslab): optimization
	string sGender = "BabyActor_Male"
	if(Gender == 1)
		sGender = "BabyActor_Female"
	endif
	
	int c = StorageUtil.FormListCount(ParentActor, "FW.AddOn." + sGender)
	if(c > 0)
		int r = Utility.RandomInt(0, c - 1)
		m = StorageUtil.FormListGet(ParentActor, "FW.AddOn." + sGender, r) as ActorBase
		if m;/!=none/;
			return validateBabyCustomRace(m)
		else
			Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetBabyActor - baby of the parent actor " + ParentActor + " cannot be found...")
			if(cfg.ShowDebugMessage)
				Debug.Messagebox("Baby of the parent actor " + ParentActor + " cannot be found...")
			endIf
		endif
		while(c > 0)
			c -= 1
			m = StorageUtil.FormListGet(ParentActor, "FW.AddOn." + sGender, c) as ActorBase
			if m;/!=none/;
				return validateBabyCustomRace(m)
			else
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetBabyActor - baby of the parent actor " + ParentActor + " cannot be found...")
				if(cfg.ShowDebugMessage)
					Debug.Messagebox("Baby of the parent actor " + ParentActor + " cannot be found...")
				endIf
			endif
		endWhile
	else
		c = StorageUtil.FormListCount(ParentRace, "FW.AddOn." + sGender)
		if(c > 0)
			int r = Utility.RandomInt(0, c - 1)
			m = StorageUtil.FormListGet(ParentRace, "FW.AddOn." + sGender, r) as ActorBase
			if m;/!=none/;
				return validateBabyCustomRace(m)
			else
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetBabyActor - baby of the parent race " + ParentRace + " cannot be found...")
				if(cfg.ShowDebugMessage)
					Debug.Messagebox("Baby of the parent race " + ParentRace + " cannot be found...")
				endIf
			endif
			while(c > 0)
				c -= 1
				m = StorageUtil.FormListGet(ParentRace, "FW.AddOn." + sGender, c) as ActorBase
				if m;/!=none/;
					return validateBabyCustomRace(m)
				else
					Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetBabyActor - baby of the parent race " + ParentRace + " cannot be found...")
					if(cfg.ShowDebugMessage)
						Debug.Messagebox("Baby of the parent race " + ParentRace + " cannot be found...")
					endIf
				endif
			endWhile
		else
			c = StorageUtil.FormListCount(none, "FW.AddOn.Global_" + sGender)
			if(c > 0)
				int r = Utility.RandomInt(0, c - 1)
				m = StorageUtil.FormListGet(none, "FW.AddOn.Global_" + sGender, r) as ActorBase
				if m;/!=none/;
					return validateBabyCustomRace(m)
				else
					Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetBabyActor - baby model cannot be found...")
					if(cfg.ShowDebugMessage)
						Debug.Messagebox("Baby model cannot be found...")
					endIf
				endif
				while(c > 0)
					c -= 1
					m = StorageUtil.FormListGet(none, "FW.AddOn.Global_" + sGender, c) as ActorBase
					if m;/!=none/;
						return validateBabyCustomRace(m)
					else
						Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetBabyActor - baby model cannot be found...")
						if(cfg.ShowDebugMessage)
							Debug.Messagebox("Baby model cannot be found...")
						endIf
					endif
				endWhile		
			else
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetBabyActor - baby actor model cannot be found...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("Baby actor model cannot be found...")
				endIf
			endIf
		endIf
	endif
	
	return none
endFunction
; Deprecated
ActorBase function GetBabyActor(race ParentRace,int Gender)
	ActorBase m;=none ;Tkc (Loverslab): optimization
	string sGender="BabyActor_Male"
	if Gender==1
		sGender="BabyActor_Female"
	endif
	int c=StorageUtil.FormListCount(ParentRace, "FW.AddOn."+sGender)
	if c>0
		int r=Utility.RandomInt(0,c - 1)
		m=StorageUtil.FormListGet(ParentRace, "FW.AddOn."+sGender,r) as ActorBase
		if m;/!=none/;
			return m
		else
			Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetBabyActor - baby of the parent race " + ParentRace + " cannot be found...")
			if cfg.ShowDebugMessage
				Debug.Messagebox("Baby of the parent race " + ParentRace + " cannot be found...")
			endIf
		endif
		while c>0
			c-=1
			m=StorageUtil.FormListGet(ParentRace, "FW.AddOn."+sGender,c) as ActorBase
			if m;/!=none/;
				return m
			else
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetBabyActor - baby of the parent race " + ParentRace + " cannot be found...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("Baby of the parent race " + ParentRace + " cannot be found...")
				endIf
			endif
		endWhile
	else
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetBabyActor - Parent race " + ParentRace + " cannot be found...")
		if cfg.ShowDebugMessage
			Debug.Messagebox("Parent race " + ParentRace + " cannot be found...")
		endIf
	endif
	return none
endFunction


; Get PlayerBabyActor
ActorBase function GetPlayerBabyActorNew(actor ParentActor, race ParentRace, int Gender)
	ActorBase m;=none ;Tkc (Loverslab): optimization
	string sGender = "BabyActor_MalePlayer"
	if(Gender == 1)
		sGender = "BabyActor_FemalePlayer"
	endif
	
	int c = StorageUtil.FormListCount(ParentActor, "FW.AddOn." + sGender)
	if(c > 0)
		int r = Utility.RandomInt(0, c - 1)
		m = StorageUtil.FormListGet(ParentActor, "FW.AddOn." + sGender, r) as ActorBase
		if m;/!=none/;
			return validateBabyCustomRace(m)
		else
			Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetPlayerBabyActor - baby of the parent actor " + ParentActor + " cannot be found...")
			if(cfg.ShowDebugMessage)
				Debug.Messagebox("Baby of the parent actor " + ParentActor + " cannot be found...")
			endIf
		endif
		while(c > 0)
			c -= 1
			m = StorageUtil.FormListGet(ParentActor, "FW.AddOn." + sGender, c) as ActorBase
			if m;/!=none/;
				return validateBabyCustomRace(m)
			else
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetPlayerBabyActor - baby of the parent actor " + ParentActor + " cannot be found...")
				if(cfg.ShowDebugMessage)
					Debug.Messagebox("Baby of the parent actor " + ParentActor + " cannot be found...")
				endIf
			endif
		endWhile
	else
		c = StorageUtil.FormListCount(ParentRace, "FW.AddOn." + sGender)
		if(c > 0)
			int r = Utility.RandomInt(0, c - 1)
			m = StorageUtil.FormListGet(ParentRace, "FW.AddOn." + sGender, r) as ActorBase
			if m;/!=none/;
				return validateBabyCustomRace(m)
			else
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetPlayerBabyActor - baby of the parent race " + ParentRace + " cannot be found...")
				if(cfg.ShowDebugMessage)
					Debug.Messagebox("Baby of the parent race " + ParentRace + " cannot be found...")
				endIf
			endif
			while(c > 0)
				c -= 1
				m = StorageUtil.FormListGet(ParentRace, "FW.AddOn." + sGender, c) as ActorBase
				if m;/!=none/;
					return validateBabyCustomRace(m)
				else
					Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetPlayerBabyActor - baby of the parent race " + ParentRace + " cannot be found...")
					if(cfg.ShowDebugMessage)
						Debug.Messagebox("Baby of the parent race " + ParentRace + " cannot be found...")
					endIf
				endif
			endWhile
		else
			c = StorageUtil.FormListCount(none, "FW.AddOn.Global_" + sGender)
			if(c > 0)
				int r = Utility.RandomInt(0, c - 1)
				m = StorageUtil.FormListGet(none, "FW.AddOn.Global_" + sGender, r) as ActorBase
				if m;/!=none/;
					return validateBabyCustomRace(m)
				else
					Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetPlayerBabyActor - baby model cannot be found...")
					if(cfg.ShowDebugMessage)
						Debug.Messagebox("Baby model cannot be found...")
					endIf
				endif
				while(c > 0)
					c -= 1
					m = StorageUtil.FormListGet(none, "FW.AddOn.Global_" + sGender, c) as ActorBase
					if m;/!=none/;
						return validateBabyCustomRace(m)
					else
						Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetPlayerBabyActor - baby model cannot be found...")
						if(cfg.ShowDebugMessage)
							Debug.Messagebox("Baby model cannot be found...")
						endIf
					endif
				endWhile		
			else
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetPlayerBabyActor - baby actor model cannot be found...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("Baby actor model cannot be found...")
				endIf
			endIf
		endIf
	endif
	
	return none
endFunction
; Deprecated
ActorBase function GetPlayerBabyActor(race ParentRace,int Gender)
	ActorBase m;=none ;Tkc (Loverslab): optimization
	string sGender="BabyActor_MalePlayer"
	if Gender==1
		sGender="BabyActor_FemalePlayer"
	endif
	int c=StorageUtil.FormListCount(ParentRace, "FW.AddOn."+sGender)
	if c>0
		int r=Utility.RandomInt(0,c - 1)
		m=StorageUtil.FormListGet(ParentRace, "FW.AddOn."+sGender,r) as ActorBase
		if m;/!=none/;
			return m
		else
			Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetPlayerBabyActor - baby of the parent race " + ParentRace + " cannot be found...")
			if cfg.ShowDebugMessage
				Debug.Messagebox("Baby of the parent race " + ParentRace + " cannot be found...")
			endIf
		endif
		while c>0
			c-=1
			m=StorageUtil.FormListGet(ParentRace, "FW.AddOn."+sGender,c) as ActorBase
			if m;/!=none/;
				return m
			else
				Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetPlayerBabyActor - baby of the parent race " + ParentRace + " cannot be found...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("Baby of the parent race " + ParentRace + " cannot be found...")
				endIf
			endif
		endWhile
	else
		Debug.Trace("[Beeing Female NG] - FWAddOnManager - GetPlayerBabyActor - Parent race " + ParentRace + " cannot be found...")
		if cfg.ShowDebugMessage
			Debug.Messagebox("Parent race " + ParentRace + " cannot be found...")
		endIf
	endif
	return none
endFunction


; Get RaceProbChildActorBorn
int Function RaceProbChildActorBornNew(actor ParentActor, race ParentRace)
	int myProbChildActorBorn = StorageUtil.GetIntValue(ParentActor, "FW.AddOn.ProbChildActorBorn", -1)
	
	if(myProbChildActorBorn > 0)
		Debug.Trace("FWAddOnManager - RaceProbChildActorBorn = " + myProbChildActorBorn + " for the actor " + ParentActor)
		return myProbChildActorBorn
	else
		myProbChildActorBorn = StorageUtil.GetIntValue(ParentRace, "FW.AddOn.ProbChildActorBorn", -1)
		if(myProbChildActorBorn > 0)
			Debug.Trace("FWAddOnManager - RaceProbChildActorBorn = " + myProbChildActorBorn + " for the race " + ParentRace)
			return myProbChildActorBorn
		else
			myProbChildActorBorn = StorageUtil.GetIntValue(none, "FW.AddOn.Global_ProbChildActorBorn", -1)
			if(myProbChildActorBorn > 0)
				Debug.Trace("FWAddOnManager - RaceProbChildActorBorn = " + myProbChildActorBorn + " for everything")
				return myProbChildActorBorn
			else
				; must be positive
				Debug.Trace("FWAddOnManager - RaceProbChildActorBorn is not defined for the race " + ParentRace)
				return -1
			endIf
		endIf
	endIf
endFunction
; Deprecated
int Function RaceProbChildActorBorn(race RaceID)
	int myProbChildActorBorn = StorageUtil.GetIntValue(RaceID, "FW.AddOn.ProbChildActorBorn", -1)
	
	if(myProbChildActorBorn > 0)
		Debug.Trace("FWAddOnManager - RaceProbChildActorBorn = " + myProbChildActorBorn + " for the race " + RaceID)
		return myProbChildActorBorn
	else	; must be positive
		Debug.Trace("FWAddOnManager - RaceProbChildActorBorn is not defined for the race " + RaceID)
		return -1
	endIf
endFunction


; Get InitialScale
float Function ActorInitialScale(actor a)
	float myInitialScale = DefaultInitialScale
	if a
		myInitialScale = StorageUtil.GetFloatValue(a, "FW.AddOn.initialScale", DefaultInitialScale)
		if(myInitialScale == DefaultInitialScale)
			race abr = a.GetRace()
			if abr
				myInitialScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.initialScale", DefaultInitialScale)
				if(myInitialScale == DefaultInitialScale)
					myInitialScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_initialScale", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myInitialScale > 0
		return myInitialScale
	else	; must be positive
		return DefaultInitialScale
	endIf
endFunction


; Get FinalScale
float Function ActorFinalScale(actor a)
	float myFinalScale = DefaultFinalScale
	if a
		myFinalScale = StorageUtil.GetFloatValue(a, "FW.AddOn.finalScale", DefaultFinalScale)
		if(myFinalScale == DefaultFinalScale)
			race abr = a.GetRace()
			if abr
				myFinalScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.finalScale", DefaultFinalScale)
				if(myFinalScale == DefaultFinalScale)
					myFinalScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_finalScale", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myFinalScale > 0
		return myFinalScale
	else	; must be positive
		return DefaultFinalScale
	endIf
endFunction
; Deprecated
float Function RaceFinalScale(race RaceID)
	float myFinalScale = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.finalScale", -1)
	if(myFinalScale <= 0)
		myFinalScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_finalScale", -1)
	endIf
	
	if myFinalScale > 0
		return myFinalScale
	else	; must be positive
		return DefaultFinalScale
	endIf
endFunction


; Get MatureTimeScale
float Function ActorMatureTimeScale(actor a)
	float result = 1.0
	
	if a
		if(StorageUtil.GetIntValue(a, "FW.AddOn.DisableMatureTime", 0) == 0)
			result = StorageUtil.GetFloatValue(a, "FW.AddOn.MatureTimeScale", -1)
		else
			race abr = a.GetRace()
			if abr
				if(StorageUtil.GetIntValue(abr, "FW.AddOn.DisableMatureTime", 0) == 0)
					result = StorageUtil.GetFloatValue(abr, "FW.AddOn.MatureTimeScale", -1)
				else
					if(StorageUtil.GetIntValue(none, "FW.AddOn.Global_DisableMatureTime", 0) == 0)
						result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_MatureTimeScale", -1)
					else
						result = 0
					endIf
				endIf
			endIf
		endIf
	endIf
	
	if result < 0
		return 1.0
	else
		return result
	endIf
endFunction
; Deprecated
float Function RaceMatureTimeScale(race RaceID)
	float result
	
	if(StorageUtil.GetIntValue(RaceID, "FW.AddOn.DisableMatureTime", 0) == 0)
		result = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.MatureTimeScale", -1)
	else
		if(StorageUtil.GetIntValue(none, "FW.AddOn.Global_DisableMatureTime", 0) == 0)
			result = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_MatureTimeScale", -1)
		else
			result = 0
		endIf
	endIf
	
	if result < 0
		return 1.0
	else
		return result
	endIf
endFunction


; Get CustomMatureTimeInHours
float Function ActorCustomMatureTimeInHours(actor a)
	float DefaultMatureTimeInHours = 24 * (BFOpt_MatureTimeInDays.GetValue())
	float myCustomMatureTimeInHours
	if a
		if(StorageUtil.GetIntValue(a, "FW.AddOn.DisableMatureTime", 0) == 0)
			myCustomMatureTimeInHours = DefaultMatureTimeInHours * StorageUtil.GetFloatValue(a, "FW.AddOn.MatureTimeScale", -1)
		else
			race abr = a.GetRace()
			if abr
				if(StorageUtil.GetIntValue(abr, "FW.AddOn.DisableMatureTime", 0) == 0)
					myCustomMatureTimeInHours = DefaultMatureTimeInHours * StorageUtil.GetFloatValue(abr, "FW.AddOn.MatureTimeScale", -1)
				else
					if(StorageUtil.GetIntValue(none, "FW.AddOn.Global_DisableMatureTime", 0) == 0)
						myCustomMatureTimeInHours = DefaultMatureTimeInHours * StorageUtil.GetFloatValue(none, "FW.AddOn.Global_MatureTimeScale", -1)
					else
						myCustomMatureTimeInHours = 0
					endIf
				endIf
			endIf
		endIf
	endIf
	if myCustomMatureTimeInHours < 0
		return DefaultMatureTimeInHours
	else
		return myCustomMatureTimeInHours
	endIf
endFunction


; Get MatureStep
int Function ActorMatureStep(actor a)
	int myMatureStep = DefaultMatureStep
	if a
		myMatureStep = StorageUtil.GetIntValue(a, "FW.AddOn.MatureStep", DefaultMatureStep)
		if(myMatureStep == DefaultMatureStep)
			race abr = a.GetRace()
			if abr
				myMatureStep = StorageUtil.GetIntValue(abr, "FW.AddOn.MatureStep", DefaultMatureStep)
				if(myMatureStep == DefaultMatureStep)
					myMatureStep = StorageUtil.GetIntValue(none, "FW.AddOn.Global_MatureStep", -1)
				endIf
			endIf
		endIf
	endIf
	
	if myMatureStep > 0
		return myMatureStep
	else	; must be positive
		return DefaultMatureStep
	endIf
endFunction


; Get MatureScaleStep
float Function ActorMatureScaleStep(actor a)
	float myInitialScale = DefaultInitialScale
	float myFinalScale = DefaultFinalScale
	int myMatureStep = DefaultMatureStep
	
	bool myInitScaleDeterminedByActor = false
	bool myInitScaleDeterminedByRace = false

	bool myFinalScaleDeterminedByActor = false
	bool myFinalScaleDeterminedByRace = false
	
	if a
		race abr = a.GetRace()
		
		myInitialScale = StorageUtil.GetFloatValue(a, "FW.AddOn.initialScale", DefaultInitialScale)
		if(myInitialScale == DefaultInitialScale)
			myInitialScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.initialScale", DefaultInitialScale)
			if(myInitialScale == DefaultInitialScale)
				myInitialScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_initialScale", -1)
			else
				myInitScaleDeterminedByRace = true
			endIf
		else
			myInitScaleDeterminedByActor = true
		endIf
		if(myInitialScale <= 0)
			myInitialScale = DefaultInitialScale
		endIf


		myFinalScale = StorageUtil.GetFloatValue(a, "FW.AddOn.finalScale", DefaultFinalScale)
		if(myFinalScale == DefaultFinalScale)
			myFinalScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.finalScale", DefaultFinalScale)
			if(myFinalScale == DefaultFinalScale)
				myFinalScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_finalScale", -1)
			else
				myFinalScaleDeterminedByRace = true
			endIf
		else
			myFinalScaleDeterminedByActor = true
		endIf
		if(myFinalScale <= 0)
			myFinalScale = DefaultFinalScale
		endIf
		
		
		if(myFinalScale >= myInitialScale)
		else
			float oldInitialScale = myInitialScale
			myInitialScale = myFinalScale
			myFinalScale = oldInitialScale
			
			if(myInitScaleDeterminedByActor)
				StorageUtil.SetFloatValue(a, "FW.AddOn.initialScale", myInitialScale)
			else
				if(myInitScaleDeterminedByRace)
					StorageUtil.SetFloatValue(abr, "FW.AddOn.initialScale", myInitialScale)
				else
					StorageUtil.SetFloatValue(none, "FW.AddOn.Global_initialScale", myInitialScale)
				endIf
			endIf
			
			if(myFinalScaleDeterminedByActor)
				StorageUtil.SetFloatValue(a, "FW.AddOn.finalScale", myFinalScale)
			else
				if(myFinalScaleDeterminedByRace)
					StorageUtil.SetFloatValue(abr, "FW.AddOn.finalScale", myFinalScale)
				else
					StorageUtil.SetFloatValue(none, "FW.AddOn.Global_finalScale", myFinalScale)
				endIf
			endIf
		endIf
		
		
		myMatureStep = StorageUtil.GetIntValue(a, "FW.AddOn.MatureStep", DefaultMatureStep)
		if(myMatureStep == DefaultMatureStep)
			myMatureStep = StorageUtil.GetIntValue(abr, "FW.AddOn.MatureStep", DefaultMatureStep)
			if(myMatureStep == DefaultMatureStep)
				myMatureStep = StorageUtil.GetIntValue(none, "FW.AddOn.Global_MatureStep", -1)
			endIf
		endIf
		if(myMatureStep < 0)
			myMatureStep = DefaultMatureStep
		endIf
	endIf


	float MatureScaleStep = (myFinalScale - myInitialScale) / myMatureStep
	if MatureScaleStep < 0	; must be positive
		return DefaultMatureScaleStep
	else
		return MatureScaleStep
	endIf
endFunction
; Deprecated
float Function RaceMatureScaleStep(race RaceID)
	float myInitialScale = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.initialScale", -1)
	if(myInitialScale > 0)
	else
		myInitialScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_initialScale", -1)
		if(myInitialScale <= 0)
			myInitialScale = DefaultInitialScale
		endIf
	endIf
	float myFinalScale = StorageUtil.GetFloatValue(RaceID, "FW.AddOn.finalScale", -1)
	if(myFinalScale > 0)
	else
		myFinalScale = StorageUtil.GetFloatValue(none, "FW.AddOn.Global_finalScale", -1)
		if(myFinalScale <= 0)
			myFinalScale = DefaultFinalScale
		endIf
	endIf
	
	if(myFinalScale >= myInitialScale)
	else
		float oldInitialScale = myInitialScale
		myInitialScale = myFinalScale
		myFinalScale = oldInitialScale
		
		StorageUtil.SetFloatValue(RaceID, "FW.AddOn.initialScale", myInitialScale)
		StorageUtil.SetFloatValue(RaceID, "FW.AddOn.finalScale", myFinalScale)
	endIf
	
	int myMatureStep = StorageUtil.GetIntValue(RaceID, "FW.AddOn.MatureStep", -1)
	if(myMatureStep < 0)
		myMatureStep = DefaultMatureStep
	endIf
	
	float MatureScaleStep = (myFinalScale - myInitialScale) / myMatureStep
	if MatureScaleStep < 0	; must be positive
		return DefaultMatureScaleStep
	else
		return MatureScaleStep
	endIf
endFunction


; Get ExcludeFromSLandBF
Faction SexLabForbiddenActors			; // FormID: 0x049068 in SexLab.esm
Function RaceExcludeFromSLandBF(actor TargetActor, actor ParentActor)
	bool bool_AddToForbidden = true
	
	if(TargetActor)
		if(ParentActor)
			if(StorageUtil.GetIntValue(ParentActor, "FW.AddOn.AllowUnrestrictedS", 0) == 0)
				race ParentRace = ParentActor.GetRace()
				if(StorageUtil.GetIntValue(ParentRace, "FW.AddOn.AllowUnrestrictedS", 0) == 0)
					if(StorageUtil.GetIntValue(none, "FW.AddOn.Global_AllowUnrestrictedS", 0) == 0)
					else
						bool_AddToForbidden = false
					endIf
				else
					bool_AddToForbidden = false
				endIf
			else
				bool_AddToForbidden = false
			endIf
		else
			Debug.Messagebox("ExcludeFromSLandBF: Failed to find parent actor. Please report to the BeeingFemaleSE_Opt mod page...")		
		endIf

		; Force human children into forbidden, regardless of unrestricted settings.
		race childRace = TargetActor.GetRace()
		if childRace
			if childRace.HasKeywordString("ActorTypeNPC")
				bool_AddToForbidden = true
			endif
		endIf
			
		if(bool_AddToForbidden)
			TargetActor.AddToFaction(BF_ForbiddenFaction)
			if(Game.IsPluginInstalled("SexLab.esm"))
				SexLabForbiddenActors = Game.GetFormFromFile(0x049068, "SexLab.esm") as Faction
								
				if(SexLabForbiddenActors)
					TargetActor.AddToFaction(SexLabForbiddenActors)
				else
					Debug.Messagebox("ExcludeFromSLandBF: Failed to get SexLabForbiddenActors faction from SexLab.esm. Please report to the BeeingFemaleSE_Opt mod page...")
				endIf
			else
				Debug.Messagebox("ExcludeFromSLandBF: SexLab is not installed...")		
			endIf
		endIf
	else
		Debug.Messagebox("ExcludeFromSLandBF: Failed to get child actor. Please report to the BeeingFemaleSE_Opt mod page...")		
	endIf
endFunction


; Add to SexLab and BeeingFemale faction
Function AddToSLandBF(actor TargetActor)
	if(TargetActor)
		if(TargetActor.IsInFaction(BF_ForbiddenFaction))
			Debug.Trace("AddToSLandBF: Actor " + TargetActor + " is in BF_ForbiddenFaction. Removing...")
			TargetActor.RemoveFromFaction(BF_ForbiddenFaction)
		endIf
		if(Game.IsPluginInstalled("SexLab.esm"))
			SexLabForbiddenActors = Game.GetFormFromFile(0x049068, "SexLab.esm") as Faction

			if(SexLabForbiddenActors)
				if(TargetActor.IsInFaction(SexLabForbiddenActors))
					Debug.Trace("AddToSLandBF: Actor " + TargetActor + " is in SexLabForbiddenActors faction. Removing...")
					TargetActor.RemoveFromFaction(SexLabForbiddenActors)
				else
					Debug.Trace("AddToSLandBF: Actor " + TargetActor + " is not in SexLabForbiddenActors faction.")
				endIf
			else
				Debug.Messagebox("AddToSLandBF: Failed to get SexLabForbiddenActors faction from SexLab.esm. Please report to the BeeingFemaleSE_Opt mod page...")
			endIf
		else
			Debug.Trace("AddToSLandBF: SexLab is not installed")
		endIf
	else
		Debug.Messagebox("AddToSLandBF: Failed to get child actor. Please report to the BeeingFemaleSE_Opt mod page...")		
	endIf
endFunction




;-----------------------------------------------------------------
; Misc AddOn Functions

FWAddOn_Misc usedCameraAddOn=none
function StartCamera()
	if usedCameraAddOn;/!=none/;
		;Debug.Trace("There was a camera already running ("+usedCameraAddOn.GetName()+") - camera stoped")
		StopCamera()
	endIf
	FWAddOn_Misc[] cams = new FWAddOn_Misc[64]
	int i=0
	int j=0
	while i<iMisc && j<64
		if Misc[i].HasCamera
			cams[j]=Misc[i]
			j+=1
		endIf
		i+=1
	endWhile
	if j<=0
		; No Cameras found
	elseif j==1
		; 1 Camera found - Speed up and direct select this AddOn
		usedCameraAddOn=cams[0]
	else
		int camID = Utility.RandomInt(1,j) - 1
		usedCameraAddOn=cams[camID]
	endIf
	if usedCameraAddOn;/!=none/;
		;Debug.Trace("Using camera "+usedCameraAddOn.GetName()+" - start it")
		usedCameraAddOn.StartCamera()
	endIf
endFunction

function StopCamera()
	if usedCameraAddOn;/!=none/;
		usedCameraAddOn.StopCamera()
		usedCameraAddOn=none
	endIf
	;Debug.Trace("Camera stoped")
endFunction

function OnEnterState(actor akFemale, int iState)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnEnterState(akFemale,iState)
		endIf
		i+=1
	endWhile
endFunction

function OnExitState(actor akFemale, int iState)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnExitState(akFemale,iState)
		endIf
		i+=1
	endWhile
endFunction

function OnUpdateFunction(actor akFemale, int iState, float StatePercentage)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnUpdateFunction(akFemale,iState, StatePercentage)
		endIf
		i+=1
	endWhile
endFunction

function OnCameInside(actor akFemale, actor akMale)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnCameInside(akFemale,akMale)
		endIf
		i+=1
	endWhile
endFunction

float function getSpermAmount(actor akFemale, actor akMale, float amount)
	int i=1
	float tamount=amount
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			tamount=Misc[i].getSpermAmount(akFemale,akMale,tamount)
		endIf
		i+=1
	endWhile
	return tamount
endFunction

function OnLaborPain(actor akFemale)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnLaborPain(akFemale)
		endIf
		i+=1
	endWhile
endFunction

function OnGiveBirth(actor akMother, int iChildCount)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnGiveBirth(akMother,iChildCount)
		endIf
		i+=1
	endWhile
endFunction

function OnGiveBirthStart(actor akMother)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnGiveBirthStart(akMother)
		endIf
		i+=1
	endWhile
endFunction

function OnGiveBirthEnd(actor akMother)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnGiveBirthEnd(akMother)
		endIf
		i+=1
	endWhile
endFunction

bool function OnPainSound(actor akMother)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			if Misc[i].OnPainSound(akMother)
				return true
			endif
		endIf
		i+=1
	endWhile
	return false
endFunction

function OnBabySpawn(actor akMother, actor akFather)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnBabySpawn(akMother,akFather)
		endIf
		i+=1
	endWhile
endFunction

function OnPotionDrink(actor akMother, potion akPotion)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnPotionDrink(akMother,akPotion)
		endIf
		i+=1
	endWhile
endFunction

function OnSpellCast(actor akMother, spell akSpell)
	if(akSpell)
		int i=0
		while i<iMisc
			if Misc[i] as FWAddOn_Misc;/!=none/;
				Misc[i].OnSpellCast(akMother,akSpell)
			endIf
			i+=1
		endWhile
	endIf
endFunction

; Damage Type:								Optional Argument
;  0	Unknown
;  1	Mittelschmerz / Ovulation pains		strength of the pains
;  2	PMS pains							
;  3	Menstruation cramps					strength of the pains
;  4	Pregnancy 1. sickness
;  5	Pregnancy 2. sickness
;  6	Pregnancy 3. sickness
;  7	premonitory pains
;  8	first stage pains
;  9	Child-Pressing pains
; 10	bearing-down pains
; 11	afterpains
; 12	baby milk drinking pains
; 13	infection pains
; 14	abortus pains
;
; The amount is a percentage value based on the players max health. 0.0 = 0 Damage; 100.0 = instant death
float function OnDoDamage(actor Woman, float Amount, int DamageType = 0, float OptionalArgument = 0.0)
	int i=0
	float xAmount=Amount
	float tAmount
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			tAmount=Misc[i].OnDoDamage(Woman,xAmount,DamageType,OptionalArgument)
			if tAmount>=0
				xAmount=tAmount
			endif
		endIf
		i+=1
	endWhile
	if xAmount>=0
		return xAmount
	else
		return 0
	endif
endFunction

function OnDoDamageStart(actor Woman, float Amount, int DamageType, float OptionalArgument)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnDoDamageStart(Woman,Amount,DamageType,OptionalArgument)
		endIf
		i+=1
	endWhile
endFunction

function OnDoDamageEnd(actor Woman, float Amount, int DamageType, float OptionalArgument)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnDoDamageEnd(Woman,Amount,DamageType,OptionalArgument)
		endIf
		i+=1
	endWhile
endFunction

function OnContraception(actor Woman, float Amount, float ValueBefore, float ValueAfter, float TimeAgo)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnContraception(Woman,Amount,ValueBefore, ValueAfter, TimeAgo)
		endIf
		i+=1
	endWhile
endFunction

function OnImpregnate(actor Woman, int NumChildren, Actor[] ChildFathers)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnImpregnate(Woman,NumChildren,ChildFathers)
		endIf
		i+=1
	endWhile
endfunction

function OnUninstall()
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnUninstall()
		endIf
		i+=1
	endWhile
endfunction

bool function CheckForCondome(actor Woman, actor Man)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			if Misc[i].CheckForCondome(Woman,Man);/==true/;
				return true
			endif
		endIf
		i+=1
	endWhile
	return false
endfunction

function RegisterChildPerk(FWChildSettings childSettings)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnRegisterChildPerk(childSettings)
		endIf
		i+=1
	endWhile
endfunction

function OnMagicEffectApply(Actor akWoman, ObjectReference akCaster, MagicEffect akEffect)
	int i=0

	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnMagicEffectApply(akWoman, akCaster, akEffect)
		endIf
		i+=1
	endWhile
endfunction

Form[] function OnStripActor(Actor ActorRef)
	int i=0
	Form[] fAll
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Form[] f = Misc[i].OnStripActor(ActorRef)
			fAll = FWUtility.FormArrayConcat(fAll,f)
		endIf
		i+=1
	endWhile
	return fAll
endfunction

function OnMimik(actor ActorRef, string ExpressionName = "", int Strength = 50, bool bClear = true)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			Misc[i].OnMimik(ActorRef, ExpressionName, Strength, bClear)
		endIf
		i+=1
	endWhile
endfunction

ObjectReference function OnGetBedRef(Actor ActorRef)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			ObjectReference or = Misc[i].OnGetBedRef(ActorRef)
			if or;/!=none/;
				return or
			endif
		endIf
		i+=1
	endWhile
	return none
endfunction

bool function OnPlayPainSound(actor ActorRef, float Strength)
	int i=0
	while i<iMisc
		if (Misc[i] as FWAddOn_Misc);/!=none/;
			if Misc[i].OnPlayPainSound(ActorRef,Strength)
				return true
			endif
		endIf
		i+=1
	endWhile
	return false
endfunction

bool function OnAllowFFCum(Actor WomanToAdd, Actor denor)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			if Misc[i].OnAllowFFCum(WomanToAdd,denor)
				return true
			endif
		endIf
		i+=1
	endWhile
	return false
endfunction

actor function OnSleepSexStart(actor p, actor aSexPartner)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			aSexPartner = Misc[i].OnSleepSexStart(p,aSexPartner)
		endif
		i+=1
	endWhile
	return aSexPartner
endFunction

actor function OnSleepSexStop(actor p, actor aSexPartner)
	int i=0
	while i<iMisc
		if Misc[i] as FWAddOn_Misc;/!=none/;
			aSexPartner = Misc[i].OnSleepSexStart(p,aSexPartner)
		endif
		i+=1
	endWhile
	return aSexPartner
endFunction


; 04.06.2019 Tkc (Loverslab) optimizations: Changes marked with "Tkc (Loverslab)" comment.
