package com.nexabyte.taskflow.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.nexabyte.taskflow.dto.attachment.AttachmentDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.exception.ResourceNotFoundException;
import com.nexabyte.taskflow.service.AttachmentService;

import java.io.IOException;

@Controller
@RequestMapping("/work-packages/{workPackageId}/attachments")
@RequiredArgsConstructor
public class AttachmentController {

    private final AttachmentService attachmentService;

    @PostMapping
    public String uploadAttachment(@PathVariable Long workPackageId,
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal User user,
            RedirectAttributes redirectAttributes) throws IOException {
        attachmentService.attachToWorkPackage(workPackageId, file, user.getId());
        redirectAttributes.addFlashAttribute("message", "File uploaded");
        return "redirect:/work-packages/" + workPackageId;
    }

    @GetMapping("/{attachmentId}/file")
    public ResponseEntity<Resource> openAttachment(@PathVariable Long workPackageId,
            @PathVariable Long attachmentId) {
        AttachmentDto attachment = attachmentService.getAttachment(attachmentId);
        assertAttachmentBelongsToWorkPackage(workPackageId, attachment);
        Resource resource = attachmentService.downloadAttachment(attachmentId);
        MediaType mediaType = resolveMediaType(attachment.getContentType());

        return ResponseEntity.ok()
                .contentType(mediaType)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + attachment.getFileName() + "\"")
                .body(resource);
    }

    @GetMapping("/{attachmentId}/download")
    public ResponseEntity<Resource> downloadAttachment(@PathVariable Long workPackageId,
            @PathVariable Long attachmentId) {
        AttachmentDto attachment = attachmentService.getAttachment(attachmentId);
        assertAttachmentBelongsToWorkPackage(workPackageId, attachment);
        Resource resource = attachmentService.downloadAttachment(attachmentId);
        return ResponseEntity.ok()
                .contentType(resolveMediaType(attachment.getContentType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + attachment.getFileName() + "\"")
                .body(resource);
    }

    @PostMapping("/{attachmentId}/delete")
    public String deleteAttachment(@PathVariable Long workPackageId,
            @PathVariable Long attachmentId,
            @AuthenticationPrincipal User user,
            RedirectAttributes redirectAttributes) {
        assertAttachmentBelongsToWorkPackage(workPackageId, attachmentService.getAttachment(attachmentId));
        attachmentService.deleteAttachment(attachmentId, user.getId());
        redirectAttributes.addFlashAttribute("message", "Attachment deleted");
        return "redirect:/work-packages/" + workPackageId;
    }

    private void assertAttachmentBelongsToWorkPackage(Long workPackageId, AttachmentDto attachment) {
        if (!workPackageId.equals(attachment.getWorkPackageId())) {
            throw new ResourceNotFoundException("Attachment not found for work package");
        }
    }

    private MediaType resolveMediaType(String contentType) {
        if (contentType == null || contentType.isBlank()) {
            return MediaType.APPLICATION_OCTET_STREAM;
        }
        try {
            return MediaType.parseMediaType(contentType);
        } catch (IllegalArgumentException ex) {
            return MediaType.APPLICATION_OCTET_STREAM;
        }
    }
}
