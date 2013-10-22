// $BACKGROUND$

void startSimulate()
{
// get directory

	
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
		result("SIMULATOR: "filename+"\n")
		simulateStack = OpenImage(fileName) 
		simulateStack.SetName("SimulateStack "+i)
		showImage(simulateStack)
		sleep(5)

		if ((optiondown() && shiftdown()))
		{
			result("SIMULATOR: manually aborted\n")
			break
		}
		
	}

}

startSimulate()


//string path = PathExtractDirectory(fullPath, 0)
//img1 := openimage(fullpath)
//showImage(img1)


