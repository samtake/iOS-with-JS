//
//  WebViewVC.m
//  JSBinding
//
//  Created by huanglongshan on 2018/8/5.
//  Copyright © 2018年 huanglongshan. All rights reserved.
//




#import "WebViewVC.h"
#import <AVFoundation/AVFoundation.h>

@interface WebViewVC ()<UIWebViewDelegate>
    
@property (strong, nonatomic) UIWebView *webView;

@end

@implementation WebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"JS与原生交互：UIWebView";
    //.创建UIWebView，并加载本地HTML(兼容iOS6使用UIWebView)
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor yellowColor];

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"index1"
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    [self.webView loadHTMLString:htmlCont baseURL:baseURL];




    /**说明
     1.为什么自定义一个loadURL 方法，不直接使用window.location.href?
     答：因为如果当前网页正使用window.location.href加载网页的同时，调用window.location.href去调用OC原生方法，会导致加载网页的操作被取消掉。
     同样的，如果连续使用window.location.href执行两次OC原生调用，也有可能导致第一次的操作被取消掉。所以我们使用自定义的loadURL，来避免这个问题。
     loadURL的实现来自关于UIWebView和PhoneGap的总结一文。
     2.为什么loadURL 中的链接，使用统一的scheme?
     答:便于在OC 中做拦截处理，减少在JS中调用一些OC 没有实现的方法时，webView 做跳转。因为我在OC 中拦截URL 时，根据scheme (即haleyAction)来区分是调用原生的方法还是正常的网页跳转。然后根据host（即//后的部分getLocation）来区分执行什么操作。
     3.为什么自定义一个asyncAlert方法？
     答：因为有的JS调用是需要OC 返回结果到JS的。stringByEvaluatingJavaScriptFromString是一个同步方法，会等待js 方法执行完成，而弹出的alert 也会阻塞界面等待用户响应，所以他们可能会造成死锁。导致alert 卡死界面。如果回调的JS 是一个耗时的操作，那么建议将耗时的操作也放入setTimeout的function 中。
     */

}


#pragma mark - UIWebViewDelegate
    /**UIWebView 有一个代理方法，可以拦截到每一个链接的Request。return YES,webView 就会加载这个链接；return NO,webView 就不会加载这个连接*/
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
    {
        NSURL *URL = request.URL;
        NSString *scheme = [URL scheme];
        if ([scheme isEqualToString:@"haleyaction"]) {
            [self handleCustomAction:URL];
            return NO;
        }
        return YES;
    }



    - (void)webViewDidFinishLoad:(UIWebView *)webView
    {
        [webView stringByEvaluatingJavaScriptFromString:@"var arr = [3, 4, 'abc'];"];
    }





#pragma mark - private method
- (void)handleCustomAction:(NSURL *)URL
    {
        NSString *host = [URL host];
        if ([host isEqualToString:@"scanClick"]) {
            NSLog(@"扫一扫");
        } else if ([host isEqualToString:@"shareClick"]) {
            [self share:URL];
        } else if ([host isEqualToString:@"getLocation"]) {
            [self getLocation];
        } else if ([host isEqualToString:@"setColor"]) {
            [self changeBGColor:URL];
        } else if ([host isEqualToString:@"payAction"]) {
            [self payAction:URL];
        } else if ([host isEqualToString:@"shake"]) {
            [self shakeAction];
        } else if ([host isEqualToString:@"goBack"]) {
            [self goBack];
        }
    }


    - (void)getLocation
    {
        // 获取位置信息

        // 将结果返回给js
        NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')",@"广东省深圳市南山区学府路XXXX号"];
        [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
    }


#pragma mark - JS 传参到 OC
    /**
     当然，有时候我们在JS中调用OC 方法的时候，也需要传参数到OC 中，怎么传呢？
     就像一个get 请求一样，把参数放在后面：
     function shareClick() {
     loadURL("haleyAction://shareClick?title=测试分享的标题&content=测试分享的内容&url=http://www.baidu.com");
     }
     */
#pragma mark -  OC 获取JS参数
    /**
     那么如果获取到这些参数呢?
     所有的参数都在URL的query中，先通过&将字符串拆分，在通过=把参数拆分成key 和实际的值。下面有示例代码：
     */
    - (void)share:(NSURL *)URL
    {
        NSArray *params =[URL.query componentsSeparatedByString:@"&"];

        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for (NSString *paramStr in params) {
            NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
            if (dicArray.count > 1) {
                NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [tempDic setObject:decodeValue forKey:dicArray[0]];
            }
        }

        NSString *title = [tempDic objectForKey:@"title"];
        NSString *content = [tempDic objectForKey:@"content"];
        NSString *url = [tempDic objectForKey:@"url"];
        // 在这里执行分享的操作

        // 将分享结果返回给js
        NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
        [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
    }





    - (void)changeBGColor:(NSURL *)URL
    {
        NSArray *params =[URL.query componentsSeparatedByString:@"&"];

        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for (NSString *paramStr in params) {
            NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
            if (dicArray.count > 1) {
                NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [tempDic setObject:decodeValue forKey:dicArray[0]];
            }
        }
        CGFloat r = [[tempDic objectForKey:@"r"] floatValue];
        CGFloat g = [[tempDic objectForKey:@"g"] floatValue];
        CGFloat b = [[tempDic objectForKey:@"b"] floatValue];
        CGFloat a = [[tempDic objectForKey:@"a"] floatValue];

        self.view.backgroundColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
    }



    - (void)payAction:(NSURL *)URL
    {
        NSArray *params =[URL.query componentsSeparatedByString:@"&"];

        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for (NSString *paramStr in params) {
            NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
            if (dicArray.count > 1) {
                NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [tempDic setObject:decodeValue forKey:dicArray[0]];
            }
        }
        //    NSString *orderNo = [tempDic objectForKey:@"order_no"];
        //    long long amount = [[tempDic objectForKey:@"amount"] longLongValue];
        //    NSString *subject = [tempDic objectForKey:@"subject"];
        //    NSString *channel = [tempDic objectForKey:@"channel"];

        // 支付操作

#pragma mark - 将支付结果返回给js
        NSUInteger code = 1;
        NSString *jsStr = [NSString stringWithFormat:@"payResult('%@',%lu)",@"支付成功",(unsigned long)code];
        [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
    }

#pragma mark - OC调用JS方法 关于将OC 执行结果返回给JS stringByEvaluatingJavaScriptFromString

    /**
     如果回调执行的JS 方法带参数，而参数不是字符串时，不要加单引号,否则可能导致调用JS 方法失败。比如我这样的：
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userProfile options:NSJSONWritingPrettyPrinted error:nil];
     NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     NSString *jsStr = [NSString stringWithFormat:@"loginResult('%@',%@)",type, jsonStr];
     [_webView stringByEvaluatingJavaScriptFromString:jsStr];

     如果第二个参数用单引号包起来，就会导致JS端的loginResult不会调用。

     另外，利用[webView stringByEvaluatingJavaScriptFromString:@"var arr = [3, 4, 'abc'];"];,可以往HMTL的JS环境中插入全局变量、JS方法等。
     */



    - (void)shakeAction
    {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }

- (void)goBack
    {
        [self.webView goBack];
    }



@end
