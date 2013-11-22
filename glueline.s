SPScriptSet("glueline", "Glue line/cross section")

class glueline:object
{
	string name 
	number iterations
	number state
	string feedback

	// the scrip is using five parameters to indicating the different conditions of the cross-section sample.
	// first it detects the Newton ring, then it measure the distance of the hole. it correlates this to steps in a recipe running on the PIPS
	// 

	number start_number
	number threshold_first
	number threshold_second
	number threshold_third
	number threshold_fourth   //this value is minus value   
	number dark_pixel
	number true_false
	number script_state
	number step
	number detect_ring_spec
	number height
	number color_threshold
	image kernel





	void setStatus(object self)
	{
		OpenAndSetProgressWindow(name,feedback,"step: "+script_state)
	}
	
	void ROIIntensityPixels(object self)
	{
		name="detect glueline"
		feedback="paused"
		state = 0
		self.setStatus()
		
	}



	// init gets executed when script is started
	void init(object self, number t1, number t2, number t3, number dark_pixel_intensity)
	{
		start_number=100
		threshold_first=t1
		threshold_second=t2
		threshold_third=t3
		threshold_fourth=10   //this value is minus value   
		dark_pixel=dark_pixel_intensity
		step=1
		detect_ring_spec=4
		color_threshold=0.9

		kernel = realimage("kernel", 4, 3, 3)
		kernel := [3,3]:
	   	{
			{1,2,1 },
			{2,4,2 },
			{1,2,1}
		}
		

		result("------- Script Started at "+datestamp()+" --------\n")
		//result("  Milling will be stopped when "+typeofhole+" area of "+threshold_um2+" um^2 is detected\n")
		//result("  "+name+": initialized\n")


		iterations=0
		state=1

		feedback = "initialized"
		self.setStatus()
	}
	
