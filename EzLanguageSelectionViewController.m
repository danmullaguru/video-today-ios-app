//
//  EzLanguageSelectionViewController.m
//  EZ Tube
//
//  Created by dan mullaguru on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EzLanguageSelectionViewController.h"

@interface EzLanguageSelectionViewController ()
- (void)configureCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
-(void) loadSupportedLanguagePlist;
-(void) loadDefaults;
-(void) setCurrentUIState;
-(void) setLocalizedChooseLanguageText;

@end

@implementation EzLanguageSelectionViewController
@synthesize chooseLanguageLocalizedText;
@synthesize supportedLangsTableView1;
@synthesize supportedLangsTableView2;
@synthesize supportedLangsTableView3;
@synthesize supportedLangsTableView4;
@synthesize supportedLangsTableView5;
@synthesize deviceLanguageLbl;
@synthesize delegate;
@synthesize useDeviceLanguageSwitch;
@synthesize deviceLangView;
@synthesize languageInitializedButton;
@synthesize useDeviceLanguage;
@synthesize currentAppLanguage;
@synthesize toAppLanguage;
@synthesize supportedAppLanguages;
@synthesize ls;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    [self loadSupportedLanguagePlist];
    [self loadDefaults];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //Load language
    ls = [LocalizationSystem sharedLocalSystem];
    
    [self setCurrentUIState];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWithPreferencesLocal:)];
    
  

    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
    //NSString *language = [[NSLocale currentLocale] displayNameForKey:NSLocaleLanguageCode value:s];
    
    NSLocale *localeLang = [[[NSLocale alloc] initWithLocaleIdentifier:langID] autorelease];
    NSLocale *localeEng = [[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease];

    NSString * langNameinEnglish = [localeEng displayNameForKey:NSLocaleIdentifier value:langID];
    
    NSString * langNameinLang = [localeLang displayNameForKey:NSLocaleIdentifier value:langID];
    
    deviceLanguageLbl.text = [NSString stringWithFormat:@"%@ (%@)",langNameinEnglish,langNameinLang];
    
    //NSLog(@"%@ (%@)",langNameinEnglish,langNameinLang);
    
    [self setLocalizedChooseLanguageText];
    
}

-(void) loadDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!([defaults objectForKey:@"useDeviceLanguage"] 
        && [defaults objectForKey:@"currentAppLanguage"])) 
    {
        [defaults setObject:@"N" forKey:@"useDeviceLanguage"];
        [defaults setObject:@"en" forKey:@"currentAppLanguage"];
        [defaults synchronize];
    }
    
    useDeviceLanguage = [defaults objectForKey:@"useDeviceLanguage"];
    currentAppLanguage = [defaults objectForKey:@"currentAppLanguage"];
    toAppLanguage = currentAppLanguage;
}

-(void) setLocalizedChooseLanguageText
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * langCode = [[defaults objectForKey:@"currentAppLanguage"] substringToIndex:2];
    
    if(!([langCode isEqualToString:@"en"]))
    {
        [self.chooseLanguageLocalizedText setHidden:NO];
        self.chooseLanguageLocalizedText.text = ls.eZ_CHOOSE_LANGUAGE;
    }
    else 
    {
        [self.chooseLanguageLocalizedText setHidden:YES];
    }
    
    
}

-(void) loadSupportedLanguagePlist
{
    /*
     NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"AppSupportedLanguages.plist"];
    NSArray *plistData = [[[NSArray alloc] initWithContentsOfFile:finalPath] retain];
    NSLog(@"plist data: %@",plistData);
    */
    
    
    //NSLog(@"Plist path:%@",[[NSBundle mainBundle] pathForResource:@"AppSupportedLanguages" ofType:@"plist"]);
    
    supportedAppLanguages = [[[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                              pathForResource:@"AppSupportedLanguages" ofType:@"plist"]] retain];
    //NSLog(@"Supported Languages Array:%@",[supportedAppLanguages description]);
}

-(void) setCurrentUIState
{
    if([useDeviceLanguage isEqualToString:@"Y"])
    {
        
        [useDeviceLanguageSwitch setOn:YES];
        //[supportedLangsTableView1 setUserInteractionEnabled:NO];
        supportedLangsTableView1.alpha = 0.4;
        supportedLangsTableView2.alpha = 0.4;
        supportedLangsTableView3.alpha = 0.4;
        supportedLangsTableView4.alpha = 0.4;
        supportedLangsTableView5.alpha = 0.4;
        deviceLangView.alpha = 1.0;
        
    }
    else {
        
        [useDeviceLanguageSwitch setOn:NO];
        //[supportedLangsTableView1 setUserInteractionEnabled:YES];
        supportedLangsTableView1.alpha = 1.0;
        supportedLangsTableView2.alpha = 1.0;
        supportedLangsTableView3.alpha = 1.0;
        supportedLangsTableView4.alpha = 1.0;
        supportedLangsTableView5.alpha = 1.0;
        deviceLangView.alpha = 0.4;
    }
}

