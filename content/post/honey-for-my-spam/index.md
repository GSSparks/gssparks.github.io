---
title: "Honey for My Spam"
date: 2023-07-15
description: "Explore the fascinating world of honeypots and their role in deterring unwanted spam and automated bot submissions."
image: "cover.jpg"
categories:
- Internet
- Hugo
keywords:
- honeypots
- spam
- email
- contact me
- hugo
- website
---
Just like a moth to flame or a fly in honey, input boxes are a spambot's magnet. Spambots have only one prime objective, to fill out forms. Using this, we can devise a trap to weed out the spam while normal users are never the wiser.

## The Honeypot

It starts with modifying our current form.
```
<form action="/send_message" method="post">
  <input type="text" id="name" name="name" placeholder="Name" required >
  <input type="email" id="email" name="email" placeholder="Email" required >
  <textarea id="message" name="message" placeholder="Your Message:" required></textarea>
  <input type="submit" value="Send Message">
</form>
```
We're going to add another input box. This box, however, will have a css style that will make it transparent, in the top left corner, and under all other elements. This will make the input box effectively invisible to human readers. We could simply use `display: none;`, however, some bots are advanced enough to recognize these honeypots. We also may want to add `tabindex="-1"` to the input box to keep a user from tabbing into the invisible field. We also want to be inconspicuous to any advanced bots. We don't want to name our text box something like 'honeypot' or 'dang-those-pesky-spambots.' We'll just name this text box 'subject' as if we're looking for a subject for the email.

```
  <div style="opacity: 0; position: absolute; top: 0; left: 0; height: 0; width: 0; z-index: -1;">
    <input type="text" id="subject" name="subject" placeholder="Subject" tabindex="-1">
  </div>
```
Unlike humans, bots see the webpage as raw html. Most don't pay attention to the styling (css) part of a website. So when a bot sees this form with this input text box, the bots gonna bot and fill it in. This allows us to differentiate posts between a bot and a human.

## The send-email.js Backend

Now that we have a good idea that the posts that include the "subject" field is a bot, we can filter those posts out in the `send-email.js` script.
```
  // Check for bots using honeypot fields
  if (req.body.subject) {
    return res.status(403).send('Access Denied')
  }
```
That's it! It simply checks to see if subject has any value. And if it does, rejects it. This is a super simple but extremely effective way of reducing the number of spam you get from your contact form. It takes the very thing that the bot is good at and uses it against it like flies to honey.
