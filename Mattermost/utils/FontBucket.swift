//
//  FontUtils.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 27.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol PostFonts: class {
    static var messageFont: UIFont {get}
    static var postDateFont: UIFont {get}
    static var postAuthorNameFont: UIFont {get}
}

private protocol FeedFonts: class {
    static var feedSendButtonTitleFont: UIFont {get}
    static var inputTextViewFont: UIFont {get}
    static var sectionTitleFont: UIFont {get}
}

private protocol LeftMenuFonts {
    static var normalTitleFont: UIFont {get}
    static var highlighTedTitleFont: UIFont {get}
}

private protocol MarkdownFonts: class {
    static var emphasisFont: UIFont {get}
    
    static func semiboldFontOfSize(size: CGFloat) -> UIFont
    static func regularFontOfSize(size: CGFloat) -> UIFont
}

final class FontBucket {
}

extension FontBucket : PostFonts {
     static let messageFont = FontBucket.regularFontOfSize(15)
     static let postDateFont = FontBucket.regularFontOfSize(13)
     static let postAuthorNameFont = FontBucket.semiboldFontOfSize(16)
}

extension FontBucket : FeedFonts {
    static let feedSendButtonTitleFont = FontBucket.semiboldFontOfSize(16)
    static let inputTextViewFont = FontBucket.regularFontOfSize(15)
    static let sectionTitleFont = FontBucket.semiboldFontOfSize(16)
}

extension FontBucket : LeftMenuFonts {
    static let normalTitleFont = FontBucket.regularFontOfSize(18)
    static let highlighTedTitleFont = FontBucket.semiboldFontOfSize(18)
}

//MARK: Helpers

extension FontBucket: MarkdownFonts {
    static let emphasisFont = FontBucket.italicFontOfSize(15)
    
    static func regularFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: FontNames.Regular, size: size)!
    }
    
    static func semiboldFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: FontNames.Semibold, size: size)!
    }
}

extension FontBucket {
    private static func italicFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: FontNames.Italic, size: size)!
    }
}

private struct FontNames {
    static let Regular               = "SFUIText-Regular"
    static let Semibold              = "SFUIText-Semibold"
    static let Medium                = "SFUIText-Medium"
    static let Bold                  = "SFUIText-Bold"
    static let Italic                = "SFUIText-LightItalic"
    static let RegularDisplay        = "SFUIDisplay-Regular"
    static let SemiboldDisplay       = "SFUIDisplay-Semibold"
    static let BoldDisplay           = "SFUIDisplay-Bold"
    static let MediumDisplay         = "SFUIDisplay-Medium"
}