package wren;

// import wren.Wren;
import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;

/**
 * A macro based Wren binding generator
 */
@:keep
@:keepSub
class Wrenegade {
	static var bindWrenPath:String;
	static var bindCPath:String;
	static var bindSignatureMap:Map<String, String>; // funcName, signature
	static var bindMethodMap:Map<String, Array<String>>; // name, args
	// static var bindStaticMethodMap:Map<String, Int>; // name, args
	static var bindCMethodMap:Map<String, String>; // signature , cmethod
	static var foreignFuncsDec:Array<String> = [];
	static var moduleName:String;

	macro static public function bind():Array<Field> {
		moduleName = Context.getLocalClass().toString();

		bindSignatureMap = new Map();
		bindMethodMap = new Map();
		bindCMethodMap = new Map();

		// trace(Context.getBuildFields());
		createPath(Context.getLocalModule());
		createBindInclude();
		return null;
	}

	private static function createPath(file:String) {
		var cdirectory = "bindings/";
		bindCPath = haxe.io.Path.join([cdirectory, "c", file.split(".").join("/")]);
		bindWrenPath = haxe.io.Path.join([cdirectory, "wren", file.split(".").join("/")]);
		FileSystem.createDirectory(bindCPath);
		FileSystem.createDirectory(bindWrenPath);
	}

	private static function createBindInclude() {
		var fields:Array<Field> = Context.getBuildFields();
		for (field in fields) {
			// trace(field);
			// trace(field.kind);

			switch (field.kind) {
				case FFun(f):
					{
						// trace(f);
						var params = [];
						var signature = bindCPath.replace("bindings/c/", "").split("/").join(".");
						var cFuncName = bindCPath.replace("bindings/c/", "").split("/").join("::");
						cFuncName += "::";
						cFuncName += field.name;
						signature += ".";
						signature += field.name;
						signature += "(_";
						var _args = f.args;
						if (_args.length > 0) {
							cFuncName += "(";
							signature += ",";
							for (i in 0..._args.length) {
								var arg = _args[i];
								if (arg != null) {
									cFuncName += 'arg${_args.indexOf(arg)}';
									signature += "_";
									params.push('arg${_args.indexOf(arg)}');
									
									// switch (arg.type) {

									// 	case TPath(p): {
									// 			switch (p.name) {
									// 				case "Dynamic": {
									// 						signature += "_";
									// 						// cFuncName += "::" + p.name;
									// 						// cFuncName += " ";
									// 						cFuncName += 'arg${_args.indexOf(arg)}';
									// 						params.push('arg${_args.indexOf(arg)}');
									// 					};
									// 				case "String": {
									// 						signature += "_";
									// 						// cFuncName += "::" + p.name;
									// 						// cFuncName += " ";
									// 						cFuncName += 'arg${_args.indexOf(arg)}';
									// 						params.push('arg${_args.indexOf(arg)}');
									// 					};
									// 				case "Int": {
									// 						signature += "_";
									// 						// cFuncName += "int ";
									// 						cFuncName += 'arg${_args.indexOf(arg)}';
									// 						params.push('arg${_args.indexOf(arg)}');
									// 					};
									// 				case _:
									// 			}
									// 		}
									// 	case _:
									// }

									if (_args.indexOf(arg) != _args.length - 1) {
										cFuncName += ", ";
										signature += ",";
									}
								}
							}
							cFuncName += ")";
							signature += ")";
						} else {
							cFuncName += "()";
							signature += ")";
						}
						// trace(cFuncName);
						var funcName = bindCPath.replace("bindings/c/", "").split("/").join("_");
						funcName += "_";
						funcName += field.name;
						funcName = funcName.toLowerCase();
						switch (field.access) {
							case [AOverride, AStatic, APublic] | [AStatic, APublic] | [APublic, AStatic]: {
									if (field.name.trim() == "new" || field.name.trim() == "main" || field.name.trim() == "constructor") {
										
									} else {
										bindMethodMap.set(funcName, params);
										bindCMethodMap.set(funcName, cFuncName);
										bindSignatureMap.set(funcName, signature);

										var foreignFunc = "static void ";
										foreignFunc += funcName;
										foreignFunc += "(WrenVM *vm);";
										foreignFuncsDec.push(foreignFunc);
									}
								};
							case _:
						}

						// trace(f.args);

						// trace(bindMethodMap);
						// trace(bindSignatureMap);
					}
				case _:
			}
		}

		var content = new StringBuf();

		content.add('#include "inc.h"');

		content.add("\n");
		content.add("\n");
		for (func in foreignFuncsDec) {
			var sig = func.replace("static void ", "").replace("(WrenVM *vm);", "");
			var params:Array<String> = bindMethodMap.get(sig);
			content.add(func);
			content.add("{");
			content.add("\n");
			content.add("\t");
			content.add('::Dynamic ${params[0]} = (::Dynamic) wrenGetSlotForeign(vm, 0);');
			content.add("\n");
			for (i in 1...params.length) {
				content.add("\t");
				content.add('auto ${params[i]} = linc::wren::getFromSlot(vm, ${i});');
				content.add("\n");
			}
			content.add("\t");
			content.add(bindCMethodMap.get(sig));
			content.add(";");
			content.add("\n");
			content.add("}");
			content.add("\n");
		}
		content.add("\n");
		content.add("\n");
		content.add('WrenForeignMethodFn ${moduleName.split(".").join("_").toLowerCase()}_bindMethod(const char* signature) {');
		content.add("\n");
		for (func in foreignFuncsDec) {
			var sig = func.replace("static void ", "").replace("(WrenVM *vm);", "");
			content.add("\t");
			content.add('if (strcmp(signature, "${bindSignatureMap.get(sig)}") == 0) return ${sig};');
			content.add("\n");
		}
		content.add("\t");
		content.add("return NULL;");
		content.add("\n");
		content.add("}");

		sys.io.File.saveContent('${bindCPath}/functions.c', content.toString());

		var include = new StringBuf();
		include.add('#ifndef ${moduleName.split(".").join("_").toLowerCase()}_h');
		include.add("\n");
		include.add('#define ${moduleName.split(".").join("_").toLowerCase()}_h');
		include.add("\n");
		include.add('#include <hxcpp.h>');
		include.add("\n");
		include.add('extern "C"');
		include.add("\n");
		include.add('{');
		include.add("\n");
		include.add('#include <../lib/wren/src/include/wren.h>');
		include.add("\n");
		include.add('}');
		include.add("\n");
		include.add('WrenForeignMethodFn ${moduleName.split(".").join("_").toLowerCase()}_bindMethod(const char* signature);');
		include.add("\n");
		include.add("#endif");
		sys.io.File.saveContent('${bindCPath}/inc.h', include.toString());
		
	}
}
