//
//  ViewController.m
//  SMT_GCD_Demo
//
//  Created by Yang on 21/05/2018.
//  Copyright © 2018 SeaMoonTime. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView2;
@property(strong,nonatomic) NSCache *cache;

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

- (NSCache *)cache{
    if (!_cache) {
        _cache = [[NSCache alloc] init];
        // 设置成本为5 当存储的数据超过总成本数，NSCache会自动回收对象
        _cache.totalCostLimit = 5;
        // 设置代理 代理方法一般不会用到，一般是进行测试的时候使用
//        _cache.delegate = self;
    }
    return _cache;
}

- (IBAction)onDownLoadImage:(UIButton *)sender {
    
    [self downloadImageByGCD2];
}

//GCD download image
-(void)downloadImageByGCD{
    dispatch_queue_t queue = dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t mainqueue = dispatch_get_main_queue();
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        // 1. 获取图片 imageUrl
        NSURL *imageUrl = [NSURL URLWithString:@"https://img1.doubanio.com\/view\/celebrity\/s_ratio_celebrity\/public\/p56339.jpg"];
        // 2. 从 imageUrl 中读取数据(下载图片) -- 耗时操作
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        // 通过二进制 data 创建 image
        UIImage *image = [UIImage imageWithData:imageData];
        
        //回到主线程
        dispatch_async(mainqueue, ^{
            weakSelf.myImageView.image = image;
        });
    });
}

//GCD download images, use NSCache
-(void)downloadImageByGCD2{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainqueue = dispatch_get_main_queue();
    dispatch_group_t group = dispatch_group_create();
    
    NSString *url1 = @"https://img3.doubanio.com\/view\/celebrity\/s_ratio_celebrity\/public\/p1524453746.1.jpg";
    NSString *url2 = @"https://img3.doubanio.com\/view\/celebrity\/s_ratio_celebrity\/public\/p1501210489.33.jpg";
    
     __weak typeof(self) weakSelf = self;
    dispatch_group_async(group, queue, ^{
        // 1. 获取图片 imageUrl
        NSURL *imageUrl = [NSURL URLWithString:url1];
        // 2. 从 imageUrl 中读取数据(下载图片) -- 耗时操作
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        [weakSelf.cache setObject:imageData forKey:url1];
    });
    
    dispatch_group_async(group, queue, ^{
        // 1. 获取图片 imageUrl
        NSURL *imageUrl = [NSURL URLWithString:url2];
        // 2. 从 imageUrl 中读取数据(下载图片) -- 耗时操作
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        [weakSelf.cache setObject:imageData forKey:url2];
    });
    
    dispatch_group_notify(group, mainqueue, ^{
        NSLog(@"%@",weakSelf.cache.description);
        NSData *imageData1 = [weakSelf.cache objectForKey:url1];
        NSData *imageData2 = [weakSelf.cache objectForKey:url2];
        weakSelf.myImageView.image = [UIImage imageWithData:imageData1];
        weakSelf.myImageView2.image = [UIImage imageWithData:imageData2];
    });
    
}




@end
