**This project is a work in progress - please come back later to see it in all its glory!**

ShinobiCharts Movement Tracker (Objective-C)
=====================

This is a demo app which tracks the user's speed, location, and distance travelled. It demonstrates the use of live datasources and custom crosshairs and tooltips in ShinobiCharts.

![Screenshot](screenshot.png?raw=true)

Building the project
------------------

In order to build this project you'll need a copy of ShinobiCharts for iOS. If you don't have it yet, you can download a free trial from the [ShinobiCharts website](http://www.shinobicontrols.com/ios/shinobicharts/).

If you've used the installer to install ShinobiCharts, everything should just work. If you haven't, then once you've downloaded and unzipped ShinobiCharts, open up the project in Xcode, and drag ShinobiCharts.embeddedframework from the finder into Xcode's 'frameworks' group, and Xcode will sort out all the header and linker paths for you.

If you're using the trial version you'll need to add your license key. To do so, open up ViewController.m and add the following line after the chart is initialised:

    chart.licenseKey=@"your license key";

Before firing up the project in the simulator, set up a moving location (Debug -> Location -> City Bicycle Ride works nicely with the default settings). Then start the app and watch your graph appear; tap on a line to see a tooltip showing the location on a map.


Contributing
------------

We'd love to see your contributions to this project - please go ahead and fork it and send us a pull request when you're done! Or if you have a new project you think we should include here, email info@shinobicontrols.com to tell us about it.

License
-------

The [Apache License, Version 2.0](license.txt) applies to everything in this repository, and will apply to any user contributions.

