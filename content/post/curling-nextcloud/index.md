---
title: "cURLing Nextcloud"
date: 2022-11-06
description: "What a workout!"
image: "cover.png"
---
One of the great things I love about using Linux on the desktop is the customization that is allowed. The only limitation is your imagination ... and skill. In my current workflow I use Nextcloud to share files between my computers and phones. This works great as is, but I wanted to take it a step further with my KDE Plasma desktop. There are two technologies that I want to fling together. One is the ability to use cURL to upload files to Nextcloud. The other is a feature that Plasma supports, Service Menus. This allows me to add more functionality to the context (right-click) menu in Dolphin, Plasma's file manager.

## Using Curl to Upload to Nextcloud

It's actually fairly simple. However, to better increase security, the first thing we need to create is a .netrc file in our home folder that curl can access for your Nextcloud credentials. In this file, we need to put in our login name and password.
```
default
login USERNAME
password PASSWORD
```
As added security, I also change the permissions of this file to read and write only for the owner.
```
chmod 600 .netrc
```
Now that we've created our .netrc file, we can now use curl to upload a file to our Nextcloud server.
```
curl -T FILENAME "https://yourcloud.yourserver.com/remote.php/dav/files/USER/
```
And with this simple command we are able to upload a file to our Nextcloud server.

## Creating a ServiceMenu in Plasma

Now it's time to turn our attention to the Desktop. We navigate to ~/.local/share/kservices5/ServiceMenus. And in this folder we create a new .desktop file called upload2nextcloud.desktop. For more details about creating a Service Menu read the [KDE Docs](https://develop.kde.org/docs/extend/dolphin/service-menus/).
```
[Desktop Entry]
Type=Service
Icon=folder-cloud
ServiceTypes=KonqPopupMenu/Plugin
MimeType=all/allfiles;
Actions=upload2nextcloud;

[Desktop Action upload2nextcloud]
Name=Upload file to Nextcloud
Icon=folder-cloud
Exec=curl -T %f "https://yourcloud.yourserver.com/remote.php/dav/files/USER/Uploads/" && kdialog --passivepopup "%f has been uploaded to Nextcloud."
```
Let's go over briefly what this file does. The MimeType tells Plasma when to display this entry in Dolphin's context menu. In this case, we’re going to use all/allfiles. This means that the context menu will be shown on all files but not directories. The meat of the file is in the Exec entry. This is where we give the curl command. The %f is a field code and is a place holder for the file that is right-clicked.

In addition to the curl command, I also added a kdialog command to run after the curl command completed. This will create a popup telling me that the file had been uploaded to Nextcloud.

The ability to create the workflow that works best for me is just one of the reasons why I love using open source software and Linux in particular. This little addition better integrates my Nextcloud server into my Plasma laptop without the need to install apps that I'll rarely use. You can't get much better than that!
