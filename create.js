'use strict';

var AWS = require('aws-sdk'),
	documentClient = new AWS.DynamoDB.DocumentClient(); 

exports.writeMovie = function(event, context, callback){
	var params = {
		Item : {
			"id" : context.awsRequestId,
			"Name" : event.name
		},
		TableName : "movies"
	};
	documentClient.put(params, function(err, data){
		callback(err, data);
	});
};