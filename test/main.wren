import "foreign/myclass" for MyClass
import "foreign/myclass" for MySuperClass
import "foreign/myclass/subpack" for Hello
import "foreign/test" for Test
import "foreign/wrenegade" for Globals

class TestClass {
    construct new() {
        
    }
    add(x, y){
        System.print(x+y) 
    }

    static callback = (s){
        System.print(s)
    }
}


var mclass = MyClass.new()
var sclass = MySuperClass.new()
mclass.add(5, 40)

mclass.callDyn("test_string")
mclass.callDyn(1080)
mclass.callDyn(mclass)

mclass.graphicsBeginFill(0x00FFFF,  1)

System.print(mclass.prop)
mclass.prop = "hello world"

System.print(mclass.prop)

System.print(mclass.superProp)

mclass.superProp = "super yada!"

System.print(mclass.superProp)

sclass.superProp = "super boom!"


System.print(sclass.superProp)


var hello = Hello.new()



Test.add(5, 20)


var callback = Globals.callback("main", "TestClass", "callback=(_)")
var c = hello.shout(callback)
// c.call()


