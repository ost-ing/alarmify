//
//  SettingsController.m
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import "SettingsController.h"

#define SPOTIFY_URI_TEXTFIELD_TAG 0
#define SLIDER_VOLUME_TAG 0
#define SLIDER_VELOCITY_TAG 1

@interface SettingsController ()

@end

@implementation SettingsController

@synthesize spotifyUriTextField;
@synthesize tabView;
@synthesize popover;
@synthesize volumeSlider, velocitySlider;
@synthesize sourceComboBox;
@synthesize spotifyTestButton;

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)awakeFromNib
{
    [self loadSettings];
    [self.window setLevel:CGWindowLevelForKey(kCGFloatingWindowLevelKey)];
}

- (void)refreshSettings
{
    [self loadSettings];
}

- (void)loadSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool alarmOn = [defaults boolForKey:@"isAlarmActive"];
    [self.spotifyUriTextField setStringValue:[defaults stringForKey:@"spotifyUri"] ?: @"spotify:search:genre:jazz"];
    [self.volumeSlider setIntegerValue:[defaults integerForKey:@"volumeLevel"] ?: 80];
    [self.velocitySlider setIntegerValue:[defaults integerForKey:@"velocityLevel"] ?: 1];
    [self.sourceComboBox selectItemAtIndex:0];
    
    [self.spotifyUriTextField setEnabled:!alarmOn];
    [self.volumeSlider setEnabled:!alarmOn];
    [self.velocitySlider setEnabled:!alarmOn];
    [self.sourceComboBox setEnabled:false];
    [self.saveButton setEnabled:!alarmOn];
}

-(IBAction)onSpotifyUriHelp:(NSButton *)sender
{
    PopupController *viewController = [[PopupController alloc] initWithNibName:@"PopupSpotifyUri" bundle:nil];
    
    // Create popover
    NSPopover *entryPopover = [[NSPopover alloc] init];
    [entryPopover setContentSize:NSMakeSize(615, 237)];
    [entryPopover setBehavior:NSPopoverBehaviorTransient];
    [entryPopover setAnimates:YES];
    [entryPopover setContentViewController:viewController];
    
    // Convert point to main window coordinates
    NSRect entryRect = [sender convertRect:sender.bounds
                                    toView:[[NSApp mainWindow] contentView]];
    
    // Show popover
    [entryPopover showRelativeToRect:entryRect
                              ofView:[[NSApp mainWindow] contentView]
                       preferredEdge:NSMinYEdge];
}

-(IBAction)onGeneralHelp:(NSButton *)sender
{
    PopupController *viewController = [[PopupController alloc] initWithNibName:@"PopupGeneral" bundle:nil];
    
    // Create popover
    NSPopover *entryPopover = [[NSPopover alloc] init];
    [entryPopover setContentSize:NSMakeSize(256, 226)];
    [entryPopover setBehavior:NSPopoverBehaviorTransient];
    [entryPopover setAnimates:YES];
    [entryPopover setContentViewController:viewController];
    
    // Convert point to main window coordinates
    NSRect entryRect = [sender convertRect:sender.bounds
                                    toView:[[NSApp mainWindow] contentView]];
    
    // Show popover
    [entryPopover showRelativeToRect:entryRect
                              ofView:[[NSApp mainWindow] contentView]
                       preferredEdge:NSMinYEdge];
}


-(IBAction)onSpotifyTest:(id)sender
{
    NSString *spotifyUri = self.spotifyUriTextField.stringValue;
    NSInteger soundVolume = self.volumeSlider.integerValue ?: 80;
    NSInteger soundVelocity = self.velocitySlider.integerValue ?: 1;
    
    if (![[SpotifyAutoplayer sharedInstance] validateUri:spotifyUri])
    {
        NSLog(@"Invalid Spotify URI. Ensure Alarmify is correctly configured.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Alarmify not properly configured"];
        [alert setInformativeText:@"The Spotify URI configured is not valid. Please ensure Alarmify is correctly configured"];
        [alert setIcon:nil];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
        return;
    }
    
    [self.spotifyTestButton setEnabled:false];
    
    [[SpotifyAutoplayer sharedInstance]beginPlaying:spotifyUri
                                     andSoundVolume:soundVolume
                                   andSoundVeloctiy:soundVelocity];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC),
                   dispatch_get_main_queue(),
                   ^{ [self.spotifyTestButton setEnabled:true]; });
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Testing Spotify"];
    [alert setInformativeText:@"Alarmify is communicating with Spotify. Your selected album/track/playlist should begin playing shortly. If not, please check the configuration and try again."];
    [alert setIcon:nil];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];   
}

-(IBAction)onSave:(NSButton *)button
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:self.volumeSlider.integerValue forKey:@"volumeLevel"];
    [prefs setInteger:self.velocitySlider.integerValue forKey:@"velocityLevel"];
    [prefs setObject:self.spotifyUriTextField.stringValue forKey:@"spotifyUri"];
    [prefs synchronize];
}

@end
