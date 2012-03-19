//
//  SplitFlapView.h
//
//  Created by rollin.su on 11-10-18.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@protocol SplitFlapViewDelegate;
@protocol SplitFlapViewDataSource;
@interface RSSplitFlapView : UIView
{
}

//A lower value exaggerates the perspective, higher value flattens it (recommended value: 300.0 to 1200.0 depending on view size)
@property (nonatomic, assign) CGFloat perspectivalDistance;

//If our flip images have transparency, this color fills it in during an animation
@property (nonatomic, retain) UIColor* fadeEffectColor;

@property (nonatomic, retain) UIView* contentView;

-(void)flipToView:(UIView*)aView;

@end
