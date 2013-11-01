

//object test1 = alloc(userScript)
//test1.init()
//test1.SPSCRIPT_init()

//sleep(10)



class testscript1:object
{
	string name 
	number iterations
	number state


	
	void userScript(object self)
	{
		name="testscript"
	}

	// init gets executed when script is started
	void init(object self, number value)
	{
		

		result("SPSCRIPT"+datestamp()+": Starting\n")
		state = 1
	}
	
	// dialogParameters() asks for script specific parameters, gets executed before init() and calls init
	void dialogParameters(object self) 
	{
		result("SPSCRIPT: dialog started\n")
		
		// dialog object created, this object will call init when parameters are set
		object dlg = alloc(Testscript1_ParameterEntryDialog).init(self)
		dlg.display("Testcase Autotermination")

	}



	
	
	// terminations, do not edit, when called, it stops the listener
	void terminate(object self)
	{
		TagGroupSetTagAsNumber( GetPersistentTagGroup(),"SPScript:listener running", 0 )
		PIPS_stoprecipe()
		PIPS_StopMilling()
		result("SPSCRIPT: terminate sent\n")
	}
	
	// listenerDetectImageUpdate() executed by listener when image is updated. this definition is there to detect change. 
	void listenerDetectImageUpdate(object self)
	{
		if (state > 0) //check if initialized
		{
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


//object test1 = alloc(userScript)
//test1.dialogParameters()


//test1.init()
//test1.SPSCRIPT_init()

//sleep(10)











class Testscript1_ParameterEntryDialog : uiframe
{
	TagGroup 	PSDialog, PSDialogItems
	Object		PSDialogWindow
	taggroup	D1, D2
	taggroup 	f1, f2	
	object parent
	number val1
			
	object init(object self, object aParent)
	{
		result("PARAMETERENTRYDIALOG: initialized\n")
		PsDialog = DLGCreateDialog("Enter parameters", PSDialogItems)
		
		// create items and add them to dialog
		D1 = DLGCreateIntegerField(1)
		f1 = DLGCreateIntegerField("testscript, nothing to specify", D1, 1,5)
		PSDialog.DLGAddElement(f1)
		
		
		//D2 = DLGCreateIntegerField(1)
		//f2 = DLGCreateRealField(" parameter 2", D2, 2,5,5)
		//PSDialog.DLGAddElement(f2)
		//Number val2 = D2.DLGGetValue()
		
		parent = aParent
		
		//PSDialog.DLGTableLayout(1,2,0)
		
		taggroup runButtonTags = DLGCreatePushButton("Run", "OnButtonPressedRun")
		taggroup pauseButtonTags = DLGCreatePushButton("Pause", "OnButtonPressedPause")
		taggroup resumeButtonTags = DLGCreatePushButton("Resume", "OnButtonPressedResume")
		taggroup stopButtonTags = DLGCreatePushButton("Manual Stop", "OnButtonPressedStop")
		PsDialog.DLGAddElement(runButtonTags)
		//PsDialog.DLGAddElement(pauseButtonTags)
		//PsDialog.DLGAddElement(resumeButtonTags)
		//PsDialog.DLGAddElement(stopButtonTags)
		dlgenabled(runButtonTags,1)
		//dlgenabled(pauseButtonTags,0)
		//dlgenabled(resumeButtonTags,0)
		//dlgenabled(stopButtonTags,0)
		dlgidentifier(runButtonTags, "run")
		//dlgidentifier(pauseButtonTags, "pause")
		//dlgidentifier(resumeButtonTags, "resume")
		//dlgidentifier(stopButtonTags, "stop")
		
		

		//Number bin = Dbin.DLGGetValue()
		return self.super.init(PSDialog)
		
	}
		
	void OnButtonPressedRun(object self)
	{

		val1 = D1.DLGGetValue()
		parent.init(val1)
		//self.setelementisenabled("run", 0);
		//self.setelementisenabled("pause", 1);
		//self.setelementisenabled("resume", 1);
		//self.setelementisenabled("stop", 1);
		
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

		parent.terminate()
		//self.setelementisenabled("run", 1);
		
	}

	void display(object self, string title)
	{
		self.super.display(title)
	}			
		
}









