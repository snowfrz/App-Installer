//
//  ImpressionableButton.m
//  App Installer
//
//  Created by AppleBetas on 2017-07-02.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "ImpressionableButton.h"

@implementation ImpressionableButton

-(void)didMoveToWindow
{
    [super didMoveToWindow];
    [self doCircleRadius];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self doCircleRadius];
}

-(void)setHighlighted:(BOOL)highlighted
{
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = highlighted ? 0.8f : 1.0f;
        self.transform = highlighted ? CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95) : CGAffineTransformIdentity;
    }];
}

-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = enabled ? 1.0f : 0.5f;
    }];
}

-(void)doCircleRadius
{
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 2;
}

@end
