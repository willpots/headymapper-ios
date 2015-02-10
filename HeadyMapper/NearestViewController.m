//
//  SecondViewController.m
//  HeadyMapper
//
//  Created by Will Potter on 2/9/15.
//  Copyright (c) 2015 Will Potter. All rights reserved.
//

#import "NearestViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface NearestViewController ()

//View Stuff
@property (nonatomic, retain) IBOutlet UITextView *loadingTextView;
@property (nonatomic, retain) IBOutlet UITextView *nameTextView;

//Non-View Stuff
@property (nonatomic, retain) CLLocationManager *locManager;
@property (nonatomic, retain) CLLocation *myLocation;
@property (nonatomic, retain) NSDictionary *locations;
@property (nonatomic, retain) NSDictionary *nearestLocation;
@property (nonatomic) double nearestDistance;



@end

@implementation NearestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _locManager = [[CLLocationManager alloc] init];
    _locManager.delegate = self;
    [_locManager requestWhenInUseAuthorization];
    [_locManager startUpdatingLocation];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"locations" ofType:@"geojson"];
    NSData *style = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    _locations = [NSJSONSerialization
                 JSONObjectWithData:style
                 options:0
                 error:&error];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (double)distanceOf:(CLLocation *)firstLoc from:(CLLocation *)secondLoc {
    return [firstLoc distanceFromLocation:secondLoc] * 0.000621371;
}

- (int)today {
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *weekdayComponents =[gregorian components:NSCalendarUnitWeekday fromDate:today];
    return (int)[weekdayComponents weekday];
}

- (int)numberFromWeekday:(NSString*)weekday {
    if([weekday isEqualToString:@"sunday"]) {
        return 1;
    } else  if([weekday isEqualToString:@"monday"]) {
        return 2;
    } else if([weekday isEqualToString:@"tuesday"]) {
        return 3;
    } else if([weekday isEqualToString:@"wednesday"]) {
        return 4;
    } else if([weekday isEqualToString:@"thursday"]) {
        return 5;
    } else if([weekday isEqualToString:@"friday"]) {
        return 6;
    } else if([weekday isEqualToString:@"saturday"]) {
        return 7;
    } else {
        return -1;
    }
}

- (void)findNearestLocation {
    NSArray *features = [_locations valueForKey:@"features"];
    _nearestDistance = INFINITY;
    _nearestLocation = nil;
    for (NSDictionary *object in features) {
        NSArray *coordinates = object[@"geometry"][@"coordinates"];
        NSString *type = object[@"properties"][@"type"];
        NSNumber *heady = object[@"properties"][@"heady"];
        NSString *weekday = object[@"properties"][@"headyDay"];
        int day = [self numberFromWeekday: weekday];
        int today = [self today];
        NSNumber *lat = coordinates[1];
        NSNumber *lon = coordinates[0];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
        if([self distanceOf:_myLocation from:location] < _nearestDistance
            && [type isEqualToString:@"store"]
            && [heady isEqualToNumber:@1]
            && day == today) {
            _nearestDistance = [self distanceOf:_myLocation from:location];
            _nearestLocation = object;
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    _loadingTextView.text = @"Couldn't find location!";
}

- (NSString*)toString {
    NSString *output = @"";
    output = [output stringByAppendingString:[[_nearestLocation objectForKey:@"properties"] objectForKey:@"name"]];
    output = [output stringByAppendingString:@"\n"];
    output = [output stringByAppendingString:[[_nearestLocation objectForKey:@"properties"] objectForKey:@"address"]];
    return output;
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    _myLocation = newLocation;
    [self findNearestLocation];
    [_locManager stopUpdatingLocation];
    
    _loadingTextView.text = @"The nearest Heady Topper is delivered to:";
    _nameTextView.text = [self toString];
    
}



@end
