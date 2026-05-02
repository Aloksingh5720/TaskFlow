package com.nexabyte.taskflow.service;

import com.nexabyte.taskflow.dto.mail.MeetingInvitationDto;
import com.nexabyte.taskflow.dto.mail.ProjectAssignmentDto;
import com.nexabyte.taskflow.dto.mail.WorkPackageAssignmentDto;

public interface MailService {

    void sendProjectAssignmentEmail(String recipient, ProjectAssignmentDto projectDetails);

    void sendMeetingInvitationEmail(String recipient, MeetingInvitationDto meetingDetails);

    void sendWorkPackageAssignmentEmail(String recipient, WorkPackageAssignmentDto workPackageDetails);
}
