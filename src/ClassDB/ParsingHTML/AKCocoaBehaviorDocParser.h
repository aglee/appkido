/*
 * AKCocoaBehaviorDocParser.h
 *
 * Created by Andy Lee on Thu Jun 05 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKCocoaGlobalsDocParser.h"

/*
 * @class       AKCocoaBehaviorDocParser
 * @abstract    Parses an HTML file that documents a class or protocol.
 * @discussion  Parses an HTML file that documents a class or protocol.
 *              Inherits from AKCocoaGlobalsDocParser because class docs
 *              can contain a "Constants" section.
 */
@interface AKCocoaBehaviorDocParser : AKCocoaGlobalsDocParser
{
}

@end
