//
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import <Foundation/Foundation.h>

@interface SpotifyAutoplayer : NSObject

+ (bool) validateUri:(NSString *)spotifyUri;
+ (void) beginPlaying:(NSString *)spotifyUri andSoundVolume:(NSInteger)soundVolume andSoundVeloctiy:(NSInteger)soundVelocity;
+ (NSString *) templateScript;

@end
