//
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import <Cocoa/Cocoa.h>
#import "SpotifyAutoplayer.h"
#import "PopupController.h"

@class SettingsController;

@protocol SettingsControllerDelegate <NSObject>

@optional

- (void) onOpenSettingsController;
- (void) refreshSettings;

@end


@interface SettingsController : NSWindowController <NSTextFieldDelegate>
{
    
}

@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *spotifyUriTextField;
@property (nonatomic, unsafe_unretained) IBOutlet NSTabView *tabView;
@property (nonatomic, unsafe_unretained) IBOutlet NSPopover *popover;
@property (nonatomic, unsafe_unretained) IBOutlet NSSlider *volumeSlider, *velocitySlider;
@property (nonatomic, unsafe_unretained) IBOutlet NSComboBox *sourceComboBox;
@property (nonatomic, unsafe_unretained) IBOutlet NSButton *launchOnBootup, *spotifyTestButton, *saveButton;

- (void)refreshSettings;
- (IBAction)onSpotifyUriHelp:(id)sender;
- (IBAction)onGeneralHelp:(NSButton *)sender;
- (IBAction)onSpotifyTest:(id)sender;
- (IBAction)onSave:(NSButton *)button;
@end
