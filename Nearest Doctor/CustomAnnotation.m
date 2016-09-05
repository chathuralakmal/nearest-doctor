//
//  CustomAnnotation.m
//  Nearest Doctor
//
//  Created by Chathura on 6/21/16.
//  Copyright © 2016 Chathura. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

-(id)initWithTitle:(NSString *)newTitle newSubtitle:(NSString *)newSubtitle Location:(CLLocationCoordinate2D)location identifier:(NSNumber *)identifier{
    self = [super init];
    
    if(self){
        _title = newTitle;
        _coordinate = location;
        _identifier = identifier;
        _subtitle = newSubtitle;
    }
    return self;
}

-(MKAnnotationView *)annotationView{
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"CustomAnnotation"];
    
    annotationView.enabled = YES;
    return annotationView;
}
@end
