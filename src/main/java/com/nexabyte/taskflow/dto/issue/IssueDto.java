package com.nexabyte.taskflow.dto.issue;

import com.nexabyte.taskflow.constants.IssueStatus;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class IssueDto {

    private Long Id;

    @NotBlank(message = "Issue title must not be blank")
    private String title;

    @NotBlank(message = "Issue description must not be blank")
    private String description;

    private IssueStatus issueStatus;

    private Long workPackageId;

    private String workPackageName;

    private Long projectId;

    private String projectName;

    private Long accountableId;
}
