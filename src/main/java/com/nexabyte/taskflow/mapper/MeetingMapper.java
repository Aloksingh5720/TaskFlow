package com.nexabyte.taskflow.mapper;

import java.util.Set;

import com.nexabyte.taskflow.dto.meeting.MeetingDto;
import com.nexabyte.taskflow.entities.Meeting;
import com.nexabyte.taskflow.entities.Project;
import com.nexabyte.taskflow.entities.User;

public class MeetingMapper {

    public static MeetingDto toDto(Meeting meeting) {
        return MeetingDto.builder()
                .id(meeting.getId())
                .title(meeting.getTitle())
                .description(meeting.getDescription())
                .meetingLink(meeting.getMeetingLink())
                .date(meeting.getDate())
                .starTime(meeting.getStartTime())
                .duration(meeting.getDuration())
                .meetingStatus(meeting.getMeetingStatus())
                .projectId(meeting.getProject() != null ? meeting.getProject().getId() : null)
                .projectName(meeting.getProject() != null ? meeting.getProject().getName() : null)
                .createdBy(meeting.getCreatedBy())
                .participantIds(meeting.getParticipants().stream().map(User::getId).sorted().toList())
                .participantNames(meeting.getParticipants().stream().map(User::getUsername).sorted().toList())
                .build();
    }

    public static Meeting toEntity(MeetingDto meetingDto, Project project, Set<User> participants) {
        return Meeting.builder()
                .id(meetingDto.getId())
                .title(meetingDto.getTitle())
                .description(meetingDto.getDescription())
                .meetingLink(meetingDto.getMeetingLink())
                .date(meetingDto.getDate())
                .startTime(meetingDto.getStarTime())
                .duration(meetingDto.getDuration())
                .meetingStatus(meetingDto.getMeetingStatus())
                .project(project)
                .participants(participants)
                .build();
    }
}
