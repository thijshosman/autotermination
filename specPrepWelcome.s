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
			
	object init(object self)
	{
		
		result("LISTENERDIALOG: initialized\n")
		PsDialog = DLGCreateDialog("Select Script", PSDialogItems)
		
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

		pulldown_items.DLGAddPopupItemEntry("Default Choice");
		pulldown_items.DLGAddPopupItemEntry("Choice 2");
		pulldown_items.DLGAddPopupItemEntry("Choice 3");
		pulldown_items.DLGAddPopupItemEntry("Choice 4");
		pulldown_items.DLGAddPopupItemEntry("Choice 5");
		pulldown_items.DLGAddPopupItemEntry("Choice 6");
		pulldown_items.DLGAddPopupItemEntry("Choice 7");
		pulldown.DLGIdentifier("MyPullDown")
		
		
		//PSDialog.DLGTableLayout(1,2,0)
		
		taggroup scriptlistitems = NewTagGroup()
		number index
		index = scriptlistitems.TagGroupCreateNewLabeledTag( "ROI" ) 
		scriptlistitems.TagGroupSetIndexedTagAsLong( index, 1 ) 
		//scriptlistitems.TagGroupCreateGroupTagAfter()
		
		//scriptlistitems.TagGroupOpenBrowserWindow( 0 ) 
		//taggGroup items = NewTagList() 
		//items(1) = 
		
		
		
		
		//taggroup browseButtonTags = DLGCreatePushButton("browse", "OnButtonPressedBrowse")	
		taggroup stopButtonTags = DLGCreatePushButton("stop", "OnButtonPressedStop")		
		taggroup startButtonTags = DLGCreatePushButton("start", "OnButtonPressedStart")
		//taggroup scriptlist = DLGCreateChoice(pulldown)
		PsDialog.DLGAddElement(pulldown)


		//PsDialog.DLGAddElement(browseButtonTags)	
		PsDialog.DLGAddElement(startButtonTags)	
		PsDialog.DLGAddElement(stopButtonTags)

		
		//dlgenabled(loadButtonTags,1)
		dlgenabled(startButtonTags,1)
		dlgenabled(stopButtonTags,1)
		
		aListenerController = alloc(listenerController)
		

		//Number bin = Dbin.DLGGetValue()
		return self.super.init(PSDialog)
		
	}
		
	void OnButtonPressedStart(object self)
	{
		
		// start listener
		aListenerController.start(1)
		
		// start sentinel
		aSentinel = alloc(ListenerSentinel)
		aSentinel.init(aListenerController).StartThread()
		
		//self.setelementisenabled("start", 0);
		result("WELCOME: started listenerController\n")

		
	}

	void OnButtonPressedStop(object self)
	{
		
		//stop sentinel, and this stops the listener
		aSentinel.stop()
		
		//filename = f1.DLGGetStringValue()
		//result(filename+"\n")
		//self.setelementisenabled("start", 0);

		result("WELCOME: stopped listenerController\n")
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

object dlg = alloc(ScriptStartDialog).init()
		dlg.display("test")






