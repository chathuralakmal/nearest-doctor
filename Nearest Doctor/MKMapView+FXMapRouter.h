//
//  MKMapView+FXMapRouter.h
//  This category class developed by Prasad De Zoysa
//  for efficient map routing features
//
//  Things to notice
//  Replace the Google api key before use
//
//
//  Created by Prasad De Zoysa on 7/24/15.
//  Copyright (c) 2015 Fexcon. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol FXRoutingDelegate <NSObject>

-(void)routingFinished;
-(void)routingFaild;

@end

@interface MKMapView (FXMapRouter)


-(void)drawRouteTo:(CLLocation*)toLoc from:(CLLocation*)from;
-(void)setRoutingDelegate:(id<FXRoutingDelegate>)_routingDelegate;
-(void)centerAnnotation:(CLLocationCoordinate2D)coordinate andSelctAnnotation:(id<MKAnnotation>)annotation;

@end
