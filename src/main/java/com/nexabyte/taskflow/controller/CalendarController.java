package com.nexabyte.taskflow.controller;

import java.util.List;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.nexabyte.taskflow.dto.calender.CalendarEventDto;
import com.nexabyte.taskflow.entities.User;
import com.nexabyte.taskflow.service.CalendarService;

import lombok.RequiredArgsConstructor;

@Controller
@RequestMapping("/calendar")
@RequiredArgsConstructor
public class CalendarController {

    private final CalendarService calendarService;

    @GetMapping
    public String showCalendar(@AuthenticationPrincipal User user, Model model) {
        boolean canView = calendarService.canViewCalendar(user.getId());

        if (!canView) {
            return "redirect:/dashboard";
        }

        model.addAttribute("canViewCalendar", canView);
        return "calendar/index";
    }

    @GetMapping("/events")
    @ResponseBody
    public List<CalendarEventDto> getCalendarEvents(@AuthenticationPrincipal User user) {
        return calendarService.getCalendarEventsForUser(user.getId());
    }

    @GetMapping("/project/events")
    @ResponseBody
    public List<CalendarEventDto> getProjectCalendarEvents(
            @RequestParam Long projectId,
            @AuthenticationPrincipal User user) {
        return calendarService.getCalendarEventsForProject(projectId, user.getId());
    }
}
