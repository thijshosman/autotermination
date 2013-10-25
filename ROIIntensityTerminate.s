
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




	// init gets executed on startup of script
	void init(object self)
	{
		name="ROI intensity termination script"
		result("SPSCRIPT"+name+": initialized\n")
		iterations = 0
		state=1
	}
	
	// dialogParameters() asks for script specific parameters, gets executed before init()
	void dialogParameters(object self) 
	{
		//get user input for intensity change
		chg = 20
		getnumber("Specify % intensity change to stop milling and draw ROI with selection tool:",chg,chg)
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
		result(datestamp()+": Starting ROI average intensity="+StartAvg+"\n")
		result("  Milling will be stopped when intensity changes by "+chg+"%\n")
		result("      Low  threshold="+low_thres+"\n")
		result("      High threshold="+high_thres+"\n")


		//now call init()
		self.init()
	}

	
	
	// terminations, do not edit, when called, it stops the listener
	void terminate(object self)
	{
		TagGroupSetTagAsNumber( GetPersistentTagGroup(),"SPScript:listener running", 0 )
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

	}

}


//object test1 = alloc(userScript)
//test1.dialogParameters()
//test1.init()
//test1.SPSCRIPT_init()

//sleep(10)









