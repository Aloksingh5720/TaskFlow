package com.nexabyte.taskflow.service.impl;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.nexabyte.taskflow.constants.GlobalRole;
import com.nexabyte.taskflow.constants.MeetingStatus;
import com.nexabyte.taskflow.constants.ProjectRole;
import com.nexabyte.taskflow.dto.mail.MeetingInvitationDto;
import com.nexabyte.taskflow.dto.meeting.MeetingDto;
import com.nexabyte.taskflow.entities.Meeting;
import com.nexabyte.taskflow.entities.Project;
import com.nexabyte.taskflow.entities.ProjectMember;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.exception.AccessDeniedException;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.mapper.MeetingMapper;
import com.nexabyte.taskflow.repository.MeetingRepository;
import com.nexabyte.taskflow.repository.ProjectMemberRepository;
import com.nexabyte.taskflow.repository.ProjectRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.service.ActivityService;
import com.nexabyte.taskflow.service.MailService;
import com.nexabyte.taskflow.service.MeetingService;
import com.nexabyte.taskflow.utils.SecurityUtils;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MeetingServiceImpl implements MeetingService {

    private final MeetingRepository meetingRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;
    private final ProjectMemberRepository projectMemberRepository;
    private final MailService mailService;
    private final ActivityService activityService;

    @Override
    @Transactional
    public MeetingDto create(Long projectId, MeetingDto meetingDto) {
        Project project = getProjectOrThrow(projectId);
        User currentUser = SecurityUtils.getCurrentUser();
        assertCanEditProjectMeetings(project.getId(), currentUser.getId());

        Meeting meeting = MeetingMapper.toEntity(meetingDto, project,
                resolveParticipants(project, meetingDto.getParticipantIds(), currentUser));
        if (meeting.getMeetingStatus() == null) {
            meeting.setMeetingStatus(MeetingStatus.SCHEDULED);
        }

        Meeting savedMeeting = meetingRepository.save(meeting);
        activityService.recordMeetingCreated(MeetingMapper.toDto(savedMeeting), currentUser.getUsername());
        sendInvitationToParticipants(meeting);
        return populateCreator(MeetingMapper.toDto(meeting));
    }

    @Override
    @Transactional
    public MeetingDto update(Long projectId, Long meetingId, MeetingDto meetingDto) {
        Project project = getProjectOrThrow(projectId);
        Meeting meeting = getMeetingEntity(meetingId);
        User currentUser = getCurrentUser();

        if (!meeting.getProject().getId().equals(project.getId())) {
            throw new ResourceNotFoundException("Meeting", "projectId", projectId.toString());
        }
        assertCanEditProjectMeetings(project.getId(), currentUser.getId());

        Set<Long> oldParticipantIds = meeting.getParticipants().stream().map(User::getId).collect(Collectors.toSet());

        if (meetingDto.getTitle() != null) {
            meeting.setTitle(meetingDto.getTitle());
        }
        if (meetingDto.getDescription() != null) {
            meeting.setDescription(meetingDto.getDescription());
        }
        if (meetingDto.getMeetingLink() != null) {
            meeting.setMeetingLink(meetingDto.getMeetingLink());
        }
        if (meetingDto.getDate() != null) {
            meeting.setDate(meetingDto.getDate());
        }
        if (meetingDto.getStarTime() != null) {
            meeting.setStartTime(meetingDto.getStarTime());
        }
        if (meetingDto.getDuration() != null) {
            meeting.setDuration(meetingDto.getDuration());
        }
        if (meetingDto.getMeetingStatus() != null) {
            meeting.setMeetingStatus(meetingDto.getMeetingStatus());
        }
        if (meetingDto.getParticipantIds() != null) {
            meeting.setParticipants(resolveParticipants(project, meetingDto.getParticipantIds(), currentUser));
        }

        meetingRepository.save(meeting);

        // Send invitations to NEW participants
        if (meetingDto.getParticipantIds() != null) {
            Set<User> newParticipants = meeting.getParticipants().stream()
                    .filter(u -> !oldParticipantIds.contains(u.getId()))
                    .collect(Collectors.toSet());
            sendInvitationToParticipants(meeting, newParticipants);
        }

        return populateCreator(MeetingMapper.toDto(meeting));
    }

    private void sendInvitationToParticipants(Meeting meeting) {
        sendInvitationToParticipants(meeting, meeting.getParticipants());
    }

    private void sendInvitationToParticipants(Meeting meeting, Set<User> participants) {
        for (User participant : participants) {
            MeetingInvitationDto invitationDto = MeetingInvitationDto.builder()
                    .name(participant.getName())
                    .title(meeting.getTitle())
                    .date(meeting.getDate().toString())
                    .time(meeting.getStartTime().toString())
                    .duration(meeting.getDuration() != null ? meeting.getDuration().toString() + " hours" : "")
                    .link(meeting.getMeetingLink())
                    .build();

            mailService.sendMeetingInvitationEmail(participant.getEmail(), invitationDto);
        }
    }

    @Override
    @Transactional
    public void delete(Long meetingId) {
        Meeting meeting = getMeetingEntity(meetingId);
        User currentUser = getCurrentUser();
        assertCanEditProjectMeetings(meeting.getProject().getId(), currentUser.getId());

        meetingRepository.delete(meeting);
    }

    @Override
    @Transactional
    public void addParticipant(Long participantId, Long meetingId) {
        Meeting meeting = getMeetingEntity(meetingId);
        User currentUser = getCurrentUser();
        assertCanEditProjectMeetings(meeting.getProject().getId(), currentUser.getId());

        User participant = getUserOrThrow(participantId);
        assertProjectMembership(meeting.getProject().getId(), participantId);

        meeting.getParticipants().add(participant);
        meetingRepository.save(meeting);

        MeetingInvitationDto invitationDto = MeetingInvitationDto.builder()
                .name(participant.getName())
                .title(meeting.getTitle())
                .date(meeting.getDate().toString())
                .time(meeting.getStartTime().toString())
                .duration(meeting.getDuration() != null ? meeting.getDuration().toString() + " hours" : "")
                .link(meeting.getMeetingLink())
                .build();

        mailService.sendMeetingInvitationEmail(participant.getEmail(), invitationDto);
    }

    @Override
    @Transactional
    public void removeParticipant(Long participantId, Long meetingId) {
        Meeting meeting = getMeetingEntity(meetingId);
        User currentUser = getCurrentUser();
        assertCanEditProjectMeetings(meeting.getProject().getId(), currentUser.getId());

        meeting.getParticipants().removeIf(participant -> participant.getId().equals(participantId));
        if (meeting.getParticipants().isEmpty()) {
            meeting.getParticipants().add(currentUser);
        }
        meetingRepository.save(meeting);
    }

    @Override
    @Transactional
    public void changeStatus(Long meetingId, MeetingStatus meetingStatus) {
        Meeting meeting = getMeetingEntity(meetingId);
        User currentUser = getCurrentUser();
        assertCanEditProjectMeetings(meeting.getProject().getId(), currentUser.getId());

        meeting.setMeetingStatus(meetingStatus);
        meetingRepository.save(meeting);
    }

    @Override
    @Transactional
    public MeetingDto getMeetingById(Long meetingId) {
        Meeting meeting = getMeetingEntity(meetingId);
        User currentUser = getCurrentUser();
        assertCanViewProjectMeetings(meeting.getProject().getId(), currentUser.getId());
        return populateCreator(MeetingMapper.toDto(meeting));
    }

    @Override
    @Transactional
    public List<MeetingDto> getAllMeetingsForUser(Long userId) {

        User user = userRepository.findById(userId).orElseThrow(() -> {
            throw new ResourceNotFoundException("User", "userId", userId.toString());
        });

        List<MeetingDto> meetings = meetingRepository.findAllByParticipantIdOrderByDateDesc(user.getId())
                .stream()
                .map(MeetingMapper::toDto)
                .toList();
        populateCreators(meetings);
        return meetings;
    }

    @Override
    @Transactional
    public List<MeetingDto> getAllMeetingsInProject(Long projectId) {
        User currentUser = getCurrentUser();
        assertCanViewProjectMeetings(projectId, currentUser.getId());

        List<MeetingDto> meetings = meetingRepository.findByProjectIdOrderByDateAscStartTimeAsc(projectId)
                .stream()
                .map(MeetingMapper::toDto)
                .toList();
        populateCreators(meetings);
        return meetings;
    }

    @Override
    public boolean canCreateAndEditMeetings(Long userId) {
        User user = getUserOrThrow(userId);
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;

        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName)) {
            return true;
        }

        return projectMemberRepository.existsByUserIdAndRole_NameIn(userId, List.of(ProjectRole.MANAGER));
    }

    @Override
    public boolean hasMeetingsForUser(Long userId) {
        getUserOrThrow(userId);
        return meetingRepository.existsByParticipantId(userId);
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return (User) authentication.getPrincipal();
    }

    private Project getProjectOrThrow(Long projectId) {
        return projectRepository.findById(projectId).orElseThrow(() -> {
            throw new ResourceNotFoundException("Project", "projectId", String.valueOf(projectId));
        });
    }

    private Meeting getMeetingEntity(Long meetingId) {
        return meetingRepository.findById(meetingId).orElseThrow(() -> {
            throw new ResourceNotFoundException("Meeting", "meetingId", meetingId.toString());
        });
    }

    private User getUserOrThrow(Long userId) {
        return userRepository.findById(userId).orElseThrow(() -> {
            throw new ResourceNotFoundException("User", "userId", userId.toString());
        });
    }

    private Set<User> resolveParticipants(Project project, List<Long> participantIds, User currentUser) {
        Set<Long> resolvedIds = new LinkedHashSet<>();
        if (participantIds != null) {
            resolvedIds.addAll(participantIds);
        }
        resolvedIds.add(currentUser.getId());

        Set<Long> memberIds = project.getProjectMembers().stream()
                .map(ProjectMember::getUser)
                .map(User::getId)
                .collect(Collectors.toSet());

        if (!memberIds.containsAll(resolvedIds)) {
            throw new IllegalArgumentException("Participants must be members of the selected project");
        }

        return resolvedIds.stream()
                .map(this::getUserOrThrow)
                .collect(Collectors.toCollection(LinkedHashSet::new));
    }

    private MeetingDto populateCreator(MeetingDto meetingDto) {
        if (meetingDto.getCreatedBy() != null) {
            userRepository.findById(meetingDto.getCreatedBy())
                    .ifPresent(user -> meetingDto.setCreator(user.getUsername()));
        }
        return meetingDto;
    }

    private void populateCreators(List<MeetingDto> meetings) {
        Set<Long> creatorIds = meetings.stream()
                .map(MeetingDto::getCreatedBy)
                .filter(id -> id != null)
                .collect(Collectors.toSet());

        if (creatorIds.isEmpty()) {
            return;
        }

        Map<Long, String> usernamesById = userRepository.findAllById(creatorIds).stream()
                .collect(Collectors.toMap(User::getId, User::getUsername));

        meetings.forEach(meeting -> {
            if (meeting.getCreatedBy() != null) {
                meeting.setCreator(usernamesById.get(meeting.getCreatedBy()));
            }
        });
    }

    private void assertProjectMembership(Long projectId, Long userId) {
        if (!projectMemberRepository.existsByProjectIdAndUserId(projectId, userId)) {
            throw new AccessDeniedException("You are not a member of this project");
        }
    }

    private void assertCanViewProjectMeetings(Long projectId, Long userId) {
        User user = getUserOrThrow(userId);
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;

        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName)) {
            return;
        }

        assertProjectMembership(projectId, userId);
    }

    private void assertCanEditProjectMeetings(Long projectId, Long userId) {
        User user = getUserOrThrow(userId);
        String globalRoleName = user.getGlobalRole() != null ? user.getGlobalRole().getName() : null;

        if (GlobalRole.SUPER_ADMIN.equals(globalRoleName)) {
            return;
        }

        boolean canEdit = projectMemberRepository.existsByProjectIdAndUserIdAndRole_NameIn(
                projectId,
                userId,
                List.of(ProjectRole.MANAGER));

        if (!canEdit) {
            throw new AccessDeniedException("You do not have permission to schedule meetings for this project");
        }
    }
}
