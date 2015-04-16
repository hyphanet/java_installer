/* 
    Copyright (C) 2015 Stephen Oliver <steve@infincia.com>

    This code is distributed under the GNU General Public License, version 2 
    (or at your option any later version).
    
    3rd party libraries may be distributed under an alternate Open Source license.
    
    See the LICENSE file included with this code for details.
    
*/


#import "FNAppDelegate.h"

#import "FNNodeController.h"
#import "FNDropdownMenuController.h"

#import "NSBundle+LoginItem.h"

@interface FNAppDelegate ()
    
@end

@implementation FNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
	// load factory defaults for node location variables, sourced from defaults.plist
	NSString *defaultsPlist = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
	NSDictionary *defaultsPlistDict = [NSDictionary dictionaryWithContentsOfFile:defaultsPlist];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [defaults registerDefaults:defaultsPlistDict];
 
    
    nodeController = [[FNNodeController alloc] init];

	/* 
        Check for first launch key, if it isn't there this is first launch and 
        we need to setup autostart/loginitem
    */
	if([defaults boolForKey:FNNodeFirstLaunchKey]) {
        [defaults setBool:NO forKey:FNNodeFirstLaunchKey];
        [defaults synchronize];
		/* 
            Since this is the first launch, we add a login item for the user. If 
            they delete that login item it wont be added again.
        */
		[[NSBundle mainBundle] addToLoginItems];
	}
    dropdownMenuController = [[FNDropdownMenuController alloc] init];
    dropdownMenuController.nodeController = nodeController;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

@end
