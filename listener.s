// $BACKGROUND$

number EventToken //the id of the listener
number counter //a counting variable to keep track of the number of changes (events)

// This is the Event Handler class which responds to the listener.

// this listener calls the specimem prep script functions (init, dialog, listenerDetectImageUpdate)
// these functions are supposed to be user updatetable 

Class MyEventHandler

{
	// Functions responds when the data in img is changed. The event flag has a value of 4
	// img is the image to which the event handler has been added.

	void DataChanged(object self, number event_flag, image img)
	{
		//number sumval=sum(img)
		result("LISTENER: Change: "+(counter+1)+"\n")
		SPSCRIPT_listenerDetectImageUpdate()
		//{
		//	img.ImageRemoveEventListener()

		//}

		// Each time the image is changed, the counter is incremented. After four changes, the listener is removed
		counter=counter+1

		// DEBUG, stop listener after 3 changes
		if(counter>3)
		{
			img.ImageRemoveEventListener(EventToken)
			result("LISTENER: Four changes have been detected - the Listener has been removed.\n")
		}
	}

	//void(object self, image img)

 
	// This is the constructor it is invoked when the Listener object is created. In this case
	// it does nothing except report itself in the Results window.
	MyEventHandler( object self)
	{
		Result("LISTENER: Event Handler Constructor called. Listener attached to image.\n")
	}

	// The destructor responds when either four changes have been detected or the image has been closed.
	~MyEventHandler(object self)
	{
		// if(counter>3) result("LISTENER: Event Handler Destructor called. Four changes detected.\n")
		result("LISTENER: Event Handler Destructor called. Image Closed.\n")
	}

}



	
	



	// Main script function - this is wrapped in a function to help avoid memory leaks.
	
	void startListener()
	{
		// dialog, ask for script specific parameters
		//SPSCRIPT_dialogParameters()
		
		// init script
		//SPSCRIPT_init()

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


	}

	void stopListener()
	{
		image front := GetFrontImage()
		front.ImageRemoveEventListener(EventToken)
		result("LISTENER:stopped\n")
	}



// Main program

// Start the listener
startListener()


number listener_running = 1
// set the Tag
TagGroupSetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener running", listener_running )
// get the Tag
TagGroupGetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener running", listener_running )

// check that listener still needs to running
while(  listener_running && !(spacedown() && shiftdown() ))
{
	TagGroupGetTagAsNumber( GetPersistentTagGroup(),"SPScript:listener running", listener_running )
	sleep(1)
	result("LISTENER:running\n")
}

// stop the listener
stopListener()







