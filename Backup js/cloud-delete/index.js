const functions = require('firebase-functions');
const firebase = require('firebase-admin');

const express = require('express');
const cors = require('cors');

firebase.initializeApp({
  apiKey: "<insert api key here>",
  authDomain: "shalomfs.firebaseapp.com",
  projectId: "shalomfs",
  storageBucket: "shalomfs.appspot.com",
  messagingSenderId: "<insert messaging sender id here>",
  appId: "<insert app id here>"
});
const app = express();
app.use(cors({ origin: true }));
app.use(express.urlencoded({
  extended: true
}))

app.get('/', async (req, res) => {
  if (req.query.date == "" || req.query.time == "" || req.query.name == "") {
    res.send("Parameters not found");
    return;
  }
  next = new Date(Date.parse(req.query.date));

  var dateTime = next.toLocaleDateString("en-US", {day: 'numeric'}) +
  " " + next.toLocaleDateString("en-US", {month: 'long'}) +
  " " + next.toLocaleDateString("en-US", {year: 'numeric'});

  var size;
  await (firebase
    .firestore()
    .collection("bookings")
    .doc(dateTime)
    .collection("list")
    //.where('time', '==', new firebase.firestore.Timestamp(parseInt(req.query.seconds), parseInt(req.query.nanoseconds)))
    .where('time', '==', new Date(Date.parse(req.query.time)))
    .where('name', '==', req.query.name)
    .limit(1)
    .get().then(snap => {
      size = snap.size;
    }));
  
  if (size == 0) {
    res.send("Record does not exist");
    return;
  }
  await firebase
    .firestore()
    .collection("bookings")
    .doc(dateTime)
    .collection("list")
    //.where('time', '==', new firebase.firestore.Timestamp(parseInt(req.query.seconds), parseInt(req.query.nanoseconds)))
    .where('time', '==', new Date(Date.parse(req.query.time)))
    .where('name', '==', req.query.name)
    .limit(1)
    .get().then(function(querySnapshot) {
      querySnapshot.forEach(function(doc) {
        doc.ref.delete();
      });
    });

  await firebase
    .firestore()
    .collection("bookings")
    .doc(dateTime)
    .update({
      "size": firebase.firestore.FieldValue.increment(-1)
    });
  res.send("Done deletion");
});

 exports.exportPubSub = functions.https.onRequest(app);