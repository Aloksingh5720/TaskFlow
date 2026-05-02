package com.nexabyte.taskflow.security;

import java.util.List;

import org.springframework.stereotype.Component;

import com.nexabyte.taskflow.constants.GlobalRole;
import com.nexabyte.taskflow.constants.ProjectRole;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.repository.ProjectMemberRepository;
import com.nexabyte.taskflow.repository.WorkPackageRepository;
import com.nexabyte.taskflow.utils.SecurityUtils;

import lombok.RequiredArgsConstructor;

@Component("projectSecurity")
@RequiredArgsConstructor
public class ProjectSecurityEvaluator {

    private final ProjectMemberRepository projectMemberRepository;
    private final WorkPackageRepository workPackageRepository;

    /**
     * Check if the current user is SUPER_ADMIN or not
     * 
     * @return true or false
     */
    public boolean isSuperAdmin() {
        User user = SecurityUtils.getCurrentUser();

        if (GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName())) {
            return true;
        }

        return false;
    }

    public boolean isSuperAdminOrAdmin() {
        User user = SecurityUtils.getCurrentUser();

        if (GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName())
                || GlobalRole.ADMIN.equals(user.getGlobalRole().getName())) {
            return true;
        }

        return false;
    }

    public boolean canCreateProject(Long parentId) {
        User user = SecurityUtils.getCurrentUser();

        if (GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName())
                || GlobalRole.ADMIN.equals(user.getGlobalRole().getName())) {
            return true;
        }

        if (parentId == null) {
            return false;
        }

        return projectMemberRepository.existsByProjectIdAndUserIdAndRole_Name(
                parentId,
                user.getId(),
                ProjectRole.MANAGER);
    }

    /**
     * Check if the current user is allowed to view project details
     * 
     * @param projectId
     * @return true or false
     */
    public boolean canViewViaProjectId(Long projectId) {
        User user = SecurityUtils.getCurrentUser();

        if (GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName())
                || GlobalRole.ADMIN.equals(user.getGlobalRole().getName()))
            return true;

        return projectMemberRepository.existsByProjectIdAndUserId(
                projectId,
                user.getId());
    }

    /**
     * Check if the current user if allowed to edit in project
     * 
     * @param projectId
     * @return true or false
     */
    public boolean canWriteViaProjectId(Long projectId) {
        User user = SecurityUtils.getCurrentUser();

        if (GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName())
                || GlobalRole.ADMIN.equals(user.getGlobalRole().getName()))
            return true;

        return projectMemberRepository.existsByProjectIdAndUserIdAndRole_NameIn(
                projectId,
                user.getId(),
                List.of(ProjectRole.MANAGER, ProjectRole.MEMBER));
    }

    public boolean canDeleteViaProjectId(Long projectId) {
        User user = SecurityUtils.getCurrentUser();

        if (GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName()))
            return true;

        return projectMemberRepository.existsByProjectIdAndUserIdAndRole_Name(
                projectId,
                user.getId(),
                ProjectRole.MANAGER);
    }

    public boolean canViewViaWorkPackageId(Long workPackageId) {
        User user = SecurityUtils.getCurrentUser();

        if (GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName())
                || GlobalRole.ADMIN.equals(user.getGlobalRole().getName()))
            return true;

        return workPackageRepository.existsByIdAndAssigneeId(workPackageId, user.getId())
                || workPackageRepository.existsByIdAndAccountableId(workPackageId, user.getId());
    }

    public boolean canWriteViaWorkPackageId(Long workPackageId) {
        User user = SecurityUtils.getCurrentUser();

        if (GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName())
                || GlobalRole.ADMIN.equals(user.getGlobalRole().getName()))
            return true;

        Long projectId = workPackageRepository.findProjectIdById(workPackageId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkPackage not found"));

        return projectMemberRepository.existsByProjectIdAndUserIdAndRole_NameIn(
                projectId,
                user.getId(),
                List.of(ProjectRole.MANAGER, ProjectRole.MEMBER));
    }

    public boolean canDeleteViaWorkPackageId(Long workPackageId) {
        User user = SecurityUtils.getCurrentUser();

        if (GlobalRole.SUPER_ADMIN.equals(user.getGlobalRole().getName()))
            return true;

        Long projectId = workPackageRepository.findProjectIdById(workPackageId)
                .orElseThrow(() -> new ResourceNotFoundException("WorkPackage not found"));

        if (projectMemberRepository.existsByProjectIdAndUserIdAndRole_Name(
                projectId, user.getId(), ProjectRole.MANAGER))
            return true;

        return workPackageRepository.existsByIdAndAccountableId(workPackageId, user.getId());
    }
}
