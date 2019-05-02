import "myclass" for MyClass

var mclass = MyClass.new()
mclass.add(5, 40)
mclass.mult(5, 40)
mclass.callDyn("test_string")
mclass.callDyn(1080)
mclass.callDyn(mclass)

System.print(mclass.prop)
mclass.prop = "hello world"

System.print(mclass.prop)

System.print(mclass.superProp)

mclass.superProp = "super yada!"

System.print(mclass.superProp)

