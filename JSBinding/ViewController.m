//
//  ViewController.m
//  JSBinding
//
//  Created by huanglongshan on 2018/8/4.
//  Copyright © 2018年 huanglongshan. All rights reserved.
//

#import "ViewController.h"

#import "JSBindingVC.h"
#import "WebViewVC.h"
#import "WKWebViewVC.h"
#import "MessageHandlerVC.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSArray *aryDataSource;
@property(nonatomic,strong)NSMutableArray *aryVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _aryDataSource = @[@"JSBinding",@"webView",@"WKWebViewVC",@"MessageHandlerVC"];
    UITableView *tableView = [[UITableView alloc]init];
    [self.view addSubview:tableView];
    tableView.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    tableView.delegate=self;
    tableView.dataSource=self;
    
    _aryVC = [NSMutableArray array];
    
    
    JSBindingVC *jsVC= [[JSBindingVC alloc]init];
    [_aryVC addObject:jsVC];
    
    WebViewVC *webVC = [WebViewVC new];
    [_aryVC addObject:webVC];
    
    WKWebViewVC *WKwebVC = [WKWebViewVC new];
    [_aryVC addObject:WKwebVC];
    
    MessageHandlerVC *messageHandleVC = [MessageHandlerVC new];
    [_aryVC addObject:messageHandleVC];
}
    
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _aryDataSource.count;
}
    
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController pushViewController:_aryVC[indexPath.row] animated:NO];
    
}
    
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    cell.textLabel.text = _aryDataSource[indexPath.row];
    return cell;
}
    
    
    
    
    
    
    
    
    
    
    
  
    
    
    
    
    
    
    
    
    
    
    

@end
