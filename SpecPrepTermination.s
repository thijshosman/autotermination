


class userScript:object
{
	string name 
	number iterations
	number state
	string feedback
	object dlg

	void setStatus(object self)
	{
		OpenAndSetProgressWindow(name,feedback,"Iteration: "+iterations)
	}
	
	void userScript(object self)
	{
		name="testscript"
		feedback="paused"
		state = 0
		self.setStatus()
	}



	// init gets executed when script is started
	void init(object self, number value)
	{
		feedback = "initialized"
		self.setStatus()

		result("SPSCRIPT"+datestamp()+": Starting\n")
		state = 1
	}
	
	// dialogParameters() asks for script specific parameters, gets executed before init() and calls init
	void dialogParameters(object self) 
	{
		result("SPSCRIPT: dialog started\n")
		
		// dialog object created, this object will call init when parameters are set
		dlg = alloc(scriptParameterEntryDialog).init(self)
		dlg.display("Testcase")

	}

	void stopRunning(object self) 
	{
		feedback = "script stopped"
		self.setStatus()
		state = 0
		result("SPSCRIPT: stopped\n")
		
	}

	
	
	// terminations, do not edit, when called, it stops the listener
	void terminate(object self)
	{
		// stop this script from listening
		self.stopRunning()
		
		// stop PIPS, whether recipe or milling
		PIPS_stoprecipe()
		PIPS_StopMilling()
		feedback = "terminated milling, script stopped"
		self.setStatus()

		result("SPSCRIPT: terminate sent\n")
	}
	
	// listenerDetectImageUpdate() executed by listener when image is updated. this definition is there to detect change. 
	void listenerDetectImageUpdate(object self)
	{
		if (state > 0) //check if initialized
		{
			iterations++
			feedback = "running"
			self.setStatus()
			result ("SPSCRIPT: I am called by listener\n")

		}

	}



	void pause(object self)
	{
		PIPS_PauseRecipe()
		result("SPSCRIPT: script paused\n")
	}
	
	void resume(object self)
	{
		PIPS_ResumeRecipe()
		result("SPSCRIPT: script resumed\n")
	}

}


//object test1 = alloc(testscript1)
//test1.dialogParameters()


//test1.init()
//test1.SPSCRIPT_init()

//sleep(10)


class scriptParameterEntryDialog : uiframe
{
	TagGroup 	PSDialog, PSDialogItems
	Object		PSDialogWindow
	taggroup	D1, D2
	taggroup 	f1, f2	
	object parent
	number val1
	
	void makeButtons(object self)
	{
		// create items and add them to dialog
		D1 = DLGCreateIntegerField(1)
		f1 = DLGCreateIntegerField("testscript, nothing to specify", D1, 1,5)
		PSDialog.DLGAddElement(f1)
		
		//D2 = DLGCreateIntegerField(1)
		//f2 = DLGCreateRealField(" parameter 2", D2, 2,5,5)
		//PSDialog.DLGAddElement(f2)
		//Number val2 = D2.DLGGetValue()
		
		//PSDialog.DLGTableLayout(1,2,0)
		
		taggroup runButtonTags = DLGCreatePushButton("Run", "OnButtonPressedRun")
		PsDialog.DLGAddElement(runButtonTags)
		dlgidentifier(runButtonTags, "run")
		dlgenabled(runButtonTags,1)

		taggroup stopButtonTags = DLGCreatePushButton("Stop", "OnButtonPressedStop")
		PsDialog.DLGAddElement(stopButtonTags)
		dlgidentifier(stopButtonTags, "stop")
		dlgenabled(stopButtonTags,0)

		taggroup pauseButtonTags = DLGCreatePushButton("Pause", "OnButtonPressedPause")
		taggroup resumeButtonTags = DLGCreatePushButton("Resume", "OnButtonPressedResume")
		

		



		//PsDialog.DLGAddElement(pauseButtonTags)
		//PsDialog.DLGAddElement(resumeButtonTags)
		
		//dlgenabled(pauseButtonTags,0)
		//dlgenabled(resumeButtonTags,0)
		
		//dlgidentifier(pauseButtonTags, "pause")
		//dlgidentifier(resumeButtonTags, "resume")
		
		

		//Number bin = Dbin.DLGGetValue()
		
		
	}

	object init(object self, object aParent)
	{
		//result("PARAMETERENTRYDIALOG: initialized\n")
		PsDialog = DLGCreateDialog("Enter parameters", PSDialogItems)
		
		parent = aParent
		self.makeButtons()

		return self.super.init(PSDialog)
	}
	


	void OnButtonPressedRun(object self)
	{

		val1 = D1.DLGGetValue()
		parent.init(val1)
		self.setelementisenabled("run", 0);
		//self.setelementisenabled("pause", 1);
		//self.setelementisenabled("resume", 1);
		self.setelementisenabled("stop", 1);
		
	}

	void OnButtonPressedPause(object self)
	{

		parent.pause()
		
	}

	void OnButtonPressedResume(object self)
	{

		parent.resume()
		
	}
	
	void OnButtonPressedStop(object self)
	{

		parent.stopRunning()
		self.setelementisenabled("run", 1);
		self.setelementisenabled("stop", 0);
		
	}

	void display(object self, string title)
	{
		self.super.display(title)
	}			
		
}

// following classes are support classes for the listener framework

// simulator, not used for modeless dialog

class simulateStack : thread
{
	number running

	object init( object self, number value )   

	{     

		running = 1   

