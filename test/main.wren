import "myclass" for MyClass

var mclass = MyClass.new()
mclass.add(5, 40)
mclass.callDyn("test_string")
mclass.callDyn(1080)
mclass.callDyn(mclass)

// Make sure the handle lives through a GC.
System.gc()

System.print(mclass.prop)
mclass.prop = "hello world"

// Make sure the handle lives through a GC.
System.gc()

System.print(mclass.prop)

