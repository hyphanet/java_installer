/* 
    This code is distributed under the GNU General Public License, version 2 
    (or at your option any later version).
    
    3rd party libraries may be distributed under an alternate Open Source license.
    
    See the LICENSE file included with this code for details.
    
*/


#import "FNAppDelegate.h"


@interface FNAppDelegate ()

@end

@implementation FNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:FNNodeFirstLaunchKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
