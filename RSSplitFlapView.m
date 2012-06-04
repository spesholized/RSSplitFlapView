//
//  SplitFlapView.m
//  TVCompanion
//
//  Created by rollin.su on 11-10-18.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSSplitFlapView.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDuration 5.f
#define kDefaultPerspectivalDistance 500.f

@interface RSSplitFlapView()
+(CAAnimation *)flipAnimationWithDuration:(NSTimeInterval)aDuration angle:(CGFloat)angleRadian;
+(CATransition *)fadeTransitionWithDuration:(NSTimeInterval)aDuration;
-(void)initProperties;
-(void)initLayers;
-(void)splitView:(UIView*)aView intoTopHalf:(UIImage**)topImage bottomHalf:(UIImage**)bottomImage;

@property (nonatomic, retain) CAAnimation* frontFlipAnimation;
@property (nonatomic, retain) CAAnimation* frontBackgroundFlipAnimation;
@property (nonatomic, retain) CAAnimation* backFlipAnimation;
@property (nonatomic, retain) CAAnimation* backBackgroundFlipAnimation;
@property (nonatomic, assign) NSUInteger imageIndex;
@property (nonatomic, retain) UIView* nextView;

@property (nonatomic, assign) BOOL isTransitioning;

@property (nonatomic, retain) CALayer* topLayer;
@property (nonatomic, retain) CALayer* frontFlipLayer;
@property (nonatomic, retain) CALayer* backFlipLayer;
@property (nonatomic, retain) CALayer* frontBackgroundFlipLayer;
@property (nonatomic, retain) CALayer* backBackgroundFlipLayer;
@end

@implementation RSSplitFlapView
@synthesize perspectivalDistance;
@synthesize frontFlipAnimation;
@synthesize frontBackgroundFlipAnimation;
@synthesize backFlipAnimation;
@synthesize backBackgroundFlipAnimation;
@synthesize fadeEffectColor;
@synthesize imageIndex;
@synthesize nextView;
@synthesize contentView;
@synthesize topLayer;
@synthesize frontFlipLayer;
@synthesize backFlipLayer;
@synthesize frontBackgroundFlipLayer;
@synthesize backBackgroundFlipLayer;
@synthesize isTransitioning;

-(id)init
{
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initProperties];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
    }
    return self;
}

-(void)dealloc
{
    [frontFlipAnimation release];
    [backFlipAnimation release];
    [frontBackgroundFlipAnimation release];
    [backBackgroundFlipAnimation release];
    [fadeEffectColor release];
    [nextView release];
    [contentView release];
    [frontFlipLayer release];
    [backFlipLayer release];
    [frontBackgroundFlipLayer release];
    [backBackgroundFlipLayer release];
    [super dealloc];
}

-(void)setContentView:(UIView *)aContentView
{
    [contentView autorelease];
    [contentView removeFromSuperview];
    contentView = [aContentView retain];
    [self addSubview:aContentView];
}

#pragma mark - private Methods

-(void)splitView:(UIView *)aView intoTopHalf:(UIImage **)topImage bottomHalf:(UIImage **)bottomImage
{
    // The size of each part is half the height of the whole image
    CGSize size = CGSizeMake(aView.frame.size.width, ceilf(aView.frame.size.height*.5f));
    
    // Create image-based graphics context for top half
    UIGraphicsBeginImageContext(size);
    
    
    // Draw into context, bottom half is cropped off
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    // Grab the current contents of the context as a UIImage 
    // and add it to our array
    if (topImage != nil) {
        *topImage = [[UIGraphicsGetImageFromCurrentImageContext() retain] autorelease];
    }
    
    
    //Clear the context
    CGContextClearRect(UIGraphicsGetCurrentContext(), CGRectMake(0.f, 0.f, size.width, size.height));
    
    //Shift the cordinates so we may render the bottom half
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.f, -size.height);
    
    // Now draw the image starting half way down, to get the bottom half
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    // And store that image in the array too
    if (bottomImage != nil) {
        *bottomImage = [[UIGraphicsGetImageFromCurrentImageContext() retain] autorelease];
    }
    
    UIGraphicsEndImageContext();
}

-(UIImage*) imageByFlippingImageVertically:(UIImage*)image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, image.size.height);
    CGContextConcatCTM(context, flipVertical);  
    
    [image drawAtPoint:CGPointMake(0.f, 0.f)];
    
    UIImage *flippedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return flippedImage;
}

-(void)initProperties
{
    self.userInteractionEnabled = NO;
    self.perspectivalDistance = kDefaultPerspectivalDistance;
    self.fadeEffectColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
}


