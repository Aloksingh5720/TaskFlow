package com.nexabyte.taskflow.controller;

import java.util.List;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.nexabyte.taskflow.dto.activity.ActivityDto;
import com.nexabyte.taskflow.dto.project.ProjectDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.service.ActivityService;
import com.nexabyte.taskflow.service.ProjectService;
import com.nexabyte.taskflow.service.WorkPackageService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final ActivityService activityService;
    private final ProjectService projectService;
    private final WorkPackageService workPackageService;

    @GetMapping
    public String dashboard(@AuthenticationPrincipal User user, Model model) {

        long projectCount = projectService.countAccessibleProjects(user.getId());
        long assignedCount = workPackageService.countAssignedWorkPackages(user.getId());
        long accountableCount = workPackageService.countAccountableWorkPackages(user.getId());
        long overdueCount = workPackageService.countOverdueWorkPackages(user.getId());
        Pageable topTen = PageRequest.of(0, 10, Sort.by(Sort.Direction.DESC, "createdAt"));
        List<ActivityDto> recentActivities = activityService.getRecentUserActivities(user.getId(), topTen);

        model.addAttribute("projectCount", projectCount);
        model.addAttribute("assignedWorkPackageCount", assignedCount);
        model.addAttribute("accountableWorkPackageCount", accountableCount);
        model.addAttribute("overdueCount", overdueCount);
        model.addAttribute("activities", recentActivities);
        model.addAttribute("createProjectForm", new ProjectDto());
        model.addAttribute("parentProjects", projectService.getAllProjectsForParentSelect());

        return "dashboard/index";
    }
}
