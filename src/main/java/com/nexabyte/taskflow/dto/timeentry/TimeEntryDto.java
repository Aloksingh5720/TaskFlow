package com.nexabyte.taskflow.dto.timeentry;

import java.math.BigDecimal;
import java.time.LocalDate;
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
public class TimeEntryDto {

    private Long id;
    private Long workPackageId;
    private Long userId;
    private String username;

    @NotBlank(message = "Time entry hours must not be blank")
    private BigDecimal hours;

    @NotBlank(message = "Time entry comment must not be blank")
    private String comment;
    private LocalDate spentOn;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private Long createdBy;
    private Long updatedBy;
}
