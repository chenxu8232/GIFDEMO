//
//  UIImage+GIF.h
//  GIFDemo
//
//  Created by Xu Chen on 2017/5/25.
//  Copyright © 2017年 Xu Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GIF)

//加载保存在本地的gif图片
+ (UIImage *)sd_animatedGIFNamed:(NSString *)name;

//获取到图片的data后重新构造一张可以播放的图片
+ (UIImage *)sd_animatedGIFWithData:(NSData *)data;

//图片按照指定的尺寸缩放
- (UIImage *)sd_animatedImageByScalingAndCroppingToSize:(CGSize)size;

@end
