## Emoji Names

Emoji Names is an iOS app written in Swift that reveals the unicode name of emoji. 

### Screenshots

<p align="center">
    <img src="images/X%201.png" width=275px> <img src="images/X%202.png" width=275px> <img src="images/X%203.png" width=275px>
</p>

### Features 
 - Use the Emoji keyboard to find and select an Emoji
 - Emoji Names will find the name of the emoji and show it on screen
 - Share customizable images of emoji straight from the app
 - Paste emoji from messages in other apps to quickly find their names
 - Choose between the system emoji style and high-res Twitter emoji

In the early days of emoji, finding the name was a pretty simple. Each emoji was a single unicode character, so you could just check the name of that individual codepoint. CoreFoundation has a `kCFStringTransformToUnicodeName` string transform that did most of the heavy lifting.

These days, there are lots of emoji that are acually composed out of many separate characters. Examples include emoji with skin tone / gender modifiers, family emoji, and country flags. Emoji Names does additional post-processing to make sure everything looks great for all of these different cases.

### Legacy Screenshots

<p align="center">
    <img src="images/legacy%201.png" width=275px> <img src="images/legacy%202.png" width=275px> <img src="images/emoji%20names.gif" width=275px>
</p>