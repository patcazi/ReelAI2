const logger = require("firebase-functions/logger");
const {TwelveLabs} = require("twelvelabs-js");
const admin = require("firebase-admin");
const axios = require("axios");
const fs = require("fs");
admin.initializeApp();

/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
// Use 'onRequest' and 'logger' so they're not unused:
exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

exports.testTwelveLabs = onRequest(async (req, res) => {
  try {
    const apiKey = process.env.TWELVE_LABS_KEY;
    const client = new TwelveLabs({apiKey});
    logger.info("Twelve Labs client initialized", {structuredData: true});
    logger.info(`TwelveLabs client methods: ${Object.keys(client)}`);

    return res.status(200).json({
      message: "Successfully set up twelvelabs-js!",
    });
  } catch (error) {
    logger.error("Error initializing Twelve Labs", {error});
    return res.status(500).json({error: error.toString()});
  }
});

exports.generateTitleHashtags = onRequest(
    {timeoutSeconds: 300},
    async (req, res) => {
      try {
        const {videoUrl} = req.body;
        const apiKey = process.env.TWELVE_LABS_KEY;
        const client = new TwelveLabs({apiKey});

        logger.info("Starting to generate titles/hashtags...", {
          structuredData: true,
          videoUrl,
        });

        logger.info("Downloading video to /tmp/video.mp4...");

        const response = await axios({
          method: "get",
          url: videoUrl,
          responseType: "stream",
        });

        // Pipe the response to a file in /tmp
        await new Promise((resolve, reject) => {
          const writer = fs.createWriteStream("/tmp/video.mp4");
          response.data.pipe(writer);
          writer.on("finish", resolve);
          writer.on("error", reject);
        });

        logger.info("Download complete!");

        const indexId = "67aa30bf474942061c271230";
        logger.info("Creating Twelve Labs task...");
        const task = await client.task.create({
          indexId,
          file: "/tmp/video.mp4",
        });
        logger.info(`Created task: id=${task.id}`);

        // Poll for upload/indexing completion
        await task.waitForDone(50, (taskStatus) => {
          logger.info(`taskStatus=${taskStatus.status}`);
        });
        if (task.status !== "ready") {
          throw new Error(`Indexing failed with status ${task.status}`);
        }
        logger.info(`Uploaded video! Unique video identifier: ${task.videoId}`);

        logger.info("Generating title and hashtags...");

        // Provide a custom prompt to get a creative title and hashtags
        const prompt = `
Return exactly two lines:
Line 1: A short, catchy video title (no extra words, no quotation marks).
Line 2: 3-5 hashtags separated by commas (do not add the word "Hashtag" or any labels).
`.trim();
        const textResponse = await client.generate.text(task.videoId, prompt);

        const responseStr = JSON.stringify(textResponse);
        logger.info(`Title/Hashtags Response: ${responseStr}`);

        let rawOutput = textResponse.data ?? "";
        rawOutput = rawOutput
            .replace(/title:\s*/gi, "")
            .replace(/hashtags:\s*/gi, "");
        logger.info(`Cleaned output: ${rawOutput}`);

        return res.status(200).json({
          message: "Successfully generated titles/hashtags",
          result: rawOutput,
        });
      } catch (error) {
        logger.error("Error in generateTitleHashtags", {
          message: error.message,
          stack: error.stack,
        });
        return res.status(500).json({error: error.toString()});
      }
    },
);
