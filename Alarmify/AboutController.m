//
//  AboutController.m
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import "AboutController.h"

@interface AboutController ()

@end

@implementation AboutController

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)awakeFromNib
{
    [self.window setLevel:CGWindowLevelForKey(kCGFloatingWindowLevelKey)];
}

- (void)onKlartek:(id)sender
{
    NSURL* url = [[NSURL alloc]initWithString:@"http://klartek.net"];
    
    [[NSWorkspace sharedWorkspace] openURLs:@[url]
                    withAppBundleIdentifier:@"com.apple.Safari"
                                    options:NSWorkspaceLaunchAsync
             additionalEventParamDescriptor:nil
                          launchIdentifiers:nil];
}

- (void)onLegal:(id)sender
{
    NSURL* url = [[NSURL alloc]initWithString:@"http://klartek.net/alarmify/legal/"];
    
    [[NSWorkspace sharedWorkspace] openURLs:@[url]
                    withAppBundleIdentifier:@"com.apple.Safari"
                                    options:NSWorkspaceLaunchAsync
             additionalEventParamDescriptor:nil
                          launchIdentifiers:nil];
}

@end
