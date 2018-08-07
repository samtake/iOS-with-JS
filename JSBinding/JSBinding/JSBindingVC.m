//
//  JSBindingVC.m
//  JSBinding
//
//  Created by huanglongshan on 2018/8/5.
//  Copyright © 2018年 huanglongshan. All rights reserved.
//

#import "JSBindingVC.h"
#import <JavaScriptCore/JavaScriptCore.h> //（iOS 7推出的）
#import "Point3D.h"
@interface JSBindingVC ()

@end

@implementation JSBindingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"JS与原生交互：JSBinding";
    //创建js上下文
    JSContext *context = [[JSContext alloc]init];
    //js的异常是不会引起OC的异常的，可以wei上下文启动一个异常处理器
    context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"%@",exception);
    };
    
    
    NSString *script ;
    JSValue * result;
    
    //要执行的js代码
    script = @"1+2+3";
    result = [context evaluateScript:script];
    NSLog(@"%@ = %f",script,[result toDouble]);
    
    
    //获取变量值
    script = @"var globalVar = 2*5";
    result = [context evaluateScript:script];
    NSLog(@"globalVar = %@",context[@"globalVar"]);
    
    
    //获取函数
    script = @"function sum(a,b){return a+b;}";
    [context evaluateScript:script];
    JSValue *sum = context[@"sum"];
    result = [sum callWithArguments:@[@1,@9]];
    NSLog(@"sum=%f",[result toDouble]);
    
    //通过不同OC类型创建js对象
    JSValue *foo = [JSValue valueWithDouble:12222.44 inContext:context];
    context[@"foo"] = foo;
    [context evaluateScript:@"foo++;"];
    NSLog(@"foo = %f",[context[@"foo"] toDouble]);
    
    
    //js调用原生代码
    //block
    context[@"sum"] = ^(int a, int b){
        return a + b;
    };
    script = @"sum(1,2)";
    result = [context evaluateScript:script];
    NSLog(@"sum(1,2) = %f",[result toDouble]);
    //解决block不能调用外部OC参数（定义在block之外的）      JSContext *ctx = [JSContext currentContext];
    //动态获取变量参数      NSArray *ary = [JSContext currentArguments];
    
    
    //JSExport
    Point3D *point3D = [[Point3D alloc]initWithContext:context];
    point3D.x = 1 ;
    point3D.y = 2 ;
    point3D.z = 3 ;
    context[@"point3D"] = point3D ;
    script = @"point3D.y = 4 ;point3D.z = 2 ;point3D.length()";
    result = [context evaluateScript:script];
    NSLog(@"point3D.length() = %f",[result toDouble]);
    
    
    //补充
    //读取html文件
    //OC对象和技术对象的相互引用，处理方法：JSVaalueManager
}


@end
