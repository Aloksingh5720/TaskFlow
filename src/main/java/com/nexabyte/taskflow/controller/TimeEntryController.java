package com.nexabyte.taskflow.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.nexabyte.taskflow.dto.timeentry.TimeEntryDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.service.TimeEntryService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/work-packages/{workPackageId}/time-entries")
@RequiredArgsConstructor
public class TimeEntryController {

    private final TimeEntryService timeEntryService;

    @GetMapping("/new")
    public String showForm(@PathVariable Long workPackageId, Model model) {
        model.addAttribute("timeEntry", new TimeEntryDto());
        return "timeentry/form";
    }

    @PostMapping
    public String logTime(@PathVariable Long workPackageId,
            @ModelAttribute TimeEntryDto dto,
            @AuthenticationPrincipal User user,
            RedirectAttributes redirectAttributes) {
        timeEntryService.logTime(workPackageId, dto, user.getId());
        redirectAttributes.addFlashAttribute("message", "Time logged");
        return "redirect:/work-packages/" + workPackageId;
    }

    @GetMapping("/{entryId}/edit")
    public String editForm(@PathVariable Integer workPackageId, @PathVariable Long entryId, Model model) {
        model.addAttribute("timeEntry", timeEntryService.getTimeEntry(entryId));
        return "timeentry/form";
    }

    @PostMapping("/{entryId}")
    public String updateTimeEntry(@PathVariable Long workPackageId,
            @PathVariable Long entryId,
            @ModelAttribute TimeEntryDto dto,
            @AuthenticationPrincipal User user,
            RedirectAttributes redirectAttributes) {
        timeEntryService.updateTimeEntry(entryId, dto, user.getId());
        redirectAttributes.addFlashAttribute("message", "Time entry updated");
        return "redirect:/work-packages/" + workPackageId;
    }

    @PostMapping("/{entryId}/delete")
    public String deleteTimeEntry(@PathVariable Long workPackageId,
            @PathVariable Long entryId,
            @AuthenticationPrincipal User user,
            RedirectAttributes redirectAttributes) {
        timeEntryService.deleteTimeEntry(entryId, user.getId());
        redirectAttributes.addFlashAttribute("message", "Time entry deleted");
        return "redirect:/work-packages/" + workPackageId;
    }
}