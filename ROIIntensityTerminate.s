number state  = 0
number iterations = 0
string name = "ROI Intensity Terminate"
image src
number chg
number x,y,z
getsize(src,x,y)





// SPSCRIPT_dialogParameters() 
void SPSCRIPT_dialogParameters() 
{

}

// init gets executed on startup of script
void SPSCRIPT_init()
{
	src:=GetFrontImage()
	chg=20


	result("starting script: "+ name+"\n")
	state = 0
	iterations = 0
}

// SPSCRIPT_listenerDetectImageUpdate() executed by listener when image is updated. this definition is there to detect change. 
void SPSCRIPT_listenerDetectImageUpdate()
{
	result("image update detected, testscript called. iteration: "+iterations+"\n")

	//return false to keep script running

}








