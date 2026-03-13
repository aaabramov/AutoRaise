/*
 * AutoRaise - Copyright (C) 2026 aaabramov
 * Some pieces of the code are based on
 * sbmpost by sbmpost as part of https://github.com/sbmpost/AutoRaise
 * metamove by jmgao as part of XFree86
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "AutoRaise.h"

@implementation ConfigClass
- (NSString *) getFilePath:(NSString *) filename {
    filename = [NSString stringWithFormat: @"%@/%@", NSHomeDirectory(), filename];
    if (not [[NSFileManager defaultManager] fileExistsAtPath: filename]) { filename = NULL; }
    return filename;
}

- (void) readConfig:(int) argc {
    // Always read config file first as a base
    [self readHiddenConfig];

    // CLI arguments (e.g. -delay 3) override config file values.
    // Only check NSArgumentDomain to avoid picking up registered defaults.
    if (argc > 1) {
        NSDictionary *arguments = [[NSUserDefaults standardUserDefaults]
            volatileDomainForName: NSArgumentDomain];

        for (id key in parametersDictionary) {
            id arg = arguments[key];
            if (arg != NULL) {
                NSLog(@"CLI override: %@ = %@", key, arg);
                parameters[key] = arg;
            }
        }
    }
    NSLog(@"Config result: delay=%@, warpX=%@, warpY=%@, scale=%@, scaleDuration=%@",
        parameters[kDelay], parameters[kWarpX], parameters[kWarpY],
        parameters[kScale], parameters[kScaleDuration]);
    return;
}

- (void) readHiddenConfig {
    // search for dotfiles
    NSString * hiddenConfigFilePath = [self getFilePath: @".AutoRaise"];
    if (!hiddenConfigFilePath) { hiddenConfigFilePath = [self getFilePath: @".config/AutoRaise/config"]; }

    if (hiddenConfigFilePath) {
        NSLog(@"Reading config from: %@", hiddenConfigFilePath);
        NSError * error;
        NSString * configContent = [[NSString alloc]
            initWithContentsOfFile: hiddenConfigFilePath
            encoding: NSUTF8StringEncoding error: &error];

        NSArray * configLines = [configContent componentsSeparatedByString: @"\n"];
        NSString * trimmedLine, * trimmedKey, * trimmedValue, * noQuotesValue;
        NSArray * components;
        for (NSString * line in configLines) {
            trimmedLine = [line stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            if (not [trimmedLine hasPrefix: @"#"]) {
                components = [trimmedLine componentsSeparatedByString: @"="];
                if ([components count] == 2) {
                    for (id key in parametersDictionary) {
                       trimmedKey = [components[0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                       trimmedValue = [components[1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                       noQuotesValue = [trimmedValue stringByReplacingOccurrencesOfString: @"\"" withString: @""];
                       if ([trimmedKey isEqual: key]) { parameters[key] = noQuotesValue; }
                    }
                }
            }
        }
    }
    return;
}

- (void) validateParameters {
    // validate and fix wrong/absent parameters
    if (!parameters[kDelay]) { parameters[kDelay] = @"1"; }
#ifdef FOCUS_FIRST
    if (!parameters[kFocusDelay]) { parameters[kFocusDelay] = @"1"; }
#endif
    if (!parameters[kRequireMouseStop]) { parameters[kRequireMouseStop] = @"true"; }
    if ([parameters[kPollMillis] intValue] < 20) { parameters[kPollMillis] = @"50"; }
    if ([parameters[kMouseDelta] floatValue] < 0) { parameters[kMouseDelta] = @"0"; }
    if ([parameters[kScale] floatValue] < 1) { parameters[kScale] = @"2.0"; }
    if (!parameters[kDisableKey]) { parameters[kDisableKey] = @"control"; }
    if ([parameters[kScaleDuration] intValue] < 200) { parameters[kScaleDuration] = @"600"; }
    if (!parameters[kWarpX]) { parameters[kWarpX] = @"0.5"; }
    if (!parameters[kWarpY]) { parameters[kWarpY] = @"0.5"; }
    warpMouse =
        [parameters[kWarpX] floatValue] > 0 && [parameters[kWarpX] floatValue] <= 1 &&
        [parameters[kWarpY] floatValue] > 0 && [parameters[kWarpY] floatValue] <= 1;
#ifdef ALTERNATIVE_TASK_SWITCHER
    if (!parameters[kAltTaskSwitcher]) { parameters[kAltTaskSwitcher] = @"true"; }
#endif
#ifdef FOCUS_FIRST
    if (![parameters[kDelay] intValue] && !parameters[kFocusDelay]) { parameters[kFocusDelay] = @"1"; }
    if (!parameters[kDelay] && ![parameters[kFocusDelay] intValue]) { parameters[kDelay] = @"1"; }
#endif
    return;
}
@end // ConfigClass
