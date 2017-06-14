//
//  ViewController.m
//  GIFDemo
//
//  Created by Xu Chen on 2017/5/25.
//  Copyright © 2017年 Xu Chen. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+GIF.h"
#import "GifView.h"

#import <Photos/Photos.h>
#import "NSGIF.h"


@interface ViewController ()<UIImagePickerControllerDelegate>

@end

@implementation ViewController
{
    NSString *_path;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeNSGIF];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(200, 50, 50, 50);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(makeViode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)makeGif{
    //gif的制作
    
    //获取源数据image
    NSMutableArray *imgs = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"clock01.png"],[UIImage imageNamed:@"clock02.png"],[UIImage imageNamed:@"clock03.png"],[UIImage imageNamed:@"clock04.png"],[UIImage imageNamed:@"clock05.png"],[UIImage imageNamed:@"clock06.png"], nil];
    
    //图像目标
    CGImageDestinationRef destination;
    
    //创建输出路径
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentStr = [document objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *textDirectory = [documentStr stringByAppendingPathComponent:@"gif"];
    [fileManager createDirectoryAtPath:textDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    _path = [textDirectory stringByAppendingPathComponent:@"test01.gif"];
    
    
   
    
    //创建CFURL对象
    /*
     CFURLCreateWithFileSystemPath(CFAllocatorRef allocator, CFStringRef filePath, CFURLPathStyle pathStyle, Boolean isDirectory)
     
     allocator : 分配器,通常使用kCFAllocatorDefault
     filePath : 路径
     pathStyle : 路径风格,我们就填写kCFURLPOSIXPathStyle 更多请打问号自己进去帮助看
     isDirectory : 一个布尔值,用于指定是否filePath被当作一个目录路径解决时相对路径组件
     */
    CFURLRef url = CFURLCreateWithFileSystemPath (
                                                  kCFAllocatorDefault,
                                                  (CFStringRef)_path,
                                                  kCFURLPOSIXPathStyle,
                                                  false);
    
    //通过一个url返回图像目标
    destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, imgs.count, NULL);
    
    //设置gif的信息,播放间隔时间,基本数据,和delay时间
    NSDictionary *frameProperties = [NSDictionary
                                     dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.5], (NSString *)kCGImagePropertyGIFDelayTime, nil]
                                     forKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    //设置gif信息
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [dict setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
    
    [dict setObject:(NSString *)kCGImagePropertyColorModelRGB forKey:(NSString *)kCGImagePropertyColorModel];
    
    [dict setObject:[NSNumber numberWithInt:8] forKey:(NSString*)kCGImagePropertyDepth];
    
    [dict setObject:[NSNumber numberWithInt:2] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:dict
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];
    //合成gif
    for (UIImage* dImg in imgs)
    {
        CGImageDestinationAddImage(destination, dImg.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    
    NSLog(@"打印合成的gif地址%@",_path);
    
    //加载保存在本地的gif图片
    UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    UIImage *image = [UIImage sd_animatedGIFNamed:_path];
    view.image = image;
    [self.view addSubview:view];
    GifView *dataView2 = [[GifView alloc] initWithFrame:CGRectMake(100, 300, 100, 100) filePath:_path];
    [self.view addSubview:dataView2];
    
    

}

-(void)makeNSGIF{
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(100, 400, 200, 200)];
    [self.view addSubview:self.webView];
    
    NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"]];
    [NSGIF optimalGIFfromURL:videoURL loopCount:0 completion:^(NSURL *GifURL) {
        
        NSLog(@"Finished generating GIF: %@", GifURL);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.webView.alpha = 1.0f;
        }];
        [self.webView loadRequest:[NSURLRequest requestWithURL:GifURL]];
    }];

}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *url = info[UIImagePickerControllerMediaURL];
    if (url){
        
        
        [NSGIF optimalGIFfromURL:url loopCount:0 completion:^(NSURL *GifURL) {
            
            NSLog(@"Finished generating GIF: %@", GifURL);
            
            [UIView animateWithDuration:0.3 animations:^{
                self.webView.alpha = 1.0f;
            }];
            [self.webView loadRequest:[NSURLRequest requestWithURL:GifURL]];
            
            UIAlertView *alert;
            if (GifURL)
                alert = [[UIAlertView alloc] initWithTitle:@"Yaay!" message:@"You successfully created your GIF!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            else
                alert = [[UIAlertView alloc] initWithTitle:@"Ooops!" message:@"Hmm... Something went wrong here!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
}
-(void)makeViode{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = @[(NSString *)kUTTypeMovie];
        
        // Present the picker
        [self presentViewController:picker animated:YES completion:nil];
    });
}
@end
