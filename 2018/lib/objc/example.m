#import <Foundation/Foundation.h>

@interface Solver: NSObject
- (NSString *)solve: (NSString *)inputFileName;
@end

@implementation Solver
- (NSString *)solve: (NSString *)inputFileName {
    NSURL *currentDirectoryURL = [NSURL fileURLWithPath: NSFileManager.defaultManager.currentDirectoryPath];
    NSURL *url = [[NSURL alloc] initWithString: inputFileName relativeToURL: currentDirectoryURL];
    return [NSString stringWithContentsOfURL: url encoding: NSASCIIStringEncoding error: nil];
}
@end

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSString *filename = @"input.txt";
    Solver *solver = [Solver new];
    NSLog(@"%@", [solver solve:filename]);

    [pool drain];
    return 0;
}
