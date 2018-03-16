//
//  ViewController.m
//  DigitalLeashParentApp
//
//  Created by Eduard Lev on 2/16/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

@interface ViewController () {
  Reachability *internetReachable;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self finishUpdatingUI];
    [self testInternetConnection];
  
  // adds an observer for notifications that the app enters the foreground.
  // this means whenever app enters the foreground, testInternetConnection will be called
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testInternetConnection)
    name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIFromInternetResult:(BOOL)internet {
  if (!internet) {
    self.errorView.hidden = FALSE;
    self.errorTextField.text = @"Please enable internet prior to using this application.";
    self.createButton.enabled = FALSE;
    self.updateButton.enabled = FALSE;
    self.statusButton.enabled = FALSE;
  } else {
    self.errorView.hidden = TRUE;
    self.createButton.enabled = TRUE;
    self.updateButton.enabled = TRUE;
    self.statusButton.enabled = TRUE;
  }
}
/**
 * Tests if the internet is reachable using the Reachability class
 * Uses google.com as test
 *
 */
- (void)testInternetConnection {
  internetReachable = [Reachability reachabilityWithHostName:@"www.google.com"];
  
  __weak typeof(self) weakSelf = self;
  
  internetReachable.reachableBlock = ^(Reachability*reach) {
    // Update the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf updateUIFromInternetResult:true];
    });
  };
  
  // Internet is not reachable
  internetReachable.unreachableBlock = ^(Reachability*reach)
  {
    // Update the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf updateUIFromInternetResult:false];
    });
  };
  
  [internetReachable startNotifier];
}

- (IBAction)createButtonClicked:(UIButton *)sender {
    // When user clicks the button, check that the form was filled in correctly
    // by calling the function "validateInput"
    if (![self validateInput]) {
        self.errorView.hidden = FALSE;
    } else {
        self.errorView.hidden = TRUE;
        [self createUser];
    }
}

// This function is only called within "createButtonClicked" and if the input is validated
// Overwrites whatever is currently in User. Previous user is deleted by ARC
- (void)createUser {
    self.user = [[User alloc] initWithUser:self.username
                                    Radius:self.radius
                                  Latitude:self.latitude
                                 Longitude:self.longitude];
    [self sendUserToFirebase];
}

// Creates dictionary from current user, converts to JSON and sends to another function
// that creaates the URL request from the resulting data
- (void)sendUserToFirebase {
    NSDictionary *dict = [self createDictionaryFromCurrentUser];
    NSData *data = [self putDictionaryIntoJSON:dict];
    [self createURLRequestToFirebase:data];
}

- (void)updateUserToFirebase {
  NSDictionary *dict = [self createDictionaryFromCurrentUser];
  NSData *data = [self putDictionaryIntoJSON:dict];
  [self createURLRequestToFirebasePATCH:data];
}

- (void)createURLRequestToFirebasePATCH:(NSData*)userData {
  NSURL *url = [[NSURL alloc] withUserName:self.user.username];
  NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
  [urlRequest setURL:url];
  urlRequest.HTTPMethod = @"PATCH";
  
  NSURLSessionDataTask *putURLToFirebase = [[NSURLSession sharedSession]
                                            uploadTaskWithRequest:urlRequest
                                                         fromData:userData
                                                completionHandler:^(NSData * _Nullable data,
                                                             NSURLResponse * _Nullable response,
                                                                   NSError * _Nullable error) {
          if(error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedRecoverySuggestion]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Dismiss",@"")
                                              otherButtonTitles:nil];
                                                    
                                                    [alert show];
                                              
                                              
          }}];
  [putURLToFirebase resume];
}

