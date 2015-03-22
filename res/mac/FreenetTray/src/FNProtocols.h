/* 
    This code is distributed under the GNU General Public License, version 2 
    (or at your option any later version).
    
    3rd party libraries may be distributed under an alternate Open Source license.
    
    See the LICENSE file included with this code for details.
    
*/

#import <Foundation/Foundation.h>

@protocol FNNodeStateProtocol <NSObject>
@required
-(void)nodeStateRunning:(NSNotification*)notification;
-(void)nodeStateNotRunning:(NSNotification*)notification;
@end
