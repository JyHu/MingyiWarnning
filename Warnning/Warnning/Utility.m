//
//  Utility.m
//  Warnning
//
//  Created by 胡金友 on 15/7/29.
//  Copyright (c) 2015年 胡金友. All rights reserved.
//

#import "Utility.h"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation Utility

+ (void)notify:(NSString *)msg
{
    UILocalNotification *notify = [[UILocalNotification alloc] init];
    
    notify.alertBody = msg;
    
    notify.soundName = UILocalNotificationDefaultSoundName;
    
    notify.alertTitle = @"提醒";
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notify];
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (BOOL)isWorkingTime
{
    NSDate *curDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comp = [calendar components:NSCalendarUnitHour fromDate:curDate];
    
    NSInteger hour = [comp hour];
    
    if (hour < 10 || hour > 18)
    {
        return YES;
    }
    
    return NO;
}

@end
