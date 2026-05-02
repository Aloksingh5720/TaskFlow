package com.nexabyte.taskflow.service.impl;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.nexabyte.taskflow.constants.GlobalRole;
import com.nexabyte.taskflow.constants.ProjectRole;
import com.nexabyte.taskflow.dto.calender.CalendarEventDto;
import com.nexabyte.taskflow.entities.Project;
import com.nexabyte.taskflow.entities.ProjectMember;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.entities.WorkPackage;
import com.nexabyte.taskflow.entities.Meeting;
import com.nexabyte.taskflow.repository.MeetingRepository;
import com.nexabyte.taskflow.repository.ProjectMemberRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.repository.WorkPackageRepository;
import com.nexabyte.taskflow.service.CalendarService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CalendarServiceImpl implements CalendarService {

    private final WorkPackageRepository workPackageRepository;
    private final MeetingRepository meetingRepository;
    private final ProjectMemberRepository projectMemberRepository;
    private final UserRepository userRepository;

    @Override
    public List<CalendarEventDto> getCalendarEventsForUser(Long userId) {
        User user = getUserOrThrow(userId);
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;

        List<CalendarEventDto> events = new ArrayList<>();

        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName)) {
            events.addAll(getAllWorkPackageEvents());
            events.addAll(getAllMeetingEvents());
        } else {
            List<Long> managerProjectIds = getManagerProjectIds(userId);
            List<Long> memberProjectIds = getMemberProjectIds(userId);

            events.addAll(getWorkPackageEventsForProjects(managerProjectIds, userId, true));
            events.addAll(getWorkPackageEventsForProjects(memberProjectIds, userId, false));
            events.addAll(getMeetingEventsForUser(userId, memberProjectIds));
        }

        return deduplicateEvents(events);
    }

    @Override
    public List<CalendarEventDto> getCalendarEventsForProject(Long projectId, Long userId) {
        User user = getUserOrThrow(userId);
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;

        if (!GlobalRole.SUPER_ADMIN.equals(globalRoleName)) {
            assertProjectAccess(projectId, userId);
        }

        boolean canViewAllWorkPackages = GlobalRole.SUPER_ADMIN.equals(globalRoleName)
                || projectMemberRepository.existsByProjectIdAndUserIdAndRole_Name(projectId, userId,
                        ProjectRole.MANAGER);

        List<CalendarEventDto> events = new ArrayList<>();
        events.addAll(getWorkPackageEventsForProject(projectId, userId, canViewAllWorkPackages));
        events.addAll(getMeetingEventsForProject(projectId));

        return deduplicateEvents(events);
    }

    @Override
    public boolean canViewCalendar(Long userId) {
        getUserOrThrow(userId);
        return true;
    }

    private List<CalendarEventDto> getAllWorkPackageEvents() {
        List<WorkPackage> workPackages = workPackageRepository.findAll();
        return workPackages.stream()
                .map(this::convertWorkPackageToEvent)
                .collect(Collectors.toList());
    }

    private List<CalendarEventDto> getAllMeetingEvents() {
        List<Meeting> meetings = meetingRepository.findAll();
        return meetings.stream()
                .map(this::convertMeetingToEvent)
                .collect(Collectors.toList());
    }

    private List<Long> getManagerProjectIds(Long userId) {
        return projectMemberRepository.findByUserIdAndRole_Name(userId, ProjectRole.MANAGER)
                .stream()
                .map(ProjectMember::getProject)
                .map(Project::getId)
                .distinct()
                .collect(Collectors.toList());
    }

    private List<Long> getMemberProjectIds(Long userId) {
        return projectMemberRepository.findByUserId(userId)
                .stream()
                .map(ProjectMember::getProject)
                .map(Project::getId)
                .distinct()
                .collect(Collectors.toList());
    }

    private List<CalendarEventDto> getWorkPackageEventsForProjects(List<Long> projectIds, Long userId,
            boolean isManager) {
        if (projectIds.isEmpty()) {
            return new ArrayList<>();
        }
        List<WorkPackage> workPackages = workPackageRepository
                .findByProjectIdIn(projectIds, org.springframework.data.domain.Pageable.unpaged()).getContent();
        return workPackages.stream()
                .filter(wp -> isManager || isWorkPackageVisible(wp, userId))
                .map(this::convertWorkPackageToEvent)
                .collect(Collectors.toMap(
                        event -> buildEventKey(event),
                        event -> event,
                        (existing, replacement) -> existing,
                        LinkedHashMap::new))
                .values()
                .stream()
                .collect(Collectors.toList());
    }

    private boolean isWorkPackageVisible(WorkPackage workPackage, Long userId) {
        return (workPackage.getAssignee() != null && workPackage.getAssignee().getId().equals(userId)) ||
                (workPackage.getAccountable() != null && workPackage.getAccountable().getId().equals(userId));
    }

    private List<CalendarEventDto> getMeetingEventsForUser(Long userId, List<Long> projectIds) {
        return meetingRepository.findAllByParticipantIdOrderByDateDesc(userId)
                .stream()
                .filter(m -> projectIds.contains(m.getProject().getId()))
                .map(this::convertMeetingToEvent)
                .collect(Collectors.toMap(
                        event -> buildEventKey(event),
                        event -> event,
                        (existing, replacement) -> existing,
                        LinkedHashMap::new))
                .values()
                .stream()
                .collect(Collectors.toList());
    }

    private List<CalendarEventDto> getWorkPackageEventsForProject(Long projectId, Long userId, boolean canViewAll) {
        List<WorkPackage> workPackages = workPackageRepository
                .findByProjectId(projectId, org.springframework.data.domain.Pageable.unpaged()).getContent();
        return workPackages.stream()
                .filter(workPackage -> canViewAll || isWorkPackageVisible(workPackage, userId))
                .map(this::convertWorkPackageToEvent)
                .collect(Collectors.toList());
    }

    private List<CalendarEventDto> getMeetingEventsForProject(Long projectId) {
        List<Meeting> meetings = meetingRepository.findByProjectIdOrderByDateAscStartTimeAsc(projectId);
        return meetings.stream()
                .map(this::convertMeetingToEvent)
                .collect(Collectors.toList());
    }

    private CalendarEventDto convertWorkPackageToEvent(WorkPackage workPackage) {
        // For all-day events in FullCalendar, endDate must be exclusive (next day)
        LocalDate endDate = workPackage.getDueDate() != null ? workPackage.getDueDate().plusDays(1) : null;

        return CalendarEventDto.builder()
                .id(workPackage.getId())
                .title("[" + workPackage.getWorkPackageType() + "] " + workPackage.getSubject())
                .description(workPackage.getDescription())
                .startDate(workPackage.getDueDate())
                .endDate(endDate)
                .eventType("WORK_PACKAGE")
                .projectId(workPackage.getProject().getId())
                .projectName(workPackage.getProject().getName())
                .url("/work-packages/" + workPackage.getId())
                .status(workPackage.getWorkPackageStatus() != null ? workPackage.getWorkPackageStatus().name() : null)
                .priority(workPackage.getWorkPackagePriority().name())
                .assigneeName(workPackage.getAssignee() != null ? workPackage.getAssignee().getName() : "Unassigned")
                .allDay("true")
                .build();
    }

    private CalendarEventDto convertMeetingToEvent(Meeting meeting) {
        // For FullCalendar, endDate must be exclusive (next day for all-day, or end
        // time for timed events)
        LocalDate endDate = meeting.getDate() != null ? meeting.getDate().plusDays(1) : null;

        // Create ISO datetime strings for timed events
        String startDateTime = null;
        String endDateTime = null;
        if (meeting.getDate() != null && meeting.getStartTime() != null) {
            startDateTime = meeting.getDate().atTime(meeting.getStartTime()).toString();
            if (meeting.getDuration() != null) {
                endDateTime = meeting.getDate()
                        .atTime(meeting.getStartTime().plusMinutes((long) (meeting.getDuration().doubleValue() * 60)))
                        .toString();
            }
        }

        return CalendarEventDto.builder()
                .id(meeting.getId())
                .title("[MEETING] " + meeting.getTitle())
                .description(meeting.getDescription())
                .startDate(meeting.getDate())
                .endDate(endDate)
                .startTime(meeting.getStartTime())
                .endTime(meeting.getDuration() != null
                        ? meeting.getStartTime().plusMinutes((long) (meeting.getDuration().doubleValue() * 60))
                        : null)
                .startDateTime(startDateTime)
                .endDateTime(endDateTime)
                .eventType("MEETING")
                .projectId(meeting.getProject().getId())
                .projectName(meeting.getProject().getName())
                .url("/meetings")
                .status(meeting.getMeetingStatus() != null ? meeting.getMeetingStatus().name() : "SCHEDULED")
                .assigneeName(String.join(", ",
                        meeting.getParticipants().stream().map(User::getName).collect(Collectors.toList())))
                .allDay("false")
                .build();
    }

    private User getUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));
    }

    private void assertProjectAccess(Long projectId, Long userId) {
        User user = getUserOrThrow(userId);
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;

        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName)) {
            return;
        }

        boolean hasAccess = projectMemberRepository.existsByProjectIdAndUserId(projectId, userId);
        if (!hasAccess) {
            throw new SecurityException("You do not have access to this project");
        }
    }

    private List<CalendarEventDto> deduplicateEvents(List<CalendarEventDto> events) {
        return new ArrayList<>(events.stream()
                .collect(Collectors.toMap(
                        this::buildEventKey,
                        event -> event,
                        (existing, replacement) -> existing,
                        LinkedHashMap::new))
                .values());
    }

    private String buildEventKey(CalendarEventDto event) {
        return event.getEventType() + ":" + event.getId();
    }
}
