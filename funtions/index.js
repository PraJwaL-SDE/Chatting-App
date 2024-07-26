const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendMessage = functions.https.onRequest(async (request, response) => {
    const token = request.query.token;
    const message = request.query.message;

    const payload = {
        notification: {
            title: 'New Message',
            body: message,
        },
    };

    try {
        await admin.messaging().sendToDevice(token, payload);
        response.status(200).send('Message sent successfully');
    } catch (error) {
        console.error('Error sending message:', error);
        response.status(500).send('Error sending message');
    }
});
