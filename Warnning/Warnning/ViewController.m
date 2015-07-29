//
//  ViewController.m
//  Warnning
//
//  Created by 胡金友 on 15/7/29.
//  Copyright (c) 2015年 胡金友. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Utility.h"
#import "AnimationView.h"

#define BeaconUUID @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"

@interface ViewController ()<CLLocationManagerDelegate>

@property (retain, nonatomic) CLLocationManager *p_locationManager;
@property (retain, nonatomic) CLBeaconRegion *p_beaconRegion;
@property (assign, nonatomic) CLProximity p_cachedProximity;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (retain, nonatomic) IBOutlet AnimationView *animationView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self popupAnimation:self.logoImageView duration:1.0];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [self animationFlipFromTop:self.logoImageView];
                   });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.34 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       
        [UIView animateWithDuration:1.1
                              delay:0
             usingSpringWithDamping:0.4
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGRect rect = self.logoImageView.frame;
                             rect.origin.y = 100;
                             self.logoImageView.frame = rect;
                         } completion:^(BOOL finished) {
                             [self.animationView animation];
                         }];
                   });
    
    [self initilizationBeacon];
}

#pragma mark - animation

- (void)popupAnimation:(UIView *)outView duration:(CFTimeInterval)duration
{
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:@"easeInEaseOut"];
    
    NSMutableArray * values = [NSMutableArray array];

    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    
    [outView.layer addAnimation:animation forKey:nil];
}

- (void)animationFlipFromTop:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"oglFlip"];
    [animation setSubtype:@"fromTop"];
    
    [view.layer addAnimation:animation forKey:nil];
}

#pragma mark - beacon

- (void)initilizationBeacon
{
    self.p_locationManager = [[CLLocationManager alloc] init];
    self.p_locationManager.delegate = self;
    self.p_locationManager.activityType = CLActivityTypeFitness;
    self.p_locationManager.distanceFilter = kCLDistanceFilterNone;
    self.p_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)
        {
            [self.p_locationManager requestAlwaysAuthorization];
        }
    }
    
    [self.p_locationManager startUpdatingLocation];
    
    [self p_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.p_locationManager startRangingBeaconsInRegion:self.p_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [Utility notify:@"进入检测区域，是不是需要上班打卡了呢 ？亲 ~ "];
    [self.p_locationManager startRangingBeaconsInRegion:self.p_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if (self.p_cachedProximity == CLProximityFar)
    {
        [Utility notify:@"已远离检测区域，是不是下班了呢？要记得打卡哦 ~ "];
    }
    
    [self.p_locationManager stopRangingBeaconsInRegion:self.p_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0)
    {
        CLBeacon *beacon = [beacons lastObject];
        
        if (beacon.proximity != CLProximityUnknown)
        {
            self.p_cachedProximity = beacon.proximity;
        }
    }
}

- (CLBeaconRegion *)p_beaconRegion
{
    if (!_p_beaconRegion)
    {
        _p_beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BeaconUUID] identifier:@"BeaconIdentifier"];
        _p_beaconRegion.notifyEntryStateOnDisplay = YES;
        _p_beaconRegion.notifyOnExit = YES;
        _p_beaconRegion.notifyOnEntry = YES;
        
        [self.p_locationManager startMonitoringForRegion:self.p_beaconRegion];
    }
    
    return _p_beaconRegion;
}

@end
