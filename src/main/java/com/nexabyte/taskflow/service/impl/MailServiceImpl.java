package com.nexabyte.taskflow.service.impl;

import com.nexabyte.taskflow.dto.mail.MeetingInvitationDto;
import com.nexabyte.taskflow.dto.mail.ProjectAssignmentDto;
import com.nexabyte.taskflow.dto.mail.WorkPackageAssignmentDto;
import com.nexabyte.taskflow.service.MailService;

import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import jakarta.mail.MessagingException;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

@Slf4j
@Service
@RequiredArgsConstructor
public class MailServiceImpl implements MailService {

    private final JavaMailSender javaMailSender;
    private final TemplateEngine templateEngine;

    @Value("${spring.mail.username}")
    private String sender;

    @Async
    @Override
    public void sendProjectAssignmentEmail(String recipient, ProjectAssignmentDto projectDetails) {
        try {
            MimeMessage mimeMessage = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");

            Context context = new Context();
            context.setVariable("name", projectDetails.getName());
            context.setVariable("projectName", projectDetails.getProjectName());
            context.setVariable("role", projectDetails.getRole());
            context.setVariable("manager", projectDetails.getManager());
            context.setVariable("startDate", projectDetails.getStartDate());
            context.setVariable("projectLink", projectDetails.getProjectLink());

            String process = templateEngine.process("project-email", context);

            helper.setFrom(sender);
            helper.setTo(recipient);
            helper.setSubject("Project Assignment: " + projectDetails.getProjectName());
            helper.setText(process, true);

            javaMailSender.send(mimeMessage);
            log.info("Email sent successfully to: {}", recipient);
        } catch (MessagingException e) {
            log.error("Error while sending mail to {}: {}", recipient, e.getMessage());
        }
    }

    @Async
    @Override
    public void sendMeetingInvitationEmail(String recipient, MeetingInvitationDto meetingDetails) {
        try {
            MimeMessage mimeMessage = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");

            Context context = new Context();
            context.setVariable("name", meetingDetails.getName());
            context.setVariable("title", meetingDetails.getTitle());
            context.setVariable("date", meetingDetails.getDate());
            context.setVariable("time", meetingDetails.getTime());
            context.setVariable("duration", meetingDetails.getDuration());
            context.setVariable("link", meetingDetails.getLink());

            String process = templateEngine.process("meeting-email", context);

            helper.setFrom(sender);
            helper.setTo(recipient);
            helper.setSubject("Meeting Invitation: " + meetingDetails.getTitle());
            helper.setText(process, true);

            javaMailSender.send(mimeMessage);
            log.info("Email sent successfully to: {}", recipient);
        } catch (MessagingException e) {
            log.error("Error while sending mail to {}: {}", recipient, e.getMessage());
        }
    }

    @Async
    @Override
    public void sendWorkPackageAssignmentEmail(String recipient, WorkPackageAssignmentDto workPackageDetails) {
        try {
            MimeMessage mimeMessage = javaMailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");

            Context context = new Context();
            context.setVariable("projectId", workPackageDetails.getProjectId());
            context.setVariable("projectName", workPackageDetails.getProjectName());
            context.setVariable("workPackageType", workPackageDetails.getWorkPackageType());
            context.setVariable("workPackageStatus", workPackageDetails.getWorkPackageStatus());
            context.setVariable("workPackagePriority", workPackageDetails.getWorkPackagePriority());
            context.setVariable("assigneeId", workPackageDetails.getAssigneeId());
            context.setVariable("assigneeName", workPackageDetails.getAssigneeName());
            context.setVariable("accountableId", workPackageDetails.getAccountableId());
            context.setVariable("accountableName", workPackageDetails.getAccountableName());
            context.setVariable("subject", workPackageDetails.getSubject());
            context.setVariable("description", workPackageDetails.getDescription());
            context.setVariable("estimatedHours", workPackageDetails.getEstimatedHours());
            context.setVariable("dueDate", workPackageDetails.getDueDate());

            String process = templateEngine.process("workpackage-email", context);

            helper.setFrom(sender);
            helper.setTo(recipient);
            helper.setSubject("WorkPackge Assignment: " + workPackageDetails.getSubject());
            helper.setText(process, true);

            javaMailSender.send(mimeMessage);
            log.info("Email sent successfully to: {}", recipient);
        } catch (MessagingException e) {
            log.error("Error while sending mail to {}: {}", recipient, e.getMessage());
        }
    }
}