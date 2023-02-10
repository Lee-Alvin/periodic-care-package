module.exports = {
	publish: (sns, params) => {
		sns.publish(params, function (err, data) {
			if (err) return err, err.stack;
			else return data;
		});
	},
};
