//
//  EZCountrySelectionViewController.h
//  EZ Tube
//
//  Created by dan mullaguru on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalizationSystem.h"
#import "EZCountryCellView.h"
#import "Reachability.h"

@protocol EZCountrySelectionViewControllerDelegate <NSObject>

-(void) doneWithCountryPreferences;
-(void) setCountryTo:(NSString *)country;
//-(void) initializeCountryTo:(NSString *)lang;

@end


@interface EZCountrySelectionViewController : UIViewController<UIAlertViewDelegate,EZCountryCellViewDelegate>

{
    	UIAlertView		*changeCountryAlert;
        UIAlertView		*internetAlert;
        NSTimer *aTimer;
}
@property(nonatomic, retain) UIAlertView *changeCountryAlert;
@property(nonatomic, retain) UIAlertView *internetAlert;
@property (nonatomic, retain) LocalizationSystem * ls;

@property (retain, nonatomic) IBOutlet UILabel *chooseCountryLocalizedText;

@property (nonatomic, retain) NSString * currentAppCountry ;
@property (nonatomic, retain) NSString * toAppCountry ;
@property (nonatomic, retain) NSString * tempAppCountry ;

@property (nonatomic, retain) NSDictionary * feedFlagsImagesDictionary;
@property (nonatomic, retain) NSArray * countryCodes;
@property (nonatomic, retain) NSArray * country_keys;


@property (strong, nonatomic) id<EZCountrySelectionViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIView *row1View;
@property (retain, nonatomic) IBOutlet UIView *row2View;
@property (retain, nonatomic) IBOutlet UIView *row3View;
@property (retain, nonatomic) IBOutlet UIView *row4View;
@property (retain, nonatomic) IBOutlet UIView *row5View;

@property (retain, nonatomic) IBOutlet UILabel *currentCountryNameLbl;

@property (retain, nonatomic) IBOutlet UIImageView *currentCountryFlagImageView;
@property (retain, nonatomic) IBOutlet UIProgressView *countryChangeProgressView;

@property (retain, nonatomic) IBOutlet UIView *countriesView;
@property (retain, nonatomic) IBOutlet UIButton *countryInitializeButton;

- (IBAction)initializeCountry:(id)sender;
- (BOOL)connected;


@end
