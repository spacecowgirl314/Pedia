//
//  UINavigationBar+DropShadow.m
//  Pedia
//
//  Created by Chloe Stars on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UINavigationBar+DropShadow.h"

@implementation UINavigationBar (DropShadow)

- (void)applyDropShadow {
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         // add the drop shadow
                         self.layer.shadowColor = [[UIColor blackColor] CGColor];
                         self.layer.shadowOffset = CGSizeMake(0.0, 1);
                         self.layer.shadowOpacity = 0.25;
                         self.layer.masksToBounds = NO;
                         self.layer.shouldRasterize = YES;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)removeDropShadow {
    [UIView animateWithDuration:0.50
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         // add the drop shadow
                         self.layer.shadowOpacity = 0.0;
                     }
                     completion:^(BOOL finished){
                     }];
}

@end
