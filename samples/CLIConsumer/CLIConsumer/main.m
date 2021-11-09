@import Foundation;
@import MySample;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString* str = MySample.new.print;
        printf("%s", [[@"Calling MySample: " stringByAppendingFormat: @"%@\n", str]  UTF8String]);
    }
    return 0;
}
