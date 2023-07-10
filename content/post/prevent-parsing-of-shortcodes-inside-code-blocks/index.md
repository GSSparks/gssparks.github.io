---
title: "Prevent Parsing of Shortcodes Inside Code Blocks"
description: "This is how you can show literal shortcodes inside your code blocks. It took me forever to find this!"
date: 2023-07-09
image: "cover.png"
categories:
- Internet
- Hugo
keywords:
- blog
- hugo
- cms
- markdown
- website
- shortcodes
---
When writing a post about my Hugo experiences, I came across this issue of Hugo wanting to parse a shortcode in my examples.
This one just about drove me insane, but I found the answer [here](https://stackoverflow.com/questions/65209999/prevent-parsing-of-shortcodes-inside-code-blocks), and thought I should document it for myself and any other Hugo/Markdown noob that comes across this issue.
I tried to escape the code `\` and even tried to use HTML entity code `&#123;` and `&#125;` for the curly braces. The solution, however, is to comment it out:
```
{{</*/* shortcode */*/>}}
```
Which will be render like this:
```
{{</* shortcode */>}}
```
Using comment syntax allows me to display the shortcode. It effectively treats the shortcode as a comment, so it is not executed or interpreted by Hugo.
