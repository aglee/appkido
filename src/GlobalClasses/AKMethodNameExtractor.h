//
//  AKMethodNameExtractor.h
//  AppKiDo
//
//  Created by Andy Lee on 7/14/12.
//  Copyright (c) 2012 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
[agl] FIXME I need to write up real comments. For now, here's a description of the
feature from the AppKiDo 0.99 release notes. Basically, looks for top-level "elements".
If it finds some of the form "xyz:", it glues them together into a method name. Otherwise,
if the last top-level element looks like a unary method name, it returns that.

----

"Search for Method" examines the selected text and tries to figure out whether it contains an Objective-C message-send or method declaration. If so, it searches for that method name. Otherwise, it searches for the literal text you have selected.

In Xcode if you have [self flyToX:100 y:200 z:300], you can double-click one of the square brackets to select the whole expression and invoke this service. AppKiDo should search for the method name flyToX:y:z:.

If you happen to be in BBEdit and double-clicking a bracket selects the text inside the brackets, the service should still work. If there is leading whitespace or a cast, or comments anywhere, it should still work, so if you have a line like this you can triple-click to select the whole line, and then invoke the service.

    (void)[self flyToX:100 y:200 z:900];  // discard the return value

Note that "Search for Method" doesn't work if there is an assignment in the selected text. For example, it won't work if you select this line:

    BOOL didFly = [self flyToX:100 y:200 z:300];
The workaround is to select just the message-send -- the part after the "=".

Another intended use is when you're looking at code that declares a method and you want to search for that method name. For example, you can select these lines and it will search for browser:child:ofItem: (the "- (id)" will be ignored):

    - (id)browser:(NSBrowser *)browser
            child:(NSInteger)index
           ofItem:(id)item

This service assumes well-formed Objective-C. You might get unexpected results otherwise. If there are nested messages, it uses the top-level one. The algorithm mainly looks at punctuation -- delimiters like brackets and a few other characters that need special treatment. The basic idea is that it ignores anything between delimiters, like (blah blah blah), [blah blah blah], or {blah blah blah}. For this reason it should work if your selected code contains blocks or the new object literals.

The "Search" service tells AppKiDo to blindly search for whatever text you have selected in your active application. This service is provided as a fallback in case "Search for Method" doesn't work as you'd like. Really, though, "Search for Method" should work for all your search needs, even when you're not searching for a method.

If you use any of these new services, remember to assign hotkeys in System Preferences > Keyboard > Keyboard Shortcuts > Services for maximum convenience.

 */
@interface AKMethodNameExtractor : NSObject
{
@private
    char *_start;
    char *_current;
}

- (id)initWithString:(NSString *)string;

+ (NSString *)extractMethodNameFromString:(NSString *)string;
- (NSString *)extractMethodName;

@end
