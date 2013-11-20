// install the script in the global tags
SPScriptSet("roiintensityave", "Detect Average Intensity Change in Region of Interest")

class ROIIntensityAve:object
{
	string name 
	number iterations
	number state
	string feedback

	number chg
	image trg_grey
	image src
	number StartAvg
	number low_thres
	number high_thres
	RGBimage trg
	number x,y,z
	number t,l,b,r


	void setStatus(object self)
	{
		OpenAndSetProgressWindow(name,feedback,"Iteration: "+iterations)
	}
	
	void ROIIntensityAve(object self)
	{
		name="Average Intensity"
		feedback="paused"
		state = 0
		self.setStatus()
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
		result("  "+datestamp()+": Starting ROI average intensity="+StartAvg+"\n")
		result("  Milling will be stopped when intensity changes by "+chg+"%\n")
		result("  Low threshold="+low_thres+"\n")
		result("  High threshold="+high_thres+"\n")
		//result(name+": initialized\n")
		iterations = 0
		state=1

		feedback = "initialized"
		self.setStatus()
	}
	
	// dialogParameters() asks for script specific parameters, gets executed before init() and calls init
	void dialogParameters(object self) 
	{
		//debug("SPSCRIPT: dialog started\n")
		
		// dialog object created, this object will call init when parameters are set
		object dlg = alloc(ROIIntensityAveParameterEntryDialog).init(self)
		dlg.display("Region of Interest Autotermination")

	}

	void stopRunning(object self) 
	{
		result("------- Script stopped at "+datestamp()+" --------\n")
		feedback = "Script stopped"
		self.setStatus()
		state = 0
		//debug("SPSCRIPT: stopped\n")
		
	}

	
	
	// terminations, do not edit, when called, it stops the listener
	void terminate(object self)
	{
		// stop this script from listening
		self.stopRunning()
		
		// stop PIPS, whether recipe or milling
		PIPS_stoprecipe()
		PIPS_StopMilling()
		feedback = "Terminated"
		self.setStatus()

		//debug("SPSCRIPT: terminate sent\n")
	}
	
	// listenerDetectImageUpdate() executed by listener when image is updated. this definition is there to detect change. 
	void listenerDetectImageUpdate(object self)
	{
		if (state > 0) //check if initialized
			{
			//increase #iterations
			iterations++
			//result("image update detected, testscript called. iteration: "+iterations+"\n")
			
			//debug("SPSCRIPT: DETECTED CHANGE\n")
			
			trg=src[0,0,0,x,y,1]
			trg_grey:=red(trg)*.3+green(trg)*.6+blue(trg)*.1
			number avg=average(trg_grey[t,l,b,r])
			//result("  "+datestamp()+":Current ROI average intensity="+avg+"\n")
		
			feedback = "Avg: "+avg
			self.setStatus()


			if (avg > high_thres || avg < low_thres)
			{
				result("  Milling stopped because intensity change exceeded threshold.\n")
				
				self.terminate()
				result("  Terminated milling\n  start average: "+StartAvg+"\n  last average: "+avg+"\n\n")
				Beep(); Beep();
				exit(0)
			}

			
		}


	}



}


//object test1 = alloc(ROIIntensityAve)
//test1.dialogParameters()


//test1.init()
//test1.SPSCRIPT_init()

//sleep(10)












class ROIIntensityAveParameterEntryDialog : uiframe
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
		f1 = DLGCreateIntegerField("Specify % intensity change to stop milling and draw ROI with selection tool:", D1, 1,5)
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
		//debug("PARAMETERENTRYDIALOG: initialized\n")
		
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


