# SimpleWeather

[Ray Wenderlich's tutorial on iOS 7 best practices](https://www.raywenderlich.com/55384/ios-7-best-practices-part-1) provides a case study by creating a weather app. The tutorial uses Objective-C. This project is a Swift implementation of the same app.

## Why?
Just to learn the Swift language, best practices, and popular Swift Libraries.

## Using OpenWeather API
This project uses OpenWeather api to get weather data. To use their API, you need to register an account and get an API key. For security purposes, the API key is not hardcoded in the project to avoid checking it into source control. The API key is being read from a file called keys.plist, which is ignored by `.gitignore`. To build this project, you need to add this file yourself. The key name is expected to be "openWeatherApiKey".

Note that this approach only avoids checking in the api key. If you build this project and release the app, it may still be possible for users to decompile your app and retrieve the api key.

## Differences from the original project
1. I did not use TSMessages for displaying error messages.
2. Instead of using ReactiveCocoa for reactive programming, I used Alamofire for asynchronous networking and Swift's property observers to refresh data/UI.
3. Instead of Using Mantle for converting JSON to NSObject classes, I used ObjectMapper (side note: there is actually an Alamofire+ObjectMapper extension which I did not use).
4. Unlike the original tutorial, this project does not show daily forecast data. The daily forecast API requires a paid account.

## Known issues
- Blurred images is not working.

## Improvements
This is my first project in Swift and it is possible some things could be written in a better manner. If you spot any thing that can be improved, feel free to send in a PR or contact me.