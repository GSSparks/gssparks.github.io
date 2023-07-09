---
title: "Using Hugo to Build My Website"
date: 2023-07-08
description: "Experience the speed and power of static websites."
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
---
I've builit a few websites over the years. My first taste of HTML was probably around 2003. I've used different tools from  Macromedia's, now Adobe's, Dreamweaver to Microsoft's FrontPage. I saw the overuse and then decline of Flash, the overuse and hopefully the decline of Javascript. I have used Joomla, got lost on Drupal, and settled on WordPress. And now, I'm moving on again.

I recently converted this site from being a dynamic website using WordPress with a full LAMP stack to a static website. Why would I do this? Well now buckaroo, just sit back and let me tell you a tale. A tale of overworked webservers, caching, and murder. Well, not really murder, just killing off Apache processes.

Actually, I simply decided that I like the simplicity, security, and performance of an old school static website.

* __Performance:__ When using a LAMP stack for a dynamic website, the server creates a html webpage for every single visit. This can be taxing on your server, and so this is where caching comes in. As a matter of fact, I was actually looking at implementing Varnish Cache when I decided to go the static route. Like Hugo states on their website, "[A cached page is a static version of a web page](https://gohugo.io/about/benefits/)." Why not just serve the static pages?
* __Simplicity:__ Dynamic website obviously have their place, but for this website, static makes way more sense. I'm just serving posts and articles. The only time the pages change is if I create a new post or update. As a plus, using static pages takes away the need for a database.
* __Security:__ Nothing is 100%, and I've never had any compromises when using WordPress, but using static webpages in theory should take away some points of potential vulnerabilities.

## Hugo Static Web Generator
There's a reason why dynamic websites that use a CMS (content management system) like WordPress became so popular. They make building websites much easier and quicker than when building a static site from scratch. They provide templates, plugins, scalability, and tools for administration. When building a static site, you have to build every page. When you write a post, you also have to write the head, meta data, footer, etc.

Hugo takes some of the conveniences of a dynamic CMS and helps make building your static site faster and easier. It is, as they say, "[A static web generator](https://gohugo.io/about/benefits/)." With Hugo, you can select a template and modify it. Creating a post is as simple as writing a markdown file. The hierarchy is determined by the file structure of the project, and meta data is created from [front matter](https://gohugo.io/content-management/front-matter/) placed at the top of the markdown file of the post.

You can watch your changes in real time by running `hugo server` in the project directory and browsing to `localhost:1313`. And when you're ready to publish, just run `hugo` and copy the generated files, found in the `public` directory, to your webserver.

## My experience using Hugo
I have to admit. It took me a few minutes to figure out Hugo. And, honestly, I'm still figuring out all of its potential. Stay tune for future posts where I'll share my experiences using Hugo with this website. In the meantime, you can find the repo for this website [HERE](https://github.com/GSSparks/gssparks.github.io)!
