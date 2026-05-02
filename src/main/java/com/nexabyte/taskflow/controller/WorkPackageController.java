package com.nexabyte.taskflow.controller;

import java.net.URI;
import java.util.Collections;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.nexabyte.taskflow.constants.IssueStatus;
import com.nexabyte.taskflow.constants.WorkPackagePriority;
import com.nexabyte.taskflow.constants.WorkPackageStatus;
import com.nexabyte.taskflow.constants.WorkPackageType;
import com.nexabyte.taskflow.dto.issue.IssueDto;
import com.nexabyte.taskflow.dto.workpackage.WorkPackageDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.service.AttachmentService;
import com.nexabyte.taskflow.service.CommentService;
import com.nexabyte.taskflow.service.IssueService;
import com.nexabyte.taskflow.service.ProjectService;
import com.nexabyte.taskflow.service.TimeEntryService;
import com.nexabyte.taskflow.service.UserService;
import com.nexabyte.taskflow.service.WorkPackageService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/work-packages")
@RequiredArgsConstructor
public class WorkPackageController {

    private final WorkPackageService workPackageService;
    private final UserService userService;
    private final ProjectService projectService;
    private final CommentService commentService;
    private final AttachmentService attachmentService;
    private final TimeEntryService timeEntryService;
    private final IssueService issueService;

    @GetMapping
    public String listAllWorkPackages(@RequestParam(required = false) Long projectId,
            @RequestParam(required = false) String openCreateWorkPackageModal,
            @AuthenticationPrincipal User user,
            Model model) {
        Page<WorkPackageDto> workPackages = projectId != null
                ? workPackageService.getAllWorkPackagesInProject(projectId, Pageable.unpaged())
                : Page.empty(Pageable.unpaged());
        model.addAttribute("workPackages", workPackages);
        model.addAttribute("title", "Work Package Administration");
        model.addAttribute("queryString", "");
        model.addAttribute("projects", projectService.getAllProjectsWhereUserIsManager(user.getId()));
        model.addAttribute("selectedProjectId", projectId);
        addAdminOptionLookup(model, workPackages, user);
        model.addAttribute("types", WorkPackageType.values());
        model.addAttribute("statuses", WorkPackageStatus.values());
        model.addAttribute("priorities", WorkPackagePriority.values());
        model.addAttribute("workPackageMembers",
                projectId != null ? projectService.getProjectMembers(projectId) : Collections.emptyList());
        if (!model.containsAttribute("createWorkPackageForm")) {
            model.addAttribute("createWorkPackageForm", WorkPackageDto.builder().projectId(projectId).build());
        }
        model.addAttribute("showCreateWorkPackageModal",
                model.containsAttribute("showCreateWorkPackageModal") || openCreateWorkPackageModal != null);
        return "workpackage/admin-list";
    }

    @GetMapping(params = "assignee=me")
    public String listAssigneeWorkPackages(@PageableDefault(size = 10) Pageable pageable,
            @AuthenticationPrincipal User user,
            Model model) {
        Page<WorkPackageDto> workPackages = workPackageService.getWorkPackagesByAssignee(user.getId(),
                pageable);
        model.addAttribute("workPackages", workPackages);
        model.addAttribute("title", "Assigned Work Packages");
        model.addAttribute("queryString", "");
        addAdminOptionLookup(model, workPackages, user);
        model.addAttribute("types", WorkPackageType.values());
        model.addAttribute("statuses", WorkPackageStatus.values());
        model.addAttribute("priorities", WorkPackagePriority.values());
        return "workpackage/assignee-list";
    }

    @GetMapping(params = "accountable=me")
    public String listAccountableWorkPackages(@PageableDefault(size = 10) Pageable pageable,
            @AuthenticationPrincipal User user,
            Model model) {
        Page<WorkPackageDto> workPackages = workPackageService.getWorkPackagesByAccountable(user.getId(),
                pageable);
        model.addAttribute("workPackages", workPackages);
        model.addAttribute("title", "Accountable Work Packages");
        model.addAttribute("queryString", "");
        addAdminOptionLookup(model, workPackages, user);
        model.addAttribute("types", WorkPackageType.values());
        model.addAttribute("statuses", WorkPackageStatus.values());
        model.addAttribute("priorities", WorkPackagePriority.values());
        return "workpackage/accountable-list";
    }

