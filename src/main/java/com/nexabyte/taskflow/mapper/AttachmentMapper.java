package com.nexabyte.taskflow.mapper;

import com.nexabyte.taskflow.dto.attachment.AttachmentDto;
import com.nexabyte.taskflow.entities.Attachment;

public class AttachmentMapper {

    public static AttachmentDto toDto(Attachment attachment) {

        return AttachmentDto.builder()
                .id(attachment.getId())
                .fileName(attachment.getFileName())
                .fileSize(attachment.getFileSize())
                .contentType(attachment.getContentType())
                .workPackageId(attachment.getWorkPackage().getId())
                .workPackageSubject(attachment.getWorkPackage().getSubject())
                .createdAt(attachment.getCreatedAt())
                .createdBy(attachment.getCreatedBy())
                .build();
    }
}
