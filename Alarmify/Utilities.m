//
//  Alarmify
//  Licensed under the Mozilla Public License 2.0
//

#import "Utilities.h"
#import "STPrivilegedTask.h"

@implementation Utilities

+ (NSArray *) runSystemCommand:(NSString *)cmd isSudoRequired:(BOOL)isSudoRequired
{
    NSLog(@"System Command: %@", cmd);
    if (isSudoRequired)
    {
        STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
        [privilegedTask setLaunchPath:@"/bin/sh"];
        [privilegedTask setArguments:[NSArray arrayWithObjects:@"-c", cmd, nil]];
        OSStatus err = [privilegedTask launch];
        return [NSArray arrayWithObjects:[NSNumber numberWithBool:err == errAuthorizationSuccess], @"", nil];
    }
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects:@"-c", cmd, nil]];
    
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    NSFileHandle *file = [outputPipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    return [NSArray arrayWithObjects:[NSNumber numberWithBool:true], output, nil];
}

+ (double) dateTimeMinuteDifference: (NSDate *)d1 with:(NSDate *)d2 includeDate:(bool)includeDate
{
    if (!includeDate)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSString *time1 = [formatter stringFromDate:d1];
        NSString *time2 = [formatter stringFromDate:d2];
        d1 = [formatter dateFromString:time1];
        d2 = [formatter dateFromString:time2];
    }
    return (double)([d1 timeIntervalSinceDate:d2] / 60.0);
}

+ (int) dayOfWeek: (NSDate *) date
{
    // Day of week Sunday = 1, Monday = 2 ...
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:date];
    // Day of week Monday = 1, Sunday = 7 ...
    int day = (int) [comps weekday] - 1;
    if (day <= 0) day = 7;
    return day;
}

@end
