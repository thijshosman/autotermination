// Example code which shows how to attach an event listener to the front-most image

// - which would typically be a live image. The listener listens for an event, in this case a

// change in the image, such as when a live image updates. It then invokes the DataChanged() method.

// This could contain any processing such as creating an FFT, but here it simply reports the sum of

// the image in the Results window.

 

// You can test this script having a live image from a camera updating on the screen. When the

// script is run, it attaches a listener to the live image, and every time the image updates,

// the sum value in the Results window is updated. When you close the live image, the listener object

// goes out of scope and the destructor function is invoked - it reports that the image has been closed.

 

// The script will listen for four changes, after which the listener is removed.

 

 

// This script is fine for live image processing. However, be aware that if the processing creates a

// new image - such as an FFT, this script makes the FFT a zombie. If you kill (close) it, the original

// event listener will simply make it pop back up again. The only way to stop the FFT is to stop the

// live image. There is a technique for dealing with this, which involves adding a second (key) listener

// to the FFT image, so you know when it has been closed - this is illustrated in the example script

// 'Using two listeners to do live processing'.

 

// Acknowledgements: Bernhard Schaffer and Vincent Hou did all the heavy lifting to work this out.

 

// D. R. G. Mitchell, adminnospam@dmscripting.com (remove the nospam to make this work)

// version:20130804, v1.0, www.dmscripting.com

 

 

// Global variables being

 

number EventToken //the id of the listener

number counter // a counting variable to keep track of the number of changes (events)

 

 

// This is the Event Handler class which responds to the listener.

 

Class MyEventHandler

{

 

// Functions responds when the data in img is changed. The event flag has a value of 4

// img is the image to which the event handler has been added.

void DataChanged(object self, number event_flag, image img)

{

number sumval=sum(img)

result("\n\nChange: "+(counter+1)+" Image sum="+sumval)

// Each time the image is changed, the counter is incremented. After four changes, the listener is removed

counter=counter+1

if(counter>3)

{

img.ImageRemoveEventListener(EventToken)

result("\n\nFour changes have been detected - the Listener has been removed.")

}

}

 

 

// This is the constructor it is invoked when the Listener object is created. In this case

// it does nothing except report itself in the Results window.

 

MyEventHandler( object self)

{

Result("\n\nEvent Handler Constructor called. Listener attached to image.")

}

// The destructor responds when either four changes have been detected or the image has been closed.

~MyEventHandler(object self)

{

if(counter>3) result("\n\nEvent Handler Destructor called. Four changes detected.")

else result("\n\nEvent Handler Destructor called. Image Closed.")

 

}

}

 

 

// Main script function - this is wrapped in a function to help avoid memory leaks.

 

void main()

{

// Check that at least one image is displayed

number nodocs=countdocumentwindowsoftype(5)

if(nodocs<1)

{

showalert("Ensure a live image is displayed front-most.",2)

return

}

// Source the front-most image

image front:= GetFrontImage()

front.setname("Live Image")

// Create the event listener object and attach it to the front-most image. The event map describes the mapping

// of the event to the reponse. The event is data_value_changed - this a predefined event in the DM scripting language

// DataChanged is the method in the EventHandler Class which is called when the event is detected.

// EventToken is a numerical id used to identity the listener. It is used to remove the event listener.

object EventListener=alloc(MyEventHandler)

string eventmap="data_value_changed:DataChanged"

EventToken = front.ImageAddEventListener(EventListener, eventmap)

}

 

 

// Main program

main()