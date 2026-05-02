package com.nexabyte.taskflow.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.nexabyte.taskflow.dto.issue.IssueDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.service.IssueService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/issues")
@RequiredArgsConstructor
public class IssueController {

    private final IssueService issueService;

    @GetMapping
    public String listMyIssues(@PageableDefault(size = 10) Pageable pageable,
            @AuthenticationPrincipal User user,
            Model model) {
        Page<IssueDto> raisedIssues = issueService.getIssuesByUser(user.getId(), pageable);
        Page<IssueDto> toResolveIssues = issueService.getIssuesToResolve(user.getId(), pageable);

        model.addAttribute("raisedIssues", raisedIssues);
        model.addAttribute("toResolveIssues", toResolveIssues);
        model.addAttribute("currentUserId", user.getId());
        model.addAttribute("title", "Issues");
        return "issue/list";
    }

    @PostMapping("/{id}/resolve")
    public String resolveIssue(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        issueService.resolveIssue(id);
        redirectAttributes.addFlashAttribute("message", "Issue marked as resolved");
        return "redirect:/issues";
    }
}
