---
title: "Creating a 'Contact Me' Form for a Static Website"
date: 2023-07-09
description: "I create a simple solution to provide a Contact Me form for this website. It uses Node.js for the backend and routes through a Gmail account."
image: "cover.jpg"
categories:
- internet
- Hugo
keywords:
- node.js
- Hugo
- cms
- markdown
- website
---
One of the hurdles I need to overcome when switching from a dynamic CMS like WordPress to using Hugo generated static pages is the need to implement a usable contact me form.
There's plenty of services out there that I could have used, but I decided I wanted to self-host the solution. Already on my webserver I have sendmail installed and have messages sent to my gmail account to notify
me when I need to update the IP address. This is what drove me to look into creating my own solution.

## The Frontend

The frontend is pretty straight forward. I created a page in `content/page/` and name it contact. Inside of that directory, I created a file called index.md.

```
vim contact/index.md

---
title: "Contact Me"
aliases:
  - contact
ReadingTime: false
menu:
    main:
        weight: -90
        params:
            icon: mail
---
{{</* contact_form */>}}

```
Of course, the shortcode for this will need to be created. So I went to `layouts/shortcodes/` and created a file called `contact_form.html`. In this file, I put in the following code:
```
<form action="/send_message" method="post">
  <input type="text" id="name" name="name" placeholder="Name" required >
  <input type="email" id="email" name="email" placeholder="Email" required >
  <textarea id="message" name="message" placeholder="Your Message:" required></textarea>
  <input type="submit" value="Send Message">
</form>
```
This form will submit data to `/send_message` which we still need to define. This will be our backend that will process and send the message.
Except for some stylistic work, that's it for the frontend.

## The Webserver

Next, I defined `/send_message` in `Nginx`. I ssh into the server and open up the config file for this website.
```
sudo vim /etc/nginx/sites-available/garysparks.info
```
And in this file I place this snippet.
```
    location /send_message {
         proxy_pass http://localhost:8383/send_message;
         proxy_set_header Host $host;
         proxy_set_header X-Real-IP $remote_addr;
         proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
    }
```
This instructs `Nginx` to send all `/send_message` traffic to `http://localhost:8383/send_message`. This is where our node.js app will be listening.

## The send-email.js App

The last thing I need to build is the app itself. I'm using `Node.js` to build the app.
```
const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const nodemailer = require('nodemailer');
const sanitizeHtml = require('sanitize-html');

// Parse URL-encoded bodies
app.use(bodyParser.urlencoded({ extended: true }));

// Validate and sanitize form inputs
app.post('/send_message', (req, res) => {
  const { name, email, message } = req.body;

  // Perform validation checks
  if (!name || !email || !message) {
    return res.status(400).send('Missing required fields');
  }

  // Sanitize inputs
  const sanitizedName = sanitizeHtml(name);
  const sanitizedEmail = sanitizeHtml(email);
  const sanitizedMessage = sanitizeHtml(message);

  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(sanitizedEmail)) {
    return res.status(400).send('Invalid email address');
  }

  // Configure nodemailer with your email provider settings
  const transporter = nodemailer.createTransport({
    service: 'EMAIL',
    auth: {
      user: 'USER@EMAIL.COM',
      pass: 'PASSWORD',
    },
  });

  const mailOptions = {
    from: 'USER@EMAIL.COM',
    to: 'USER@EMAIL.COM',
    subject: 'New Contact Message',
    text: `Name: ${sanitizedName}\nEmail: ${sanitizedEmail}\n\nMessage:\n${sanitizedMessage}`,
  };

  // Send email
  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error(error);
      res.status(500).send('Error sending message');
    } else {
      console.log('Email sent: ' + info.response);
      res.sendFile('PATH/TO/SUCCESS/MESSAGE');
    }
  });
});

// Handle GET requests to /send_message
app.use((req, res) => {
  res.status(404).sendFile('PATH/TO/404/MESSAGE');
});

// Start the server
app.listen(8383, () => {
  console.log('Server listening on port 8383');
});
```
There's a few things that you'll have to change if you're following along at home. EMAIL needs to be your email provider.
USER@EMAIL.COM needs to be your email address. PASSWORD needs to be ... yes you guessed it ... your password. Also, I made
provisions to send a custom HTML for a successful message sent message, which you'll have to change to your success message.html
location. And I also made it 404 any request that isn't a POST. You'll also have to provide a 404.html file for it to serve.

In this app, I also tried to provide some sanitation to keep malicious code from being passed to it. The `sanitize-html` library
sanitizes the inputs and prevents XSS attacks.

If you set up your email and password and run this on the server, the `Contact Me` page will send an email to your email. Using Gmail,
I had to jump through a few hoops on my setup. I needed to create an App Password for this app because I have 2fa activated on my account.

Once running, you can test it by submitting this command:
```
curl -X POST \
  -d "name=John&email=john@example.com&message=Hello%20World" \
  http://localhost:8000/send_message
```
Yay! Success! :)

## Making the App a Service

Chances are we don't want to babysit our webserver. If it goes down, or if the app stops for some reason, we want
to be able to have `send-mail.js` restart. To do this, I created a systemd service unit file.
```
sudo nano /etc/systemd/system/send-email.service

[Unit]
Description=App to listen for incoming messages from my website.
Documentation=https://garysparks.info

[Service]
ExecStart=/usr/bin/node /path/to/send-email.js
WorkingDirectory=/path/to/send-email.js
Restart=always
User=your_username
Group=your_group

[Install]
WantedBy=multi-user.target
```
After saving this file, I reloaded the systemd daemon and enable and started the service.
```
sudo systemctl daemon-reload
sudo systemctl enable --now send-email.service
```
To monitor the service, I can issue the following command:
```
sudo systemctl status send-email.service
```

## What's Next?

This is working great! There are, however, a few tweaks that I need to get to. For example, I would like for the `message_sent`
message to redirect to `home` after a few seconds. I did a quick hack by adding:
```
<meta http-equiv="refresh" content="5; url=/">
```
in the head of the already generated `message_sent.html` file, but it'll be rewritten over just as soon as I re-run Hugo when adding new content.
Also, it's possible to go to the `message_sent.html` file manually which isn't ideal. But, those are just more projects for the future!

## UPDATE

I stopped outside traffic from going to `message_sent.html` by adding the following snippet in my `nginx` config file.

```
location /message_sent {
  if ($remote_addr != 127.0.0.1) {
    return 404;
  }
}
```
Works like a charm! :) More to come!
