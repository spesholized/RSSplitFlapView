//
//  ViewController.h
//  RSSplitFlapSample
//
//  Created by rollin.su on 12-02-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSSplitFlapView;
@interface ViewController : UIViewController

@property (retain, nonatomic) IBOutlet RSSplitFlapView *splitFlapView1;
@property (retain, nonatomic) IBOutlet RSSplitFlapView *splitFlapView2;
- (IBAction)onMinusButtonTapped:(id)sender;
- (IBAction)onPlusButtonTapped:(id)sender;
@end