	// dialogParameters() asks for script specific parameters, gets executed before init() and calls init
	void dialogParameters(object self) 
	{
		//debug("SPSCRIPT: dialog started\n")
		
		// dialog object created, this object will call init when parameters are set
		object dlg = alloc(gluelineParameterEntryDialog).init(self)
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
	
	number detecting(object self,number threshold) // script specific
	{
	    true_false=0
	    number start_x, start_y,end_x, end_y
        number number_annotations, annotationID
        image front:=getfrontimage()
        imagedisplay imgdisp=front.imagegetimagedisplay(0)
        number nobar=imgdisp.componentcountchildrenoftype(31)
        if (nobar>0)
        {
            component scalebar=imgdisp.componentgetnthchildoftype(31,0)
            componentremovefromparent(scalebar)
        }

        number_annotations = countannotations(front)
        annotationID = GetnthAnnotationID(front, number_annotations-1)
        if(annotationID==0)
        	throw("Please draw a ROI line along the glue position.")
        getannotationrect(front, annotationID, start_x, start_y, end_x, end_y)
        image color_r,color_g,color_b,color_bg,color_rg,brightness
        color_r=red(front)
        color_b=blue(front)
        color_g=green(front)
        color_rg=color_r/color_g
        brightness=sqrt(color_r**2+color_b**2+color_g**2)
   
        number scaleX,scaleY,xsize,ysize
        string unit
        getscale(front,scaleX,scaleY)
        getunitstring(front,unit)
        getsize(front,xsize,ysize)

        number profile_number=sqrt((end_x-start_x)**2+(end_y-start_y)**2)
        number slope=atan((end_x-start_x)/(end_y-start_y))
        number aa=end_x-start_x
        number bb=end_y-start_y


        if(threshold==start_number)
        {
            step=1
             
            result("The step "+step+" is runing.\n")
            image color_temp:=realimage("color_temp",4,xsize,ysize)
            color_temp=color_rg
            color_temp= convolution(color_temp,kernel)
            number width=end_y-start_y
            number height=start_x-100
            image temp:=realimage("temp",4,width,height)
            temp=color_temp[start_x-height,start_y,start_x,start_y+width]
         	//    showimage(temp)
            image new:=realimage("new",4,width,5)
        	//     showimage(new)
             
            number p
            for(p=0;p<height/10;p++)
                {
            		image colum:=realimage("colum",4,width,1)
                    colum=warp(temp,icol,irow+10*p)
                    image pulse=tert(colum>color_threshold,1,0)
                    number count=0
                    number i
                    for (i=0;i<width-5;i++)
                    {
                    	if(getpixel(pulse,i,0)==1 && getpixel(pulse,i+1,0)==1 && getpixel(pulse,i+2,0)==1 && getpixel(pulse,i+3,0)==1 && getpixel(pulse,i+4,0)==0)
                        count++
                    }
                   	if (count>=detect_ring_spec)
                       {
                          true_false=1
                          result("\nNewton ring is detected\n")
                          break
                       }
                }
        }   
           
        
       	if (threshold==threshold_first ||threshold==threshold_second || threshold==threshold_third)
        {
        	if(threshold==threshold_first)
           		step=1
           	if(threshold==threshold_second)
           		step=2
           	if(threshold==threshold_third)
           		step=3
        
           	number pixel_threshold=threshold/cos(slope)/scaleX
           	result("\nFor the step "+step+", the hole position should be at the distance of "+threshold+" um \n")

           	number down_up
           	for(down_up=0;down_up<=pixel_threshold;down_up++)
            {
              	image profile_line_up:=realimage("profile_up",4,profile_number+1,1)
                            
              	if(bb>=0)
                	profile_line_up = warp(brightness, icol*cos(slope)-irow*sin(slope)+start_y, icol*sin(slope) + irow*cos(slope) + start_x - down_up)
                   
              	if(bb<0)
                 	profile_line_up = warp(brightness, -icol*cos(slope)-irow*sin(slope)+start_y, -icol*sin(slope) + irow*cos(slope) + start_x - down_up)
                
              	number i
              	for (i=0;i<=profile_number-10;i++)
                {    
                  	if(getpixel(profile_line_up,i,0)<dark_pixel && getpixel(profile_line_up,i+1,0)<dark_pixel&& getpixel(profile_line_up,i+2,0)<dark_pixel&& \
                         getpixel(profile_line_up,i+3,0)<dark_pixel&& getpixel(profile_line_up,i+4,0)<dark_pixel&& getpixel(profile_line_up,i+5,0)<dark_pixel&& \
                         getpixel(profile_line_up,i+6,0)<dark_pixel&& getpixel(profile_line_up,i+7,0)<dark_pixel&& getpixel(profile_line_up,i+8,0)<dark_pixel&&\
                         getpixel(profile_line_up,i+9,0)<dark_pixel)
                    	true_false=1
                       
                   	if (true_false==1)
                    {
                        result("The X coordinate of the detected hole point is: "+i+"\n" ) 
                        break
                    }
                }
              
              	if (true_false==1)
                {
                    result("The Y coordinate of the detected hole point is: "+down_up+"\n" )
                    break
                }
            }
            
        }
         
    	if (threshold==threshold_fourth)
       	{
        	step=3
        
           	number pixel_threshold=threshold/cos(slope)/scaleX
           	result("\nFor the step "+step+", the hole position should be at the distance of -"+threshold+" um \n")

           	number down_up=pixel_threshold

           	image profile_line_down:=realimage("profile_down",4,profile_number+1,1)
           
           	if(bb>=0)
            	profile_line_down = warp(brightness, icol*cos(slope)-irow*sin(slope)+start_y, icol*sin(slope) + irow*cos(slope) + start_x + down_up)
                 
           	if(bb<0)
            	profile_line_down = warp(brightness, -icol*cos(slope)-irow*sin(slope)+start_y, -icol*sin(slope) + irow*cos(slope) + start_x + down_up)
                
           	number i
           	for (i=0;i<=profile_number-10;i++)
            {
                if(getpixel(profile_line_down,i,0)<dark_pixel && getpixel(profile_line_down,i+1,0)<dark_pixel&& getpixel(profile_line_down,i+2,0)<dark_pixel&& \
                      getpixel(profile_line_down,i+3,0)<dark_pixel&& getpixel(profile_line_down,i+4,0)<dark_pixel&& getpixel(profile_line_down,i+5,0)<dark_pixel&& \
                      getpixel(profile_line_down,i+6,0)<dark_pixel&& getpixel(profile_line_down,i+7,0)<dark_pixel&& getpixel(profile_line_down,i+8,0)<dark_pixel&&\
                      getpixel(profile_line_down,i+9,0)<dark_pixel)
                    true_false=1
                               
                if (true_false==1)
                    {
                        result("The X coordinate of the detected hole point is: "+i+"\n" ) 
                        break
                    }
            }
        }

      	return true_false
    }





	// listenerDetectImageUpdate() executed by listener when image is updated. this definition is there to detect change. 
	void listenerDetectImageUpdate(object self)
	{
		if (state > 0) //check if initialized
		{		
			iterations++
			
		   	
		   	if(script_state==0)
	        {
	            
	            if(self.detecting(start_number)==1)
	            {
	                 script_state = 1
	                 result("  The step 1 is runing. \n")
	 
	            }
	                        
	        } 
		
	       	if(script_state==1)
	        {
	            
	            if(self.detecting(threshold_first)==1)
	            {
	                script_state =2
	                result("  The step 1 is finished.\t"+datestamp()+"  \n")
	                PIPS_RecipeNextStep()
	            }
	                            
	        } 
	          
			if(script_state==2)
	        {
	            
	            if(self.detecting(threshold_second)==1)
	            {
	                script_state = 3
	                result("  The step 2 is finished.\t"+datestamp()+"  \n")
	                PIPS_RecipeNextStep()
	            }
	                            
	        } 
	     	if(script_state==3)
	        {
	            
	            if(self.detecting(threshold_third)==1)
	            {
	                script_state = 4
	                result("  Now,the hole position is at the distance of "+threshold_third+"um.\t"+datestamp()+" \n")
	            }
	                            
	        } 
	     
	    	if(script_state==4)
	     	{
	            
	            if(self.detecting(threshold_fourth)==1)
	            {
	                script_state = 0 
	                result("  The step 3 is finished.\t"+datestamp()+"  \n")
	                self.terminate()
	                result("  Terminated milling at "+datestamp()+"\n\n")
	                Beep(); Beep();
					exit(0)
	            }
	                            
	        } 
		}


			
	}


	



}


//object test1 = alloc(glueline)
//test1.dialogParameters()


class gluelineParameterEntryDialog : uiframe
{
	
