package com.nexabyte.taskflow.mapper;

import com.nexabyte.taskflow.dto.issue.IssueDto;
import com.nexabyte.taskflow.entities.Issue;

public class IssueMapper {

    public static IssueDto toDto(Issue issue) {
        return IssueDto.builder()
                .Id(issue.getId())
                .title(issue.getTitle())
                .description(issue.getDescription())
                .issueStatus(issue.getIssueStatus())
                .workPackageId(issue.getWorkPackage() != null ? issue.getWorkPackage().getId() : null)
                .workPackageName(issue.getWorkPackage() != null ? issue.getWorkPackage().getSubject() : null)
                .projectId(issue.getWorkPackage() != null && issue.getWorkPackage().getProject() != null
                        ? issue.getWorkPackage().getProject().getId()
                        : null)
                .projectName(issue.getWorkPackage() != null && issue.getWorkPackage().getProject() != null
                        ? issue.getWorkPackage().getProject().getName()
                        : null)
                .accountableId(issue.getWorkPackage() != null && issue.getWorkPackage().getAccountable() != null
                        ? issue.getWorkPackage().getAccountable().getId()
                        : null)
                .build();
    }
}
