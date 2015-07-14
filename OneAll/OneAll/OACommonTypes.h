//
//  OACommonTypes.h
//  oneall
//
//  Created by Uri Kogan on 16/4/15.
//  Copyright (c) 2015 urk. All rights reserved.
//
#ifndef oneall_OACommonTypes_h
#define oneall_OACommonTypes_h

/** social link action type */
typedef NS_ENUM(NSInteger, OASocialLinkAction)
{
    /** no social link action */
    OASocialLinkActionNone,
    
    /** social link action: link */
    OASocialLinkActionLink,
    
    /** social link action: unlink */
    OASocialLinkActionUnlink
};

#endif
