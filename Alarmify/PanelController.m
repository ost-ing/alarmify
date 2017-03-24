#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "Utilities.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1
#define SEARCH_INSET 17
#define POPUP_HEIGHT 65
#define POPUP_HEIGHT_ALARM_OFFSET 0 // 10
#define PANEL_WIDTH 280
#define MENU_ANIMATION_DURATION .1

#define DEFAULT_SPOTIFY_URI @"spotify:album:0RXzDyBEGd2EGQTmv8cxQa"
#define SPOTIFY_URI_TEXTFIELD_TAG 1
#define WEEKDAY_BUTTON_TAG 1
#define WEEKEND_BUTTON_TAG 2
#define BOOTUP_MINUTES 3

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView, delegate = _delegate,
alarmButton, datePicker, weekdaysButton, weekendsButton, additionalMenu, wakeupTextField;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate, AboutControllerDelegate, SettingsControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil){
        _delegate = delegate;
        
        // Use notifications to subscribe to the computer waking up
        NSNotificationCenter* notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
        [notificationCenter removeObserver: self];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAlarmActive"])
        {
            [notificationCenter addObserver: self
                                   selector: @selector(receiveWakeNote:)
                                       name: NSWorkspaceDidWakeNotification
                                     object: NULL];
        }
    }
    return self;
}

- (void)dealloc { }

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    [self loadAlarmConfiguration];
    [self.delegate panelControllerDidUpdate:self];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}


#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel == flag) return;
    _hasActivePanel = flag;
    if (_hasActivePanel)
        [self openPanel];
    else
        [self closePanel];
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    if ([[self window] isVisible]){
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    self.backgroundView.arrowX = panelX;
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}


#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    
    if (statusItemView){
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else{
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool alarmOn = [defaults boolForKey:@"isAlarmActive"];
    
    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.size.height = POPUP_HEIGHT + (alarmOn ? POPUP_HEIGHT_ALARM_OFFSET : 0);
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown){
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed){
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        [self.window orderOut:nil];
    });
}

#pragma mark - Alarm logic

- (void) loadAlarmConfiguration
{
    // Set default states
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool alarmOn = [defaults boolForKey:@"isAlarmActive"];
    [self.alarmButton setState:alarmOn];
    [self.weekdaysButton setState:[[defaults stringForKey:@"isWeekday"] ?: @"false" boolValue]];
    [self.weekendsButton setState:[[defaults stringForKey:@"isWeekend"] ?: @"false" boolValue]];
    [self.datePicker setDateValue:[defaults objectForKey:@"wakeTime"] ?: [NSDate date]];
    
    // Dont allow changing inputs if alarm is on
    [self.datePicker setEnabled:!alarmOn];
    [self.weekdaysButton setEnabled:!alarmOn];
    [self.weekendsButton setEnabled:!alarmOn];
}


- (void) installAlarm
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *spotifyUri = [defaults stringForKey:@"spotifyUri"] ?: DEFAULT_SPOTIFY_URI;
    if (![[SpotifyAutoplayer sharedInstance] validateUri:spotifyUri])
    {
        NSLog(@"Invalid Spotify URI. Ensure Alarmify is correctly configured.");
        [self.alarmButton setState:false];

        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Alarmify not properly configured"];
        [alert setInformativeText:@"The Spotify URI configured is not valid. Please ensure Alarmify is correctly configured"];
        [alert setIcon:nil];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
        
        return;
    }
    
    // Setup scheduler parameters
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    NSDate *scheduledTime = [self.datePicker.dateValue dateByAddingTimeInterval:-60 * /*BOOTUP_MINUTES*/ 0];
    [outputFormatter setDateFormat:@"mm"];
    NSString *minutes = [outputFormatter stringFromDate:scheduledTime];
    [outputFormatter setDateFormat:@"H"];
    NSString *hours = [outputFormatter stringFromDate:scheduledTime];
    NSString *schedulerDays = @"";
    if (!self.weekdaysButton.state && !self.weekdaysButton.state)
    {
        schedulerDays = @"MTWRFSU";
    }
    else
    {
        if (self.weekdaysButton.state) schedulerDays = [schedulerDays stringByAppendingString:@"MTWRF"];
        if (self.weekendsButton.state) schedulerDays = [schedulerDays stringByAppendingString:@"SU"];
    }
    NSString *schedulerTiming = [NSString stringWithFormat:@"%@:%@:00", hours, minutes];
    
    // Execute shell cmd to schedule macOS to automatically boot
    NSArray* result = [Utilities runSystemCommand:[NSString stringWithFormat:@"pmset repeat cancel; pmset repeat wakeorpoweron %@ %@",
                                                   schedulerDays,
                                                   schedulerTiming]
                                   isSudoRequired:true];
    
    if (![[result objectAtIndex:0] boolValue])
    {
        NSLog(@"Installation failed");
        [self.alarmButton setState:false];
        return;
    }
    
    // Use notifications to subscribe to the computer waking up
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification
                                                             object: NULL];
    
    // Update NSUserDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:TRUE forKey:@"isAlarmActive"];
    [prefs synchronize];
    
    // Reload NSUserDefaults
    [self loadAlarmConfiguration];
    [self.delegate refreshSettings];
}

