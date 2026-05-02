package com.nexabyte.taskflow.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.nexabyte.taskflow.dto.comment.CommentDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.service.CommentService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/work-packages/{workPackageId}/comments")
@RequiredArgsConstructor
public class CommentController {

	private final CommentService commentService;

	@PostMapping
	public String addComment(@PathVariable Long workPackageId, @ModelAttribute CommentDto commentDto,
			@AuthenticationPrincipal User user, RedirectAttributes redirectAttributes) {

		commentService.addComment(workPackageId, commentDto, user.getId());
		redirectAttributes.addFlashAttribute("message", "Comment added");
		return "redirect:/work-packages/" + workPackageId;
	}

	@PostMapping("/{commentId}/delete")
	public String deleteComment(@PathVariable Long workPackageId, @PathVariable Long commentId,
			@AuthenticationPrincipal User user, RedirectAttributes redirectAttributes) {

		commentService.deleteComment(commentId, user.getId());
		redirectAttributes.addFlashAttribute("message", "Comment deleted");
		return "redirect:/work-packages/" + workPackageId;
	}
}