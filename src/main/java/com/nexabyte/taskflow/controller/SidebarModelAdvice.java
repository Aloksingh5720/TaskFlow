package com.nexabyte.taskflow.controller;

import java.util.Map;

import org.springframework.security.core.Authentication;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.servlet.HandlerMapping;

import com.nexabyte.taskflow.dto.workpackage.WorkPackageDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.service.CalendarService;
import com.nexabyte.taskflow.service.ProjectService;
import com.nexabyte.taskflow.service.WorkPackageService;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;

@ControllerAdvice
@RequiredArgsConstructor
public class SidebarModelAdvice {

    private final ProjectService projectService;
    private final WorkPackageService workPackageService;
    private final CalendarService calendarService;

    @ModelAttribute
    public void populateSidebarFlags(HttpServletRequest request, Authentication authentication, Model model) {
        Long projectId = resolveProjectId(request);
        Long userId = resolveUserId(authentication);

        model.addAttribute("showAdminOption",
                userId != null && (projectId != null
                        ? projectService.canSeeAdminOption(projectId)
                        : projectService.canSeeAdminOption(userId)));
        model.addAttribute("showMeetings", userId != null);
        model.addAttribute("showCalendar", userId != null && calendarService.canViewCalendar(userId));
    }

    private Long resolveUserId(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof User user)) {
            return null;
        }
        return user.getId();
    }

    @SuppressWarnings("unchecked")
    private Long resolveProjectId(HttpServletRequest request) {
        Map<String, String> uriVariables = (Map<String, String>) request
                .getAttribute(HandlerMapping.URI_TEMPLATE_VARIABLES_ATTRIBUTE);

        Long projectId = parseLong(uriVariables != null ? uriVariables.get("projectId") : null);
        if (projectId != null) {
            return projectId;
        }

        String requestUri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String relativeUri = contextPath != null && !contextPath.isBlank() && requestUri.startsWith(contextPath)
                ? requestUri.substring(contextPath.length())
                : requestUri;

        if (relativeUri.startsWith("/projects/")) {
            projectId = parseLong(uriVariables != null ? uriVariables.get("id") : null);
            if (projectId != null) {
                return projectId;
            }
        }

        projectId = parseLong(request.getParameter("projectId"));
        if (projectId != null) {
            return projectId;
        }

        if (relativeUri.startsWith("/work-packages/") && !relativeUri.startsWith("/work-packages/project/")) {
            Long workPackageId = parseLong(uriVariables != null ? uriVariables.get("id") : null);
            if (workPackageId != null) {
                WorkPackageDto workPackage = workPackageService.getWorkPackage(workPackageId);
                return workPackage.getProjectId();
            }
        }

        return null;
    }

    private Long parseLong(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Long.valueOf(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
