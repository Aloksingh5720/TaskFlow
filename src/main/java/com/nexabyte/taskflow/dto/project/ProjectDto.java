package com.nexabyte.taskflow.dto.project;

import java.time.LocalDateTime;

import com.nexabyte.taskflow.constants.ProjectStatus;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProjectDto {

    private Long id;
    private String uiId;

    @NotBlank(message = "Project name must not be blank")
    @Size(min = 3, message = "Project name must be at least 3 characters long")
    private String name;

    @NotBlank(message = "Description must not be blank")
    @Size(min = 3, message = "Description must be at least 3 characters long")
    private String description;

    private Long parentId;

    private String parentName;

    private ProjectStatus projectStatus;

    private LocalDateTime createdAt;

    private Long createdBy;

    private String creator;

    private LocalDateTime updatedAt;

    private Long updatedBy;

    private boolean isArchived;
}
