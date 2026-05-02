package com.nexabyte.taskflow.controller;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.PathVariable;

import com.nexabyte.taskflow.constants.MeetingStatus;
import com.nexabyte.taskflow.constants.GlobalRole;
import com.nexabyte.taskflow.dto.meeting.MeetingDto;
import com.nexabyte.taskflow.dto.project.ProjectDto;
import com.nexabyte.taskflow.dto.projectmember.ProjectMemberDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.service.MeetingService;
import com.nexabyte.taskflow.service.ProjectService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
public class MeetingController {

    private final MeetingService meetingService;
    private final ProjectService projectService;

    @GetMapping("/meetings")
    public String listAllMeetings(@AuthenticationPrincipal User user, Model model) {
        List<MeetingDto> meetings = meetingService.getAllMeetingsForUser(user.getId());
        model.addAttribute("meetings", meetings);
        boolean canCreateMeetings = meetingService.canCreateAndEditMeetings(user.getId());
        model.addAttribute("canCreateMeetings", canCreateMeetings);
        Map<Long, Boolean> canManageMeetingsByProject = getManageabilityLookup(meetings, user);
        model.addAttribute("canManageMeetingsByProject", canManageMeetingsByProject);
        model.addAttribute("showMeetingActions", canManageMeetingsByProject.containsValue(Boolean.TRUE));
        if (!model.containsAttribute("meeting")) {
            MeetingDto meetingDto = new MeetingDto();
            meetingDto.setMeetingStatus(MeetingStatus.SCHEDULED);
            model.addAttribute("meeting", meetingDto);
        }
        if (!model.containsAttribute("editMeeting")) {
            model.addAttribute("editMeeting", new MeetingDto());
        }
        populateGlobalMeetingFormModel(model, user, canCreateMeetings);
        return "meeting/list";
    }

    @PostMapping("/meetings")
    public String createNewMeeting(
            @Valid @ModelAttribute("meeting") MeetingDto meetingDto,
            BindingResult result,
            @AuthenticationPrincipal User user,
            RedirectAttributes redirectAttributes,
            Model model) {
        if (result.hasErrors()) {
            List<MeetingDto> meetings = meetingService.getAllMeetingsForUser(user.getId());
            model.addAttribute("meetings", meetings);
            model.addAttribute("canCreateMeetings", meetingService.canCreateAndEditMeetings(user.getId()));
            Map<Long, Boolean> canManageMeetingsByProject = getManageabilityLookup(meetings, user);
            model.addAttribute("canManageMeetingsByProject", canManageMeetingsByProject);
            model.addAttribute("showMeetingActions", canManageMeetingsByProject.containsValue(Boolean.TRUE));
            model.addAttribute("showCreateMeetingModal", true);
            if (!model.containsAttribute("editMeeting")) {
                model.addAttribute("editMeeting", new MeetingDto());
            }
            populateGlobalMeetingFormModel(model, user, meetingService.canCreateAndEditMeetings(user.getId()));
            return "meeting/list";
        }

        meetingService.create(meetingDto.getProjectId(), meetingDto);
        redirectAttributes.addFlashAttribute("message", "Meeting scheduled");
        return "redirect:/meetings";
    }

    @PostMapping("/meetings/{id}")
    public String updateMeeting(@PathVariable Long id,
            @Valid @ModelAttribute("editMeeting") MeetingDto meetingDto,
            BindingResult result,
            @AuthenticationPrincipal User user,
            RedirectAttributes redirectAttributes,
            Model model) {
        if (result.hasErrors()) {
            List<MeetingDto> meetings = meetingService.getAllMeetingsForUser(user.getId());
            model.addAttribute("meetings", meetings);
            model.addAttribute("canCreateMeetings", meetingService.canCreateAndEditMeetings(user.getId()));
            Map<Long, Boolean> canManageMeetingsByProject = getManageabilityLookup(meetings, user);
            model.addAttribute("canManageMeetingsByProject", canManageMeetingsByProject);
            model.addAttribute("showMeetingActions", canManageMeetingsByProject.containsValue(Boolean.TRUE));
            model.addAttribute("showEditMeetingModal", true);
            if (!model.containsAttribute("meeting")) {
                MeetingDto createMeetingDto = new MeetingDto();
                createMeetingDto.setMeetingStatus(MeetingStatus.SCHEDULED);
                model.addAttribute("meeting", createMeetingDto);
            }
            populateGlobalMeetingFormModel(model, user, meetingService.canCreateAndEditMeetings(user.getId()));
            return "meeting/list";
        }

        meetingService.update(meetingDto.getProjectId(), id, meetingDto);
        redirectAttributes.addFlashAttribute("message", "Meeting updated");
        return "redirect:/meetings";
    }

    @PostMapping("/meetings/{id}/delete")
    public String deleteMeeting(@PathVariable Long id,
            RedirectAttributes redirectAttributes) {
        meetingService.delete(id);
        redirectAttributes.addFlashAttribute("message", "Meeting deleted");
        return "redirect:/meetings";
    }

    @PostMapping("/meetings/{id}/status")
    public String updateMeetingStatus(@PathVariable Long id,
            @RequestParam MeetingStatus meetingStatus,
            RedirectAttributes redirectAttributes) {
        meetingService.changeStatus(id, meetingStatus);
        redirectAttributes.addFlashAttribute("message", "Meeting status updated");
        return "redirect:/meetings";
    }

    private void populateGlobalMeetingFormModel(Model model, User user, boolean canCreateMeetings) {
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;
        List<ProjectDto> availableProjects = Collections.emptyList();
        Map<Long, List<ProjectMemberDto>> projectMembersByProject = Collections.emptyMap();

        if (canCreateMeetings) {
            availableProjects = GlobalRole.SUPER_ADMIN.equals(globalRoleName)
                    ? projectService.getAllProjectsForParentSelect()
                    : projectService.getAllProjectsWhereUserIsManager(user.getId());

            projectMembersByProject = availableProjects.stream()
                    .collect(Collectors.toMap(
                            ProjectDto::getId,
                            project -> projectService.getProjectMembers(project.getId())));
        }

        model.addAttribute("meetingStatuses", MeetingStatus.values());
        model.addAttribute("currentUserId", user.getId());
        model.addAttribute("availableProjects", availableProjects);
        model.addAttribute("projectMembersByProject", projectMembersByProject);
    }

    private Map<Long, Boolean> getManageabilityLookup(List<MeetingDto> meetings, User user) {
        return meetings.stream()
                .map(MeetingDto::getProjectId)
                .distinct()
                .collect(Collectors.toMap(Function.identity(),
                        projectId -> projectService.canManageProject(projectId)));
    }
}