		return self   

	}  

	

	void runThread(object self)
	{
	// get directory

		// allow us to stop the thread
		//TagGroupGetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener running", running )
		
		
		String defDir = GetApplicationDirectory("current", 0)
		//String defDir = ""
		String inDir
		

		if (!GetDirectoryDialog("Select Directory of Image Stack", defDir, inDir)) 
			exit(0)
		
		//inDir = "C:\Users\thosman\Documents\PIPS 2\sample data\cu perforation stack\Part 3\" //"
		
		result(indir+"\n")

		TagGroup imageList = NewTagList()
		Number flags = 3
		imageList = GetFilesInDirectory(inDir, flags)

		Number nFiles = TagGroupCountTags(imageList)
		result("SIMULATOR: number of images"+nFiles+"\n")

		if (nFiles == 0)
		{
			OkDialog("No Files Found in directory \n"+inDir)
			exit(0)
		}	
		
		
		
		// open first image 
		//	image simulateStack := openImage()
		Image simulateStack 
		//= GetFrontImage()
		//simulateStack.showImage()
		
		
		
		// show each image		
		number i
		for (i=0; i<nFiles; i++)
		{
			TagGroup tg
			imageList.TagGroupGetIndexedTagAsTagGroup(i, tg)
			String fileName
			TagGroupGetTagAsString(tg,"Name", fileName)
			fileName = inDir + fileName
			result("SIMULATOR: "+filename+"\n")
			simulateStack = OpenImage(fileName) 
			simulateStack.SetName("SimulateStack "+i)
			showImage(simulateStack)
			sleep(5)

			if ((optiondown() && shiftdown()) || running ==0)
			{
				result("SIMULATOR: aborted\n")
				break
			}
			
		}

	}
	void stop(object self)
	{
		running = 0
	}
}




// factory class tht allows generation of script objects (by dialog)

class userScriptFactory : object
{
	//object type
	//number type

	object init(object self, number type)
	{
		object aScript
		if(type == 4)
		{
			aScript = alloc(UserScript)
		}
		if(type == 0)
		{
			aScript = alloc(ROIIntensityAve)
		} 
		if(type == 1)
		{
			aScript = alloc(ROIIntensityPixels)
		}
		if(type == 2)
		{
			aScript = alloc(PlanarFringe)
		}
		if(type == 3)
		{
			aScript = alloc(glueline)
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
	
	object Script
	number counter //a counting variable to keep track of the number of changes (events)
	number record_buffer_size
	//number simulation

	void initUserScript(object self, object aScript, number s)
	{
		//result("Image listener started\n")

		//display dialog with script specific parameters
		Script = aScript
		Script.dialogParameters()

	}

	void DataChanged(object self, number event_flag, image img)
	{
		
		// notify userScript, but only once independent of size of buffer
		// for now, we just set it to 1 in the welcome window
		
		TagGroupGetTagAsNumber( GetPersistentTagGroup(), "PIPS:Record:Buffer size", record_buffer_size )
		
		// debug("LISTENER: Change, counter: "+(counter+1)+"\n")
		
		if (!(counter%record_buffer_size))
		{
			// debug("LISTENER: Change sent, counter: "+(counter+1)+"\n")
			Script.listenerDetectImageUpdate()
		}
		counter++

	}

 
	// This is the constructor it is invoked when the Listener object is created. In this case
	// it does nothing except report itself in the Results window.
	MyEventHandler(object self)
	{
		//debug("Listener attached to image.\n")
	}

	// The destructor responds the image has been closed.
	~MyEventHandler(object self)
	{
		
		//debug("Listener removed. Image Closed.\n")
	}


}

// this is the listener class that attaches a listener to the images and manages the event handling

class listenerController
{
	number EventToken //the id of the listener

	// Main script function - this is wrapped in a function to help avoid memory leaks.

	void start(object self, object aScript, number simulation)
	{

		// kill previous eventtokens so that we are sure there is only 1 listener running at the same time

		// get the Tag
		TagGroupGetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener id", EventToken )

		// Check that at least one image is displayed
		number nodocs=countdocumentwindowsoftype(5)

		if(nodocs<1)
		{
			showalert("Ensure a live image is displayed front-most.",2)
			return
		}

		// Source the front-most image
		image front:= GetFrontImage()
		try {
			front.ImageRemoveEventListener(EventToken)
		} 
		catch {
			break
		}
		


		// Create the event listener object and attach it to the front-most image. The event map describes the mapping
		// of the event to the reponse. The event is data_value_changed - this a predefined event in the DM scripting language
		// DataChanged is the method in the EventHandler Class which is called when the event is detected.
		// EventToken is a numerical id used to identity the listener. It is used to remove the event listener.

		object EventListener=alloc(MyEventHandler)
		string eventmap="data_value_changed:DataChanged"
		
		EventToken = front.ImageAddEventListener(EventListener, eventmap)


		// set the Tag so that the ID can be killed the next time the script runs
		TagGroupSetTagAsNumber( GetPersistentTagGroup(), "SPScript:listener id", EventToken )
		
		// start userscript, ask for script specific parameters through its own dialog and init
		EventListener.initUserScript(aScript, simulation)

	}

	void stop(object self)
	{
		image front := GetFrontImage()
		front.ImageRemoveEventListener(EventToken)
		//debug("Image listener stopped\n")
	}

}

// Main program code // testcode

// Start the listener

//object aListener = alloc(listener)

//aListener.start(1)

