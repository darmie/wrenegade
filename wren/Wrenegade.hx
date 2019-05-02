package wren;

#if macro
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Context;
import yaml.Yaml;
import yaml.Parser;
import yaml.util.ObjectMap;

using StringTools;

/**
 * A macro based Wren binding generator
 */
@:keep
@:keepSub
class Wrenegade {
	static var bindingsDir:String;
	static var bindWrenPath:String;
	static var bindCPath:String;
	static var bindClassSignatureMap:Map<String, String> = new Map(); // funcName, signature
	static var bindSignatureMap:Map<String, String> = new Map(); // funcName, signature
	static var bindMethodMap:Map<String, Array<String>> = new Map(); // name, args
	static var bindCMethodMap:Map<String, String> = new Map(); // signature , cmethod
	static var bindCClassMap:Map<String, String> = new Map(); // signature , cmethod
	static var bindCClassArgsMap:Map<String, Array<String>> = new Map();
	static var foreignFuncsDec:Array<String> = [];
	static var foreignConstructorDec:Array<String> = [];
	static var moduleName:String;
	static var bindCModules:Map<String, String> = new Map();
	static var className:String;
	static var cpath:String;
	static var wrenlibpath:String;
	static var wrensrcpath:String;

	macro static public function bind():Array<Field> {
		moduleName = Context.getLocalClass().toString();
		className = moduleName.split(".")[moduleName.split(".").length - 1];

		var dir = Sys.getCwd();
		var env = {dir: dir};
		var config = Path.join([dir, ".wrenconfig"]);
		var config_data:AnyObjectMap = Yaml.read(config);
		bindingsDir = config_data.get("bindpath");
		wrenlibpath = new haxe.Template(config_data.get("wrenlib")).execute(env);
		wrensrcpath = new haxe.Template(config_data.get("wrensrc")).execute(env);

		createPath(Context.getLocalModule());
		createBindInclude();
		return null;
	}

	private static function createPath(file:String) {
		cpath = Path.join([bindingsDir, "c"]) + "/";
		bindCPath = haxe.io.Path.join([bindingsDir, "c", file.split(".").join("/")]);
		bindWrenPath = haxe.io.Path.join([wrensrcpath, file.split(".").join("/")]);

		var wren_bindings = new StringBuf();
		wren_bindings.add("#ifndef _WREN_BINDINGS_\n");
		wren_bindings.add("#define _WREN_BINDINGS_\n");
		wren_bindings.add('#include "c/functions.h"\n');
		wren_bindings.add("#endif");

		var wren_bindings_xml = new StringBuf();
		wren_bindings_xml.add("<xml>\n");
		wren_bindings_xml.add('\t<set name="WREN" value="${FileSystem.absolutePath(wrenlibpath)}" />\n');
		wren_bindings_xml.add('\t<set name="WREN_BINDINGS" value="${FileSystem.absolutePath(bindingsDir)}" />\n');
		wren_bindings_xml.add("\t<files id='haxe'>\n");
		wren_bindings_xml.add('\t\t<precompiledheader name="wren_bindings" dir="${FileSystem.absolutePath(bindingsDir)}" />\n');
		wren_bindings_xml.add('\t\t<precompiledheader name="wren" dir="${FileSystem.absolutePath(wrenlibpath + "/src/include")}" />\n');
		// wren_bindings_xml.add('\t\t<compilerflag value="-I${FileSystem.absolutePath(bindingsDir)}/wren_bindings.h"/>\n');
		wren_bindings_xml.add('\t\t<file name="${FileSystem.absolutePath(cpath)}/functions.cpp" />\n');
		wren_bindings_xml.add("\t</files>\n");
		wren_bindings_xml.add("</xml>");

		FileSystem.createDirectory(cpath);
		// FileSystem.createDirectory(bindWrenPath);

		sys.io.File.saveContent('${bindingsDir}/wren_bindings.xml', wren_bindings_xml.toString());
		sys.io.File.saveContent('${bindingsDir}/wren_bindings.h', wren_bindings.toString());
	}

