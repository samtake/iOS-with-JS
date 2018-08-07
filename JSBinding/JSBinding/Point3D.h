//
//  Point3D.h
//  JSBinding
//
//  Created by huanglongshan on 2018/8/4.
//  Copyright © 2018年 huanglongshan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


//定义协议,只有暴露在JSExport的方法js才可以操作
@protocol Point3DExport <JSExport>
@property double x;
@property double y;
@property double z;

-(double)length;

@end

@interface Point3D : NSObject <Point3DExport>{
    JSContext *context;
}
-(id)initWithContext:(JSContext *)ctx;

@end
