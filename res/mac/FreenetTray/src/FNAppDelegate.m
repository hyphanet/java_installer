// This code is distributed under the GNU General
// Public License, version 2 (or at your option any later version). See
// http://www.gnu.org/ for further details of the GPL. */


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
