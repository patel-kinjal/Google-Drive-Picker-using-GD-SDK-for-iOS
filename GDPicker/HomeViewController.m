//
//  HomeViewController.m
//  GDPicker
//
//  Created by Kinjal Patel on 11/07/17.
//  Copyright © 2017 Kinjal Patel. All rights reserved.
//

#import "HomeViewController.h"
#import "GDPickerViewController.h"

@interface HomeViewController () <GDPickerDelegate>

@end

@implementation HomeViewController

#pragma mark - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentImageView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Action Methods

- (IBAction)signInButtonTapped:(id)sender {

    GDPickerViewController *picker=[[GDPickerViewController alloc]init];
    picker.gdPickerDelegate=self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - GDPickerView Delgate Methods

-(void) gd_filePickerViewController:(GDPickerViewController*) pickerVC didFinishSelectingFile:(GTLRDrive_File*) file {

    [self.contentImageView setHidden:NO];
    self.contentImageView.image = file.contentImage;
    [[GIDSignIn sharedInstance] signOut];
    [pickerVC dismissViewControllerAnimated:YES completion:NULL];
}

@end
