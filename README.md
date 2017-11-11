## Emoji Names

Emoji Names is an iOS app written in Swift that reveals the unicode name of emoji. 

In the early days of emoji, this was a pretty simple. Each emoji was a single unicode character, so you could just check the name of that individual codepoint. CoreFoundation has a `kCFStringTransformToUnicodeName` string transform that did most of the heavy lifting.

These days, there are lots of emoji that are acually composed out of many separate characters. Examples include emoji with skin tone / gender modifiers, family emoji, and country flags. Emoji Names does additional post-processing to make sure everything looks great for all of these different cases.

### Screenshots

<p align="center">
    <img src="images/X%201.png" width=300px> <img src="images/X%203.png" width=300px>
</p>

<p align="center">
    <img src="images/emoji%20names.gif" width=300px>
</p>