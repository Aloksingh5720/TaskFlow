package com.nexabyte.taskflow.service;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.nexabyte.taskflow.dto.issue.IssueDto;

public interface IssueService {

    void createIssue(IssueDto issueDto, Long workPackageId);

    void updateIssue(IssueDto issueDto, Long issueId);

    void deleteIssue(Long issueId);

    IssueDto getIssueById(Long issueId);

    List<IssueDto> getByWorkPackgeId(Long workPackageId);

    Page<IssueDto> getIssuesByUser(Long userId, Pageable pageable);

    Page<IssueDto> getIssuesToResolve(Long userId, Pageable pageable);

    void resolveIssue(Long issueId);
}