-(void) receiveWakeNote:(NSNotification *)notification
{
    // Reload the NSUserDefaults (incase something has changed) will update the GUI
    [self loadAlarmConfiguration];
    
    // Read out the values
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *spotifyUri = [defaults stringForKey:@"spotifyUri"];
    NSInteger soundVolume = [defaults integerForKey:@"volumeLevel"] ?: 80;
    NSInteger soundVelocity = [defaults integerForKey:@"velocityLevel"] ?: 1;
    NSDate *dateTime = [self.datePicker dateValue];
    
    // If alarm is off, or it has already fired, abort
    if (!self.alarmButton.state) {
        return;
    }
    
    // We only want to trigger the alarm if the wake event happened approximately at the time of scheduling
    double dt = fabs([Utilities dateTimeMinuteDifference:dateTime with:[NSDate date] includeDate:false]);
    if (dt > BOOTUP_MINUTES)
    {
        // TODO: Experiment with what the best value is, smaller = more accurate but could affect slower systems
        return;
    }
    
    [[SpotifyAutoplayer sharedInstance]beginPlaying:spotifyUri
                                     andSoundVolume:soundVolume
                                   andSoundVeloctiy:soundVelocity];
}


- (void) uninstallAlarm
{
    // Remove the macOS schedule
    NSArray* result = [Utilities runSystemCommand:@"pmset repeat cancel" isSudoRequired:true];
    if (![[result objectAtIndex:0] boolValue])
    {
        NSLog(@"Uninstallation failed");
        [self.alarmButton setState:true];
        return;
    }
    
    // Remove notification
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver: self];
    
    // Update NSUserDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"false" forKey:@"isAlarmActive"];
    [prefs synchronize];
    
    // Reload NSUserDefaults
    [self loadAlarmConfiguration];
    [self.delegate refreshSettings];
}


- (IBAction)onAlarmToggled:(NSButton *)button
{
    if (button.state)
        [self installAlarm];
    else
        [self uninstallAlarm];
    
    [self.delegate panelControllerDidUpdate:self];
}

- (IBAction)onWeekdayAndWeekendButtonPressed:(NSButton *) button
{
    if (button.tag != WEEKDAY_BUTTON_TAG && button.tag != WEEKEND_BUTTON_TAG) return;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:button.state ? @"true" : @"false"
              forKey:button.tag == WEEKDAY_BUTTON_TAG ? @"isWeekday" : @"isWeekend"];
    [prefs synchronize];
}

- (IBAction)onDatePickerChanged:(NSDatePicker *)aDatePicker
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:aDatePicker.dateValue forKey:@"wakeTime"];
    [prefs synchronize];
}

- (IBAction)onOpenAdditionalMenu:(NSButton *)button
{
    NSPoint location = [ self.window convertBaseToScreen:button.frame.origin ];
    [self.additionalMenu popUpMenuPositioningItem:nil atLocation:location inView:nil];
}

- (IBAction)onQuitApplication:(NSMenuItem *)item
{
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

- (IBAction)onOpenAboutMenu:(NSMenuItem *)item
{
    [self.delegate onOpenAboutController];
}

- (IBAction)onOpenSettingsMenu:(NSMenuItem *)item
{
    [self.delegate onOpenSettingsController];
}

@end
