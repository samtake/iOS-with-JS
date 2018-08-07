//
//  Point3D.m
//  JSBinding
//
//  Created by huanglongshan on 2018/8/4.
//  Copyright © 2018年 huanglongshan. All rights reserved.
//

#import "Point3D.h"

@implementation Point3D
    @synthesize x;
    @synthesize y;
    @synthesize z;
    
    
-(id)initWithContext:(JSContext *)ctx{
    if (self = [super  init]) {
        context = ctx;
        context[@"Point3D"] = [Point3D class];
    }
    return self;
}
    -(double)length {
        return sqrt(self.x*self.x + self.y*self.y + self.z*self.z);
    }
@end
