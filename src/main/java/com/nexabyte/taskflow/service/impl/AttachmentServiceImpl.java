package com.nexabyte.taskflow.service.impl;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.nexabyte.taskflow.dto.attachment.AttachmentDto;
import com.nexabyte.taskflow.entities.Attachment;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.entities.WorkPackage;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.mapper.AttachmentMapper;
import com.nexabyte.taskflow.repository.AttachmentRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.repository.WorkPackageRepository;
import com.nexabyte.taskflow.service.ActivityService;
import com.nexabyte.taskflow.service.AttachmentService;
import com.nexabyte.taskflow.service.FileStorageService;
import com.nexabyte.taskflow.utils.SecurityUtils;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class AttachmentServiceImpl implements AttachmentService {

    private final AttachmentRepository attachmentRepository;
    private final WorkPackageRepository workPackageRepository;
    private final UserRepository userRepository;
    private final FileStorageService fileStorageService;
    private final ActivityService activityService;

    @Override
    public AttachmentDto attachToWorkPackage(Long workPackageId, MultipartFile file, Long userId)
            throws IOException {
        User currentUser = SecurityUtils.getCurrentUser();

        WorkPackage workPackage = workPackageRepository.findById(workPackageId)
                .orElseThrow(() -> new ResourceNotFoundException("Work package not found with id: " + workPackageId));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        String storedFileName = fileStorageService.storeFile(file);
        Attachment attachment = new Attachment();
        attachment.setFileName(file.getOriginalFilename());
        attachment.setFilePath(storedFileName);
        attachment.setFileSize(file.getSize());
        attachment.setContentType(file.getContentType());
        attachment.setWorkPackage(workPackage);
        attachment.setUploadedBy(user);

        attachment = attachmentRepository.save(attachment);

        AttachmentDto attachmentDto = AttachmentMapper.toDto(attachment);
        activityService.recordAttachmentAdded(attachmentDto, currentUser.getUsername());
        return attachmentDto;
    }

    @Override
    public void deleteAttachment(Long attachmentId, Long userId) {
        Attachment attachment = attachmentRepository.findById(attachmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Attachment not found with id: " + attachmentId));

        fileStorageService.deleteFile(attachment.getFilePath());
        attachmentRepository.delete(attachment);
    }

    @Override
    public AttachmentDto getAttachment(Long attachmentId) {
        Attachment attachment = attachmentRepository.findById(attachmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Attachment not found with id: " + attachmentId));
        return AttachmentMapper.toDto(attachment);
    }

    @Override
    public Resource downloadAttachment(Long attachmentId) {
        Attachment attachment = attachmentRepository.findById(attachmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Attachment not found with id: " + attachmentId));

        try {
            Resource resource = fileStorageService.loadFileAsResource(attachment.getFilePath());
            return resource;
        } catch (IOException e) {
            throw new RuntimeException("Could not read file: " + attachment.getFileName(), e);
        }
    }

    @Override
    public List<AttachmentDto> getAttachmentsForWorkPackage(Long workPackageId) {
        return attachmentRepository.findByWorkPackageId(workPackageId)
                .stream()
                .map(AttachmentMapper::toDto)
                .collect(Collectors.toList());
    }
}
