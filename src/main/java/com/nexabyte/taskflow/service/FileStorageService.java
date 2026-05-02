package com.nexabyte.taskflow.service;

import java.io.IOException;
import java.nio.file.Path;

import org.springframework.core.io.Resource;
import org.springframework.web.multipart.MultipartFile;


public interface FileStorageService {

    String storeFile(MultipartFile file) throws IOException;

    Resource loadFileAsResource(String fileName) throws IOException;

    Path getFilePath(String fileName);

    boolean deleteFile(String fileName);

    boolean fileExists(String fileName);
}