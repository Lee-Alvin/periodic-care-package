const starter = require("./service/starter.js");

exports.handler = async (event, context, callback) => {
	callback(null, await starter(event, context));
};
