package com.nexabyte.taskflow.dto.workpackage;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import com.nexabyte.taskflow.constants.WorkPackagePriority;
import com.nexabyte.taskflow.constants.WorkPackageStatus;
import com.nexabyte.taskflow.constants.WorkPackageType;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WorkPackageDto {
    private Long id;
    private String uiId;

    @NotNull(message = "Project is required")
    private Long projectId;
    private String projectUiId;
    private String projectName;

    @NotNull(message = "Type is required")
    private WorkPackageType workPackageType;

    @NotNull(message = "Status is required")
    private WorkPackageStatus workPackageStatus;

    @NotNull(message = "Priority is required")
    private WorkPackagePriority workPackagePriority;

    private Long assigneeId;
    private String assigneeName;
    private String assigneeUsername;

    private Long accountableId;
    private String accountableName;
    private String accountableUsername;

    @NotBlank(message = "Subject name must not be blank")
    @Size(min = 3, message = "Subject name must be at least 3 characters long")
    private String subject;

    @NotBlank(message = "Description must not be blank")
    @Size(min = 3, message = "Description must be at least 3 characters long")
    private String description;

    @DecimalMin(value = "0.0", inclusive = false, message = "Estimated hours must be greater than 0")
    @Digits(integer = 5, fraction = 2, message = "Estimated hours must be a valid number (max 99999.99)")
    private BigDecimal estimatedHours;

    @FutureOrPresent(message = "Due date must be today or in the future")
    private LocalDate dueDate;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long createdBy;
    private Long updatedBy;
}
