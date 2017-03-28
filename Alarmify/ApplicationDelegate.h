//
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import "MenubarController.h"
#import "PanelController.h"
#import "AboutController.h"
#import "SettingsController.h"


@interface ApplicationDelegate : NSObject <
    NSApplicationDelegate,
    PanelControllerDelegate,
    AboutControllerDelegate,
    SettingsControllerDelegate
>

@property (nonatomic, strong) SettingsController *settingsController;
@property (nonatomic, strong) AboutController *aboutController;
@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;

- (IBAction)togglePanel:(id)sender;

@end
