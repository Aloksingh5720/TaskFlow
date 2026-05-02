package com.nexabyte.taskflow.service.impl;

import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import com.nexabyte.taskflow.constants.GlobalRole;

import com.nexabyte.taskflow.constants.ProjectRole;
import com.nexabyte.taskflow.constants.ProjectStatus;
import com.nexabyte.taskflow.dto.project.ProjectDto;
import com.nexabyte.taskflow.dto.projectmember.ProjectMemberDto;
import com.nexabyte.taskflow.dto.user.CreateUserDto;
import com.nexabyte.taskflow.entities.Activity;
import com.nexabyte.taskflow.entities.Project;
import com.nexabyte.taskflow.entities.ProjectMember;
import com.nexabyte.taskflow.entities.Role;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.exception.AccessDeniedException;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.mapper.ProjectMapper;
import com.nexabyte.taskflow.mapper.ProjectMemberMapper;
import com.nexabyte.taskflow.mapper.UserMapper;
import com.nexabyte.taskflow.repository.ActivityRepository;
import com.nexabyte.taskflow.repository.ProjectMemberRepository;
import com.nexabyte.taskflow.repository.ProjectRepository;
import com.nexabyte.taskflow.repository.RoleRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.service.ActivityService;
import com.nexabyte.taskflow.service.ProjectService;
import com.nexabyte.taskflow.service.UiIdGeneratorService;
import com.nexabyte.taskflow.utils.SecurityUtils;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

@Service
@RequiredArgsConstructor
public class ProjectServiceImpl implements ProjectService {

    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ProjectMemberRepository projectMemberRepository;
    private final ActivityRepository activityRepository;
    private final ActivityService activityService;
    private final UiIdGeneratorService uiIdGeneratorService;

    @Override
    @Transactional
    @PreAuthorize("@projectSecurity.canCreateProject(#projectDto.parentId)")
    public ProjectDto createProject(ProjectDto projectDto) {
        User user = SecurityUtils.getCurrentUser();
        Project parentProject = null;

        Project project = new Project();
        project.setName(projectDto.getName());
        project.setDescription(projectDto.getDescription());
        project.setProjectStatus(ProjectStatus.NOT_STARTED);

        if (projectDto.getParentId() != null) {
            parentProject = projectRepository.findById(projectDto.getParentId())
                    .orElseThrow(() -> new ResourceNotFoundException("Parent project not found"));
            project.setParent(parentProject);
        }

        Project savedProject = projectRepository.save(project);
        savedProject.setUiId(uiIdGeneratorService.generateProjectUiId(savedProject.getId()));
        savedProject = projectRepository.save(savedProject);
        final Project createdProject = savedProject;

        Role projectManagerRole = roleRepository.findByName(ProjectRole.MANAGER)
                .orElseThrow(() -> new ResourceNotFoundException("Default role not found"));

        createProjectMembership(createdProject, user, projectManagerRole);

        if (parentProject != null) {
            projectMemberRepository.findByProjectId(parentProject.getId()).stream()
                    .filter(parentMember -> ProjectRole.MANAGER.equals(parentMember.getRole().getName()))
                    .map(ProjectMember::getUser)
                    .filter(parentManager -> !parentManager.getId().equals(user.getId()))
                    .forEach(parentManager -> createProjectMembership(createdProject, parentManager, projectManagerRole));
        }

        ProjectDto savedProjectDto = populateCreator(ProjectMapper.toDto(savedProject));
        activityService.recordProjectCreated(savedProjectDto, user.getUsername());
        return savedProjectDto;
    }

    @Override
    @PreAuthorize("@projectSecurity.canWriteViaProjectId(#projectId)")
    public ProjectDto updateProject(Long projectId, ProjectDto projectDto) {
        User user = SecurityUtils.getCurrentUser();

        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new IllegalArgumentException("Project not found with id: " + projectId));

