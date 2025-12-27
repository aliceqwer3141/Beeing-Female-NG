#include "skse64/GameAPI.h"
#include "skse64/GameData.h"
#include "skse64/GameTypes.h"
#include "skse64/GameForms.h"
#include "skse64/GameRTTI.h"
#include "skse64/ScaleformState.h"
#include "skse64/PapyrusActor.h"

class TESForm;
class TESObjectWEAP;
class Actor;
class SpellItem;
class ActiveEffect;
class VMClassRegistry;
class BGSHeadPart;
class TESObjectREFR;

namespace FWChildActor {
	class FWChildActor : Actor {
		enum SpellTypes {
			ShildSpell = 1,
			SummonSpell = 2,
			AttackSpell = 4,
			FunSpell = 8,
			HealSpell = 16,
			DarknessSpell = 32
		};

		enum SpellElement {
			Neutral = 0,
			Fire = 1,
			Ice = 2,
			Shock = 3
		};

		class SpellListInfo {
		public:
			int ID;
			SpellTypes Type;
			SpellElement Element;
			float MinDistance;
			float MaxDistance;
		};

		DEFINE_MEMBER_FN(GetLevel, UInt16, 0x006A7320);
		DEFINE_MEMBER_FN(SetRace, void, 0x006AF590, TESRace*, bool isPlayer);
		DEFINE_MEMBER_FN(SetLevel, void, 0x006A7320, UInt16);
	};

	bool RegisterFuncs(VMClassRegistry* registry);
}