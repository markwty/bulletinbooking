const functions = require('firebase-functions');
const firebase = require('firebase-admin');
const { parseAsync } = require('json2csv');

const fs = require('fs');
const path = require('path');
const os = require('os');
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
  const now = new Date();
  const weekDay = now.getDay();
  var next;

  //functions.logger.log(req.query);
  if (req.query.date == "") {
    if (weekDay == 7 && now.getHour() >= 12) {
      next = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    } else {
      next = new Date(now.getTime() + (7-weekDay) * 24 * 60 * 60 * 1000);
    }
  } else {
    next = new Date(Date.parse(req.query.date));
  }

  var dateTime = next.toLocaleDateString("en-US", {day: 'numeric'}) +
  " " + next.toLocaleDateString("en-US", {month: 'long'}) +
  " " + next.toLocaleDateString("en-US", {year: 'numeric'});

  if (req.query.update == "" || req.query.update == "0") {
    const applicationsSnapshot = await firebase
      .firestore()
      .collection("bookings")
      .doc(dateTime)
      .collection("list")
      .orderBy("time")
      .get();

    const applications = applicationsSnapshot.docs.map((doc) => {
      var data = doc.data();
      data.time = data.time.toDate();
      //data.seconds = data.time._seconds;
      //data.nanoseconds = data.time._nanoseconds;
      return data;
    });

    const fields = [
      'time',
      //'seconds',
      //'nanoseconds',
      'name',
      'choice',
      'reason'
    ];

    const output = await parseAsync(applications, { fields });
    dateTime = dateTime.replace(/\W/g, "");
    const filename = `bookings_${dateTime}.csv`;
    const tempLocalFile = path.join(os.tmpdir(), filename);
    fs.writeFile(tempLocalFile, output, error => {
      if (error) {
        return;
      }
      res.download(tempLocalFile);
    });
  } else {
    await firebase
      .firestore()
      .collection("bookings")
      .doc(dateTime)
      .update({
        "size": firebase.firestore.FieldValue.increment(parseInt(req.query.update))
      });
    res.send("Done changing size");
  }
});

 exports.exportPubSub = functions.https.onRequest(app);
