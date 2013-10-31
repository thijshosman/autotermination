//sentinel that has to check whether listener is still running and needs to stop
class listenerSentinel : thread
{
	number listener_running
	object aListenerController

	object init(object self, object listenerController)
	{
		listener_running = 1

		// set the Tag
		TagGroupSetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener running", listener_running )
		// get the Tag
		TagGroupGetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener running", listener_running )
		aListenerController = listenerController
		return self
	}

	void RunThread(object self)
	{	
		// check that listener still needs to running
		while(  listener_running && !(spacedown() && shiftdown() ))
		{
			TagGroupGetTagAsNumber( GetPersistentTagGroup(),"SPScript:listener running", listener_running )
			sleep(1)
			//DEBUG 
			result("SENTINEL:running\n")
		}

		// stop the listener
		aListenerController.stop()
	}

	void stop(object self)
	{
		TagGroupSetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener running", 0 )
	}

}




//alloc(listenerSentinel).init().StartThread()









