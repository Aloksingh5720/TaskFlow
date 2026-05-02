package com.nexabyte.taskflow.dto.projectmember;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProjectMemberDto {

    private Long id;
    private String uiId;
    private Long projectId;
    private String projectName;
    private Long userId;
    private String username;
    private String email;
    private String role;
    private Long roleId;
    private LocalDateTime joinedAt;
}
