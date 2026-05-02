package com.nexabyte.taskflow.dto.comment;

import java.time.LocalDateTime;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommentDto {

    private Long id;
    private Long workPackageId;
    private Long userId;
    private String username;
    private String workPackageSubject;

    @NotBlank(message = "Content must not be blank")
    private String content;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}