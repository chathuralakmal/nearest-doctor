//
//  MKMapView+FXMapRouter.m
//  YouTurn
//
//  Created by Prasad De Zoysa on 7/24/15.
//  Copyright (c) 2015 Fexcon. All rights reserved.
//

#import "MKMapView+FXMapRouter.h"

NSArray *arrRoutePoints;
MKPolyline *objPolyline;
id<FXRoutingDelegate> routingDelegate;

@implementation MKMapView (FXMapRouter)


#pragma mark - Routing
#pragma mark -

-(void)drawRouteTo:(CLLocation*)toLoc from:(CLLocation*)from{
    
    arrRoutePoints = [self getRoutePointFrom:from to:toLoc];
    
    if ([arrRoutePoints count] > 0) {
      
        [self drawRoute];
        arrRoutePoints = [[NSArray alloc] initWithObjects:toLoc, from, nil];
        [self centerMap];
    }else{
        
        if (routingDelegate) {
            [routingDelegate routingFaild];
        }
        
        //Focus all the annotations available
        [self zoomToFitMapAnnotations:self];
        
        //No routes available, notify user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Over the sea routes are not available." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (NSArray*)getRoutePointFrom:(CLLocation *)origin to:(CLLocation *)destination{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
    
    NSMutableString *apiUrlStr = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false&mode=%@&departure_time=%.0f", saddr, daddr, @"car", [[NSDate date] timeIntervalSince1970]];
    
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError *error;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
    NSData *data = [apiResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *routes = [json objectForKey:@"routes"];
    NSString *encodedPoints = nil;
    
    if (routes && [routes count] > 0) {
        
        if (routingDelegate) {
            [routingDelegate routingFaild];
        }
        
        encodedPoints = [[[[json objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"overview_polyline"] objectForKey:@"points"];
        
    }
    
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

- (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedString{
    [encodedString replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, [encodedString length])];
    NSInteger len = [encodedString length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        printf("\n[%f,", [latitude doubleValue]);
        printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    
    return array;
}

- (void)drawRoute{
    
    [self removeOverlays:self.overlays];
    
    long numPoints = [arrRoutePoints count];
    
    if (numPoints > 1)
    {
      
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [arrRoutePoints objectAtIndex:i];
            coords[i] = current.coordinate;
        }
        
        objPolyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
        
        [self addOverlay:objPolyline];
        [self setNeedsDisplay];
   
    }
}

#pragma mark - Zooming and center
#pragma mark -

- (void)centerMap{
    
    NSMutableArray *allPoints = [[NSMutableArray alloc] initWithArray:arrRoutePoints];
    
    long numPoints = [allPoints count];
    if (numPoints == 0) return;
    
    MKCoordinateRegion region;
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for(int idx = 0; idx < allPoints.count; idx++)
    {
        CLLocation* currentLocation = [allPoints objectAtIndex:idx];
        
        if(!CLLocationCoordinate2DIsValid(currentLocation.coordinate)) return;
        
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    
    region.center.latitude     = ((maxLat + minLat) / 2);
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = (maxLat - minLat) + 0.1;
    region.span.longitudeDelta = (maxLon - minLon) + 0.1;
    
    [self setRegion:region animated:YES];
    
    
    
    if (routingDelegate) {
       [routingDelegate routingFinished];
    }
}

- (void)zoomToFitMapAnnotations:(MKMapView *)mapView {
    if ([mapView.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    // Add a little extra space on the sides
  
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
    
    [self selectAnnotation:mapView.userLocation animated:YES];
}

-(void)centerAnnotation:(CLLocationCoordinate2D)coordinate andSelctAnnotation:(id<MKAnnotation>)annotation{
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    region.span = span;
    region.center = coordinate;
    
    [self setRegion:region animated:TRUE];
    [self regionThatFits:region];
    
    [self selectAnnotation:annotation animated:YES];
}

#pragma mark - Routing delegate
#pragma mark -

-(void)setRoutingDelegate:(id<FXRoutingDelegate>)_routingDelegate{
    routingDelegate = _routingDelegate;
}


@end
