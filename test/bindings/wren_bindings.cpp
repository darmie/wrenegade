#include "c/myclass/subpack/Hello/Hello.h"
#include "c/myclass/MySuperClass/MySuperClass.h"
#include "c/myclass/MyClass/MyClass.h"
#include "c/test/Test/Test.h"
#include "wren_bindings.h"
namespace wrenegade {
void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods) {
	if (strcmp(module, "test") == 0){
			
		if (strcmp(className, "Test") == 0){
			::test_Test_functions::bindClass(module, className, methods); return;
		}
	}
	if (strcmp(module, "myclass_subpack") == 0){
			
		if (strcmp(className, "Hello") == 0){
			::myclass_subpack_Hello_functions::bindClass(module, className, methods); return;
		}
	}
	if (strcmp(module, "myclass") == 0){
			
		if (strcmp(className, "MySuperClass") == 0){
			::myclass_MySuperClass_functions::bindClass(module, className, methods); return;
		}

			
		if (strcmp(className, "MyClass") == 0){
			::myclass_MyClass_functions::bindClass(module, className, methods); return;
		}
	}

}
WrenForeignMethodFn bindMethod(const char* module, const char *className, const char* signature) {

		if (strcmp(module, "test") == 0){
			
		if (strcmp(className, "Test") == 0){
			return ::test_Test_functions::bindMethod(module, signature);
		}
	}

		if (strcmp(module, "myclass_subpack") == 0){
			
		if (strcmp(className, "Hello") == 0){
			return ::myclass_subpack_Hello_functions::bindMethod(module, signature);
		}
	}

		if (strcmp(module, "myclass") == 0){
			
		if (strcmp(className, "MySuperClass") == 0){
			return ::myclass_MySuperClass_functions::bindMethod(module, signature);
		}

			
		if (strcmp(className, "MyClass") == 0){
			return ::myclass_MyClass_functions::bindMethod(module, signature);
		}
	}

	return NULL;
}
}