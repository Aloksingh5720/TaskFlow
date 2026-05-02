package com.nexabyte.taskflow.controller;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.nexabyte.taskflow.constants.ProjectStatus;
import com.nexabyte.taskflow.constants.WorkPackagePriority;
import com.nexabyte.taskflow.constants.WorkPackageStatus;
import com.nexabyte.taskflow.constants.WorkPackageType;
import com.nexabyte.taskflow.dto.gantt.GanttTaskDto;
import com.nexabyte.taskflow.dto.project.ProjectDto;
import com.nexabyte.taskflow.dto.projectmember.ProjectMemberDto;
import com.nexabyte.taskflow.dto.workpackage.WorkPackageDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.service.ProjectService;
import com.nexabyte.taskflow.service.RoleService;
import com.nexabyte.taskflow.service.UserService;
import com.nexabyte.taskflow.service.WorkPackageService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/projects")
@RequiredArgsConstructor
public class ProjectController {

    private final ProjectService projectService;
    private final WorkPackageService workPackageService;
    private final UserService userService;
    private final RoleService roleService;

    @GetMapping
    public String listProjects(
            @PageableDefault(size = 10, sort = "id", direction = Sort.Direction.DESC) Pageable pageable,
            @RequestParam(required = false) String search,
            Model model) {
        populateProjectListModel(model, pageable, search);
        return "project/list";
    }

    @GetMapping("/new")
    public String showCreateForm(@RequestParam(required = false) Long parentId, Model model) {
        ProjectDto projectDto = new ProjectDto();
        projectDto.setParentId(parentId);
        model.addAttribute("project", projectDto);
        model.addAttribute("projects", projectService.getAllProjectsForParentSelect());
        return "project/form";
    }

