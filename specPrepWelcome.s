// simple dialog script to demonstrate the resetting of pulldown menus
// D. R. G. Mitchell, drm678ansto.gov.au (replace the 678 with the 'at' symbol)
// ANSTO Materials, Feb 2006
// verions 1.0

//ssxcg
// variables666

number returnno
string returnname, returnstring
taggroup intfield1

class DialogLibraryTestClass : uiframe
{
	number change_count, action_count;

	void tracknamechange( object self, TagGroup tg)
	{
			returnno=val(dlggetstringvalue(tg))
			dlggetnthlabel(tg, returnno, returnname)
			dlgvalue(intfield1,dlggetvalue(tg))
	}

	void cancelpane( object self) // when the 'Cancel' button is pressed
	{
		//windowclose(getdocumentwindow(0),0)
	}




// This part of the script does the resetting, when the reset button is pressed

	void reset(object self) // when the 'Reset' button is pressed
	{

		taggroup Getthepulldown=self.lookupelement("MyPullDown")
		
		// open window to view tag content
		//taggroupopenbrowserwindow(GetthePulldown,0)

		TagGroupSetTagAsNumber( GetthePulldown, "Value", 1 ) 

		intfield1.dlgvalue(1)
	}
}


TagGroup MakeFields() // makes the integer field
{
	taggroup label1=dlgcreatelabel("Pulldown Value").dlganchor("Center")
	intfield1 = DLGCreateIntegerField(0,10).DLGAnchor("Center");
	intfield1.dlgvalue(1)
	taggroup group1=dlggroupitems(label1,intfield1)
	return group1	
}


TagGroup Makepulldowns() // creates the pulldown menu
{
	TagGroup pulldown_items;
	TagGroup pulldown = DLGCreatePopup(pulldown_items, 1, "tracknamechange")

	// Edit these lines to change your user list

	pulldown_items.DLGAddPopupItemEntry("Default Choice");
	pulldown_items.DLGAddPopupItemEntry("Choice 2");
	pulldown_items.DLGAddPopupItemEntry("Choice 3");
	pulldown_items.DLGAddPopupItemEntry("Choice 4");
	pulldown_items.DLGAddPopupItemEntry("Choice 5");
	pulldown_items.DLGAddPopupItemEntry("Choice 6");
	pulldown_items.DLGAddPopupItemEntry("Choice 7");




// The command below labels the taggroup for the pulldown menu with a string - 'MyPullDown'. This is used in the Reset function
// to source the taggroup, without having to use a global variable for the tag group

	pulldown.DLGIdentifier("MyPullDown")
	



	taggroup label2=dlgcreatelabel("Choose Here").dlganchor("Centre")
	taggroup pulldowngroup=dlggroupitems(label2, pulldown)

	return pulldowngroup
}

// This creates the reset and cancel buttons in the dialog

TagGroup MakeButtons()
{
	taggroup pushbuttons
	TagGroup CalculateButton = DLGCreatePushButton("Reset", "Reset").DLGSide("Bottom");
	calculatebutton.dlgexternalpadding(10,10)
	TagGroup CancelButton = DLGCreatePushButton(" Cancel ", "cancelpane").DLGSide("Bottom");
	cancelbutton.dlgexternalpadding(10,10)
	pushbuttons=dlggroupitems(calculatebutton, cancelbutton)
	pushbuttons.dlgtablelayout(2,1,0)

	return pushbuttons
}


// function to create the dialog

void createdialog()
{
	TagGroup dialog_items;	
	TagGroup dialog = DLGCreateDialog("Enter Specimen Number and User Name", dialog_items);
	
	dialog_items.DLGAddElement(makepulldowns() );
	dialog_items.DLGAddElement( MakeFields() );
	dialog_items.dlgaddelement(MakeButtons() );
	dialog.DLGTableLayout(2,2, 0);

	object dialog_frame = alloc(DialogLibraryTestClass).init(dialog)
	dialog_frame.display("Set and Reset Pulldowns")

}


// Main Program
createdialog()