-(void)initLayers
{
    //Get image size
    CGSize imageSize = self.contentView.frame.size;
    
    self.topLayer = [CALayer layer];
    topLayer.doubleSided = NO;
    topLayer.frame = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height * 0.5f);
    
    self.frontFlipLayer= [CALayer layer];
    frontFlipLayer.doubleSided = NO;
    frontFlipLayer.name = @"1";
    frontFlipLayer.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height * 0.5f); 
    frontFlipLayer.anchorPoint = CGPointMake(0.5f, 1.f);
    frontFlipLayer.position = CGPointMake(frontFlipLayer.position.x, imageSize.height * 0.5f); 
    [frontFlipLayer setMasksToBounds:NO];
    
    self.backFlipLayer = [CALayer layer];
    backFlipLayer.doubleSided = YES;
    backFlipLayer.name = @"2";
    backFlipLayer.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height/2);
    backFlipLayer.anchorPoint = CGPointMake(0.5f, 1.f);
    backFlipLayer.position = CGPointMake(backFlipLayer.position.x, imageSize.height/2);
    [backFlipLayer setMasksToBounds:NO];
    
    self.frontBackgroundFlipLayer = [CALayer layer];
    frontBackgroundFlipLayer.doubleSided = YES;
    frontBackgroundFlipLayer.name = @"3";
    frontBackgroundFlipLayer.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height/2);
    frontBackgroundFlipLayer.anchorPoint = CGPointMake(0.5f, 1.f);
    frontBackgroundFlipLayer.position = CGPointMake(frontBackgroundFlipLayer.position.x, imageSize.height/2);
    //frontBackgroundFlipLayer.cornerRadius = 4.f;
    frontBackgroundFlipLayer.backgroundColor = fadeEffectColor.CGColor;
    [frontBackgroundFlipLayer setMasksToBounds:NO];
    
    self.backBackgroundFlipLayer = [CALayer layer];
    backBackgroundFlipLayer.doubleSided = YES;
    backBackgroundFlipLayer.name = @"4";
    backBackgroundFlipLayer.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height/2);
    backBackgroundFlipLayer.anchorPoint = CGPointMake(0.5f, 1.f);
    backBackgroundFlipLayer.position = CGPointMake(backBackgroundFlipLayer.position.x, imageSize.height/2);
    //backBackgroundFlipLayer.cornerRadius = 4.f;
    backBackgroundFlipLayer.backgroundColor = fadeEffectColor.CGColor;
    [backBackgroundFlipLayer setMasksToBounds:NO];
    
    [self.layer addSublayer:topLayer];
    [self.layer addSublayer:backBackgroundFlipLayer];
    [self.layer addSublayer:backFlipLayer];
    [self.layer addSublayer:frontBackgroundFlipLayer];
    [self.layer addSublayer:frontFlipLayer];
    
    CGFloat zDistance = self.perspectivalDistance;
    CATransform3D perspective = CATransform3DIdentity; 
    perspective.m34 = -1. / zDistance;
    frontFlipLayer.transform = perspective;
    backFlipLayer.transform = perspective;
    frontBackgroundFlipLayer.transform = perspective;
    backBackgroundFlipLayer.transform = perspective;
}


+(CAAnimation *)flipAnimationWithDuration:(NSTimeInterval)aDuration angle:(CGFloat)angleRadian;
{    
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    CGFloat startValue = 0.f;
    CGFloat endValue = angleRadian;
    flipAnimation.fromValue = [NSNumber numberWithDouble:startValue];
    flipAnimation.toValue = [NSNumber numberWithDouble:endValue];
    
    //Remember not to set the delegate here
    
    flipAnimation.repeatCount = 1;
    flipAnimation.duration = aDuration;
    flipAnimation.fillMode = kCAFillModeForwards;
    flipAnimation.removedOnCompletion = NO;
    
    return flipAnimation;
    
}


+(CATransition *)fadeTransitionWithDuration:(NSTimeInterval)aDuration
{
    CATransition* trans = [CATransition animation];
    trans.type = kCATransitionFade;
    trans.duration = aDuration;
    trans.removedOnCompletion = YES;
    trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return trans;
}

- (void)flipToView:(UIView *)aView
{
    if (isTransitioning)
		return;
    
	isTransitioning = YES;
    
    self.nextView = aView;
    
    [self initLayers];
    
    UIImage* oldImageTop;
    UIImage* newImageTop;
    UIImage* newImageBottom;
    [self splitView:aView intoTopHalf:&newImageTop bottomHalf:&newImageBottom];
    [self splitView:contentView intoTopHalf:&oldImageTop bottomHalf:nil];
    
    if (nil == frontFlipAnimation) {
        self.frontFlipAnimation = [RSSplitFlapView flipAnimationWithDuration:kAnimationDuration*.5f angle:-M_PI_2];
        self.frontBackgroundFlipAnimation = [RSSplitFlapView flipAnimationWithDuration:kAnimationDuration*.5f angle:-M_PI_2];
        
        self.backFlipAnimation = [RSSplitFlapView flipAnimationWithDuration:kAnimationDuration angle:-M_PI];
        self.backBackgroundFlipAnimation = [RSSplitFlapView flipAnimationWithDuration:kAnimationDuration angle:-M_PI];
    }
    backFlipAnimation.delegate = self;
    
    frontFlipLayer.contents = (id)oldImageTop.CGImage;
    topLayer.contents = (id) newImageTop.CGImage;    
    backFlipLayer.contents = (id) newImageBottom.CGImage;//[self imageByFlippingImageVertically:newImageTop].CGImage;

    
    [CATransaction begin];
    [frontFlipLayer addAnimation:self.frontFlipAnimation forKey:@"flip"];
    [frontBackgroundFlipLayer addAnimation:self.frontBackgroundFlipAnimation forKey:@"flip"];
    [backFlipLayer addAnimation:self.backFlipAnimation forKey:@"flip"];
    [backBackgroundFlipLayer addAnimation:self.backBackgroundFlipAnimation forKey:@"flip"];
    [CATransaction commit];
}

#pragma mark - animation delegate
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    isTransitioning = NO;
    
    self.contentView = nextView;
    self.nextView = nil;
    [frontFlipLayer removeFromSuperlayer];
    [backFlipLayer removeFromSuperlayer];
    [frontBackgroundFlipLayer removeFromSuperlayer];
    [backBackgroundFlipLayer removeFromSuperlayer];
        
}
@end
