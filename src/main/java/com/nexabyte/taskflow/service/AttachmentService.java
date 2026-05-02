package com.nexabyte.taskflow.service;

import java.io.IOException;
import java.util.List;

import org.springframework.core.io.Resource;
import org.springframework.web.multipart.MultipartFile;

import com.nexabyte.taskflow.dto.attachment.AttachmentDto;

public interface AttachmentService {

    AttachmentDto attachToWorkPackage(Long workPackageId, MultipartFile file, Long userId) throws IOException;

    void deleteAttachment(Long attachmentId, Long userId);

    AttachmentDto getAttachment(Long attachmentId);

    Resource downloadAttachment(Long attachmentId);

    List<AttachmentDto> getAttachmentsForWorkPackage(Long workPackageId);
}
