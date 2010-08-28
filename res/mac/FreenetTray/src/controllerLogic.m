//
//  controllerLogic.m
// This code is distributed under the GNU General
// Public License, version 2 (or at your option any later version). See
// http://www.gnu.org/ for further details of the GPL. */
// Code version 1.1

#import "controllerLogic.h"
#include "UKLoginItemRegistry.h"

@implementation controllerLogic
 
- (void)awakeFromNib { 
	// set this class to be NSApp delegate
	[NSApp setDelegate:self];
	// load factory defaults for node location variables, sourced from defaults.plist
	NSString *defaultsPlist = [[NSBundle mainBundle]
							   pathForResource:@"defaults" ofType:@"plist"];
	NSDictionary *defaultsPlistDict = [NSDictionary dictionaryWithContentsOfFile:defaultsPlist];
	//find our preferences plist if one exists, 
	//note that this name will change depending on what this application calls itself in the bundleidentifier item in info.plist
	//this is just the easiest way to tell if it exists
	NSString *preferencesLocation = @"~/Library/Preferences/com.freenet.tray.plist";
	NSString *preferencesPlist = [preferencesLocation stringByStandardizingPath];
	//get standard user defaults for use a few lines down
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//file manager for reading plist
	NSFileManager *fileManager = [NSFileManager defaultManager];
	//check for plist, if it isn't there this is first launch and we set defaults and setup autostart/loginitem
	if(! [fileManager isReadableFileAtPath:preferencesPlist]) {
		//NSLog(@"preferences not found");
		NSDictionary *appDefaults = [NSDictionary dictionary];
		[defaults registerDefaults:appDefaults];
		//retrieve value for specific keys from the defaults.plist object we created earlier, then shove them into the userdefaults object so they get stored on the users machine later by the synchronize method
		[defaults setValue:[defaultsPlistDict objectForKey:@"nodeurl"] forKey:@"nodeurl"];
		[defaults setValue:[defaultsPlistDict objectForKey:@"nodepath"] forKey:@"nodepath"];
		// set a flag so we know this is the first launch, can be referenced later
		[defaults setBool:YES forKey:@"firstlaunch"];
		// take the defaults we just setup and cause them to be written to disk
		[defaults synchronize];
		// since this is the first launch, we add a login item for the user. if they delete that login item it wont be added again
		[self addLoginItem];
	}	
	// spawn a thread to keep the node status indicator updated in realtime. The method called here cannot be run again while this thread is running
	[NSThread detachNewThreadSelector:@selector(checkNodeStatus:) toTarget:self withObject:nil];
	//start the tray item
	[self initializeSystemTray:nil];
}

- (void) addLoginItem {
	[UKLoginItemRegistry addLoginItemWithPath:[[NSBundle mainBundle] bundlePath] hideIt: NO];
}

- (void)initializeSystemTray:(id)sender {
	// load some images into memory
	trayImageRunning = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FreenetTray-Running-24" ofType:@"png"]];
	trayImageNotRunning = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FreenetTray-NotRunning-24" ofType:@"png"]];
	trayHighlightImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FreenetTray-Selected-24" ofType:@"png"]];
	// create an NSMenu to hold our menu options, and populate it with our initial items
	// this is not the best way to create a GUI, but there are only a few items so it isn't necessary to use interface builder
	// there are some strange bugs/behavior when you try to modify NSMenuItems that were created in interface builder, so these are created in code instead
	trayMenu = [[[NSMenu alloc] initWithTitle:@""] retain];
	// this item is changed later on in reaction to the node status
	startStopToggle = [trayMenu addItemWithTitle: @"Start Freenet"  
						action: @selector (startFreenet:)  
				 keyEquivalent: @"s"];
	// opens the node url in the users default browser
	webInterfaceOption = [trayMenu addItemWithTitle: @"Open Web Interface"  
											 action: @selector (openWebInterface:)  
									  keyEquivalent: @"w"];
	[trayMenu addItem:[NSMenuItem separatorItem]];
	//not currently implemented so commented out
	//preferencesOption = [trayMenu addItemWithTitle: @"Preferences"  
	//										action: @selector (openPreferences:)  
	//								 keyEquivalent: @"p"];
	// opens the standard about panel with info sourced from the info.plist file
	aboutPanel = [trayMenu addItemWithTitle: @"About"  
                                     action: @selector (orderFrontStandardAboutPanel:)  
									  keyEquivalent: @"a"];
	// ends the program
	quitItem = [trayMenu addItemWithTitle: @"Quit"  
								   action: @selector (quitProgram:)  
							keyEquivalent: @"q"];
	// create an NSStatusItem and load some images, strings and variables into it. Icon size area is square, but can be made to fit longer images
    trayItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	// sets the image that will be displayed when the menu bar item is clicked
	[trayItem setAlternateImage:trayHighlightImage];
	//no title
	[trayItem setTitle:@""];
	[trayItem setToolTip:@"Freenet Menu"];
	// this can be turned off if highlighting isn't needed
	[trayItem setHighlightMode:YES];
	// set our previously created NSMenu to be the main menu of this NSStatusItem
	[trayItem setMenu:trayMenu];
	// enable our NSStatusItem
	[trayItem setEnabled:YES];
}

-(void)nodeRunning:(id)sender {
	//node was running so change the image to reflect that
	[trayItem setImage:trayImageRunning];
	//change the title of the main menu option
	[startStopToggle setTitle:@"Stop Freenet"];
	// change the action of the main menu option
	[startStopToggle setAction:@selector(stopFreenet:)];
}

