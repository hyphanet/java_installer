/* 
    Copyright (C) 2015 Stephen Oliver <steve@infincia.com>
    
    This code is distributed under the GNU General Public License, version 2.
    
    3rd party libraries may be distributed under an alternate Open Source license.
    
    See the LICENSE file included with this code for details.
    
*/


@import Foundation;

#pragma mark - General constants

FOUNDATION_EXPORT NSString *const FNWebDomain;

FOUNDATION_EXPORT NSTimeInterval const FNNodeCheckTimeInterval;

#pragma mark - NSUserDefaults keys

FOUNDATION_EXPORT NSString *const FNStartAtLaunchKey;

FOUNDATION_EXPORT NSString *const FNNodeURLKey;
FOUNDATION_EXPORT NSString *const FNNodeInstallationDirectoryKey;
FOUNDATION_EXPORT NSString *const FNNodeFirstLaunchKey;

#pragma mark - Custom NSNotifications

FOUNDATION_EXPORT NSString *const FNNodeStateRunningNotification;
FOUNDATION_EXPORT NSString *const FNNodeStateNotRunningNotification;

#pragma mark - Node state

typedef NS_ENUM(NSInteger, FNNodeState) {
    FNNodeStateUnknown    = -1,
    FNNodeStateNotRunning =  0,
    FNNodeStateRunning    =  1
};