// Input: userData containing the fields of user
// Will create url, url request and start data task to PUT data to URL
- (void)createURLRequestToFirebase:(NSData*)userData {
    // Creates url with current user name
    NSURL *url = [[NSURL alloc] withUserName:self.user.username];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:url];
    urlRequest.HTTPMethod = @"PUT";
    
    // Create data task to put data to url in firebase
    NSURLSessionDataTask *putURLToFirebase = [[NSURLSession sharedSession]
    uploadTaskWithRequest:urlRequest fromData:userData
    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response,
                        NSError * _Nullable error) {
      if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedRecoverySuggestion]
                                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Dismiss",@"")
                                              otherButtonTitles:nil];
      }}];
   [putURLToFirebase resume];
}

// Creates a dictionary for use in creation JSON
// Uses properties from the current user saved in self.user
- (NSDictionary*)createDictionaryFromCurrentUser {
    NSString *lat = [NSString stringWithFormat:@"%0.4f", self.user.latitude];
    NSString *log = [NSString stringWithFormat:@"%0.4f", self.user.longitude];
    NSString *rad = [NSString stringWithFormat:@"%0.4f", self.user.radius];
    
    NSDictionary *userDetails = @{
        @"username": self.user.username,
        @"latitude": lat,
        @"longitude": log,
        @"radius": rad,
    };
    
    return userDetails;
}

// Input: NSDictionary object, Output: NSData* with JSON format
- (NSData*)putDictionaryIntoJSON:(NSDictionary*)dict {
    // Create JSON Object
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:NSJSONWritingPrettyPrinted error:&error];
    return data;
}

- (IBAction)updateButtonClicked:(id)sender {
    // add logic when update button is clicked
    if ([self updateUser]) {
        [self updateUserToFirebase];
    }
}

// Update user currently assumes that the current Person object named user
// has the same name as what is in the username field
- (BOOL)updateUser {
    // Check if user already exists.
    // If they do, update the user object.
    // If they don't, alert user that the user doesn't exist
    // You have to create the same user that you update
    if (![self validateInput]) {
        self.errorView.hidden = FALSE;
        return false;
    } else {
        self.errorView.hidden = TRUE;
        if ([self.user.username isEqualToString:self.usernameTextField.text]) {
            // creates a new instance of user!
            // old should be deleted b/c no pointer!
            self.user = [[User alloc] initWithUser:self.username
                                            Radius:self.radius
                                          Latitude:self.latitude
                                         Longitude:self.longitude];
            return true;
        } else {
            self.errorView.hidden = FALSE;
            self.errorTextField.text = @"This user does not yet exist. Please create user first.";
            return false;
        }
    }
}

- (IBAction)statusButtonClicked:(UIButton *)sender {
    // 1 - Check that a user has been created in the first place
    // A user can only be created when the 'create' button is clocked
    // Perhaps the easiest way is to check that the self.user object is pointing to a non-nil object
    if ((self.user == nil)||(self.user.username != self.usernameTextField.text)) {
        self.errorView.hidden = FALSE;
        self.errorTextField.text = @"This user does not yet exist. Please create user first.";
    } else {
        self.errorView.hidden = TRUE;
        [self getJSONFromFirebase];
    }
    
    // Add this code when you can check the logic of what you need to check
}

-(void)checkChildLocationAndSegue {
    // compare child latitude and longitude with the parent set latitude and longitude
    /*
    To do this, use the built-in method
        - (CLLocationDistance)distanceFromLocation:(const CLLocation *)location
        to find the distance between the location the parent set and the child’s current location,
     and then check that it is less than the set radius. */
    CLLocation *child_location = [[CLLocation alloc] initWithLatitude:self.current_latitude
                                                            longitude:self.current_longitude];
    CLLocation *parent_location = [[CLLocation alloc] initWithLatitude:self.user.latitude
                                                             longitude:self.user.longitude];
  NSLog(@"%f,%f,%f,%f",self.current_latitude,self.current_longitude,self.user.latitude,self.user.longitude);
  
    self.distance = [parent_location distanceFromLocation:child_location];
  NSLog(@"%f",self.distance);
    
    if (self.distance <= self.user.radius) {
        [self performSegueWithIdentifier:@"okaySegue" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"notOkaySegue" sender:nil];
    }
}

