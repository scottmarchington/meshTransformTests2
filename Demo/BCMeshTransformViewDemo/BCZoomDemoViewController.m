//
//  BCZoomDemoViewController.m
//  BCMeshTransformViewDemo
//
//  Created by Bartosz Ciechanowski on 11/05/14.
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import "BCZoomDemoViewController.h"
#import "BCMeshTransformView.h"
#import "BCMeshTransform+DemoTransforms.h"

@interface BCZoomDemoViewController ()

@end

@implementation BCZoomDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture.jpg"]];
    imageView.center = CGPointMake(CGRectGetMidX(self.transformView.contentView.bounds),
                                   CGRectGetMidY(self.transformView.contentView.bounds));
    
    [self.transformView.contentView addSubview:imageView];
    
    // we don't want any shading on this one
    self.transformView.diffuseLightFactor = 0.7;
    
//    self.transformView.meshTransform = [BCMeshTransform meltTransformIdentity];
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateMelt)];
    
    self.transformView.meshTransform = [BCMeshTransform dripTransformIdentity];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateDrip)];
    
    [self.view addGestureRecognizer:tapGR];
}

- (void)animateMelt
{
    BCMeshTransform *meltTransform = [BCMeshTransform meltTransform];
    [UIView animateWithDuration:5 animations:^{
        self.transformView.meshTransform = meltTransform;
    }];
}

- (void)animateDrip
{
    BCMeshTransform *dripTransform = [BCMeshTransform dripTransform];
    [UIView animateWithDuration:0.5 animations:^{
        self.transformView.meshTransform = dripTransform;
    }];
}

@end
