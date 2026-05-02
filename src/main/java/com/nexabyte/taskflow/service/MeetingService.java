package com.nexabyte.taskflow.service;

import java.util.List;

import com.nexabyte.taskflow.constants.MeetingStatus;
import com.nexabyte.taskflow.dto.meeting.MeetingDto;

public interface MeetingService {

    MeetingDto create(Long projectId, MeetingDto meetingDto);

    MeetingDto update(Long projectId, Long meetingId, MeetingDto meetingDto);

    void delete(Long meetingId);

    void addParticipant(Long participantId, Long meetingId);

    void removeParticipant(Long participantId, Long meetingId);

    void changeStatus(Long meetingId, MeetingStatus meetingStatus);

    MeetingDto getMeetingById(Long meetingId);

    List<MeetingDto> getAllMeetingsForUser(Long userId);

    List<MeetingDto> getAllMeetingsInProject(Long projectId);

    boolean canCreateAndEditMeetings(Long userId);

    boolean hasMeetingsForUser(Long userId);
}