-(void)getJSONFromFirebase {
    NSURL *url = [[NSURL alloc] withUserName:self.user.username];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:url];
    urlRequest.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *getJSON = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response,
                        NSError * _Nullable error) {
        NSError *get_error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingAllowFragments error:&get_error];
        if (([dict objectForKey:@"current_latitude"] == nil)
            ||([dict objectForKey:@"current_longitude"] == nil)) {
            [self showErrorView:FALSE withText:@"The child user has not reported their location"];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.errorView.hidden = TRUE;
            });
            NSString *lat = [dict objectForKey:@"current_latitude"];
            NSString *log = [dict objectForKey:@"current_longitude"];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.current_latitude = [lat doubleValue];
                self.current_longitude = [log doubleValue];
                [self checkChildLocationAndSegue];
            });
        }
    }];
    
    [getJSON resume];
}

-(void)showErrorView:(BOOL)state withText:(NSString*)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.errorView.hidden = state;
        self.errorTextField.text = text;
    });
}

- (IBAction)unwindForSegue:(UIStoryboardSegue *)unwindSegue
     towardsViewController:(UIViewController *)subsequentVC {
    
    // NO CODE HERE
    // VIEW CONTROLLER BUTTONS WOO HOO AND UH OH RETURN
    // BACK TO MAIN INPUT SCREEN
    // THROUGH EXIT SCREEN WITH UNWIND SEGUE
}

#pragma mark Form Validation Functions

// Returns TRUE if all input is validated.
// Returns FALSE if just one input is not validated.
// Sets instance properties self.radius,self.latitude,self.longitude and self.username
// to whatever strings and NSNumbers are extracted from the form, good or bad.
- (BOOL)validateInput {
    // First create strings from the input in each text field.
    self.username = self.usernameTextField.text;
    NSString* inputRadiusString = self.radiusTextField.text;
    NSString* inputLatitudeString = self.parentLatitudeTextFieldInput.text;
    NSString* inputLongitudeString = self.parentLongitudeTextFieldInput.text;
    
    NSNumberFormatter *num_formatter = [[NSNumberFormatter alloc] init];
    
    // Create NSNumbers from Strings created above
    // Why NSNumbers? Because if the strings can't be formatted into numbers,
    // NSNumber will be nil - this property is required in the next validation functions
    self.radius = [num_formatter numberFromString:inputRadiusString];
    self.latitude = [num_formatter numberFromString:inputLatitudeString];
    self.longitude = [num_formatter numberFromString:inputLongitudeString];
    
    // Check each field for correct validation
    // username - radius - latitude - longitude
    // returns true if all true
    // returns false is just one is false
    return (([self validateUsername:self.username])&&
    ([self validateRadius:self.radius])&&
    ([self validateLatitude:self.latitude])&&
            ([self validateLongitude:self.longitude]));
}

/* VALIDATION FUNCTIONS
 *
 * Each validate function will change the text in `errorTextField` to correspond
 * to the specific error made in validation. It will also change the color of the
 * label and text fieldthat is in error. If the form is correctly validated,
 * the function will change the color of both back to white as it was originally.
 */

// Checks if username is correctly input - AKA not blank or equal to nil
// If not, returns false and changes error message
// If true, returns true
-(BOOL)validateUsername:(NSString*)username {
    // Checks username for spaces (not allowed) or empty string, or nil.
    if ((([username containsString:@" "])||(username == nil))||([username isEqualToString:@""])) {
        self.errorTextField.text = @"Error: Please enter a valid Username";
        [self setLabelToErrorColor:self.usernameLabel andTextField:self.usernameTextField];
        return false;
    }
    [self setLabelToWhiteColor:self.usernameLabel andTextField:self.usernameTextField];
    return true;
}

