//
//  ImageScrollView.m
//  Wiki App
//
//  Created by Chloe Stars on 4/24/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import "ImageScrollView.h"
#import <QuartzCore/CALayer.h>

@implementation ImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    //////////////////////////////
    // Listen for Double Tap Zoom
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    
    [self addGestureRecognizer:doubleTap];
    
    // add shadow to the image
    tileContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    tileContainerView.layer.shadowOffset = CGSizeMake(0, 0);
    tileContainerView.layer.shadowOpacity = 1;
    tileContainerView.layer.shadowRadius = 1.0;
}

// Double tap to Zoom!
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if(self.zoomScale > self.minimumZoomScale)
        [self setZoomScale:self.minimumZoomScale animated:YES]; 
    else 
        [self setZoomScale:self.maximumZoomScale animated:YES]; 
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    currentPoint = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint activePoint = [[touches anyObject] locationInView:self];
    // did we make minimal movement? if so then it must be a touch
    if (abs(activePoint.x - currentPoint.x) < 10 && abs(activePoint.y - currentPoint.y) < 10) {
        touchesMoved=NO;
    }
    else {
        touchesMoved=YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Only hide if touched and didn't zoom or tap to zoom.
     This only applies to the iPad because the iPhone doesn't use an overlay it uses a separate view*/
    if (touchesMoved==NO && [[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        self.hidden=YES;
        // reset zoom
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
        tileContainerView.transform = transform;
        [self setContentSize:CGSizeZero];
        // post notifcation to remove dimming
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:@"closeImage" 
         object:nil];
    }
    touchesMoved=NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = tileContainerView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    tileContainerView.frame = frameToCenter;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
