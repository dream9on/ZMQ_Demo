/* ZMQHelper.h: Helper methods. */
#import <Foundation/Foundation.h>

// Returns a random integer within the range [0, i).
static inline int within(int i);

@interface ZMQHelper : NSObject


+ (NSString*) createUuidString;
+(NSDictionary *) translateStringToDict:(NSString *)str;
+(NSString *) translateDictToString:(NSDictionary *)dic;

@end

static inline int
within(int i) {
	float frac = ((float)RAND_MAX - random()) / RAND_MAX;
	return i * frac;
}
