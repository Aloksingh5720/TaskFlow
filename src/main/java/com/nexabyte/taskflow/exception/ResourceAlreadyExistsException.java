package com.nexabyte.taskflow.exception;

public class ResourceAlreadyExistsException extends RuntimeException {

    public ResourceAlreadyExistsException(String resource, String fieldName, String fieldValue) {
        super(String.format("%s already exists with %s: %s", resource, fieldName, fieldValue));
    }

    public ResourceAlreadyExistsException(String message) {
        super(message);
    }
}
