class ROIIntensityPixels:object
{
	string name 
	number iterations
	number state
	string feedback

	number threshold
	image trg_grey
	image src
	number StartAvg
	number low_thres
	number high_thres
	RGBimage trg
	number x,y,z
	number t,l,b,r
	number dark_intensity_threshold
	number light_intensity_threshold
	number lightOrDark

	void setStatus(object self)
	{
		OpenAndSetProgressWindow(name,feedback,"Iteration: "+iterations)
	}
	
	void ROIIntensityPixels(object self)
	{
		name="ROIIntensityPixels"
		feedback="paused"
		state = 0
		self.setStatus()
	}



	// init gets executed when script is started
	void init(object self, number size, number condition)
	{
		string typeofhole
		dark_intensity_threshold = 10
		light_intensity_threshold = 245
		lightordark = condition

		debug("size: "+size+" lightordark: "+lightordark+"\n")
		
		// calculate number of pixels the desired hole threshold is
		threshold = size/0.1225 

		src:=GetFrontImage()
		
		getsize(src,x,y)

		trg:=RGBimage("test",4,x,y)
		trg=src[0,0,0,x,y,1]

		//let user define ROI 
		GetSelection(src,t,l,b,r)

		// create greyscale image from target image
		trg_grey:=red(trg)*.3+green(trg)*.6+blue(trg)*.1

		if (lightOrDark == 1) // dark hole
		{
				typeofhole = "dark"
		} else if (lightOrDark == 0) // light hole 
		{
				typeofhole = "bright"
		}		
		

		result("------- Detect Hole ------------------\n")
		result(datestamp()+"\n")
		result("Milling will be stopped when "+typeofhole+" hole with area of "+threshold+" um^2 is detected\n")
		result(name+": initialized\n")
		
		iterations=0
		state=1

		feedback = "initialized"
		self.setStatus()
	}
	
	// dialogParameters() asks for script specific parameters, gets executed before init() and calls init
	void dialogParameters(object self) 
	{
		debug("SPSCRIPT: dialog started\n")
		
		// dialog object created, this object will call init when parameters are set
		object dlg = alloc(ROIIntensityPixelsParameterEntryDialog).init(self)
		dlg.display("Region of Interest Autotermination")

	}

	void stopRunning(object self) 
	{
		feedback = "script stopped"
		self.setStatus()
		state = 0
		debug("SPSCRIPT: stopped\n")
		
	}

	
	
	// terminations, do not edit, when called, it stops the listener
	void terminate(object self)
	{
		// stop this script from listening
		self.stopRunning()
		
		// stop PIPS, whether recipe or milling
		PIPS_stoprecipe()
		PIPS_StopMilling()
		feedback = "terminated, script stopped"
		self.setStatus()

		debug("SPSCRIPT: terminate sent\n")
	}
	
	// listenerDetectImageUpdate() executed by listener when image is updated. this definition is there to detect change. 
	void listenerDetectImageUpdate(object self)
	{
		if (state > 0) //check if initialized
			{
			number current_hole_size

			//increase #iterations
			iterations++
			//debug("SPSCRIPT: DETECTED CHANGE, iteration: "+iterations+"\n")
			

			trg=src[0,0,0,x,y,1]
			trg_grey:=red(trg)*.3+green(trg)*.6+blue(trg)*.1
		
			feedback = "running"
			self.setStatus()

			if (lightOrDark == 1) // dark hole
			{
				current_hole_size = 0.1225 * sum(trg_grey[t,l,b,r] < dark_intensity_threshold)
				
			}

			if (lightOrDark == 0) // bright hole
			{
				current_hole_size = 0.1225 * sum(trg_grey[t,l,b,r] > light_intensity_threshold)
				
			}

			result(datestamp()+" size of hole detected in ROI: "+current_hole_size+"\n")

			if (current_hole_size > threshold)
			{
				result("  Milling stopped because the detected hole exceeds threshold\n")
				
				self.terminate()
				result("terminated milling at "+datestamp()+"\nHole size: "+current_hole_size+"\n\n")
				Beep(); Beep();
				exit(0)
			}

			
		}


	}



}


//object test1 = alloc(ROIIntensityPixels)
//test1.dialogParameters()


class ROIIntensityPixelsParameterEntryDialog : uiframe
{
	number val1
	object parent
	TagGroup 	PSDialog, PSDialogItems
	Object		PSDialogWindow
	taggroup	D1, f1
	taggroup 	radioItems1, radio1

	number lightOrDark

	void makeButtons(object self)
	{

		TagGroup label1
		label1 = DLGCreateLabel("Please use selection tool to draw region of interest in image")
		PSDialog.DLGAddElement(label1)

		// create items and add them to dialog
		D1 = DLGCreateIntegerField(1)
		f1 = DLGCreateIntegerField("Specify the minimum termination hole area in um^2 ", D1, 1,5)
		PSDialog.DLGAddElement(f1)
		
		// radio button for light/dark
		
		radio1 = DLGCreateRadioList(radioItems1, 1, "lightOrDarkSelection")
		radioItems1.DLGAddRadioItem("Look for Bright Hole", 0 )
		radioItems1.DLGAddRadioItem("Look for Dark Hole", 1 )
		radio1.DLGIdentifier("radio1")
		PSDialog.DLGAddElement(radio1)
		lightOrDark = 1

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
		debug("PARAMETERENTRYDIALOG: initialized\n")
		PsDialog = DLGCreateDialog("Enter parameters", PSDialogItems)
		
		parent = aParent
		self.makeButtons()

		return self.super.init(PSDialog)
	}
	
	void lightOrDarkSelection(object self, TagGroup tg)
	{
			// 0 is Bright, 1 is Dark
			lightOrDark = tg.DLGGetValue()
			
			//result(lightorDark)
			//result(tg.DLGGetValue())
			//taggroupopenbrowserwindow(tg,0)
			//dlggetnthlabel(tg, returnno, returnname)
			//dlgvalue(intfield1,dlggetvalue(tg))
	}



	void OnButtonPressedRun(object self)
	{

		val1 = D1.DLGGetValue()
		parent.init(val1, lightOrDark)
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





