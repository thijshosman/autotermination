// $BACKGROUND$
//dialog that allows users to start scripts

class ScriptStartDialog : uiframe
{
	TagGroup 	PSDialog, PSDialogItems
	Object		PSDialogWindow
	
	taggroup 	f1, f2	
	object parent
	string filename
	object aListenerController
	object aSentinel
	number scriptSelected
	number simulator
	object aSimulator
	object aScript
			
	object init(object self)
	{
		
		//result("LISTENERDIALOG: initialized\n")
		PsDialog = DLGCreateDialog("Select Script", PSDialogItems)
		
		f1 = DLGCreatelabel("Please select image window and a script and press Start")
		PSDialog.DLGAddElement(f1)
		
		// create items and add them to dialog
		//D1 = DLGCreateStringField("select")
		//f1 = DLGCreateStringField("test").DLGIdentifier( "stringValue" )
		//PSDialog.DLGAddElement(f1)
		
		//D2 = DLGCreateIntegerField(1)
		//f2 = DLGCreateRealField(" parameter 2", D2, 2,5,5)
		//PSDialog.DLGAddElement(f2)
		//Number val2 = D2.DLGGetValue()
		

		TagGroup pulldown_items;
		TagGroup pulldown = DLGCreatechoice(pulldown_items, 1, "tracknamechange")

		// Edit these lines to change your user list

		pulldown_items.DLGAddPopupItemEntry("Detect Average Intensity Change in Region of Interest", 1);
		pulldown_items.DLGAddPopupItemEntry("Detect Dark or Bright Areas in Region of Interest", 1);
		//pulldown_items.DLGAddPopupItemEntry("Count Fringes Planar", 1);
		//pulldown_items.DLGAddPopupItemEntry("Glue line/cross section", 1);
		//pulldown_items.DLGAddPopupItemEntry("Testcase 0", 1);

		pulldown.DLGIdentifier("MyPullDown")
		
		
		// create checkbox to allow for simulator to start
		TagGroup simulatorcheckbox = DLGCreateCheckBox("Start Simulator", 0, "toggleSimulator" )
		simulatorcheckbox.DLGIdentifier("checkbox")
		

		
		
		
		
		
		
		//PSDialog.DLGTableLayout(1,2,0)
		
		//taggroup scriptlistitems = NewTagGroup()
		//number index
		//index = scriptlistitems.TagGroupCreateNewLabeledTag( "ROI" ) 
		//scriptlistitems.TagGroupSetIndexedTagAsLong( index, 1 ) 
		//scriptlistitems.TagGroupCreateGroupTagAfter()
		
		//scriptlistitems.TagGroupOpenBrowserWindow( 0 ) 
		//taggGroup items = NewTagList() 
		//items(1) = 
		
		
		
		
		//taggroup browseButtonTags = DLGCreatePushButton("browse", "OnButtonPressedBrowse")	
		taggroup stopButtonTags = DLGCreatePushButton("stop", "OnButtonPressedStop")		
		taggroup startButtonTags = DLGCreatePushButton("start", "OnButtonPressedStart")
		//taggroup scriptlist = DLGCreateChoice(pulldown)
		PsDialog.DLGAddElement(pulldown)
		//PsDialog.DLGAddElement(simulatorcheckbox)
		

		// set the default to the testcase
		TagGroupSetTagAsNumber( pulldown, "Value", 0 ) 
		// set the default to no simulator
		simulator = 0


		//PsDialog.DLGAddElement(browseButtonTags)	
		//PsDialog.DLGAddElement(startButtonTags)	
		//PsDialog.DLGAddElement(stopButtonTags)

		
		//dlgenabled(loadButtonTags,1)
		//dlgenabled(startButtonTags,1)
		//dlgenabled(stopButtonTags,1)

		

		//Number bin = Dbin.DLGGetValue()
		return self.super.init(PSDialog)
		
	}
	
	void tracknamechange( object self, TagGroup tg)
	{
			scriptSelected=val(dlggetstringvalue(tg))

			//dlggetnthlabel(tg, returnno, returnname)
			//dlgvalue(intfield1,dlggetvalue(tg))
	}

	void toggleSimulator( object self, TagGroup tg)
	{
			simulator = tg.DLGGetValue()
			
			result(simulator+"\n")
			//dlggetnthlabel(tg, returnno, returnname)
			//dlgvalue(intfield1,dlggetvalue(tg))
	}

	void OnButtonPressedStart(object self) //not used anymore in modeless dialog
	{
		
		// set progress window
		//OpenAndSetProgressWindow("listener started","","")
		
		// start simulator if needed (ie checkbox checked)
		// not used in modeless dialog
		if (simulator == 1)
		{
			aSimulator = alloc(simulateStack)
			aSimulator.init(1).startthread()	
		}
		
		// wait for image to load
		//sleep(7)
		
		// craete script of desired type
		// aScript = alloc(userScriptFactory).init(scriptSelected)
		// start listener
		//aListenerController.start(aScript, simulator)
		
		// start sentinel
		// not used in modeless dialog
		//aSentinel = alloc(ListenerSentinel)
		//aSentinel.init(aListenerController).StartThread()
		
		//self.setelementisenabled("start", 0);
		//result("WELCOME: started listenerController\n")

		
	}

	void OnButtonPressedStop(object self)
	{
		
		// set progress window
		//OpenAndSetProgressWindow("listener stopped","","")
		
		//stop sentinel, and this stops the listener
		//aSentinel.stop()
		
		if (simulator == 1)
		{
			aSimulator.stop()
		}

		//filename = f1.DLGGetStringValue()
		//result(filename+"\n")
		//self.setelementisenabled("start", 0);

		//result("WELCOME: stopped listenerController\n")
	}

	number getScriptSelected(object self)
	{
		return scriptSelected
	}


//		void OnButtonPressedBrowse(object self)
//	{
//
//		filename = f1.DLGGetStringValue()
//		result(filename+"\n")
//		self.setelementisenabled("start", 0);
//		OpenDialog(filename)
//		result(filename+"\n")
//		
//	}



	void display(object self, string title)
	{
		self.super.display(title)
	}			
		
}

void main()
{
	// start script
	object dlg = alloc(ScriptStartDialog).init()
	//dlg.display("SpecPrep Autotermination")
	if (dlg.pose()) // if 
	{
		//debug("WELCOME: started listenerController\n")

		object aListenercontroller
		object aScript
		
		// load script (with script specific dialog)
		aScript = alloc(userScriptFactory).init(dlg.getScriptSelected())
		//debug("WELCOME: script selected: "+dlg.getScriptSelected()+"\n")

		// start listener
		aListenerController = alloc(listenerController)
		aListenerController.start(aScript, 0)
		
		// make sure the buffer size is one, otherwise there will be a lot of change events sent
		TagGroupSetTagAsNumber( GetPersistentTagGroup(), "PIPS:Record:Buffer size", 1 )

	} else {
		//result("canceled\n")
	}
}

//function, to avoid memory leaks
main()
