package wren;

#if (macro && !flash)
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import yaml.Yaml;
import yaml.Parser;
import yaml.util.ObjectMap;
import Type as HaxeType;

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
	static var modules:Array<String> = [];
	static var packageMap:Map<String, String> = new Map();

	macro static public function bind():Array<Field> {
		init();
		createPath(Context.getLocalModule());
		createBindInclude();

		return null;
	}

	private static function init() {
		moduleName = Context.getLocalClass().toString();
		className = moduleName.split(".")[moduleName.split(".").length - 1];

		var dir = Sys.getCwd();
		var env = {dir: dir};
		var config = Path.join([dir, ".wrenconfig"]);
		var config_data:AnyObjectMap = Yaml.read(config);
		bindingsDir = config_data.get("bindpath");
		wrenlibpath = new haxe.Template(config_data.get("wrenlib")).execute(env);
		wrensrcpath = new haxe.Template(config_data.get("wrensrc")).execute(env);
	}

	private static var pack_sigs:Map<String, Array<String>> = new Map();

	private static function createPath(file:String) {
		cpath = Path.join([bindingsDir, "c"]) + "/";
		bindCPath = haxe.io.Path.join([bindingsDir, "c", file.split(".").join("/")]);
		modules.push(bindCPath.replace(cpath, "c/"));
		bindWrenPath = haxe.io.Path.join([wrensrcpath, file.split(".").join("/")]);

		var wren_bindings = new StringBuf();
		var wren_cbindings = new StringBuf();
		wren_bindings.add("#ifndef _WREN_BINDINGS_\n");
		wren_bindings.add("#define _WREN_BINDINGS_\n");
		for (module in modules) {
			var cls = module.replace("c/", "").split("/")[module.replace("c/", "").split("/").length - 1];
			var sig = module.replace("c/", "").replace("/", "_").replace('_${cls}', "");
			var path = 'bindings/${module}';
			FileSystem.createDirectory(path);
			wren_cbindings.add('#include "${module}/${cls}.h"\n');
			if (pack_sigs.exists(sig)) {
				var mod = pack_sigs.get(sig);
				if (mod.indexOf(cls) == -1) {
					mod.push(cls);
				}
				pack_sigs.set(sig, mod);
			} else {
				pack_sigs.set(sig, [cls]);
			}
		}

		wren_cbindings.add('#include "wren_bindings.h"');
		wren_bindings.add("\n");
		wren_bindings.add('extern "C"');
		wren_bindings.add("\n");
		wren_bindings.add('{');
		wren_bindings.add("\n");
		wren_bindings.add('#include <wren.h>');
		wren_bindings.add("\n");
		wren_bindings.add('}');
		wren_bindings.add("\n");
		wren_cbindings.add("\n");
		wren_cbindings.add("namespace wrenegade {");
		wren_bindings.add("namespace wrenegade {");
		wren_cbindings.add("\n");
		wren_bindings.add("\n");
		wren_bindings.add('void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods);');
		wren_cbindings.add('void bindClass(const char* module, const char* className, WrenForeignClassMethods* methods) {');
		wren_cbindings.add("\n");

		for (pack in pack_sigs.keys()) {
			var mod = pack_sigs.get(pack);
			wren_cbindings.add("\t");
			wren_cbindings.add('if (strcmp(module, "${pack}") == 0){');

			for (i in 0...mod.length) {
				wren_cbindings.add("\n");
				wren_cbindings.add("\t");
				var cls = '::${pack}_${mod[i]}_functions::bindClass';

				wren_cbindings.add("\t");
				wren_cbindings.add("\t");
				wren_cbindings.add("\n");
				wren_cbindings.add("\t");
				wren_cbindings.add("\t");
				wren_cbindings.add('if (strcmp(className, "${mod[i]}") == 0){');
				wren_cbindings.add("\n");
				wren_cbindings.add("\t");
				wren_cbindings.add("\t");
				wren_cbindings.add("\t");
				wren_cbindings.add('${cls}(methods); return;');
				wren_cbindings.add("\n");
				wren_cbindings.add("\t");
				wren_cbindings.add("\t");
				wren_cbindings.add("}");
				wren_cbindings.add("\n");
			}

			wren_cbindings.add("\t");
			wren_cbindings.add("}");
			wren_cbindings.add("\n");
		}
		wren_cbindings.add("\n");
		wren_cbindings.add("}");
		wren_bindings.add("\n");
		wren_bindings.add('WrenForeignMethodFn bindMethod(const char* module, const char *className, const char* signature);');
		wren_cbindings.add("\n");
		wren_cbindings.add('WrenForeignMethodFn bindMethod(const char* module, const char *className, const char* signature) {');
		wren_cbindings.add("\n");

		for (pack in pack_sigs.keys()) {
			var mod = pack_sigs.get(pack);
			wren_cbindings.add("\n");
			wren_cbindings.add("\t");
			wren_cbindings.add('if (strcmp(module, "${pack}") == 0){');

			for (i in 0...mod.length) {
				wren_cbindings.add("\n");
				wren_cbindings.add("\t");
				var cls = '::${pack}_${mod[i]}_functions::bindMethod';

				wren_cbindings.add("\t");
				wren_cbindings.add("\t");
				wren_cbindings.add("\n");
				wren_cbindings.add("\t");
				wren_cbindings.add("\t");
				wren_cbindings.add('if (strcmp(className, "${mod[i]}") == 0){');
				wren_cbindings.add("\n");
				wren_cbindings.add("\t");
				wren_cbindings.add("\t");
				wren_cbindings.add("\t");
				wren_cbindings.add('return ${cls}(signature);');
				wren_cbindings.add("\n");
				wren_cbindings.add("\t");
				wren_cbindings.add("\t");
				wren_cbindings.add("}");
				wren_cbindings.add("\n");
			}

			wren_cbindings.add("\t");
			wren_cbindings.add("}");
			wren_cbindings.add("\n");
		}
		wren_cbindings.add("\n");
		wren_cbindings.add("\t");
		wren_cbindings.add("return NULL;");
		wren_cbindings.add("\n");
		wren_cbindings.add("}");
		wren_cbindings.add("\n");
		wren_bindings.add("}");
		wren_cbindings.add("}");
		wren_bindings.add("\n");
		wren_bindings.add("#endif");

		var wren_bindings_xml = new StringBuf();
		wren_bindings_xml.add("<xml>\n");
		wren_bindings_xml.add('\t<set name="WREN" value="${FileSystem.absolutePath(wrenlibpath)}" />\n');
		wren_bindings_xml.add('\t<set name="WREN_BINDINGS" value="${FileSystem.absolutePath(bindingsDir)}" />\n');
		wren_bindings_xml.add("\t<files id='haxe'>\n");
		wren_bindings_xml.add('\t\t<precompiledheader name="wren_bindings" dir="${FileSystem.absolutePath(bindingsDir)}" />\n');
		wren_bindings_xml.add('\t\t<precompiledheader name="wren" dir="${FileSystem.absolutePath(wrenlibpath + "/src/include")}" />\n');
		var bpath = 'bindings';
		for (module in modules) {
			var path = 'bindings/${module}';
			var cls = module.replace("c/", "").split("/")[module.replace("c/", "").split("/").length - 1];
			wren_bindings_xml.add('\t\t<file name="${FileSystem.absolutePath(path)}/${cls}.cpp" />\n');
		}
		wren_bindings_xml.add('\t\t<file name="${FileSystem.absolutePath(bpath)}/wren_bindings.cpp" />\n');
		wren_bindings_xml.add("\t</files>\n");
		wren_bindings_xml.add("</xml>");

		FileSystem.createDirectory(cpath);

		sys.io.File.saveContent('${bindingsDir}/wren_bindings.xml', wren_bindings_xml.toString());
		sys.io.File.saveContent('${bindingsDir}/wren_bindings.h', wren_bindings.toString());
		sys.io.File.saveContent('${bindingsDir}/wren_bindings.cpp', wren_cbindings.toString());

		reset();
	}

	private static function createBindInclude() {
		var fields:Array<Field> = Context.getBuildFields();
		var start = null;

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
							case [APublic] | [AOverride, APublic]: {
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
							signature += ")";
						}
						var funcName = bindCPath.replace(cpath, "").split("/").join("_");
						funcName += "_";
						funcName += field.name;
						funcName = funcName.toLowerCase();
						switch (field.access) {
							case [APublic] | [AOverride, APublic]: {
									if (field.name.trim() == "new") {
										bindClassSignatureMap.set(funcName, signature.split("(")[0].replace(".new", ""));
										bindCClassMap.set(funcName, cFuncName);
										bindCClassArgsMap.set(funcName, params);
										bindSignatureMap.set(funcName, signature);

										bindCModules.set(funcName, moduleName);

										var foreignFunc = "static void ";
										foreignFunc += funcName;
										foreignFunc += "(WrenVM *vm);";
										if (foreignConstructorDec.indexOf(foreignFunc) != -1) {
											// foreignConstructorDec[foreignFunc] = foreignFunc;
										} else {
											foreignConstructorDec.push(foreignFunc);
											packageMap.set(foreignFunc, moduleName.replace(className, ""));
										}
									} else {
										bindMethodMap.set(funcName, params);
										bindCMethodMap.set(funcName, cFuncName);
										bindSignatureMap.set(funcName, signature);

										var foreignFunc = "static void ";
										foreignFunc += funcName;
										foreignFunc += "(WrenVM *vm);";
										if (foreignFuncsDec.indexOf(foreignFunc) != -1) {} else {
											foreignFuncsDec.push(foreignFunc);
											packageMap.set(foreignFunc, moduleName.replace(className, ""));
										}
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
										if (foreignFuncsDec.indexOf(foreignFunc) != -1) {} else {
											foreignFuncsDec.push(foreignFunc);
											packageMap.set(foreignFunc, moduleName.replace(className, ""));
										}
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
										packageMap.set(foreignFunc, moduleName.replace(className, ""));
										var _foreignFunc = "static void ";
										_foreignFunc += funcName + "_get";
										_foreignFunc += "(WrenVM *vm);";
										foreignFuncsDec.push(_foreignFunc);
										packageMap.set(_foreignFunc, moduleName.replace(className, ""));
									}
								case _:
							}
						}
					}
				case _:
			}
		}

		var includes = [];
		var content = new StringBuf();

		if (Reflect.hasField(Context.getLocalClass().get(), "superClass")) {
			if (Context.getLocalClass().get().superClass != null
				&& Context.getLocalClass().get().superClass.t.get().module != "wren.WrenClass") {
				createBindSuperClass(bindCPath, cpath, Context.getLocalClass(), className, moduleName, bindMethodMap, bindCMethodMap, bindSignatureMap, foreignFuncsDec, packageMap,
					runInclude.bind(bindCPath, className, includes[0], foreignFuncsDec, content),
					genContent.bind(moduleName, bindCModules, 
						bindCPath, content, includes, className, bindMethodMap, bindCMethodMap, bindSignatureMap, bindCClassArgsMap, bindClassSignatureMap, foreignFuncsDec, foreignConstructorDec, packageMap));
				return;
			} else {
				
				genContent(moduleName, bindCModules, bindCPath, content, includes, className, bindMethodMap, bindCMethodMap, bindSignatureMap, bindCClassArgsMap, bindClassSignatureMap, foreignFuncsDec, foreignConstructorDec, packageMap);
				return;
			}
		}
	}

	private static function genContent(moduleName:String, bindCModules:Map<String, String> , bindCPath:String, content:StringBuf, includes:Array<String>, className:String,
			bindMethodMap:Map<String, Array<String>>, bindCMethodMap:Map<String, String>, bindSignatureMap:Map<String, String>, bindCClassArgsMap:Map<String, Array<String>>, bindClassSignatureMap:Map<String, String>, foreignFuncsDec:Array<String>, foreignConstructorDec:Array<String>,
			packageMap:Map<String, String>) {

		
		var cModule = moduleName.replace(".", "::");

		content.add('#include "${className}.h"');
		content.add("\n");
		content.add("\n");

		content.add('#include <linc_helper.h>');
		content.add("\n");

		content.add("\n");
		content.add('#ifndef INCLUDED_type\n');
		content.add("#include <Type.h>");
		content.add("\n");
		content.add('#endif\n');
		content.add("\n");
		content.add("\n");
		for (inc in bindCModules) {
			if (includes.indexOf(inc) == -1) {
				content.add('#include <${inc.replace(".", "/").replace("static ", "")}.h>');
				content.add("\n");
				content.add('static WrenHandle* ${inc.replace(".", "_").replace("static ", "")}_handle;');
				content.add("\n");
				includes.push(inc);
			}
		}
		
		content.add("\n");
		content.add('namespace ${includes[0].replace(".", "_").replace("static ", "")}_functions {');
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
					content.add('auto ${params[i]} = linc::helper::getFromSlot(vm, ${i + 1});');
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
						content.add('::${cModule} inst = (::${cModule})linc::helper::getFromSlot(vm, 0);');
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
								content.add('::${cModule} inst = (::${cModule})linc::helper::getFromSlot(vm, 0);\n');
								content.add("\t");
								content.add('auto val = inst->${method};');
							}

							content.add("\n");
							content.add("\t");
							content.add("::ValueType type = ::Type_obj::_hx_typeof(val);");
							content.add("\n");
							content.add("\t");
							content.add('linc::helper::saveToSlot(vm, 0, val, type);');
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
							content.add('*value = linc::helper::getFromSlot(vm, 1);');
							content.add("\n");

							content.add("\t");
							if (method == null) {
								content.add('${bindCMethodMap.get(sig.replace("_set", ""))} = *value;');
							} else {
								content.add('::${cModule} inst = (::${cModule})linc::helper::getFromSlot(vm, 0);\n');
								content.add("\t");
								content.add('inst->${method} = *value;');
							}
							content.add("\n");
						}
					case _:
						{
							content.add("\t");

							if (bindCMethodMap.get(sig) != null) {
								var method = bindCMethodMap.get(sig)
									.split("->")
									.length > 1 ? bindCMethodMap.get(sig)
									.split("->")[1] : null;
								if (method == null) {
									content.add(bindCMethodMap.get(sig));
								} else {
									content.add('::${cModule} inst = (::${cModule})linc::helper::getFromSlot(vm, 0);');
									content.add("\n");
									content.add("\t");
									content.add('${'inst->' + method}');
								}
							}
							content.add(";");
							content.add("\n");
						}
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
				.add('::${bindCModules.get(sig).replace(".", "::")}* constructor = (${bindCModules.get(sig).replace(".", "::")}*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(::${bindCModules.get(sig).replace(".", "::")}));');
			content.add("\n");
			for (i in 0...params.length) {
				content.add("\t");
				content.add('auto value = linc::helper::getFromSlot(vm, ${i + 1});');
				content.add("\n");
				content.add("\t");
				content.add('::Dynamic ${params[i]} = (::Dynamic) value;');
				content.add("\n");
			}
			content.add("\t");
			content.add('::${cModule}_obj obj;');
			content.add("\n");
			content.add("\t");
			content.add('auto data = obj.__new(${params.join(", ")});');
			content.add("\n");
			content.add("\t");
			content.add('std::memcpy(constructor, &data, sizeof(::${bindCModules.get(sig).replace(".", "::")}));');
			content.add("\n");
			content.add("}");
			content.add("\n");
		}
		content.add("\n");
		content.add("\n");
		content.add('WrenForeignMethodFn bindMethod(const char* signature) {');
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

		content.add("\n");
		content.add("\n");
		content.add('void bindClass(WrenForeignClassMethods* methods) {');
		content.add("\n");

		for (func in foreignConstructorDec) {
			var sig = func.replace("static void ", "").replace("(WrenVM *vm);", "");
			var funct = bindClassSignatureMap.get(sig);
			content.add("\t");
			content.add('methods->allocate = ${funct.indexOf("static") != -1 ? "NULL" : sig}; \n \treturn;');
			content.add("\n");
		}
		content.add("}");
		content.add("\n");
		content.add("}");
		content.add("\n");
	

		sys.io.File.saveContent('${bindCPath}/${className}.cpp', content.toString());

		runInclude(bindCPath, className, includes[0], foreignFuncsDec, content);
	}

	private static function runInclude(bindCPath, className, _includes:String, foreignFuncsDec:Array<String>, content:StringBuf) {
		var include = new StringBuf();
		include.add('#ifndef _bindings_${_includes.replace(".", "_").replace("static ", "")}_h');
		include.add("\n");
		include.add('#define _bindings_${_includes.replace(".", "_").replace("static ", "")}_h');
		include.add("\n");
		include.add('#include <hxcpp.h>');
		include.add("\n");
		include.add('#ifndef INCLUDED_haxe_Log\n');
		include.add('#include <haxe/Log.h>\n');
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
		include.add("\n");
		include.add('namespace ${_includes.replace(".", "_").replace("static ", "")}_functions  {');
		include.add("\n");
		for (func in foreignFuncsDec) {
			include.add(func);
			include.add("\n");
		}
		include.add("\n");
		include.add('WrenForeignMethodFn bindMethod(const char* signature);');
		include.add("\n");
		include.add("void bindClass(WrenForeignClassMethods* methods);");
		include.add("\n");
		include.add('}');
		include.add("\n");
		include.add("\n");
		include.add("#endif");

		sys.io.File.saveContent('${bindCPath}/${className}.h', include.toString());
	}

	private static function createBindSuperClass(bindCPath:String, cpath:String, localClass:Ref<ClassType>, className:String, moduleName:String, bindMethodMap, bindCMethodMap,
			bindSignatureMap, foreignFuncsDec, packageMap:Map<String, String>, ?cb, ?cb2) {
		if (localClass.get().superClass.t.get().module != "wren.WrenClass") {
			var fields = localClass.get().superClass.t.get().fields.get();

			for (field in fields) {
				if (field.isPublic) {
					switch (field.kind) {
						case FMethod(k):
							{
								var params = [];
								var signature = "";

								signature += className;
								var cFuncName = "::";
								cFuncName += bindCPath.replace(cpath, "").split("/").join("::");
								cFuncName += "_obj";
								cFuncName += "::";
								cFuncName += "getInstance()";
								cFuncName += "->";
								cFuncName += field.name;
								signature += ".";
								signature += field.name;
								signature += "(";
								switch (field.expr().expr) {
									case TFunction(f): {
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
												signature += ")";
											}
											var funcName = bindCPath.replace(cpath, "").split("/").join("_");
											funcName += "_";
											funcName += field.name;
											funcName = funcName.toLowerCase();
											bindMethodMap.set(funcName, params);
											bindCMethodMap.set(funcName, cFuncName);
											bindSignatureMap.set(funcName, signature);

											var foreignFunc = "static void ";
											foreignFunc += funcName;
											foreignFunc += "(WrenVM *vm);";
											foreignFuncsDec.push(foreignFunc);
											packageMap.set(foreignFunc, moduleName.replace(className, ""));
										}
									case _:
								}
							}
						case FVar(r, w):
							{
								var params = [];
								var signature = "";
								signature += className;
								var cFuncName = "::";
								cFuncName += bindCPath.replace(cpath, "").split("/").join("::");
								cFuncName += "_obj";
								cFuncName += "::";
								cFuncName += "getInstance()";
								cFuncName += "->";

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
								packageMap.set(foreignFunc, moduleName.replace(className, ""));
								var _foreignFunc = "static void ";
								_foreignFunc += funcName + "_get";
								_foreignFunc += "(WrenVM *vm);";
								foreignFuncsDec.push(_foreignFunc);
								packageMap.set(_foreignFunc, moduleName.replace(className, ""));
							}
					}
				}
			}
		}

		if (Reflect.hasField(localClass.get().superClass.t.get(), "superClass")) {
			if (localClass.get().superClass.t.get().superClass != null
				&& localClass.get().superClass.t.get().superClass.t.get().module != "wren.WrenClass") {
				createBindSuperClass(bindCPath, cpath, localClass, className, moduleName, bindMethodMap, bindCMethodMap, bindSignatureMap, foreignFuncsDec, packageMap, cb, cb2);
			} else {
				cb2();
			}
		}
	}

	private static function reset() {
		bindClassSignatureMap = new Map(); // funcName, signature
		bindSignatureMap = new Map(); // funcName, signature
		bindMethodMap = new Map(); // name, args
		bindCMethodMap = new Map(); // signature , cmethod
		bindCClassMap = new Map(); // signature , cmethod
		bindCClassArgsMap = new Map();
		foreignFuncsDec = [];
		foreignConstructorDec = [];
		bindCModules = new Map();
		packageMap = new Map();
	}
}
#end
