//
//  EzLanguageSelectionViewController.h
//  EZ Tube
//
//  Created by dan mullaguru on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalizationSystem.h"

@protocol EzLanguageSelectionViewControllerDelegate <NSObject>

-(void) doneWithLanguagePreferences;
-(void) setLanguageTo:(NSString *)lang;
//-(void) initializeLanguageTo:(NSString *)lang;
@end

@interface EzLanguageSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    
    id<EzLanguageSelectionViewControllerDelegate> delegate;
}
@property (nonatomic, retain) NSString * useDeviceLanguage;
@property (nonatomic, retain) NSString * currentAppLanguage;
@property (nonatomic, retain) NSString * toAppLanguage;
@property (nonatomic, retain) NSArray * supportedAppLanguages ;
- (IBAction)SwitchUseDeviceLanguage:(id)sender;
@property (retain, nonatomic) IBOutlet UITableView *supportedLangsTableView1;
@property (retain, nonatomic) IBOutlet UITableView *supportedLangsTableView2;
@property (retain, nonatomic) IBOutlet UITableView *supportedLangsTableView3;
@property (retain, nonatomic) IBOutlet UITableView *supportedLangsTableView4;
@property (retain, nonatomic) IBOutlet UITableView *supportedLangsTableView5;

@property (retain, nonatomic) IBOutlet UILabel *deviceLanguageLbl;

@property (strong, nonatomic) id<EzLanguageSelectionViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UISwitch *useDeviceLanguageSwitch;
@property (retain, nonatomic) IBOutlet UIView *deviceLangView;
@property (retain, nonatomic) IBOutlet UIButton *languageInitializedButton;
- (IBAction)initializeLanguage:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *chooseLanguageLocalizedText;
@property (nonatomic, retain) LocalizationSystem * ls;

@end