        if (projectDto.getName() != null) {
            project.setName(projectDto.getName());
        }
        if (projectDto.getDescription() != null) {
            project.setDescription(projectDto.getDescription());
        }
        if (projectDto.getProjectStatus() != null) {
            project.setProjectStatus(projectDto.getProjectStatus());
        }
        if (projectDto.getParentId() != null) {
            Project parent = projectRepository.findById(projectDto.getParentId())
                    .orElseThrow(() -> new RuntimeException("Parent project not found"));
            project.setParent(parent);
        } else {
            project.setParent(null);
        }

        Project savedProject = projectRepository.save(project);

        ProjectDto savedProjectDto = populateCreator(ProjectMapper.toDto(savedProject));
        activityService.recordProjectUpdated(savedProjectDto, user.getUsername());
        return savedProjectDto;
    }

    @Override
    @Transactional
    @PreAuthorize("@projectSecurity.canDeleteViaProjectId(#projectId)")
    public void deleteProject(Long projectId) {
        User user = SecurityUtils.getCurrentUser();
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Project",
                        "projectId",
                        projectId.toString()));

        Set<User> members = projectMemberRepository.findUsersByProjectId(projectId);

        Activity activity = Activity.builder()
                .description(String.format("Deleted project: %s", project.getName()))
                .project(project)
                .actor(user.getUsername())
                .users(members)
                .build();

        activityRepository.save(activity);
        projectRepository.delete(project);
    }

    @Override
    @PreAuthorize("@projectSecurity.canViewViaProjectId(#projectId)")
    public ProjectDto getProjectById(Long projectId) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", "projectId", projectId.toString()));

        return populateCreator(ProjectMapper.toDto(project));
    }

    @Override
    public Page<ProjectDto> getProjects(Pageable pageable) {
        User user = getCurrentUser();
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;
        Page<Project> projectPage = GlobalRole.SUPER_ADMIN.equals(globalRoleName)
                ? projectRepository.findByArchivedFalseAndParentIsNull(pageable)
                : projectRepository.findAccessibleProjects(user.getId(), pageable);
        return projectPage.map(project -> populateCreator(ProjectMapper.toDto(project)));
    }

    @Override
    public Page<ProjectDto> searchProjects(String searchTerm, Pageable pageable) {
        User user = getCurrentUser();
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;
        String normalizedSearchTerm = searchTerm == null ? "" : searchTerm.trim();

        if (normalizedSearchTerm.isEmpty()) {
            return getProjects(pageable);
        }

        Page<Project> projectPage = GlobalRole.SUPER_ADMIN.equals(globalRoleName)
                ? projectRepository.searchActiveProjects(normalizedSearchTerm, pageable)
                : projectRepository.searchAccessibleProjects(user.getId(), normalizedSearchTerm, pageable);
        return projectPage.map(project -> populateCreator(ProjectMapper.toDto(project)));
    }

    @Override
    public List<ProjectDto> getAllProjectsForParentSelect() {
        List<ProjectDto> projects = projectRepository.findAll().stream()
                .map(ProjectMapper::toDto)
                .toList();
        populateCreators(projects);
        return projects;
    }

    @Override
    public List<ProjectDto> getAllProjectsWhereUserIsManager(Long userId) {
        User user = userRepository.findById(userId).orElseThrow(() -> {
            throw new ResourceNotFoundException("User", "userId", userId.toString());
        });

        String globalRole = user.getGlobalRole().getName();
        boolean isSuperAdminOrAdmin = GlobalRole.SUPER_ADMIN.equals(globalRole)
                || GlobalRole.ADMIN.equals(globalRole);

        if (isSuperAdminOrAdmin) {
            List<ProjectDto> projects = projectRepository.findAll().stream()
                    .map(ProjectMapper::toDto)
                    .toList();
            populateCreators(projects);
            return projects;
        }

        List<ProjectDto> projects = projectRepository.findAllProjectsWhereUserIsManager(userId).stream()
                .map(ProjectMapper::toDto)
                .toList();
        populateCreators(projects);
        return projects;
    }

    @Override
    public ProjectMemberDto getProjectMemberById(Long memberId) {
        ProjectMember member = projectMemberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Project member not found"));
        return ProjectMemberMapper.toDto(member);
    }

    @Override
    public void updateMemberRoles(Long memberId, Long roleId) {
        ProjectMember projectMember = projectMemberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Project member not found with id: " + memberId));

        Role role = roleRepository.findById(roleId)
                .orElseThrow(() -> new RuntimeException("Role not found with id: " + roleId));

        boolean isProjectRole = role.getName().equals(ProjectRole.MANAGER) ||
                role.getName().equals(ProjectRole.MEMBER) ||
                role.getName().equals(ProjectRole.VIEWER);

        if (!isProjectRole) {
            throw new IllegalArgumentException("Only project roles (MANAGER, MEMBER, VIEWER) can be assigned");
        }

        projectMember.setRole(role);
        projectMemberRepository.save(projectMember);
    }

    @Override
    public void addMember(Long projectId, Long userId, Long roleId) {
        User currentUser = SecurityUtils.getCurrentUser();
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", "projectId", projectId.toString()));

        if (project.getParent() != null) {
            boolean isParentMember = projectMemberRepository.findByProjectId(project.getParent().getId()).stream()
                    .anyMatch(pm -> pm.getUser().getId().equals(userId));
            if (!isParentMember) {
                throw new IllegalArgumentException("User must be a member of the parent project first");
            }
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Role role = roleRepository.findById(roleId)
                .orElseThrow(() -> new RuntimeException("Role not found with id: " + roleId));

        boolean isProjectRole = role.getName().equals(ProjectRole.MANAGER) ||
                role.getName().equals(ProjectRole.MEMBER) ||
                role.getName().equals(ProjectRole.VIEWER);

        if (!isProjectRole) {
            throw new IllegalArgumentException("Only project roles (MANAGER, MEMBER, VIEWER) can be assigned");
        }

        ProjectMember projectMember = ProjectMember.builder()
                .project(project)
                .user(user)
                .role(role)
                .build();

        ProjectMember savedMember = projectMemberRepository.save(projectMember);
        savedMember.setUiId(uiIdGeneratorService.generateMemberUiId(savedMember.getId()));
        savedMember = projectMemberRepository.save(savedMember);
        activityService.recordMemberAdded(
                ProjectMapper.toDto(project),
                ProjectMemberMapper.toDto(savedMember),
                currentUser.getUsername());

        if (ProjectRole.MANAGER.equals(role.getName())) {
            propagateManagerToChildProjects(project, user, role);
        }
    }

    @Override
    public void removeMember(Long memberId) {
        User currentUser = SecurityUtils.getCurrentUser();
        ProjectMember projectMember = projectMemberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        Project project = projectMember.getProject();

        projectMemberRepository.delete(projectMember);
        activityService.recordMemberRemoved(
                ProjectMapper.toDto(project),
                ProjectMemberMapper.toDto(projectMember),
                currentUser.getUsername());
    }

    @Override
    @PreAuthorize("@projectSecurity.canViewViaProjectId(#parentId)")
    public List<ProjectDto> getSubprojects(Long parentId) {

        if (parentId == null) {
            throw new IllegalArgumentException("Parent project ID cannot be null");
        }

        if (!projectRepository.existsById(parentId)) {
            throw new RuntimeException("Parent project not found with id: " + parentId);
        }

        User user = getCurrentUser();
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;

        List<Project> subprojects;

        // Super admin can see all subprojects
        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName)) {
            subprojects = projectRepository.findByParentId(parentId);
        } else {
            // For other roles, only return subprojects where the user has access
            subprojects = projectRepository.findAccessibleSubprojectsByParentId(user.getId(), parentId);
        }

        return subprojects.stream()
                .map(ProjectMapper::toDto)
                .collect(Collectors.collectingAndThen(Collectors.toList(), projects -> {
                    populateCreators(projects);
                    return projects;
                }));
    }

    @Override
    public Map<Long, List<ProjectDto>> getSubprojectsByParentIds(List<Long> parentIds) {
        if (parentIds == null || parentIds.isEmpty()) {
            return Map.of();
        }

        List<ProjectDto> childProjects = projectRepository.findByParentIdIn(parentIds).stream()
                .filter(project -> !project.isArchived())
                .map(ProjectMapper::toDto)
                .toList();
        populateCreators(childProjects);

        Map<Long, List<ProjectDto>> grouped = new LinkedHashMap<>();
        for (Long parentId : parentIds) {
            grouped.put(parentId, childProjects.stream()
                    .filter(project -> parentId.equals(project.getParentId()))
                    .toList());
        }
        return grouped;
    }

    private ProjectDto populateCreator(ProjectDto projectDto) {
        if (projectDto.getCreatedBy() != null) {
            userRepository.findById(projectDto.getCreatedBy())
                    .ifPresent(user -> projectDto.setCreator(user.getUsername()));
        }
        return projectDto;
    }

    private void populateCreators(List<ProjectDto> projects) {
        Set<Long> creatorIds = projects.stream()
                .map(ProjectDto::getCreatedBy)
                .filter(id -> id != null)
                .collect(Collectors.toSet());

        if (creatorIds.isEmpty()) {
            return;
        }

        Map<Long, String> usernamesById = userRepository.findAllById(creatorIds).stream()
                .collect(Collectors.toMap(User::getId, User::getUsername));

        projects.forEach(project -> {
            if (project.getCreatedBy() != null) {
                project.setCreator(usernamesById.get(project.getCreatedBy()));
            }
        });
    }

    @Override
    @Transactional
    public List<ProjectMemberDto> getProjectMembers(Long projectId) {

        if (projectId == null) {
            throw new IllegalArgumentException("Project ID cannot be null");
        }

        if (!projectRepository.existsById(projectId)) {
            throw new RuntimeException("Project not found with id: " + projectId);
        }

        return projectMemberRepository.findByProjectId(projectId).stream()
                .map(ProjectMemberMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<CreateUserDto> getUsersNotInProject(Long projectId) {

        if (projectId == null) {
            throw new IllegalArgumentException("Project ID cannot be null");
        }

        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", "projectId", projectId.toString()));

        List<User> usersNotInProject;
        if (project.getParent() != null) {
            usersNotInProject = userRepository.findUsersInParentButNotInChild(project.getParent().getId(),
                    project.getId());
        } else {
            usersNotInProject = userRepository.findUsersNotInProject(project.getId());
        }

        return usersNotInProject.stream()
                .map(UserMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public Page<ProjectMemberDto> getLastNAddedMembers(Long projectId, Pageable pageable) {

        if (projectId == null) {
            throw new IllegalArgumentException("Project ID cannot be null");
        }

        if (!projectRepository.existsById(projectId)) {
            throw new RuntimeException("Project not found with id: " + projectId);
        }

        Page<ProjectMember> projectMembers = projectMemberRepository.findRecentlyAddedMembers(projectId, pageable);
        return projectMembers.map(ProjectMemberMapper::toDto);
    }

    @Override
    public Page<ProjectMemberDto> searchProjectMembers(Long projectId, String searchTerm, Pageable pageable) {

        if (projectId == null) {
            throw new IllegalArgumentException("Project ID cannot be null");
        }

        if (!projectRepository.existsById(projectId)) {
            throw new RuntimeException("Project not found with id: " + projectId);
        }

        String normalizedSearchTerm = searchTerm == null ? "" : searchTerm.trim();
        if (normalizedSearchTerm.isEmpty()) {
            return getLastNAddedMembers(projectId, pageable);
        }

        Page<ProjectMember> projectMembers = projectMemberRepository.searchProjectMembers(projectId,
                normalizedSearchTerm, pageable);
        return projectMembers.map(ProjectMemberMapper::toDto);
    }

    @Override
    public long countAccessibleProjects(Long userId) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "userId", userId.toString()));

        String globalRoleName = user.getGlobalRole().getName();

        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName)) {
            return projectRepository.countByArchivedFalseAndParentIsNull();
        }

        if (GlobalRole.ADMIN.equals(globalRoleName)) {
            return projectRepository.countProjectsWhereUserIsManagerNotIncludingChild(userId);
        }

        return projectRepository.countProjectsWhereUserHasAnyRoleNotIncludingChild(userId);
    }

    @Override
    public boolean canManageProject(Long projectId) {
        if (projectId == null) {
            return false;
        }
        User user = getCurrentUser();
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;
        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName) || GlobalRole.ADMIN.equals(globalRoleName)) {
            return true;
        }

        return projectMemberRepository.existsByProjectIdAndUserIdAndRole_NameIn(
                projectId,
                user.getId(),
                List.of(ProjectRole.MANAGER));
    }

    @Override
    public boolean canDeleteProject(Long projectId) {
        if (projectId == null) {
            return false;
        }

        User user = getCurrentUser();
        if (user == null || user.getGlobalRole() == null) {
            return false;
        }

        String globalRoleName = user.getGlobalRole().getName();
        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName)) {
            return true;
        }

        return projectMemberRepository.existsByProjectIdAndUserIdAndRole_Name(
                projectId,
                user.getId(),
                ProjectRole.MANAGER);
    }

    @Override
    public boolean canSeeAdminOption(Long projectId) {
        if (projectId == null) {
            return false;
        }

        User user = getCurrentUser();

        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;
        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName) || GlobalRole.ADMIN.equals(globalRoleName)) {
            return true;
        }

        return projectMemberRepository.existsByProjectIdAndUserIdAndRole_Name(projectId, user.getId(),
                ProjectRole.MANAGER);
    }

    @Override
    @Transactional
    public boolean canCreateWorkPackge(Long projectId) {
        if (projectId == null) {
            return false;
        }

        User user = getCurrentUser();
        String globalRoleName = user.getGlobalRole().getName();
        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName) || GlobalRole.ADMIN.equals(globalRoleName)) {
            return true;
        }

        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", "projectId", projectId.toString()));

        ProjectMember membership = project.getProjectMembers().stream()
                .filter(member -> member.getUser().getId().equals(user.getId()))
                .findFirst()
                .orElseThrow(() -> new AccessDeniedException(
                        "Can't create work packages, you are not a member of this project\""));

        String roleName = membership.getRole().getName();

        if (roleName.equals(ProjectRole.VIEWER)) {
            return false;
        }

        return true;
    }

    @Override
    public void updateProjectStatus(Long projectId, ProjectStatus status) {
        Project project = projectRepository.findById(projectId).orElseThrow(() -> {
            return new ResourceNotFoundException("Project", "projectId", projectId.toString());
        });

        project.setProjectStatus(status);
        projectRepository.save(project);
    }

    private ProjectMember createProjectMembership(Project project, User user, Role role) {
        ProjectMember projectMember = ProjectMember.builder()
                .project(project)
                .user(user)
                .role(role)
                .build();

        ProjectMember savedMember = projectMemberRepository.save(projectMember);
        savedMember.setUiId(uiIdGeneratorService.generateMemberUiId(savedMember.getId()));
        return projectMemberRepository.save(savedMember);
    }

    private void propagateManagerToChildProjects(Project parentProject, User user, Role managerRole) {
        for (Project childProject : projectRepository.findByParentId(parentProject.getId())) {
            upsertManagerMembership(childProject, user, managerRole);
            propagateManagerToChildProjects(childProject, user, managerRole);
        }
    }

    private void upsertManagerMembership(Project project, User user, Role managerRole) {
        ProjectMember existingMembership = projectMemberRepository.findByProjectId(project.getId()).stream()
                .filter(member -> member.getUser().getId().equals(user.getId()))
                .findFirst()
                .orElse(null);

        if (existingMembership == null) {
            createProjectMembership(project, user, managerRole);
            return;
        }

        if (!ProjectRole.MANAGER.equals(existingMembership.getRole().getName())) {
            existingMembership.setRole(managerRole);
            projectMemberRepository.save(existingMembership);
        }
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof User)) {
            return null;
        }
        return (User) authentication.getPrincipal();
    }
}
