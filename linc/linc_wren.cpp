#include "./linc_wren.h"

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

void writeFn(WrenVM *vm, const char *text)
{

	fflush(stdout);
}

char *loadModuleFn(WrenVM *vm, const char *mod)
{

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
	bindings::functions::bindClass(module, className, &holder);

	return holder;
}

WrenForeignMethodFn bindForeignMethod(WrenVM *vm, const char *module, const char *className, bool isStatic, const char *signature)
{
	std::stringstream fullName;

	if(isStatic) {
		fullName << "static ";
	}
	
	fullName << className << "." << signature;
	return bindings::functions::bindMethod(module, fullName.str().c_str());
};

void writeErr(WrenVM *vm, WrenErrorType errorType, const char *module, int line, const char *message)
{
	// printf("errMessage: %s\n", std::string(message).c_str());
	::wren::Helper_obj::writeErr(vm, errorType, module, line, message);
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
		// if(_config->__FieldRef(HX_CSTRING("bindForeignClassFn")) != null()){
		//     config.bindForeignClassFn = bindClass;
		// }
		// if(_config->__FieldRef(HX_CSTRING("bindForeignMethodFn")) != null()){
		//     config.bindForeignMethodFn = bindMethod;
		// }
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

// static void saveToSlot(WrenVM *vm, int slot, void *value, const char *type)
// {
// 	switch (std::string(type))
// 	{
// 	case std::string("Int"):
// 	{
// 		wrenSetSlotDouble(vm, slot, (double)*value);
// 	}
// 	case "Float":
// 	{
// 		wrenSetSlotDouble(vm, slot, (double)*value);
// 	}
// 	case "Bool":
// 	{
// 		wrenSetSlotBool(vm, slot, (bool)*value);
// 	}
// 	case "String":
// 	{
// 		wrenSetSlotString(vm, slot, (const char*)*value);
// 	}
// 	case "Null":
// 	{
// 		wrenSetSlotNull(vm, slot);
// 	}
// 	case "Unknown":
// 	{
// 		wrenSetSlotNull(vm, slot);
// 	}
// 	default:
// 	{
// 		throw 'don\'t know how to save type to a slot';
// 	}
// 	}
// }

static void *getFromSlot(WrenVM *vm, int slot)
{
	return NULL;
	// switch(getSlotType(vm, slot)){
	// 	case WREN_TYPE_BOOL:{
	// 		bool value = wrenGetSlotBool(vm, slot);
	// 		return &value;
	// 	};
	// 	case WREN_TYPE_NUM:{
	// 		double value = wrenGetSlotDouble(vm, slot);
	// 		return &value;
	// 	};
	// 	case WREN_TYPE_STRING:{
	// 		const char* value = (const char*)wrenGetSlotString(vm, slot);
	// 		return &value;
	// 	};
	// 	case WREN_TYPE_NULL:{
	// 		return null();
	// 	};
	// 	case WREN_TYPE_UNKNOWN:{
	// 		return null();
	// 	};
	// 	// case WREN_TYPE_LIST:{
	// 	// 	int count = wrenGetListCount(vm, slot);
	// 	// 	::cpp::VirtualArray* result = ::cpp::VirtualArray_obj::__new(count,0);
	// 	// 	for(int i=0;i<count;i++){
	// 	// 		wrenGetListElement(vm, slot, i, 0);
	// 	// 		auto elem = getFromSlot(vm, 0);
	// 	// 		result->__unsafe_set(i, elem);
	// 	// 	}
	// 	// };
	// 	case WREN_TYPE_FOREIGN:{
	// 		auto value = (::Dynamic *) wrenGetSlotForeign(vm, slot);
	// 		return &value;
	// 	}
	// 	default: {
	// 		return null();
	// 	}
}

} // namespace wren

} // namespace linc