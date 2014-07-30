//
//  EscapeViewController.m
//  Escape
//
//  Created by Kevin on 12/06/2014.
//  Copyright (c) 2014 ___kevinPitolin___. All rights reserved.
//
#import <CoreMotion/CoreMotion.h>
#import "EscapeViewController.h"
#import "PlaygroundView.h"
@interface EscapeViewController ()
@property (nonatomic, strong)UIView * ball;
@property (nonatomic , strong) PlaygroundView * playground;

// The following is strong because anything don't have
@property (nonatomic, strong) UIDynamicAnimator* animator;

//These are weak because the animator have strong pointers to them
@property (nonatomic, weak) UICollisionBehavior * collider;
@property (nonatomic, weak) UIGravityBehavior * gravity;
@property (nonatomic, weak) UIDynamicItemBehavior * elastic;
@property (nonatomic, weak) UIDynamicItemBehavior * rotation;
@property (nonatomic, strong) CMMotionManager * motionManager;
@property (nonatomic, weak) UIDynamicItemBehavior * quicksand; // slow down the business man XD
@property (nonatomic, weak) UIAttachmentBehavior * attachment;


@end

@implementation EscapeViewController



- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self resumeGame];
}
-(void) viewDidLoad
{
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * note){
                                                      [self pauseGame];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * note){
                                                      [self resumeGame];
                                                  }];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self viewWillDisappear:animated];
    [self resumeGame];
}

-(BOOL) isPaused
{
    return !self.motionManager.isAccelerometerActive;
}
-(void)tap{
    if ([self isPaused]) {
        [self resumeGame];
        UILabel*  pauseLabel = [[UILabel alloc ] init];
        pauseLabel.text = @"Paused";
        pauseLabel.textColor = [UIColor lightGrayColor];
        [self.view addSubview:pauseLabel] ;
    } else{
        [self pauseGame];
    }
}





#define SQUARE_SIZE 40
static CGSize SQUARE_DIMENSIONS  = {SQUARE_SIZE,SQUARE_SIZE};

-(UIView *)addBlockOffsetFromCenterBy: (UIOffset )offset withX:(CGFloat)width andY:(CGFloat)height
{
    // Designing the red block
    
    CGPoint ballCenter = CGPointMake(CGRectGetMidX(self.view.bounds) + offset.horizontal, CGRectGetMidY(self.view.bounds) + offset.vertical);
    CGRect ball = CGRectMake(ballCenter.x-width/2, ballCenter.y-height/2, width, height);

    UIView * ballView = [[UIView alloc] initWithFrame:ball];

    // Put the red Block on screen
    
    
    return ballView;
}

-(void) pauseGame
{
    [self.motionManager stopAccelerometerUpdates ];
    self.gravity.gravityDirection = CGVectorMake(0, 0);  // at start we have no gravity going on
    self.quicksand.resistance = 10.0;

    
}
#define WALL_WIDTH 500
#define WALL_HEIGHT 40
-(PlaygroundView *) createPlayGround
{
    

    PlaygroundView* walls = [[PlaygroundView alloc ]initWithFrame:self.view.bounds ];
    
    UIBezierPath * path1 = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0,self.view.bounds.size.height/4, self.view.bounds.size.width/3, self.view.bounds.size.height*3/4)];
    UIBezierPath * path2 = [UIBezierPath bezierPathWithRect:CGRectMake(self.view.bounds.size.width*2/3, 0.0, self.view.bounds.size.width/3, self.view.bounds.size.height*3/4)];
    walls.bezierPathArray = @[path1,path2];
    NSArray * matrice =  @[
                                             @[ @1, @1, @1, @1],
                                             @[ @0, @0, @0, @1],
                                             @[ @1, @1, @0, @1],
                                             @[ @1, @1, @0, @1],
                                             ];
    
    [self.view  addSubview: walls];

    return walls;
    
}

