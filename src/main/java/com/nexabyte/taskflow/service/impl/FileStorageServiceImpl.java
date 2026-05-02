package com.nexabyte.taskflow.service.impl;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Objects;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.nexabyte.taskflow.service.FileStorageService;

@Service
public class FileStorageServiceImpl implements FileStorageService {

    private final Path fileStorageLocation;

    public FileStorageServiceImpl(@Value("${file.upload-dir}") String uploadDir) throws IOException {
        this.fileStorageLocation = Paths.get(uploadDir).toAbsolutePath().normalize();
        Files.createDirectories(this.fileStorageLocation);
    }

    @Override
    public String storeFile(MultipartFile file) throws IOException {
        // Normalize file name
        String originalFileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));

        // Check for invalid characters
        if (originalFileName.contains("..")) {
            throw new IOException("Filename contains invalid path sequence: " + originalFileName);
        }

        // Generate unique filename to avoid collisions
        String fileExtension = "";
        int lastDotIndex = originalFileName.lastIndexOf(".");
        if (lastDotIndex > 0) {
            fileExtension = originalFileName.substring(lastDotIndex);
        }
        String storedFileName = UUID.randomUUID() + fileExtension;

        // Copy file to the target location
        Path targetLocation = fileStorageLocation.resolve(storedFileName);
        Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);
        return storedFileName;
    }

    @Override
    public Resource loadFileAsResource(String fileName) throws IOException {
        try {
            Path filePath = fileStorageLocation.resolve(fileName).normalize();
            Resource resource = new UrlResource(filePath.toUri());
            if (resource.exists() && resource.isReadable()) {
                return resource;
            } else {
                throw new IOException("File not found or not readable: " + fileName);
            }
        } catch (MalformedURLException ex) {
            throw new IOException("Invalid file path: " + fileName, ex);
        }
    }

    @Override
    public Path getFilePath(String fileName) {
        return fileStorageLocation.resolve(fileName).normalize();
    }

    @Override
    public boolean deleteFile(String fileName) {
        try {
            Path filePath = fileStorageLocation.resolve(fileName).normalize();
            return Files.deleteIfExists(filePath);
        } catch (IOException e) {
            return false;
        }
    }

    @Override
    public boolean fileExists(String fileName) {
        Path filePath = fileStorageLocation.resolve(fileName).normalize();
        return Files.exists(filePath);
    }
}