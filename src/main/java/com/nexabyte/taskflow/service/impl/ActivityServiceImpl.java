package com.nexabyte.taskflow.service.impl;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import com.nexabyte.taskflow.dto.activity.ActivityDto;
import com.nexabyte.taskflow.dto.attachment.AttachmentDto;
import com.nexabyte.taskflow.dto.comment.CommentDto;
import com.nexabyte.taskflow.dto.meeting.MeetingDto;
import com.nexabyte.taskflow.dto.project.ProjectDto;
import com.nexabyte.taskflow.dto.projectmember.ProjectMemberDto;
import com.nexabyte.taskflow.dto.workpackage.WorkPackageDto;
import com.nexabyte.taskflow.entities.Activity;
import com.nexabyte.taskflow.entities.Meeting;
import com.nexabyte.taskflow.entities.Project;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.entities.WorkPackage;
import com.nexabyte.taskflow.mapper.ActivityMapper;
import com.nexabyte.taskflow.repository.ActivityRepository;
import com.nexabyte.taskflow.repository.MeetingRepository;
import com.nexabyte.taskflow.repository.ProjectMemberRepository;
import com.nexabyte.taskflow.repository.ProjectRepository;
import com.nexabyte.taskflow.repository.UserRepository;
import com.nexabyte.taskflow.repository.WorkPackageRepository;
import com.nexabyte.taskflow.service.ActivityService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ActivityServiceImpl implements ActivityService {

        private final ActivityRepository activityRepository;
        private final UserRepository userRepository;
        private final ProjectRepository projectRepository;
        private final ProjectMemberRepository projectMemberRepository;
        private final MeetingRepository meetingRepository;
        private final WorkPackageRepository workPackageRepository;

        @Override
        public void recordWorkPackageCreated(WorkPackageDto dto, String actor) {
                String description = String.format("Created work package: %s in project: %s",
                                dto.getSubject(), dto.getProjectName());

                Project project = projectRepository.getReferenceById(dto.getProjectId());
                User assignee = userRepository.getReferenceById(dto.getAssigneeId());
                User accountable = userRepository.getReferenceById(dto.getAccountableId());

                Set<User> recipients = new HashSet<>();
                if (assignee != null) {
                        recipients.add(assignee);
                }
                if (accountable != null) {
                        recipients.add(accountable);
                }

                Activity activity = Activity.builder()
                                .description(description)
                                .project(project)
                                .actor(actor)
                                .users(recipients)
                                .build();

                activityRepository.save(activity);
        }

        @Override
        public void recordWorkPackageUpdated(WorkPackageDto dto, String actor) {
                String description = String.format("Updated work package: %s in project: %s",
                                dto.getSubject(), dto.getProjectName());

                Project project = projectRepository.getReferenceById(dto.getProjectId());
                User assignee = userRepository.getReferenceById(dto.getAssigneeId());
                User accountable = userRepository.getReferenceById(dto.getAccountableId());

                Set<User> recipients = new HashSet<>();
                if (assignee != null) {
                        recipients.add(assignee);
                }
                if (accountable != null) {
                        recipients.add(accountable);
                }

                Activity activity = Activity.builder()
                                .description(description)
                                .project(project)
                                .actor(actor)
                                .users(recipients)
                                .build();

                activityRepository.save(activity);
        }

        @Override
        public void recordWorkPackageDeleted(WorkPackageDto dto, String actor) {
                String description = String.format("Deleted work package: %s in project: %s",
                                dto.getSubject(), dto.getProjectName());

                Project project = projectRepository.getReferenceById(dto.getProjectId());
                User assignee = userRepository.getReferenceById(dto.getAssigneeId());
                User accountable = userRepository.getReferenceById(dto.getAccountableId());

                Set<User> recipients = new HashSet<>();
                if (assignee != null) {
                        recipients.add(assignee);
                }
                if (accountable != null) {
                        recipients.add(accountable);
                }

                Activity activity = Activity.builder()
                                .description(description)
                                .project(project)
                                .actor(actor)
                                .users(recipients)
                                .build();

                activityRepository.save(activity);
        }

        @Override
        public void recordProjectCreated(ProjectDto projectDto, String actor) {
                String description = String.format("Created Project: %s",
                                projectDto.getName());

                Project project = projectRepository.getReferenceById(projectDto.getId());
                Set<User> recipients = projectMemberRepository.findUsersByProjectId(projectDto.getId());

                Activity activity = Activity.builder()
                                .description(description)
                                .project(project)
                                .actor(actor)
                                .users(recipients)
                                .build();

                activityRepository.save(activity);
        }

        @Override
        public void recordProjectUpdated(ProjectDto projectDto, String actor) {
                String description = String.format("Updated Project: %s",
                                projectDto.getName());

                Project project = projectRepository.getReferenceById(projectDto.getId());
                Set<User> recipients = projectMemberRepository.findUsersByProjectId(projectDto.getId());

                Activity activity = Activity.builder()
                                .description(description)
                                .project(project)
                                .actor(actor)
                                .users(recipients)
                                .build();

                activityRepository.save(activity);
        }

        @Override
        public void recordMemberAdded(ProjectDto projectDto, ProjectMemberDto projectMemberDto, String actor) {
                String description = String.format("%s has been added to project: %s",
                                projectMemberDto.getUsername(),
                                projectDto.getName());

                Project project = projectRepository.getReferenceById(projectDto.getId());
                Set<User> recipients = projectMemberRepository.findUsersByProjectId(projectDto.getId());

                Activity activity = Activity.builder()
                                .description(description)
                                .project(project)
                                .actor(actor)
                                .users(recipients)
                                .build();

                activityRepository.save(activity);
        }

        @Override
        public void recordMemberRemoved(ProjectDto projectDto, ProjectMemberDto projectMemberDto, String actor) {
                String description = String.format("%s has been removed from project: %s",
                                projectMemberDto.getUsername(),
                                projectDto.getName());

                Project project = projectRepository.getReferenceById(projectDto.getId());
                Set<User> recipients = projectMemberRepository.findUsersByProjectId(projectDto.getId());
                User removedUser = userRepository.getReferenceById(projectMemberDto.getUserId());
                recipients.add(removedUser);

                Activity activity = Activity.builder()
                                .description(description)
                                .project(project)
                                .actor(actor)
                                .users(recipients)
                                .build();

                activityRepository.save(activity);
        }

        @Override
        public void recordMeetingCreated(MeetingDto meetingDto, String actor) {
                String description = String.format("Meeting: %s has been scheduled in project: %s",
                                meetingDto.getTitle(),
                                meetingDto.getProjectName());

                Meeting meeting = meetingRepository.getReferenceById(meetingDto.getId());
                Project project = meeting.getProject();
                Set<User> recipients = new HashSet<>(meeting.getParticipants());

                Activity activity = Activity.builder()
                                .description(description)
                                .project(project)
                                .actor(actor)
                                .users(recipients)
                                .build();

                activityRepository.save(activity);
        }

        @Override
        public void recordCommentAdded(CommentDto commentDto, String actor) {
                String description = String.format("A new comment has been added in workpackage: %s",
                                commentDto.getWorkPackageSubject());

                WorkPackage workPackage = workPackageRepository.getReferenceById(commentDto.getWorkPackageId());

                Project project = workPackage.getProject();
                User assignee = workPackage.getAssignee();
                User accountable = workPackage.getAccountable();

                Set<User> recipients = new HashSet<>();
                if (assignee != null) {
                        recipients.add(assignee);
                }
                if (accountable != null) {
                        recipients.add(accountable);
                }

                Activity activity = Activity.builder()
                                .description(description)
                                .project(project)
                                .actor(actor)
                                .users(recipients)
                                .build();

                activityRepository.save(activity);
        }

        @Override
        public void recordAttachmentAdded(AttachmentDto attachmentDto, String actor) {
                String description = String.format("A new attachment has been added in workpackage: %s",
                                attachmentDto.getWorkPackageSubject());

                WorkPackage workPackage = workPackageRepository.getReferenceById(attachmentDto.getWorkPackageId());

                Project project = workPackage.getProject();
                User assignee = workPackage.getAssignee();
                User accountable = workPackage.getAccountable();

                Set<User> recipients = new HashSet<>();
                if (assignee != null) {
                        recipients.add(assignee);
                }
                if (accountable != null) {
                        recipients.add(accountable);
                }

                Activity activity = Activity.builder()
                                .description(description)
                                .project(project)
                                .actor(actor)
                                .users(recipients)
                                .build();

                activityRepository.save(activity);
        }

        @Override
        public List<ActivityDto> getRecentUserActivities(Long userId, Pageable pageable) {
                return activityRepository.findByUsers_Id(userId, pageable).stream()
                                .map(ActivityMapper::toDto)
                                .toList();
        }
}
