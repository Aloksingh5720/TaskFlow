package com.nexabyte.taskflow.service;

import java.util.List;
import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import com.nexabyte.taskflow.constants.ProjectStatus;
import com.nexabyte.taskflow.dto.project.ProjectDto;
import com.nexabyte.taskflow.dto.projectmember.ProjectMemberDto;
import com.nexabyte.taskflow.dto.user.CreateUserDto;

public interface ProjectService {

	ProjectDto createProject(ProjectDto projectDto);

	ProjectDto updateProject(Long projectId, ProjectDto projectDto);

	void deleteProject(Long projectId);

	void updateProjectStatus(Long projectId, ProjectStatus status);

	ProjectDto getProjectById(Long projectId);

	Page<ProjectDto> getProjects(Pageable pageable);

	Page<ProjectDto> searchProjects(String searchTerm, Pageable pageable);

	List<ProjectDto> getAllProjectsForParentSelect();

	List<ProjectDto> getAllProjectsWhereUserIsManager(Long userId);

	ProjectMemberDto getProjectMemberById(Long memberId);

	void updateMemberRoles(Long memberId, Long roleId);

	void addMember(Long projectId, Long userId, Long roleId);

	void removeMember(Long memberId);

	List<ProjectDto> getSubprojects(Long parentId);

	Map<Long, List<ProjectDto>> getSubprojectsByParentIds(List<Long> parentIds);

	List<ProjectMemberDto> getProjectMembers(Long projectId);

	List<CreateUserDto> getUsersNotInProject(Long projectId);

	long countAccessibleProjects(Long userId);

	boolean canManageProject(Long projectId);

	boolean canDeleteProject(Long projectId);

	boolean canSeeAdminOption(Long projectId);

	// boolean canSeeAdminOption(Long userId);

	boolean canCreateWorkPackge(Long projectId);

	Page<ProjectMemberDto> getLastNAddedMembers(Long projectId, Pageable pageable);

	Page<ProjectMemberDto> searchProjectMembers(Long projectId, String searchTerm, Pageable pageable);
}
