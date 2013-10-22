class testscript_mini : object
{
	number num1

	void init(object self)
	{
		result("initialized mini script\n")
	}

}


class testscript : object
{
	number num1
	object atest

	void init(object self)
	{
		result("initialized\n")
		atest = alloc(testscript_mini)
	}

	void printmini(object self)
	{
		atest.init()
	}
	
}


object test1 = alloc(testscript)
test1.init()
test1.printmini()
