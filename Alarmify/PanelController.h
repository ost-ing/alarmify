#import "BackgroundView.h"
#import "StatusItemView.h"
#import "AboutController.h"
#import "SettingsController.h"
#import "SpotifyAutoplayer.h"
#import "AudioHelper.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;
- (void) panelControllerDidUpdate:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate, NSSpeechRecognizerDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<
        PanelControllerDelegate,
        AboutControllerDelegate,
        SettingsControllerDelegate> _delegate;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<
    PanelControllerDelegate,
    AboutControllerDelegate,
    SettingsControllerDelegate> delegate;
- (id)initWithDelegate:(id<PanelControllerDelegate, AboutControllerDelegate, SettingsControllerDelegate>)delegate;
- (void)openPanel;
- (void)closePanel;


// Application
@property (nonatomic, unsafe_unretained) IBOutlet NSButton *alarmButton;
@property (nonatomic, unsafe_unretained) IBOutlet NSDatePicker *datePicker;
@property (nonatomic, unsafe_unretained) IBOutlet NSButton *weekdaysButton, *weekendsButton;
@property (nonatomic, unsafe_unretained) IBOutlet NSMenu *additionalMenu;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *wakeupTextField;

- (IBAction)onAlarmToggled:(NSButton *)button;
- (IBAction)onWeekdayAndWeekendButtonPressed:(NSButton *) button;
- (IBAction)onDatePickerChanged:(NSDatePicker *)datePicker;
- (IBAction)onOpenAdditionalMenu:(NSButton *)button;
- (IBAction)onQuitApplication:(NSMenuItem *)item;
- (IBAction)onOpenSettingsMenu:(NSMenuItem *)item;

@end
