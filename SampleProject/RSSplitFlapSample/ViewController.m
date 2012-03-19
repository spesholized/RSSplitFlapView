//
//  ViewController.m
//  RSSplitFlapSample
//
//  Created by rollin.su on 12-02-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "RSSplitFlapView.h"

@interface ViewController()

-(UILabel*)splitFlapLabelWithText:(NSString*)text;
@end

@implementation ViewController
@synthesize splitFlapView1;
@synthesize splitFlapView2;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(UILabel*)splitFlapLabelWithText:(NSString *)text
{
    UILabel* label = [[[UILabel alloc] init] autorelease];
    label.font = [UIFont boldSystemFontOfSize:220.f];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor greenColor];
    label.text = text;
    return label;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel* label = [self splitFlapLabelWithText:@"8"];
    label.frame = CGRectMake(0.f, 0.f, splitFlapView1.bounds.size.width, splitFlapView1.bounds.size.height);
    self.splitFlapView1.contentView = label;
}

- (void)viewDidUnload
{
    
    [self setSplitFlapView1:nil];
    [self setSplitFlapView2:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc {
    [splitFlapView1 release];
    [splitFlapView2 release];
    [super dealloc];
}
- (IBAction)onMinusButtonTapped:(id)sender {
    static NSUInteger sCount = 0;
    UILabel* nextLabel = [self splitFlapLabelWithText:[NSString stringWithFormat:@"%u", (sCount++)%10]];
    nextLabel.frame = self.splitFlapView1.bounds;
    [self.splitFlapView1 flipToView:nextLabel];
}

- (IBAction)onPlusButtonTapped:(id)sender {
}
@end
