package com.nexabyte.taskflow.service.impl;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.nexabyte.taskflow.constants.IssueStatus;
import com.nexabyte.taskflow.dto.issue.IssueDto;
import com.nexabyte.taskflow.entities.Issue;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.entities.WorkPackage;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.mapper.IssueMapper;
import com.nexabyte.taskflow.repository.IssueRepository;
import com.nexabyte.taskflow.repository.WorkPackageRepository;
import com.nexabyte.taskflow.service.IssueService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class IssueServiceImpl implements IssueService {

    private final IssueRepository issueRepository;
    private final WorkPackageRepository workPackageRepository;

    @Override
    public void createIssue(IssueDto issueDto, Long workPackgeId) {

        WorkPackage workPackage = workPackageRepository.findById(workPackgeId).orElseThrow(() -> {
            throw new ResourceNotFoundException("WorkPackage", "workPackageId", workPackgeId.toString());
        });

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        if (workPackage.getAssignee() == null || !user.getId().equals(workPackage.getAssignee().getId())) {
            throw new IllegalStateException("You can't create an issue in a workpackge that is not assigned to you");
        }

        Issue issue = Issue.builder()
                .id(issueDto.getId())
                .title(issueDto.getTitle())
                .description(issueDto.getDescription())
                .issueStatus(IssueStatus.UNRESOLVED)
                .workPackage(workPackage)
                .build();

        issueRepository.save(issue);
    }

    @Override
    public void updateIssue(IssueDto issueDto, Long issueId) {
        Issue issue = issueRepository.findById(issueId).orElseThrow(() -> {
            throw new ResourceNotFoundException("Issue", "issueId", issueId.toString());
        });

        issue.setTitle(issueDto.getTitle());
        issue.setDescription(issueDto.getDescription());
        issue.setIssueStatus(issueDto.getIssueStatus());

        issueRepository.save(issue);
    }

    @Override
    public void deleteIssue(Long issueId) {
        Issue issue = issueRepository.findById(issueId).orElseThrow(() -> {
            throw new ResourceNotFoundException("Issue", "issueId", issueId.toString());
        });
        issueRepository.delete(issue);
    }

    @Override
    public IssueDto getIssueById(Long issueId) {
        Issue issue = issueRepository.findById(issueId).orElseThrow(() -> {
            throw new ResourceNotFoundException("Issue", "issueId", issueId.toString());
        });
        return IssueMapper.toDto(issue);
    }

    @Override
    public List<IssueDto> getByWorkPackgeId(Long workPackageId) {
        return issueRepository.findAll().stream()
                .filter(issue -> issue.getWorkPackage().getId().equals(workPackageId))
                .map(IssueMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public Page<IssueDto> getIssuesByUser(Long userId, Pageable pageable) {
        return issueRepository.findByCreatedBy(userId, pageable)
                .map(IssueMapper::toDto);
    }

    @Override
    public Page<IssueDto> getIssuesToResolve(Long userId, Pageable pageable) {
        return issueRepository.findByWorkPackageAccountableId(userId, pageable)
                .map(IssueMapper::toDto);
    }

    @Override
    public void resolveIssue(Long issueId) {
        Issue issue = issueRepository.findById(issueId).orElseThrow(() -> {
            throw new ResourceNotFoundException("Issue", "issueId", issueId.toString());
        });

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) authentication.getPrincipal();

        if (issue.getWorkPackage().getAccountable() == null
                || !user.getId().equals(issue.getWorkPackage().getAccountable().getId())) {
            throw new IllegalStateException("Only the accountable user can resolve this issue");
        }

        issue.setIssueStatus(IssueStatus.RESOLVED);
        issueRepository.save(issue);
    }
}
