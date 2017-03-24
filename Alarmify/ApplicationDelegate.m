//
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import "ApplicationDelegate.h"

@implementation ApplicationDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;
@synthesize aboutController = _aboutController;
@synthesize settingsController = _settingsController;

#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
    [self panelController];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
        [_panelController loadWindow];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller{
    return self.menubarController.statusItemView;
}

- (void) panelControllerDidUpdate:(PanelController *)controller {
    if (controller.alarmButton.state) {
        self.menubarController.statusItemView.currentImagePath = @"bar_spotifyface";
    } else {
        self.menubarController.statusItemView.currentImagePath = @"bar_clockface";

    }
    [self.menubarController.statusItemView updateLayer];
}

#pragma mark - AboutControllerDelegate

- (void) onOpenAboutController {
    if (_aboutController == nil){
        _aboutController = [[AboutController alloc] initWithWindowNibName:@"About"];
        [_aboutController loadWindow];
    }
    [_aboutController showWindow:self];
}

#pragma mark - SettingsControllerDelegate

- (void) onOpenSettingsController {
    if (_settingsController == nil){
        _settingsController = [[SettingsController alloc] initWithWindowNibName:@"Settings"];
        [_settingsController loadWindow];
    }
    
    [_settingsController showWindow:self];
    [_settingsController refreshSettings];
}

- (void) refreshSettings {
    [_settingsController refreshSettings];
}


@end
