package com.nexabyte.taskflow.exception;

public class ResourceNotFoundException extends RuntimeException {

    public ResourceNotFoundException(String resource, String fieldName, String fieldValue) {
        super(String.format("%s not found with %s: %s", resource, fieldName, fieldValue));
    }

    public ResourceNotFoundException(String message) {
        super(message);
    }
}