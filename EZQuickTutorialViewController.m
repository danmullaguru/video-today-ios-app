//
//  EZQuickTutorialViewController.m
//  EZ Tube
//
//  Created by dan mullaguru on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EZQuickTutorialViewController.h"

@interface EZQuickTutorialViewController ()
-(void) loadTutorialImages;
-(void) layoutTutorialPages;
-(void) setScrollViewContentSize;
-(void) showHidePrevNextDoneButtons;
-(void) setLocalizedTutorialText;
@end

@implementation EZQuickTutorialViewController
@synthesize tutorialLocalizedText;
@synthesize doneButton;
@synthesize nextPageButton;
@synthesize tutorialScrollView;
@synthesize previousPageButton;

@synthesize currentPageNum;
@synthesize tutorialImages;
@synthesize pageControl;
@synthesize ls;

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
    ls = [LocalizationSystem sharedLocalSystem];
    
    [self loadTutorialImages];
    [self layoutTutorialPages];
    self.currentPageNum = 0;
    self.pageControl.currentPage =0; 
    [self showHidePrevNextDoneButtons];
    
    // Do any additional setup after loading the view from its nib.
    
    UIImage *buttonImageNormal = [UIImage imageNamed:@"action-normal.png"];
    UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [doneButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    
    UIImage *buttonImagePressed = [UIImage imageNamed:@"action-pressed.png"];
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [doneButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
    [self setLocalizedTutorialText];
}

- (void)viewDidUnload
{
    [self setPageControl:nil];
    [self setTutorialScrollView:nil];
    [self setPreviousPageButton:nil];
    [self setNextPageButton:nil];
    [self setDoneButton:nil];
    [self setTutorialLocalizedText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//return YES;
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
    [pageControl release];
    [tutorialScrollView release];
    [previousPageButton release];
    [nextPageButton release];
    [doneButton release];
    [tutorialLocalizedText release];
    [super dealloc];
}

-(void) setLocalizedTutorialText
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * langCode = [[defaults objectForKey:@"currentAppLanguage"] substringToIndex:2];
    
    if(!([langCode isEqualToString:@"en"]))
    {
        [self.tutorialLocalizedText setHidden:NO];
        self.tutorialLocalizedText.text = ls.eZ_TUTORIAL;
    }
    else 
    {
        [self.tutorialLocalizedText setHidden:YES];
    }
    
    
}

-(void) loadTutorialImages
{
    
    self.tutorialImages =  [[NSArray alloc] initWithObjects: 
                                    [UIImage imageNamed:@"tutorial1.jpg"],
                                    [UIImage imageNamed:@"tutorial2.jpg"],
                                    [UIImage imageNamed:@"tutorial3.jpg"],
                                    [UIImage imageNamed:@"tutorial4.jpg"],
                                    [UIImage imageNamed:@"tutorial5.jpg"],
                                    [UIImage imageNamed:@"tutorial6.jpg"],
                                    [UIImage imageNamed:@"tutorial7.jpg"],
                                    nil];
}

-(void) layoutTutorialPages
{
    [self setScrollViewContentSize];
    int x = 0;
    int y = 0;
    int width = self.tutorialScrollView.frame.size.width;
    int height = self.tutorialScrollView.frame.size.height;
    
   for(UIImage * img in self.tutorialImages)
   {
       UIImageView * imgView = [[UIImageView alloc]initWithImage:img];
       imgView.frame = CGRectMake(x, y, width, height);
       [self.tutorialScrollView addSubview:imgView];
       x = x+width;
    
       
       
   }
    
}

-(void) setScrollViewContentSize
{
    int width = self.tutorialScrollView.frame.size.width * self.tutorialImages.count;
    self.tutorialScrollView.contentSize = CGSizeMake(width, self.tutorialScrollView.frame.size.height);
}
    
- (IBAction)changePage:(id)sender 
{
    
    int page = pageControl.currentPage;
    pageControlUsed = YES;
	currentPageNum = page;

    
	// update the scroll view to the appropriate page
    CGRect frame = tutorialScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [tutorialScrollView scrollRectToVisible:frame animated:YES];
    
     [self showHidePrevNextDoneButtons];
    
}

#pragma mark  Layout Pages when scrolled Horizontally -

-(void)scrollViewDidScroll:(UIScrollView *)scrollView

{
    //NSLog(@"Scroll View did scroll in the Channel");
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    pageControlUsed = NO;
    CGFloat pageWidth = tutorialScrollView.frame.size.width;// self.view.frame.size.width;
    //int offset = ((UIScrollView *)self.view).contentOffset.x;
    int pageNum = floor((self.tutorialScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    currentPageNum = pageNum;
    pageControl.currentPage = pageNum;
     [self showHidePrevNextDoneButtons];
}

-(void) showHidePrevNextDoneButtons
{
    

        
    if(self.currentPageNum >0)
    {
        [self.previousPageButton setHidden:NO];
    }
    else 
    {
        [self.previousPageButton setHidden:YES];
    }
    
    if(self.currentPageNum < self.tutorialImages.count-1)
    {
        [self.nextPageButton setHidden:NO];
    }
    else 
    {
        [self.nextPageButton setHidden:YES];
    }
    
    if(self.currentPageNum == self.tutorialImages.count-1)
    {
        [self.doneButton setHidden:NO];
    }
    else 
    {    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //App language not set yet
        if (!([defaults objectForKey:@"appInitialized"])) 
        {
            [self.doneButton setHidden:YES];
        }
        else 
        {
             [self.doneButton setHidden:NO];
        }
    }
}

- (IBAction)goToPreviousPage:(id)sender 
{
    if(self.currentPageNum >0)
    {
        pageControl.currentPage = self.currentPageNum-1;
        [self changePage:nil];
    }
     [self showHidePrevNextDoneButtons];
}
- (IBAction)goToNextPage:(id)sender 
{
    if(self.currentPageNum < self.tutorialImages.count-1)
    {
        pageControl.currentPage = self.currentPageNum+1;
        [self changePage:nil];
    }
     [self showHidePrevNextDoneButtons];
    
}

- (IBAction)tutorialCompleted:(id)sender 
{
    //[self setAppInitializationComplete];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Y" forKey:@"appInitialized"];
    [defaults synchronize];
    
    [self dismissModalViewControllerAnimated:YES];
}
@end
