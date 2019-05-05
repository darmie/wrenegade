#include "c/myclass/subpack/Hello/Hello.h"
#include "c/myclass/MySuperClass/MySuperClass.h"
#include "c/myclass/MyClass/MyClass.h"
#include "c/test/Test/Test.h"
#include "wren_bindings.h"
namespace wrenegade {
void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods) {
	if (strcmp(module, "foreign/test") == 0){
			
		if (strcmp(className, "Test") == 0){
			::test_Test_functions::bindClass(methods); return;
		}
	}
	if (strcmp(module, "foreign/myclass/subpack") == 0){
			
		if (strcmp(className, "Hello") == 0){
			::myclass_subpack_Hello_functions::bindClass(methods); return;
		}
	}
	if (strcmp(module, "foreign/myclass") == 0){
			
		if (strcmp(className, "MySuperClass") == 0){
			::myclass_MySuperClass_functions::bindClass(methods); return;
		}

			
		if (strcmp(className, "MyClass") == 0){
			::myclass_MyClass_functions::bindClass(methods); return;
		}
	}

}
WrenForeignMethodFn bindMethod(const char* module, const char *className, const char* signature) {

	if (strcmp(module, "foreign/test") == 0){
			
		if (strcmp(className, "Test") == 0){
			return ::test_Test_functions::bindMethod(signature);
		}
	}

	if (strcmp(module, "foreign/myclass/subpack") == 0){
			
		if (strcmp(className, "Hello") == 0){
			return ::myclass_subpack_Hello_functions::bindMethod(signature);
		}
	}

	if (strcmp(module, "foreign/myclass") == 0){
			
		if (strcmp(className, "MySuperClass") == 0){
			return ::myclass_MySuperClass_functions::bindMethod(signature);
		}

			
		if (strcmp(className, "MyClass") == 0){
			return ::myclass_MyClass_functions::bindMethod(signature);
		}
	}

	return NULL;
}
}