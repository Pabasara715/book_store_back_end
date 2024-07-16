import book_store.store;

import ballerina/http;
import ballerina/persist;

final store:Client sClient = check new ();

@http:ServiceConfig {
    cors: {
        allowOrigins: ["https://3ad45069-6f2b-47e3-9915-9586f353223b.e1-eu-north-azure.choreoapps.dev"],
        allowCredentials: true,
        allowHeaders: ["x-jwt-assertion"],
        maxAge: 84900

    }
}
service / on new http:Listener(9090) {

    resource function post books(store:BookRequest book) returns int|error {
        store:BookInsert bookInsert = check book.cloneWithType();
        int[] bookIds = check sClient->/books.post([bookInsert]);
        return bookIds[0];
    }

    resource function get books/[int id]() returns store:Book|error {
        return check sClient->/books/[id];
    }

    resource function get books() returns store:Book[]|error {
        stream<store:Book, persist:Error?> resultStream = sClient->/books;
        return check from store:Book book in resultStream
            select book;
    }

    resource function put books/[int id](store:BookUpdate book) returns store:Book|error {
        return check sClient->/books/[id].put(book);
    }

    resource function delete books/[int id]() returns store:Book|error {
        return check sClient->/books/[id].delete();
    }
}
