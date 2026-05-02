package com.nexabyte.taskflow.mapper;

import com.nexabyte.taskflow.dto.project.ProjectDto;
import com.nexabyte.taskflow.entities.Project;

public class ProjectMapper {

    public static ProjectDto toDto(Project project) {
        return ProjectDto.builder()
                .id(project.getId())
                .uiId(project.getUiId())
                .name(project.getName())
                .description(project.getDescription())
                .parentId(project.getParent() != null ? project.getParent().getId() : null)
                .parentName(project.getParent() != null ? project.getParent().getName() : null)
                .projectStatus(project.getProjectStatus())
                .createdAt(project.getCreatedAt())
                .createdBy(project.getCreatedBy())
                .updatedAt(project.getUpdatedAt())
                .updatedBy(project.getUpdatedBy())
                .build();
    }
}
