#include "./linc_wren.h"

#include <hxcpp.h>

#ifndef INCLUDED_wren_helper
#include <wren/Helper.h>
#endif

#include <string>
#include <sstream>
#include <fstream>
#include <sys/stat.h>
#include <cassert>

#ifndef INCLUDED_wren_VM
#include <wren/VM.h>
#endif

namespace linc
{

namespace wren
{

void setClass(const char *name, ::cpp::Function<void(cpp::Reference<WrenVM>)> handler)
{
	ClassHandler *_class = new ClassHandler(name, handler);
	_class->id = counter;
	_classes[counter] = _class;

	// printf("%s\n", name);
	counter++;
}

static ClassHandler *getClass(const char *name)
{
	ClassHandler *ret = nullptr;
	for (int i = 0; i < MAX_REGISTRATIONS; i++)
	{
		ClassHandler *val = _classes[i];
		if (strcmp(val->name, name) == 0)
		{
			// printf("getClass %s , %s\n", val->name, name);
			ret = val;
			break;
		}
		continue;
	}

	return ret;
}

void setMethod(const char *className, const char *signature, bool isStatic, ::cpp::Function<void(cpp::Reference<WrenVM>)> handler)
{
	MethodHandler *m = new MethodHandler(isStatic, signature, handler);
	ClassHandler *_class = getClass(className);
	_class->setMethod(m);
	// printf("setMethod %s\n", signature);
}

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

static int currentClassId = 0;
static MethodHandler *currentMethod = nullptr;
static void allocator(WrenVM *vm)
{
	_classes[currentClassId]->_constructor(vm);
}

static void methodCaller(WrenVM *vm)
{
	printf("method %s called", currentMethod->registry.signature);
	currentMethod->caller(vm);
}
static ::Dynamic __config;

WrenForeignClassMethods bindClass(WrenVM *vm, const char *module, const char *className)
{
	// if(strcmp(module, "main") != 0){
	// 	throw "tried to bind foreign class from non-main module";
	// }

	// ClassHandler *c = getClass(className);

	// currentClassId = c->id;

	// WrenForeignClassMethods holder;
	// holder.finalize = NULL;
	// holder.allocate = allocator;
	// return holder;
	return ::wren::VM_obj::bindClass(vm, module, className);
};

WrenForeignMethodFn bindMethod(WrenVM *vm, const char *module, const char *className, bool isStatic, const char *signature)
{
	// if(strcmp(module, "main") != 0){
	// 	return WrenForeignMethodFn(0);
	// }
	// std::stringstream fullName;
	// if(isStatic) {
	// 	fullName << "static ";
	// }
	// fullName << className << "." << signature;
	// ClassHandler *c = linc::wren::getClass(className);
	// currentMethod = c->getMethod(signature, isStatic);
	// printf("method %s called", currentMethod->registry.signature);
	// return methodCaller;
	return ::wren::VM_obj::bindMethod(vm, module, className, isStatic, signature);
};

void writeErr(WrenVM *vm, WrenErrorType errorType, const char *module, int line, const char *message)
{
	printf("errMessage: %s", std::string(message).c_str());
	::wren::Helper_obj::writeErr(vm, errorType, module, line, message);
}

WrenVM *newVM(Dynamic _config)
{

	WrenConfiguration config;
	wrenInitConfiguration(&config);

	config.writeFn = writeFn;
	config.errorFn = writeErr;
	config.loadModuleFn = loadModuleFn;

	config.bindForeignClassFn = bindClass;

	config.bindForeignMethodFn = bindMethod;

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

		__config = _config;
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

static void saveToSlot(WrenVM *vm, int slot, void *value, const char *type)
{
	switch (type)
	{
	case "Int":
	{
		wrenSetSlotDouble(vm, slot, value);
	}
	case "Float":
	{
		wrenSetSlotDouble(vm, slot, value);
	}
	case "Bool":
	{
		wrenSetSlotBool(vm, slot, value);
	}
	case "String":
	{
		wrenSetSlotString(vm, slot, value);
	}
	case "Null":
	{
		wrenSetSlotNull(vm, slot);
	}
	case "Unknown":
	{
		wrenSetSlotNull(vm, slot);
	}
	default:
	{
		throw 'don\'t know how to save type to a slot';
	}
	}
}

static void* getFromSlot(WrenVM *vm, int slot){
	switch(getSlotType(vm, slot)){
		case WREN_TYPE_BOOL:{
			return wrenGetSlotBool(vm, slot);
		};
		case WREN_TYPE_NUM:{
			return wrenGetSlotDouble(vm, slot);
		};
		case WREN_TYPE_STRING:{
			return wrenGetSlotString(vm, slot);
		};
		case WREN_TYPE_NULL:{
			return null();
		};
		case WREN_TYPE_UNKNOWN:{
			return null();
		};
		case WREN_TYPE_LIST:{
			int count = wrenGetListCount(vm, slot);
			::cpp::VirtualArray result = ::cpp::VirtualArray_obj::__new(count,0);
			for(int i=0;i<count;i++){
				wrenGetListElement(vm, slot, i, 0);
				auto elem = getFromSlot(vm, 0);
				result->__unsafe_set(i, elem);
			}
		};
		case WREN_TYPE_FOREIGN:{
			return (::Dynamic *) wrenGetSlotForeign(vm, slot);
		}
	}
}

} // namespace wren

} // namespace linc