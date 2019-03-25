const vision = require("@google-cloud/vision");
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.callVision = functions.storage.object().onFinalize((object) => {
	const fileBucket = object.bucket;
	const filePath = object.name;
	const gcsPath = `gs://${fileBucket}/${filePath}`;
	const client = new vision.v1.ImageAnnotatorClient();
	// Call the Vision API's detection endpoints
	return client.labelDetection(gcsPath).then(response => {
		let labelAnnotations = response[0].labelAnnotations;
		return {labels: labelAnnotations};
	}).then((visionResp) => {
		let db = admin.firestore();
		let imageRef = db.collection('images').doc(filePath);
		console.log(imageRef);

		return imageRef.set(visionResp);
	}).catch(err => {
			console.log('vision api error', err);
		});
});