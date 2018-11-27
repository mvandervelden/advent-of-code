#import <Foundation/Foundation.h>

// Running:
// $ gcc -framework Foundation example.m -o example
// $ ./example [inputfilename]
// If no argument provided, it takes "input.txt"


@interface Solver: NSObject
- (NSString *)solve:(NSString *)inputFileName;
@end

@implementation Solver
- (NSString *)solve:(NSString *)inputFileName {
    NSString *input = [self readFile:inputFileName];
    //TODO solve
    return input;
}

- (NSString *)readFile:(NSString *)inputFileName {
    NSURL *currentDirectoryURL = [NSURL fileURLWithPath: NSFileManager.defaultManager.currentDirectoryPath];
    NSURL *url = [[NSURL alloc] initWithString: inputFileName relativeToURL: currentDirectoryURL];
    return [NSString stringWithContentsOfURL: url encoding: NSASCIIStringEncoding error: nil];
}
@end

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];

    NSString *filename;
    if (arguments.count > 1) {
        filename = arguments[1];
    } else {
        filename = @"input.txt";
    }

    Solver *solver = [Solver new];
    NSString *result = [solver solve:filename];
    NSLog(@"%@", result);

    [pool drain];
    return 0;
}