-(void) resumeGame
{
    self.quicksand.resistance = 0;
    
    if (! self.ball && !self.playground )
    {
        // Setting the ball  frame and color
        self.ball = [self addBlockOffsetFromCenterBy:UIOffsetMake(0, 0) withX:SQUARE_DIMENSIONS.width andY:SQUARE_DIMENSIONS.height];
        self.ball.layer.cornerRadius = SQUARE_SIZE/2;

        self.ball.backgroundColor = [UIColor blueColor];
        
        self.playground = [self createPlayGround];
        int i = 0;
        for ( UIBezierPath * bezierPath in self.playground.bezierPathArray) {
            [self.collider addBoundaryWithIdentifier:[ NSString stringWithFormat: @"wall%d",i] forPath:bezierPath];
            i++;

        }
        [self.playground addSubview:self.ball];

        [self.collider addItem:self.ball];
        [self.elastic addItem:self.ball];
        [self.gravity addItem:self.ball];
        [self.quicksand addItem:self.ball];

        
    }
    
    self.gravity.gravityDirection = CGVectorMake(0, 0);  // at start we have no gravity going on
    if ([self.motionManager isAccelerometerAvailable]) {
        if(!self.motionManager.isAccelerometerActive){
            
            [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                CGFloat x = accelerometerData.acceleration.x;
                CGFloat y = accelerometerData.acceleration.y;
                
                switch (self.interfaceOrientation) {
                    case UIInterfaceOrientationLandscapeRight:
                        self.gravity.gravityDirection = CGVectorMake(-y, -x);
                        
                        break;
                    case UIInterfaceOrientationLandscapeLeft:
                        self.gravity.gravityDirection = CGVectorMake(y, x);
                        
                        break;
                    case UIInterfaceOrientationPortrait:
                        self.gravity.gravityDirection = CGVectorMake(x, -y);
                        
                        break;
                        
                    case UIInterfaceOrientationPortraitUpsideDown:
                        self.gravity.gravityDirection = CGVectorMake(-x, y);
                        
                        break;
                        
                }
                
            }];
        }
    }else
    {
        [self alert:@"Your device doesn't have accelerometer"];
    }
    
}


-(void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Erreur"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil
      , nil] show];
}
#pragma  mark - Animation
- (UIDynamicAnimator *)animator
{
    if (!_animator){
        UIDynamicAnimator * animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view ];
        self.animator = animator;
    }
    
    return  _animator;
}

#define UPDATES_PER_SECOND 100
-(CMMotionManager *) motionManager
{
    if (!_motionManager)
    {
        CMMotionManager * motionManager = [[CMMotionManager alloc] init];
        motionManager.accelerometerUpdateInterval = 1/UPDATES_PER_SECOND;
        _motionManager = motionManager;
    }
    return _motionManager;
}


// We'll need to custom that (with the real gravity with Core Motion)
-(UIGravityBehavior *)gravity{
    if (!_gravity) {
        UIGravityBehavior * gravity = [[UIGravityBehavior alloc] init];
        [self.animator addBehavior:gravity];
        self.gravity = gravity;
    }
    return _gravity;
    
    
}

// We'll need to custom that (with the real gravity with Core Motion)


- (UICollisionBehavior *)collider{
    if (!_collider)
    {
        UICollisionBehavior * collider = [[UICollisionBehavior alloc ]  init];
        collider.translatesReferenceBoundsIntoBoundary = YES;
        [self.animator addBehavior:collider];
        self.collider = collider ;
    }
    return _collider;
}

- (UIDynamicItemBehavior *) elastic
{
    if (!_elastic)
    {
        UIDynamicItemBehavior * elastic  = [[UIDynamicItemBehavior alloc] init];
        elastic.elasticity = 1.0;
        [self.animator addBehavior:elastic];
        self.elastic  = elastic;
    }
    return _elastic;
}


- (UIDynamicItemBehavior *) rotation
{
    if (!_rotation)
    {
        UIDynamicItemBehavior * rotation  = [[UIDynamicItemBehavior alloc] init];
        rotation.allowsRotation = NO;
        [self.animator addBehavior:rotation];
        self.rotation  = rotation;
    }
    return _rotation;
}
-(UIDynamicItemBehavior *) quicksand {
    if (!_quicksand) {
        UIDynamicItemBehavior * quicksand = [[UIDynamicItemBehavior alloc] init];
        quicksand.resistance = 0;
        [self.animator addBehavior:quicksand];
        self.quicksand = quicksand;
    }
    
    return _quicksand ;
}


@end
