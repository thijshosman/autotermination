
// A dialog example which shows how to create buttons and how to set them as enabled or disabled and to change

// their status in response to something. In this case, button 1 is enabled and button 2 disabled when the

// dialog is first created. Subsequently pressing button 1 disables button 1 and enables button 2. Pressing

// button 2 enables button 1 and disables button 2 etc.

// Enabling/disabling buttons is a useful way of directing the work flow, without having to use extensive

// error trapping

 

// D. R. G. Mitchell, adminnospam@dmscripting.com (remove the nospam to make this email address work)

// v1.0, March 2005

// version:20050317

// thanks to B. Schaffer for hints on setting buttons enabled/disabled status.

 

// variables

 

taggroup firstbutton, secondbutton

number true=1

number false=0

 

// the class createbuttondialog is of the type user interface frame (UIFrame), and responds to interactions

// with the dialog - in this case pressing buttons



class CreateButtonDialog : uiframe

{

 

	void button1response(object self)

	{

	 

		//this is the response when the button is pressed

		Beep()

		self.Setelementisenabled("first", false);// these commands set the button as enabled or not enabled

		self.Setelementisenabled("second", true);// "second" in this command is the identifier of the button 'secondbutton'

		okdialog("First button pressed")

	 

	}

	 

	void button2response(object self)

	{

	 

		//this is the response when the second button is pressed

		Beep()

		self.Setelementisenabled("first",true);

		self.Setelementisenabled("second",false);

		okdialog("Second button pressed")

	 

	}

 

}

 

// this function creates a button taggroup which returns the taggroup 'box' which is added to

// the dialog in the createdialog function.

 

taggroup MakeButton()

{

 

// Creates a box in the dialog which surrounds the button

 

taggroup box_items

taggroup box=dlgcreatebox(" Parameters ", box_items)

box.dlgexternalpadding(5,5)

box.dlginternalpadding(25,25)

 

// Creates the first button

 

firstButton = DLGCreatePushButton("First Button", "button1response")

dlgenabled(firstbutton,1) // sets the button as enabled when the dialog is first created

dlgidentifier(firstbutton, "first") // identifiers are strings which identify an element, such as a button

// they are used to change the enabled/disabled status of the element in the button response functions above

firstbutton.dlginternalpadding(10,0)

 

box_items.dlgaddelement(firstbutton)

 

// Creates the second button

 

secondButton = DLGCreatePushButton("Second Button", "button2response")

dlgenabled(secondbutton,0)

secondbutton.dlgexternalpadding(5,10)

dlgidentifier(secondbutton, "second")

 

box_items.dlgaddelement(secondbutton)

return box

 

}

 

// This function creates the dialog, drawing togther the parts (buttons etc) which make it up

// and alloc 'ing' the dialog with the response, so that one responds to the other. It also

// displays the dialog

 

void CreateDialogExample()

{

 

// Configure the positioning in the top right of the application window

 

TagGroup position;

position = DLGBuildPositionFromApplication()

position.TagGroupSetTagAsTagGroup( "Width", DLGBuildAutoSize() )

position.TagGroupSetTagAsTagGroup( "Height", DLGBuildAutoSize() )

position.TagGroupSetTagAsTagGroup( "X", DLGBuildRelativePosition( "Inside", 1 ) )

position.TagGroupSetTagAsTagGroup( "Y", DLGBuildRelativePosition( "Inside", 1 ) )

 

TagGroup dialog_items;

TagGroup dialog = DLGCreateDialog("Example Dialog", dialog_items).dlgposition(position);

dialog_items.dlgaddelement( MakeButton() );

 

object dialog_frame = alloc(CreateButtonDialog).init(dialog)

dialog_frame.display("Dialog Template");

 

}

 

// calls the above function which puts it all together

 

createdialogexample()