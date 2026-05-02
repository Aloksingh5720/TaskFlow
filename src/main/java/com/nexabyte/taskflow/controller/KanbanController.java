package com.nexabyte.taskflow.controller;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import com.nexabyte.taskflow.constants.GlobalRole;
import com.nexabyte.taskflow.constants.ProjectRole;
import com.nexabyte.taskflow.constants.WorkPackagePriority;
import com.nexabyte.taskflow.constants.WorkPackageStatus;
import com.nexabyte.taskflow.constants.WorkPackageType;
import com.nexabyte.taskflow.dto.project.ProjectDto;
import com.nexabyte.taskflow.dto.workpackage.WorkPackageDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.service.ProjectService;
import com.nexabyte.taskflow.service.WorkPackageService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class KanbanController {

    private final WorkPackageService workPackageService;
    private final ProjectService projectService;

    @GetMapping("/projects/{projectId}/kanban")
    public String getKanbanBoard(@PathVariable Long projectId,
            @org.springframework.web.bind.annotation.RequestParam(required = false) String openCreateWorkPackageModal,
            @AuthenticationPrincipal User user,
            Model model) {

        ProjectDto project = projectService.getProjectById(projectId);
        List<WorkPackageStatus> statuses = List.of(WorkPackageStatus.values());

        Map<WorkPackageStatus, List<WorkPackageDto>> workPackagesByStatus = new LinkedHashMap<>();

        for (WorkPackageStatus status : statuses) {
            List<WorkPackageDto> cards = workPackageService.getAllWorkPackagesByStatusIncludingChildren(projectId,
                    status);
            workPackagesByStatus.put(status, cards);
        }

        model.addAttribute("project", project);
        model.addAttribute("statuses", statuses);
        model.addAttribute("types", WorkPackageType.values());
        model.addAttribute("priorities", WorkPackagePriority.values());
        model.addAttribute("workPackagesByStatus", workPackagesByStatus);
        model.addAttribute("canDragWorkPackages", canDragWorkPackages(projectId, user));
        model.addAttribute("showAdminOption", projectService.canSeeAdminOption(projectId));
        model.addAttribute("workPackageMembers", projectService.getProjectMembers(projectId));
        if (!model.containsAttribute("createWorkPackageForm")) {
            model.addAttribute("createWorkPackageForm", WorkPackageDto.builder().projectId(projectId).build());
        }
        model.addAttribute("showCreateWorkPackageModal",
                model.containsAttribute("showCreateWorkPackageModal") || openCreateWorkPackageModal != null);
        return "kanban/board";
    }

    private boolean canDragWorkPackages(Long projectId, User user) {
        if (projectId == null || user == null) {
            return false;
        }

        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;
        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName) || GlobalRole.ADMIN.equals(globalRoleName)) {
            return true;
        }

        return projectService.getProjectMembers(projectId).stream()
                .anyMatch(member -> user.getId().equals(member.getUserId())
                        && !ProjectRole.VIEWER.equals(member.getRole()));
    }
}
