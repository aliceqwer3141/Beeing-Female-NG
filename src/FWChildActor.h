#include "CommonLibCompat.h"

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
