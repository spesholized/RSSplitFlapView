//
//  SplitFlapView.m
//  TVCompanion
//
//  Created by rollin.su on 11-10-18.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSSplitFlapView.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDuration 2.f
#define kDefaultPerspectivalDistance 500.f

@interface RSSplitFlapView()
+(CAAnimation *)flipAnimationWithDuration:(NSTimeInterval)aDuration angle:(CGFloat)angleRadian;
+(CATransition *)fadeTransitionWithDuration:(NSTimeInterval)aDuration;
-(void)initProperties;
-(void)initLayers;
-(void)splitView:(UIView*)aView intoTopHalf:(UIImage**)topImage bottomHalf:(UIImage**)bottomImage;

@property (nonatomic, strong) CAAnimation* frontFlipAnimation;
@property (nonatomic, strong) CAAnimation* frontBackgroundFlipAnimation;
@property (nonatomic, strong) CAAnimation* backFlipAnimation;
@property (nonatomic, strong) CAAnimation* backBackgroundFlipAnimation;
@property (nonatomic, assign) NSUInteger imageIndex;
@property (nonatomic, strong) UIView* nextView;

@property (nonatomic, assign) BOOL isTransitioning;

@property (nonatomic, strong) CALayer* topLayer;
@property (nonatomic, strong) CALayer* frontFlipLayer;
@property (nonatomic, strong) CALayer* backFlipLayer;
@property (nonatomic, strong) CALayer* frontBackgroundFlipLayer;
@property (nonatomic, strong) CALayer* backBackgroundFlipLayer;
@end

@implementation RSSplitFlapView

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


-(void)setContentView:(UIView *)aContentView
{
    if (aContentView != _contentView) {
        [_contentView removeFromSuperview];
        _contentView = aContentView;
        [self addSubview:aContentView];
    }
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
        *topImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    
    
    //Clear the context
    CGContextClearRect(UIGraphicsGetCurrentContext(), CGRectMake(0.f, 0.f, size.width, size.height));
    
    //Shift the cordinates so we may render the bottom half
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.f, -size.height);
    
    // Now draw the image starting half way down, to get the bottom half
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    // And store that image in the array too
    if (bottomImage != nil) {
        *bottomImage = UIGraphicsGetImageFromCurrentImageContext();
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
    _topLayer.doubleSided = NO;
    _topLayer.frame = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height * 0.5f);
    
    self.frontFlipLayer= [CALayer layer];
    _frontFlipLayer.doubleSided = NO;
    _frontFlipLayer.name = @"1";
    _frontFlipLayer.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height * 0.5f);
    _frontFlipLayer.anchorPoint = CGPointMake(0.5f, 1.f);
    _frontFlipLayer.position = CGPointMake(_frontFlipLayer.position.x, imageSize.height * 0.5f);
    [_frontFlipLayer setMasksToBounds:NO];
    
    self.backFlipLayer = [CALayer layer];
    _backFlipLayer.doubleSided = YES;
    _backFlipLayer.name = @"2";
    _backFlipLayer.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height/2);
    _backFlipLayer.anchorPoint = CGPointMake(0.5f, 1.f);
    _backFlipLayer.position = CGPointMake(_backFlipLayer.position.x, imageSize.height/2);
    [_backFlipLayer setMasksToBounds:NO];
    
    self.frontBackgroundFlipLayer = [CALayer layer];
    _frontBackgroundFlipLayer.doubleSided = YES;
    _frontBackgroundFlipLayer.name = @"3";
    _frontBackgroundFlipLayer.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height/2);
    _frontBackgroundFlipLayer.anchorPoint = CGPointMake(0.5f, 1.f);
    _frontBackgroundFlipLayer.position = CGPointMake(_frontBackgroundFlipLayer.position.x, imageSize.height/2);
    //frontBackgroundFlipLayer.cornerRadius = 4.f;
    _frontBackgroundFlipLayer.backgroundColor = _fadeEffectColor.CGColor;
    [_frontBackgroundFlipLayer setMasksToBounds:NO];
    
    self.backBackgroundFlipLayer = [CALayer layer];
    _backBackgroundFlipLayer.doubleSided = YES;
    _backBackgroundFlipLayer.name = @"4";
    _backBackgroundFlipLayer.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height/2);
    _backBackgroundFlipLayer.anchorPoint = CGPointMake(0.5f, 1.f);
    _backBackgroundFlipLayer.position = CGPointMake(_backBackgroundFlipLayer.position.x, imageSize.height/2);
    //backBackgroundFlipLayer.cornerRadius = 4.f;
    _backBackgroundFlipLayer.backgroundColor = _fadeEffectColor.CGColor;
    [_backBackgroundFlipLayer setMasksToBounds:NO];
    
    [self.layer addSublayer:_topLayer];
    [self.layer addSublayer:_backBackgroundFlipLayer];
    [self.layer addSublayer:_backFlipLayer];
    [self.layer addSublayer:_frontBackgroundFlipLayer];
    [self.layer addSublayer:_frontFlipLayer];
    
    CGFloat zDistance = self.perspectivalDistance;
    CATransform3D perspective = CATransform3DIdentity; 
    perspective.m34 = -1. / zDistance;
    _frontFlipLayer.transform = perspective;
    _backFlipLayer.transform = perspective;
    _frontBackgroundFlipLayer.transform = perspective;
    _backBackgroundFlipLayer.transform = perspective;
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
    if (_isTransitioning)
		return;
    
	_isTransitioning = YES;
    
    self.nextView = aView;
    
    [self initLayers];
    
    UIImage* oldImageTop;
    UIImage* newImageTop;
    UIImage* newImageBottom;
    [self splitView:aView intoTopHalf:&newImageTop bottomHalf:&newImageBottom];
    [self splitView:_contentView intoTopHalf:&oldImageTop bottomHalf:nil];
    
    if (nil == _frontFlipAnimation) {
        self.frontFlipAnimation = [RSSplitFlapView flipAnimationWithDuration:kAnimationDuration*.5f angle:-M_PI_2];
        self.frontBackgroundFlipAnimation = [RSSplitFlapView flipAnimationWithDuration:kAnimationDuration*.5f angle:-M_PI_2];
        
        self.backFlipAnimation = [RSSplitFlapView flipAnimationWithDuration:kAnimationDuration angle:-M_PI];
        self.backBackgroundFlipAnimation = [RSSplitFlapView flipAnimationWithDuration:kAnimationDuration angle:-M_PI];
    }
    _backFlipAnimation.delegate = self;
    
    _frontFlipLayer.contents = (id)oldImageTop.CGImage;
    _topLayer.contents = (id) newImageTop.CGImage;
    _backFlipLayer.contents = (id) [self imageByFlippingImageVertically:newImageBottom].CGImage;

    
    [CATransaction begin];
    [_frontFlipLayer addAnimation:self.frontFlipAnimation forKey:@"flip"];
    [_frontBackgroundFlipLayer addAnimation:self.frontBackgroundFlipAnimation forKey:@"flip"];
    [_backFlipLayer addAnimation:self.backFlipAnimation forKey:@"flip"];
    [_backBackgroundFlipLayer addAnimation:self.backBackgroundFlipAnimation forKey:@"flip"];
    [CATransaction commit];
}

#pragma mark - animation delegate
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _isTransitioning = NO;
    
    self.contentView = _nextView;
    self.nextView = nil;
    [_frontFlipLayer removeFromSuperlayer];
    [_backFlipLayer removeFromSuperlayer];
    [_frontBackgroundFlipLayer removeFromSuperlayer];
    [_backBackgroundFlipLayer removeFromSuperlayer];
        
}
@end
