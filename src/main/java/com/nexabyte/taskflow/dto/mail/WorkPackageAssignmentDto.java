package com.nexabyte.taskflow.dto.mail;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkPackageAssignmentDto {

    private Long projectId;

    private String projectName;

    private String workPackageType;

    private String workPackageStatus;

    private String workPackagePriority;

    private Long assigneeId;
    private String assigneeName;

    private Long accountableId;
    private String accountableName;

    private String subject;

    private String description;

    private String estimatedHours;

    private String dueDate;
}
