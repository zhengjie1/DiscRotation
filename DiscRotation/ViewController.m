//
//  ViewController.m
//  DiscRotation
//
//  Created by as on 15/3/31.
//  Copyright (c) 2015年 as. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UIImageView *mDiscBG;
    UIImageView *mDiscImage;
    
    UIButton *startButton;
    
    UIImageView * mPointerImage;

    
    NSInteger mAngle;
    NSTimer *mRunTimer;
    NSMutableArray *mMoveRotate;
    UIImage *mTempImage;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    mDiscImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Roulette"]];
    mDiscImage.center = CGPointMake(160, 400);
    mDiscBG = [[UIImageView alloc] initWithImage:[self grayImage:mDiscImage.image]];
    mDiscBG.frame = mDiscImage.frame;

    mTempImage = [UIImage imageNamed:@"Roulette"];

    mPointerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pointer"]];
    mPointerImage.center = CGPointMake(mDiscImage.frame.size.width/2, mDiscImage.frame.origin.y + mDiscImage.frame.size.height);
    
    mPointerImage.transform=CGAffineTransformMakeRotation(-M_PI*90/180);
    
    [self.view addSubview:mDiscBG];
    [self.view addSubview:mDiscImage];
    [self.view addSubview:mPointerImage];

    startButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 150, 220, 50)];
    [startButton addTarget:self action:@selector(onStartAction) forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:@"start" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:startButton];
    
    mAngle = 0;

    mMoveRotate = [[NSMutableArray alloc] initWithArray:@[]];
    mDiscImage.image = [self SectorMask:mTempImage Angle:mAngle];

}

-(void)viewWillAppear:(BOOL)animated
{
}

-(void)onStartAction
{
    NSInteger num = (arc4random() % 180)+1;
    mAngle = 0;
    [self RotationAngle:num];
}

-(UIImage *)grayImage:(UIImage *)sourceImage
{
    CGSize SourceImageSize = CGSizeMake(320, 320);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(nil, SourceImageSize.width, SourceImageSize.height, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    CGContextDrawImage(context, CGRectMake(0, 0, SourceImageSize.width, SourceImageSize.height), [sourceImage CGImage]);
    
    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    context = CGBitmapContextCreate(nil, SourceImageSize.width , SourceImageSize.height, 8, 0, nil, kCGImageAlphaOnly | kCGBitmapByteOrderDefault);
    CGContextDrawImage(context, CGRectMake(0, 0, SourceImageSize.width, SourceImageSize.height), [sourceImage CGImage]);
    CGImageRef mask = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *grayImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImageRef, mask) scale:sourceImage.scale orientation:sourceImage.imageOrientation];
    CGImageRelease(grayImageRef);
    CGImageRelease(mask);
    
    return grayImage;
}

-(void)RotationAngle:(NSInteger) angle
{
    NSInteger _moveAngle = angle - mAngle;
    NSInteger _AbsoluteMoveAngle = ABS(_moveAngle);
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:@[]];
    for(NSInteger i =0; i<_AbsoluteMoveAngle/2;i++)
    {
        CGFloat f = [self easeOutBack:i b:0 c:_AbsoluteMoveAngle d:_AbsoluteMoveAngle/2];
        
        NSNumber *anumber = [NSNumber numberWithInteger:f];
        [tempArray addObject:anumber];
    }
    
    NSArray* reversedArray = [[tempArray reverseObjectEnumerator] allObjects];
    [mMoveRotate setArray:reversedArray];
    mRunTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(changeImage:) userInfo:nil repeats:YES];
}

-(UIImage *)SectorMask:(UIImage *) sourceImage Angle:(NSInteger) angle
{
    if(angle>179)
        angle = 179;
    angle = 180 - angle%180;
    
    
    CGFloat DValue;
    if(angle <40)
    {
        DValue = 90 + angle/2;
    }else if(39<angle && angle<70)
    {
        DValue = 110;
    }else if(69<angle && angle<90)
    {
        DValue = 110 - (angle-68);
    }else if(89 <angle && angle<110)
    {
        DValue = 90 - (angle-89);
    }else if(109<angle && angle<140)
    {
        DValue = 70;
    }else if(139<angle && angle<181)
    {
        DValue = 70 + (angle - 139)/2;
    }
    
    
    mPointerImage.transform=CGAffineTransformMakeRotation(-M_PI*(angle - DValue)/180);
    
    CGSize SourceImageSize = CGSizeMake(320, 320);
    CGPoint cenetPoint = CGPointMake(160, 0);
    CGFloat radius = 320;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(nil, SourceImageSize.width, SourceImageSize.height, 8, 0, colorSpace, 2);
    CGColorSpaceRelease(colorSpace);
    
    CGContextMoveToPoint(context, cenetPoint.x, cenetPoint.y);
    
    CGContextSetFillColor(context, CGColorGetComponents( [[UIColor yellowColor] CGColor]));
    
    CGContextAddArc(context, cenetPoint.x, cenetPoint.y, radius,  0, angle*(M_PI/180), 0);
    CGContextFillPath(context);
    
    CGImageRef sectorMask = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    CGImageRef maskRef = sectorMask;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    UIImage *sectorMaskImage = [UIImage imageWithCGImage:CGImageCreateWithMask([sourceImage CGImage], mask)];
    
    return sectorMaskImage;
}

-(CGFloat)easeOutBack:(CGFloat) t b:(CGFloat) b c:(CGFloat) c d:(CGFloat) d
{
    CGFloat s = 1.8;
    t= t/d - 1;
    return c*(t*t*((s+1)*t + s) + 1) + b;
}


- (void)changeImage: (NSTimer *)timer
{
    if([mMoveRotate count]>0)
    {
        mAngle = [[mMoveRotate lastObject] integerValue];
        [mMoveRotate removeLastObject];
        mDiscImage.image = [self SectorMask:mTempImage Angle:mAngle];
    }else{
        [mRunTimer invalidate];
    }
}
@end
