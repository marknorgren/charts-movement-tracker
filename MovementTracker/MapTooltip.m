//
//  MapTooltip.m
//  MovementTracker
//
//  Created by Alison Clarke on 19/08/2013.
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

#import "MapTooltip.h"
#import <ShinobiCharts/SChartCanvas.h>

@interface MapTooltip () {
    MKPointAnnotation *_annotation;
    MKCoordinateRegion _region;
    MKMapView *_mapView;
    MKPolyline* _polyline;
}

@end

@implementation MapTooltip

-(id)initWithDatasource:(MovementTrackerDataSource*)ds locationManager:(CLLocationManager*)lm {
    
    self = [super init];
    if (self) {
        self.locationManager = lm;
        self.datasource = ds;
        
        // Set up our 200x200 frame, with a 2px black border
        CGRect frame = CGRectZero;
        frame.origin.x = 0.f;
        frame.size.height = 200.f;
        frame.size.width = 200.f;
        self.frame = frame;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 2.0f;        
        
        [self setupMap];
    }
    
    return self;
}

-(void)setupMap {
    // Create and set up an MKMapView, using ourselves as its delegate
    _mapView = [[MKMapView alloc] initWithFrame:self.frame];
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    _mapView.scrollEnabled = NO;
    _mapView.zoomEnabled = NO;
    
    // Create a region, which we'll reuse to keep the zoom constant
    _region = MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, 250, 250);
    [_mapView setRegion:_region animated:YES];
    
    // Prevent the map from scrolling with the user - we'll control its center ourselves
    [_mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
    
    // Remove the original tooltip label and replace it with our map
    [self.label removeFromSuperview];
    [self addSubview: _mapView];
}

-(void)addLocations:(NSArray *)locations {
    // Add the given locations to our annotation line
    int numPoints = [locations count];
    if (numPoints > 1)
    {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [locations objectAtIndex:(i)];
            coords[i] = current.coordinate;
        }
    
        _polyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
    
        [_mapView addOverlay:_polyline];
        [_mapView setNeedsDisplay];
    }
}

#pragma mark - MKMapViewDelegate methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.fillColor = [UIColor redColor];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 3;
    return renderer;
}

#pragma mark - SChartTooltip overrides

- (void)setPosition:(SChartPoint)pos onCanvas:(SChartCanvas*)canvas {
    [self layoutContents];
    
    // Position the tooltip on the canvas, with the given position as its center
    CGRect tempFrame = _mapView.frame;
    tempFrame.origin.x = pos.x - tempFrame.size.width/2.f;
    tempFrame.origin.y = pos.y - tempFrame.size.height/2.f;
    self.frame = tempFrame;
}

- (void)setDataPoint:(id<SChartData>)dataPoint fromSeries:(SChartSeries *)series fromChart:(ShinobiChart *)chart {
    // Find relevant data point from data source;
    CLLocation* location = [_datasource getMovementTrackerDatumAtIndex:dataPoint.sChartDataPointIndex].location;
    
    if (location != NULL) {
        // Remove the old annotation
        [_mapView removeAnnotation:_annotation];
        
        // Place a single pin in the map
        if (_annotation == NULL) {
            _annotation = [[MKPointAnnotation alloc] init];
        }
        [_annotation setCoordinate:location.coordinate];
        
        NSString *unit;
        SChartAxis *yAxis;
        if ([series.title isEqualToString:@"Distance"]) {
            unit = @"miles";
            yAxis = chart.secondaryYAxes[0];
        } else {
            unit = @"mph";
            yAxis = chart.yAxis;
        }
        [_annotation setTitle:[NSString stringWithFormat:@"%@: %@ %@", [series title], [yAxis stringForId: [dataPoint sChartYValue]], unit]];
        [_annotation setSubtitle:[NSString stringWithFormat:@"Time: %@", [chart.xAxis stringForId: [dataPoint sChartXValue]]]];
        [_mapView addAnnotation:_annotation];
        [_mapView selectAnnotation:_annotation animated:NO];
        
        // Center map on that location
        _region.center = location.coordinate;
        [_mapView setRegion:_region animated:NO];
    }
}

@end
