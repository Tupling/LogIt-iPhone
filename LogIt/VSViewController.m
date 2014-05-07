//
//  VSViewController.m
//  LogIt
//
//  Created by Dale Tupling on 5/5/14.
//  Copyright (c) 2014 Dale Tupling. All rights reserved.
//

#import "VSViewController.h"

@interface VSViewController () <UITextFieldDelegate>
@property (nonatomic, retain) PFSignUpViewController *signUpController;

@end

@implementation VSViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];

  
}

-(void)viewWillAppear:(BOOL)animated
{

    PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
    logInController.delegate = self;
    [self presentViewController:logInController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
