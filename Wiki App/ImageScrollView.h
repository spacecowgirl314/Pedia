//
//  ImageScrollView.h
//  Wiki App
//
//  Created by Chloe Stars on 4/24/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageScrollViewDelegate <NSObject>
@required
- (BOOL)isFinishedDownloading;
@end

@interface ImageScrollView : UIScrollView <UIActionSheetDelegate> {
    id <ImageScrollViewDelegate> imageScrollViewDelegate;
    IBOutlet UIImageView *tileContainerView;
    UIWebView *vectorView;
    CGPoint originalImagePos;
    BOOL touchesMoved;
    CGPoint currentPoint;
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)setVectorView:(UIWebView*)_vectorView;

@property id imageScrollViewDelegate;

@end
