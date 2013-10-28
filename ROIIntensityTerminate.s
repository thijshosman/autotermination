
class userScript:object
{
	string name 
	number iterations
	number state

	number chg
	image trg_grey
	image src
	number StartAvg
	number low_thres
	number high_thres
	RGBimage trg
	number x,y,z
	number t,l,b,r

	
	void userScript(object self)
	{
		name="ROI intensity termination script"
	}

	// init gets executed when script is started
	void init(object self, number value)
	{
		
		chg = value

		src:=GetFrontImage()

		
		getsize(src,x,y)

		trg:=RGBimage("test",4,x,y)
		trg=src[0,0,0,x,y,1]

		//let user define ROI 
		
		GetSelection(src,t,l,b,r)

		// create greyscale image from target image
		trg_grey:=red(trg)*.3+green(trg)*.6+blue(trg)*.1
		StartAvg = average(trg_grey[t,l,b,r])
		low_thres = startavg * (1-chg/100)
		high_thres = startavg * (1+chg/100)

		result("------- Terminate Milling from Image Intensity Change ------------------\n")
		result("SPSCRIPT"+datestamp()+": Starting ROI average intensity="+StartAvg+"\n")
		result("SPSCRIPT  Milling will be stopped when intensity changes by "+chg+"%\n")
		result("SPSCRIPT      Low  threshold="+low_thres+"\n")
		result("SPSCRIPT      High threshold="+high_thres+"\n")
		result("SPSCRIPT"+name+": initialized\n")
		iterations = 0
		state=1
	}
	
	// dialogParameters() asks for script specific parameters, gets executed before init() and calls init
	void dialogParameters(object self) 
	{
		result("SPSCRIPT: dialog started\n")
		//get user input for intensity change
		//chg = 20
		//getnumber("Specify % intensity change to stop milling and draw ROI with selection tool:",chg,chg)
		
		// dialog object created, this object will call init when parameters are set
		object dlg = alloc(ParameterEntryDialog).init(self)
		dlg.display("Test Dialog")

		


		//now call init()
		//self.init()
	}



	
	
	// terminations, do not edit, when called, it stops the listener
	void terminate(object self)
	{
		TagGroupSetTagAsNumber( GetPersistentTagGroup(),"SPScript:listener running", 0 )
		PIPS_stoprecipe()
		result("SPSCRIPT: terminate sent\n")
	}
	
	// listenerDetectImageUpdate() executed by listener when image is updated. this definition is there to detect change. 
	void listenerDetectImageUpdate(object self)
	{
		if (state > 0) //check if initialized
			{
			//increase #iterations
			iterations++
			result("image update detected, testscript called. iteration: "+iterations+"\n")
			
			result("SPSCRIPT: DETECTED CHANGE\n")
			
			trg=src[0,0,0,x,y,1]
			trg_grey:=red(trg)*.3+green(trg)*.6+blue(trg)*.1
			number avg=average(trg_grey[t,l,b,r])
			result(datestamp()+":Current ROI average intensity="+avg+"\n")
		
			if (avg > high_thres || avg < low_thres)
			{
				result("  Milling stopped because intensity change exceeded threshold.\n\n")
				//PIPS_StopMilling()
				self.terminate()
				Beep(); Beep();
				exit(0)
			}

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











class ParameterEntryDialog : uiframe
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
		f1 = DLGCreateIntegerField("Specify % intensity change to stop milling and draw ROI with selection tool:", D1, 1,5)
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
		PsDialog.DLGAddElement(pauseButtonTags)
		PsDialog.DLGAddElement(resumeButtonTags)
		PsDialog.DLGAddElement(stopButtonTags)
		dlgenabled(runButtonTags,1)
		dlgenabled(pauseButtonTags,0)
		dlgenabled(resumeButtonTags,0)
		dlgenabled(stopButtonTags,0)
		dlgidentifier(runButtonTags, "run")
		dlgidentifier(pauseButtonTags, "pause")
		dlgidentifier(resumeButtonTags, "resume")
		dlgidentifier(stopButtonTags, "stop")
		
		

		//Number bin = Dbin.DLGGetValue()
		return self.super.init(PSDialog)
		
	}
		
	void OnButtonPressedRun(object self)
	{

		val1 = D1.DLGGetValue()
		parent.init(val1)
		self.setelementisenabled("run", 0);
		self.setelementisenabled("pause", 1);
		self.setelementisenabled("resume", 1);
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

		parent.terminate()
		self.setelementisenabled("run", 1);
		
	}

	void display(object self, string title)
	{
		self.super.display(title)
	}			
		
}





