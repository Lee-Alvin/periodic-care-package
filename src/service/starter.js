const AWS = require('aws-sdk');
AWS.config.update({ region: 'REGION' });

const util = require("./util.js")

module.exports = () => {
    return new Promise(async (resolve) => {
        const api_endpoints_pathes = {
            "official-joke-api.appspot.com": "/random_joke",
            "thecocktaildb.com": "/api/json/v1/1/random.php",
            "themealdb.com": "/api/json/v1/1/random.php",
            "catfact.ninja": "/fact"
        }
        const options = {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
            },
        }

        try {
            var api_call_promises = []
            var cleaned_responses = []
            for (var attribute in api_endpoints_pathes) {
                api_call_promises.push(util.call_api(attribute, api_endpoints_pathes[attribute], options))
            }
            var responses = await Promise.all(api_call_promises)

            responses.forEach(element => {
                cleaned_responses.push(util.clean_response(element))
            })
            var result = await Promise.all(cleaned_responses)
            return resolve(result)
        } catch (err) {
            return resolve(err)
        }
    })
}

