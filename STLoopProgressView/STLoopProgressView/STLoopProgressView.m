//
//  STLoopProgressView.m
//  STLoopProgressView
//
//  Created by TangJR on 6/29/15.
//  Copyright (c) 2015 tangjr. All rights reserved.
//

#import "STLoopProgressView.h"
#import "STLoopProgressView+BaseConfiguration.h"

#define SELF_WIDTH CGRectGetWidth(self.bounds)
#define SELF_HEIGHT CGRectGetHeight(self.bounds)

@interface STLoopProgressView ()

@property (strong, nonatomic) CAShapeLayer *colorMaskLayer; // 渐变色遮罩
@property (strong, nonatomic) CAShapeLayer *colorLayer; // 渐变色
@property (strong, nonatomic) CAShapeLayer *blueMaskLayer; // 蓝色背景遮罩
@property (strong, nonatomic) CAShapeLayer *waveLineLayer; // 波纹线遮罩
@property (nonatomic) NSUInteger numberOfWaves;
@property (nonatomic) CGFloat amplitude; //振幅
@property (nonatomic) CGFloat waveWidth;
@property (nonatomic) CGFloat density; //密度
@property (nonatomic) CGFloat waveMid;
@property (nonatomic) CGFloat maxAmplitude;
@property (nonatomic) CGFloat phase;
@property (nonatomic) CGFloat waveHeight;
@property (nonatomic) CGFloat phaseShift; //相移
@property (nonatomic) CGFloat idleAmplitude;
@property (nonatomic) CGFloat frequency;

@end

@implementation STLoopProgressView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = [STLoopProgressView backgroundColor];
    
    [self setupColorLayer];
//    [self setupColorMaskLayer];
//    [self setupBlueMaskLayer];
    [self setupWaveLineLayer];
}

/**
 *  设置波纹view的遮罩
 */
- (void)setupWaveLineLayer {
    _numberOfWaves = 4;
    _amplitude = 0.15;
    _waveWidth = SELF_WIDTH;
    _waveMid = _waveWidth / 2;
    _density = 1.0;
    _maxAmplitude = 90;
    _frequency = 1.2f;
    _phaseShift = -0.25f;
    _idleAmplitude = 0.01f;
    
    _waveLineLayer = [CAShapeLayer layer];
    _waveLineLayer.frame = self.bounds;
    _waveLineLayer.lineCap       = kCALineCapButt; //指定线的边缘
    _waveLineLayer.lineJoin      = kCALineJoinRound;
    _waveLineLayer.fillColor     = [[UIColor clearColor] CGColor]; //波纹的填充色
    [_waveLineLayer setLineWidth:3];
    _waveLineLayer.strokeColor = [STLoopProgressView centerColor].CGColor; //指定path的渲染颜色
//    switch (i) {
//        case 0:
//            [waveline setLineWidth:3];
//            waveline.strokeColor = [[UIColor colorFromHexString:@"#fcc080"] CGColor]; //指定path的渲染颜色
//            break;
//        case 1:
//            [waveline setLineWidth:2.5];
//            waveline.strokeColor = [[UIColor colorFromHexString:@"#ffb8b6" alpha:0.4] CGColor];
//            break;
//        case 2:
//            [waveline setLineWidth:2];
//            waveline.strokeColor = [[UIColor colorFromHexString:@"#fcc080"] CGColor];
//            break;
//        case 3:
//            [waveline setLineWidth:1.5];
//            waveline.strokeColor = [[UIColor colorFromHexString:@"#ffb8b6" alpha:0.4] CGColor];
//            break;
//        default:
//            break;
//    }
//    [self.layer addSublayer:_waveLineLayer];
    self.colorLayer.mask = _waveLineLayer;
//    self.layer.mask = _waveLineLayer;
}

/**
 *  设置整个蓝色view的遮罩
 */
- (void)setupBlueMaskLayer {
    CAShapeLayer *layer = [self generateMaskLayer];
    self.layer.mask = layer;
    self.blueMaskLayer = layer;
}

/**
 *  设置渐变色，渐变色由左右两个部分组成，左边部分由黄到绿，右边部分由黄到红
 */
