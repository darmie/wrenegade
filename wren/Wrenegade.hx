package wren;

#if macro
import haxe.io.Path;
import sys.io.File;
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
	static var bindClassSignatureMap:Map<String, String> = new Map(); // funcName, signature
	static var bindSignatureMap:Map<String, String> = new Map(); // funcName, signature
	static var bindMethodMap:Map<String, Array<String>> = new Map(); // name, args
	static var bindCMethodMap:Map<String, String> = new Map(); // signature , cmethod
	static var bindCClassMap:Map<String, String> = new Map(); // signature , cmethod
	static var bindCClassArgsMap:Map<String, Array<String>> = new Map();
	static var foreignFuncsDec:Array<String> = [];
	static var foreignConstructorDec:Array<String> = [];
	static var moduleName:String;

	macro static public function bind():Array<Field> {
		moduleName = Context.getLocalClass().toString();

		var _pos =  Context.currentPos();
		var _pos_info = Context.getPosInfos(_pos);
		var _class = Context.getLocalClass();

		var _source_path = Path.directory(_pos_info.file);
		if (!Path.isAbsolute(_source_path)) {
			_source_path = Path.join([Sys.getCwd(), _source_path]);
		}

		_source_path = Path.normalize(_source_path);

		// var _buildXml = '<include name="${_source_path}/../linc/linc_wren.xml"/>';

		// var _buildXml = '
		//  <set name="WREN" value="${_source_path}/../lib/wren" />
		//  <files id="wrenegade">
		// 	<compilerflag value="-I${_source_path}/../bindings/c/"/>
		// 	<file name="${_source_path}/../bindings/c/functions.c" />
		// </files>
		// ';
		// _class.get().meta.add(":buildXml", [{ expr:EConst( CString( '$_buildXml' ) ), pos:_pos }], _pos );

		createPath(Context.getLocalModule());
		createBindInclude();
		return null;
	}

	private static function createPath(file:String) {
		var cdirectory = "bindings/";
		bindCPath = haxe.io.Path.join([cdirectory, "c", file.split(".").join("/")]);
		bindWrenPath = haxe.io.Path.join([cdirectory, "wren", file.split(".").join("/")]);

		FileSystem.createDirectory("bindings/c");
		FileSystem.createDirectory(bindWrenPath);
	}

	private static function createBindInclude() {
		var fields:Array<Field> = Context.getBuildFields();
		for (field in fields) {
			switch (field.kind) {
				case FFun(f):
					{
						var params = [];
						var signature = bindCPath.replace("bindings/c/", "").split("/").join(".");
						var cFuncName = "::";
						cFuncName += bindCPath.replace("bindings/c/", "").split("/").join("::");
						cFuncName+= "_obj";
						cFuncName += "::";
						cFuncName += field.name;
						signature += ".";
						signature += field.name;
						signature += "(";
						var _args = f.args;
						if (_args.length > 0) {
							cFuncName += "(";
							for (i in 0..._args.length) {
								var arg = _args[i];
								if (arg != null) {
									if (_args.indexOf(arg) == 0)
										cFuncName += 'arg${_args.indexOf(arg)}';
									if (_args.indexOf(arg) > 0)
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
							if (signature.split(",").length > 1) {
								signature = signature.split(",").slice(0, signature.split(",").length - 1).join(",");
							}

							signature += ")";
						} else {
							cFuncName += "()";
							signature += ")";
						}
						var funcName = bindCPath.replace("bindings/c/", "").split("/").join("_");
						funcName += "_";
						funcName += field.name;
						funcName = funcName.toLowerCase();
						switch (field.access) {
							case [AOverride, AStatic, APublic] | [AStatic, APublic] | [APublic, AStatic]: {
									if (field.name.trim() == "new" || field.name.trim() == "main" || field.name.trim() == "constructor") {
										if (field.name.trim() == "constructor") {
											bindClassSignatureMap.set(funcName, signature.split("(")[0].replace(".constructor", ""));
											bindCClassMap.set(funcName, cFuncName);
											bindCClassArgsMap.set(funcName, params);
											var foreignFunc = "static void ";
											foreignFunc += funcName;
											foreignFunc += "(WrenVM *vm);";
											foreignConstructorDec.push(foreignFunc);
										}
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
					}
				case _:
			}
		}

		var content = new StringBuf();


		content.add('#include "../../linc/linc_wren.h"');
		content.add("\n");
		content.add('#include "functions.h"');
		content.add("\n");
		content.add('#include <wren/Helper.h>');
		content.add("\n");
		for (inc in bindClassSignatureMap) {
			content.add('#include <${inc.replace(".", "/")}.h>');
			content.add("\n");
		}
		content.add("namespace bindings {");
		content.add("\n");
		content.add("namespace functions {");
		content.add("\n");
		content.add("\n");
		for (func in foreignFuncsDec) {
			var sig = func.replace("static void ", "").replace("(WrenVM *vm);", "");
			var params:Array<String> = bindMethodMap.get(sig);
			content.add(func.replace(";", ""));
			content.add("{");
			content.add("\n");
			content.add("\t");
			content.add('auto value =  wrenGetSlotForeign(vm, 0);');
			content.add("\n");
			content.add("\t");
			content.add('::Dynamic ${params[0]} = (::Dynamic) ::cpp::CreateDynamicPointer(value);');
			content.add("\n");
			for (i in 1...params.length) {
				content.add("\t");
				content.add('auto ${params[i]} = ::wren::Helper_obj::getFromSlot(vm, ${i});');
				content.add("\n");
				// content.add("\t");
				// content.add('::Dynamic ${params[i]} = (::Dynamic) ::cpp::CreateDynamicPointer(value_${params[i]});');
				content.add("\n");
			}
			content.add("\t");
			content.add(bindCMethodMap.get(sig));
			content.add(";");
			content.add("\n");
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
			content.add("wrenSetSlotNewForeign(vm, 0, 0, sizeof(::Dynamic));");
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
			content.add(bindCClassMap.get(sig));
			content.add(";");
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
		content.add('void bindClass(const char* className, WrenForeignClassMethods* methods) {');
		content.add("\n");
		for (func in foreignConstructorDec) {
			var sig = func.replace("static void ", "").replace("(WrenVM *vm);", "");
			content.add("\t");
			content.add('if (strcmp(className, "${bindClassSignatureMap.get(sig)}") == 0) { \n\t\tmethods->allocate = ${sig}; \n \t\treturn; \n\t}');
			content.add("\n");
		}
		content.add("}");
		content.add("\n");
		content.add("}");
		content.add("\n");
		content.add("}");

		sys.io.File.saveContent('bindings/c/functions.cpp', content.toString());

		var include = new StringBuf();
		include.add('#ifndef _bindings_functions_h');
		include.add("\n");
		include.add('#define _bindings_functions_h');
		include.add("\n");
		include.add('#include <hxcpp.h>');
		include.add("\n");
		// include.add('#include "../../linc/linc_wren.h"');
		// include.add("\n");
		include.add('extern "C"');
		include.add("\n");
		include.add('{');
		include.add("\n");
		include.add('#include <../lib/wren/src/include/wren.h>');
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
		include.add('WrenForeignMethodFn bindMethod(const char* signature);');
		include.add("\n");
		include.add("void bindClass(const char* className, WrenForeignClassMethods* methods);");
		include.add("\n");
		include.add('}');
		include.add("\n");
		include.add('}');
		include.add("\n");
		include.add("#endif");
		sys.io.File.saveContent('bindings/c/functions.h', include.toString());
	}
}
#end