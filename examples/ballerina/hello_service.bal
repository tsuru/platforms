// The HTTP module provides implementations for connecting and
// interacting with HTTP, HTTP2, and WebSocket endpoints. This
// package is referenced with ‘http’ namespace in the code body.
import ballerina/http;
import ballerina/io;

// A service is a network-accessible entry point. This service
// is accessed at '/hello', and bound to a listener on port 9090.
service hello on new http:Listener(9090) {

  // A resource is an API method which can be called by a listener.
  // It is always visible to the listener to which the service is
  // attached. This resource is accessed at '/hello/sayHello’ and
  // `caller` is the client calling us.
  resource function sayHello(http:Caller caller,
                             http:Request request) {

    // Create an object to carry data back to the caller.
    http:Response response = new;

    // Objects have function calls.
    response.setPayload("Hello Ballerina!\n");

    // Send a response to the caller. Ignore errors with `_`.
    // ‘->’ is a synchronous network-bound call.
    _ = caller -> respond(response);
  }
}
