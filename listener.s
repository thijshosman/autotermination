

// factory class tht allows generation of script objects (by dialog)

class userScriptFactory : object
{
	//object type
	//number type

	object init(object self, number type)
	{
		object aScript
		if(type == 1)
		{
			aScript = alloc(UserScript)
		}
		return aScript
	}



}

// TESTING

//object aScript1 = alloc(userScriptFactory).init(1)
//aScript1.dialogParameters()



// This is the Event Handler class which responds to the listener.

// this listener calls the specimem prep script functions (init, dialog, listenerDetectImageUpdate)
// these functions are supposed to be user updatetable 

Class MyEventHandler
{
	// Functions responds when the data in img is changed. The event flag has a value of 4
	// img is the image to which the event handler has been added.

	// initialize the user defined script that is going to be called
	
	object aScript
	number counter //a counting variable to keep track of the number of changes (events)
	
	void initUserScript(object self, number scriptType)
	{
		result("LISTENER: inituserscript\n")
		//create userscript object 
		//aScript = alloc(userScript)
		
		//create userscript with factory method
		aScript = alloc(userScriptFactory).init(scriptType)


		//display dialog with script specific parameters
		aScript.dialogParameters()

	}

	void DataChanged(object self, number event_flag, image img)
	{
		
		// notify userScript
		result("LISTENER: Change sent, counter: "+(counter+1)+"\n")
		aScript.listenerDetectImageUpdate()
		counter++
		//{
		//	img.ImageRemoveEventListener()

		//}

		// Each time the image is changed, the counter is incremented. After four changes, the listener is removed
		

		// DEBUG, stop listener after 3 changes
		//if(counter>3)
		//{
		//	img.ImageRemoveEventListener(EventToken)
		//	result("LISTENER: Four changes have been detected - the Listener has been removed.\n")
		//}
	}

 
	// This is the constructor it is invoked when the Listener object is created. In this case
	// it does nothing except report itself in the Results window.
	MyEventHandler( object self)
	{
		Result("LISTENER: Event Handler Constructor called. Listener attached to image.\n")
	}

	// The destructor responds the image has been closed.
	~MyEventHandler(object self)
	{
		
		result("LISTENER: Event Handler Destructor called. Image Closed.\n")
	}


}

// this is the listener class that attaches a listener to the images and manages the event handling

class listenerController
{
	number EventToken //the id of the listener

	// Main script function - this is wrapped in a function to help avoid memory leaks.

	void start(object self, number scriptType)
	{
		//TODO: make sure this function can only be called once

		// Check that at least one image is displayed
		number nodocs=countdocumentwindowsoftype(5)

		if(nodocs<1)
		{
			showalert("Ensure a live image is displayed front-most.",2)
			return
		}

		// Source the front-most image
		image front:= GetFrontImage()

		// Create the event listener object and attach it to the front-most image. The event map describes the mapping
		// of the event to the reponse. The event is data_value_changed - this a predefined event in the DM scripting language
		// DataChanged is the method in the EventHandler Class which is called when the event is detected.
		// EventToken is a numerical id used to identity the listener. It is used to remove the event listener.

		object EventListener=alloc(MyEventHandler)
		string eventmap="data_value_changed:DataChanged"
		
		EventToken = front.ImageAddEventListener(EventListener, eventmap)
		
		// start userscript, ask for script specific parameters and init
		EventListener.initUserScript(scriptType)

	}

	void stop(object self)
	{
		image front := GetFrontImage()
		front.ImageRemoveEventListener(EventToken)
		result("LISTENER:stopped\n")
	}

}

// Main program code

// Start the listener

//object aListener = alloc(listener)

//aListener.start(1)


//number listener_running = 1

// set the Tag
//TagGroupSetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener running", listener_running )
// get the Tag
//TagGroupGetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener running", listener_running )

// check that listener still needs to running
//while(  listener_running && !(spacedown() && shiftdown() ))
//{
//	TagGroupGetTagAsNumber( GetPersistentTagGroup(),"SPScript:listener running", listener_running )
//	sleep(1)
	//DEBUG result("LISTENER:running\n")
//}

// stop the listener
//aListener.stop()
