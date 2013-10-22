
class userScript:object
{
	string name 
	number iterations
	number state



	void init(object self)
	{
		name="testscript one"
		result("SPSCRIPT: initialized\n")
		
	}
	
	// SPSCRIPT_dialogParameters() 
	void dialogParameters(object self) 
	{
		
	}

	// init gets executed on startup of script
	void SPSCRIPT_init(object self)
	{
		

		



		//TagGroupSetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener running", listener_running )

		result("starting script: "+ name+"\n")



	}

	// SPSCRIPT_listenerDetectImageUpdate() executed by listener when image is updated. this definition is there to detect change. 
	void SPSCRIPT_listenerDetectImageUpdate(object self)
	{
		result("image update detected, testscript called. iteration: "+iterations+"\n")
		

		number state
		TagGroupGetTagAsNumber( GetPersistentTagGroup(), "SPScript:state", state )


		//return false to keep script running

	}

}


object test1 = alloc(userScript)
test1.init()
test1.SPSCRIPT_init()

sleep(10)



