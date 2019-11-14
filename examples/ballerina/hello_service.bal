// The HTTP module provides implementations for connecting and
// interacting with HTTP, HTTP2, and WebSocket endpoints. This
// package is referenced with ‘http’ namespace in the code body.
import ballerina/config;
import ballerina/http;

// A service is a network-accessible entry point. This service
// is accessed at '/hello', and bound to a listener on port default 8888.

int port = config:getAsInt("PORT", 8888);

service hello on new http:Listener(port) {

    resource function sayHello(http:Caller caller, http:Request request) returns error? {

        http:Response response = new;
        response.setTextPayload("Hello Ballerina!");
        check caller->respond(response);

    }

}
