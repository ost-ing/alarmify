//
//  Utilities.h
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject
+ (NSArray *) runSystemCommand:(NSString *)cmd isSudoRequired:(BOOL)isSudoRequired;
+ (double) dateTimeMinuteDifference: (NSDate *)d1 with:(NSDate *)d2 includeDate:(bool)includeDate;
+ (int) dayOfWeek: (NSDate *) date;
@end
