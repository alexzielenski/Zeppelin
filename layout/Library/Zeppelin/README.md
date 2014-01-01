# How to make Zeppelin themes


A Zeppelin theme includes up to 10 images, all with a distinct purpose. Some images are optional depending upon whether or not a theme supports a given iOS version.

## Sizing

###### iOS 4/5/6
All images should have a high of 20px in 1x and 40px for retina (@2x) – but don’t fille the entire image unless you want it to take the entire height of the statusbar. Also, the image usually needs to be pushed a bit to the right side because for some reason iOS doesn’t have the same amount of padding on both sides.

###### iOS 7+
Make your images as small as possible within 16px tall (32px on retina) and 40px wide (80px on retina). Trim transparent pixels. Zeppelin takes care of the above padding issue mentioned above.

## Naming

**silver**: *(iOS 4/5)* shown on the silver, opaque statusbar. Should be a colored (usually blue) gradient with a white drop shadow.

**black**: *(iOS 4/5/6)* shown when the statusbar. Should be very light grey with a very transparent, glow or drop shadow above it.

**etched**: *(iOS 5/6)* shown in notification center. Should be white with a 90° black drop shadow below it.

**logo**: *(iOS 7+)* Make this a black silhouette of your logo with no whitespace around it. Zeppelin will color it accordingly.

**dark**: *(iOS 7+)* Shown when statusbar icons are dark. Do whatever you want with this image. It will be used on iOS 7 if **logo** does not exist and not be tinted.

**light**: *(iOS 7+)* Shown when statusbar icons are light. Do whatever you want with this image. It will be used on iOS 7 if **logo** does not exist and not be tinted.

## Filenames

Any theme you create should have a 1x and 2x representation of each image. So the possible file names are:

	silver.png
	silver@2x.png
	black.png
	black@2x.png
	etched.png
	etched@2x.png
	light.png
	light@2x.png
	dark.png
	dark@2x.png

You do not need to have all of the images present. But here are breakdowns of the files you need for targeting each OS version:

###### iOS4

	silver.png
	silver@2x.png
	black.png
	black@2x.png

###### iOS5

	silver.png
	silver@2x.png
	black.png
	black@2x.png
	etched.png
	etched@2x.png

###### iOS6

	black.png
	black@2x.png
	etched.png
	etched@2x.png

###### iOS7

	logo.png
	logo@2x.png
	
Zeppelin will tint these images depending on the context of the menubar. If you wish to not have your logo tinted at all, instead use these images:

	dark.png        # used when the rest of the colors are dark
	dark@2x.png
	light.png       # used when the rest of the colors are light
	light@2x.png
	
\* Files with the *@2x* suffix are used on retina devices
## Styles

A template can be found [here](https://github.com/alexzielenski/Zeppelin/blob/master/Zeppelin%20Logo%20PSD.psd) with layer styles used for **silver**, **black**, and **etched**.

No template is needed for **logo** because Zeppelin colors it by itself. Just make it a black image of your logo

