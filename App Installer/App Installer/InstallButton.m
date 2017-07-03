//
//  InstallButton.m
//  App Installer
//
//  Created by AppleBetas on 2017-06-27.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "InstallButton.h"

@implementation InstallButton

-(void)didMoveToWindow
{
    [super didMoveToWindow];
    [self setColours];
    self.contentEdgeInsets = UIEdgeInsetsMake(12, 22, 12, 22);
}

-(void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self setColours];
}

-(void)setColours
{
    self.backgroundColor = self.tintColor;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end