- (void)setupColorLayer {
    self.colorLayer = [CAShapeLayer layer];
    self.colorLayer.frame = self.bounds;
    [self.layer addSublayer:self.colorLayer];

    CAGradientLayer *leftLayer = [CAGradientLayer layer];
    leftLayer.frame = CGRectMake(0, 0, SELF_WIDTH / 2, SELF_HEIGHT);
    // 分段设置渐变色
    leftLayer.locations = @[@0.3, @0.9, @1];
    leftLayer.colors = @[(id)[STLoopProgressView centerColor].CGColor, (id)[STLoopProgressView startColor].CGColor];
    [self.colorLayer addSublayer:leftLayer];
    
    CAGradientLayer *rightLayer = [CAGradientLayer layer];
    rightLayer.frame = CGRectMake(SELF_WIDTH / 2, 0, SELF_WIDTH / 2, SELF_HEIGHT);
    rightLayer.locations = @[@0.3, @0.9, @1];
    rightLayer.colors = @[(id)[STLoopProgressView centerColor].CGColor, (id)[STLoopProgressView endColor].CGColor];
    [self.colorLayer addSublayer:rightLayer];
}

/**
 *  设置渐变色的遮罩
 */
- (void)setupColorMaskLayer {
    CAShapeLayer *layer = [self generateMaskLayer];
    layer.lineWidth = [STLoopProgressView lineWidth] + 0.5; // 渐变遮罩线宽较大，防止蓝色遮罩有边露出来
    self.colorLayer.mask = layer;
    self.colorMaskLayer = layer;
}

/**
 *  生成一个圆环形的遮罩层
 *  因为蓝色遮罩与渐变遮罩的配置都相同，所以封装出来
 *
 *  @return 环形遮罩
 */
- (CAShapeLayer *)generateMaskLayer {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    
    // 创建一个圆心为父视图中点的圆，半径为父视图宽的2/5，起始角度是从-240°到60°
    
    UIBezierPath *path = nil;
    if ([STLoopProgressView clockWiseType]) {
        path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(SELF_WIDTH / 2, SELF_HEIGHT / 2) radius:SELF_WIDTH / 2.5 startAngle:[STLoopProgressView startAngle] endAngle:[STLoopProgressView endAngle] clockwise:YES];
    } else {
        path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(SELF_WIDTH / 2, SELF_HEIGHT / 2) radius:SELF_WIDTH / 2.5 startAngle:[STLoopProgressView endAngle] endAngle:[STLoopProgressView startAngle] clockwise:NO];
    }
    
    layer.lineWidth = [STLoopProgressView lineWidth];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor; // 填充色为透明（不设置为黑色）
    layer.strokeColor = [UIColor blackColor].CGColor; // 随便设置一个边框颜色
    layer.lineCap = kCALineCapRound; // 设置线为圆角
    return layer;
}

/**
 *  在修改百分比的时候，修改彩色遮罩的大小
 *
 *  @param persentage 百分比
 */
- (void)setPersentage:(CGFloat)persentage {
    _persentage = persentage;
    self.colorMaskLayer.strokeEnd = persentage;
    
    [self updateMaveLevel];
}

- (void)updateMaveLevel {
    _persentage = 0.5;
    self.phase += self.phaseShift; // Move the wave
    self.amplitude = fmax(_persentage, self.idleAmplitude);
    
    UIGraphicsBeginImageContext(self.frame.size);
    UIBezierPath *wavelinePath = [UIBezierPath bezierPath];
    
    // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
    
    int i = 0;
    CGFloat progress = 1.0f - (CGFloat)i / self.numberOfWaves;
    CGFloat normedAmplitude = (1.5f * progress - 0.5f) * self.amplitude;
    //        NSLog(@"progress:%f, self.amplitude:%f, normedAmplitude:%f", progress, self.amplitude, normedAmplitude);
    CAShapeLayer *waveline = _waveLineLayer;
    
    //x初始值依赖于self.frame.origin.x
    for (CGFloat x = self.frame.origin.x; x < self.waveWidth + self.density; x += self.density) {
        //Thanks to https://github.com/stefanceriu/SCSiriWaveformView
        // We use a parable to scale the sinus wave, that has its peak in the middle of the view.
        //缩放
        //double pow (double base, double exponent);求base的exponent次方值
        if (self.waveMid == 0) {
            continue;
        }
        CGFloat scaling = -pow(x / self.waveMid  - 1, 2) + 1; // make center bigger
        //sinf：计算正弦值和双曲线的正弦值
        CGFloat y = scaling * self.maxAmplitude * normedAmplitude * sinf(2 * M_PI *(x / self.waveWidth) * self.frequency + self.phase) + (self.waveHeight * 0.5);
        
        if (x == self.frame.origin.x) {
            /**
             *  设置第一个起始点到接收器
             *  @param point 起点坐标
             */
            [wavelinePath moveToPoint:CGPointMake(x, y)];
        } else {
            /**
             *  附加一条直线到接收器的路径
             *  @param point 要到达的坐标
             */
            [wavelinePath addLineToPoint:CGPointMake(x, y)];
        }
        waveline.path = [wavelinePath CGPath];
    }
    
    UIGraphicsEndImageContext();
}

@end