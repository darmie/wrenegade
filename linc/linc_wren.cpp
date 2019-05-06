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
inline bool bindings_exist (const std::string& name) {
    if (FILE *file = fopen(name.c_str(), "r")) {
        fclose(file);
        return true;
    } else {
        return false;
    }   
}

inline bool fileExists(const std::string &file)
{

	struct stat buffer;
	return (stat(file.c_str(), &buffer) == 0);
}

inline std::string fileToString(const std::string &file)
{

	std::ifstream fin;
	size_t start_pos = file.find("bindings/wren/wrenegade");
	bool exists = start_pos != std::string::npos;
	if (!exists){
		exists = fileExists(file);
	} 
	

	if (!exists)
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



char *loadModuleFn(WrenVM *vm, const char *mod)
{

	std::stringstream base;
	std::stringstream path;
	

	std::string str(mod);
	
	if (replaceString(str, "foreign", ""))
	{
		
		base << wrenegade::BIND_PATH << str;
		std::stringstream f;
		f << base.str() << ".wren";
		
		if (fileExists(f.str()))
		{	
			
			const char *v = base.str().c_str();
			mod = v;

			path << mod << ".wren";
		}

	} else {
		path << mod << ".wren";
	}
	
	std::string source;

	try
	{
		source = fileToString(path.str());
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