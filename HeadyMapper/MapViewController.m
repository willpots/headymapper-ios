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

@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic, retain) RMMapView *mapView;
@end

@implementation MapViewController
@synthesize mapView, points;

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RMConfiguration sharedInstance] setAccessToken:@"sk.eyJ1Ijoid2lsbHBvdHMiLCJhIjoiOXNUWFFPVSJ9.lS1DtIrA2hKDnkyUGQ-7xg"];
    
    RMMapboxSource *interactiveSource = [[RMMapboxSource alloc] initWithMapID:@"mapbox.light"];
    
    mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:interactiveSource];
    
    mapView.delegate = self;
    
    mapView.zoom = 9;
    mapView.centerCoordinate = CLLocationCoordinate2DMake(44.28158729232232, -72.87643432617186);
    
    [self.view addSubview:mapView];
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"shape" ofType:@"geojson"];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:jsonPath]
                                                        options:0
                                                        error:nil];
    
    points = [[[[json objectForKey:@"features"] objectAtIndex:0] valueForKeyPath:@"geometry.coordinates"] mutableCopy];
    
    for (NSUInteger i = 0; i < [points count]; i++)
    [points replaceObjectAtIndex:i
                           withObject:[[CLLocation alloc] initWithLatitude:[[[self.points objectAtIndex:i] objectAtIndex:1] doubleValue]
                                                                 longitude:[[[self.points objectAtIndex:i] objectAtIndex:0] doubleValue]]];
    
    RMAnnotation *annotation = [[RMAnnotation alloc] initWithMapView:mapView
                                                          coordinate:mapView.centerCoordinate
                                                            andTitle:@"My Path"];
    
    [mapView addAnnotation:annotation];
    [annotation setBoundingBoxFromLocations:self.points];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
    return nil;
    
    RMShape *shape = [[RMShape alloc] initWithView:mapView];
    
    shape.lineColor = [UIColor purpleColor];
    shape.lineWidth = 5.0;
    
    for (CLLocation *point in self.points)
    [shape addLineToCoordinate:point.coordinate];
    
    return shape;
}


@end