    @GetMapping(params = "overdue=true")
    public String listOverdueWorkPackages(@PageableDefault(size = 10) Pageable pageable,
            @AuthenticationPrincipal User user,
            Model model) {
        Page<WorkPackageDto> workPackages = workPackageService.getOverdueWorkPackages(user.getId(), pageable);
        model.addAttribute("workPackages", workPackages);
        model.addAttribute("title", "Overdue Work Packages");
        model.addAttribute("queryString", "");
        addAdminOptionLookup(model, workPackages, user);
        model.addAttribute("types", WorkPackageType.values());
        model.addAttribute("statuses", WorkPackageStatus.values());
        model.addAttribute("priorities", WorkPackagePriority.values());
        return "workpackage/list";
    }

    @GetMapping("/project/{projectId}")
    public String listProjectWorkPackages(@PathVariable Long projectId,
            @PageableDefault(size = 10) Pageable pageable,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) WorkPackageType type,
            @RequestParam(required = false) WorkPackageStatus status,
            @RequestParam(required = false) WorkPackagePriority priority,
            @RequestParam(required = false) Long assigneeId,
            @RequestParam(required = false) String openCreateWorkPackageModal,
            @AuthenticationPrincipal User user,
            Model model) {

        Page<WorkPackageDto> workPackages = workPackageService.getWorkPackagesWithFilters(
                projectId, search, type, status, priority, assigneeId, pageable);
        model.addAttribute("workPackages", workPackages);
        model.addAttribute("project", projectService.getProjectById(projectId));
        model.addAttribute("showAdminOption",
                user != null && projectService.canSeeAdminOption(projectId));
        model.addAttribute("canChangeWorkPackageClassification",
                user != null && projectService.canSeeAdminOption(projectId));
        model.addAttribute("currentUserId", user != null ? user.getId() : null);
        model.addAttribute("search", search);
        model.addAttribute("types", WorkPackageType.values());
        model.addAttribute("statuses", WorkPackageStatus.values());
        model.addAttribute("priorities", WorkPackagePriority.values());
        model.addAttribute("users", userService.getAllUsers());
        model.addAttribute("workPackageMembers", projectService.getProjectMembers(projectId));
        if (!model.containsAttribute("createWorkPackageForm")) {
            model.addAttribute("createWorkPackageForm", WorkPackageDto.builder().projectId(projectId).build());
        }
        model.addAttribute("showCreateWorkPackageModal",
                model.containsAttribute("showCreateWorkPackageModal") || openCreateWorkPackageModal != null);

        // Build query string for pagination (preserve filters)
        StringBuilder queryString = new StringBuilder();
        if (search != null && !search.isBlank())
            queryString.append("search=").append(search.trim()).append("&");
        if (type != null)
            queryString.append("type=").append(type.name()).append("&");
        if (status != null)
            queryString.append("status=").append(status.name()).append("&");
        if (priority != null)
            queryString.append("priority=").append(priority.name()).append("&");
        if (assigneeId != null)
            queryString.append("assigneeId=").append(assigneeId).append("&");
        model.addAttribute("queryString",
                queryString.length() > 0 ? queryString.substring(0, queryString.length() - 1) : "");

        return "workpackage/list";
    }

    @GetMapping("/{id}")
    public String viewWorkPackage(@PathVariable Long id,
            @AuthenticationPrincipal User user,
            Model model) {

        WorkPackageDto workPackage = workPackageService.getWorkPackage(id);
        model.addAttribute("workPackage", workPackage);
        model.addAttribute("projectName", workPackage.getProjectName());

        model.addAttribute("comments", commentService.getCommentsForWorkPackage(id, Pageable.unpaged()).getContent());
        model.addAttribute("attachments", attachmentService.getAttachmentsForWorkPackage(id));
        model.addAttribute("timeEntries",
                timeEntryService.getTimeEntriesForWorkPackage(id, Pageable.unpaged()).getContent());
        model.addAttribute("issues", issueService.getByWorkPackgeId(id));

        model.addAttribute("currentUserId", user.getId());
        model.addAttribute("showAdminOption",
                user != null && projectService.canSeeAdminOption(workPackage.getProjectId()));

        return "workpackage/view";
    }

    @GetMapping("/new")
    public String showCreateForm(@RequestParam(required = false) Long projectId) {
        if (projectId != null) {
            return "redirect:/work-packages/project/" + projectId + "?openCreateWorkPackageModal=1";
        }
        return "redirect:/work-packages?openCreateWorkPackageModal=1";
    }

    @PostMapping
    public String createWorkPackage(@ModelAttribute("createWorkPackageForm") @Valid WorkPackageDto workPackageDto,
            BindingResult result,
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) String redirectPath,
            RedirectAttributes redirectAttributes) {

        validateDistinctAssignment(workPackageDto, result);

        if (result.hasErrors()) {
            redirectAttributes.addFlashAttribute("createWorkPackageForm", workPackageDto);
            redirectAttributes.addFlashAttribute(
                    "org.springframework.validation.BindingResult.createWorkPackageForm",
                    result);
            redirectAttributes.addFlashAttribute("showCreateWorkPackageModal", true);
            return "redirect:" + resolveCreateRedirectPath(redirectPath, workPackageDto.getProjectId());
        }

        workPackageService.createWorkPackage(workPackageDto.getProjectId(), workPackageDto);
        redirectAttributes.addFlashAttribute("message", "Work package created");
        return "redirect:" + resolveCreateRedirectPath(redirectPath, workPackageDto.getProjectId());
    }

    @GetMapping("/{id}/edit")
    public String showEditForm(@PathVariable Long id, Model model) {
        WorkPackageDto workPackage = workPackageService.getWorkPackage(id);
        model.addAttribute("workPackage", workPackage);
        populateWorkPackageFormModel(model, workPackage);
        return "workpackage/form";
    }

    @PostMapping("/{id}")
    public String updateWorkPackage(@PathVariable Long id,
            @ModelAttribute("workPackage") @Valid WorkPackageDto dto,
            BindingResult result,
            Model model,
            RedirectAttributes redirectAttributes) {
        validateDistinctAssignment(dto, result);

        if (result.hasErrors()) {
            populateWorkPackageFormModel(model, dto);
            return "workpackage/form";
        }

        workPackageService.updateWorkPackage(id, dto);
        redirectAttributes.addFlashAttribute("message", "Work package updated");
        return "redirect:/work-packages/" + id;
    }

    @PostMapping("/{id}/quick-update")
    public String quickUpdateClassification(@PathVariable Long id,
            @RequestParam WorkPackageType type,
            @RequestParam WorkPackageStatus status,
            @RequestParam WorkPackagePriority priority,
            HttpServletRequest request,
            RedirectAttributes redirectAttributes) {
        workPackageService.updateClassification(id, type, status, priority);
        redirectAttributes.addFlashAttribute("message", "Work package updated");
        String refererPath = extractSafeRefererPath(request);
        if (refererPath != null) {
            return "redirect:" + refererPath;
        }
        return "redirect:/work-packages/" + id;
    }

    @PostMapping("/{id}/status")
    public ResponseEntity<Void> updateStatus(@PathVariable Long id,
            @RequestParam WorkPackageStatus status) {
        workPackageService.updateStatus(id, status);
        return ResponseEntity.ok().build();
    }

    private void addAdminOptionLookup(Model model, Page<WorkPackageDto> workPackages, User user) {
        if (user == null) {
            model.addAttribute("showAdminOption", false);
            model.addAttribute("adminOptionByProjectId", Collections.emptyMap());
            return;
        }

        Map<Long, Boolean> adminOptionByProjectId = workPackages.getContent().stream()
                .map(WorkPackageDto::getProjectId)
                .filter(projectId -> projectId != null)
                .distinct()
                .collect(Collectors.toMap(Function.identity(),
                        projectId -> projectService.canSeeAdminOption(projectId)));

        model.addAttribute("showAdminOption", projectService.canSeeAdminOption(user.getId()));
        model.addAttribute("adminOptionByProjectId", adminOptionByProjectId);
    }

    private String extractSafeRefererPath(HttpServletRequest request) {
        String referer = request.getHeader("Referer");
        if (referer == null || referer.isBlank()) {
            return null;
        }
        try {
            URI uri = URI.create(referer);
            String path = uri.getPath();
            if (path == null || path.isBlank()) {
                return null;
            }

            String contextPath = request.getContextPath();
            if (contextPath != null && !contextPath.isBlank() && path.startsWith(contextPath + "/")) {
                path = path.substring(contextPath.length());
            }

            if (!path.startsWith("/work-packages") && !path.startsWith("/projects")) {
                return null;
            }

            String query = uri.getQuery();
            return (query == null || query.isBlank()) ? path : path + "?" + query;
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    private void populateWorkPackageFormModel(Model model, WorkPackageDto workPackage) {
        model.addAttribute("projectId", workPackage.getProjectId());
        model.addAttribute("projects", projectService.getAllProjectsForParentSelect());
        model.addAttribute("types", WorkPackageType.values());
        model.addAttribute("statuses", WorkPackageStatus.values());
        model.addAttribute("priorities", WorkPackagePriority.values());
        model.addAttribute("projectMembers",
                workPackage.getProjectId() != null
                        ? projectService.getProjectMembers(workPackage.getProjectId())
                        : Collections.emptyList());
    }

    private void validateDistinctAssignment(WorkPackageDto workPackageDto, BindingResult result) {
        if (workPackageDto.getAssigneeId() == null || workPackageDto.getAccountableId() == null) {
            return;
        }

        if (workPackageDto.getAssigneeId().equals(workPackageDto.getAccountableId())) {
            String message = "Assignee and accountable must be different users";
            result.rejectValue("accountableId", "workPackage.accountableId.sameAsAssignee", message);
        }
    }

    private String resolveCreateRedirectPath(String redirectPath, Long projectId) {
        String safePath = sanitizeInternalPath(redirectPath);
        if (safePath != null) {
            return safePath;
        }
        if (projectId != null) {
            return "/work-packages/project/" + projectId;
        }
        return "/work-packages";
    }

    private String sanitizeInternalPath(String path) {
        if (path == null || path.isBlank()) {
            return null;
        }
        if (!path.startsWith("/")) {
            return null;
        }
        if (!path.startsWith("/work-packages") && !path.startsWith("/projects")) {
            return null;
        }
        return path;
    }

    @PostMapping("/{id}/delete")
    public String deleteWorkPackage(@PathVariable Long id,
            HttpServletRequest request,
            RedirectAttributes redirectAttributes) {
        WorkPackageDto workPackageDto = workPackageService.getWorkPackage(id);
        workPackageService.deleteWorkPackage(id);
        redirectAttributes.addFlashAttribute("message", "Work package deleted");

        String refererPath = extractSafeRefererPath(request);
        if (refererPath != null && !refererPath.equals("/work-packages/" + id)
                && !refererPath.startsWith("/work-packages/" + id + "?")) {
            return "redirect:" + refererPath;
        }

        return "redirect:/work-packages/project/" + workPackageDto.getProjectId();
    }

    @GetMapping("/{workPackageId}/issue/new")
    public String newIssueForm(@PathVariable Long workPackageId, Model model) {
        IssueDto issue = IssueDto.builder()
                .issueStatus(IssueStatus.UNRESOLVED)
                .build();

        model.addAttribute("issue", issue);
        model.addAttribute("workPackage", workPackageService.getWorkPackage(workPackageId));

        return "issue/form";
    }

    @PostMapping("/{workPackageId}/issue")
    public String createNewIssue(@ModelAttribute("issue") @Valid IssueDto issueDto,
            BindingResult result,
            @PathVariable Long workPackageId, Model model) {

        if (result.hasErrors()) {
            model.addAttribute("id", issueDto.getId());
            model.addAttribute("title", issueDto.getTitle());
            model.addAttribute("description", issueDto.getDescription());
            return "issue/form";
        }

        issueService.createIssue(issueDto, workPackageId);
        return "redirect:/issues";
    }
}