// Input is NSNumber which was initialized by calling numberFromString on a String
// If the string is able to be formatted into a number, it will have done so
// Otherwise numberFromString returns nil - thats why the object is checked for equality to nil
-(BOOL)validateRadius:(NSNumber*)radius {
    if (radius == nil) {
        self.errorTextField.text = @"Error: Radius must be a valid numerical value";
        [self setLabelToErrorColor:self.radiusLabel andTextField:self.radiusTextField];
        return false;
    }
    [self setLabelToWhiteColor:self.radiusLabel andTextField:self.radiusTextField];
    return true;
}

// Input is NSNumber which was initialized by calling numberFromString on a String
// If the string is able to be formatted into a number, it will have done so
// Otherwise numberFromString returns nil - thats why the object is checked for equality to nil
-(BOOL)validateLatitude:(NSNumber*)latitude {
    if (latitude == nil) {
        self.errorTextField.text = @"Error: Latitude must be a valid numerical value";
        [self setLabelToErrorColor:self.zoneLatitudeLabel
                      andTextField:self.parentLatitudeTextFieldInput];
        return false;
    }
    [self setLabelToWhiteColor:self.zoneLatitudeLabel
                  andTextField:self.parentLatitudeTextFieldInput];
    return true;
}

// Input is NSNumber which was initialized by calling numberFromString on a String
// If the string is able to be formatted into a number, it will have done so
// Otherwise numberFromString returns nil - thats why the object is checked for equality to nil
-(BOOL)validateLongitude:(NSNumber*)longitude {
    if (longitude == nil) {
        self.errorTextField.text = @"Error: Longitude must be a valid numerical value";
        [self setLabelToErrorColor:self.zoneLongitudeLabel
                      andTextField:self.parentLongitudeTextFieldInput];
        return false;
    }
    [self setLabelToWhiteColor:self.zoneLongitudeLabel
                  andTextField:self.parentLongitudeTextFieldInput];
    return true;
}

#pragma mark Graphics Functions

-(void)setLabelToErrorColor:(UILabel*)label andTextField:(UITextField*)field {
    UIColor *errorColor = [self getErrorColor];
    label.textColor = errorColor;
    field.textColor = errorColor;
}

-(void)setLabelToWhiteColor:(UILabel*)label andTextField:(UITextField*)field{
    UIColor *white = [[UIColor alloc] initWithWhite:1.0 alpha:1.0];
    label.textColor = white;
    field.textColor = white;
}

-(UIColor*)getErrorColor {
    return [UIColor colorWithRed:0.95 green:0.51 blue:0.51 alpha:1.0];
}

// THIS FUNCTION TAKEN FROM STACK - OVERFLOW
// CONVERTS HEX STRING TO A UI COLOR OBJECT
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

// See Digital Leash PDF for look & feel
// Buttons should have rounded edges, and text input should be indented
-(void)finishUpdatingUI {
    [self createRoundedButtons];
    [self createIndentedTextInput];
}

// Creates rounded corners for buttons on main ViewController
-(void)createRoundedButtons {
    [self addRoundedCornersToButton:self.createButton];
    [self addRoundedCornersToButton:self.updateButton];
    [self addRoundedCornersToButton:self.statusButton];
}

-(void)addRoundedCornersToButton:(UIButton*)button {
    button.layer.cornerRadius = 20;
    button.clipsToBounds = YES;
}

// Helper function - calls a function to add indent for text fields on screen
-(void)createIndentedTextInput {
    [self addIndentToTextField:self.usernameTextField];
    [self addIndentToTextField:self.radiusTextField];
    [self addIndentToTextField:self.parentLongitudeTextFieldInput];
    [self addIndentToTextField:self.parentLatitudeTextFieldInput];
}

// This function adds a rectangle view on the left of the text input
// so that when the user starts typing, the flashing bar starts indented
// as is shown on the Digital Leash PDF example
-(void)addIndentToTextField:(UITextField*)textField {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10,40)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

@end
