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

	// initialize the user defined script that is going to be called
	object aScript

	void DataChanged(object self, number event_flag, image img)
	{
		
		// notify userScript
		result("LISTENER: Change sent, counter: "+(counter+1)+"\n")
		aScript.listenerDetectImageUpdate()

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


	void initUserScript(object self)
	{
		//create userscript object 
		aScript = alloc(userScript)
		
		//display dialog with script specific parameters
		aScript.dialogParameters()

		//init script (ie set parameters to zero)
		//aScript.init()
	}


}



	
	



// Main script function - this is wrapped in a function to help avoid memory leaks.

void startListener()
{
	//TODO: make sure this function can only be installed once
	


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
	EventListener.initUserScript()

}

void stopListener()
{
	image front := GetFrontImage()
	front.ImageRemoveEventListener(EventToken)
	result("LISTENER:stopped\n")
}



// Main program code

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
	//DEBUG result("LISTENER:running\n")
}

// stop the listener
stopListener()

class ScriptStartDialog : uiframe
{
	TagGroup 	PSDialog, PSDialogItems
	Object		PSDialogWindow
	
	taggroup 	f1, f2	
	object parent
	string filename
			
	object init(object self)
	{
		result("LISTENERDIALOG: initialized\n")
		PsDialog = DLGCreateDialog("Select Script", PSDialogItems)
		
		// create items and add them to dialog
		//D1 = DLGCreateStringField("select")
		f1 = DLGCreateStringField("test").DLGIdentifier( "stringValue" )
		PSDialog.DLGAddElement(f1)
		
		//D2 = DLGCreateIntegerField(1)
		//f2 = DLGCreateRealField(" parameter 2", D2, 2,5,5)
		//PSDialog.DLGAddElement(f2)
		//Number val2 = D2.DLGGetValue()
		
		
		//PSDialog.DLGTableLayout(1,2,0)
		
		taggroup browseButtonTags = DLGCreatePushButton("browse", "OnButtonPressedBrowse")	
		taggroup loadButtonTags = DLGCreatePushButton("load script", "OnButtonPressedLoad")		
		taggroup startButtonTags = DLGCreatePushButton("start", "OnButtonPressedStart")

		PsDialog.DLGAddElement(browseButtonTags)	
		PsDialog.DLGAddElement(loadButtonTags)	
		PsDialog.DLGAddElement(startButtonTags)

		
		dlgenabled(loadButtonTags,1)
		dlgenabled(startButtonTags,1)
		dlgenabled(browseButtonTags,1)
		
		

		//Number bin = Dbin.DLGGetValue()
		return self.super.init(PSDialog)
		
	}
		
	void OnButtonPressedStart(object self)
	{

		
		self.setelementisenabled("start", 0);

		
	}

		void OnButtonPressedLoad(object self)
	{

		filename = f1.DLGGetStringValue()
		result(filename+"\n")
		self.setelementisenabled("start", 0);

		
	}

		void OnButtonPressedBrowse(object self)
	{

		filename = f1.DLGGetStringValue()
		result(filename+"\n")
		self.setelementisenabled("start", 0);
		OpenDialog(filename)
		result(filename+"\n")
		
	}




	void OnButtonPressedStop(object self)
	{


		self.setelementisenabled("run", 1);
		
	}

	void display(object self, string title)
	{
		self.super.display(title)
	}			
		
}

object dlg = alloc(ScriptStartDialog).init()
		dlg.display("test")






