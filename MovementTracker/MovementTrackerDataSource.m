//
//  MovementTrackerDataSource.m
//  MovementTracker
//
//  Created by Alison Clarke on 30/07/2013.
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

#import "MovementTrackerDataSource.h"
#import "MovementTrackerDatum.h"

@interface MovementTrackerDataSource () {
    double _totalDistance;
    NSMutableArray* _locationData;
}

@end

@implementation MovementTrackerDataSource

-(id)init {
    if ( self = [super init] ) {
        _locationData = [[NSMutableArray alloc] init];
        _totalDistance = 0;
    }
    return self;
}

// Adds the location to our data
- (void)addLocation:(CLLocation*)location {
    // Create a new MovementTrackerDatum object based on the given location
    MovementTrackerDatum *datum = [[MovementTrackerDatum alloc] init];
    datum.date = location.timestamp;
    datum.location = location;
    if ([_locationData count] > 0)
    {
        // Convert distance (in meters) into miles and add to total
        _totalDistance += [location distanceFromLocation:[self getLastLocation]] * 0.000621371192;
    }
    datum.totalDistance = _totalDistance;
    // Convert speed (in m/s) into mph
    datum.speed = location.speed * 2.23693629;
    
    // Add to the series
    [_locationData addObject:datum];
}

// Gets the data from the given index
- (MovementTrackerDatum*) getMovementTrackerDatumAtIndex:(int) index {
    if (index < [_locationData count]) {
        return _locationData[index];
    } else {
        return NULL;
    }
}

// Get the last location visited
- (CLLocation*) getLastLocation {
    return ((MovementTrackerDatum*)[_locationData lastObject]).location;
}

#pragma mark - SChartDatasource implementation methods

- (int)numberOfSeriesInSChart:(ShinobiChart*)chart
{
    return 2;
}

-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(int)index {
    SChartLineSeries* lineSeries = [[SChartLineSeries alloc] init];
    if (index == 0) {
        lineSeries.title = @"Speed";
    } else {
        lineSeries.title = @"Distance";
    }
    lineSeries.crosshairEnabled = YES;
    lineSeries.style.pointStyle.showPoints = YES;
    return lineSeries;
}

-(int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex {
    return _locationData.count;
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex {
    
    MovementTrackerDatum *datum = [_locationData objectAtIndex:dataIndex];
    
    // Create a new datapoint
    SChartDataPoint* pt = [SChartDataPoint new];
    pt.xValue = datum.date;
    
    if (seriesIndex==0) {
        // First series is speed
        pt.yValue = @(datum.speed);
    } else {
        // Second series is distance
        pt.yValue = @(datum.totalDistance);
    }
    
    return pt;
}

- (SChartAxis *)sChart:(ShinobiChart *)chart yAxisForSeriesAtIndex:(int)index {
    NSArray* axes = chart.allYAxes;
    return axes[index];
}

@end
