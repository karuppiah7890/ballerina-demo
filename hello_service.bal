// Packages contain functions, annotations and connectors. This
// package is referenced with ‘http’ namespace in the code body.
import ballerina/http;
import ballerina/io;
import ballerina/config;
import wso2/twitter;

endpoint twitter:Client twitterClient {
  clientId: config:getAsString("consumerKey"),
  clientSecret: config:getAsString("consumerSecret"),
  accessToken: config:getAsString("accessToken"),
  accessTokenSecret: config:getAsString("accessTokenSecret")
};

endpoint http:Listener listener {
    port: 9090
};

// A service is a network-accessible API. This service is accessed
// at '/hello', and bound to a listener on port 9090.
// `http:Service`is a protocol object in the `http` package.
@http:ServiceConfig {
  basePath: "/"
}
service<http:Service> hello bind listener {

  // A resource is an invokable API method. This resource accessed
  // at '/hello/sayHello’. `caller` is the client calling us.
  @http:ResourceConfig {
    methods: ["POST"],
    path: "/"
  }
  sayHello (endpoint caller, http:Request request) {
    string statusContent = check request.getTextPayload();
    twitter:Status status = check twitterClient->tweet(statusContent);

    http:Response response = new;
    response.setTextPayload("ID:" + <string>status.id + "\n");

    // Send a response to the caller. Ignore errors with `_`.
    // ‘->’ is a synchronous network-bound call.
    _ = caller -> respond(response);
  }
}
