//
//  SMTTableViewController.m
//  SMT_GCD_Demo2
//
//  Created by Yang on 25/05/2018.
//  Copyright © 2018 SeaMoonTime. All rights reserved.
//

#import "SMTTableViewController.h"
#import "SMTTableViewCell.h"

@interface SMTTableViewController ()

@property(copy, nonatomic)NSArray *urls;
@property(strong,nonatomic)NSCache *imageCache;
@property(assign,nonatomic)BOOL bDownLoadSuccess;

@end

@implementation SMTTableViewController
{
    dispatch_semaphore_t semaphoreLock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"DataList" ofType:@"plist"];
    self.urls = [[NSArray alloc]initWithContentsOfFile:plistPath];
    self.bDownLoadSuccess = false;
//    NSLog(@"%@",_urls.description);
    [self downloadImages];
}

- (NSCache *)imageCache{
    if (!_imageCache) {
        _imageCache = [[NSCache alloc]init];
        _imageCache.totalCostLimit = 15;
    }
    return _imageCache;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _urls.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"smtcell" forIndexPath:indexPath];
    
    if (!_bDownLoadSuccess) {
        cell.smtImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
    } else {
        NSString *url = _urls[indexPath.row];
        NSData *imageData = [_imageCache objectForKey:url];
        if (imageData) {
             cell.smtImageView.image = [UIImage imageWithData:imageData];
        } else {
            cell.smtImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
        }
       
    }
   
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - download images
-(void)downloadImages{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainqueue = dispatch_get_main_queue();
    dispatch_group_t group = dispatch_group_create();
    
    semaphoreLock = dispatch_semaphore_create(1);
    
    __weak typeof(self) weakSelf = self;
    
    for (NSString *urlStr in _urls) {
        dispatch_group_async(group, queue, ^{
            // 相当于加锁
            dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
            // 1. 获取图片 imageUrl
            NSURL *imageUrl = [NSURL URLWithString:urlStr]; //网址中如有“\”等符号，可能会出错，NSURL变量无法生成
            // 2. 从 imageUrl 中读取数据(下载图片) -- 耗时操作
            NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];

            if (imageData) {
                [weakSelf.imageCache setObject:imageData forKey:urlStr];
                NSLog(@"url=%@",urlStr);
            }

            // 相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
        });
    }
    
    dispatch_group_notify(group, mainqueue, ^{
        NSLog(@"%@",weakSelf.imageCache.description);
        _bDownLoadSuccess = true;
        [self.tableView reloadData];
    });
}


@end
