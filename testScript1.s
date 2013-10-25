
class userScript:object
{
	string name 
	number iterations
	number state


	// init gets executed on startup of script
	void init(object self)
	{
		name="testscript one"
		result("SPSCRIPT: initialized\n")
		iterations = 0
		state=1
	}
	
	// dialogParameters() asks for script specific parameters, gets executed before init()
	void dialogParameters(object self) 
	{



		//after parameter information is in, call init()
		self.init()
	}

	
	
	// terminations, do not edit, when called, it stops the listener
	void terminate(object self)
	{
		TagGroupSetTagAsNumber( GetPersistentTagGroup(),"SPScript:listener running", 0 )
		result("SPSCRIPT: terminate sent\n")
	}
	
	// listenerDetectImageUpdate() executed by listener when image is updated. this definition is there to detect change. 
	void listenerDetectImageUpdate(object self)
	{
		if (state > 0) //check if initialized
			//increase #iterations
			iterations++
			result("image update detected, testscript called. iteration: "+iterations+"\n")
			
			result("SPSCRIPT: DETECTED CHANGE\n")
			
			// test to terminate after 4 iterations
			if (iterations > 4)
			{
				self.terminate()
			}
		}
	}



	void pause(object self)
	{

	}

}


//object test1 = alloc(userScript)
//test1.init()
//test1.SPSCRIPT_init()

//sleep(10)






