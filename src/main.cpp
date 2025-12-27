#include "common/IDebugLog.h"  // IDebugLog
#include "skse64_common/skse_version.h"  // RUNTIME_VERSION
#include "skse64/PluginAPI.h"  // SKSEInterface, PluginInfo

#include "BeeingFemale/FWUtility.h"
#include "BeeingFemale/FWChildActor.h"
#include "BeeingFemale/FWSystem.h"
#include "BeeingFemale/FWChildEnchant.h"
#include "BeeingFemale/FWTextContents.h"

#include <ShlObj.h>  // CSIDL_MYDOCUMENTS

#include "version.h"  // VERSION_VERSTRING, VERSION_MAJOR

PluginHandle	g_pluginHandle = kPluginHandle_Invalid;

// here is a global reference to the interface, keeping to the skse style
SKSESerializationInterface* g_serialization = NULL;
SKSEPapyrusInterface* g_papyrus = NULL;

#define RUNTIME_VERSION = RUNTIME_VERSION_1_6_1170;

extern "C" {
	__declspec(dllexport) SKSEPluginVersionData SKSEPlugin_Version =
	{
		SKSEPluginVersionData::kVersion,

		7,
		"BeeingFemale",

		"DoctorBooooom",
		"support@example.com",

		0,	// not version independent (extended field)
		0,	// not version independent
		{ RUNTIME_VERSION_1_6_1170, 0 },	// compatible with 1.6.1170

		0,	// works with any version of the script extender. you probably do not need to put anything here
	};

	bool SKSEPlugin_Query(const SKSEInterface* skse, PluginInfo* info)
	{
		info->infoVersion = PluginInfo::kInfoVersion;
		info->name = "BeeingFemale";
		info->version = 7;

		return true;
	}

	bool SKSEPlugin_Load(const SKSEInterface* skse) {
		
		g_pluginHandle = skse->GetPluginHandle();

		g_serialization = (SKSESerializationInterface*)skse->QueryInterface(kInterface_Serialization);
		g_papyrus = (SKSEPapyrusInterface*)skse->QueryInterface(kInterface_Papyrus);
		if (!g_papyrus) {
			return false;
		}

		if (skse->isEditor)
			return false;
		else if (skse->runtimeVersion != RUNTIME_VERSION_1_6_1170) {
			return false;
		}

		g_serialization->SetUniqueID(g_pluginHandle, 'BF10');
		g_papyrus->Register(FWUtility::RegisterFuncs);
		g_papyrus->Register(FWChildActor::RegisterFuncs);
		g_papyrus->Register(FWChildEnchant::RegisterFuncs);
		g_papyrus->Register(FWTextContents::RegisterFuncs);
		//BeeingFemale::FWConsole_Init();
		return true;
	}
};