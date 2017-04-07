//
//  MapCrosshair.m
//  MovementTracker
//
//  Created by Alison Clarke on 09/09/2013.
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
#import "MapCrosshair.h"
#import "MapTooltip.h"

@interface MapCrosshair() {
    BOOL _isShown;
    BOOL _inRange;
    SChartPoint _lastCoords;
    SChartPoint _lastDataPoint;
    SChartCartesianSeries *_lastSeries;
    id<SChartData> _lastDataSeriesPoint;
}
@end

@implementation MapCrosshair

-(void)showCrosshair
{
    // Keep track of current status before passing to parent
    _isShown = YES;
    [super showCrosshair];
}

-(BOOL)removeCrosshair
{
    // Keep track of current status before passing to parent
    _isShown = NO;
    return [super removeCrosshair];
}

- (void)moveToPosition:(SChartPoint)coords
   andDisplayDataPoint:(SChartPoint)dataPoint
            fromSeries:(SChartCartesianSeries *)series
    andSeriesDataPoint:(id<SChartData>)dataSeriesPoint
{
    // If the crosshair is in range, keep track of current data before passing to the parent
    if (_inRange) {
        _lastCoords = coords;
        _lastDataPoint = dataPoint;
        _lastSeries = series;
        _lastDataSeriesPoint = dataSeriesPoint;
    }
    [super moveToPosition:coords andDisplayDataPoint:dataPoint fromSeries:series andSeriesDataPoint:dataSeriesPoint];
}

-(void)crosshairMovedOutOfRange {
    // Keep track of current status before passing to parent
    _inRange = NO;
    [super crosshairMovedOutOfRange];
}

-(void)crosshairMovedInsideRange {
    // Keep track of current status before passing to parent
    _inRange = YES;
    [super crosshairMovedInsideRange];
}

-(void)updateCrosshair
{
    if (_isShown) {
        // Update the crosshair's position, based on the previous data
        [self crosshairMovedInsideRange];
        [super showCrosshair];
   
        // Find the relevant y-axis for the series
        SChartAxis *yAxis = self.chart.yAxis;
        if ([_lastSeries.title isEqualToString:@"Distance"]) {
            yAxis = self.chart.secondaryYAxes[0];
        }
        
        // Calculate the new pixel positions
        double xCoord = self.chart.canvas.frame.origin.x + [self.chart.xAxis pixelValueForDataValue: @(_lastDataPoint.x)];
        double yCoord = self.chart.canvas.frame.origin.y + [yAxis pixelValueForDataValue: @(_lastDataPoint.y)];
        
        SChartPoint const mappedPosition = {
            xCoord, yCoord
        };
        
        // Call moveToPosition with our new position and the previous data
        [super moveToPosition:mappedPosition andDisplayDataPoint:_lastDataPoint fromSeries:_lastSeries andSeriesDataPoint:_lastDataSeriesPoint];
    }
}

@end