	object parent
	TagGroup 	PSDialog, PSDialogItems
	Object		PSDialogWindow
	taggroup	D1, f1, D2, f2, D3, f3, D4, f4


	number threshold1, threshold2, threshold3, dark_pixel
	

	void makeButtons(object self)
	{

		TagGroup label1
		label1 = DLGCreateLabel("Please enter values for the three distances to the glueline used to go to the next recipe steps\n and draw an ROI line at the location of the glueline")
		PSDialog.DLGAddElement(label1)

		// create items and add them to dialog
		D1 = DLGCreateIntegerField(1)
		f1 = DLGCreateIntegerField("threshold distance to glueline ending first recipe step (in um) ", D1, 50,5)
		PSDialog.DLGAddElement(f1)
		
		D2 = DLGCreateIntegerField(1)
		f2 = DLGCreateIntegerField("threshold distance to glueline ending second recipe step (in um) ", D2, 20,5)
		PSDialog.DLGAddElement(f2)

		D3 = DLGCreateIntegerField(1)
		f3 = DLGCreateIntegerField("threshold distance to glueline ending third recipe step (in um) ", D3, 0,5)
		PSDialog.DLGAddElement(f3)

		D4 = DLGCreateIntegerField(1)
		f4 = DLGCreateIntegerField("\nmaximum value of what is considered a 'dark' pixel ", D4, 60,5)
		PSDialog.DLGAddElement(f4)

		
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

		threshold1 = D1.DLGGetValue()
		threshold2 = D2.DLGGetValue()
		threshold3 = D3.DLGGetValue()
		dark_pixel = D4.DLGGetValue()

		parent.init(threshold1, threshold2, threshold3, dark_pixel)
		
		// make sure the buttons have the right value
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





