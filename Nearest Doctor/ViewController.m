//
//  ViewController.m
//  Nearest Doctor
//
//  Created by Chathura on 6/21/16.
//  Copyright © 2016 Chathura. All rights reserved.
//

#import "ViewController.h"
#define METERS_PER_MILE 1609.344

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setHidden:TRUE];
    
    UIImage *icon = [UIImage imageNamed:@"medical.png"];
    UIColor *color = [UIColor colorWithRed:36.0/255.0f green:145.0/255.0f blue:232.0/255.0f alpha:1.0];
    CBZSplashView *splashView = [CBZSplashView splashViewWithIcon:icon backgroundColor:color];
    
    // customize duration, icon size, or icon color here;
    
    [self.view addSubview:splashView];
    [splashView startAnimationWithCompletionHandler:^{
         [self.navigationController.navigationBar setHidden:FALSE];
    }];
    
//    [self downloadLoadsOfAmazingContentWithCompletion:^(BOOL success, NSError *error) {
//        [splashView startAnimation];
//    }];
    
    NSDictionary *docPlaces1 = @{@"identifier":@"1",@"latitude":@"6.856987",@"longitude":@"79.909510",@"title":@"High Level Road Medicare",@"subtitle":@"Dr. Sujatha Aththanayaka (MBBS Colombo)"};
    
    NSDictionary *docPlaces2 = @{@"identifier":@"2",@"latitude":@"6.856744",@"longitude":@"79.907525",@"title":@"Soratha Mawatha Medicare",@"subtitle":@"Dr. Thinila Kurukularachchi (MBBS, Kelaniya)"};
    
    docPlaces = [NSMutableArray arrayWithObjects:
                            docPlaces1, docPlaces2, nil];
    
     _mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
  
    
    //  Start updating location changes.
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;

    
    for ( int i=0; i<[docPlaces count]; i++)
    {
        NSDictionary *temp = [docPlaces objectAtIndex:i];
        CLLocationCoordinate2D coord;
        
        coord.latitude=[[NSString stringWithFormat:@"%@",[temp objectForKey:@"latitude"]] floatValue];
        coord.longitude=[[NSString stringWithFormat:@"%@",
                          [temp objectForKey:@"longitude"]] floatValue];

        JPSThumbnail *thumbnail = [[JPSThumbnail alloc] init];
        thumbnail.image = [UIImage imageNamed:@"empire.jpg"];
        thumbnail.title = [temp objectForKey:@"title"];
        thumbnail.subtitle = [temp objectForKey:@"subtitle"];
        thumbnail.coordinate = coord;
        thumbnail.disclosureBlock = ^{
            
            self.nameLabel.text = [temp objectForKey:@"title"];
            self.descriptionLabel.text = [temp objectForKey:@"subtitle"];
            
            CATransition *animation = [CATransition animation];
            animation.type = kCATransitionFade;
            animation.duration = 0.4;
            [_bottomView.layer addAnimation:animation forKey:nil];
            
            [self.bottomView setHidden:FALSE];

            NSLog(@"selected %@",[temp objectForKey:@"identifier"]); };
        
        [_mapView addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:thumbnail]];

  
    }

    [self.bottomView setHidden:TRUE];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = newLocation.coordinate.latitude;
    zoomLocation.longitude= newLocation.coordinate.longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
      [_mapView setRegion:viewRegion animated:YES];
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
    
//    CustomAnnotation *annotation = view.annotation;
//  
//    if(![annotation isKindOfClass:[MKUserLocation class]])
//    {
//        NSLog(@"Identifier %@",annotation.identifier);
//        for ( int i=0; i<[docPlaces count]; i++)
//        {
//            NSDictionary *temp = [docPlaces objectAtIndex:i];
//            
//            if([[temp objectForKey:@"identifier"]isEqual:annotation.identifier]){
//                /*
//                MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
//                MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placemark];
//                [destination setName:annotation.title];
//                NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
//                [destination openInMapsWithLaunchOptions:options];*/
//                
//              /*  NSURL *appUrl;
//                
//                //Is Google Maps App Installed ?
//                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
//                    
//                    // Use Google Maps App to get Directions
//                    appUrl = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&views=traffic",
//                                                   [[temp objectForKey:@"latitude"] doubleValue], [[temp objectForKey:@"longitude"] doubleValue]]];
//                }else{
//                
//                    // Use Safari Browser GoogleMaps to get Directions
//                    NSLog(@"Please Install Google Maps");
//                    [[UIApplication sharedApplication] openURL:
//                     [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.google.com/maps?daddr=%f,%f&views=traffic", [[temp objectForKey:@"latitude"] doubleValue], [[temp objectForKey:@"longitude"] doubleValue]]]];
//                    
//                }
//                
//                [[UIApplication sharedApplication] openURL:appUrl];
//               */
//                
//            }
//        }
//        
//        self.bottomViewHeight.constant = 128;
//        self.mapViewBottom.constant = 0;
//       
//    }

}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
        
       
       
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.4;
        [_bottomView.layer addAnimation:animation forKey:nil];
        _bottomView.hidden = YES;

    }

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}

- (IBAction)MenuView:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    
    NSString *userId;
    
    userId = @"test";
    
    if(userId){
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Add New Place" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"My Places" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
    }]];
        
    }else{
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Add New Place" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
    }]];
        
    
    }
   
    UIPopoverPresentationController *popPresenter = [actionSheet popoverPresentationController];
    popPresenter.barButtonItem = sender;
    popPresenter.permittedArrowDirections = UIPopoverArrowDirectionUp;
    
   
        // The device is an iPhone or iPod touch.
           [self presentViewController:actionSheet animated:YES completion:nil];
    
    
    
    
}
@end
