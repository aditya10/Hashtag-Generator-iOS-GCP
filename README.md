# Hashtag-Generator-iOS-GCP
Using Google's Vision API to generate hashtags on an iOS app

<img src="https://github.com/aditya10/Hashtag-Generator-iOS-GCP/blob/master/Hashtagger/AppIcons/Icon-white-bk.png" width="100">

## Hashtagger - iOS Client
The hashtagger client will select and upload an image to Google Firebase. In return, it will connect to Cloud Firestore to retrive hashtags for the associated image.

## Hashtag Generator - Firebase Functions
On receiving a new image file on Firebase storage, Firebase Functions will automatically trigger an API call to the GCP Vision API for image labeling. The API returns the associated label attributes, which is then written to Cloud Firestore.

This part of the project is written in Node.js using the firebase, firebase-admin, and vision npm packages.

### References:

* [Google Firebase](https://firebase.google.com)
* [Google Vision API](https://cloud.google.com/vision/)
* [Adding Computer Vision to your iOS App - Sara Robinson](https://medium.com/@srobtweets/adding-computer-vision-to-your-ios-app-66d6f540cdd2)