-(void)nodeNotRunning:(id)sender {
	//node was not running so set image accordingly 
	[trayItem setImage:trayImageNotRunning];
	//change the title of the main menu option
	[startStopToggle setTitle:@"Start Freenet"];
	// change the action of the main menu option
	[startStopToggle setAction:@selector(startFreenet:)];
}

- (void)checkNodeStatus:(id)sender {
	// this may not be necessary
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	//get users preferred location of node files and put it in a string
	NSMutableString *nodeFilesLocation = (NSMutableString*)[[[NSUserDefaults standardUserDefaults] objectForKey:@"nodepath"] stringByStandardizingPath];
	//make a new string to store the absolute path of the anchor file
	NSMutableString *anchorFile = [[NSMutableString alloc] initWithString:nodeFilesLocation];
	[anchorFile appendString:@"/Freenet.anchor"];
	//NSLog(@"%@", anchorFile);
	// start a continuous loop to set the status indicator, this whole method (checkNodeStatus) should be started from a separate thread so it doesn't block main app
	while (1) {
		//file manager for reading anchor file
		NSFileManager *fileManager;
		fileManager = [NSFileManager defaultManager];
		//if the anchor file exists, the node should be running.
		if([fileManager isReadableFileAtPath:anchorFile]) {
			// if we find the anchor file we run the NodeRunning method, this can be a false positive, node may be stopped even if this file exists
			[self performSelectorOnMainThread:@selector(nodeRunning:) withObject:nil waitUntilDone:NO];
		}
		else {
			// otherwise we run NodeNotRunning which will display the Not Running image to the user, this should be 100% reliable, the node won't run without that anchor file
			[self performSelectorOnMainThread:@selector(nodeNotRunning:) withObject:nil waitUntilDone:NO];
		}
		sleep(5);
	}
	[anchorFile release];
	[autoreleasepool release];
}

- (void)startFreenet:(id)sender {
	//get users preferred location of node files and put it in a string
	NSMutableString *nodeFilesLocation = (NSMutableString*)[[[NSUserDefaults standardUserDefaults] objectForKey:@"nodepath"] stringByStandardizingPath];
	//make a new string to store the absolute path to the run script
	NSMutableString *runScriptTemp = [[NSMutableString alloc] initWithString:nodeFilesLocation];
	[runScriptTemp appendString:@"/run.sh"];
	//NSLog(@"%@",runScriptTemp);
	NSString *runScript = [NSString stringWithFormat:@"\"%@\" start",runScriptTemp];
	//NSLog(@"%@",runScript);
	//make a new string to store the absolute path of the anchor file
	NSMutableString *anchorFile = [[NSMutableString alloc] initWithString:nodeFilesLocation];
	[anchorFile appendString:@"/Freenet.anchor"];
	//NSLog(@"%@", anchorFile);
	//load arguments into an array for use later by run.sh script
	NSArray * startArguments = [NSArray arrayWithObjects:@"-c",runScript,nil];
	//file manager for reading anchor file
	NSFileManager *fileManager;
	fileManager = [NSFileManager defaultManager];
	if([fileManager isReadableFileAtPath:anchorFile]) {
		// user wants to start freenet, but anchor file is already there. Either node crashed or node file location is wrong.
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Error"];
		[alert setInformativeText:@"Your node is already running!"];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
		[alert release];
	}	
	else {
		//nstask to start freenet
		NSTask *startFreenet;
		startFreenet = [[NSTask alloc] init];
		[startFreenet setLaunchPath:@"/bin/sh"];
		[startFreenet setArguments:startArguments];
		[startFreenet launch];
		[startFreenet terminate];
		[startFreenet release];
	}
	//[runScript release];
	[anchorFile release];

}

- (void)stopFreenet:(id)sender {
	//get users preferred location of node files and put it in a string	
	NSMutableString *nodeFilesLocation = (NSMutableString*)[[[NSUserDefaults standardUserDefaults] objectForKey:@"nodepath"] stringByStandardizingPath];
	//make a new string to store the absolute path of the anchor file
	NSMutableString *anchorFile = [[NSMutableString alloc] initWithString:nodeFilesLocation];
	[anchorFile appendString:@"/Freenet.anchor"];
	//NSLog(@"%@", anchorFile);
	//store location of the rm command so we can reference it
	NSString *rmCommand = @"/bin/rm";
	//set arguments to rm command to be anchor file
	NSArray *rmArguments = [NSArray arrayWithObject:anchorFile];
	//file manager for reading anchor file
	NSFileManager *fileManager;
	fileManager = [NSFileManager defaultManager];
	if([fileManager isReadableFileAtPath:anchorFile]) {
		// since we found the anchor file and the user wants to stop freenet, we set an NSTask to delete the file, which should cause the node to stop
		NSTask *stopFreenet;
		stopFreenet = [[NSTask alloc] init];
		[stopFreenet setLaunchPath:rmCommand];
		[stopFreenet setArguments:rmArguments];
		[stopFreenet launch];
		[stopFreenet terminate];
		[stopFreenet release];
	}
	else {
		//if user wants to stop freenet but anchor file doesn't exist, either node isn't running or files aren't where they should be. Either way we can't do anything but throw an error box up on the screen
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Error"];
		[alert setInformativeText:@"Your freenet node was not running!"];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
		[alert release];
		}
	[anchorFile release];
	[rmCommand release];
}

- (void)openWebInterface:(id)sender {
	//load the URL of our node from the preferences
	NSString *nodeURL = [[NSUserDefaults standardUserDefaults] valueForKey:@"nodeurl"];
	// This is a method to open the fproxy page in users default browser.
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:nodeURL]];
}

- (void) dealloc {
	[trayMenu release];
	[trayItem release];
	[super dealloc];
}

- (void)quitProgram:(id)sender {
	[NSApp terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstlaunch"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
@end
