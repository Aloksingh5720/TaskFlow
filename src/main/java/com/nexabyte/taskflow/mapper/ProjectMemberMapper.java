package com.nexabyte.taskflow.mapper;

import com.nexabyte.taskflow.dto.projectmember.ProjectMemberDto;
import com.nexabyte.taskflow.entities.ProjectMember;

public class ProjectMemberMapper {

    public static ProjectMemberDto toDto(ProjectMember projectMember) {

        return ProjectMemberDto.builder()
                .id(projectMember.getId())
                .uiId(projectMember.getUiId())
                .projectId(projectMember.getProject().getId())
                .projectName(projectMember.getProject().getName())
                .userId(projectMember.getUser().getId())
                .username(projectMember.getUser().getUsername())
                .email(projectMember.getUser().getEmail())
                .role(projectMember.getRole().getName())
                .roleId(projectMember.getRole().getId())
                .joinedAt(projectMember.getCreatedAt())
                .build();
    }
}
