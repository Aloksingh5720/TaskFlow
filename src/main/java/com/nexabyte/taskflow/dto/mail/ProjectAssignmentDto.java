package com.nexabyte.taskflow.dto.mail;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProjectAssignmentDto {
    private String name;
    private String projectName;
    private String role;
    private String manager;
    private String startDate;
    private String projectLink;
}