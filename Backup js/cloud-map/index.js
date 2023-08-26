const functions = require('firebase-functions');
const firebase = require('firebase-admin');

const { v4 } = require('uuid');
const fs = require('fs');
const path = require('path');
const os = require('os');
const express = require('express');
const cors = require('cors');

firebase.initializeApp({
  apiKey: "<insert api key here>",
  projectId: "shalomfs"
});
const app = express();
app.use(cors({ origin: true }));
app.use(express.urlencoded({
  extended: true
}))

app.get('/', async (req, res) => {
  if (req.query.txt == "" || req.query.data == "") {
    return;
  }
  var bucket = firebase.storage().bucket("shalomfs.appspot.com")
    bucket.file(req.query.txt + ".txt")
    .delete().then(function() {
      const filename = req.query.txt + ".txt";
      const tempLocalFile = path.join(os.tmpdir(), filename);
      const data = (req.query.data).split('\\n').join('\n');
      fs.writeFile(tempLocalFile, data, error => {
        if (error) {
          return;
        }
        bucket.upload(tempLocalFile, {
          public: true,
          destination: req.query.txt + ".txt",
          metadata: {
            cacheControl: 'public, max-age=1',
            metadata: {
              firebaseStorageDownloadTokens: v4(),
            }
          }
        });
        res.send("Done");
      });
    }).catch(console.error);
});

 exports.exportPubSub = functions.https.onRequest(app);