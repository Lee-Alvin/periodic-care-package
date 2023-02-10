module.exports = {
	publish: (sns, params) => {
		return new Promise(async () => {
			sns.publish(params, function(err, data) {
				if (err) console.log(err, err.stack);
				else console.log(data);
			});
		});
	}
};
