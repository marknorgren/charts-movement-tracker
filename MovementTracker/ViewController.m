//
//  ViewController.m
//  MovementTracker
//
//  Created by Alison Clarke on 16/07/2013.
//  
//  Copyright 2013 Scott Logic
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <ShinobiCharts/SChartCanvas.h>
#import "SChartCanvasOverlay+ReorderSubviews.h"
#import "ViewController.h"
#import "MovementTrackerDatum.h"
#import "MovementTrackerDataSource.h"
#import "MapCrosshair.h"
#import "MapTooltip.h"

@interface ViewController () {
    CLLocationManager *_locationManager;
    MovementTrackerDataSource *_datasource;
    CLLocation* _lastLocation;
    double _totalDistance;
    ShinobiChart* _chart;
    MapTooltip* _mapTooltip;
    MapCrosshair* _mapCrosshair;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Set up the location manager
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _locationManager.distanceFilter = 5;
    [_locationManager startUpdatingLocation];
    
    // Create a data source
    _datasource = [[MovementTrackerDataSource alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupChart {
    // Initialize chart and do basic setup
    _chart = [[ShinobiChart alloc] initWithFrame:CGRectMake(60, 80, self.view.bounds.size.width - 120, self.view.bounds.size.height - 90)];
    _chart.datasource = _datasource;
    _chart.delegate = self;
    _chart.legend.hidden = NO;
    _chart.legend.position = SChartLegendPositionBottomMiddle;
    _chart.title = @"Movement Tracker";
    
    // Turn off clipsToBounds so that out tooltip can go outside of the chart area
    [_chart setClipsToBounds:NO];
    
    // Add x-axis
    SChartDateTimeAxis *dateAxis = [[SChartDateTimeAxis alloc] init];
    dateAxis.title = @"Time";
    _chart.xAxis = dateAxis;
    
    // Add first y-axis (speed)
    SChartNumberAxis *speedAxis = [[SChartNumberAxis alloc] init];
    speedAxis.title = @"Speed (mph)";
    _chart.yAxis = speedAxis;
    
    // Add second y-axis (distance)
    SChartNumberAxis *distanceAxis = [[SChartNumberAxis alloc] init];
    distanceAxis.title = @"Distance (miles)";
    distanceAxis.axisPosition = SChartAxisPositionReverse;
    distanceAxis.axisLabelsAreFixed = YES;
    [_chart addYAxis: distanceAxis];
    
    // Set up custom tooltip and crosshair style
    _mapTooltip = [[MapTooltip alloc] initWithDatasource:_datasource locationManager:_locationManager];
    _mapCrosshair = [[MapCrosshair alloc] initWithChart:_chart];
    _mapCrosshair.interpolatePoints = YES;
    _chart.crosshair = _mapCrosshair;
    _chart.crosshair.tooltip = _mapTooltip;
    _chart.crosshair.style.lineWidth = [NSNumber numberWithInt:2];
    _chart.crosshair.style.lineColor = [UIColor blackColor];
    
    // Add the chart to our view
    [self.view addSubview:_chart];
    
    // Tell the datasource about the chart now it's set up
    _datasource.chart = _chart;
    NSLog(@"%@", [_chart getInfo]);
}

#pragma mark - CLLocationManagerDelegate implementation methods

// Delegate method from the CLLocationManagerDelegate protocol
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    // Add the location to our datasource
    [_datasource addLocation:location lastLocation:_lastLocation];
    
    if (_chart == NULL) {
        // Set up the chart now we've got a data point
        [self setupChart];
    } else {
        // Pass the new locations, plus the last location, to our custom tooltip, so it can plot the path on its map
        NSMutableArray *allLocations = [NSMutableArray arrayWithArray:locations];
        [allLocations insertObject:_lastLocation atIndex:0];
        [_mapTooltip addLocations:allLocations];
    }
    
    // Update the last location
    _lastLocation = location;
}

#pragma mark - SChartDelegate methods

-(void)sChartRenderFinished:(ShinobiChart *)chart
{
    // Reorder the subviews on our canvas overlay
    [chart.canvas.overlay reorderSubviews];
    // Update the crosshair
    [_mapCrosshair updateCrosshair];
}

-(void)sChart:(ShinobiChart *)chart crosshairMovedToXValue:(id)x andYValue:(id)y
{
    // Reorder the subviews on our canvas overlay
    [chart.canvas.overlay reorderSubviews];
}

@end
