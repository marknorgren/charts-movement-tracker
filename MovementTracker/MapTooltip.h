//
//  MapTooltip.h
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

#import <UIKit/UIKit.h>
#import <ShinobiCharts/ShinobiChart.h>
#import <MapKit/MapKit.h>
#import "MovementTrackerDataSource.h"

@interface MapTooltip : SChartCrosshairTooltip<MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MovementTrackerDataSource* datasource;

-(id)initWithDatasource:(MovementTrackerDataSource*)ds locationManager:(CLLocationManager*)lm;
// Draws the given locations on the map
-(void)addLocations:(NSArray *)locations;

@end
