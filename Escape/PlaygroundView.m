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

    // Drawing code
    UIBezierPath * inverseBezier = [UIBezierPath bezierPathWithRect:self.bounds ];
    [[UIColor whiteColor] setFill];
    [inverseBezier fill];
    for (UIBezierPath * bezier  in self.bezierPathArray) {
        [[UIColor blackColor] setFill];

        [bezier fill];
    }
    


   
    [self setNeedsDisplay];
}


@end
