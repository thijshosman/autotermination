// This example script shows how to create a sub-dialog from within a dialog. This can

// be useful where, for example, pressing a button creates a prompt for more information.

// This could be in the form of a subdialog presenting fields in which to enter the data.

 

// D. R. G. Mitchell, adminnospam@dmscripting.com (remove the nospam to make this email address work)

// September 2009

// version:20090922, v1.0

 

 

// the class maindialog is of the type user interface frame, and responds to interaction

// with the main dialog

 

class MainDialog : uiframe

{

 

// pressing the button creates the subdialog

 

void buttonresponse(object self)

{

 

//this is the response when the button is pressed

// create a subdialog called subdialog. This contains a single field

taggroup subdialog, subdialogitems, subdialoglabel

subdialog=dlgcreatedialog("subdialog", subdialogitems)

taggroup intfieldlabel=dlgcreatelabel("subdialog value")

taggroup intfield=dlgcreateintegerfield(42,4)

taggroup intfieldgroup=dlggroupitems(intfieldlabel, intfield)

subdialogitems.dlgaddelement(intfieldgroup)

// set up and display the dialog using pose() - automatically

// generates the OK and cancel buttons

object thesubdialog=alloc(UIFrame).init(subdialog)

 

 

// If Cancel is pressing the dialog closes and control returns to the main dialog

 

// If OK is pressed the following code is executed. In this case the value from the

// field in the subdialog is sourced and displayed.

if(thesubdialog.pose())

{

number intfieldval=dlggetvalue(intfield)

showalert("The subdialog field value = "+intfieldval,2)

}

return

}

}

 

 

// function to create a button inside a box

 

taggroup MakeButton()

{

 

// Creates a box in the dialog which surrounds the button

 

taggroup box_items

taggroup box=dlgcreatebox(" Box Around Button", box_items)

box.dlgexternalpadding(5,5)

box.dlginternalpadding(25,25)

 

// Creates the button

 

TagGroup ExampleButton = DLGCreatePushButton("Get More Info", "buttonresponse")

examplebutton.dlgexternalpadding(10,10)

 

box_items.dlgaddelement(examplebutton)

return box

 

}

 

// This function creates the dialog, drawing togther the parts (buttons etc) which make it up

// and alloc 'ing' the dialog with the response, so that one responds to the other. It also

// displays the dialog

 

void CreateMainDialog()

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

 

object dialog_frame = alloc(MainDialog).init(dialog)

dialog_frame.display("Main Dialog")

}

 

 

// calls the above function which puts it all together

 

createmaindialog()

 