package com.nexabyte.taskflow.dto.attachment;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AttachmentDto {
    private Long id;
    private String fileName;
    private Long fileSize;
    private String contentType;
    private Long workPackageId;
    private String workPackageSubject;
    private LocalDateTime createdAt;
    private Long createdBy;
}
