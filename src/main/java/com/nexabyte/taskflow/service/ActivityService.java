package com.nexabyte.taskflow.service;

import java.util.List;

import org.springframework.data.domain.Pageable;

import com.nexabyte.taskflow.dto.activity.ActivityDto;
import com.nexabyte.taskflow.dto.attachment.AttachmentDto;
import com.nexabyte.taskflow.dto.comment.CommentDto;
import com.nexabyte.taskflow.dto.meeting.MeetingDto;
import com.nexabyte.taskflow.dto.project.ProjectDto;
import com.nexabyte.taskflow.dto.projectmember.ProjectMemberDto;
import com.nexabyte.taskflow.dto.workpackage.WorkPackageDto;

public interface ActivityService {

    void recordWorkPackageCreated(WorkPackageDto workPackageDto, String actor);

    void recordWorkPackageUpdated(WorkPackageDto workPackageDto, String actor);

    void recordWorkPackageDeleted(WorkPackageDto workPackageDto, String actor);

    void recordProjectCreated(ProjectDto projectDto, String actor);

    void recordProjectUpdated(ProjectDto projectDto, String actor);

    void recordMemberAdded(ProjectDto projectDto, ProjectMemberDto projectMemberDto, String actor);

    void recordMemberRemoved(ProjectDto projectDto, ProjectMemberDto projectMemberDto, String actor);

    void recordMeetingCreated(MeetingDto meetingDto, String actor);

    void recordCommentAdded(CommentDto commentDto, String actor);

    void recordAttachmentAdded(AttachmentDto attachmentDto, String actor);

    List<ActivityDto> getRecentUserActivities(Long userId, Pageable pageable);
}
