#include "./linc_wren.h"
#include "./wrenegade_helper.h"

#include <hxcpp.h>

#include <string>
#include <sstream>
#include <fstream>
#include <sys/stat.h>
#include <cassert>

// #ifndef INCLUDED_wren_VM
// #include <wren/VM.h>
// #endif

namespace linc
{

namespace wren
{

inline bool fileExists(const std::string &file)
{

	struct stat buffer;
	return (stat(file.c_str(), &buffer) == 0);
}

inline std::string fileToString(const std::string &file)
{

	std::ifstream fin;

	if (!fileExists(file))
	{
		throw std::runtime_error("file not found!");
	}

	fin.open(file, std::ios::in);

	std::stringstream buffer;
	buffer << fin.rdbuf() << '\0';

	return buffer.str();
}

inline bool replaceString(std::string &str, const std::string &from, const std::string &to)
{
	size_t start_pos = str.find(from);
	if (start_pos == std::string::npos)
		return false;
	str.replace(start_pos, from.length(), to);
	return true;
}

void writeFn(WrenVM *vm, const char *text)
{
	printf("%s", std::string(text).c_str());
	fflush(stdout);
}

inline bool bindings_exist (const std::string& name) {
    if (FILE *file = fopen(name.c_str(), "r")) {
        fclose(file);
        return true;
    } else {
        return false;
    }   
}

char *loadModuleFn(WrenVM *vm, const char *mod)
{

	std::stringstream base;
	

	std::string str(mod);
	
	if (replaceString(str, "foreign", ""))
	{
		
		base << wrenegade::BIND_PATH << str;
		std::stringstream f;
		f << base.str() << ".wren";

		if (bindings_exist(f.str()))
		{
			mod = base.str().c_str();
		}
	}

	std::string path(mod);
	path += ".wren";
	std::string source;

	

	try
	{
		source = fileToString(path);
	}

	catch (const std::exception &)
	{
		return NULL;
	}

	char *buffer = (char *)malloc(source.size());

	assert(buffer != nullptr);
	memcpy(buffer, source.c_str(), source.size());

	return buffer;
};

WrenForeignClassMethods bindForeignClass(WrenVM *vm, const char *module, const char *className)
{
	WrenForeignClassMethods holder;
	holder.finalize = NULL;
	wrenegade::bindClass(module, className, &holder);

	return holder;
}

WrenForeignMethodFn bindForeignMethod(WrenVM *vm, const char *module, const char *className, bool isStatic, const char *signature)
{
	std::stringstream fullName;

	if (isStatic)
	{
		fullName << "static ";
	}

	fullName << className << "." << signature;
	// printf("%s\n",module);
	// printf("%s\n",fullName.str().c_str());
	return wrenegade::bindMethod(module, className, fullName.str().c_str());
};

void writeErr(WrenVM *vm, WrenErrorType errorType, const char *module, int line, const char *message)
{
	wrenegade::helper::writeErr(vm, errorType, module, line, message);
}

WrenVM *newVM(Dynamic _config)
{

	WrenConfiguration config;
	wrenInitConfiguration(&config);

	config.writeFn = writeFn;
	config.errorFn = writeErr;
	config.loadModuleFn = loadModuleFn;

	config.bindForeignClassFn = bindForeignClass;

	config.bindForeignMethodFn = bindForeignMethod;

	if (_config != null())
	{
		if (_config->__FieldRef(HX_CSTRING("initialHeapSize")) != null())
		{
			config.initialHeapSize = (int)_config->__FieldRef(HX_CSTRING("initialHeapSize"));
		}
		if (_config->__FieldRef(HX_CSTRING("minHeapSize")) != null())
		{
			config.minHeapSize = (int)_config->__FieldRef(HX_CSTRING("minHeapSize"));
		}
		if (_config->__FieldRef(HX_CSTRING("heapGrowthPercent")) != null())
		{
			config.heapGrowthPercent = _config->__FieldRef(HX_CSTRING("heapGrowthPercent"));
		}
	}

	return wrenNewVM(&config);
}

::String getSlotString(WrenVM *vm, int slot)
{

	return ::String(wrenGetSlotString(vm, slot));
}

static WrenType getSlotType(WrenVM *vm, int slot)
{
	return wrenGetSlotType(vm, slot);
}

static void *setSlotNewForeign(WrenVM *vm, int slot, int classSlot, size_t size)
{
	return wrenSetSlotNewForeign(vm, 0, 0, 8);
}

} // namespace wren

} // namespace linc