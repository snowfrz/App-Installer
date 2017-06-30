//
//  InstallButton.m
//  App Installer
//
//  Created by Justin Proulx on 2017-06-29. Based on work by AppleBetas.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "TwitterButtons.h"

@implementation TwitterButtons

-(void)setHighlighted:(BOOL)highlighted
{
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = highlighted ? 0.8 : 1;
        self.transform = highlighted ? CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95) : CGAffineTransformIdentity;
    }];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self doCircleRadius];
    [self addShadow];
    [self setColours];
}

-(void)setColours
{
    self.backgroundColor = [UIColor whiteColor];
    //[self setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

-(void)doCircleRadius
{
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 3;
}

- (void)addShadow
{
    //give a drop shadow to buttons
    UIBezierPath *ShadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.layer.shadowOpacity = 0.1f;
    self.layer.shadowPath = ShadowPath.CGPath;
}

@end
