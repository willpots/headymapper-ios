//
//  FirstViewController.m
//  HeadyMapper
//
//  Created by Will Potter on 2/9/15.
//  Copyright (c) 2015 Will Potter. All rights reserved.
//

#import "MapViewController.h"
#import "Mapbox.h"



@interface MapViewController ()

@property (nonatomic, retain) RMMapView *mapView;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UITextView *helpText;

@end

@implementation MapViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RMConfiguration sharedInstance] setAccessToken:@"sk.eyJ1Ijoid2lsbHBvdHMiLCJhIjoiOXNUWFFPVSJ9.lS1DtIrA2hKDnkyUGQ-7xg"];
    
    RMMapboxSource *mapboxLight = [[RMMapboxSource alloc] initWithMapID:@"mapbox.light"];
    
    _mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:mapboxLight];
    _mapView.delegate = self;
    _mapView.zoom = 6.245945;
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(43.684209, -72.445327);
    
    [_containerView addSubview:_mapView];

    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"locations" ofType:@"geojson"];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:jsonPath]
                                                        options:0
                                                        error:nil];
    for (NSDictionary *point in json[@"features"]) {
        if([point[@"properties"][@"type"] isEqualToString:@"store"]
        && [point[@"properties"][@"heady"] isEqualToNumber:@1]) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[point[@"geometry"][@"coordinates"] objectAtIndex:1] doubleValue], [[point[@"geometry"][@"coordinates"] objectAtIndex:0] doubleValue]);
            RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:_mapView
                                                                            coordinate:coordinate
                                                                              andTitle:point[@"properties"][@"name"]];
            annotation.userInfo = point;
            [_mapView addAnnotation:annotation];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - RMMapViewDelegate

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation{
    if (annotation.isUserLocationAnnotation)
    return nil;
    UIColor *color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    NSString *day = (NSString*)annotation.userInfo[@"properties"][@"headyDay"];
    if([day isEqualToString:@"monday"]) {
        color = [UIColor colorWithRed:0.460 green:0.003 blue:0.505 alpha:1.000];
    } else if([day isEqualToString:@"tuesday"]) {
        color = [UIColor colorWithRed:0.523 green:0.494 blue:0.000 alpha:1.000];
    } else if([day isEqualToString:@"wednesday"]) {
        color = [UIColor colorWithRed:0.002 green:0.447 blue:0.175 alpha:1.000];
    } else if([day isEqualToString:@"thursday"]) {
        color = [UIColor colorWithRed:0.000 green:0.068 blue:0.447 alpha:1.000];
    } else if([day isEqualToString:@"friday"]) {
        color = [UIColor colorWithRed:0.449 green:0.000 blue:0.000 alpha:1.000];        
    }
    RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"shop" tintColor:color];
    
    marker.canShowCallout = YES;
    
    return marker;
}
- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction {
    if(wasUserAction) {
        [_helpText removeFromSuperview];
    }
}
- (void)doubleTapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
    NSLog(@"annotation: %@", annotation.userInfo[@"properties"][@"address"]);
    NSString *urlPart = [@[annotation.userInfo[@"properties"][@"name"], annotation.userInfo[@"properties"][@"address"]] componentsJoinedByString: @", "];
    urlPart = [urlPart stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *url = [NSURL URLWithString:[@"http://maps.apple.com/?q=" stringByAppendingString:urlPart]];
    [[UIApplication sharedApplication] openURL:url];

}
@end
