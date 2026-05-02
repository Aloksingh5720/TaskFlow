package com.nexabyte.taskflow.mapper;

import com.nexabyte.taskflow.dto.mail.WorkPackageAssignmentDto;
import com.nexabyte.taskflow.dto.workpackage.WorkPackageDto;
import com.nexabyte.taskflow.entities.WorkPackage;

public class WorkPackageMapper {

    public static WorkPackageDto toDto(WorkPackage wp) {
        return WorkPackageDto.builder()
                .id(wp.getId())
                .uiId(wp.getUiId())
                .projectId(wp.getProject().getId())
                .projectUiId(wp.getProject().getUiId())
                .projectName(wp.getProject().getName())
                .workPackageType(wp.getWorkPackageType())
                .workPackageStatus(wp.getWorkPackageStatus())
                .workPackagePriority(wp.getWorkPackagePriority())
                .assigneeId(wp.getAssignee().getId())
                .assigneeName(wp.getAssignee().getName())
                .assigneeUsername(wp.getAssignee().getUsername())
                .accountableId(wp.getAccountable().getId())
                .accountableName(wp.getAccountable().getName())
                .accountableUsername(wp.getAccountable().getUsername())
                .subject(wp.getSubject())
                .description(wp.getDescription())
                .estimatedHours(wp.getEstimatedHours())
                .dueDate(wp.getDueDate())
                .completedAt(wp.getCompletedAt())
                .createdAt(wp.getCreatedAt())
                .updatedAt(wp.getUpdatedAt())
                .createdBy(wp.getCreatedBy())
                .updatedBy(wp.getUpdatedBy())
                .build();
    }

    public static WorkPackageAssignmentDto toAssignmentDto(WorkPackage wp) {
        return WorkPackageAssignmentDto.builder()
                .projectId(wp.getProject().getId())
                .projectName(wp.getProject().getName())
                .workPackageType(wp.getWorkPackageType().toString())
                .workPackageStatus(wp.getWorkPackageStatus().toString())
                .workPackagePriority(wp.getWorkPackagePriority().toString())
                .assigneeId(wp.getAssignee().getId())
                .assigneeName(wp.getAssignee().getName())
                .accountableId(wp.getAccountable() != null ? wp.getAccountable().getId() : null)
                .accountableName(wp.getAccountable() != null ? wp.getAccountable().getName() : null)
                .subject(wp.getSubject())
                .description(wp.getDescription())
                .estimatedHours(wp.getEstimatedHours() != null ? wp.getEstimatedHours().toPlainString() : null)
                .dueDate(wp.getDueDate() != null ? wp.getDueDate().toString() : null)
                .build();
    }
}
