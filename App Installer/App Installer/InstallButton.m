//
//  InstallButton.m
//  App Installer
//
//  Created by AppleBetas on 2017-06-27.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "InstallButton.h"

@implementation InstallButton

-(void)didMoveToWindow {
    [super didMoveToWindow];
    self.layer.masksToBounds = YES;
    [self doCircleRadius];
    [self setColours];
    self.contentEdgeInsets = UIEdgeInsetsMake(12, 22, 12, 22);
}

-(void)setHighlighted:(BOOL)highlighted {
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = highlighted ? 0.8 : 1;
        self.transform = highlighted ? CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95) : CGAffineTransformIdentity;
    }];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self doCircleRadius];
}

-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = enabled ? 1 : 0.5;
    }];
}

-(void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self setColours];
}

-(void)setColours {
    self.backgroundColor = self.tintColor;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void)doCircleRadius {
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 2;
}

@end
