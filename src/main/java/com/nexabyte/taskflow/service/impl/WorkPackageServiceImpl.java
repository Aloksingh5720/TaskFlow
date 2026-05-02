package com.nexabyte.taskflow.service.impl;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nexabyte.taskflow.constants.GlobalRole;
import com.nexabyte.taskflow.constants.ProjectRole;
import com.nexabyte.taskflow.constants.WorkPackagePriority;
import com.nexabyte.taskflow.constants.WorkPackageStatus;
import com.nexabyte.taskflow.constants.WorkPackageType;
import com.nexabyte.taskflow.dto.gantt.GanttTaskDto;
import com.nexabyte.taskflow.dto.mail.WorkPackageAssignmentDto;
import com.nexabyte.taskflow.dto.workpackage.WorkPackageDto;
import com.nexabyte.taskflow.entities.Project;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.entities.WorkPackage;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.mapper.WorkPackageMapper;
import com.nexabyte.taskflow.repository.ProjectMemberRepository;
import com.nexabyte.taskflow.repository.ProjectRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.repository.WorkPackageRepository;
import com.nexabyte.taskflow.service.ActivityService;
import com.nexabyte.taskflow.service.MailService;
import com.nexabyte.taskflow.service.UiIdGeneratorService;
import com.nexabyte.taskflow.service.WorkPackageService;
import com.nexabyte.taskflow.utils.SecurityUtils;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class WorkPackageServiceImpl implements WorkPackageService {

    private final WorkPackageRepository workPackageRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;
    private final MailService mailService;
    private final ProjectMemberRepository projectMemberRepository;
    private final ActivityService activityService;
    private final UiIdGeneratorService uiIdGeneratorService;

    @Override
    @Transactional
    @PreAuthorize("@projectSecurity.canWriteViaProjectId(#projectId)")
    public WorkPackageDto createWorkPackage(Long projectId, WorkPackageDto workPackageDto) {
        User user = SecurityUtils.getCurrentUser();
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", "projectId", projectId.toString()));

        User assignee = userRepository.getReferenceById(workPackageDto.getAssigneeId());
        User accountable = userRepository.getReferenceById(workPackageDto.getAccountableId());

        WorkPackage workPackage = WorkPackage.builder()
                .project(project)
                .workPackageType(workPackageDto.getWorkPackageType())
                .workPackageStatus(workPackageDto.getWorkPackageStatus())
                .workPackagePriority(workPackageDto.getWorkPackagePriority())
                .assignee(assignee)
                .accountable(accountable)
                .subject(workPackageDto.getSubject())
                .description(workPackageDto.getDescription())
                .estimatedHours(workPackageDto.getEstimatedHours())
                .dueDate(workPackageDto.getDueDate())
                .build();

        WorkPackage savedWorkPackage = workPackageRepository.save(workPackage);
        savedWorkPackage.setUiId(uiIdGeneratorService.generateWorkPackageUiId(savedWorkPackage.getId()));
        savedWorkPackage = workPackageRepository.save(savedWorkPackage);
        activityService.recordWorkPackageCreated(WorkPackageMapper.toDto(savedWorkPackage), user.getUsername());

        WorkPackageAssignmentDto workPackageAssignmentDto = WorkPackageAssignmentDto.builder()
                .projectId(projectId)
                .projectName(project.getName())
                .workPackageType(workPackage.getWorkPackageType().toString())
                .workPackageStatus(workPackage.getWorkPackageStatus().toString())
                .workPackagePriority(workPackage.getWorkPackagePriority().toString())
                .assigneeId(assignee.getId())
                .assigneeName(assignee.getName())
                .accountableId(accountable.getId())
                .accountableName(accountable.getName())
                .subject(workPackage.getSubject())
                .description(workPackage.getDescription())
                .estimatedHours(workPackage.getEstimatedHours().toPlainString())
                .dueDate(workPackage.getDueDate().toString())
                .build();

        mailService.sendWorkPackageAssignmentEmail(assignee.getEmail(), workPackageAssignmentDto);
        return WorkPackageMapper.toDto(workPackage);
    }

    @Override
    @PreAuthorize("@projectSecurity.canWriteViaWorkPackageId(#workPackageId)")
    public WorkPackageDto updateWorkPackage(Long workPackageId, WorkPackageDto workPackageDto) {
        User user = SecurityUtils.getCurrentUser();
        WorkPackage workPackage = workPackageRepository.findById(workPackageId)
                .orElseThrow(
                        () -> new ResourceNotFoundException(
                                "Workpackage",
                                "workPackageId",
                                workPackageId.toString()));

        User assignee = workPackageDto.getAssigneeId() != null
                ? userRepository.getReferenceById(workPackageDto.getAssigneeId())
                : null;

        User accountable = workPackageDto.getAccountableId() != null
                ? userRepository.getReferenceById(workPackageDto.getAccountableId())
                : null;

        if (workPackageDto.getWorkPackageType() != null) {
            workPackage.setWorkPackageType(workPackageDto.getWorkPackageType());
        }
        if (workPackageDto.getWorkPackageStatus() != null) {
            workPackage.setWorkPackageStatus(workPackageDto.getWorkPackageStatus());
        }
        if (workPackageDto.getWorkPackagePriority() != null) {
            workPackage.setWorkPackagePriority(workPackageDto.getWorkPackagePriority());
        }
        if (workPackageDto.getAssigneeId() != null) {
            workPackage.setAssignee(assignee);
        }
        if (workPackageDto.getAccountableId() != null) {
            workPackage.setAccountable(accountable);
        }
        if (workPackageDto.getSubject() != null) {
            workPackage.setSubject(workPackageDto.getSubject());
        }
        if (workPackageDto.getEstimatedHours() != null) {
            workPackage.setEstimatedHours(workPackageDto.getEstimatedHours());
        }
        if (workPackageDto.getDescription() != null) {
            workPackage.setDescription(workPackageDto.getDescription());
        }
        if (workPackageDto.getDueDate() != null) {
            workPackage.setDueDate(workPackageDto.getDueDate());
        }

        WorkPackage savedWorkPackage = workPackageRepository.save(workPackage);
        activityService.recordWorkPackageUpdated(WorkPackageMapper.toDto(savedWorkPackage), user.getUsername());

        return WorkPackageMapper.toDto(workPackage);
    }

    @Override
    @PreAuthorize("@projectSecurity.canWriteViaWorkPackageId(#workPackageId)")
    public WorkPackageDto updateClassification(Long workPackageId,
            WorkPackageType type,
            WorkPackageStatus status,
            WorkPackagePriority priority) {

        User user = SecurityUtils.getCurrentUser();
        WorkPackage workPackage = workPackageRepository.findById(workPackageId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Workpackage", "workPackageId", workPackageId.toString()));

        boolean canChangeClassification = canChangeWorkPackageClassification(workPackage, user);

        if (canChangeClassification && type != null) {
            workPackage.setWorkPackageType(type);
        }
        if (status != null) {
            workPackage.setWorkPackageStatus(status);
        }
        if (canChangeClassification && priority != null) {
            workPackage.setWorkPackagePriority(priority);
        }

        workPackageRepository.save(workPackage);
        return WorkPackageMapper.toDto(workPackage);
    }

    @Override
    @PreAuthorize("@projectSecurity.canWriteViaWorkPackageId(#workPackageId)")
    public WorkPackageDto updateStatus(Long workPackageId, WorkPackageStatus status) {

        WorkPackage workPackage = workPackageRepository.findById(workPackageId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Workpackage", "workPackageId", workPackageId.toString()));

        if (status != null) {
            workPackage.setWorkPackageStatus(status);
        }

        workPackageRepository.save(workPackage);
        return WorkPackageMapper.toDto(workPackage);
    }

    @Override
    @PreAuthorize("@projectSecurity.canDeleteViaWorkPackageId(#workPackageId)")
    public void deleteWorkPackage(Long workPackageId) {
        User user = SecurityUtils.getCurrentUser();
        WorkPackage workPackage = workPackageRepository.findById(workPackageId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Workpackage",
                        "workPackageId",
                        workPackageId.toString()));

        workPackageRepository.delete(workPackage);
        activityService.recordWorkPackageDeleted(WorkPackageMapper.toDto(workPackage), user.getUsername());
    }

    @Override
    @PreAuthorize("@projectSecurity.canViewViaWorkPackageId(#workPackageId)")
    public WorkPackageDto getWorkPackage(Long workPackageId) {
        WorkPackage workPackage = workPackageRepository.findById(workPackageId)
                .orElseThrow(
                        () -> new ResourceNotFoundException("Workpackage", "workPackageId", workPackageId.toString()));

        return WorkPackageMapper.toDto(workPackage);
    }

    @Override
    @PreAuthorize("@projectSecurity.canViewViaProjectId(#projectId)")
    public Page<WorkPackageDto> getAllWorkPackagesInProject(Long projectId, Pageable pageable) {
        User user = SecurityUtils.getCurrentUser();
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", "projectId", projectId.toString()));

        if (project.getParent() != null) {
            if (canSeeAllWorkPackages(user)) {
                return workPackageRepository.findByProjectId(projectId, pageable).map(WorkPackageMapper::toDto);
            }

            return workPackageRepository.findVisibleByProjectId(projectId, user.getId(), pageable)
                    .map(WorkPackageMapper::toDto);
        }

        List<Long> projectIds = new ArrayList<>();
        projectIds.add(projectId);
        projectRepository.findByParentId(projectId).forEach(child -> projectIds.add(child.getId()));

        if (canSeeAllWorkPackages(user)) {
            return workPackageRepository.findByProjectIdIn(projectIds, pageable).map(WorkPackageMapper::toDto);
        }

        return workPackageRepository.findVisibleByProjectIdIn(projectIds, user.getId(), pageable)
                .map(WorkPackageMapper::toDto);
    }

    @Override
    @PreAuthorize("@projectSecurity.canViewViaProjectId(#projectId)")
    public Page<WorkPackageDto> getWorkPackagesWithFilters(Long projectId,
            String search,
            WorkPackageType type,
            WorkPackageStatus status,
            WorkPackagePriority priority,
            Long assigneeId,
            Pageable pageable) {

        User user = SecurityUtils.getCurrentUser();
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", "projectId", projectId.toString()));

        String normalizedSearch = search == null || search.trim().isEmpty() ? null : search.trim();
        boolean canSeeAll = canSeeAllWorkPackages(user);

        // For top-level projects, include child projects
        if (project.getParent() == null) {
            List<Long> projectIds = new ArrayList<>();
            projectIds.add(projectId);
            projectRepository.findByParentId(projectId).forEach(child -> projectIds.add(child.getId()));

            if (canSeeAll) {
                return workPackageRepository
                        .findWorkPackagesWithFiltersInProjects(projectIds, normalizedSearch, type, status, priority,
                                assigneeId, pageable)
                        .map(WorkPackageMapper::toDto);
            }

            return workPackageRepository
                    .findVisibleWorkPackagesWithFiltersInProjects(projectIds, user.getId(), normalizedSearch, type,
                            status, priority, assigneeId, pageable)
                    .map(WorkPackageMapper::toDto);
        }

        // For child projects, just query the current project
        if (canSeeAll) {
            return workPackageRepository
                    .findWorkPackagesWithFilters(projectId, normalizedSearch, type, status, priority, assigneeId,
                            pageable)
                    .map(WorkPackageMapper::toDto);
        }

        return workPackageRepository
                .findVisibleWorkPackagesWithFilters(projectId, user.getId(), normalizedSearch, type, status, priority,
                        assigneeId, pageable)
                .map(WorkPackageMapper::toDto);
    }

    @Override
    @PreAuthorize("@projectSecurity.isSuperAdmin()")
    public Page<WorkPackageDto> getAllWorkPackages(Pageable pageable) {
        return workPackageRepository.findAll(pageable).map(WorkPackageMapper::toDto);
    }

    @Override
    @Transactional
    @PreAuthorize("@projectSecurity.canViewViaProjectId(#projectId)")
    public Page<WorkPackageDto> getLastNUpdatedWorkPackages(Long projectId, Pageable pageable) {
        User user = SecurityUtils.getCurrentUser();
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", "projectId", projectId.toString()));
        List<Long> projectIds = getProjectAndChildIds(project);

        boolean canSeeAll = canSeeAllWorkPackages(user);

        if (canSeeAll) {
            return workPackageRepository.findRecentByProjectIdIn(projectIds, pageable)
                    .map(WorkPackageMapper::toDto);
        }

        return workPackageRepository.findRecentByProjectIdInAndUserId(projectIds, user.getId(), pageable)
                .map(WorkPackageMapper::toDto);
    }

    @Override
    @PreAuthorize("@projectSecurity.canViewViaProjectId(#projectId)")
    public List<WorkPackageDto> getAllWorkPackagesByStatus(Long projectId, Long userId, WorkPackageStatus status) {
        User user = SecurityUtils.getCurrentUser();

        boolean canSeeAll = canSeeAllWorkPackages(user);

        if (canSeeAll) {
            return workPackageRepository.findByProjectIdAndWorkPackageStatus(projectId, status)
                    .stream().map(WorkPackageMapper::toDto).toList();
        }

        return workPackageRepository
                .findVisibleByProjectIdAndUserIdAndWorkPackageStatus(projectId, user.getId(), status)
                .stream().map(WorkPackageMapper::toDto).toList();
    }

    @Override
    @PreAuthorize("@projectSecurity.canViewViaProjectId(#projectId)")
    public List<WorkPackageDto> getAllWorkPackagesByStatusIncludingChildren(Long projectId,
            WorkPackageStatus status) {

        User user = SecurityUtils.getCurrentUser();
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", "projectId", projectId.toString()));

        List<Long> allProjectIds = projectRepository.findProjectIdAndChildIds(project.getId());

        if (!canSeeAllWorkPackages(user)) {
            return workPackageRepository.findVisibleByProjectIdInAndWorkPackageStatus(allProjectIds, user.getId(),
                    status)
                    .stream()
                    .map(WorkPackageMapper::toDto)
                    .toList();
        }

        return workPackageRepository.findByProjectIdInAndWorkPackageStatus(allProjectIds, status)
                .stream()
                .map(WorkPackageMapper::toDto)
                .toList();
    }

    @Override
    @PreAuthorize("@projectSecurity.canViewViaProjectId(#projectId)")
    public List<GanttTaskDto> getProjectGanttTasks(Long projectId) {
        projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", "projectId", projectId.toString()));

        return getAllWorkPackagesInProject(projectId, Pageable.unpaged())
                .getContent()
                .stream()
                .filter(workPackage -> workPackage.getCreatedAt() != null || workPackage.getDueDate() != null)
                .sorted(Comparator
                        .comparing(this::resolveStartDate, Comparator.nullsLast(LocalDate::compareTo))
                        .thenComparing(WorkPackageDto::getId, Comparator.nullsLast(Long::compareTo)))
                .map(workPackage -> {
                    LocalDate startDate = resolveStartDate(workPackage);
                    LocalDate endDate = resolveEndDate(workPackage, startDate);

                    return GanttTaskDto.builder()
                            .id(String.valueOf(workPackage.getId()))
                            .name(workPackage.getSubject())
                            .start(startDate.toString())
                            .end(endDate.toString())
                            .progress(resolveProgressPercent(workPackage.getWorkPackageStatus()))
                            .status(workPackage.getWorkPackageStatus().name())
                            .assignee(workPackage.getAssigneeName())
                            .build();
                })
                .toList();
    }

    @Override
    public Page<WorkPackageDto> getWorkPackagesByAssignee(Long userId, Pageable pageable) {
        User user = userRepository.findById(userId).orElseThrow(() -> {
            return new ResourceNotFoundException("User", "userId", userId.toString());
        });

        return workPackageRepository.findAssignedWorkPackages(user.getId(), pageable)
                .map(WorkPackageMapper::toDto);
    }

    @Override
    public Page<WorkPackageDto> getWorkPackagesByAccountable(Long userId, Pageable pageable) {
        User user = userRepository.findById(userId).orElseThrow(() -> {
            return new ResourceNotFoundException("User", "userId", userId.toString());
        });

        return workPackageRepository.findAccountableWorkPackages(user.getId(), pageable)
                .map(WorkPackageMapper::toDto);
    }

    @Override
    public Page<WorkPackageDto> getOverdueWorkPackages(Long userId, Pageable pageable) {
        User user = userRepository.findById(userId).orElseThrow(() -> {
            return new ResourceNotFoundException("User", "userId", userId.toString());
        });

        boolean isSuperAdmin = GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName());

        if (isSuperAdmin) {
            return workPackageRepository.findOverdue(LocalDate.now(), pageable)
                    .map(WorkPackageMapper::toDto);
        }

        return workPackageRepository.findAllOverdueByUserId(user.getId(), LocalDate.now(), pageable)
                .map(WorkPackageMapper::toDto);
    }

    @Override
    public long countAssignedWorkPackages(Long userId) {
        User user = userRepository.findById(userId).orElseThrow(() -> {
            return new ResourceNotFoundException("User", "userId", userId.toString());
        });

        return workPackageRepository.countAssigneeWorkPackages(user.getId());
    }

    @Override
    public long countAccountableWorkPackages(Long userId) {
        User user = userRepository.findById(userId).orElseThrow(() -> {
            return new ResourceNotFoundException("User", "userId", userId.toString());
        });

        return workPackageRepository.countAccountableWorkPackages(user.getId());
    }

    @Override
    public long countOverdueWorkPackages(Long userId) {
        User user = userRepository.findById(userId).orElseThrow(() -> {
            return new ResourceNotFoundException("User", "userId", userId.toString());
        });

        boolean isSuperAdmin = GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName());

        if (isSuperAdmin) {
            return workPackageRepository.countOverdue(LocalDate.now());
        }

        return workPackageRepository.countAllOverdueByUserId(user.getId(), LocalDate.now());
    }

    private LocalDate resolveStartDate(WorkPackageDto workPackage) {
        if (workPackage.getCreatedAt() != null) {
            return workPackage.getCreatedAt().toLocalDate();
        }
        if (workPackage.getDueDate() != null) {
            return workPackage.getDueDate().minusDays(1);
        }
        return LocalDate.now();
    }

    private LocalDate resolveEndDate(WorkPackageDto workPackage, LocalDate startDate) {
        if (workPackage.getDueDate() == null) {
            return startDate.plusDays(1);
        }
        if (workPackage.getDueDate().isBefore(startDate)) {
            return startDate.plusDays(1);
        }
        if (workPackage.getDueDate().isEqual(startDate)) {
            return startDate.plusDays(1);
        }
        return workPackage.getDueDate();
    }

    private int resolveProgressPercent(WorkPackageStatus status) {
        if (status == null) {
            return 0;
        }

        return switch (status) {
            case INITIAL -> 0;
            case IN_PROGRESS -> 50;
            case ON_HOLD -> 25;
            case COMPLETED -> 100;
        };
    }

    private boolean canSeeAllWorkPackages(User user) {
        if (user == null || user.getGlobalRole() == null) {
            return false;
        }

        String globalRoleName = user.getGlobalRole().getName();
        return GlobalRole.SUPER_ADMIN.equals(globalRoleName) || GlobalRole.ADMIN.equals(globalRoleName);
    }

    private List<Long> getProjectAndChildIds(Project project) {
        List<Long> projectIds = new ArrayList<>();
        projectIds.add(project.getId());

        if (project.getParent() == null) {
            projectRepository.findByParentId(project.getId()).forEach(child -> projectIds.add(child.getId()));
        }

        return projectIds;
    }

    private boolean canChangeWorkPackageClassification(WorkPackage workPackage, User user) {
        if (canSeeAllWorkPackages(user)) {
            return true;
        }

        if (workPackage.getAccountable() != null && workPackage.getAccountable().getId().equals(user.getId())) {
            return true;
        }

        return projectMemberRepository.existsByProjectIdAndUserIdAndRole_Name(
                workPackage.getProject().getId(), user.getId(), ProjectRole.MANAGER);
    }
}