- (IBAction)SwitchUseDeviceLanguage:(id)sender {
    
    if(! useDeviceLanguageSwitch.isOn)
    {
       
        //[supportedLangsTableView1 setUserInteractionEnabled:YES];
        supportedLangsTableView1.alpha = 1.0;
        supportedLangsTableView2.alpha = 1.0;
        supportedLangsTableView3.alpha = 1.0;
        supportedLangsTableView4.alpha = 1.0;
        supportedLangsTableView5.alpha = 1.0;
        deviceLangView.alpha = 0.4;
        
        useDeviceLanguage = @"N";
        [[NSUserDefaults standardUserDefaults] setObject:useDeviceLanguage forKey:@"useDeviceLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
    }
    else {
       
        //[supportedLangsTableView1 setUserInteractionEnabled:NO];
        supportedLangsTableView1.alpha = 0.4;
        supportedLangsTableView2.alpha = 0.4;
        supportedLangsTableView3.alpha = 0.4;
        supportedLangsTableView4.alpha = 0.4;
        supportedLangsTableView5.alpha = 0.4;
        deviceLangView.alpha = 1.0;
        
        useDeviceLanguage = @"Y";
        [[NSUserDefaults standardUserDefaults] setObject:useDeviceLanguage forKey:@"useDeviceLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

- (void)viewDidUnload
{

    [self setSupportedLangsTableView1:nil];
    [self setSupportedLangsTableView2:nil];
    [self setSupportedLangsTableView3:nil];
    [self setDeviceLanguageLbl:nil];
    [self setUseDeviceLanguageSwitch:nil];
    [self setDeviceLangView:nil];
    [self setSupportedLangsTableView4:nil];
    [self setSupportedLangsTableView5:nil];
    [self setLanguageInitializedButton:nil];
    [self setChooseLanguageLocalizedText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//return YES;
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


#pragma mark - Table datasource delegate methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
 
 NSArray * sectionTitles = [NSArray arrayWithObject:@"Channels"];
 return sectionTitles;
 }
 */


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows =0;
    if([tableView isEqual:supportedLangsTableView1])
    {
        rows = 8;
    }
    else if([tableView isEqual:supportedLangsTableView2])
    {
        rows = 8;
    }
    else if([tableView isEqual:supportedLangsTableView3])
    {
        rows = 8;
    }
    else if([tableView isEqual:supportedLangsTableView4])
    {
        rows = 8;
    }
    else if([tableView isEqual:supportedLangsTableView5])
    {
        rows = 5;
    }
    return rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SupportedLanguage";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];

    }
    
    [self configureCell:cell forTableView:tableView atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    int actualRow = 0;
    
    if([tableView isEqual:supportedLangsTableView1])
    {
        actualRow = indexPath.row;
    }
    else if([tableView isEqual:supportedLangsTableView2])
    {
        actualRow = indexPath.row+8;
    }
    else if([tableView isEqual:supportedLangsTableView3])
    {
        actualRow = indexPath.row+16;
    }
    else if([tableView isEqual:supportedLangsTableView4])
    {
        actualRow = indexPath.row+24;
    }
    else if([tableView isEqual:supportedLangsTableView5])
    {
        actualRow = indexPath.row+32;
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    //[cell.textLabel sizeToFit];
    cell.textLabel.text = [[supportedAppLanguages objectAtIndex:actualRow] valueForKey:@"langNameLocal"];
    cell.detailTextLabel.text = [[supportedAppLanguages objectAtIndex:actualRow] valueForKey:@"langName"];
    
    if([toAppLanguage isEqualToString:[[supportedAppLanguages objectAtIndex:actualRow] valueForKey:@"langCode"]])
    {
     //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //cell.textLabel.font. = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.contentView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"langcellSelected.png"]];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    else 
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.contentView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"langcellDefault.png"]];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        
    }
                        
    //cell.detailTextLabel.text = [[supportedAppLanguages objectAtIndex:indexPath.row] valueForKey:@"langNameLocal"];//@"english";

    
}

#pragma mark - TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int actualRow = 0;
    
    if([tableView isEqual:supportedLangsTableView1])
    {
        actualRow = indexPath.row;
    }
    else if([tableView isEqual:supportedLangsTableView2])
    {
        actualRow = indexPath.row+8;
    }
    else if([tableView isEqual:supportedLangsTableView3])
    {
        actualRow = indexPath.row+16;
    }
    else if([tableView isEqual:supportedLangsTableView4])
    {
        actualRow = indexPath.row+24;
    }
    else if([tableView isEqual:supportedLangsTableView5])
    {
        actualRow = indexPath.row+32;
    }
    
    toAppLanguage = [[supportedAppLanguages objectAtIndex:actualRow] valueForKey:@"langCode"];
    [supportedLangsTableView1 reloadData];
    [supportedLangsTableView2 reloadData];
    [supportedLangsTableView3 reloadData];
    [supportedLangsTableView4 reloadData];
    [supportedLangsTableView5 reloadData];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 65.0f;
}

-(void)setLanguageTo:(NSString *)lang
{

}

- (IBAction)initializeLanguage:(id)sender {
    
        [[NSUserDefaults standardUserDefaults] setObject:toAppLanguage forKey:@"currentAppLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.delegate setLanguageTo:toAppLanguage];
    
    [self dismissModalViewControllerAnimated:YES];
    
}

-(void) doneWithPreferencesLocal:(id)sender {
    if(![toAppLanguage isEqualToString:currentAppLanguage])
    {
        [[NSUserDefaults standardUserDefaults] setObject:toAppLanguage forKey:@"currentAppLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.delegate setLanguageTo:toAppLanguage];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    
    [supportedLangsTableView1 release];
    [supportedLangsTableView2 release];
    [supportedLangsTableView3 release];
    [deviceLanguageLbl release];
    [useDeviceLanguageSwitch release];
    [deviceLangView release];
    [supportedLangsTableView4 release];
    [supportedLangsTableView5 release];
    [languageInitializedButton release];
    [chooseLanguageLocalizedText release];
    [super dealloc];
}


@end