	private static function createBindInclude() {
		var fields:Array<Field> = Context.getBuildFields();

		for (field in fields) {
			switch (field.kind) {
				case FFun(f):
					{
						var params = [];
						var signature = "";
						switch (field.access) {
							case [AOverride, AStatic, APublic] | [AStatic, APublic] | [APublic, AStatic]: {
									signature += "static ";
								}
							case _:
						}

						signature += className;
						var cFuncName = "::";
						cFuncName += bindCPath.replace(cpath, "").split("/").join("::");
						cFuncName += "_obj";
						cFuncName += "::";
						switch (field.access) {
							case [APublic]: {
									if (field.name.trim() != "new") {
										cFuncName += "getInstance()";
										cFuncName += "->";
									}
								}
							case _:
						}
						if (field.name.trim() != "new") {
							cFuncName += field.name;
						} else {
							cFuncName += "__";
							cFuncName += field.name;
						}
						signature += ".";
						signature += field.name;
						signature += "(";
						var _args = f.args;
						if (_args.length > 0) {
							cFuncName += "(";
							for (i in 0..._args.length) {
								var arg = _args[i];
								if (arg != null) {
									cFuncName += 'arg${_args.indexOf(arg)}';
									signature += "_";
									params.push('arg${_args.indexOf(arg)}');

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
							signature += "_)";
						}
						var funcName = bindCPath.replace(cpath, "").split("/").join("_");
						funcName += "_";
						funcName += field.name;
						funcName = funcName.toLowerCase();
						switch (field.access) {
							case [APublic]: {
									if (field.name.trim() == "new") {
										bindClassSignatureMap.set(funcName, signature.split("(")[0].replace(".new", ""));
										bindCClassMap.set(funcName, cFuncName);
										bindCClassArgsMap.set(funcName, params);
										bindSignatureMap.set(funcName, signature);

										bindCModules.set(funcName, moduleName);

										var foreignFunc = "static void ";
										foreignFunc += funcName;
										foreignFunc += "(WrenVM *vm);";
										foreignConstructorDec.push(foreignFunc);
									} else {
										bindMethodMap.set(funcName, params);
										bindCMethodMap.set(funcName, cFuncName);
										bindSignatureMap.set(funcName, signature);

										var foreignFunc = "static void ";
										foreignFunc += funcName;
										foreignFunc += "(WrenVM *vm);";
										foreignFuncsDec.push(foreignFunc);
									}
								}
							case [AOverride, AStatic, APublic] | [AStatic, APublic] | [APublic, AStatic]: {
									if (field.name.trim() == "new" || field.name.trim() == "main") {} else if (field.name.trim() != "getInstance") {
										bindMethodMap.set(funcName, params);
										bindCMethodMap.set(funcName, cFuncName);
										bindSignatureMap.set(funcName, signature);
										bindCModules.set(funcName, moduleName);

										var foreignFunc = "static void ";
										foreignFunc += funcName;
										foreignFunc += "(WrenVM *vm);";
										foreignFuncsDec.push(foreignFunc);
									} else if (field.name.trim() == "getInstance") {
										bindCClassArgsMap.set(funcName, params);
										bindCModules.set(funcName, moduleName);

										var foreignFunc = "static void ";
										foreignFunc += funcName;
										foreignFunc += "(WrenVM *vm);";
									}
								};
							case _:
						}
					}
				case FVar(v):
					{
						if (field.name != "instance") {
							var params = [];
							var signature = "";
							switch (field.access) {
								case [AOverride, AStatic, APublic] | [AStatic, APublic] | [APublic, AStatic]: {
										signature += "static ";
									}
								case _:
							}

							signature += className;
							var cFuncName = "::";
							cFuncName += bindCPath.replace(cpath, "").split("/").join("::");
							cFuncName += "_obj";
							cFuncName += "::";
							switch (field.access) {
								case [APublic]: {
										if (field.name.trim() != "new") {
											cFuncName += "getInstance()";
											cFuncName += "->";
										}
									}
								case _:
							}

							cFuncName += field.name;
							signature += ".";
							signature += field.name;
							signature += "=(";
							signature += "_)";

							var funcName = bindCPath.replace(cpath, "").split("/").join("_");
							funcName += "_";
							funcName += field.name;
							funcName = funcName.toLowerCase();

							bindMethodMap.set(funcName, null);
							bindCMethodMap.set(funcName, cFuncName);
							bindSignatureMap.set(funcName + "_set", signature);
							bindSignatureMap.set(funcName + "_get", signature.replace("=(_)", ""));

							var foreignFunc = "static void ";
							foreignFunc += funcName + "_set";
							foreignFunc += "(WrenVM *vm);";
							foreignFuncsDec.push(foreignFunc);
							var _foreignFunc = "static void ";
							_foreignFunc += funcName + "_get";
							_foreignFunc += "(WrenVM *vm);";
							foreignFuncsDec.push(_foreignFunc);
						}
					}
				case _:
			}
		}

		var content = new StringBuf();

		var cModule = moduleName.replace(".", "::");

		content.add('#include "functions.h"');
		content.add("\n");
		content.add('#include <wren/Helper.h>');
		content.add("\n");
		var includes = [];
		for (inc in bindCModules) {
			if (includes.indexOf(inc) == -1) {
				content.add('#include <${inc.replace(".", "/").replace("static ", "")}.h>');
				content.add("\n");
				content.add('static WrenHandle* ${inc.replace(".", "_").replace("static ", "")}_handle;');
				content.add("\n");
				includes.push(inc);
			}
		}
		content.add("namespace bindings {");
		content.add("\n");
		content.add("namespace functions {");
		content.add("\n");
		content.add("\n");
		for (func in foreignFuncsDec) {
			var sig = func.replace("static void ", "").replace("(WrenVM *vm);", "");
			var params:Array<String> = bindMethodMap.exists(sig) ? bindMethodMap.get(sig) : [];
			content.add("\n");
			content.add(func.replace(";", ""));
			content.add("{");
			content.add("\n");
			content.add("\t");
			content.add("\n");

			if (params.length != 0) {
				for (i in 0...params.length) {
					content.add("\t");
					content.add('auto ${params[i]} = ::wren::Helper_obj::getFromSlot(vm, ${i + 1});');
					content.add("\n");
				}
				content.add("\t");

				if (bindCMethodMap.get(sig) != null) {
					var method = bindCMethodMap.get(sig)
						.split("->")
						.length > 1 ? bindCMethodMap.get(sig)
						.split("->")[1] : null;
					if (method == null) {
						content.add(bindCMethodMap.get(sig));
					} else {
						content.add('${cModule} inst = (${cModule})::wren::Helper_obj::getFromSlot(vm, 0);');
						content.add("\n");
						content.add("\t");
						content.add('${'inst->' + method}');
					}
				}
				content.add(";");
				content.add("\n");
			} else {
				var _sig = sig.split("_");
				var prop_type = _sig[_sig.length - 1];
				var cval = cModule.replace("::", "_").replace("static ", "") + "_handle";
				var method = null;
				switch (prop_type) {
					case "get":
						{
							
							if (bindCMethodMap.get(sig.replace("_get", "")) != null) {
								method = bindCMethodMap.get(sig.replace("_get", ""))
									.split("->")
									.length > 1 ? bindCMethodMap.get(sig.replace("_get", ""))
									.split("->")[1] : null;
							}
							content.add("\t");
							if (method == null) {
								content.add('${bindCMethodMap.get(sig.replace("_get", ""))} = *value;');
							} else {
								content.add('${cModule} inst = (${cModule})::wren::Helper_obj::getFromSlot(vm, 0);\n');
								content.add("\t");
								content.add('auto val = inst->${method};');
							}
							// content.add('auto val = ${bindCMethodMap.get(sig.replace("_get", ""))};');
							content.add("\n");
							content.add("\t");
							content.add("::ValueType type = ::Type_obj::_hx_typeof(val);");
							content.add("\n");
							content.add("\t");
							content.add('::wren::Helper_obj::saveToSlot(vm, 0, val, type);');
							content.add("\n");
						}
					case "set":
						{
							if (bindCMethodMap.get(sig.replace("_set", "")) != null) {
								method = bindCMethodMap.get(sig.replace("_set", ""))
									.split("->")
									.length > 1 ? bindCMethodMap.get(sig.replace("_set", ""))
									.split("->")[1] : null;
							}
							content.add("\t");
							content.add('::Dynamic* value = (::Dynamic*)wrenGetSlotForeign(vm, 1);');
							content.add("\n");
							content.add("\t");
							content.add('*value = ::wren::Helper_obj::getFromSlot(vm, 1);');
							content.add("\n");
							// content.add("\t");
							// content.add('::haxe::Log_obj::trace(*value);');
							// content.add("\n");
							content.add("\t");
							if (method == null) {
								content.add('${bindCMethodMap.get(sig.replace("_set", ""))} = *value;');
							} else {
								content.add('${cModule} inst = (${cModule})::wren::Helper_obj::getFromSlot(vm, 0);\n');
								content.add("\t");
								content.add('inst->${method} = *value;');
							}
							content.add("\n");
						}
					case _:
				}
			}
			content.add("}");
			content.add("\n");
		}
		for (func in foreignConstructorDec) {
			var sig = func.replace("static void ", "").replace("(WrenVM *vm);", "");
			var params:Array<String> = bindCClassArgsMap.get(sig);
			content.add(func.replace(";", ""));
			content.add("{");
			content.add("\n");
			content.add("\t");
			content
				.add('${bindCModules.get(sig).replace(".", "::")}* constructor = (${bindCModules.get(sig).replace(".", "::")}*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(${bindCModules.get(sig).replace(".", "::")}));');
			content.add("\n");
			for (i in 0...params.length) {
				content.add("\t");
				content.add('auto value = ::wren::Helper_obj::getFromSlot(vm, ${i + 1});');
				content.add("\n");
				content.add("\t");
				content.add('::Dynamic ${params[i]} = (::Dynamic) value;');
				content.add("\n");
			}
			content.add("\t");
			content.add('auto data = ${bindCClassMap.get(sig)};');
			content.add("\n");
			content.add("\t");
			content.add('std::memcpy(constructor, &data, sizeof(${bindCModules.get(sig).replace(".", "::")}));');
			content.add("\n");
			content.add("}");
			content.add("\n");
		}
		content.add("\n");
		content.add("\n");
		content.add('WrenForeignMethodFn bindMethod(const char* module, const char* signature) {');
		content.add("\n");
		for (func in foreignFuncsDec) {
			var sig = func.replace("static void ", "").replace("(WrenVM *vm);", "");
			var _sig = sig.split("_");
			var module = "main";
			if (_sig.length > 2) {
				module = _sig[0];
			}
			content.add("\t");
			content.add('if (strcmp(module, "$module") == 0){');
			content.add("\t");
			content.add("\t");
			content.add('if (strcmp(signature, "${bindSignatureMap.get(sig)}") == 0) return ${sig};');
			content.add("\t");
			content.add("}");
			content.add("\n");
		}
		content.add("\t");
		content.add("return NULL;");
		content.add("\n");
		content.add("}");

		content.add("\n");
		content.add("\n");
		content.add('void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods) {');
		content.add("\n");

		for (func in foreignConstructorDec) {
			var sig = func.replace("static void ", "").replace("(WrenVM *vm);", "");
			var funct = bindClassSignatureMap.get(sig);
			var _f = funct.split(".");
			var _sig = sig.split("_");
			var module = "main";
			if (_sig.length > 2) {
				module = _sig[0];
			}
			content.add("\t");
			content.add('if (strcmp(module, "$module") == 0){');
			content.add("\n");
			content.add("\t");
			content.add("\t");
			content
				.add('if (strcmp(className, "${funct.indexOf("static") != -1 ? funct.replace("static ", "") : _f[_f.length - 1]}") == 0) { \n\t\t\tmethods->allocate = ${funct.indexOf("static") != -1 ? "NULL" : sig}; \n \t\t\treturn; \n\t\t}');
			content.add("\n");
			content.add("\t");
			content.add("}");
			content.add("\n");
		}
		content.add("}");
		content.add("\n");
		content.add("}");
		content.add("\n");
		content.add("}");

		sys.io.File.saveContent('${cpath}/functions.cpp', content.toString());

		var include = new StringBuf();
		include.add('#ifndef _bindings_functions_h');
		include.add("\n");
		include.add('#define _bindings_functions_h');
		include.add("\n");
		include.add('#include <hxcpp.h>');
		include.add("\n");
		include.add('#ifndef INCLUDED_haxe_Log\n');
		include.add('#include <haxe/Log.h>\n');
		include.add('#endif');
		include.add("\n");
		include.add('#ifndef INCLUDED_Type\n');
		include.add('#include <Type.h>\n');
		include.add('#endif');
		include.add("\n");
		include.add('extern "C"');
		include.add("\n");
		include.add('{');
		include.add("\n");
		include.add('#include <wren.h>');
		include.add("\n");
		include.add('}');
		include.add("\n");
		include.add("namespace bindings {");
		include.add("\n");
		include.add("namespace functions {");
		include.add("\n");
		for (func in foreignFuncsDec) {
			include.add(func);
			include.add("\n");
		}
		include.add("\n");
		include.add('WrenForeignMethodFn bindMethod(const char* module, const char* signature);');
		include.add("\n");
		include.add("void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods);");
		include.add("\n");
		include.add('}');
		include.add("\n");
		include.add('}');
		include.add("\n");
		include.add("#endif");
		sys.io.File.saveContent('${cpath}/functions.h', include.toString());
	}
}
#end
