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
    // add the drop shadow
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0.0, 0.25);
    self.layer.shadowOpacity = 0.25;
    self.layer.masksToBounds = NO;
    self.layer.shouldRasterize = YES;
}

- (void)removeDropShadow {
    // remove the shadow
    self.layer.shadowOpacity = 0.0;
}

@end
