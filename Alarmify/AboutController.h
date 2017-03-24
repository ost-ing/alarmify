//
//  AboutController.h
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import <Cocoa/Cocoa.h>

@class AboutController;

@protocol AboutControllerDelegate <NSObject>

@optional

- (void) onOpenAboutController;

@end

@interface AboutController : NSWindowController

- (IBAction)onKlartek:(id)sender;
- (IBAction)onLegal:(id)sender;


@end