    @PostMapping
    public String createProject(@Valid @ModelAttribute("createProjectForm") ProjectDto projectDto,
            BindingResult result,
            Model model,
            RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            populateProjectListModel(model, PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "id")), null);
            model.addAttribute("showCreateProjectModal", true);
            return "project/list";
        }
        ProjectDto created = projectService.createProject(projectDto);
        redirectAttributes.addFlashAttribute("message", "Project created successfully");
        return "redirect:/projects/" + created.getId();
    }

    @GetMapping("/{id}")
    public String viewProject(@PathVariable Long id,
            @RequestParam(required = false) String openCreateWorkPackageModal,
            @AuthenticationPrincipal User user,
            Model model) {
        ProjectDto project = projectService.getProjectById(id);
        model.addAttribute("project", project);

        // Fetch last 5 updated workpackges
        Page<WorkPackageDto> workPackages = workPackageService.getLastNUpdatedWorkPackages(id,
                Pageable.ofSize(5));
        model.addAttribute("workPackages", workPackages);

        // // Fetch last 5 updated members
        Page<ProjectMemberDto> members = projectService.getLastNAddedMembers(id, Pageable.ofSize(5));
        model.addAttribute("members", members);
        model.addAttribute("canManageProjectActions", projectService.canManageProject(id));
        model.addAttribute("showAdminOption", projectService.canSeeAdminOption(id));
        model.addAttribute("currentUserId", user != null ? user.getId() : null);
        model.addAttribute("canCreateWorkPackage", projectService.canCreateWorkPackge(id));
        model.addAttribute("projectStatuses", ProjectStatus.values());
        model.addAttribute("types", WorkPackageType.values());
        model.addAttribute("statuses", WorkPackageStatus.values());
        model.addAttribute("priorities", WorkPackagePriority.values());
        model.addAttribute("workPackageMembers", projectService.getProjectMembers(id));
        if (!model.containsAttribute("createWorkPackageForm")) {
            model.addAttribute("createWorkPackageForm", WorkPackageDto.builder().projectId(id).build());
        }
        model.addAttribute("showCreateWorkPackageModal",
                model.containsAttribute("showCreateWorkPackageModal") || openCreateWorkPackageModal != null);
        model.addAttribute("createProjectForm", ProjectDto.builder().parentId(id).build());
        model.addAttribute("parentProjects", projectService.getAllProjectsForParentSelect());

        List<ProjectDto> childProjects = projectService.getSubprojects(id);
        model.addAttribute("childProjects", childProjects);
        model.addAttribute("childProjectsCount", childProjects.size());

        // For member modals
        model.addAttribute("availableUsers", projectService.getUsersNotInProject(id));
        model.addAttribute("roles", roleService.getAllProjectRoles());

        return "project/view";
    }

    @GetMapping("/{id}/gantt-tasks")
    @ResponseBody
    public List<GanttTaskDto> getProjectGanttTasks(@PathVariable Long id) {
        return workPackageService.getProjectGanttTasks(id);
    }

    @GetMapping("/{id}/gantt")
    public String showGantt(@PathVariable Long id, Model model) {
        model.addAttribute("project", projectService.getProjectById(id));
        return "project/gantt";
    }

    @GetMapping("/{id}/edit")
    public String showEditForm(@PathVariable Long id, Model model) {
        model.addAttribute("project", projectService.getProjectById(id));
        model.addAttribute("projects", projectService.getAllProjectsForParentSelect());
        model.addAttribute("projectStatuses", ProjectStatus.values());
        return "project/form";
    }

    @PostMapping("/{id}/change-status")
    public String changeProjectStatus(@PathVariable Long id, @ModelAttribute("project") ProjectDto projectDto) {
        projectService.updateProjectStatus(id, projectDto.getProjectStatus());
        return "redirect:/projects/" + id;
    }

    @GetMapping("/{id}/settings")
    public String showSettings(@PathVariable Long id, Model model) {
        model.addAttribute("project", projectService.getProjectById(id));
        return "project/settings";
    }

    @PostMapping("/{id}")
    public String updateProject(@PathVariable Long id,
            @Valid @ModelAttribute("project") ProjectDto projectDto,
            BindingResult result,
            RedirectAttributes redirectAttributes,
            Model model) {
        if (result.hasErrors()) {
            model.addAttribute("projects", projectService.getAllProjectsForParentSelect());
            model.addAttribute("projectStatuses", ProjectStatus.values());
            return "project/form";
        }
        projectService.updateProject(id, projectDto);
        redirectAttributes.addFlashAttribute("message", "Project updated");
        return "redirect:/projects/" + id;
    }

    @PostMapping("/{id}/delete")
    public String deleteProject(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        projectService.deleteProject(id);
        redirectAttributes.addFlashAttribute("message", "Project deleted");
        return "redirect:/projects";
    }

    @GetMapping("/{projectId}/members")
    public String listMembers(@PathVariable Long projectId,
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable,
            @RequestParam(required = false) String search,
            Model model) {
        Page<ProjectMemberDto> members = (search != null && !search.trim().isEmpty())
                ? projectService.searchProjectMembers(projectId, search, pageable)
                : projectService.getLastNAddedMembers(projectId, pageable);
        model.addAttribute("project", projectService.getProjectById(projectId));
        model.addAttribute("members", members);
        model.addAttribute("search", search);
        model.addAttribute("canManageProjectActions", projectService.canManageProject(projectId));
        model.addAttribute("availableUsers", projectService.getUsersNotInProject(projectId));
        model.addAttribute("roles", roleService.getAllProjectRoles());
        return "project/members";
    }

    @GetMapping("/{projectId}/members/add")
    public String showAddMemberForm(@PathVariable Long projectId, Model model) {
        ProjectMemberDto dto = new ProjectMemberDto();
        dto.setProjectId(projectId);
        model.addAttribute("member", dto);
        model.addAttribute("project", projectService.getProjectById(projectId));
        model.addAttribute("users", projectService.getUsersNotInProject(projectId));
        model.addAttribute("roles", roleService.getAllProjectRoles());
        return "project/member-form";
    }

    @PostMapping("/{projectId}/members")
    public String addMember(@PathVariable Long projectId,
            @RequestParam Long userId,
            @RequestParam(required = false) Long roleId,
            RedirectAttributes redirectAttributes) {
        projectService.addMember(projectId, userId, roleId);
        redirectAttributes.addFlashAttribute("message", "Member added successfully");
        return "redirect:/projects/" + projectId + "/members";
    }

    @GetMapping("/{projectId}/members/{memberId}/edit")
    public String showEditMemberForm(@PathVariable Long projectId,
            @PathVariable Long memberId,
            Model model) {
        ProjectMemberDto member = projectService.getProjectMemberById(memberId);
        model.addAttribute("member", member);
        model.addAttribute("project", projectService.getProjectById(projectId));
        model.addAttribute("users", userService.getAllUsers()); // for display only
        model.addAttribute("roles", roleService.getAllProjectRoles());
        return "project/member-form";
    }

    @PostMapping("/{projectId}/members/{memberId}")
    public String updateMember(@PathVariable Long projectId,
            @PathVariable Long memberId,
            @RequestParam(required = false) Long roleId,
            RedirectAttributes redirectAttributes) {
        // Assuming we have a method to update member roles
        projectService.updateMemberRoles(memberId, roleId);
        redirectAttributes.addFlashAttribute("message", "Member roles updated");
        return "redirect:/projects/" + projectId + "/members";
    }

    @PostMapping("/{projectId}/members/{memberId}/delete")
    public String removeMember(@PathVariable Long projectId,
            @PathVariable Long memberId,
            RedirectAttributes redirectAttributes) {
        projectService.removeMember(memberId);
        redirectAttributes.addFlashAttribute("message", "Member removed");
        return "redirect:/projects/" + projectId + "/members";
    }

    private void populateProjectListModel(Model model, Pageable pageable, String search) {
        Page<ProjectDto> projects = (search != null && !search.trim().isEmpty())
                ? projectService.searchProjects(search, pageable)
                : projectService.getProjects(pageable);
        model.addAttribute("projects", projects);
        Map<Long, List<ProjectDto>> childProjectsByParentId = projectService.getSubprojectsByParentIds(
                projects.getContent().stream().map(ProjectDto::getId).toList());
        model.addAttribute("childProjectsByParentId", childProjectsByParentId);
        model.addAttribute("canDeleteProjectById", buildProjectDeletePermissionMap(projects, childProjectsByParentId));
        model.addAttribute("search", search);
        if (!model.containsAttribute("createProjectForm")) {
            model.addAttribute("createProjectForm", new ProjectDto());
        }
        model.addAttribute("parentProjects", projectService.getAllProjectsForParentSelect());
        model.addAttribute("projectStatuses", ProjectStatus.values());
    }

    private Map<Long, Boolean> buildProjectDeletePermissionMap(Page<ProjectDto> projects,
            Map<Long, List<ProjectDto>> childProjectsByParentId) {
        List<Long> projectIds = projects.getContent().stream()
                .map(ProjectDto::getId)
                .collect(Collectors.toList());

        childProjectsByParentId.values().stream()
                .flatMap(List::stream)
                .map(ProjectDto::getId)
                .forEach(projectIds::add);

        return projectIds.stream()
                .distinct()
                .collect(Collectors.toMap(
                        projectId -> projectId,
                        projectService::canDeleteProject));
    }
}
