//
//  EZQuickTutorialViewController.h
//  EZ Tube
//
//  Created by dan mullaguru on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalizationSystem.h"

@interface EZQuickTutorialViewController : UIViewController
{
    BOOL pageControlUsed;
}

@property int currentPageNum;
@property (nonatomic, retain) NSArray * tutorialImages;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)changePage:(id)sender;
@property (retain, nonatomic) IBOutlet UIScrollView *tutorialScrollView;
@property (retain, nonatomic) IBOutlet UIButton *previousPageButton;
- (IBAction)goToPreviousPage:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *nextPageButton;
- (IBAction)goToNextPage:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)tutorialCompleted:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *tutorialLocalizedText;
@property (nonatomic, retain) LocalizationSystem * ls;

@end
