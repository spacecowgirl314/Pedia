//
//  ImageScrollView.h
//  Wiki App
//
//  Created by Chloe Stars on 4/24/12.
//  Copyright (c) 2012 hachidorii@icloud.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollView : UIScrollView <UIActionSheetDelegate> {
    IBOutlet UIImageView *tileContainerView;
    CGPoint originalImagePos;
    BOOL touchesMoved;
    CGPoint currentPoint;
    BOOL isDownloaded;
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer;

@end
