//
//  EZCountryCellViewController.m
//  EZ Tube
//
//  Created by dan mullaguru on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EZCountryCellView.h"



@implementation EZCountryCellView

@synthesize flagImageView;
@synthesize flagBorderImageView;
@synthesize countryNameLbl;
@synthesize countryCode;
@synthesize countryName;
@synthesize delegate;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setFlagImageView:nil];
    [self setCountryNameLbl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

*/


- (id)initWithFrame:(CGRect)frame {
    
    //self = [super initWithFrame:frame]; // not needed - thanks ddickison
	if (self) {
        NSArray *nib = [[NSBundle mainBundle] 
						loadNibNamed:@"EZCountryCellView"
						owner:self
						options:nil];
		
		[self release];	// release object before reassignment to avoid leak - thanks ddickison
		self = [nib objectAtIndex:0];
       
        
        // Initialization code
        // single tap
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer: singleTap];
        [singleTap release];
 	
    }
    return self;
}

-(void)refreshToCountryCode:(NSString *)toCountryCode
{
    
    if([toCountryCode isEqualToString:self.countryCode])
    {
         [self.flagBorderImageView setHidden:NO];
    }
    else 
    {
         [self.flagBorderImageView setHidden:YES];
    }
    
}

-(void) handleSingleTap:(UITapGestureRecognizer *)gr {
    //NSLog(@"Country selected");
    [self.delegate showChangeCountryAlert:self.countryCode];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc {
    [flagImageView release];
    [countryNameLbl release];
    [flagBorderImageView release];
    [super dealloc];
}
@end
