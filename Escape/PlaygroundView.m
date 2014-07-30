//
//  PlaygroundView.m
//  Escape
//
//  Created by KEVIN on 30/07/2014.
//  Copyright (c) 2014 ___kevinPitolin___. All rights reserved.
//

#import "PlaygroundView.h"

@implementation PlaygroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setBezierPath:(NSArray *)bezierPathArray
{
    _bezierPathArray = bezierPathArray;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor whiteColor];

    // Drawing code
    [[UIColor blackColor] setFill];

    for (UIBezierPath * bezier  in self.bezierPathArray) {
        [[UIColor whiteColor] setFill];

        [bezier fill];
    }
   
    [self setNeedsDisplay];
}


@end
