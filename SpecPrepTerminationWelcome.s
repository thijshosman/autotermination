// $BACKGROUND$
//dialog that allows users to start scripts


class ScriptStartDialog : uiframe
{
	TagGroup 	PSDialog, PSDialogItems
	Object		PSDialogWindow
	
	taggroup installed_scripts
	
	taggroup 	f1, f2	
	object parent
	string filename
	object aListenerController
	object aSentinel
	string scriptSelected
	number simulator
	object aSimulator
	object aScript
			
	object init(object self)
	{
		
		//result("LISTENERDIALOG: initialized\n")
		PsDialog = DLGCreateDialog("Select Script", PSDialogItems)
		
		f1 = DLGCreatelabel("Please select image window and a script and press Ok")
		PSDialog.DLGAddElement(f1)
		

		

		TagGroup pulldown_items;
		TagGroup pulldown = DLGCreatechoice(pulldown_items, 1, "tracknamechange")
		
		installed_scripts = SPScriptGetInstalledScripts()

		// generate pulldown menu with installed scripts
		number count = installed_scripts.TagGroupCountTags()
		number i
		
		for(i = 0; i < count; i++)
		{
			pulldown_items.DLGAddPopupItemEntry(SPScriptGetLabel(installed_scripts.TagGroupGetTagLabel( i )), 1);
		}
		
		// default script selected is the top one
		scriptSelected = installed_scripts.TagGroupGetTagLabel( 0 )

		pulldown.DLGIdentifier("MyPullDown")
		
		
		// create checkbox to allow for simulator to start
		TagGroup simulatorcheckbox = DLGCreateCheckBox("Start Simulator", 0, "toggleSimulator" )
		simulatorcheckbox.DLGIdentifier("checkbox")
		

		
		
		
		
		
		

		taggroup stopButtonTags = DLGCreatePushButton("stop", "OnButtonPressedStop")		
		taggroup startButtonTags = DLGCreatePushButton("start", "OnButtonPressedStart")

		PsDialog.DLGAddElement(pulldown)


		// set the default to the testcase
		TagGroupSetTagAsNumber( pulldown, "Value", 0 ) 
		// set the default to no simulator
		simulator = 0


		


		return self.super.init(PSDialog)
		
	}
	
	// gets called by the pulldown menu every time a choice is made
	void tracknamechange( object self, TagGroup tg)
	{
			
			number choice = val(dlggetstringvalue(tg))
			scriptSelected=installed_scripts.TagGroupGetTagLabel(choice)
			
	}

	

	// gets called by the main function, needs assessor for some reason
	string getScriptSelected(object self)
	{
		//debug("selected script: "+scriptSelected+"\n")
		return scriptSelected
	}


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
		//debug(dlg.getScriptSelected())
		
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
