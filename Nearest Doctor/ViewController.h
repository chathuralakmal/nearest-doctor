//
//  ViewController.h
//  Nearest Doctor
//
//  Created by Chathura on 6/21/16.
//  Copyright © 2016 Chathura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MKMapView+FXMapRouter.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKMapView.h>
#import "CustomAnnotation.h"
#import "JPSThumbnail.h"
#import "JPSThumbnailAnnotation.h"
#import "CBZSplashView.h"

@interface ViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>{

    NSArray *docLatitude;
    NSArray *docLongitude;
    NSArray *docTitle;
    
    NSMutableArray *docPlaces;


}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;

- (IBAction)MenuView:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *bottomView;

//View Outlets
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuOutlet;

@end

