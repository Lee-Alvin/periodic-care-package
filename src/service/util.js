const _ = require("lodash")
const https = require("https")


module.exports = {
    call_api: (endpoint, path, options) => {
        return new Promise(async (resolve, reject) => {
            let data = ''
            let start = new Date()

            options.hostname = endpoint
            options.path = path
            const request = https.request(options, (response) => {
                response.setEncoding('utf8');
                response.on('data', (chunk) => {
                    data += chunk;
                });

                response.on('end', () => {
                    console.log(`Response time for ${endpoint} in ms:`, new Date() - start)
                    return resolve(JSON.parse(data));
                });
            });

            request.on('error', (error) => {
                return reject(error);
            });
            request.end();
        })
    },

    clean_response: (response) => {
        return new Promise(async (resolve) => {
            if (response["meals"]) response = response["meals"][0]
            if (response["drinks"]) response = response["drinks"][0]
            for (var attribute in response) {
                if (_.isEmpty(response[attribute] || _.isEqual(response[attribute], " "))) delete response[attribute]
            }
            return resolve(response)
        })
    },

}