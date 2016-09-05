//
//  CustomAnnotation.h
//  Nearest Doctor
//
//  Created by Chathura on 6/21/16.
//  Copyright © 2016 Chathura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface CustomAnnotation : NSObject<MKAnnotation>


@property (nonatomic, readonly)CLLocationCoordinate2D coordinate;
@property (copy, nonatomic)NSString *title;
@property (copy, nonatomic)NSString *subtitle;
@property (copy, nonatomic)NSNumber *identifier;


-(id)initWithTitle:(NSString *)newTitle newSubtitle:(NSString *)newSubtitle Location:(CLLocationCoordinate2D)location identifier:(NSNumber *)identifier;
-(MKAnnotationView *)annotationView;

@end
